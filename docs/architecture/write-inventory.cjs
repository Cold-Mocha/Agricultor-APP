const fs = require('node:fs');
const cp = require('node:child_process');
const path = require('node:path');
const manifest = JSON.parse(fs.readFileSync('docs/architecture/migration-manifest.json','utf8'));
const skip = new Set(['.dart_tool','.migration-cache','build','.gradle','.kotlin','.temp','.branches']);
function walk(dir) {
  return fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>skip.has(e.name)?[]:e.isDirectory()?walk(`${dir}/${e.name}`):[`${dir}/${e.name}`]);
}
const git = args => cp.execFileSync('git',['-c',`safe.directory=${process.cwd().replaceAll('\\','/')}`,...args],{encoding:'utf8'}).trim().split('\n').filter(Boolean);
const native = git(['ls-files','android']).map(from=>({from,to:`frontend/${from}`}));
const moves = [...manifest,...native];
const targets = new Set(moves.map(e=>e.to));
const newFiles = [...walk('frontend/lib'),...walk('backend/lib'),...walk('frontend/test'),...walk('backend/test')].filter(f=>!targets.has(f));
const config = ['backend/pubspec.yaml','backend/pubspec.lock','backend/analysis_options.yaml','backend/README.md','frontend/README.md','docs/architecture/frontend-backend-boundary.md','docs/architecture/migration-report.md','docs/architecture/migration-manifest.json','docs/architecture/migration-files.md','docs/architecture/verify-migration.cjs','docs/architecture/write-inventory.cjs'];
let output = '# Inventario físico de la migración\n\n';
output += `Se movieron ${manifest.length} archivos inventariados y el directorio Android completo (${native.length} archivos nativos versionados). Los hashes iniciales están en [migration-manifest.json](./migration-manifest.json). Se conservaron archivos locales ignorados.\n\n`;
output += '## Archivos movidos\n\n| Origen | Destino final |\n|---|---|\n'+moves.map(e=>`| \`${e.from}\` | \`${e.to}\` |`).join('\n')+'\n\n';
output += '## Archivos nuevos de código y pruebas\n\n'+newFiles.map(f=>`- \`${f}\``).join('\n')+'\n\n';
output += '## Configuración y documentación nuevas\n\n'+config.map(f=>`- \`${f}\``).join('\n')+'\n\n';
output += '## Retirada de ubicaciones obsoletas\n\nNo se borraron implementaciones: los originales se movieron. Se eliminaron 188 directorios comprobados vacíos, incluyendo `lib/`, `test/`, `integration_test/`, `assets/`, `drift_schemas/`, `supabase/` y la anidación `controllers/controllers/`. El detalle está en [removed-empty-directories.json](./validation/removed-empty-directories.json). Las caches de la raíz se conservaron en `frontend/.migration-cache/` (ignoradas, sin uso productivo). Los scripts temporales de ejecución de esta migración se retiraron al concluir.\n';
fs.writeFileSync('docs/architecture/migration-files.md',output);
console.log({inventoriedMoves:manifest.length,trackedAndroidMoves:native.length,newCodeAndTestFiles:newFiles.length});
