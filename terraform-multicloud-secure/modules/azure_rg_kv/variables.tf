variable "location" {
  type        = string
  description = "Región de Azure."
}

variable "rg_name" {
  type        = string
  description = "Nombre del Resource Group."
}

variable "kv_name" {
  type        = string
  description = "Nombre del Key Vault (único globalmente en Azure)."
}

variable "tags" {
  type        = map(string)
  description = "Tags para recursos Azure."
  default     = {}
}