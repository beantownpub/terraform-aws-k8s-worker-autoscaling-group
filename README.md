# terraform-aws-k8s-worker-autoscaling-group
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.15.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.15.1 |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.workers](https://registry.terraform.io/providers/hashicorp/aws/4.15.1/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_policy.cloudwatch_cpu](https://registry.terraform.io/providers/hashicorp/aws/4.15.1/docs/resources/autoscaling_policy) | resource |
| [aws_autoscaling_policy.cpu_utilization](https://registry.terraform.io/providers/hashicorp/aws/4.15.1/docs/resources/autoscaling_policy) | resource |
| [aws_cloudwatch_metric_alarm.instance_cpu](https://registry.terraform.io/providers/hashicorp/aws/4.15.1/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_key_pair.cluster_nodes](https://registry.terraform.io/providers/hashicorp/aws/4.15.1/docs/resources/key_pair) | resource |
| [aws_launch_configuration.worker](https://registry.terraform.io/providers/hashicorp/aws/4.15.1/docs/resources/launch_configuration) | resource |
| [template_file.join](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | n/a | `any` | n/a | yes |
| <a name="input_ca_cert_hash"></a> [ca\_cert\_hash](#input\_ca\_cert\_hash) | n/a | `any` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `any` | n/a | yes |
| <a name="input_control_plane_ip"></a> [control\_plane\_ip](#input\_control\_plane\_ip) | n/a | `any` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | n/a | `any` | n/a | yes |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | n/a | `any` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | n/a | `any` | n/a | yes |
| <a name="input_kubernetes_join_token"></a> [kubernetes\_join\_token](#input\_kubernetes\_join\_token) | n/a | `any` | n/a | yes |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | n/a | `number` | `2` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | n/a | `number` | `1` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | n/a | `any` | n/a | yes |
| <a name="input_region_code"></a> [region\_code](#input\_region\_code) | n/a | `any` | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | n/a | `any` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | n/a | `any` | n/a | yes |
| <a name="input_target_group_arns"></a> [target\_group\_arns](#input\_target\_group\_arns) | n/a | `list` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
