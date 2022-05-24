# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# 2022

variable "ami" {}
variable "control_plane_ip" {}
variable "cluster_name" {}
variable "env" {}
variable "iam_instance_profile" {}
variable "instance_type" {}
variable "kubernetes_join_token" {}
variable "max_size" { default = 2 }
variable "min_size" { default = 1 }
variable "public_key" {}
variable "region_code" {}
variable "security_groups" {}
variable "subnets" {}
variable "target_group_arns" { default = [] }
