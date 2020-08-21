variable "region" { default = "us-west-2" }
variable "availability_zone" { default = "us-west-2a" }
variable "root_zone" {}
variable "owner" {}

# The name of the key to use for SSH access.
# You can create it via Terraform (in which case you can reference it directly or through the UI (which is what I did here)
# Either way, check the private_key field in lightsail.tf to make sure it points to the right location.
variable "key_name" {}

variable "services" { type = map(string) }
