resource "aws_eks_addon" "csi_driver" {
  cluster_name             = var.eks_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.addon_version
  service_account_role_arn = aws_iam_role.eks_ebs_csi_driver.arn
}