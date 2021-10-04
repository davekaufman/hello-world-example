module "hello_world" {
  source = "./modules/hello-world" # in a non-test example, this would more properly be a git repo with a tagged version or other identifier to a specific revision

  environment                 = var.environment
  org_name                    = var.org_name
  vpc_cidr_block              = var.vpc_cidr_block
  database_subnet_cidr_blocks = var.database_subnet_cidr_blocks
  private_subnet_cidr_blocks  = var.private_subnet_cidr_blocks
  public_subnet_cidr_blocks   = var.public_subnet_cidr_blocks
  create_hosted_zone          = var.create_hosted_zone
  hosted_zone_name            = var.hosted_zone_name
  issue_acm_certificate       = var.issue_acm_certificate
  tags                        = var.tags
}
