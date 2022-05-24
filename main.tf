# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2022

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

data "template_file" "join" {
  template = file("${path.module}/templates/user_data.sh")

  vars = {
    kubernetes_join_token = var.kubernetes_join_token
    control_plane_ip      = var.control_plane_ip
  }
}

resource "aws_key_pair" "cluster_nodes" {
  key_name   = "cluster-worker-nodes"
  public_key = var.public_key
}

resource "aws_launch_configuration" "worker" {
  associate_public_ip_address = false
  name_prefix                 = "worker-"
  image_id                    = var.ami == null ? data.aws_ami.amazon_linux2.id : var.ami
  instance_type               = var.instance_type
  security_groups             = var.security_groups
  iam_instance_profile        = var.iam_instance_profile
  user_data                   = data.template_file.join.rendered
  key_name                    = aws_key_pair.cluster_nodes.key_name
  lifecycle {
    create_before_destroy = true
  }
  root_block_device {
    encrypted   = false
    volume_size = 25
  }
}

resource "aws_autoscaling_group" "workers" {
  name                 = "workers"
  launch_configuration = aws_launch_configuration.worker.name
  min_size             = var.min_size
  max_size             = var.max_size
  target_group_arns    = var.target_group_arns
  termination_policies = ["OldestInstance"]
  vpc_zone_identifier  = var.subnets
  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = "k8s-worker"
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = var.env
    propagate_at_launch = true
  }
  tag {
    key                 = "RegionCode"
    value               = var.region_code
    propagate_at_launch = true
  }
  tag {
    key                 = "Role"
    value               = "worker"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "cpu_utilization" {
  autoscaling_group_name = aws_autoscaling_group.workers.name
  name                   = "workers"
  policy_type            = "PredictiveScaling"
  predictive_scaling_configuration {
    metric_specification {
      target_value = 10
      predefined_load_metric_specification {
        predefined_metric_type = "ASGTotalCPUUtilization"
        resource_label         = "testLabel"
      }
      customized_scaling_metric_specification {
        metric_data_queries {
          id = "scaling"
          metric_stat {
            metric {
              metric_name = "CPUUtilization"
              namespace   = "AWS/EC2"
              dimensions {
                name  = "AutoScalingGroupName"
                value = aws_autoscaling_group.workers.name
              }
            }
            stat = "Average"
          }
        }
      }
    }
  }
}
