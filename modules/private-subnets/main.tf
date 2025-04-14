# Fetch VPC ID based on its Name tag
data "aws_vpcs" "filtered_vpcs" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_vpc" "selected" {
  id = data.aws_vpcs.filtered_vpcs.ids[0]
}

# Local values to calculate newbits and ensure safe subnet indexing
locals {
  vpc_cidr_block     = data.aws_vpc.selected.cidr_block
  vpc_cidr_prefixlen = tonumber(split("/", local.vpc_cidr_block)[1])
  newbits            = 27 - local.vpc_cidr_prefixlen
  max_subnets        = pow(2, local.newbits)

  # Subnet indexes to use (skip 0-1 for LZA or reserved blocks)
  private_subnet_indexes = [2, 3, 4]

  # Validate that we don't exceed the subnet limit
  valid_indexes = [for i in local.private_subnet_indexes : i if i < local.max_subnets]
}

# Create private /27 subnets in 3 AZs
resource "aws_subnet" "private" {
  count             = length(local.valid_indexes)
  vpc_id            = data.aws_vpc.selected.id
  cidr_block        = cidrsubnet(local.vpc_cidr_block, local.newbits, local.valid_indexes[count.index])
  availability_zone = element(["eu-west-2a", "eu-west-2b", "eu-west-2c"], count.index)

  tags = merge({
    Name = "${var.vpc_name}-private-main-subnet-${element(["a", "b", "c"], count.index)}"
  }, var.tags)
}
