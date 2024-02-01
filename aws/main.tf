resource "aws_vpc" "prnVPC" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub1" {
    vpc_id = aws_vpc.prnVPC.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
  
}
resource "aws_subnet" "sub2" {
    vpc_id = aws_vpc.prnVPC.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = true
  
}

resource "aws_internet_gateway" "prnIGW" {
    vpc_id = aws_vpc.prnVPC.id

    tags = {
    Name = "prnIGW"
  }
  
}

resource "aws_route_table" "prnRT" {
    vpc_id = aws_vpc.prnVPC.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.prnIGW.id
    }
   
    tags = {
    Name = "prnRT"
    }  
  
}

resource "aws_route_table_association" "prnRTASSCO" {
    subnet_id = aws_subnet.sub1.id
    route_table_id = aws_route_table.prnRT.id
  
}


resource "aws_route_table_association" "prnRTASSCO2" {
    subnet_id = aws_subnet.sub2.id
    route_table_id = aws_route_table.prnRT.id
  
}

resource "aws_security_group" "prn-sg" {
  name        = "websg"
  vpc_id      = "${aws_vpc.prnVPC.id}"

  ingress {
    description = "http from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web-sg"
  }
}

resource "aws_s3_bucket" "s3pranay" {
  bucket = "pranay700-sudybshuif-tf-test-bucket"
  tags = {
    Name = "pranayS3"
  }
}

resource "aws_key_pair" "terraform_ec2_key" {
	key_name = "terraform_ec2_key"
	public_key = "${file("id_rsa.pub")}"
}

resource "aws_instance" "firstinstance" {
  ami           = "ami-03f4878755434977f"
  instance_type = "t2.micro"
  key_name = "terraform_ec2_key"
  vpc_security_group_ids = [aws_security_group.prn-sg.id]
  subnet_id = aws_subnet.sub1.id
  user_data = base64encode(file("userdata.sh"))

  tags = {
    Name = "pranyEC2"
  }
}

resource "aws_instance" "secondinstance" {
  ami           = "ami-03f4878755434977f"
  instance_type = "t2.micro"
  key_name = "terraform_ec2_key"
  vpc_security_group_ids = [aws_security_group.prn-sg.id]
  subnet_id = aws_subnet.sub2.id
  user_data = base64encode(file("userdata2.sh"))

  tags = {
    Name = "pranyEC2"
  }
}