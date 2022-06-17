# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2022

resource "aws_autoscaling_policy" "cloudwatch_cpu" {
  name                   = "${var.cluster_name}-cloudwatch-cpu"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.nodes.name
}

resource "aws_cloudwatch_metric_alarm" "instance_cpu" {
  alarm_name          = "${var.cluster_name}-instance-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.nodes.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization. Created via Terraform"
  alarm_actions     = [aws_autoscaling_policy.cloudwatch_cpu.arn]
}
