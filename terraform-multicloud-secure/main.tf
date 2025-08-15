terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Backend por defecto: S3 (AWS). Los valores se pasan vía -backend-config
  backend "s3" {}

  # --- Alternativa Azure Blob (comentado) ---
  # backend "azurerm" {}
}

provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

# --- Módulo AWS: VPC + subnets ---
module "aws_vpc" {
  source         = "./modules/aws_vpc"
  name_prefix    = var.name_prefix
  vpc_cidr       = var.vpc_cidr
  public_cidrs   = var.public_subnet_cidrs
  private_cidrs  = var.private_subnet_cidrs
  aws_tags       = var.tags
}

# --- Módulo Azure: RG + KeyVault ---
module "azure_rg_kv" {
  source      = "./modules/azure_rg_kv"
  location    = var.azure_location
  rg_name     = "${var.name_prefix}-rg"
  kv_name     = "${var.name_prefix}-kv"
  tags        = var.tags
}
