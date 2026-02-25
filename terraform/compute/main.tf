data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Ubuntu 24.04 LTS (Noble Numbat) – used for the monitoring node
data "aws_ami" "ubuntu_24_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "jenkins_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.jenkins_instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.jenkins_sg_id]
  iam_instance_profile   = var.jenkins_instance_profile

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-server"
  }
}

resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.app_instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.app_sg_id]
  iam_instance_profile   = var.app_instance_profile

  tags = {
    Name = "${var.project_name}-${var.environment}-app-server"
  }
}

# ==============================================
# Monitoring Server (Prometheus + Grafana)
# Ubuntu 24.04 LTS – dedicated observability node
# ==============================================
resource "aws_instance" "monitoring_server" {
  ami                    = data.aws_ami.ubuntu_24_04.id
  instance_type          = var.monitoring_instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.monitoring_sg_id]

  root_block_device {
    volume_size           = 20    # GB – stores 30 days of Prometheus TSDB
    volume_type           = "gp3"
    delete_on_termination = true

    tags = {
      Name = "${var.project_name}-${var.environment}-monitoring-root"
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-monitoring-server"
    Role = "observability"
  }
}
