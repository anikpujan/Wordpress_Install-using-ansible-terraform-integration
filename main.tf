locals {
  vpc_id           = "Your vpc id"
  subnet_id        = "Your subnet id"
  ssh_user         = "ec2-user"
  key_name         = "keyname"
  private_key_path = "Key path"
}

# variable "aws_access_key" {}
# variable "aws_secret_key" {}
# variable "region" {}
provider "aws" {
  region = "ca-central-1"
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key


}

resource "aws_security_group" "wordpress" {
  name   = "wordpress_access"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "wordpress" {
  ami                         = "ami-0101734ab73bd9e15"
  subnet_id                   = local.subnet_id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.wordpress.id]
  key_name                    = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.wordpress.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.nginx.public_ip}, --private-key ${local.private_key_path} wordpress.yaml"
  }
}

output "wordpress_ip" {
  value = aws_instance.wordpress.public_ip
}
