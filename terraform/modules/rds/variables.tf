variable "project" {
  description = "Project name"
  type        = string
  default     = "petclinic"
}

variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
}

variable "tags" {
  description = "Additional tags to merge onto resources"
  type        = map(string)
  default     = {}
}
