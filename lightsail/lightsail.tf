provider "aws" {
  region = var.region
}

# XXX: Lightsail only allows ports 80 and 22 by default. You need to manually allow port 443 through the UI (because there's no way to do it via Terraform).
# see: https://stackoverflow.com/q/52487543

resource "aws_lightsail_instance" "server" {
  for_each          = var.services
  name              = "${each.key}-instance"
  availability_zone = var.availability_zone
  blueprint_id      = each.value["blueprint_id"]
  # Choose your instance size here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lightsail_instance#bundles
  bundle_id     = each.value["bundle_id"]
  key_pair_name = var.key_name
  tags = {
    owner = var.owner
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip_address
    private_key = file("~/.ssh/${var.key_name}.pem")
  }
}

resource "aws_lightsail_static_ip" "ip" {
  for_each = var.services
  name     = "${each.key}-ip"
}

resource "aws_lightsail_static_ip_attachment" "attachment" {
  for_each       = var.services
  static_ip_name = aws_lightsail_static_ip.ip[each.key].id
  instance_name  = aws_lightsail_instance.server[each.key].id
}

# Domain
data "aws_route53_zone" "domain_zone" {
  name         = var.root_zone
  private_zone = false
}

resource "aws_route53_record" "server_record" {
  for_each = var.services
  zone_id  = data.aws_route53_zone.domain_zone.zone_id
  name     = each.value["domain"]
  type     = "A"
  ttl      = 60
  records  = [aws_lightsail_static_ip.ip[each.key].ip_address]
}

# resource "aws_route53_record" "wildcard_record" {
#   zone_id = data.aws_route53_zone.domain_zone.zone_id
#   name    = "*.${var.domain}"
#   type    = "CNAME"
#   ttl     = 300
#   records = [aws_route53_record.server_record.name]
# }
