# infra

Entorno local y documentacion transversal del proyecto de practica.

## Repositorios
- `backend`: Spring Boot 4 (Java 17), Oracle + Flyway, CI con GitHub Actions
- `frontend`: Angular + TypeScript, CI con GitHub Actions
- `infra` (este): base de datos local con Docker, documentacion

## Base de datos local (requiere Docker Desktop)
1. `copy .env.example .env` y cambia las claves
2. `docker compose up -d`
3. Conexion en DBeaver: host `localhost`, puerto `1521`, servicio `FREEPDB1`, usuario/clave de `APP_USER`
4. Arranca el backend con `DB_PASSWORD` igual a `APP_USER_PASSWORD`; Flyway creara las tablas

## Fases de aprendizaje
1. Repositorios y Pull Requests (ramas, proteccion de `main`)
2. CI con GitHub Actions (ya hay un workflow por repo)
3. Base de datos y migraciones con Flyway
4. Docker: Dockerfile de backend y frontend
5. Despliegue por entornos (dev/prod) y rollback
6. Infraestructura como codigo (Terraform)
7. Secretos y seguridad
8. Observabilidad
