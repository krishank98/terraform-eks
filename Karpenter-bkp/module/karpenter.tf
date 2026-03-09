resource "helm_release" "karpenter" {
  count = var.is_karpenter_enable ? 1 : 0
  name       = "karpenter"
  namespace  = "karpenter"
  repository = "oci://public.ecr.aws/karpenter/karpenter"
  chart      = "karpenter"

  create_namespace = true

  set = [
    {
      name  = "settings.clusterName"
      value = var.cluster_name
    },
    {
      name  = "settings.clusterEndpoint"
      value = aws_eks_cluster.eks[0].endpoint
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.karpenter_controller[0].arn
    }
  ]
}

resource "kubernetes_manifest" "karpenter_nodepool" {
  count = var.is_karpenter_enable ? 1 : 0
  manifest = {
    apiVersion = "karpenter.sh/v1beta1"
    kind       = "NodePool"

    metadata = {
      name = "default"
    }

    spec = {
      template = {
        spec = {
          requirements = [
            {
              key      = "node.kubernetes.io/instance-type"
              operator = "In"
              values   = ["t3.medium", "t3.large"]
            }
          ]
        }
      }
    }
  }
}