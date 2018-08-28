# On a manager run : docker stack deploy --compose-file=mastodon.yml mastodon
version: '3'
services:
  db:
    image: postgres:10.5-alpine
    env_file: mastodon_env.production
    networks:
      - internal-net
    labels:
      - traefik.enable=false
    volumes:
      - postgres:/var/lib/postgresql/data
    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 20s
      placement:
        constraints:
          - node.labels.db == true
  redis:
    image: redis:4.0-alpine
    env_file: mastodon_env.production
    volumes:
      - redis:/data
    networks:
      - internal-net
    labels:
      - traefik.enable=false
    command: [
      "redis-server", 
      "--appendonly", "yes", 
      "--bind", "0.0.0.0", 
      "--requirepass", "${redis_pw}"]
    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 10s
      placement:
        constraints:
          - node.labels.redis == true
  traefik:
    image: traefik:1.6-alpine
    ports:
      - "80:80"  
      - "443:443"  
      - "8080:8080" # admin port
    volumes:
      # traefik needs the docker socket in order to work properly
      - /var/run/docker.sock:/var/run/docker.sock
      # no traefik config file is being used
      # http://docs.traefik.io/user-guide/examples/
      - /dev/null:/traefik.toml
      # use a named-volume for certs persistency
      - acme-storage:/etc/traefik/acme 
    networks:
      - traefik-net
      - internal-net
    command: [
        "traefik", 
        "--acme",
        "--acme.acmelogging=true",
        "--acme.caserver=${acme_caserver}",
        "--acme.email=${acme_email}",
        "--acme.entrypoint=https",
        "--acme.httpchallenge",
        "--acme.httpchallenge.entrypoint=http",
        "--acme.ondemand=false",
        "--acme.onhostrule=true",
        "--acme.storage=/etc/traefik/acme/acme.json",
        "--api",
        "--debug",
        "--defaultentrypoints=http,https",
        "--entryPoints=Name:http Address::80 Redirect.EntryPoint:https",
        "--entryPoints=Name:https Address::443 TLS",
        "--docker", 
        "--docker.swarmMode", 
        "--docker.watch", 
        "--docker.domain=${domain_name}",
        "--retry"]
    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 20s
      placement:
        constraints:
          - node.labels.traefik == true
  web:
    image: tootsuite/mastodon:v2.4.4
    env_file: mastodon_env.production
    command: bash -c "rm -f /mastodon/tmp/pids/server.pid; bundle exec rails s -p 3000 -b '0.0.0.0'"
    ports:
      - "3000"
    depends_on:
      - db
      - redis
    volumes:
      - public-system:/mastodon/public/system
    networks:
      - traefik-net
      - internal-net
    deploy:
      mode: replicated
      replicas: 2
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 20s
      labels:
        - "traefik.backend=web"
        - "traefik.port=3000"
        - "traefik.docker.network=mastodon_traefik-net"
        - "traefik.frontend.rule=Host:${domain_name}"
      placement:
        constraints:
          - node.labels.db != true
  streaming:
    image: tootsuite/mastodon:v2.4.4
    env_file: mastodon_env.production
    command: yarn start
    ports:
      - "4000"
    depends_on:
      - db
      - redis
    networks:
      - internal-net
      - traefik-net
    deploy:
      mode: replicated
      replicas: 2
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 20s
      labels:
        - "traefik.port=4000"
        - "traefik.docker.network=mastodon_traefik-net"
        - "traefik.backend=streaming"
        - "traefik.frontend.rule=Host:${domain_name};PathPrefixStrip:/api/v1/streaming"
      placement:
        constraints:
          - node.labels.db != true
  sidekiq:
    image: tootsuite/mastodon:v2.4.4
    env_file: mastodon_env.production
    command: bundle exec sidekiq -q default -q mailers -q pull -q push
    networks:
      - internal-net
    labels:
      - traefik.enable=false
    depends_on:
      - db
      - redis
    volumes:
      - public-system:/mastodon/public/system
    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 10s
      placement:
        constraints:
          - node.labels.db != true
networks:
  internal-net:
    internal: true
  traefik-net:

volumes:
  postgres:
  redis:
  public-system:
  acme-storage: