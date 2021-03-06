// VPC
variable "account_id" {
  default     = "<<your_account_id>>"
  description = "Account id"
  type        = string 
}

variable "cluster_name" {
  default     = "eks_demo"
  description = "EKS Cluster name"
  type        = string
}

variable "main_network_block" {
  default     = "192.168.0.0/16"
  description = "main network address block"
  type        = string
}

variable "available_azs" {
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
  description = "available zones you want to set worker nodes"
  type        = list(string)
}

variable "public_subnet_cidr_block" {
  default     = ["192.168.1.0/24", "192.168.2.0/24"]
  description = "public subnet block"
  type        = list(string)
}

variable "private_subnet_cidr_block" {
  default     = ["192.168.11.0/24", "192.168.12.0/24"]
  description = "private subnet blick"
  type        = list(string)
}



// EKS
variable "worker_sg_name" {
  default     = "demo_eks_worker_sg"
  description = "EKS Worker Security Group name"
  type        = string
}

variable "cluster_sg_name" {
  default     = "demo_eks_cluster_sg"
  description = "EKS Cluster Security Group name"
  type        = string
}

variable "worker_group_name" {
  default     = "worker"
  description = "EKS Cluster Worker Node Group name"
  type        = string
}



variable "ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Defaults to AL2_x86_64. Valid values: AL2_x86_64, AL2_x86_64_GPU."
  type        = string
  default     = "AL2_x86_64"
}

variable "disk_size" {
  description = "Disk size in GiB for worker nodes. Defaults to 20."
  type        = number
  default     = 20
}

variable "instance_types" {
  type        = list(string)
  default     = ["t3.medium"]
  description = "Set of instance types associated with the EKS Node Group."
}

variable "desired_size" {
  description = "Desired number of worker nodes in private subnet"
  default     = 2
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes in private subnet."
  default     = 2
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes in private subnet."
  default     = 2
  type        = number
}
