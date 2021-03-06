resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    // I Solved subnet_ids problem here
    // : https://github.com/terraform-aws-modules/terraform-aws-vpc/issues/271
    subnet_ids         = concat(aws_subnet.private_subnet.*.id, aws_subnet.public_subnet.*.id)
    security_group_ids = [aws_security_group.eks_cluster_sg.id, aws_security_group.eks_worker_sg.id]
  }

  // Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-policy,
    aws_iam_role_policy_attachment.eks-service-policy,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}