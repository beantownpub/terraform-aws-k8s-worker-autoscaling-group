# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2022

terraform {
  required_providers {
    # Provider versions are pinned to avoid unexpected upgrades
    aws = {
      source  = "hashicorp/aws"
      version = "4.15.1"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

module "network" {
  source  = "app.terraform.io/beantown/network/aws"
  version = "0.1.5"

  availability_zones              = ["us-west-2a", "us-west-2b"]
  create_ssh_sg                   = true
  default_security_group_deny_all = false
  environment                     = "test"
  cidr_block                      = "10.0.0.0/16"
  internet_gateway_enabled        = true
  label_create_enabled            = true
  nat_gateway_enabled             = false
  nat_instance_enabled            = false
  region_code                     = "usw2"
}

data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-*-gp2"]
  }
}

module "worker_autoscaling" {
  source = "../.."

  ami                   = data.aws_ami.amazon_linux2.id
  cluster_name          = "test-usw2"
  control_plane_ip      = "10.0.0.8"
  env                   = "test"
  iam_instance_profile  = "K8sWorkerNode"
  instance_type         = "t3.medium"
  kubernetes_join_token = "foo"
  public_key            = "foo"
  region_code           = "usw2"
  subnets               = module.network.private_subnet_ids
  security_groups       = []
  target_group_arns     = []
}
