#!/usr/bin/env bash
# Envia las solicitudes de prueba a los webhooks de n8n.
# Uso: API_KEY=<clave del webhook> ./scripts/probar.sh [v1|v2|reembolso|invalida]
set -euo pipefail
cd "$(dirname "$0")/.."

BASE="${N8N_BASE:-http://localhost:5678/webhook}"
CASO="${1:-v2}"

case "$CASO" in
  v1)
    echo "v1 (sin autenticacion):"
    curl -s -X POST "$BASE/solicitudes" -H "Content-Type: application/json" -d @tests/solicitud-ejemplo.json ;;
  v2)
    echo "v2 (con X-API-Key):"
    curl -s -X POST "$BASE/v2/solicitudes" -H "Content-Type: application/json" \
      -H "X-API-Key: ${API_KEY:?Define API_KEY con la clave del webhook}" -d @tests/solicitud-ejemplo.json ;;
  sinclave)
    echo "v2 sin clave (debe responder 403):"
    curl -s -o /dev/null -w "HTTP %{http_code}\n" -X POST "$BASE/v2/solicitudes" \
      -H "Content-Type: application/json" -d @tests/solicitud-ejemplo.json ;;
  reembolso)
    echo "v2 reembolso (espera aprobacion humana):"
    curl -s -X POST "$BASE/v2/solicitudes" -H "Content-Type: application/json" \
      -H "X-API-Key: ${API_KEY:?Define API_KEY}" -d @tests/solicitud-reembolso.json ;;
  invalida)
    echo "v2 invalida (debe responder 400):"
    curl -s -X POST "$BASE/v2/solicitudes" -H "Content-Type: application/json" \
      -H "X-API-Key: ${API_KEY:?Define API_KEY}" -d @tests/solicitud-invalida.json ;;
  *) echo "Casos: v1 | v2 | sinclave | reembolso | invalida"; exit 1 ;;
esac
echo
