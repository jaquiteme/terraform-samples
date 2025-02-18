variable "resource_group_name" {
  type        = string
  description = "Name of the resource group provided."
}

variable "prefix" {
  type        = string
  description = "Prefix to be used for all resources."
}

variable "storage_account_tier" {
  type        = string
  default     = "Standard"
  description = "Storage account tier to be used for storing the remote state."
}

variable "storage_account_replication_type" {
  type        = string
  default     = "LRS"
  description = "Storage account replication type to be used."
}

variable "storage_account_sku" {
  type        = string
  default     = "StorageV2"
  description = "Storage account sku to be used."
}


variable "remote_state_delete_retention_days" {
  type        = number
  default     = 30
  description = "Delete retention days to be applied on the remote state storage"
}

variable "default_tags" {
  type        = object()
  default     = {}
  description = "Default tags to be applied"
}
