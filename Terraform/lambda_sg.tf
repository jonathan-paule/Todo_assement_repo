resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Allow Lambda to access RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = []
    # No inbound needed unless Lambda receives traffic inside VPC
  }

  egress {
    description = "Allow Lambda to connect to RDS"
    from_port   = 3306 
    to_port     = 3306 
    protocol    = "tcp"
    security_groups = [aws_security_group.rds_sg.id]
  }

  tags = {
    Name = "lambda-sg"
  }
}
