# ---------------------------------------------------------
# SECURITY GROUP: Lambda SG (Private Subnet)
# ---------------------------------------------------------
resource "aws_security_group" "lambda_sg" {
  name        = "${var.project}-lambda-sg"
  description = "Security group for Lambda inside private subnet"
  vpc_id      = aws_vpc.main.id

  # No inbound rules for Lambda (invoked by AWS internally)
  # Outbound ONLY to RDS port

  egress {
    description      = "Allow Lambda to access RDS"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [aws_security_group.rds_sg.id]
  }

  tags = {
    Name = "${var.project}-lambda-sg"
  }
}


# ---------------------------------------------------------
# SECURITY GROUP: RDS SG (Private Subnet)
# ---------------------------------------------------------
resource "aws_security_group" "rds_sg" {
  name        = "${var.project}-rds-sg"
  description = "Security group for private RDS"
  vpc_id      = aws_vpc.main.id

  # Inbound from Lambda
  ingress {
    description      = "Allow Lambda access to DB"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [aws_security_group.lambda_sg.id]
  }

  # Inbound from Bastion Host
  ingress {
    description      = "Allow Bastion host psql access"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [aws_security_group.bastion_sg.id]
  }

  # Outbound — allowed by default (VPC local communication)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-rds-sg"
  }
}


# ---------------------------------------------------------
# SECURITY GROUP: Bastion Host SG (Public Subnet)
# ---------------------------------------------------------
resource "aws_security_group" "bastion_sg" {
  name        = "${var.project}-bastion-sg"
  description = "Security group for Bastion host"
  vpc_id      = aws_vpc.main.id

  # SSH from your IP only
  ingress {
    description = "SSH access from user's IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]  
  }

  # Allow bastion to talk to RDS (as part of inbound handled on rds_sg)
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-bastion-sg"
  }
}
