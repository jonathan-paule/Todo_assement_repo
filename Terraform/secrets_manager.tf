resource "aws_secretsmanager_secret" "db" {
  name = "todoapp/db_credentials"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.todo_db.address
    dbname   = var.db_name
    port     = 3306
  })
}
