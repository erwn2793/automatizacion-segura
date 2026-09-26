# Ficha de cumplimiento: Registro de solicitudes

> Documento de trabajo del curso. No reemplaza la revision del area legal de la organizacion.
> Marco: Ley 29733 y su reglamento (D.S. 016-2024-JUS, vigente desde el 30/03/2025) y, si hay titulares en la Union Europea, el GDPR.

## 1. Tratamiento

| Campo | Valor |
| --- | --- |
| Finalidad | Registrar y atender solicitudes de clientes (consultas, reclamos, reembolsos) |
| Base legal | Consentimiento expreso del titular (casilla obligatoria en la app, sin premarcar) |
| Responsable del tratamiento | _Empresa_ |
| Oficial de Datos Personales / DPO | _Nombre y correo_ |
| Banco de datos inscrito ante la ANPD | _Pendiente / numero de inscripcion_ |

## 2. Datos que se recogen (minimizacion)

| Dato | Para que se usa | Se puede eliminar? |
| --- | --- | --- |
| Nombre | Dirigirse al titular | No |
| DNI | Identificar al titular en el sistema destino | No; en la bitacora solo se guarda su hash |
| Correo | Responder la solicitud | No |
| Telefono | Contacto alternativo | Si es opcional, dejarlo opcional en la app |
| Detalle | Atender la solicitud | No; pedir al usuario que no incluya datos sensibles |

## 3. Por donde pasa el dato (transferencias)

| Sistema | Que hace | Region / pais | Garantia |
| --- | --- | --- | --- |
| Power Apps / Dataverse | Captura y almacena | _Region del entorno_ | Contrato Microsoft |
| Power Automate | Envia a n8n | _Region del entorno_ | Contrato Microsoft |
| n8n | Valida y orquesta | _Servidor propio / n8n Cloud (region)_ | _Contrato o infraestructura propia_ |
| UiPath Automation Cloud | Ejecuta el robot | _Region de la organizacion_ | Contrato UiPath |
| Google Sheets | Bitacora (sin datos personales en claro) | _Region_ | Contrato Google |
| Proveedor SMTP | Correos | _Region_ | _Contrato_ |

## 4. Medidas de seguridad aplicadas

| Medida | Donde |
| --- | --- |
| Webhook autenticado con clave (`X-API-Key`) | n8n |
| Secretos en almacenes cifrados (Credentials, Assets, variables de entorno) | n8n, UiPath, Power Platform |
| Sin secretos en el repositorio (gitleaks) | GitHub |
| DNI con hash y sal en la bitacora; enmascarado en logs | n8n, UiPath |
| Ejecuciones exitosas no se guardan; las fallidas se borran a los 7 dias | n8n |
| Secure inputs / outputs en el flujo | Power Automate |
| Casilla Private en actividades con datos personales | UiPath |
| Roles con minimo privilegio | Orchestrator, Power Platform, GitHub |
| Rama `main` protegida y PR con revision | GitHub |

## 5. Conservacion

| Donde | Plazo | Como se borra |
| --- | --- | --- |
| Dataverse | _Definir, por ejemplo 2 anos_ | _Proceso de depuracion_ |
| Ejecuciones de n8n | Exitosas: no se guardan. Fallidas: 7 dias | Poda automatica (`EXECUTIONS_DATA_MAX_AGE=168`) |
| Logs de Orchestrator | _Segun politica del tenant_ | Retencion de Orchestrator |
| Bitacora de auditoria | _Definir_ | Solo contiene hash, sin datos en claro |

## 6. Decisiones automatizadas y etica

- Las solicitudes de tipo **Reembolso** no se procesan sin aprobacion humana (enlace de aprobar/rechazar; limite 24 horas).
- La respuesta al titular indica que el proceso es automatico y ofrece un contacto humano.
- Prueba de sesgo: si se agrega un paso de IA o reglas de priorizacion, probar pares de solicitudes que solo cambian nombre, distrito o edad y documentar el resultado aqui.

| Fecha | Cambio probado | Resultado | Accion |
| --- | --- | --- | --- |
| | | | |

## 7. Derechos del titular (ARCO y portabilidad)

1. El titular escribe a _correo de atencion_.
2. Se identifica la solicitud calculando el hash de su DNI y buscandolo en la bitacora.
3. Se atiende en el sistema destino y en Dataverse; se registra la atencion sin guardar el dato suprimido.

## 8. Incidentes de seguridad

| Paso | Plazo | Responsable |
| --- | --- | --- |
| Contener (desactivar flujos, rotar credenciales) | Inmediato | |
| Evaluar datos y titulares afectados | Primeras horas | |
| Notificar a la ANPD | Maximo 48 horas desde que se conoce el incidente | |
| Comunicar a los titulares afectados | En lenguaje claro, con las medidas adoptadas | |
| GDPR (si aplica): notificar a la autoridad de control | Maximo 72 horas | |
