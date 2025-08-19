# 📌 Proyecto 1 – terraform-multicloud-secure

### 🎯 Objetivo
Desplegar infraestructura básica y segura en **AWS** y **Azure** utilizando Terraform, aplicando buenas prácticas de seguridad, modularidad y control de estado.

---

## 🏗 Arquitectura
```mermaid
flowchart LR
    Dev(DevSecOps Engineer) -->|Terraform Apply| Backend[(Remote Backend S3/Azure Blob)]
    Backend --> AWS[(AWS Cloud)]
    Backend --> Azure[(Azure Cloud)]
    AWS --> VPC1[VPC Privada + Subnets]
    Azure --> RG1[Resource Group + Key Vault]
