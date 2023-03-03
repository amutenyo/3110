terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.56.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}

#new vpc
resource "aws_vpc" "tf-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tf-vpc"
  }
}

#subnet
resource "aws_subnet" "tf-subnet" {
  vpc_id     = aws_vpc.tf-vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "tf-subnet"
  }
}

#security group
resource "aws_security_group" "tf-sg" {
  name   = "tf-sg"
  vpc_id = aws_vpc.tf-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "tf-sg"
  }
}

# gateway
resource "aws_internet_gateway" "tf-ig" {
  vpc_id = aws_vpc.tf-vpc.id
  tags = {
    Name = "tf-ig"
  }
}

#route table
resource "aws_route_table" "tf-r" {
  vpc_id = aws_vpc.tf-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-ig.id
  }
  tags = {
    Name = "tf-rt"
  }
}

# associate the route table with my subnet
resource "aws_route_table_association" "tf-r-subnet" {
  subnet_id      = aws_subnet.tf-subnet.id
  route_table_id = aws_route_table.tf-r.id
}

#ssh key pair
resource "aws_key_pair" "tf-key" {
  key_name   = "tf-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDnjdkWxtsAZAkj9sSrcXmfESElMHqHdPROFF+LJZD9juF3E2TPdfY0Gg6foAwgZwOeHBhJWGd/xc5PEFG0tsRcCdXqdvkLKJYaKWyx6uVkMTRhHTKQoTF+Z3oTkUdaQXBtidhT8T5fQKgoiGrQwsts0gIIQUZOMo4ym/YQBXVKtUhP29O6dJrfTqOWCkFryzKeLorfcYEShqlyObdrXj0C+zTVs1Vp+x/ESKfeq8CRMU/m+zu+CqyCKFlMCHoTZa6XxxR2RT+JOoSTo0zvOx6O66M1PLY8Ze3LHjof4RVvw9S47Mkojur447tnazeRsBqijxLwLY6fLKYtzJmJ3Qp3 d00407449@desdemona"
  tags = {
    Name = "tf-key"
  }
}

# Create three EC2 instances
resource "aws_instance" "dev" {
  ami                         = "ami-0557a15b87f6559cf"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.tf-subnet.id
  key_name                    = aws_key_pair.tf-key.key_name
  associate_public_ip_address = true
  security_groups             = [aws_security_group.tf-sg.id]

  user_data = <<-EOF
    #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
EOF
}

resource "aws_instance" "test" {
  ami                         = "ami-0557a15b87f6559cf"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.tf-subnet.id
  key_name                    = aws_key_pair.tf-key.key_name
  associate_public_ip_address = true
  security_groups             = [aws_security_group.tf-sg.id]

  user_data = <<-EOF
     #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
EOF
}

resource "aws_instance" "prod" {
  ami                         = "ami-0557a15b87f6559cf"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.tf-subnet.id
  key_name                    = aws_key_pair.tf-key.key_name
  associate_public_ip_address = true
  security_groups             = [aws_security_group.tf-sg.id]

  user_data = <<-EOF
 #!/bin/bash
         wget http://computing.utahtech.edu/it/3110/notes/2021/terraform/install.sh -O /tmp/install.sh
         chmod +x /tmp/install.sh
         source /tmp/install.sh
EOF
}

output "dev_instance_public_ip" {
  value = aws_instance.dev.public_ip
}

output "test_instance_public_ip" {
  value = aws_instance.test.public_ip
}

output "prod_instance_public_ip" {
  value = aws_instance.prod.public_ip
}
