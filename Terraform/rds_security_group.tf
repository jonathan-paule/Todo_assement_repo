resource "aws_security_group" "rdsmysql_sg" {
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
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rdsmysql_sg.id
  source_security_group_id = aws_security_group.lambda_sg.id
  description              = "Allow Lambda to connect to RDS (all ports)"
}
resource "aws_security_group_rule" "rds_from_bastion" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rdsmysql_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id
  description              = "Allow Bastion to connect to MySQL"
}



resource "aws_security_group_rule" "rds_outbound1" {
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.rdsmysql_sg.id
  source_security_group_id = aws_security_group.bastion_sg.id

}



resource "aws_security_group_rule" "rds_outbound2" {
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.rdsmysql_sg.id
  source_security_group_id = aws_security_group.lambda_sg.id

}
