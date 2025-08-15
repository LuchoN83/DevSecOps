# 1) Autenticación:
#   - AWS: export AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_DEFAULT_REGION
#   - Azure: az login (y usa la suscripción indicada)

# 2) Inicializa backend (S3 por defecto)
terraform init -backend-config=backend-config/aws-backend.hcl

# 3) Revisa plan con tus variables
cp terraform.tfvars.example terraform.tfvars
terraform plan

# 4) Aplica
terraform apply
