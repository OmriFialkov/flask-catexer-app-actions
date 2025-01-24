provider "aws" {
  region = "us-east-1" # Change to your preferred region
}

resource "aws_security_group" "flask_sg" {
  name        = "flask-app-sg-tf"
  description = "Security group for Flask app"

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port   = 5002
    to_port     = 5002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "flask_instance" {
  ami           = "ami-01816d07b1128cd2d" # Amazon Linux 2 AMI (update if needed)
  instance_type = "t2.micro"
  key_name      = "privatekey" # Reference your existing key pair by name

  security_groups = [aws_security_group.flask_sg.name]

  iam_instance_profile = "access-to-s3" # Reference the existing IAM instance profile directly

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y git docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user
              newgrp docker
              yum install -y libxcrypt-compat
              curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              git clone https://github.com/OmriFialkov/flask-catexer-app-actions.git /home/ec2-user/flask-app
              aws s3 cp s3://docker-gifs-project/.env /home/ec2-user/flask-app
              cd /home/ec2-user/flask-app
              docker-compose up -d
              EOF

  tags = {
    Name = "FlaskAppInstance"
  }
}

output "instance_public_ip" {
  value       = aws_instance.flask_instance.public_ip
  description = "Public IP of the EC2 instance"
}
