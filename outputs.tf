output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "ec2_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.wordpress.public_ip
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.wordpress.endpoint
  sensitive   = true
}

output "rds_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.wordpress.port
}