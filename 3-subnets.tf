# -------------------------------------------------------------------
# Subnets (count.index driven, NO locals)
# -------------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element([var.subnet_cidr.private_zone1, var.subnet_cidr.private_zone2], count.index)
  availability_zone       = length(var.availability_zones) >= 2 ? var.availability_zones[count.index] : data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-${length(var.availability_zones) >= 2 ? var.availability_zones[count.index] : data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element([var.subnet_cidr.public_zone1, var.subnet_cidr.public_zone2], count.index)
  availability_zone       = length(var.availability_zones) >= 2 ? var.availability_zones[count.index] : data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-${length(var.availability_zones) >= 2 ? var.availability_zones[count.index] : data.aws_availability_zones.available.names[count.index]}"
  }
}
