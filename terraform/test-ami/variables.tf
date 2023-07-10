
variable "aws_region" {
    description = ""
    type        = string
    default     = "us-east-1"
}

variable "aws_profile" {
    description = ""
    type        = string
    default     = ""
}

variable "default_root_block_device" {
    description = "Used as the default root block device configuration; you can override in the cluster launch configuration; otherwise these are used."
    type = object({
        volume_type             = string
        volume_size             = number
        iops                    = string
        delete_on_termination   = bool
        encrypted               = bool
    })
    default = {
        volume_type             = "gp2"
        volume_size             = 20
        iops                    = null
        delete_on_termination   = true
        encrypted               = true
    }
}

variable "default_block_devices" {
    description = "Used as the default ebs block devices configuration; you can override in the cluster launch configuration; otherwise these are used."
    type = map(object({
        device_name             = string
        snapshot_id            = string
        volume_type             = string
        volume_size             = number
        iops                    = string
        delete_on_termination   = bool
        encrypted               = bool
    }))
    default = {
        vol1 = {
            device_name             = "/dev/sdf"
            snapshot_id            = null
            volume_type             = "gp2"
            volume_size             = 20
            iops                    = null
            delete_on_termination   = true
            encrypted               = true
    }}
}

variable "default_tags" {
    description = "Default tags applied to everything, some other configurations can have merged specific ones."
    type        = object({
        Environment     = string
        ManagedBy       = string
        Platform        = string
        Project         = string
        Sub_Platform1   = string
    })
}

variable "name" {
    description = "Name of the platform"
    type        = string
}

variable "clusters" {
    description = "Clusters configuration"
    type = map(object({
        name    = string
        enabled = bool

        code_deploy = object({
            cd_s3_source    = string
            cd_source_type  = string
        })

        tags = object({
            Environment     = string
            ManagedBy       = string
            Platform        = string
            Project         = string
        })

        asg = object({
            max_size                    = number
            min_size                    = number
            desired_capacity            = number
            force_delete                = bool
            default_cooldown            = number
            health_check_type           = string
            health_check_grace_period   = number
            wait_for_capacity_timeout   = string
            enabled_metrics             = list(string)
            vpc_zone_identifier         = list(string)
            target_group_arns           = list(string)
            load_balancers              = list(string)
        })

        launch_config = object({
            key_name                = string
            image_id                = string
            instance_type           = string
            enable_monitoring       = string
            ebs_optimized           = bool
            root_block_device       = map(any)
            ebs_block_devices       = map(map(any))
            security_groups         = list(string)
            iam_instance_profile    = string
            cloud_init_file         = string
            cloud_init_vars         = map(any)
            cloud_init_base_encode  = bool
            cloud_init_gzip         = bool
            user_data               = string

        })
    }))
}
