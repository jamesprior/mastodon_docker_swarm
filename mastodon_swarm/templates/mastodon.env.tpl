# Service dependencies
# You may set REDIS_URL instead for more advanced options
# You may also set REDIS_NAMESPACE to share Redis between multiple Mastodon servers
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=${redis_pw}
# You may set DATABASE_URL instead for more advanced options
DB_HOST=db
DB_USER=mastodon
POSTGRES_USER=mastodon
DB_NAME=mastodon_production
POSTGRES_DB=mastodon_production
DB_PASS=${postgres_pw}
POSTGRES_PASSWORD=${postgres_pw}
DB_PORT=5432
# Optional ElasticSearch configuration
# ES_ENABLED=true
# ES_HOST=es
# ES_PORT=9200

# Federation
# Note: Changing LOCAL_DOMAIN at a later time will cause unwanted side effects, including breaking all existing federation.
# LOCAL_DOMAIN should *NOT* contain the protocol part of the domain e.g https://example.com.
LOCAL_DOMAIN=${swarm_hostname}

# Changing LOCAL_HTTPS in production is no longer supported. (Mastodon will always serve https:// links)

# Use this only if you need to run mastodon on a different domain than the one used for federation.
# You can read more about this option on https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Serving_a_different_domain.md
# DO *NOT* USE THIS UNLESS YOU KNOW *EXACTLY* WHAT YOU ARE DOING.
# WEB_DOMAIN=mastodon.example.com

# Use this if you want to have several aliases handler@example1.com
# handler@example2.com etc. for the same user. LOCAL_DOMAIN should not
# be added. Comma separated values
# ALTERNATE_DOMAINS=example1.com,example2.com

# Application secrets
# Generate each with the `RAILS_ENV=production bundle exec rake secret` task (`docker-compose run --rm web rake secret` if you use docker compose)
SECRET_KEY_BASE=${secret_key_base}
OTP_SECRET=${otp_secret}

# VAPID keys (used for push notifications
# You can generate the keys using the following command (first is the private key, second is the public one)
# You should only generate this once per instance. If you later decide to change it, all push subscription will
# be invalidated, requiring the users to access the website again to resubscribe.
#
# Generate with `RAILS_ENV=production bundle exec rake mastodon:webpush:generate_vapid_key` task (`docker-compose run --rm web rake mastodon:webpush:generate_vapid_key` if you use docker compose)
#
# For more information visit https://rossta.net/blog/using-the-web-push-api-with-vapid.html
VAPID_PRIVATE_KEY=${vapid_private_key}
VAPID_PUBLIC_KEY=${vapid_public_key}

# Registrations
# Single user mode will disable registrations and redirect frontpage to the first profile
# SINGLE_USER_MODE=true
# Prevent registrations with following e-mail domains
# EMAIL_DOMAIN_BLACKLIST=example1.com|example2.de|etc
# Only allow registrations with the following e-mail domains
# EMAIL_DOMAIN_WHITELIST=example1.com|example2.de|etc

# Optionally change default language
# DEFAULT_LOCALE=de

# E-mail configuration
# Note: Mailgun and SparkPost (https://sparkpo.st/smtp) each have good free tiers
# If you want to use an SMTP server without authentication (e.g local Postfix relay)
# then set SMTP_AUTH_METHOD and SMTP_OPENSSL_VERIFY_MODE to 'none' and
# *comment* SMTP_LOGIN and SMTP_PASSWORD (leaving them blank is not enough).
SMTP_SERVER=${smtp_server}
SMTP_PORT=${smtp_port}
SMTP_LOGIN=${smtp_login}
SMTP_PASSWORD=${smtp_password}
SMTP_FROM_ADDRESS=${smtp_from_address}
#SMTP_DOMAIN= # defaults to LOCAL_DOMAIN
#SMTP_DELIVERY_METHOD=smtp # delivery method can also be sendmail
#SMTP_AUTH_METHOD=plain
#SMTP_CA_FILE=/etc/ssl/certs/ca-certificates.crt
#SMTP_OPENSSL_VERIFY_MODE=peer
#SMTP_ENABLE_STARTTLS_AUTO=true
#SMTP_TLS=true

# Optional user upload path and URL (images, avatars). Default is :rails_root/public/system. If you set this variable, you are responsible for making your HTTP server (eg. nginx) serve these files.
# PAPERCLIP_ROOT_PATH=/var/lib/mastodon/public-system
# PAPERCLIP_ROOT_URL=/system

# Optional asset host for multi-server setups
# The asset host must allow cross origin request from WEB_DOMAIN or LOCAL_DOMAIN
# if WEB_DOMAIN is not set. For example, the server may have the
# following header field:
# Access-Control-Allow-Origin: https://example.com/
# CDN_HOST=https://assets.example.com

# S3 (optional)
# The attachment host must allow cross origin request from WEB_DOMAIN or
# LOCAL_DOMAIN if WEB_DOMAIN is not set. For example, the server may have the
# following header field:
# Access-Control-Allow-Origin: https://192.168.1.123:9000/
# S3_ENABLED=true
# S3_BUCKET=
# AWS_ACCESS_KEY_ID=
# AWS_SECRET_ACCESS_KEY=
# S3_REGION=
# S3_PROTOCOL=http
# S3_HOSTNAME=192.168.1.123:9000

# S3 (Minio Config (optional) Please check Minio instance for details)
# The attachment host must allow cross origin request - see the description
# above.
# S3_ENABLED=true
# S3_BUCKET=
# AWS_ACCESS_KEY_ID=
# AWS_SECRET_ACCESS_KEY=
# S3_REGION=
# S3_PROTOCOL=https
# S3_HOSTNAME=
# S3_ENDPOINT=
# S3_SIGNATURE_VERSION=

# This is configured for Digital Ocean spaces
S3_ENABLED=true
S3_BUCKET=${s3_bucket}
AWS_ACCESS_KEY_ID=${aws_access_key_id}
AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}
S3_REGION=${s3_region}
S3_PROTOCOL=${s3_protocol}
S3_HOSTNAME=${s3_hostname}
S3_ENDPOINT=${s3_protocol}://${s3_hostname}
S3_ALIAS_HOST=${s3_alias_host}


# Swift (optional)
# The attachment host must allow cross origin request - see the description
# above.
# SWIFT_ENABLED=true
# SWIFT_USERNAME=
# For Keystone V3, the value for SWIFT_TENANT should be the project name
# SWIFT_TENANT=
# SWIFT_PASSWORD=
# Some OpenStack V3 providers require PROJECT_ID (optional)
# SWIFT_PROJECT_ID=
# Keystone V2 and V3 URLs are supported. Use a V3 URL if possible to avoid
# issues with token rate-limiting during high load.
# SWIFT_AUTH_URL=
# SWIFT_CONTAINER=
# SWIFT_OBJECT_URL=
# SWIFT_REGION=
# Defaults to 'default'
# SWIFT_DOMAIN_NAME=
# Defaults to 60 seconds. Set to 0 to disable
# SWIFT_CACHE_TTL=

# Optional alias for S3 if you want to use Cloudfront or Cloudflare in front
# S3_CLOUDFRONT_HOST=

# Streaming API integration
# STREAMING_API_BASE_URL=

# Advanced settings
# If you need to use pgBouncer, you need to disable prepared statements:
# PREPARED_STATEMENTS=false

# Cluster number setting for streaming API server.
# If you comment out following line, cluster number will be `numOfCpuCores - 1`.
STREAMING_CLUSTER_NUM=1

# Docker mastodon user
# If you use Docker, you may want to assign UID/GID manually.
# UID=1000
# GID=1000

# LDAP authentication (optional)
# LDAP_ENABLED=true
# LDAP_HOST=localhost
# LDAP_PORT=389
# LDAP_METHOD=simple_tls
# LDAP_BASE=
# LDAP_BIND_DN=
# LDAP_PASSWORD=
# LDAP_UID=cn
# LDAP_SEARCH_FILTER="%%{uid}=%%{email}"

# PAM authentication (optional)
# PAM authentication uses for the email generation the "email" pam variable
# and optional as fallback PAM_DEFAULT_SUFFIX
# The pam environment variable "email" is provided by:
# https://github.com/devkral/pam_email_extractor
# PAM_ENABLED=true
# Fallback email domain for email address generation (LOCAL_DOMAIN by default)
# PAM_EMAIL_DOMAIN=example.com
# Name of the pam service (pam "auth" section is evaluated)
# PAM_DEFAULT_SERVICE=rpam
# Name of the pam service used for checking if an user can register (pam "account" section is evaluated) (nil (disabled) by default)
# PAM_CONTROLLED_SERVICE=rpam

# Global OAuth settings (optional) :
# If you have only one strategy, you may want to enable this
# OAUTH_REDIRECT_AT_SIGN_IN=true

# Optional CAS authentication (cf. omniauth-cas) :
# CAS_ENABLED=true
# CAS_URL=https://sso.myserver.com/
# CAS_HOST=sso.myserver.com/
# CAS_PORT=443
# CAS_SSL=true
# CAS_VALIDATE_URL=
# CAS_CALLBACK_URL=
# CAS_LOGOUT_URL=
# CAS_LOGIN_URL=
# CAS_UID_FIELD='user'
# CAS_CA_PATH=
# CAS_DISABLE_SSL_VERIFICATION=false
# CAS_UID_KEY='user'
# CAS_NAME_KEY='name'
# CAS_EMAIL_KEY='email'
# CAS_NICKNAME_KEY='nickname'
# CAS_FIRST_NAME_KEY='firstname'
# CAS_LAST_NAME_KEY='lastname'
# CAS_LOCATION_KEY='location'
# CAS_IMAGE_KEY='image'
# CAS_PHONE_KEY='phone'

# Optional SAML authentication (cf. omniauth-saml)
# SAML_ENABLED=true
# SAML_ACS_URL=
# SAML_ISSUER=http://localhost:3000/auth/auth/saml/callback
# SAML_IDP_SSO_TARGET_URL=https://idp.testshib.org/idp/profile/SAML2/Redirect/SSO
# SAML_IDP_CERT=
# SAML_IDP_CERT_FINGERPRINT=
# SAML_NAME_IDENTIFIER_FORMAT=
# SAML_CERT=
# SAML_PRIVATE_KEY=
# SAML_SECURITY_WANT_ASSERTION_SIGNED=true
# SAML_SECURITY_WANT_ASSERTION_ENCRYPTED=true
# SAML_SECURITY_ASSUME_EMAIL_IS_VERIFIED=true
# SAML_ATTRIBUTES_STATEMENTS_UID="urn:oid:0.9.2342.19200300.100.1.1"
# SAML_ATTRIBUTES_STATEMENTS_EMAIL="urn:oid:1.3.6.1.4.1.6923.1.1.1.6"
# SAML_ATTRIBUTES_STATEMENTS_FULL_NAME="urn:oid:2.16.840.1.113730.3.1.241"
# SAML_ATTRIBUTES_STATEMENTS_FIRST_NAME="urn:oid:2.5.4.42"
# SAML_ATTRIBUTES_STATEMENTS_LAST_NAME="urn:oid:2.5.4.4"
# SAML_UID_ATTRIBUTE="urn:oid:0.9.2342.19200300.100.1.1"
# SAML_ATTRIBUTES_STATEMENTS_VERIFIED=
# SAML_ATTRIBUTES_STATEMENTS_VERIFIED_EMAIL=

# Use HTTP proxy for outgoing request (optional)
# http_proxy=http://gateway.local:8118
# Access control for hidden service.
# ALLOW_ACCESS_TO_HIDDEN_SERVICE=true
