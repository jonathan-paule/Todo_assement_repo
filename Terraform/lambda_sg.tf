resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Allow Lambda to access RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]

  }

  egress {
    description = "Allow Lambda to connect to RDS for private subnet1"
    from_port   = 3306 
    to_port     = 3306 
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }

egress {
    description = "Allow Lambda to connect to RDS for private subnet2"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24"]  
  }
  tags = {
    Name = "lambda-sg"
  }
}
