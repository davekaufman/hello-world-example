variable "app_name" {
  type        = string
  description = "the app name. defaults to 'hello-world'"
  default     = "hello-world"
}

variable "app_cpu" {
  type        = number
  description = "number of CPU units to assign to the app"
  default     = null
}

variable "app_mem" {
  type        = number
  description = "amount of memory in MB to assign to the app"
  default     = null
}

variable "app_port" {
  type        = number
  description = "the port number the app container listens on"
  default     = null
}

variable "create_hosted_zone" {
  type        = bool
  description = "whether to create new a route53 hosted zone. defaults to false"
  default     = false
}

variable "buildtime" {
  type        = string
  description = "build time in epoch seconds. used to tag image"
  default     = null
}

variable "environment" {
  type        = string
  description = "environment name"
  default     = null
}

variable "hosted_zone_name" {
  type        = string
  description = "the domain name to assign to the new route53 hosted zone"
  default     = null
}

variable "issue_acm_certificate" {
  type        = bool
  description = "whether a new ACM cert should be issued for use with teh load balancer. when true, cert CN will be app_name.hosted_zone_name"
  default     = false
}

variable "org_name" {
  type        = string
  description = "the organization name."
  default     = null
}

variable "database_subnet_cidr_blocks" {
  type        = list(any)
  description = "the cidr blocks for the database subnets to create."
}

variable "private_subnet_cidr_blocks" {
  type        = list(any)
  description = "the cidr blocks for the private subnets to create."
}

variable "public_subnet_cidr_blocks" {
  type        = list(any)
  description = "the cidr blocks for the public subnets to create."
}

variable "tags" {
  type        = map(any)
  description = "list of tags that should be added to all resources"
  default     = {}
}

variable "vpc_cidr_block" {
  type        = string
  description = "the cidr block of the vpc to create."
}
