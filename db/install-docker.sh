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
    sudo docker-compose up -d    