
variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to AWS resources"
}

variable "eks_cluster1_name" {
  description = "EKS Cluster 1 Name"
  type        = string
}

variable "eks_cluster2_name" {
  description = "EKS Cluster 2 Name"
  type        = string
}

variable "tgw_id" {
  description = "TGW Id"
  type        = string
}

variable "tag_vpc_name" {
  description = "Sets the value of a tag called VpcName on the VPC"
  type        = string
  default     = ""
}