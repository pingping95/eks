provider "aws" {
  region = "ap-northeast-2"
}


# used for accesing Account ID and ARN
data "aws_caller_identity" "current" {}