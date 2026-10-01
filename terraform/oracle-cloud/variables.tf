variable "config_file_profile" {
  description = "Perfil de ~/.oci/config (region, usuario y clave de la API)"
  type        = string
  default     = "DEFAULT"
}

variable "compartment_ocid" {
  description = "OCID del compartimento. Para la cuenta gratuita sirve el OCID del tenancy (compartimento raiz)"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Clave publica SSH que podra entrar al servidor como usuario ubuntu"
  type        = string
  default     = "~/.ssh/oracle_free.pub"
}

variable "ssh_allowed_cidr" {
  description = "Desde donde se permite SSH. 0.0.0.0/0 = cualquier sitio; mejor tu IP publica con /32"
  type        = string
  default     = "0.0.0.0/0"
}

variable "nombre" {
  description = "Prefijo de los recursos"
  type        = string
  default     = "empresa"
}

# --- Limites del plan Always Free (ARM Ampere A1). Superarlos podria COSTAR dinero ---
variable "ocpus" {
  description = "Nucleos ARM. Always Free: 1.500 horas de OCPU al mes = 2 OCPU encendidos todo el mes"
  type        = number
  default     = 2

  validation {
    condition     = var.ocpus >= 1 && var.ocpus <= 2
    error_message = "Para seguir dentro de Always Free, ocpus debe estar entre 1 y 2."
  }
}

variable "memoria_gb" {
  description = "RAM en GB. Always Free: 9.000 horas de GB al mes = 12 GB encendidos todo el mes"
  type        = number
  default     = 12

  validation {
    condition     = var.memoria_gb >= 1 && var.memoria_gb <= 12
    error_message = "Para seguir dentro de Always Free, memoria_gb debe estar entre 1 y 12."
  }
}

variable "disco_gb" {
  description = "Disco de arranque en GB. Always Free incluye 200 GB de almacenamiento en bloque en total"
  type        = number
  default     = 100

  validation {
    condition     = var.disco_gb >= 50 && var.disco_gb <= 200
    error_message = "El disco debe estar entre 50 GB (minimo) y 200 GB (limite Always Free)."
  }
}
