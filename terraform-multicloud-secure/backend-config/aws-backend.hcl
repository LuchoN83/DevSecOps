bucket         = "mi-terraform-states"
key            = "multicloud/devsecops/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "mi-terraform-locks"
encrypt        = true
