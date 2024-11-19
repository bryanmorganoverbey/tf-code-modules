

provider "aws" {
  region = "us-west-1"
}

resource "aws_db_instance" "example" {
  identifier_prefix   = "terraform-up-and-running"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  skip_final_snapshot = true
  # enable backups
  backup_retention_period = var.backup_retention_period
  #if specified, this DB will be a replica
  replicate_source_db = var.replicate_source_db

  # only set these params if replicate_source_db is not set
  engine   = var.replicate_source_db == null ? "mysql" : null
  db_name  = var.replicate_source_db == null ? var.db_name : null
  username = var.replicate_source_db == null ? var.db_username : null
  password = var.replicate_source_db == null ? var.db_password : null
}

terraform {
  backend "s3" {
    bucket         = "remote-state-for-terraform-up-and-running-bryan"
    key            = "stage/data-stores/mysql/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}
