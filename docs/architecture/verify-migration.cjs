// Repeatable structural/integrity check; does not change production files.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const entries = JSON.parse(fs.readFileSync('docs/architecture/migration-manifest.json','utf8'));
const hash = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
assert(!fs.existsSync('lib'), 'Root production lib must not exist');
assert(fs.existsSync('frontend/android/app/src/main/AndroidManifest.xml'));
assert(fs.readFileSync('frontend/pubspec.yaml','utf8').includes('path: ../backend'));
const preserved = entries.filter(e => e.to.startsWith('backend/supabase/') || e.to.startsWith('backend/drift_schemas/'));
for (const entry of preserved) assert.equal(hash(entry.to),entry.sha256,`Remote/schema content changed: ${entry.to}`);
for(const entry of entries) {
  const target = entry.to;
  assert(fs.existsSync(target), `Missing migrated file: ${target}`);
  assert(!fs.existsSync(entry.from), `Old source still present: ${entry.from}`);
}
for(const file of ['index.html','agrocampo-highfi.html']) {
  const source=fs.readFileSync(file,'utf8');
  for(const match of source.matchAll(/src="(frontend\/assets\/[^"?#]+)"/g)) assert(fs.existsSync(match[1]),`Missing prototype asset ${match[1]}`);
}
const summary = {movedFiles:entries.length,preservedSupabaseAndSchemaFiles:preserved.length,rootLibAbsent:true,localDependency:true};
fs.writeFileSync('docs/architecture/validation/migration-integrity.json',JSON.stringify(summary,null,2)+'\n');
console.log(summary);
