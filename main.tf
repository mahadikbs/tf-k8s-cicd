resource "aws_key_pair" "my-k8s-key" {
    key_name = var.key-name
    public_key = file("~/.ssh/id_rsa.pub")
  
}

resource "aws_instance" "terraform-test" {
    ami = var.ami-id
    instance_type = var.instance-type
    key_name = aws_key_pair.my-k8s-key.key_name
    security_groups = [aws_security_group.k8s-sg.name]


    provisioner "file" {
        source = "docker-compose.yml"
        destination = "/home/ec2-user/docker-compose.yml"
      
    }

        provisioner "file" {
        source = "prometheus.yml"
        destination = "/home/ec2-user/prometheus.yml"
      
    }


        provisioner "file" {
            source = "db/install-docker.sh"
            destination = "/home/ec2-user/install-docker.sh"
          
    }
        provisioner "file" {
            source = "db/install-kubectl.sh"
            destination = "/home/ec2-user/install-kubectl.sh"
          
        }
      
      
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host = self.public_ip
    }

    user_data = <<EOF
    #!/bin/bash
    sudo chmod +x /home/ec2-user/home/ec2-user/install-docker.sh
    sudo chmod +x /home/ec2-user/install-kubectl.sh
    sudo sh /home/ec2-user/install-docker.sh
    sudo sh /home/ec2-user/install-kubectl.sh
   
     EOF    

    provisioner "remote-exec" {
        inline = [ 
            "sudo service docker start",
            "cd /home/ec2/user",
            "docker-compose up -d"
         ]
      
    }
}

resource "aws_security_group" "k8s-sg" {
    name = "k8s-sg"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 9090
        to_port = 9090
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 16443
        to_port = 16443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

