resource "aws_security_group" "lambda_sg" {
  name        = "${var.project}-lambda-sg"
  description = "Lambda SG"
  vpc_id      = aws_vpc.main.id

  # Lambda does not require inbound rules
  # Allow all outbound so Lambda can reach Secrets Manager, RDS DNS, etc.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-lambda-sg"
  }
}
