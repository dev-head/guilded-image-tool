
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}

resource "aws_launch_configuration" "platform" {
  for_each                    = local.enabled_clusters
  name_prefix                 = format("%s-", lookup(each.value, "name"))
  key_name                    = lookup(each.value.launch_config, "key_name")
  image_id                    = lookup(each.value.launch_config, "image_id")
  instance_type               = lookup(each.value.launch_config, "instance_type")
  enable_monitoring           = lookup(each.value.launch_config, "enable_monitoring", true)
  ebs_optimized               = lookup(each.value.launch_config, "ebs_optimized", false)
  associate_public_ip_address = lookup(each.value.launch_config, "associate_public_ip_address", true)
  iam_instance_profile        = lookup(each.value.launch_config, "iam_instance_profile")

  dynamic "root_block_device" {
    for_each = [merge(var.default_root_block_device, lookup(each.value.launch_config, "root_block_device", {}))]
    content {
      volume_type           = lookup(root_block_device.value, "volume_type", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
      encrypted             = lookup(root_block_device.value, "encrypted", true)
    }
  }

  dynamic "ebs_block_device" {
    for_each = merge(var.default_block_devices, lookup(each.value.launch_config, "ebs_block_devices", {}))
    content {
      device_name           = lookup(ebs_block_device.value, "device_name", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
      encrypted             = lookup(ebs_block_device.value, "encrypted", true)
    }
  }

  security_groups = lookup(each.value.launch_config, "security_groups", true)
  user_data       = lookup(each.value.launch_config, "cloud_init_file", "") != "" ? data.template_cloudinit_config.platform[each.key].rendered : lookup(each.value.launch_config, "user_data", "")

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "platform" {
  for_each                  = local.enabled_clusters
  name_prefix               = format("%s", lookup(each.value, "name"))
  launch_configuration      = aws_launch_configuration.platform[each.key].id
  max_size                  = lookup(each.value.asg, "max_size")
  min_size                  = lookup(each.value.asg, "min_size")
  desired_capacity          = lookup(each.value.asg, "desired_capacity")
  force_delete              = lookup(each.value.asg, "force_delete")
  default_cooldown          = lookup(each.value.asg, "default_cooldown")
  health_check_type         = lookup(each.value.asg, "health_check_type")
  health_check_grace_period = lookup(each.value.asg, "health_check_grace_period")
  wait_for_capacity_timeout = lookup(each.value.asg, "wait_for_capacity_timeout")
  enabled_metrics           = lookup(each.value.asg, "enabled_metrics")
  vpc_zone_identifier       = lookup(each.value.asg, "vpc_zone_identifier")
  target_group_arns         = lookup(each.value.asg, "target_group_arns")
  load_balancers            = lookup(each.value.asg, "load_balancers")

  tags = flatten(concat([
    for _key, _value in merge(var.default_tags, each.value["tags"]) : {
      key                 = _key
      value               = _value
      propagate_at_launch = true
    }
    ],
    [{
      key                 = "Name"
      value               = lookup(each.value, "name")
      propagate_at_launch = true
    }]
    )
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = []
  }
}

data "template_file" "platform" {
  for_each = local.clusters_with_cloud_init
  template = file(lookup(each.value.launch_config, "cloud_init_file"))
  vars = merge(
    { Name : lookup(each.value, "name") },
    var.default_tags,
    lookup(each.value, "tags"),
    lookup(each.value.launch_config, "cloud_init_vars"),
    lookup(each.value, "code_deploy")
  )
}

data "template_cloudinit_config" "platform" {
  gzip          = lookup(each.value.launch_config, "cloud_init_gzip", true)
  base64_encode = lookup(each.value.launch_config, "cloud_init_base_encode", true)
  for_each      = local.clusters_with_cloud_init

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.platform[each.key].rendered
  }
}

# collection created if there's a cloud init file to use; needed in order to enforce
locals {
  enabled_clusters         = { for key, item in var.clusters : key => item if item.enabled == true }
  clusters_with_cloud_init = { for key, item in local.enabled_clusters : key => item if item.launch_config.cloud_init_file != "" }
}


