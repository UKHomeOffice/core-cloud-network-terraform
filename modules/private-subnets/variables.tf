
variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to AWS resources"
}
