// security group 생성
// Outbound : all 허용
// Inbound  : ssh 접속만 허용
resource "aws_security_group" "bastion_sg" {
  name = "value"
  description = "value"
  vpc_id = "value"

  ingress {
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
    cidr_blocks   = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.cluster_name}-bastion-sg"
  }
}

// key pair 생성
resource "aws_key_pair" "bastion_key" {
  key_name = "bastion_key"
  public_key = file("~/.ssh/test-eks-bastion.pub")
}

// bastion용 ec2 instance 생성
resource "aws_instance" "bastion_ec2" {
  ami =             "ami-0078a04747667d409" // ubuntu 19.04 ami-id
  subnet_id         = element(module.vpc.public_subnets, 0)
  instance_type     = "t2.micro"
  key_name          = aws_key_pair.bastion_key.key_name
  availability_zone = "ap-northeast-2a"
  host_id           = "test_eks_bastion"
  private_ip        = "192.168.1.10"
  
  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id,
  ]

  tags = {
    Name = "test_eks_bastion"
  }
}