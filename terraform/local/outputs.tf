output "url_frontend" {
  description = "Donde abrir la aplicacion"
  value       = "http://localhost:${var.http_port}"
}

output "contenedores" {
  value = [
    docker_container.oracle.name,
    docker_container.backend.name,
    docker_container.frontend.name,
  ]
}
