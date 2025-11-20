resource "aws_db_subnet_group" "db_subnets" {
  name       = "db-subnet-grp"
  subnet_ids = [aws_subnet.private_subnet.id,
                aws_subnet.private_subnet2.id]

  tags = {
    Name = "todo-db-subnet-group"
  }
}


resource "aws_db_instance" "todo_db" {
  identifier              = "todo-db"
  allocated_storage       = 10
  max_allocated_storage   = 20
  engine                  = var.engine         
  engine_version          = "8.0"             
  instance_class          = var.instance_class

  username = var.db_username
  password = var.db_password
  db_name  = var.db_name

  vpc_security_group_ids = [aws_security_group.rdsmysql_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name

  port                    = 3306  
  publicly_accessible     = false
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 0

  parameter_group_name = "default.mysql8.0"   
}
