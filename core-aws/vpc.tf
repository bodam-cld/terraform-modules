module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.12.0"

  name = local.resource_name
  azs  = data.aws_availability_zones.available.names

  # https://github.com/terraform-aws-modules/terraform-aws-vpc#private-versus-intra-subnets
  cidr = "10.0.0.0/16"
  # 10.0.0.0/17
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"] # 8190 per subnet
  # 10.0.128.0/18
  intra_subnets = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"] # 4094 per subnet
  # 10.0.192.0/19
  public_subnets = ["10.0.192.0/21", "10.0.200.0/21", "10.0.208.0/21"] # 2046 per subnet
  # spare: 10.0.224.0/19

  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  enable_nat_gateway     = var.vpc_enable_nat_gateway
  single_nat_gateway     = var.vpc_enable_nat_gateway && var.vpc_single_nat_gateway
  one_nat_gateway_per_az = var.vpc_enable_nat_gateway && !var.vpc_single_nat_gateway && var.vpc_nat_gateway_per_az

  # required for EKS Route 53 private hosted zone
  enable_dns_support   = true
  enable_dns_hostnames = true

  #   # https://aws.amazon.com/premiumsupport/knowledge-center/eks-vpc-subnet-discovery/
  #   # https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  #   public_subnet_tags = {
  #     "kubernetes.io/cluster/${local.kubernetes_cluster_name}" = "shared"
  #     "kubernetes.io/role/elb"                                 = "1"
  #   }
  #   private_subnet_tags = {
  #     "kubernetes.io/cluster/${local.kubernetes_cluster_name}" = "shared"
  #     "kubernetes.io/role/internal-elb"                        = "1"
  #   }

  #   tags = local.aws_tags
}
