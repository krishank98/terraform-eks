data "tls_certificate" "eks_certificate" {
  url = aws_eks_cluster.eks[0].identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "eks_oidc_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks_oidc.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.eks[0].identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:aws-test"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.eks[0].identity[0].oidc[0].issuer, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

