# NAT GW 내에서 사용할 Elastic IP Reserve하기
resource "aws_eip" "nat_gw_elastic_ip" {
  vpc = true

  tags = {
    Name            = "${var.cluster_name}-nat-eip"
    iac_environment = var.iac_environment_tag
  }
}



// 공식 AWS VPC Module을 사용하여 VPC 생성
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = 2.77
  name = "${var.name_prefix}-vpc"
  cidr = var.main_network_block
  
  azs                     = var.available_azs
  public_subnets          = var.public_subnet
  private_subnets         = var.private_subnet

  # enable single NAT Gateway to save some money
  # WARNING: this could create a single point of failure, since we are creating a NAT Gateway in one AZ only
  enable_nat_gateway     = true     
  single_nat_gateway     = true     
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  reuse_nat_ips          = true
  external_nat_ip_ids    = [aws_eip.nat_gw_elastic_ip.id]

  // EKS에 의해 요구되는 VPC와 Subnet의 Tag를 추가
  // 단, VPC의 Tag 경우 1.15 버전 이상은 Tag가 필요하지 않다고 한다.
  // https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/network_reqs.html
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    iac_environment                             = var.iac_environment_tag
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
    iac_environment                             = var.iac_environment_tag
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
    iac_environment                             = var.iac_environment_tag
  }
}