variable "name_prefix" {
  type        = string
  description = "Prefijo para nombrar recursos."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR de la VPC."
}

variable "public_cidrs" {
  type        = list(string)
  description = "CIDRs para subnets públicas."
}

variable "private_cidrs" {
  type        = list(string)
  description = "CIDRs para subnets privadas."
}

variable "aws_tags" {
  type        = map(string)
  description = "Tags para recursos AWS."
  default     = {}
}