// Normaliza los workflows exportados por el CLI de n8n para que Git muestre solo cambios reales.
// - Nombra cada archivo por el titulo del workflow (en vez del id)
// - Conserva solo los campos necesarios para reimportar
// - Elimina pinData (puede contener datos personales reales) y campos que cambian solos
// Uso (dentro del contenedor): node /scripts/normalizar-export.js /tmp/export
const fs = require('fs');
const path = require('path');

const dir = process.argv[2];
if (!dir) {
  console.error('Uso: node normalizar-export.js <carpeta>');
  process.exit(1);
}

const nombreSeguro = (s) =>
  s.normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^A-Za-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');

for (const archivo of fs.readdirSync(dir)) {
  if (!archivo.endsWith('.json')) continue;
  const ruta = path.join(dir, archivo);
  const wf = JSON.parse(fs.readFileSync(ruta, 'utf8'));
  const limpio = {
    id: wf.id,
    name: wf.name,
    active: false,
    nodes: wf.nodes,
    connections: wf.connections,
    settings: wf.settings || {},
    pinData: {},
    tags: [],
  };
  fs.unlinkSync(ruta);
  const destino = path.join(dir, nombreSeguro(wf.name) + '.json');
  fs.writeFileSync(destino, JSON.stringify(limpio, null, 2) + '\n');
  console.log('  ' + wf.name + ' -> ' + path.basename(destino));
}
