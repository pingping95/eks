// eks_cluster_role
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

// 2개의 정책을 할당
// attach AmazonEKSClusterPolicy to eks_cluster_role
resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

// attach AmazonEKSServicePolicy to eks_cluster_role
resource "aws_iam_role_policy_attachment" "eks-service-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}



// eks_worker_role
resource "aws_iam_role" "eks_worker_role" {
  name = "eks_worker_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

// 7개의 정책을 할당
// attach AmazonEKSWorkerNodePolicy to eks_worker_role
resource "aws_iam_role_policy_attachment" "eks_worker_role_worker_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_role.name
}

// attach AmazonEKS_CNI_Policy to eks_worker_role
resource "aws_iam_role_policy_attachment" "eks_worker_role_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker_role.name
}

// attach AmazonEC2ContainerRegistryReadOnlyPolicy to eks_worker_role
resource "aws_iam_role_policy_attachment" "eks_worker_role_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_role.name
}

// attach ALBIngressControllerIAMPolicyPolicy to eks_worker_role
resource "aws_iam_role_policy_attachment" "eks_worker_role_Route53_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
  role       = aws_iam_role.eks_worker_role.name
}

// attach CloudWatchLogsFullAccessPolicy to eks_worker_role
resource "aws_iam_role_policy_attachment" "eks_worker_role_CWLogs_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role       = aws_iam_role.eks_worker_role.name
}

// attach EKSAutoscailerPolicy to eks_worker_role
resource "aws_iam_role_policy_attachment" "eks_worker_role_Autoscailer_policy" {
  #policy_arn = "arn:aws:iam::001243379513:policy/EKSAutoscailerPolicy"
  policy_arn = format("arn:aws:iam::%s:policy/EKSAutoscailerPolicy", var.account_id)
  role       = aws_iam_role.eks_worker_role.name
}

// attach CloudWatchLogsFullAccessPolicy to eks_worker_role
resource "aws_iam_role_policy_attachment" "eks_worker_role_ALBIngress_policy" {
  #policy_arn = "arn:aws:iam::${}:policy/ALBIngressControllerPolicy"
  policy_arn = format("arn:aws:iam::%s:policy/ALBIngressControllerPolicy", var.account_id)
  role       = aws_iam_role.eks_worker_role.name
}






// ??
# resource "aws_iam_instance_profile" "eks-worker-role-profile" {
#   name = "eks-worker-role-profile"
#   role = aws_iam_role.eks-worker-role.name
# }