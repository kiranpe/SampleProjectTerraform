resource "aws_instance" "dev_prod" {
    ami = data.aws_ami.web.id
    instance_type = var.ec2_type
    key_name = aws_key_pair.key_file.key_name
    security_groups = ["${aws_security_group.web.name}"]
    
    count = 2
 
    connection {
      user = var.user_name
      private_key = tls_private_key.private_key.private_key_pem
      host = self.public_ip
    }
  
    provisioner "remote-exec" {
      inline = ["sudo apt-add-repository ppa:ansible/ansible -y && sudo apt-get update && sleep 10 && sudo apt-get install ansible -y"]
    }
    
    provisioner "local-exec" {
       command = <<EOT
       sleep 5;
        >> dev-prod/devprod;
        echo "[${element(var.names, count.index)}]" | tee -a dev-prod/devprod;
        echo "${self.public_ip} ansible_user=${var.user_name} ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_python_interpreter=/usr/bin/python2.7" | tee -a dev-prod/devprod;
        ansible-playbook -u ${var.user_name} --private-key  ${local_file.key.filename} -i dev-prod/devprod dev-prod/docker.yml -e "hub_user=dockeruser hub_pass=dockerpass"
       EOT
    }

    tags = {
     Name = "${element(var.names, count.index)}"
    }

    depends_on = [
       tls_private_key.private_key,
       aws_key_pair.key_file,
       aws_security_group.web,
       aws_instance.dev_prod[0]
       ]
}
