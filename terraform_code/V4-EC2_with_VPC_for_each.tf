provider "aws" {
  region = "us-east-1"
  access_key = "AKIAUD2BZOX56EUIE64U"
  secret_key = "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"

}

resource "aws_instance" "web" {
    ami                    = "ami-0c7217cdde317cfec"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.dpp-public_subent_01.id
    vpc_security_group_ids = [aws_security_group.demo-sg.id]
for_each = toset(["jenkins_master", "build_slave", "ansible"])
   tags = {
     Name = "${each.key}"
   }
}



resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"
  vpc_id = aws_vpc.dpp-vpc.id
  
  ingress {
    description      = "Shh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ssh-prot"

  }
}

  resource "aws_vpc" "dpp-vpc" {
       cidr_block = "10.1.0.0/16"
       tags = {
        Name = "dpp-vpc"
     }
   }


  resource "aws_subnet" "dpp-public_subent_01" {
    vpc_id = aws_vpc.dpp-vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
      Name = "dpp-public_subent_01"
    }
}
 
 resource "aws_subnet" "dpp-public_subent_02" {
    vpc_id = aws_vpc.dpp-vpc.id
    cidr_block = "10.1.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1b"
    tags = {
      Name = "dpp-public_subent_02"
    }
}

//Creating an Internet Gateway 
resource "aws_internet_gateway" "dpp-igw" {
    vpc_id = aws_vpc.dpp-vpc.id
    tags = {
      Name = "dpp-igw"
    }
}


 resource "aws_route_table" "dpp-public-rt" {
    vpc_id = aws_vpc.dpp-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dpp-igw.id
    }
    tags = {
      Name = "dpp-public-rt"
    }
}



 resource "aws_route_table_association" "dpp-rta-public-subent-1" {
    subnet_id = aws_subnet.dpp-public_subent_01.id
    route_table_id = aws_route_table.dpp-public-rt.id
}