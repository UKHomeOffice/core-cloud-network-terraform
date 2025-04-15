output "subnet_names_and_cidrs" {
  value = {
    for subnet in aws_subnet.private :
    subnet.tags["Name"] => {
      name = subnet.tags["Name"]
      cidr = subnet.cidr_block
      id   = subnet.id
    }
  }
}
