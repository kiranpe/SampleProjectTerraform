resource "aws_instance" "jenkins" {
     ami = data.aws_ami.web.id
     instance_type = var.ec2_type
     key_name = aws_key_pair.key_file.key_name
     security_groups = ["${aws_security_group.web.name}"] 
  
     connection {
       user = var.user_name
       private_key = tls_private_key.private_key.private_key_pem
       host = self.public_ip
     }
 
     provisioner "remote-exec" {
       inline = ["sudo apt-add-repository ppa:ansible/ansible -y && sudo apt-get update && sleep 15 && sudo apt-get install -f ansible -y"]
     }
  
     provisioner "local-exec" {
       command = <<EOT
        sleep 15;
         > jenkins/jenkinsci;
           echo "[jenkinsci]" | tee -a jenkins/jenkinsci;
           echo "${self.public_ip} ansible_user=${var.user_name} ansible_ssh_common_args='-o StrictHostKeyChecking=no' ansible_python_interpreter=/usr/bin/python2.7" | tee -a jenkins/jenkinsci;
           cat dev-prod/devprod | tee -a jenkins/jenkinsci;
           mv dev-prod/devprod dev-prod/devprod.old;
           ansible-playbook -u ${var.user_name} --private-key  ${local_file.key.filename} -i jenkins/jenkinsci jenkins/install-jenkins.yml -e "hub_user=dockeruser hub_pass=dockerpass"
       EOT
     }
   
     tags = {
       Name = "jenkins-instance"
     }
    
     depends_on = [
       tls_private_key.private_key,
       aws_key_pair.key_file,
       aws_security_group.web,
       aws_instance.dev_prod
      ]
}

output "jenkins_url" {
   value = "http://${aws_instance.jenkins.public_ip}:8080"
}
