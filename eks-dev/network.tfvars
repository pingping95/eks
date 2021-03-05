cluster_name            = "test-eks"
iac_environment_tag     = "development"
name_prefix             = "test"
main_network_block      = "192.168.0.0/16"
available_azs           = ["ap-northeast-2a", "ap-northeast-2c"]
public_subnet           = ["192.168.1.0/24","192.168.2.0/24"]
private_subnet           = ["192.168.11.0/24", "192.168.12.0/24"]