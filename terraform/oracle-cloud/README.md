# Oracle Cloud (Always Free)

Servidor ARM **gratuito** para la aplicación, descrito con Terraform. Solo crea recursos del plan *Always Free*; las variables `ocpus`, `memoria_gb` y `disco_gb` tienen validación para no pasarse del límite gratuito.

| Recurso | Límite gratuito aplicado |
|---|---|
| VM `VM.Standard.A1.Flex` (ARM) | máx. 2 OCPU y 12 GB de RAM (1.500 h de OCPU y 9.000 h de GB al mes) |
| Disco de arranque | 100 GB por defecto (límite del plan: 200 GB en total) |
| Red (VCN, subred, gateway, rutas, firewall) | gratis |
| IP pública efímera | gratis |

> **No actualices la cuenta a "Pay As You Go"**: mientras sigas en el plan gratuito, Oracle no puede cobrarte por encima del crédito de prueba.

## Requisitos
- `~/.oci/config` con tu usuario, tenancy, fingerprint, región y clave privada de la API
- Clave SSH `~/.ssh/oracle_free` (+ `.pub`)
- `terraform.tfvars` con `compartment_ocid` (ver `terraform.tfvars.example`)

## Uso
```
terraform init
terraform plan
terraform apply
```

### "Out of host capacity"
Es habitual con el plan gratuito: Oracle no tiene hueco ARM libre en ese momento. Prueba `.\reintentar.ps1`, que reintenta cada pocos minutos (empieza con 1 OCPU y 6 GB, que es más fácil de conseguir; después se amplía a 2 OCPU y 12 GB cambiando las variables y repitiendo `apply`, con un reinicio).

## Qué instala el servidor
`cloud-init.yaml` instala Docker y deja `/opt/app` listo. **No lleva contraseñas**: el despliegue por SSH escribirá el `.env` y levantará la pila.
