# Terraform (terraform/eks/rds.tf)
resource "aws_db_instance" "crm_rds" {
  identifier         = "crm-db"
  engine             = "postgres"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  db_name            = "crmdb"
  username           = "admin"
  password           = "YourPassword123"
  skip_final_snapshot = true
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  db_subnet_group_name = aws_db_subnet_group.crm_subnet_group.name
}

resource "aws_db_subnet_group" "crm_subnet_group" {
  name       = "crm-db-subnet-group"
  subnet_ids = module.vpc.private_subnets
}
