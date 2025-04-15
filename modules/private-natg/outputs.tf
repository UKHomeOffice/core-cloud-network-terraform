output "nat_gateway_name" {
  value = aws_nat_gateway.private_nat.tags["Name"]
}

output "nat_gateway_id" {
  value = aws_nat_gateway.private_nat.id
}
