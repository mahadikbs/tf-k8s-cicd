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

    user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install docker
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    newgrp docker
    docker login -u '${var.DOCKER_USERNAME}' --password '${var.DOCKER_PASSWORD}'
    sudo yum update -y
    sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    cd /home/ec2-user
    docker-compose up -d   
    EOF    

    provisioner "remote-exec" {
        inline = [ 
            "cd /home/ec2-user",
            "sudo sh install-kubectl.sh"
         ]
      
    }

    tags = {
      Name = "tf-k8s-1012434"
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

