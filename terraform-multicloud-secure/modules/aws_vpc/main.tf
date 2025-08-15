resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.aws_tags, { Name = "${var.name_prefix}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.aws_tags, { Name = "${var.name_prefix}-igw" })
}

# Subnets públicas
resource "aws_subnet" "public" {
  for_each          = toset(var.public_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.key
  map_public_ip_on_launch = true
  tags = merge(var.aws_tags, {
    Name = "${var.name_prefix}-public-${replace(each.key, "/.*", "")}"
    Tier = "public"
  })
}

# Subnets privadas
resource "aws_subnet" "private" {
  for_each   = toset(var.private_cidrs)
  vpc_id     = aws_vpc.this.id
  cidr_block = each.key
  tags = merge(var.aws_tags, {
    Name = "${var.name_prefix}-private-${replace(each.key, "/.*", "")}"
    Tier = "private"
  })
}

# Tabla de rutas pública con salida a Internet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.aws_tags, { Name = "${var.name_prefix}-rtb-public" })
}

# Asociaciones de subnets públicas
resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}