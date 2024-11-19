terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

module "mysql" {
  source                  = "../../data-stores/mysql"
  backup_retention_period = 1

  db_name     = "example_database"
  db_username = "admin"
  db_password = "password"
}
