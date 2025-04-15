variable "tags" {
  type        = map(string)
  description = "Tags to apply to AWS resources"
}

variable "private_main_subnet_a_id" {
  description = "Private Subnet Zone-A id"
  type        = string
}

variable "private_main_subnet_a_name" {
  description = "Private Subnet Zone-A Name"
  type        = string
}
