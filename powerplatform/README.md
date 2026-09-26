# Power Platform: versionado y seguridad de RegistroSolicitudes

La app, la tabla de Dataverse y el flujo de Power Automate van dentro de una solucion. El codigo desempaquetado vive en Git; lo desplegado lleva numero de version.

## Exportar al repo

```bash
pac auth create --environment https://<tu-org>.crm.dynamics.com
pac solution export --name RegistroSolicitudes --path ./RegistroSolicitudes.zip --managed false
pac solution unpack --zipfile ./RegistroSolicitudes.zip --folder ./powerplatform/src/RegistroSolicitudes --packagetype Unmanaged
```

En la carpeta desempaquetada: el flujo es JSON en `Workflows/` y la app en `CanvasApps/`. Unmanaged es Dev (editable). Managed es Test/Prod (bloqueada). El numero de version esta en `Other/Solution.xml`.

## Rollback

Power Platform no permite importar una version menor sobre una mayor.

```bash
git checkout <tag> -- powerplatform/
# Subir la version en powerplatform/src/RegistroSolicitudes/Other/Solution.xml
# por ejemplo 1.0.2.0 -> 1.0.3.0
pac solution pack --zipfile out/RegistroSolicitudes_managed.zip --folder powerplatform/src/RegistroSolicitudes --packagetype Managed
pac solution import --path out/RegistroSolicitudes_managed.zip
```

Probar desde la app y revisar el run history del flujo.

## Credenciales y datos

- Variables de entorno de la solucion: URL del webhook de n8n (Text) y clave API. La clave va en el encabezado `X-API-Key`. Lo ideal es tipo Secret enlazado a Azure Key Vault.
- Connection references: se crean al agregar el flujo a la solucion, para no amarrarlo a una cuenta personal.
- En el flujo, Secure inputs y Secure outputs en el trigger y en la accion HTTP.
- En la app, casilla de consentimiento sin premarcar. El boton Enviar queda deshabilitado mientras no este marcada.
- Compartir el flujo como run-only user. Las politicas DLP del admin center definen que conectores pueden combinarse.
