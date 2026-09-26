# Runbook de rollback: Registro de solicitudes

## Cuando aplicarlo

- Mas de 10 % de ejecuciones con error en una hora, o
- Datos incorrectos confirmados en el sistema destino, o
- Alerta del workflow "Manejo de errores" repetida despues de un despliegue

Si hay sospecha de filtracion de datos personales, ademas del rollback activar el procedimiento de incidentes de `docs/cumplimiento.md` (aviso a la ANPD en maximo 48 horas).

## Responsables

| Rol | Nombre | Contacto |
| --- | --- | --- |
| Ejecuta el rollback | | |
| Aprueba el rollback | | |
| Comunica a usuarios | | |

## 1. Identificar la ultima version buena

```bash
git tag --sort=-creatordate      # versiones desplegadas
git log --oneline -10            # ultimos cambios
```

## 2. Pasos por plataforma

### n8n

1. Desactivar el workflow afectado en el editor.
2. `./scripts/n8n-rollback.sh <tag> Solicitudes_v2_segura`
3. Publicar el workflow (Publish en n8n 2.x) y ejecutar `API_KEY=<clave> ./scripts/probar.sh v2`
4. Dejar constancia: `git checkout <tag> -- n8n/workflows/Solicitudes_v2_segura.json` y commit `fix: rollback a <tag>`

### UiPath

1. Orchestrator > carpeta > Automations > Processes > proceso `ProcesarSolicitud`.
2. Editar el proceso y seleccionar la version anterior del paquete (o accion Rollback).
3. Ejecutar un job de prueba y revisar Logs.
4. Anotar en la tabla de incidentes la version restaurada y el commit que corresponde.

### Power Platform

Power Platform no permite importar una version menor sobre una mayor.

1. `git checkout <tag> -- powerplatform/`
2. Subir la version en `powerplatform/src/RegistroSolicitudes/Other/Solution.xml` (por ejemplo, 1.0.2.0 -> 1.0.3.0).
3. `pac solution pack --zipfile out/RegistroSolicitudes_managed.zip --folder powerplatform/src/RegistroSolicitudes --packagetype Managed`
4. `pac solution import --path out/RegistroSolicitudes_managed.zip`
5. Probar desde la app y revisar el run history del flujo.

## 3. Verificacion

- [ ] Una solicitud de prueba llega a n8n (respuesta 202)
- [ ] El robot se ejecuta en Orchestrator sin error
- [ ] La fila aparece en la bitacora de auditoria con la version restaurada
- [ ] Sin alertas nuevas durante 30 minutos

## 4. Registro de incidentes

| Fecha | Plataforma | Version afectada | Version restaurada | Causa | Tiempo de recuperacion | Commit del fix |
| --- | --- | --- | --- | --- | --- | --- |
| | | | | | | |
