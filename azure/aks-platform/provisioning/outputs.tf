output "cluster_fqdn" {
  value = module.aks.cluster_fqdn
  sensitive = true
}

output "client_key" {
  value = module.aks.client_key
  sensitive = true
}

output "client_certificate" {
  value = module.aks.client_certificate
  sensitive = true
}

output "cluster_ca_certificate" {
  value = module.aks.cluster_ca_certificate
  sensitive = true
}