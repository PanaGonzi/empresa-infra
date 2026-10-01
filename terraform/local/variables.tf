variable "docker_host" {
  description = "Endpoint del motor Docker"
  type        = string
  default     = "npipe:////./pipe/docker_engine"
}

variable "entorno" {
  description = "Nombre del entorno; prefija todos los recursos para poder tener varios a la vez"
  type        = string
  default     = "tf-dev"
}

variable "github_owner" {
  description = "Propietario en GHCR, en minusculas"
  type        = string
  default     = "panagonzi"
}

variable "backend_tag" {
  description = "Tag de la imagen del backend (sha completo o latest). Cambiarlo = desplegar otra version o hacer rollback"
  type        = string
  default     = "latest"
}

variable "frontend_tag" {
  description = "Tag de la imagen del frontend"
  type        = string
  default     = "latest"
}

variable "http_port" {
  description = "Puerto local donde se publica el frontend"
  type        = number
  default     = 8090
}

variable "app_user" {
  type    = string
  default = "APP_USER"
}

# Sin valor por defecto a proposito: se pasan por TF_VAR_* o terraform.tfvars (que no se sube a git)
variable "oracle_password" {
  type      = string
  sensitive = true
}

variable "app_user_password" {
  type      = string
  sensitive = true
}
