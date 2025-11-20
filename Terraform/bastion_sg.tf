# bastion sg
resource "aws_security_group" "bastion_sg" {
  name        = "${var.project}-bastion-sg"
  description = "Bastion Host SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]   # "your-ip/32"
  }
}

resource "aws_security_group_rule" "egress_mysql" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  
  source_security_group_id = aws_security_group.rdsmysql_sg.id 
  
  security_group_id        = aws_security_group.bastion_sg.id 

  description              = "to access db"
}
resource "aws_security_group_rule" "egress_mysql_https" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"] 
  description              = for downloading mysql on bastion
}
