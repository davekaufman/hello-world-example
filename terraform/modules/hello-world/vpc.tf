# Pretty bog-standard vpc setup with public/private/database subnets
# you could get all of this and more by using the public terraform vpc module - deliberately elected not to for this exercise to demonstrate understanding of vpc creation and resource dependencies
#
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block
  tags = merge(
    {
      Name = var.app_name
    },
    var.tags
  )
}

resource "aws_subnet" "public" {
  count             = length(toset(var.public_subnet_cidr_blocks))
  vpc_id            = aws_vpc.this.id
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  cidr_block        = element(var.public_subnet_cidr_blocks, count.index)
  tags = merge(
    {
      Name = "${var.app_name} public subnet"
    },
    var.tags
  )
}

resource "aws_subnet" "private" {
  count             = length(toset(var.private_subnet_cidr_blocks))
  vpc_id            = aws_vpc.this.id
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  cidr_block        = element(var.private_subnet_cidr_blocks, count.index)
  tags = merge(
    {
      Name = "${var.app_name} private subnet"
    },
    var.tags
  )
}

resource "aws_subnet" "database" {
  count             = length(toset(var.database_subnet_cidr_blocks))
  vpc_id            = aws_vpc.this.id
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  cidr_block        = element(var.database_subnet_cidr_blocks, count.index)
  tags = merge(
    {
      Name = "${var.app_name} database subnet"
    },
    var.tags
  )
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table_association" "public" {
  count          = length(toset(var.public_subnet_cidr_blocks))
  route_table_id = aws_route_table.public.id
  subnet_id      = element(aws_subnet.public.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = length(toset(var.public_subnet_cidr_blocks))
  route_table_id = aws_route_table.private.id
  subnet_id      = element(aws_subnet.private.*.id, count.index)
}

resource "aws_route_table_association" "database" {
  count          = length(toset(var.public_subnet_cidr_blocks))
  route_table_id = aws_route_table.database.id
  subnet_id      = element(aws_subnet.database.*.id, count.index)
}

resource "aws_eip" "nat" {
  vpc = true
  tags = merge(
    {
      Name = "${var.app_name} nat eip"
    },
    var.tags
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    {
      Name = var.app_name
    },
    var.tags
  )
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on    = [aws_internet_gateway.this]
  tags = merge(
    {
      Name = var.app_name
    },
    var.tags
  )
}

resource "aws_route" "igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route" "db_nat" {
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}
