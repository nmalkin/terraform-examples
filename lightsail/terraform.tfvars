owner       = "your_username_here"
# If you're using Route 53 to manage your domain name, enter the zone name here
root_zone   = ""
services    = {
    "internal_name": {
        "domain": "service.example.com",
        "blueprint_id": "ubuntu_20_04",
        "bundle_id": "nano_2_0"
    },
}
key_name    = "key_name_here"
