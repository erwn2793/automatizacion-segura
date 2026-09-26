Resumen y agenda
En 2 horas se muestra el proyecto de los módulos 1 y 2 "llevado a producción": versionado en Git con rollback probado (módulo 3) y protegido, conforme a la ley y auditable (módulo 4). Todo llega preconstruido en el paquete automatizacion-segura.zip. En clase se hacen demos cortas y el alumno replica los pasos después con este manual.
Supuesto: el proyecto base es Power Apps → Dataverse → Power Automate → webhook de n8n → n8n inicia el robot de UiPath vía la API de Orchestrator. Si el tuyo difiere, cambian los nombres pero no los pasos.
Probado en n8n 2.40.7: el webhook responde 202, 400 y 403 según el caso, el hash del DNI coincide con SHA-256(sal + DNI), los enlaces de aprobar y rechazar reanudan el flujo, la alerta de errores llega por correo, gitleaks detecta el secreto del v1 y el export tras importar no genera cambios espurios. Lo que depende de tus cuentas (UiPath, Google Sheets, Power Platform) se probó con servicios simulados.
Minuto
Bloque
Formato
Sección del manual
0–10
Contexto: qué le falta al proyecto básico para producción
Explicación
Arquitectura
10–25
Repo, ramas, PR y tags
Demo en vivo
M3 parte A
25–35
Versionado y rollback en n8n
Demo en vivo
M3 parte B
35–45
Versionado y rollback en UiPath y Power Platform
Demo con material preparado
M3 parte C
45–60
Fork, cambio y PR
Práctica del alumno
Práctica
60–75
Credenciales y accesos: antes y después
Demo comparativa
M4 parte A
75–95
Protección de datos y cumplimiento
Demo + checklist
M4 parte B
95–110
Aprobación humana y bitácora de auditoría
Demo en vivo
M4 parte C
110–120
Preguntas y entrega del manual
Cierre
Guion
Checklist del instructor (un día antes):
[ ] Repo creado en GitHub desde el paquete, con rama main protegida y tags v1.0.0 y v1.1.0
[ ] n8n corriendo con docker compose up -d y los 3 workflows importados y con credenciales asignadas
[ ] Workflow v2 probado de punta a punta con tests/solicitud-ejemplo.json
[ ] UiPath: proyecto con Git y dos paquetes publicados en Orchestrator (1.0.1 correcto, 1.0.2 con error)
[ ] Power Platform: solución exportada y desempaquetada en powerplatform/src/
[ ] Hoja "Bitácora auditoría" con algunas ejecuciones registradas
[ ] Enlace del repo listo para que los alumnos hagan fork
Arquitectura: antes y después
El flujo de negocio no cambia; cambia cómo se construye, se protege y se controla. Mostrar las dos versiones lado a lado es la forma más rápida de explicar ambos módulos.
Power Apps ──► Dataverse ──► Power Automate ──► n8n (webhook) ──► API Orchestrator ──► Robot UiPath
                                                      │
                                                      └──► Bitácora de auditoría
Aspecto
v1 básica (módulos 1-2)
v2 segura (módulos 3-4)
Código fuente
Solo dentro de cada plataforma
Repo GitHub con ramas, PRs y tags
Rollback
Rehacer a mano
Runbook: reimportar JSON, versión anterior del paquete, solución con versión mayor
Webhook de n8n
Abierto, sin autenticación
Header Auth con clave X-API-Key
Secreto de UiPath
client_secret escrito en el nodo HTTP
Credencial OAuth2 de n8n, cifrada
URL y clave en Power Automate
Escritas en la acción HTTP
Variables de entorno de la solución
DNI
Viaja y se guarda completo en historiales
Validado, con hash para auditoría y enmascarado; ejecuciones exitosas no se guardan
Consentimiento
No se pide
Casilla obligatoria en la app, validada en n8n
Decisiones
Todo automático
Solicitudes de tipo "Reembolso" esperan aprobación humana
Errores
Nadie se entera
Workflow de errores que envía correo
Auditoría
Ninguna
Bitácora común: fecha, ejecución, versión, resultado, dni_hash, aprobador
Contenido del paquete automatizacion-segura.zip:
Ruta
Para qué sirve
README.md
Ficha del bot e instrucciones de arranque
docker-compose.yml, .env.example
n8n local con cifrado, poda de ejecuciones y variables del curso
n8n/workflows/Solicitudes_v1_insegura.json
Versión básica, para mostrar el "antes"
n8n/workflows/Solicitudes_v2_segura.json
Versión segura, para el "después"
n8n/workflows/Manejo_de_errores.json
Error Trigger con aviso por correo
scripts/n8n-export.sh, scripts/n8n-rollback.sh
Exportar a Git y restaurar una versión
uipath/README.md, powerplatform/README.md
Pasos de versionado y seguridad en cada plataforma
docs/runbook-rollback.md
Procedimiento de rollback de las 3 plataformas
docs/cumplimiento.md
Ficha GDPR / Ley 29733 prellenada
docs/bitacora-auditoria.csv
Encabezados de la bitácora para Google Sheets o Power BI
tests/solicitud-ejemplo.json
Datos de prueba (ficticios)
.gitignore, .github/pull_request_template.md
Protecciones del repo
Módulo 3 · Parte A: repositorio, ramas, PR y tags (15 min)
Mensaje clave: un bot sin control de versiones no se puede revisar, auditar ni revertir. Git guarda quién cambió qué, cuándo y por qué, y GitHub añade la revisión antes de llegar a producción.
Modelo de ramas del curso: main = producción (protegida), develop = pruebas, feature/<tema> para cambios y hotfix/<tema> para urgencias. Mensajes con Conventional Commits: feat:, fix:, docs:, chore:.
Preparación (instructor, antes de clase)
1. Descomprimir el paquete y crear el repo:
cd automatizacion-segura
git init -b main
git add .
git commit -m "chore: estructura inicial del proyecto"
git remote add origin https://github.com/<usuario>/automatizacion-segura.git
git push -u origin main
git tag v1.0.0 && git push origin v1.0.0
2. En GitHub → Settings → Branches → Add branch ruleset (o Add rule) para main: exigir pull request y 1 aprobación.
3. Crear develop: git checkout -b develop && git push -u origin develop.
Demo en vivo
1. Crear rama: git checkout -b feature/mensaje-respuesta develop.
2. Hacer un cambio visible, por ejemplo el texto de respuesta del webhook en n8n (ver parte B para exportarlo).
3. git status → git diff → git add . → git commit -m "feat: nuevo mensaje de confirmación" → git push -u origin feature/mensaje-respuesta.
4. En GitHub, abrir el PR hacia develop. Se carga la plantilla con el checklist de seguridad; recorrerla en voz alta.
5. Mostrar la pestaña Files changed: el JSON del workflow se revisa como cualquier código.
6. Aprobar (con una segunda cuenta o un alumno como revisor) y fusionar.
7. PR de develop → main, fusionar y crear el tag: git checkout main && git pull && git tag v1.1.0 && git push origin v1.1.0.
Qué deben llevarse los alumnos: una rama por cambio, nunca commit directo a main, PR con revisión y un tag por cada versión que llega a producción.
Módulo 3 · Parte B: versionado y rollback en n8n (10 min)
Un workflow de n8n es un JSON: versionarlo es exportarlo al repo, y hacer rollback es reimportar el JSON de un tag anterior. La edición Community no trae integración Git, así que el paquete incluye dos scripts que lo resuelven.
Preparación
1. Copiar .env.example a .env y completar los valores (la clave de cifrado se genera una sola vez: openssl rand -hex 32).
2. Levantar n8n: docker compose up -d y crear la cuenta de owner en http://localhost:5678.
3. Importar los 3 workflows: docker compose exec -u node n8n n8n import:workflow --separate --input=/workflows.
4. Abrir cada workflow y asignar las credenciales (se explican en el módulo 4 parte A).
Demo en vivo: exportar a Git
1. En el editor, cambiar el texto del nodo "Responder 202" y guardar.
2. Ejecutar ./scripts/n8n-export.sh. El script exporta todos los workflows, los nombra por su título y quita campos volátiles (updatedAt, versionId) para que el diff muestre solo cambios reales.
3. git diff n8n/workflows/ muestra exactamente la línea cambiada.
4. Commit, push y PR como en la parte A.
Demo en vivo: rollback
1. Romper el workflow a propósito: borrar la conexión del nodo "Validar datos" y guardar.
2. Probar con curl (ver guion) y mostrar el error.
3. Restaurar la última versión buena:
./scripts/n8n-rollback.sh v1.1.0 Solicitudes_v2_segura
4. El script recupera el archivo del tag, lo importa (mismo id, así que sobrescribe) y avisa que hay que reactivarlo. Publicarlo (Publish en n8n 2.x, Active en 1.x) y volver a probar.
5. Mencionar la alternativa sin Git: el historial de versiones del editor de n8n, con retención limitada según el plan.
En Windows los scripts funcionan en Git Bash (se instala con Git).
Módulo 3 · Parte C: UiPath y Power Platform (10 min)
En ambas plataformas hay dos niveles: el código fuente va a Git y lo desplegado lleva número de versión (paquete en Orchestrator, solución en Power Platform). El rollback rápido se hace en la plataforma; Git sirve para reconstruir y auditar. Esta parte se muestra con material ya preparado.
UiPath (5 min)
Preparación:
1. Guardar el proyecto del robot (por ejemplo ProcesarSolicitud) en uipath/ProcesarSolicitud/ dentro del repo.
2. En Studio, barra inferior → Add to Source Control → Git Init (Studio detecta que la carpeta ya es un repo). Hacer Commit and Push.
3. Publish a Orchestrator la versión 1.0.1 (correcta). Luego publicar la 1.0.2 con un error intencional (por ejemplo, una actividad Throw al inicio). En Release Notes, anotar el commit.
4. Dejar el proceso apuntando a la 1.0.2.
Demo:
1. Mostrar en Studio el selector de ramas y el historial (Show History); clic derecho en Main.xaml → Compare with Latest para ver el diff.
2. En Orchestrator, ejecutar el proceso: falla.
3. Rollback: editar el proceso y elegir el paquete 1.0.1 (o la acción Rollback del proceso). Ejecutar de nuevo: funciona.
4. Mostrar Design → Analyze Project (Workflow Analyzer) como revisión de código automática antes de publicar.
Power Platform (5 min)
Preparación: la app, la tabla de Dataverse y el flujo deben estar dentro de una solución (RegistroSolicitudes). Si se crearon fuera, agregarlos con Add existing.
pac auth create --environment https://<tu-org>.crm.dynamics.com
pac solution export --name RegistroSolicitudes --path ./RegistroSolicitudes.zip --managed false
pac solution export --name RegistroSolicitudes --path ./RegistroSolicitudes_managed.zip --managed true
pac solution unpack --zipfile ./RegistroSolicitudes.zip --folder ./powerplatform/src/RegistroSolicitudes --packagetype Both
Demo:
1. Mostrar en VS Code la carpeta desempaquetada: el flujo es un JSON en Workflows/, la app en CanvasApps/.
2. Explicar unmanaged (Dev, editable) vs. managed (Test/Prod, bloqueada) y el número de versión en Settings de la solución.
3. Rollback: Power Platform no permite importar una versión menor sobre una mayor. Se recupera la versión anterior del repo (git checkout v1.0.0 -- powerplatform/), se sube el número de versión, se empaqueta (pac solution pack) y se importa. En el módulo 5 esto se automatiza con GitHub Actions.
Práctica del alumno: fork, cambio y PR (15 min)
Es el único momento en que el alumno trabaja solo, y basta con Git y una cuenta de GitHub: no necesita n8n ni UiPath instalados. El objetivo es que viva el flujo completo una vez.
1. Entrar al repo del instructor y pulsar Fork.
2. Clonar su fork: git clone https://github.com/<su-usuario>/automatizacion-segura.git y cd automatizacion-segura.
3. Crear rama: git checkout -b feature/<su-nombre>.
4. Editar README.md: en la sección "Equipo", agregar su nombre y una mejora de seguridad que propondría para el bot.
5. git add README.md → git commit -m "docs: agrega a <nombre> al equipo" → git push -u origin feature/<su-nombre>.
6. En GitHub, abrir el PR hacia el repo del instructor (Contribute → Open pull request) y completar el checklist de la plantilla.
7. Revisar el PR de un compañero y dejar un comentario.
Si alguien no tiene Git instalado: puede hacer todo desde el navegador (editar el archivo en GitHub con el ícono del lápiz, elegir "Create a new branch" y proponer el cambio).
Cierre del bloque (instructor): fusionar 2 o 3 PRs en pantalla. Si dos alumnos editaron la misma línea, resolver el conflicto en vivo; es la mejor demostración de merge.
Módulo 4 · Parte A: credenciales y control de acceso (15 min)
Regla del bloque: ningún secreto vive en el flujo ni en el repo, y cada persona o robot tiene solo el acceso que necesita. La demo empieza abriendo el v1 para mostrar el problema.
Demo "antes": el secreto expuesto (3 min)
1. Abrir Solicitudes_v1_insegura.json en GitHub: el client_secret de UiPath está en texto plano y cualquiera con acceso al repo lo ve (es un valor ficticio para la demo).
2. Ejecutar gitleaks detect --source . -v (o docker run -v "$PWD:/repo" zricethezav/gitleaks detect --source /repo -v) y mostrar que lo detecta.
3. Mostrar que el webhook v1 acepta cualquier petición sin clave.
n8n: cómo se configuró el v2
1. Credencial del webhook: Credentials → New → Header Auth. Name: X-API-Key, Value: una clave larga generada (openssl rand -hex 24). Asignarla al nodo Webhook (Authentication = Header Auth).
2. Credencial de UiPath: Credentials → New → OAuth2 API:
    ◦ Grant Type: Client Credentials
    ◦ Access Token URL: https://cloud.uipath.com/identity_/connect/token
    ◦ Client ID y Client Secret: los de la External Application de UiPath
    ◦ Scope: OR.Jobs OR.Execution
    ◦ Authentication: Send credentials in body
3. Asignarla al nodo "Iniciar robot UiPath" (Authentication = Generic Credential Type → OAuth2 API). n8n obtiene y renueva el token solo.
4. Los datos no secretos (organización, tenant, carpeta, release key) van en el .env y el workflow los lee con $env.
5. Las credenciales quedan cifradas con N8N_ENCRYPTION_KEY y no se exportan con el workflow: el JSON solo guarda su nombre e id.
UiPath
1. External Application (para que n8n lance el robot): Automation Cloud → Admin → External Applications → Add → Confidential application → scopes de Orchestrator OR.Jobs y OR.Execution. Guardar Client ID y Secret en la credencial de n8n, nunca en el repo.
2. Secretos del robot: Orchestrator → carpeta → Assets → Add → tipo Credential (por ejemplo, SistemaDestino_Login). En el robot, usar Get Credential; la contraseña llega como SecureString.
3. Accesos: crear un rol "Operador de solicitudes" en la carpeta con permisos de ver y ejecutar procesos y ver logs, sin editar assets ni paquetes.
Power Platform
1. En la solución, crear dos variables de entorno: URL webhook n8n (Text) y Clave API n8n. Para la clave, lo ideal es el tipo Secret enlazado a Azure Key Vault; sin suscripción de Azure, usar Text y explicar la diferencia.
2. En el flujo, reemplazar la URL y la clave escritas en la acción HTTP por esas variables; la clave va en el encabezado X-API-Key.
3. Usar connection references (se crean al agregar el flujo a la solución) para no amarrar el flujo a una cuenta personal.
4. Mencionar las políticas DLP del admin center: definen qué conectores pueden combinarse (por ejemplo, bloquear redes sociales en este entorno).
5. Compartir el flujo con otros como run-only user.
Módulo 4 · Parte B: protección de datos y cumplimiento (20 min)
La mayoría de fugas en automatización no vienen de romper un cifrado, sino de un historial o un log que guardó el DNI completo. El v2 pide consentimiento, valida, guarda solo un hash para auditoría y no conserva ejecuciones exitosas.
Demo "antes y después" (8 min)
1. Enviar la misma solicitud a v1 y v2 (ver guion).
2. En n8n → Executions: v1 muestra el DNI, correo y teléfono completos; v2 no guarda la ejecución exitosa.
3. Enviar a v2 una solicitud sin consentimiento o con un DNI de 7 dígitos: responde 400 con los errores.
Cómo se construyó en n8n
1. Nodo "Validar datos" (Code): verifica DNI de 8 dígitos, correo válido y consentimiento = true; genera dni_mascara (por ejemplo 45****78) y un correlation_id a partir del ID de ejecución.
2. Nodo "Hash DNI" (Crypto, SHA256): calcula dni_hash sobre HASH_SALT + DNI. La sal vive en el .env, así el hash no se puede revertir probando los 100 millones de DNI posibles sin conocerla.
3. Settings del workflow: Save successful production executions = Do not save; Save manual executions = No.
4. .env: EXECUTIONS_DATA_PRUNE=true y EXECUTIONS_DATA_MAX_AGE=168 borran las ejecuciones fallidas a los 7 días.
5. Transporte: en producción n8n va detrás de HTTPS (proxy inverso como Caddy o Traefik); en local se explica y no se monta.
Power Platform
1. En la tabla de Dataverse, agregar la columna Consentimiento (Sí/No, obligatoria).
2. En la app, agregar un control Toggle o Checkbox con el texto del consentimiento y dejar el botón Enviar deshabilitado mientras no esté marcado (DisplayMode: If(chkConsentimiento.Value, DisplayMode.Edit, DisplayMode.Disabled)).
3. En el flujo, activar Secure inputs y Secure outputs (Settings de la acción) en el trigger y en la acción HTTP. Mostrar en el run history que el contenido ya no aparece.
UiPath
1. Registrar en Log Message solo dni_mascara y correlation_id, nunca el DNI completo.
2. Marcar la casilla Private en las actividades que manejan el DNI para que Orchestrator no registre sus valores.
Cumplimiento: recorrer docs/cumplimiento.md (7 min)
La ficha ya está llena para el caso. Recorrer en pantalla las decisiones de diseño que la norma exige:
Obligación
GDPR
Ley 29733 + D.S. 016-2024-JUS
Dónde se ve en el proyecto
Consentimiento expreso
Art. 6 y 7
Expreso y demostrable, sin casillas premarcadas
Casilla en la app, validada en n8n
Minimización
Art. 5
Proporcionalidad
Solo los campos necesarios
Seguridad y privacidad desde el diseño
Art. 25 y 32
Medidas de seguridad y responsabilidad proactiva
Credenciales, hash, retención
Registro del tratamiento
Art. 30
Inscripción del banco de datos ante la ANPD
Ficha de cumplimiento.md
Decisiones automatizadas
Art. 22
Derecho a no ser objeto de decisiones solo automatizadas
Aprobación humana (parte C)
Incidentes
Aviso a la autoridad en 72 h
Aviso a la ANPD en máximo 48 h
Runbook y responsable nombrado
El reglamento peruano está vigente desde el 30 de marzo de 2025 (MINJUSDH, TYTL). Aclarar a los alumnos que esto no reemplaza la asesoría legal de su organización.
Módulo 4 · Parte C: ética y auditoría (15 min)
Un flujo que decide sobre personas necesita un responsable con nombre, una persona que revise las decisiones con impacto y un registro que permita reconstruir qué pasó. En el v2, las solicitudes de tipo "Reembolso" esperan aprobación humana y toda ejecución deja una fila en la bitácora.
Ética en 5 minutos (explicación)
• Sesgo: si un paso de IA o una regla prioriza solicitudes, puede castigar por nombre, distrito o edad sin que nadie lo pida. Se prueba enviando pares de solicitudes idénticas que solo cambian ese dato.
• Transparencia: el usuario debe saber que lo atiende un proceso automático y cómo llegar a una persona. La respuesta del v2 lo indica.
• Responsabilidad: el README.md tiene la ficha del bot con su dueño; "lo decidió el sistema" no es una respuesta aceptable.
Demo: aprobación humana en n8n (5 min)
1. Enviar una solicitud de tipo "Reembolso".
2. Llega un correo al aprobador con dos enlaces: Aprobar y Rechazar (usan $execution.resumeUrl).
3. En Executions, la ejecución queda en espera (nodo Wait).
4. Clic en Aprobar: la ejecución continúa, lanza el robot y registra quién aprobó.
Cómo se construyó: IF "¿Requiere aprobación?" → Send Email con los enlaces → Wait (Resume: On Webhook Call, método GET, límite de 24 horas) → IF "¿Aprobada?" leyendo $json.query.decision.
Equivalentes: en UiPath, Action Center (Create Form Task + Wait for Form Task and Resume); en Power Automate, el conector Approvals ("Start and wait for an approval").
Demo: bitácora de auditoría (5 min)
1. Abrir la hoja "Bitácora auditoría" (columnas en docs/bitacora-auditoria.csv): fecha_utc, plataforma, workflow, version, id_ejecucion, correlation_id, tipo, resultado, dni_hash, aprobado_por.
2. Mostrar que no hay DNI ni nombre: solo el hash. Para buscar a una persona se calcula el hash de su DNI con la misma sal.
3. La columna version sale de una constante del nodo "Validar datos" que se actualiza en cada release; así cada fila se vincula con un tag y un commit de Git.
4. Mencionar la auditoría nativa: Orchestrator → Audit en UiPath (quién cambió paquetes, assets o procesos) y la auditoría de Dataverse y Microsoft Purview en Power Platform.
Ejercicio de cierre (oral, 2 min): "Una persona reclama que su reembolso fue rechazado el martes". Con la bitácora: hash de su DNI → fila → versión → tag → PR → quién lo revisó, y aprobado_por → quién rechazó. Eso es trazabilidad.
Nota: en la edición Community de n8n, restringir la edición de la hoja de Google Sheets a una sola cuenta; en el módulo 5 esta bitácora se conecta al dashboard de monitoreo.
Guion del día y problemas frecuentes
Comandos en el orden de la clase, todos desde la raíz del repo. API_KEY es la clave del Header Auth de n8n.
Comandos de la demo
# M3 · A: rama, cambio, PR y tag
git checkout -b feature/mensaje-respuesta develop
./scripts/n8n-export.sh
git diff n8n/workflows/
git commit -am "feat: nuevo mensaje de confirmación" && git push -u origin feature/mensaje-respuesta

# M3 · B: rollback de n8n
./scripts/n8n-rollback.sh v1.1.0 Solicitudes_v2_segura

# M4 · A: el antes (secreto expuesto y webhook abierto)
docker run --rm -v "$PWD:/repo" zricethezav/gitleaks detect --source /repo --no-git -v
./scripts/probar.sh v1
./scripts/probar.sh sinclave        # v2 sin clave: HTTP 403

# M4 · B: validación y protección de datos
API_KEY=<clave> ./scripts/probar.sh v2          # 202
API_KEY=<clave> ./scripts/probar.sh invalida    # 400 con errores

# M4 · C: aprobación humana y bitácora
API_KEY=<clave> ./scripts/probar.sh reembolso   # llega el correo de aprobación
Problemas frecuentes
Síntoma
Causa probable
Solución
El webhook responde 404
Workflow inactivo, o se usa /webhook-test/ sin ejecutar en el editor
Publicar el workflow (botón Publish en n8n 2.x) y usar /webhook/
El webhook v2 responde 403
Falta el encabezado X-API-Key o no coincide
Revisar la credencial Header Auth
El nodo "Hash DNI" da error de acceso a $env
N8N_BLOCK_ENV_ACCESS_IN_NODE está en true
Usar el docker-compose.yml del paquete (lo deja en false)
"Iniciar robot UiPath" responde 401
Credencial OAuth2 mal configurada o sin scopes
Revisar Client ID/Secret y scopes OR.Jobs OR.Execution
Responde 400 "Folder does not exist" o similar
UIPATH_FOLDER_ID o UIPATH_RELEASE_KEY incorrectos
Obtenerlos como indica uipath/README.md
La bitácora no recibe filas
La hoja no tiene la pestaña Bitacora con los encabezados
Importar docs/bitacora-auditoria.csv en una pestaña llamada Bitacora
Después del rollback el webhook no responde
El import deja el workflow desactivado
Activarlo (o publicarlo) en el editor
Los enlaces Aprobar y Rechazar del correo no abren
WEBHOOK_URL apunta a localhost y el aprobador abre el correo desde otro equipo
Poner la URL pública de n8n en WEBHOOK_URL del .env y reiniciar
Los scripts fallan en Windows
Se ejecutan en PowerShell
Usar Git Bash
Después de la sesión
Entregar a los alumnos el enlace al repo y este manual. En la próxima sesión (módulos 5 y 6), el mismo repo recibe los pipelines de GitHub Actions y la bitácora alimenta el dashboard de monitoreo.