provider "aws" {
  region = "ap-southeast-1"

}

# Generate SSH key pair
resource "tls_private_key" "tf-rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tf-keys" {
  key_name   = "tf-keys"
  public_key = tls_private_key.tf-rsa.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "ssh_private_key.pem"
  content  = tls_private_key.tf-rsa.private_key_pem
}

resource "aws_instance" "Docker_Terraform" {
  ami                         = "ami-06c4be2792f419b7b"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.tf-keys.key_name # Use the key name generated by Terraform
  tags = {
    "Name" = "sarmad-project-tf"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu" # Assuming Ubuntu AMI
    host        = self.public_ip
    private_key = tls_private_key.tf-rsa.private_key_pem
    timeout     = "1m"
  }

  provisioner "file" {
    source      = "install.sh"
    destination = "/tmp/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install.sh",
      "bash /tmp/install.sh"
    ]
  }
}

output "public_ip" {
  value = aws_instance.Docker_Terraform.public_ip
}
