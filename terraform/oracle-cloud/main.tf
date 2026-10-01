terraform {
  required_version = ">= 1.6"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.0"
    }
  }
}

# Se autentica con ~/.oci/config (usuario, tenancy, fingerprint, region y clave privada)
provider "oci" {
  config_file_profile = var.config_file_profile
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Ubuntu 24.04 para ARM (aarch64), la imagen mas reciente
data "oci_core_images" "ubuntu_arm" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# --- Red (VCN, subred publica, salida a internet): todo gratuito ---
resource "oci_core_vcn" "red" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.nombre}-vcn"
  cidr_blocks    = ["10.0.0.0/16"]
  dns_label      = var.nombre
}

resource "oci_core_internet_gateway" "salida" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.red.id
  display_name   = "${var.nombre}-igw"
}

resource "oci_core_route_table" "publica" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.red.id
  display_name   = "${var.nombre}-rutas"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.salida.id
  }
}

# Firewall de la nube: solo SSH y HTTP entran; todo puede salir
resource "oci_core_security_list" "firewall" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.red.id
  display_name   = "${var.nombre}-firewall"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.ssh_allowed_cidr
    description = "SSH"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "HTTP (frontend)"
    tcp_options {
      min = 80
      max = 80
    }
  }
}

resource "oci_core_subnet" "publica" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.red.id
  display_name      = "${var.nombre}-subred-publica"
  cidr_block        = "10.0.1.0/24"
  dns_label         = "publica"
  route_table_id    = oci_core_route_table.publica.id
  security_list_ids = [oci_core_security_list.firewall.id]
}

# --- Servidor: ARM Ampere A1 (Always Free) ---
resource "oci_core_instance" "servidor" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "${var.nombre}-servidor"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memoria_gb
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ubuntu_arm.images[0].id
    boot_volume_size_in_gbs = var.disco_gb
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.publica.id
    assign_public_ip = true # IP efimera: gratis
  }

  metadata = {
    ssh_authorized_keys = file(pathexpand(var.ssh_public_key_path))
    user_data           = base64encode(file("${path.module}/cloud-init.yaml"))
  }

  lifecycle {
    # Una imagen nueva de Ubuntu no debe destruir y recrear el servidor
    ignore_changes = [source_details[0].source_id]
  }
}
