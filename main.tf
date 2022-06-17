# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2022

locals {
  key_pair_name = var.key_pair_name != null ? var.key_pair_name : "${var.cluster_name}-${var.asg_name}-key-pair"
}

resource "aws_key_pair" "nodes" {
  key_name   = local.key_pair_name
  public_key = var.public_key
}

resource "aws_launch_configuration" "node" {
  associate_public_ip_address = var.associate_public_ip_address
  name_prefix                 = var.name_prefix
  image_id                    = var.ami
  instance_type               = var.instance_type
  security_groups             = var.security_groups
  iam_instance_profile        = var.iam_instance_profile
  user_data                   = var.user_data_rendered
  key_name                    = aws_key_pair.nodes.key_name
  lifecycle {
    create_before_destroy = true
  }
  root_block_device {
    encrypted   = var.volume_encrypted
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
}

resource "aws_autoscaling_group" "nodes" {
  name                 = var.asg_name
  launch_configuration = aws_launch_configuration.node.name
  min_size             = var.min_size
  max_size             = var.max_size
  target_group_arns    = var.target_group_arns
  termination_policies = var.termination_policies
  vpc_zone_identifier  = var.subnets
  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = var.node_name
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
    value               = var.node_role
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "cpu_utilization" {
  autoscaling_group_name = aws_autoscaling_group.nodes.name
  name                   = var.autoscaling_policy_name
  policy_type            = "PredictiveScaling"
  predictive_scaling_configuration {
    metric_specification {
      target_value = 10
      customized_load_metric_specification {
        metric_data_queries {
          id         = "load_sum"
          expression = "SUM(SEARCH('{AWS/EC2,AutoScalingGroupName} MetricName=\"CPUUtilization\" ${aws_autoscaling_group.nodes.name}', 'Sum', 3600))"
        }
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
                value = aws_autoscaling_group.nodes.name
              }
            }
            stat = "Average"
          }
        }
      }
    }
  }
}
