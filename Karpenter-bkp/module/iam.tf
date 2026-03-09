
resource "random_integer" "random_suffix" {
  min = 1000
  max = 9999
}

resource "aws_iam_role" "eks_cluster_role" {
  count = var.is_eks_role_enabled ? 1 : 0

  name = "${local.cluster_name}-role-${random_integer.random_suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  count = var.is_eks_role_enabled ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role[count.index].name
}

resource "aws_iam_role" "eks_nodegroup_role" {
  count = var.is_nodegroup_role_enabled ? 1 : 0

  name = "${local.cluster_name}-nodegroup-role-${random_integer.random_suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_AmazonWorkerNodePolicy" {
  count = var.is_nodegroup_role_enabled ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role[count.index].name
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKS_CNI_Policy" {
  count = var.is_nodegroup_role_enabled ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role[count.index].name
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEC2ContainerRegistryReadOnly" {
  count = var.is_nodegroup_role_enabled ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role[count.index].name
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEBSCSIContainerDriverPolicy" {
  count = var.is_nodegroup_role_enabled ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_nodegroup_role[count.index].name
}

resource "aws_iam_role" "eks_oidc" {
  name               = "eks-oidc"
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role_policy.json
}

resource "aws_iam_role" "jump_server_role" {

  name = "jump-server-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jump_eks_policy" {

  role       = aws_iam_role.jump_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "jump_ssm_policy" {

  role       = aws_iam_role.jump_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "jump_profile" {
  name = "jump-server-profile"
  role = aws_iam_role.jump_server_role.name
}

############################################
# OIDC Certificate
############################################

data "tls_certificate" "eks" {
  count = var.is_karpenter_enable ? 1 : 0

  url = aws_eks_cluster.eks[0].identity[0].oidc[0].issuer
}

############################################
# OIDC Provider
############################################

resource "aws_iam_openid_connect_provider" "eks" {

  count = var.is_karpenter_enable ? 1 : 0

  url = aws_eks_cluster.eks[0].identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks[0].certificates[0].sha1_fingerprint
  ]
}

############################################
# Karpenter Controller Role
############################################

resource "aws_iam_role" "karpenter_controller" {

  count = var.is_karpenter_enable ? 1 : 0

  name = "${var.cluster_name}-karpenter-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"

      Principal = {
        Federated = aws_iam_openid_connect_provider.eks[0].arn
      }

      Action = "sts:AssumeRoleWithWebIdentity"
    }]
  })
}

############################################
# Controller Policy
############################################

resource "aws_iam_role_policy_attachment" "karpenter_policy" {

  count = var.is_karpenter_enable ? 1 : 0

  role       = aws_iam_role.karpenter_controller[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

############################################
# Node Role
############################################

resource "aws_iam_role" "karpenter_node_role" {

  count = var.is_karpenter_enable ? 1 : 0

  name = "${var.cluster_name}-karpenter-node"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

############################################
# Worker Node Policies
############################################

resource "aws_iam_role_policy_attachment" "karpenter_worker_policy" {

  count = var.is_karpenter_enable ? 1 : 0

  role       = aws_iam_role.karpenter_node_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "karpenter_ecr" {

  count = var.is_karpenter_enable ? 1 : 0

  role       = aws_iam_role.karpenter_node_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

############################################
# Instance Profile
############################################

resource "aws_iam_instance_profile" "karpenter_node_profile" {

  count = var.is_karpenter_enable ? 1 : 0

  name = "${var.cluster_name}-karpenter-profile"
  role = aws_iam_role.karpenter_node_role[0].name
}