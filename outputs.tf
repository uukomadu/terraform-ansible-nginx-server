output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.proj_3.id
}

output "subnet_id" {
  description = "ID of the public subnet containing the EC2 instance"
  value       = data.aws_subnet.public.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway attached to the default VPC"
  value       = data.aws_internet_gateway.public.id
}

output "route_table_id" {
  description = "ID of the route table used by the public subnet"
  value       = data.aws_route_table.public.id
}

output "public_ip" {
  description = "Public IPv4 address used by Ansible and SSH"
  value       = aws_instance.proj_3.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.proj_3.public_dns
}

output "website_url" {
  description = "URL for the deployed website"
  value       = "http://${aws_instance.proj_3.public_ip}"
}

output "ssh_command" {
  description = "Example SSH command"
  value       = "ssh -i ~/.ssh/P3.pem ubuntu@${aws_instance.proj_3.public_ip}"
}
