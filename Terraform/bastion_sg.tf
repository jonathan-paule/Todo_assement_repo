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
  
  # CORRECTED: The attribute to reference the ID is simply '.id'
  source_security_group_id = aws_security_group.rdsmysql_sg.id 
  
  # This correctly references the ID of the Bastion SG defined above
  security_group_id        = aws_security_group.bastion_sg.id 

  description              = "to access db
}
