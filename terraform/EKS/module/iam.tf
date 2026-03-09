
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