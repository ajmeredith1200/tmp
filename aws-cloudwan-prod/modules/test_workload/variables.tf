variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "subnets" {
  type = map(object({
    name = string
    cidr = string
  }))
}

variable "core_network_id" {
  type = string
}

variable "core_network_arn" {
  type = string
}

variable "attach_to_cwan" {
  type = bool
}

variable "attachment_tags" {
  type = map(string)
}

variable "management_cidrs" {
  description = "Management host or network CIDRs allowed to access the workload VM"
  type        = list(string)
}

variable "workload_route_table_name" {
  type = string
}

variable "vm_hostname" {
  type = string
}
variable "vm_instance_name" {
  type = string
}

variable "az1" {
  type = string
}

variable "az2" {
  type = string
}

variable "az3" {
  type = string
}
