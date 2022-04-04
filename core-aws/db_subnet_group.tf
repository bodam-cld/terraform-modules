resource "aws_db_subnet_group" "default" {
  count      = var.create_db_subnet_groups ? 1 : 0
  name       = "${var.environment}-default"
  subnet_ids = module.vpc.intra_subnets
}
