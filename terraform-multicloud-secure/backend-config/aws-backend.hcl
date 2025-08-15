bucket         = "terraform-states-mcs"
key            = "multicloud/devsecops/terraform.tfstate"
region         = "us-east-2"
dynamodb_table = "terraform-locks-mcs"
encrypt        = true
