output "instance_ip" {
  value = {
    for instance in aws_lightsail_instance.server :
    instance.name => instance.public_ip_address
  }
}

output "static_ip" {
  value = {
    for ip in aws_lightsail_static_ip.ip :
    ip.name => ip.ip_address
  }
}
