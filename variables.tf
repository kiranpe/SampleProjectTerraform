variable "ec2_type" {
   default = "t2.micro"
}

variable "user_name" {
   default = "ubuntu"
}

variable "names" {
   type = list
   default = ["prodserver", "devserver"]
}

variable "ports" {
   type = list(number)
   default = [22, 80, 443 , 7010, 8080]
}
