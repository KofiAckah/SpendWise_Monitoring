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
