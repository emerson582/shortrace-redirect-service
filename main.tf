module "redirect_service" {
  source = "./terraform"
}

output "endpoint_url" {
  description = "URL raíz del API Gateway central para consumir los endpoints"
  value       = module.redirect_service.api_url
}