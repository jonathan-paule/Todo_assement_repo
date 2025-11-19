resource "aws_instance" "bastion" {
  ami           = var.ami_id  # Amazon Linux 2
  instance_type = var.instance_type

  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  associate_public_ip_address = true

  key_name = var.key_name
}
