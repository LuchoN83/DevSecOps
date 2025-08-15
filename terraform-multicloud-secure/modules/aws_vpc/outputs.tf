output "vpc_id" {
  value       = aws_vpc.this.id
  description = "ID de la VPC."
}

output "public_subnet_ids" {
  value       = [for s in aws_subnet.public : s.id]
  description = "IDs de subnets públicas."
}

output "private_subnet_ids" {
  value       = [for s in aws_subnet.private : s.id]
  description = "IDs de subnets privadas."
}