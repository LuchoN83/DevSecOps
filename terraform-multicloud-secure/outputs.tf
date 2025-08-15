output "aws_vpc_id" {
  description = "ID de la VPC creada en AWS."
  value       = module.aws_vpc.vpc_id
}

output "aws_public_subnets" {
  description = "IDs de subnets públicas."
  value       = module.aws_vpc.public_subnet_ids
}

output "aws_private_subnets" {
  description = "IDs de subnets privadas."
  value       = module.aws_vpc.private_subnet_ids
}

output "azure_resource_group" {
  description = "Nombre del Resource Group en Azure."
  value       = module.azure_rg_kv.resource_group_name
}

output "azure_key_vault_uri" {
  description = "URI del Key Vault (https://..)."
  value       = module.azure_rg_kv.key_vault_uri
}
