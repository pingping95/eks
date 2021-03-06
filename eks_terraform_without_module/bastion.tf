// security group 생성
// Outbound : all 허용
// Inbound  : ssh 접속만 허용
resource "aws_security_group" "bastion_sg" {
  name   = "${var.cluster_name}_bastion_sg"
  vpc_id = aws_vpc.vpc.id

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
    "Name" = "${var.cluster_name}_bastion_sg"
  }
}

// key pair 생성
resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion_key"
  public_key = file("~/.ssh/bastion.pub")
}

// bastion용 ec2 instance 생성
resource "aws_instance" "bastion_ec2" {
  ami               = "ami-006e2f9fa7597680a" // Amazon Linux 2 AMI
  subnet_id         = aws_subnet.public_subnet[0].id
  instance_type     = "t2.micro"
  key_name          = aws_key_pair.bastion_key.key_name
  availability_zone = "ap-northeast-2a"
  private_ip        = "192.168.1.10"

  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id,
  ]

  tags = {
    Name = "${var.cluster_name}_bastion"
  }
}