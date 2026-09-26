#!/usr/bin/env bash
# Restaura en n8n la version de un workflow guardada en un tag de Git.
# Uso: ./scripts/n8n-rollback.sh <tag> <archivo-sin-extension>
# Ej.: ./scripts/n8n-rollback.sh v1.1.0 Solicitudes_v2_segura
set -euo pipefail
export MSYS_NO_PATHCONV=1

TAG="${1:?Uso: n8n-rollback.sh <tag> <archivo-sin-extension>}"
WF="${2:?Uso: n8n-rollback.sh <tag> <archivo-sin-extension>}"
CONTAINER="${N8N_CONTAINER:-n8n}"
cd "$(dirname "$0")/.."

ARCHIVO="n8n/workflows/$WF.json"
TMP=".rollback-tmp.json"

git rev-parse -q --verify "refs/tags/$TAG" >/dev/null || { echo "No existe el tag '$TAG'. Tags disponibles:"; git tag; exit 1; }
git cat-file -e "$TAG:$ARCHIVO" 2>/dev/null || { echo "El tag '$TAG' no contiene $ARCHIVO"; exit 1; }

echo "1/3 Recuperando $ARCHIVO del tag $TAG"
git show "$TAG:$ARCHIVO" > "$TMP"

echo "2/3 Importando en n8n (mismo id: sobrescribe el workflow actual)"
docker cp "$TMP" "$CONTAINER:/tmp/rollback.json"
docker exec -u node "$CONTAINER" n8n import:workflow --input=/tmp/rollback.json
rm -f "$TMP"

echo "3/3 Listo."
echo
echo "IMPORTANTE:"
echo " - El workflow queda sin publicar: publicalo (Publish en n8n 2.x, Active en 1.x) y pruebalo."
echo " - Deja constancia en Git y en el registro del runbook:"
echo "     git checkout $TAG -- $ARCHIVO"
echo "     git commit -m \"fix: rollback de $WF a $TAG\""
