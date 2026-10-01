terraform {
  required_version = ">= 1.6"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Docker Desktop en Windows expone el motor por una tuberia con nombre
provider "docker" {
  host = var.docker_host
}

# --- Imagenes (se descargan de GHCR / Docker Hub) ---
resource "docker_image" "oracle" {
  name         = "gvenzl/oracle-free:slim"
  keep_locally = true # no borrar la imagen al destruir: otros contenedores pueden usarla
}

resource "docker_image" "backend" {
  name         = "ghcr.io/${var.github_owner}/empresa-backend:${var.backend_tag}"
  keep_locally = true
}

resource "docker_image" "frontend" {
  name         = "ghcr.io/${var.github_owner}/empresa-frontend:${var.frontend_tag}"
  keep_locally = true
}

# --- Red y volumen ---
resource "docker_network" "app" {
  name = "${var.entorno}-red"
}

resource "docker_volume" "oracle_data" {
  name = "${var.entorno}-oracle-data"
}

# --- Base de datos ---
resource "docker_container" "oracle" {
  name  = "${var.entorno}-oracle"
  image = docker_image.oracle.image_id

  env = [
    "ORACLE_PASSWORD=${var.oracle_password}",
    "APP_USER=${var.app_user}",
    "APP_USER_PASSWORD=${var.app_user_password}",
  ]

  volumes {
    volume_name    = docker_volume.oracle_data.name
    container_path = "/opt/oracle/oradata"
  }

  networks_advanced {
    name    = docker_network.app.name
    aliases = ["oracle"]
  }

  healthcheck {
    test     = ["CMD", "healthcheck.sh"]
    interval = "15s"
    timeout  = "10s"
    retries  = 30
  }

  restart = "unless-stopped"
}

# --- Backend ---
resource "docker_container" "backend" {
  name  = "${var.entorno}-backend"
  image = docker_image.backend.image_id

  env = [
    "DB_URL=jdbc:oracle:thin:@//oracle:1521/FREEPDB1",
    "DB_USER=${var.app_user}",
    "DB_PASSWORD=${var.app_user_password}",
    "TZ=UTC",
  ]

  networks_advanced {
    name    = docker_network.app.name
    aliases = ["backend"]
  }

  restart    = "unless-stopped"
  depends_on = [docker_container.oracle]
}

# --- Frontend (nginx) ---
resource "docker_container" "frontend" {
  name  = "${var.entorno}-frontend"
  image = docker_image.frontend.image_id

  ports {
    internal = 80
    external = var.http_port
  }

  networks_advanced {
    name    = docker_network.app.name
    aliases = ["frontend"]
  }

  restart    = "unless-stopped"
  depends_on = [docker_container.backend]
}
