resource "tls_private_key" "private_key" {
   algorithm = "RSA"
}

resource "aws_key_pair" "key_file" {
   key_name = "private_key"
   public_key = tls_private_key.private_key.public_key_openssh 


   depends_on = [
      tls_private_key.private_key
     ]
}

resource "local_file" "key" {
   content = tls_private_key.private_key.private_key_pem
   filename = "privatekey.pem"
   file_permission = "0600"

   depends_on = [
     tls_private_key.private_key,
     aws_key_pair.key_file
     ]
}

resource "aws_security_group" "web" {
    name = "web_sec"
    
    dynamic "ingress" {
      for_each = var.ports
     
      content {
        description = "web sec grp"
        from_port = ingress.value
        to_port = ingress.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

    egress {
      description = "web sec grp"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "web_sec_grp"
    }
}
