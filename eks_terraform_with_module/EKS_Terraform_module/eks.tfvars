admin_users                              = ["admin1", "admin2"]
developer_users                          = ["developer1", "developer2"]
asg_instance_types                       = ["t3.small", "t2.small"]
autoscaling_minimum_size_by_az           = 2
autoscaling_maximum_size_by_az           = 4
autoscaling_average_cpu                  = 30
// https://github.com/aws/eks-charts/tree/gh-pages
spot_termination_handler_chart_name      = "aws-node-termination-handler"
spot_termination_handler_chart_repo      = "https://aws.github.io/eks-charts"
spot_termination_handler_chart_version   = "0.9.5"    // Latest Version
spot_termination_handler_chart_namespace = "kube-system"