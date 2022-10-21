provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  config_path = "~/.kube/config"

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints"

  # EKS CLUSTER
  cluster_version           = "1.23"
  vpc_id                    = var.network.vpc.id
  private_subnet_ids        = var.network.subnets.*.id
  cluster_name              = "cluster"



#  worker_additional_security_group_ids = ["${aws_security_group.worker_sg.id}"]
#  cluster_additional_security_group_ids = ["${aws_security_group.blah.id}"]
#  node_security_group_additional_rules = {
#    ingress_from_this_pc = {
#      protocol                   = "tcp"
#      from_port                  = 0
#      to_port                    = 0
#      type                       = "ingress"
#      cidr_blocks                = ["${chomp(data.http.myip.body)}/32"]
#    }
#  }





  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_m5 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t3.medium"]
      subnet_ids      = var.network.subnets.*.id
    }
  }
}

# See: https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/710762bcb431878b7d2394feec52f44b8f7a4ad8/modules/kubernetes-addons/variables.tf
module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  # EKS Addons
  enable_amazon_eks_vpc_cni            = false
  enable_amazon_eks_coredns            = false
  enable_amazon_eks_kube_proxy         = false
  enable_amazon_eks_aws_ebs_csi_driver = false

  #K8s Add-ons
  enable_argocd                       = false
  enable_aws_for_fluentbit            = false
  enable_aws_load_balancer_controller = true
  enable_cluster_autoscaler           = false
  enable_metrics_server               = false
  enable_prometheus                   = false
}







resource "aws_security_group" "worker_sg" {
  name        = "eks_worker"
  vpc_id      = var.network.vpc.id
  tags        = var.tags
}

resource "aws_security_group_rule" "worker_ingress" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "tcp"
  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  security_group_id = aws_security_group.worker_sg.id
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "blah" {
  name        = "blah"
  vpc_id      = var.network.vpc.id
  tags        = var.tags
}

resource "aws_security_group_rule" "blah" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "tcp"
  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  security_group_id = aws_security_group.blah.id
}