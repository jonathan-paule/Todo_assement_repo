data "aws_secretsmanager_secret_version" "db" {
  secret_id = "todoapp/db_credentials"
}

# Decode JSON stored in Secrets Manager
locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)
}



resource "aws_db_instance" "todo_db" {
  allocated_storage      = 10
  max_allocated_storage  = 20
  engine                 = var.engine
  engine_version         = "13"
  instance_class         = var.instance_class

  username                = var.db_username
  password                = var.db_password
  db_name                 = var.db_name

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection       = false
  backup_retention_period   = 0  
  multi_az                  = false


  db_subnet_group_name = aws_db_subnet_group.db_subnets.name
}

resource "aws_db_subnet_group" "db_subnets" {
  name       = "db-subnet-grp"
  subnet_ids = [aws_subnet.private_subnet.id]
}
