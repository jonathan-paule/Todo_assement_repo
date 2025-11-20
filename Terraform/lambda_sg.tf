resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Allow Lambda to access RDS"
  vpc_id      = aws_vpc.main.id



resource "aws_security_group_rule" "lambda_sg_inbound" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lambda_sg.id
  source_security_group_id = aws_security_group.rdsmysql_sg.id
  description              = "inbound"


resource "aws_security_group_rule" "lambda_sg_outbound" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lambda_sg.id
  source_security_group_id = aws_security_group.rdsmysql_sg.id
  description              = "outbound"
