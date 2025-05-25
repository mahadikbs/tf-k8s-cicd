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
        source = "db/docker.sh"
        destination = "/home/ec2-user/install-docker.sh"
      
    }

    

    #     provisioner "file" {
    #     source = "db/docker1.sh"
    #     destination = "/home/ec2-user/docker-login.sh"
      
    # }

    provisioner "remote-exec" {
        inline = [
            "sudo yum update -y",
            "sudo yum install -y docker.io",
            "sudo systemctl start docker",
            "sudo systemctl enable docker",
            "docker login -u '${var.DOCKER_USERNAME}' --password '${var.DOCKER_PASSWORD}'",     
            "docker pull mahadikbs/k8s-prom-grafana:latest",
            "docker run -d -p 8080:8080 -p 9090:9090 -p 16443:16443 -p 3000:3000 --name k8s-server mahadikbs/k8s-prom-grafana:latest",

        ]
      
    }

    # provisioner "remote-exec" {
    #     inline = [ 
    #         "cd /home/ec2-user/",
    #         "ls",
    #         "sh install-docker.sh",
    #         "sh docker-login.sh"
    #        ]
      
    # }    

    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host = self.public_ip
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

