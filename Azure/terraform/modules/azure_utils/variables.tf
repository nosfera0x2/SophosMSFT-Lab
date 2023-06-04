# azure_utils module: variables.tf

variable "azure_region" {
  type        = string
  description = "Azure Region standard name, CLI name or slug format"
  default     = null
}