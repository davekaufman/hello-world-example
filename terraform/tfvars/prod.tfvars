environment = "prod"
org_name = "daveops"
vpc_cidr_block = "10.0.0.0/16"
create_hosted_zone = true
issue_acm_certificate = true
hosted_zone_name = "test.daveops.org"


# /22 gives just over 1000 usable IPs per subnet.  3 subnets per class, deliberately leave the 4th undefined for expansion into a future AZ if desired.
# sure, you can have terraform do this automatically with cidrsubnet and mask bits, but I find that's less clear
public_subnet_cidr_blocks = [
  "10.0.0.0/22",
  "10.0.4.0/22",
  "10.0.8.0/22",
]

private_subnet_cidr_blocks = [
  "10.0.16.0/22",
  "10.0.20.0/22",
  "10.0.24.0/22",
]

database_subnet_cidr_blocks = [
  "10.0.32.0/22",
  "10.0.36.0/22",
  "10.0.40.0/22",
]

tags = {
    environment = "prod"
    created_by  = "terraform"
  }
