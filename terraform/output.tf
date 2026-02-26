output "vpc_id" {
  description = "The ID of the VPC created in the networking module"
  value       = module.networking.vpc_id
}

output "public_subnet_id" {
  description = "The ID of the public subnet created in the networking module"
  value       = module.networking.public_subnet_id
}

output "jenkins_sg_id" {
  description = "Security Group ID for Jenkins"
  value       = module.security.jenkins_sg_id
}

output "app_sg_id" {
  description = "Security Group ID for App"
  value       = module.security.app_sg_id
}

output "backend_ecr_repository_url" {
  description = "The URL of the backend ECR repository"
  value       = module.ecr.backend_repository_url
}

output "frontend_ecr_repository_url" {
  description = "The URL of the frontend ECR repository"
  value       = module.ecr.frontend_repository_url
}

output "jenkins_public_ip" {
  description = "Public IP of the Jenkins Server"
  value       = module.compute.jenkins_public_ip
}

output "app_public_ip" {
  description = "Public IP of the App Server"
  value       = module.compute.app_public_ip
}

output "jenkins_instance_id" {
  description = "Instance ID of the Jenkins Server"
  value       = module.compute.jenkins_instance_id
}

output "app_instance_id" {
  description = "Instance ID of the App Server"
  value       = module.compute.app_instance_id
}

output "parameter_store_path" {
  description = "Parameter Store path prefix for application configuration"
  value       = module.parameters.parameter_path_prefix
}

output "parameter_names" {
  description = "Map of parameter names in Parameter Store"
  value       = module.parameters.parameter_names
}

output "monitoring_server_public_ip" {
  description = "Public IP of the Monitoring Server (Prometheus + Grafana)"
  value       = module.compute.monitoring_server_public_ip
}

output "monitoring_server_instance_id" {
  description = "Instance ID of the Monitoring Server"
  value       = module.compute.monitoring_server_instance_id
}

output "monitoring_sg_id" {
  description = "Security Group ID for the Monitoring Server"
  value       = module.security.monitoring_sg_id
}

# ==============================================================
# Monitoring module outputs (CloudWatch / CloudTrail / GuardDuty)
# ==============================================================
output "cloudwatch_log_group_name" {
  description = "CloudWatch Log Group name for SpendWise application logs."
  value       = module.monitoring.cloudwatch_log_group_name
}

output "cloudtrail_s3_bucket_name" {
  description = "S3 bucket name used by the spendwise-trail CloudTrail."
  value       = module.monitoring.cloudtrail_s3_bucket_name
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID for this account/region."
  value       = module.monitoring.guardduty_detector_id
}
