environment = "dev"
org_name = "yourcompany"
vpc_cidr_block = "10.1.0.0/16"


# /22 gives just over 1000 usable IPs per subnet.  3 subnets per class, deliberately leave the 4th undefined for expansion into a future AZ if desired.
# sure, you can have terraform do this automatically with cidrsubnet and mask bits, but I find that's less clear
public_subnet_cidr_blocks = [
  "10.1.0.0/22",
  "10.1.4.0/22",
  "10.1.8.0/22",
]

private_subnet_cidr_blocks = [
  "10.1.16.0/22",
  "10.1.20.0/22",
  "10.1.24.0/22",
]

database_subnet_cidr_blocks = [
  "10.1.32.0/22",
  "10.1.36.0/22",
  "10.1.40.0/22",
]

tags = {
    environment = "dev"
    created_by  = "terraform"
  }
