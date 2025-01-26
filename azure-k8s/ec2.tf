provider "aws" {
  region = "us-east-1" # Change to your preferred region, 7 v1, deploy could be commented-out, 26/1 deploy.
}

# Define any required variables in the Terraform file
variable "azure_client_id" {
  description = "Azure Client ID for service principal"
  type        = string
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID for service principal"
  type        = string
}

variable "azure_client_secret" {
  description = "Azure Client Secret for service principal"
  type        = string
}

resource "random_id" "sg_suffix" {
  byte_length = 4
}

resource "aws_security_group" "flask_sg" {
  name        = "flask-app-sg-azure-k8s-${random_id.sg_suffix.hex}"
  description = "Security group for Flask app"

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

  user_data = <<-EOF
              #!/bin/bash
              sudo yum install -y git
              git clone https://github.com/OmriFialkov/flask-catexer-app-actions.git /home/ec2-user/flask-app

              sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
              sudo curl -o /etc/yum.repos.d/azure-cli.repo https://packages.microsoft.com/config/rhel/8/prod.repo
              sudo yum install -y azure-cli

              AZURE_CLIENT_ID="${var.azure_client_id}"
              AZURE_TENANT_ID="${var.azure_tenant_id}"
              AZURE_CLIENT_SECRET="${var.azure_client_secret}"

              su - ec2-user -c "              
              az login --service-principal \
                  --username $AZURE_CLIENT_ID \
                  --password $AZURE_CLIENT_SECRET \
                  --tenant $AZURE_TENANT_ID
              "

              echo 'az login succeeded!' > /tmp/azlogin.log
              EOF


  provisioner "remote-exec" {
    inline = [
    "while [ ! -f /tmp/azlogin.log ]; do echo 'waiting for az login to succeed..'; sleep 5; done",
    "echo 'now connecting to azure cluster!'",
    "az aks get-credentials --resource-group azure-aks-rg --name aks-cluster-omri",

    # Download kubectl
    "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
    "if [ -f ./kubectl ]; then chmod +x kubectl && sudo mv kubectl /usr/local/bin/; else echo 'kubectl download failed'; exit 1; fi",

    # Change directory to the app folder
    "if [ -d /home/ec2-user/flask-app ]; then cd /home/ec2-user/flask-app; else echo 'Directory /home/ec2-user/flask-app not found'; exit 1; fi",

    # Apply Kubernetes configurations
    "echo 'now applying k8s config files!'",
    "kubectl apply -f ./k8s-config"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/my-aws-key.pem")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "CICD-TERRAFORM-K8S-AZURE-DEPLOY"
  }
}

output "instance_public_ip" {
  value       = aws_instance.flask_instance.public_ip
  description = "Public IP of the EC2 instance"
}
