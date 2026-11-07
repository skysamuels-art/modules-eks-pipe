output "public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "private_ip" {
  value = aws_instance.jenkins.private_ip
}

output "security_group_id" {
  value = aws_security_group.jenkins.id
}