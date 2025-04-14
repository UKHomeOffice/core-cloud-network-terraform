
resource "aws_nat_gateway" "private_nat" {
  connectivity_type = "private"
  subnet_id         = var.private_main_subnet_a_id

  tags = merge(
    {
      Name = "${var.private_main_subnet_a_name}-natg"
    },
    var.tags
  )
}
