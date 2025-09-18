output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_ca_certificate" {
  description = "The CA certificate for the EKS cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}