provider "aws" {
  region = "us-east-1" # Change to your preferred region
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
              yum update -y
              curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
              sudo yum install -y azure-cli
              
              AZURE_CLIENT_ID="${var.azure_client_id}"
              AZURE_TENANT_ID="${var.azure_tenant_id}"
              AZURE_CLIENT_SECRET="${var.azure_client_secret}"
              
              az login --service-principal \
                  --username $AZURE_CLIENT_ID \
                  --password $AZURE_CLIENT_SECRET \
                  --tenant $AZURE_TENANT_ID

              az account show
              EOF


#   provisioner "remote-exec" {
#     inline = [
#       "echo 'Provisioning complete!'"
#     ]

#     connection {
#       type        = "ssh"
#       user        = "ec2-user"
#       private_key = 
#       host        = self.public_ip
#     }
#   }

  tags = {
    Name = "CICD-TERRAFORM-K8S-AZURE-DEPLOY"
  }
}

output "instance_public_ip" {
  value       = aws_instance.flask_instance.public_ip
  description = "Public IP of the EC2 instance"
}
