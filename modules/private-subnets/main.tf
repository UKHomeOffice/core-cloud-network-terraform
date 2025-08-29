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

  # AZ suffixes
  az_suffixes = ["a", "b", "c"]

  tag_vpc_name = trim(var.tag_vpc_name, " ")
}
# Create private /27 subnets in 3 AZs
resource "aws_subnet" "private" {
  count             = length(local.valid_indexes)
  vpc_id            = data.aws_vpc.selected.id
  cidr_block        = cidrsubnet(local.vpc_cidr_block, local.newbits, local.valid_indexes[count.index])
  availability_zone = element(["eu-west-2a", "eu-west-2b", "eu-west-2c"], count.index)

  tags = merge({
    Name = "${var.vpc_name}-private-main-${element(local.az_suffixes, count.index)}"
    },
    var.eks_cluster1_name != "" ? { "kubernetes.io/cluster/${var.eks_cluster1_name}" = "owned" } : null,
    var.eks_cluster2_name != "" ? { "kubernetes.io/cluster/${var.eks_cluster2_name}" = "owned" } : null,
    {
      "kubernetes.io/role/internal-elb" = "1"
  }, var.tags)
}

resource "aws_ec2_tag" "tag-vpc-name" {
  count       = local.tag_vpc_name == "" ? 0 : 1
  resource_id = data.aws_vpc.selected.id
  key         = "VpcName"
  value       = local.tag_vpc_name
}

# Convert subnet list to map for for_each compatibility
locals {
  subnet_map = { for idx, subnet in aws_subnet.private : idx => subnet }
}

# Create route table per subnet
resource "aws_route_table" "main_private_subnet_route_tables" {
  for_each = local.subnet_map

  vpc_id = data.aws_vpc.selected.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.tgw_id
  }

  tags = {
    Name = "${var.vpc_name}-private-main-${element(local.az_suffixes, tonumber(each.key))}"
  }
}

# Associate each subnet with its route table
resource "aws_route_table_association" "main_private_subnets_association" {
  for_each       = local.subnet_map
  subnet_id      = each.value.id
  route_table_id = aws_route_table.main_private_subnet_route_tables[each.key].id
}

# Associate private route tables with S3 VPC endpoint
resource "aws_vpc_endpoint_route_table_association" "main_private_subnets_private_s3" {
  for_each        = local.subnet_map
  vpc_endpoint_id = data.aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.main_private_subnet_route_tables[each.key].id
}

# Associate private route tables with DynamoDB VPC endpoint
resource "aws_vpc_endpoint_route_table_association" "main_private_subnets_private_dynamodb" {
  for_each        = local.subnet_map
  vpc_endpoint_id = data.aws_vpc_endpoint.dynamodb.id
  route_table_id  = aws_route_table.main_private_subnet_route_tables[each.key].id
}

# Private NAT Gateways

resource "aws_nat_gateway" "private_nat_gw" {
  for_each          = local.subnet_map
  connectivity_type = "private"
  subnet_id         = each.value.id
  tags = {
    Name = "${var.vpc_name}-private-main-${element(local.az_suffixes, tonumber(each.key))}"
  }
}
