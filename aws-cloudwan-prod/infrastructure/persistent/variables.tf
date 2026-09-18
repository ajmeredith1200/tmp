variable "default_region" {
  description = "Primary region used for AWS Cloud WAN global resources"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment Name"
  type        = string
  default     = "prod"
}

variable "layer" {
  description = "Layer Name"
  type        = string
}