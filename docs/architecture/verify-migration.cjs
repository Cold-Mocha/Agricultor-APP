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
// Supabase CLI writes `.temp` operational metadata locally; it is not a
// migrated source artifact and changes with the installed CLI version.
const stableEntries = entries.filter(e => !e.to.includes('/.temp/'));
const preserved = stableEntries.filter(e => e.to.startsWith('backend/supabase/') || e.to.startsWith('backend/drift_schemas/'));
for (const entry of preserved) assert.equal(hash(entry.to),entry.sha256,`Remote/schema content changed: ${entry.to}`);
const preservedTargets = new Set(preserved.map(e => e.to));
const retainedWorkspaceFiles = new Set(['pubspec.yaml', 'pubspec.lock']);
const relocatedIntermediateFiles = [];
for(const entry of stableEntries) {
  const target = entry.to;
  if (!retainedWorkspaceFiles.has(entry.from)) {
    assert(!fs.existsSync(entry.from), `Old source still present: ${entry.from}`);
  }
  // The original split was followed by the approved `src/`/feature-first
  // reorganization. Its manifest destinations remain historical evidence;
  // current layout is checked independently by tool/check_architecture.dart.
  if (!fs.existsSync(target)) {
    if (preservedTargets.has(target)) assert.fail(`Missing preserved file: ${target}`);
    relocatedIntermediateFiles.push(target);
    continue;
  }
}
for(const file of ['index.html','agrocampo-highfi.html']) {
  const source=fs.readFileSync(file,'utf8');
  for(const match of source.matchAll(/src="(frontend\/assets\/[^"?#]+)"/g)) assert(fs.existsSync(match[1]),`Missing prototype asset ${match[1]}`);
}
const summary = {movedFiles:entries.length,preservedSupabaseAndSchemaFiles:preserved.length,relocatedIntermediateFiles:relocatedIntermediateFiles.length,rootLibAbsent:true,localDependency:true};
fs.writeFileSync('docs/architecture/validation/migration-integrity.json',JSON.stringify(summary,null,2)+'\n');
console.log(summary);
