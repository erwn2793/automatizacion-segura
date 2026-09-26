# Registro de solicitudes: automatizacion segura

Proyecto del Programa de Especializacion en Integracion, Seguridad y Despliegue con n8n, UiPath y Power Platform (modulos 3 y 4).

```
Power Apps -> Dataverse -> Power Automate -> n8n (webhook) -> API de Orchestrator -> Robot UiPath
                                               |
                                               +-> Bitacora de auditoria (Google Sheets)
```

## Ficha del bot

| Campo | Valor |
| --- | --- |
| Nombre | Registro de solicitudes |
| Dueno (responsable) | _nombre y correo_ |
| Proposito | Registrar solicitudes de clientes y ejecutar su procesamiento en el sistema destino |
| Datos personales | Nombre, DNI, correo, telefono (ver `docs/cumplimiento.md`) |
| Decisiones automaticas | Valida datos y envia al robot. Las solicitudes de tipo "Reembolso" requieren aprobacion humana |
| Transparencia | La respuesta al usuario indica que el proceso es automatico y como contactar a una persona |
| Reportar un problema | _correo de soporte_ |

## Estructura

| Ruta | Contenido |
| --- | --- |
| `n8n/workflows/` | Workflows exportados (v1 insegura para la demo, v2 segura, manejo de errores) |
| `scripts/` | Exportar, hacer rollback y probar los workflows de n8n |
| `uipath/` | Proyecto del robot y guia de versionado y seguridad |
| `powerplatform/` | Solucion desempaquetada y guia |
| `docs/` | Runbook de rollback, cumplimiento y encabezados de la bitacora |
| `tests/` | Solicitudes de prueba con datos ficticios |

## Arranque rapido (n8n)

```bash
cp .env.example .env              # completar valores
docker compose up -d              # abrir http://localhost:5678 y crear la cuenta owner
docker compose exec -u node n8n n8n import:workflow --separate --input=/workflows
```

Importacion desde la interfaz: abre un workflow vacio y usa el menu del workflow (los tres puntos) → **Import from File**. Repite una vez por archivo, en este orden:

1. `n8n/workflows/Manejo_de_errores.json`
2. `n8n/workflows/Solicitudes_v1_insegura.json`
3. `n8n/workflows/Solicitudes_v2_segura.json`

Cada archivo es un solo workflow. n8n rechaza un JSON que sea una lista de varios.

Luego, en el editor de n8n:

1. Crear las credenciales: **Header Auth** (`X-API-Key`), **OAuth2 API** de UiPath (Client Credentials), **SMTP** y **Google Sheets**.
2. Abrir cada workflow y seleccionar la credencial en los nodos que la piden.
3. En `Solicitudes v2 - segura` > Settings > Error workflow: `Manejo de errores`.
4. Publicar el workflow (boton **Publish** en n8n 2.x; **Active** en versiones anteriores) y probar: `API_KEY=<clave> ./scripts/probar.sh v2`

Probado con n8n 2.40.7: respuestas 202/400/403, aprobacion humana, hash del DNI, alerta de errores y exportacion sin cambios espurios.

## Flujo de trabajo con Git

- `main` = produccion (protegida, solo por PR con aprobacion)
- `develop` = pruebas
- `feature/<tema>` para cambios, `hotfix/<tema>` para urgencias
- Cada version que llega a produccion lleva un tag (`v1.1.0`) y actualiza la constante `VERSION` del nodo "Validar datos"

## Equipo

<!-- Practica: agrega tu nombre y una mejora de seguridad que propondrias -->
- Instructor: _nombre_
