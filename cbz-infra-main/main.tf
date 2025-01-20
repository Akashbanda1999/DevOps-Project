provider "aws" {
    region = "us-east-1"
}

module "rds" {
    source = "./modules/rds"
}

module "eks" {
    source = "./modules/eks"
}

module "s3" {
    source = "./modules/s3"
}
