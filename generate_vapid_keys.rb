require 'webpush'

vapid_key = Webpush.generate_key

puts "Add or update secrets.auto.tfvars with the following:\n"

puts "vapid_public_key = \"#{vapid_key.public_key}\""
puts "vapid_private_key = \"#{vapid_key.private_key}\""
