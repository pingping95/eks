resource "aws_eks_node_group" "eks_worker" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.worker_group_name
  node_role_arn   = aws_iam_role.eks_worker_role.arn
  subnet_ids      = aws_subnet.private_subnet[*].id

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  tags = {
    "Name" = var.worker_group_name
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_role_worker_policy,
    aws_iam_role_policy_attachment.eks_worker_role_cni_policy,
    aws_iam_role_policy_attachment.eks_worker_role_ecr_policy,
    aws_iam_role_policy_attachment.eks_worker_role_Route53_policy,
    aws_iam_role_policy_attachment.eks_worker_role_CWLogs_policy,
    aws_iam_role_policy_attachment.eks_worker_role_Autoscailer_policy,
    aws_iam_role_policy_attachment.eks_worker_role_ALBIngress_policy,
  ]
}