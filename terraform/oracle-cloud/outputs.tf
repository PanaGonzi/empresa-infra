output "ip_publica" {
  description = "IP publica del servidor"
  value       = oci_core_instance.servidor.public_ip
}

output "ssh" {
  description = "Comando para entrar"
  value       = "ssh -i ~/.ssh/oracle_free ubuntu@${oci_core_instance.servidor.public_ip}"
}

output "url" {
  description = "Donde estara la aplicacion tras el despliegue"
  value       = "http://${oci_core_instance.servidor.public_ip}"
}

output "recursos_gratuitos" {
  description = "Resumen para comprobar que todo cabe en Always Free"
  value = {
    shape      = oci_core_instance.servidor.shape
    ocpus      = var.ocpus
    memoria_gb = var.memoria_gb
    disco_gb   = var.disco_gb
  }
}
