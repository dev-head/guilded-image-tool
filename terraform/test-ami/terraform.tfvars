aws_region  = "us-east-1"
name        = "platform_test"

default_tags    = {
    Environment     = "test"
    ManagedBy       = "terraform"
    Platform        = "Example"
    Project         = "test"
    Sub_Platform1   = "TestingPackerAMI"
}

clusters    = {

    example_ecs = {
        name    = "ami_test_example_ecs"
        enabled = true
        code_deploy = {
            cd_s3_source    = ""
            cd_source_type  = ""
        }
        tags = {
            Environment     = "Test"
            Project         = "test"
            ManagedBy       = "terraform"
            Platform        = "Example"
        }
        asg = {
            max_size                    = 1
            min_size                    = 0
            desired_capacity            = 0
            force_delete                = false
            default_cooldown            = 10
            health_check_type           = "EC2"
            health_check_grace_period   = 300
            wait_for_capacity_timeout   = "5m"
            enabled_metrics             = []
            vpc_zone_identifier         = ["subnet-55555555", "subnet-55555555"]
            target_group_arns           = []
            load_balancers              = []
        }
        launch_config = {
            key_name                    = "cluster"
            image_id                    = "ami-blahblahblahblah1"
            instance_type               = "t3.micro"
            enable_monitoring           = false
            ebs_optimized               = false
            security_groups             = ["sg-555555"]
            iam_instance_profile        = ""
            cloud_init_file             = "cloud-init.example-ecs.yml"
            cloud_init_vars             = {}
            cloud_init_base_encode      = false
            cloud_init_gzip             = false
            user_data                   = ""
            root_block_device   = {
                volume_type             = "gp2"
                volume_size             = 20
                iops                    = null
                delete_on_termination   = true
            }
            ebs_block_devices = {
                vol1 = {
                    device_name             = "/dev/sdf"
                    volume_type             = "gp2"
                    volume_size             = 200
                    iops                    = null
                    delete_on_termination   = true
                }
            }
        }
    }

    example_nginx_php56 = {
        name    = "ami_test_example_nginx_php56"
        enabled = true
        code_deploy = {
            cd_s3_source    = ""
            cd_source_type  = ""
        }
        tags = {
            Environment     = "Test"
            Project         = "test"
            ManagedBy       = "terraform"
            Platform        = "Example"
        }
        asg = {
            max_size                    = 1
            min_size                    = 0
            desired_capacity            = 0
            force_delete                = false
            default_cooldown            = 10
            health_check_type           = "EC2"
            health_check_grace_period   = 300
            wait_for_capacity_timeout   = "5m"
            enabled_metrics             = []
            vpc_zone_identifier         = ["subnet-55555555", "subnet-55555555"]
            target_group_arns           = []
            load_balancers              = []
        }
        launch_config = {
            key_name                    = "cluster"
            image_id                    = "ami-blahblahblahblah2"
            instance_type               = "t3.micro"
            enable_monitoring           = false
            ebs_optimized               = false
            security_groups             = ["sg-555555"]
            iam_instance_profile        = ""
            cloud_init_file             = "cloud-init.example-nginx-php56.yml"
            cloud_init_vars             = {}
            cloud_init_base_encode      = false
            cloud_init_gzip             = false
            user_data                   = ""
            root_block_device   = {
                volume_type             = "gp2"
                volume_size             = 20
                iops                    = null
                delete_on_termination   = true
            }
            ebs_block_devices = {
                vol1 = {
                    device_name             = "/dev/sdf"
                    volume_type             = "gp2"
                    volume_size             = 200
                    iops                    = null
                    delete_on_termination   = true
                }
            }
        }
    }

    example_apache_php56 = {
        name    = "ami_test_example_apache_php56"
        enabled = true
        code_deploy = {
            cd_s3_source    = ""
            cd_source_type  = ""
        }
        tags = {
            Environment     = "Test"
            Project         = "test"
            ManagedBy       = "terraform"
            Platform        = "Example"
        }
        asg = {
            max_size                    = 1
            min_size                    = 0
            desired_capacity            = 0
            force_delete                = false
            default_cooldown            = 10
            health_check_type           = "EC2"
            health_check_grace_period   = 300
            wait_for_capacity_timeout   = "5m"
            enabled_metrics             = []
            vpc_zone_identifier         = ["subnet-55555555", "subnet-55555555"]
            target_group_arns           = []
            load_balancers              = []
        }
        launch_config = {
            key_name                    = "cluster"
            image_id                    = "ami-blahblahblahblah3"
            instance_type               = "t3.micro"
            enable_monitoring           = false
            ebs_optimized               = false
            security_groups             = ["sg-555555"]
            iam_instance_profile        = ""
            cloud_init_file             = "cloud-init.example-apache-php56.yml"
            cloud_init_vars             = {}
            cloud_init_base_encode      = false
            cloud_init_gzip             = false
            user_data                   = ""
            root_block_device   = {
                volume_type             = "gp2"
                volume_size             = 20
                iops                    = null
                delete_on_termination   = true
            }
            ebs_block_devices = {
                vol1 = {
                    device_name             = "/dev/sdf"
                    volume_type             = "gp2"
                    volume_size             = 200
                    iops                    = null
                    delete_on_termination   = true
                }
            }
        }
    }
}