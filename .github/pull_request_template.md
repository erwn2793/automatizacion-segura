## Que cambia

<!-- Describe el cambio en 1-3 lineas. Plataforma(s): n8n / UiPath / Power Platform -->

## Como probarlo

<!-- Pasos o comando, por ejemplo: API_KEY=... ./scripts/probar.sh v2 -->

## Checklist de seguridad

- [ ] Sin credenciales, tokens, claves ni datos personales reales en el cambio
- [ ] Los secretos nuevos estan en Credentials (n8n), Assets (UiPath) o variables de entorno (Power Platform)
- [ ] Manejo de errores y alerta configurados
- [ ] Datos personales enmascarados en logs e historiales
- [ ] Si toma decisiones sobre personas: la revision humana esta definida
- [ ] Documentacion y `docs/runbook-rollback.md` actualizados si aplica
- [ ] Version incrementada (constante VERSION en n8n / paquete UiPath / solucion Power Platform)
