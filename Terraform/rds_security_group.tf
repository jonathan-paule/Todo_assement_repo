resource "aws_security_group" "rds_sg" {
  name        = "${var.project}-rds-sg"
  description = "RDS Security Group"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project}-rds-sg"
  }
}

# Allow Lambda SG to connect to RDS on all ports 
resource "aws_security_group_rule" "rds_from_lambda" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.lambda_sg.id
  description              = "Allow all traffic from Lambda SG"
}


# RDS outbound (allow all)
resource "aws_security_group_rule" "rds_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.rds_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}
