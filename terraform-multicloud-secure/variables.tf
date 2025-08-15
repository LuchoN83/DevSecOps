variable "name_prefix" {
  description = "Prefijo común para nombrar recursos."
  type        = string
  default     = "devsecops"
}

variable "aws_region" {
  description = "Región de AWS."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR para la VPC en AWS."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs para subnets públicas."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs para subnets privadas."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "azure_subscription_id" {
  description = "Subscription ID de Azure."
  type        = string
}

variable "azure_location" {
  description = "Ubicación/región de Azure."
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags aplicadas a los recursos."
  type        = map(string)
  default     = {
    owner = "lucho"
    env   = "sandbox"
  }
}
