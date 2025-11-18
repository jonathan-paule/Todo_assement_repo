resource "aws_db_instance" "todo_db" {
  allocated_storage      = 10
  max_allocated_storage  = 20
  engine                 = "postgres"
  engine_version         = "13"
  instance_class         = "db.t3.micro"

  username               = var.db_user
  password               = var.db_password
  db_name                = "todosDB"

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
