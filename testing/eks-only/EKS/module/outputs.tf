output "cluster_name" {
  value = aws_eks_cluster.eks[0].name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks[0].endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.eks[0].certificate_authority[0].data
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "cluster_autoscaler_role_arn" {
  value = aws_iam_role.cluster_autoscaler.arn
}