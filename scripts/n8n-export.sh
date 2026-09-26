#!/usr/bin/env bash
# Exporta todos los workflows de n8n a n8n/workflows/ para versionarlos con Git.
# Uso: ./scripts/n8n-export.sh        (en Windows, desde Git Bash)
set -euo pipefail
export MSYS_NO_PATHCONV=1            # evita que Git Bash en Windows altere las rutas del contenedor

CONTAINER="${N8N_CONTAINER:-n8n}"
cd "$(dirname "$0")/.."              # raiz del repositorio

echo "Exportando workflows desde el contenedor '$CONTAINER'..."
docker exec -u node "$CONTAINER" sh -c 'rm -rf /tmp/export && mkdir -p /tmp/export'
docker exec -u node "$CONTAINER" n8n export:workflow --all --separate --pretty --output=/tmp/export/ >/dev/null
docker exec -u node "$CONTAINER" node /scripts/normalizar-export.js /tmp/export

# Reemplazar el contenido de la carpeta (asi tambien se reflejan workflows borrados)
rm -f n8n/workflows/*.json
docker cp "$CONTAINER:/tmp/export/." "n8n/workflows/"

echo
echo "Cambios detectados:"
git status --short n8n/workflows/ || true
echo
echo "Siguiente paso: git diff n8n/workflows/  ->  git add  ->  git commit -m \"feat: ...\""
