
resource "aws_launch_configuration" "example" {
  image_id      = var.ami
  instance_type = var.instance_type
  # The vpc_security_group_ids parameter is set to the ID of the security group created by the module.
  security_groups = [aws_security_group.instance.id]
  # The <<EOF and EOF are Terraform’s heredoc syntax, which allows you to create
  # multiline strings without having to insert \n characters all over the plac


  user_data = var.user_data

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
    precondition {
      condition     = data.aws_ec2_instance_type.instance.free_tier_eligible
      error_message = "${var.instance_type} is not part of the AWS Free Tier!"
    }
  }

}
resource "aws_autoscaling_group" "example" {
  count                = var.enable_autoscaling ? 1 : 0
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnets.default.ids

  # Configure integrations with a load balancer
  target_group_arns = var.target_group_arns
  health_check_type = var.health_check_type

  min_size = var.min_size
  max_size = var.max_size
  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }

  lifecycle {
    postcondition {
      condition     = length(self.availability_zones) > 1
      error_message = "You must use more than one AZ for high availability!"
    }
  }

  dynamic "tag" {
    for_each = var.custom_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

}
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count                  = var.enable_autoscaling ? 1 : 0
  autoscaling_group_name = module.webserver_cluster.asg_name
  scheduled_action_name  = "${var.cluster_name}-scale-out-during-business-hours"
  min_size               = 1
  max_size               = 2
  desired_capacity       = 2
  recurrence             = "0 9 * * *"
}
resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count                  = var.enable_autoscaling ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.example.name
  scheduled_action_name  = "${var.cluster_name}-scale-in-at-night"
  min_size               = 1
  max_size               = 2
  desired_capacity       = 1
  recurrence             = "0 17 * * *"
}

resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

