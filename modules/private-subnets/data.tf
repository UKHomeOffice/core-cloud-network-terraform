
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



data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

data "aws_vpc_endpoint" "s3" {
  vpc_id       = data.aws_vpc.selected.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
}

data "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = data.aws_vpc.selected.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
}