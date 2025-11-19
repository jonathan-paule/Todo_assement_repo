#lambda sg

resource "aws_security_group" "lambda_sg" {
  name        = "${var.project}-lambda-sg"
  description = "SG for Lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Lambda -> RDS (Postgres)"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.rds_sg.id]
  }
}

#rds sg

resource "aws_security_group" "rds_sg" {
  name        = "${var.project}-rds-sg"
  description = "Allow DB access from Lambda and Bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Lambda -> RDS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  ingress {
    description     = "Bastion -> RDS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
}

#bastion sg

resource "aws_security_group" "bastion_sg" {
  name        = "${var.project}-bastion-sg"
  description = "Bastion SSH access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]  # your-ip/32
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.rds_sg.id]
  }
}
