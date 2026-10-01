# Terraform

Infraestructura como código: la misma pila (Oracle + backend + frontend) descrita en archivos,
para que se pueda crear, cambiar y destruir de forma reproducible.

## `local/` — pila en tu Docker Desktop
Practica el ciclo completo de Terraform sin cuentas de nube ni costes.
Usa nombres con prefijo `tf-dev-` y el puerto **8090** para no chocar con el compose manual.

```bash
cd terraform/local
cp terraform.tfvars.example terraform.tfvars   # y cambia las claves
terraform init       # descarga el proveedor docker
terraform validate   # comprueba la sintaxis
terraform plan       # muestra QUE cambiaria, sin tocar nada
terraform apply      # lo crea (pide confirmacion)
terraform destroy    # lo borra todo
```

### Ejercicios
1. **Idempotencia:** ejecuta `terraform apply` dos veces; la segunda debe decir "No changes".
2. **Rollback:** `terraform apply -var backend_tag=<sha de una version anterior>` y luego vuelve a `latest`.
3. **Deriva (drift):** borra un contenedor a mano con `docker rm -f tf-dev-backend` y ejecuta `terraform plan`; verás que lo detecta y lo recrea.

## Del local a la nube
Cuando haya presupuesto y proveedor, se añade un módulo `servidor/` (VM + red + firewall + base de datos
gestionada) con el mismo patrón, y el **estado remoto** (bucket con bloqueo) para trabajar sin perderlo.
Reglas que conviene fijar desde el principio:
- El estado (`*.tfstate`) puede contener secretos: nunca en git, siempre en un backend remoto cifrado.
- Cambios de infraestructura **solo por Pull Request**, con `terraform plan` visible en el PR.
- Un directorio (y un estado) por entorno: `dev` y `prod` separados.
