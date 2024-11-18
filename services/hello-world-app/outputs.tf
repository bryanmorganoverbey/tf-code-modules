output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "The domain name of the load balancer"
}

output "asg_name" {
  value       = aws_autoscaling_group.example.name
  description = "the autoscaling group name"
}

output "instance_security_group_id" {
  value       = aws_security_group.instance.id
  description = "The ID of the security group for the instances"
}
