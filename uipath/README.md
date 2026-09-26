# UiPath: versionado y seguridad del robot ProcesarSolicitud

n8n llama a este proceso por la API de Orchestrator (`StartJobs`). El codigo fuente vive en Git; lo que se ejecuta es un paquete con numero de version.

## Obtener la Release Key

1. Orchestrator → carpeta del curso → Automations → Processes → `ProcesarSolicitud`.
2. La Release Key aparece en los detalles del proceso (o en la URL al editarlo).
3. Copiarla a `UIPATH_RELEASE_KEY` del `.env`. El id de la carpeta (`fid=` en la URL) va en `UIPATH_FOLDER_ID`.

## Versionado

1. Guardar el proyecto en `uipath/ProcesarSolicitud/` dentro de este repo.
2. En Studio: barra inferior → Add to Source Control → Git Init (la carpeta ya es un repo). Commit and Push.
3. Publicar en Orchestrator la version **1.0.1** (correcta).
4. Publicar la **1.0.2** con un error intencional (una actividad Throw al inicio) y anotar el commit en Release Notes.
5. Dejar el proceso apuntando a la 1.0.2 para la demo de rollback.

En la demo: Show History y Compare with Latest sobre `Main.xaml`. Ejecutar 1.0.2 (falla). Editar el proceso y elegir el paquete 1.0.1 (o Rollback). Ejecutar de nuevo. Antes de publicar, Design → Analyze Project (Workflow Analyzer).

## Credenciales y accesos

- External Application (Confidential) con scopes `OR.Jobs` y `OR.Execution`. El Client ID y el Secret van en la credencial OAuth2 de n8n, nunca en el repo.
- Secretos del robot: Assets de tipo Credential. En el robot, Get Credential (SecureString).
- Rol "Operador de solicitudes": ver y ejecutar procesos y ver logs. Sin editar assets ni paquetes.

## Datos personales

Registrar en Log Message solo `dni_mascara` y `correlation_id`. Marcar Private en las actividades que reciben el DNI para que Orchestrator no guarde el valor.
