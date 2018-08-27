data "template_file" "mastodon_stack" {
  template = "${file("templates/mastodon.yml.tpl")}"
  vars {
    do_tag             = "${digitalocean_tag.project_name.name}"
  }
}

data "template_file" "mastodon_env" {
  template = "${file("templates/mastodon_env.production.tpl")}"
  vars {
    do_tag             = "${digitalocean_tag.project_name.name}"
  }
}


resource "null_resource" "mastodon_stack" {
  provisioner "local-exec" {
    command = "cat > mastodon.yml <<EOL\n${data.template_file.mastodon_stack.rendered}\nEOL"
  }
  
  provisioner "local-exec" {
    command = "cat > mastodon_env.production <<EOL\n${data.template_file.mastodon_env.rendered}\nEOL"
  }
  
}
