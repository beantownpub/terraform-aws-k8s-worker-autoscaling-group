# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2022

variable "ami" {}
variable "asg_name" {
  description = "Name of the auto scaling group"
  default     = "workers"
}
variable "associate_public_ip_address" { default = false }
variable "autoscaling_policy_name" { default = "worker-cpu" }
variable "key_pair_name" { default = null }
variable "ca_cert_hash" { default = null }
variable "control_plane_ip" {}
variable "cluster_name" {}
variable "env" {
  description = "Value for Environment AWS Tag"
}
variable "iam_instance_profile" {}
variable "instance_type" {}
variable "kubernetes_join_token" {}
variable "name_prefix" { default = "worker-" }
variable "node_name" {
  description = "Tag Name value for worker node instances"
  default     = "k8s-worker"
}
variable "node_role" {
  description = "Value for Role AWS Tag"
  default     = "worker"
}
variable "max_size" { default = 2 }
variable "min_size" { default = 1 }
variable "public_key" {}
variable "region_code" {
  description = "Value for RegionCode AWS Tag"
}
variable "security_groups" {}
variable "subnets" {}

variable "target_group_arns" { default = [] }
variable "termination_policies" {
  description = "Policies for terminating nodes in asg"
  default     = ["OldestInstance"]
}
variable "volume_encrypted" { default = false }
variable "volume_size" { default = 25 }
variable "volume_type" { default = "gp3" }

variable "user_data_rendered" {}
