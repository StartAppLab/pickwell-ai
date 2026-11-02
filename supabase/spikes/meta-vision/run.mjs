// Operator-only live integration runner. No Meta key is needed on this client.
import { readFile, open } from 'node:fs/promises';
import { resolve, dirname } from 'node:path';
import { validateImage, MAX_IMAGE } from './core.mjs';

async function main() {
  const { SPIKE_URL, SPIKE_OPERATOR_TOKEN, SPIKE_USER_JWT, SPIKE_PUBLISHABLE_KEY } = process.env;
  if (!SPIKE_URL || !SPIKE_OPERATOR_TOKEN || !SPIKE_USER_JWT || !SPIKE_PUBLISHABLE_KEY) {
    throw new Error('HARD BLOCKED: missing protected spike URL, operator token, verified-user JWT or public key');
  }
  const url = new URL(SPIKE_URL);
  if (url.protocol !== 'https:' || !/^[a-z0-9-]+\.supabase\.co$/.test(url.hostname) ||
      url.username || url.password || url.search || url.hash ||
      url.pathname !== '/functions/v1/meta-vision-spike') throw new Error('Invalid spike URL');
  if (!process.argv[2]) throw new Error('HARD BLOCKED: supply a private three-case manifest');
  const file = resolve(process.argv[2]);
  const manifest = JSON.parse(await readFile(file, 'utf8'));
  const expected = ['extracted', 'extracted', 'needs_retake'];
  if (!Array.isArray(manifest.cases) || manifest.cases.length !== 3 ||
      manifest.cases.some((item, index) => item.expected_status !== expected[index])) {
    throw new Error('Manifest requires two product pairs and one unreadable case, in that order');
  }
  // Validate every image before making any remote request. Do not fetch image URLs.
  const cases = [];
  for (const item of manifest.cases) {
    const pair = [];
    for (const name of ['nutrition', 'ingredients']) {
      const bytes = await readFile(resolve(dirname(file), item[name]));
      if (bytes.length > MAX_IMAGE) throw new Error('Image exceeds spike size limit');
      const mime = bytes[0] === 0x89 ? 'image/png' : 'image/jpeg';
      const data = `data:${mime};base64,${bytes.toString('base64')}`;
      validateImage(data); pair.push(data);
    }
    if (pair[0] === pair[1]) throw new Error('Each case requires two different images');
    cases.push(pair);
  }
  if (cases[0][0] === cases[1][0] || cases[0][1] === cases[1][1]) {
    throw new Error('The first two cases must use distinct product pairs');
  }
  let passed = true;
  // Optional private evidence for manual comparison with labels; never log raw
  // provider responses or images. Refuse to overwrite an existing evidence file.
  const evidence = process.env.SPIKE_EVIDENCE_PATH
    ? await open(process.env.SPIKE_EVIDENCE_PATH, 'wx', 0o600) : null;
  try {
    for (let index = 0; index < cases.length; index++) {
      const response = await fetch(url, {
        method: 'POST', redirect: 'error', signal: AbortSignal.timeout(45000),
        headers: { Authorization: `Bearer ${SPIKE_USER_JWT}`, apikey: SPIKE_PUBLISHABLE_KEY,
          'x-spike-token': SPIKE_OPERATOR_TOKEN, 'content-type': 'application/json' },
        body: JSON.stringify({ idempotency_key: crypto.randomUUID(),
          nutrition_image: cases[index][0], ingredients_image: cases[index][1] }),
      });
      const result = await response.json();
      const matches = response.ok && result.status === expected[index];
      passed &&= matches;
      if (evidence) await evidence.writeFile(JSON.stringify({ case: index + 1,
        http_status: response.status, result }) + '\n');
      // Print an allowlisted receipt, not raw model content, images or credentials.
      console.log(JSON.stringify({ case: index + 1, http_status: response.status, passed: matches,
        status: ['extracted', 'needs_retake'].includes(result.status) ? result.status : 'failed',
        basis: result.nutrition?.basis ?? null, nutrient_count: result.nutrition?.nutrients?.length ?? 0,
        retake: result.retake, metadata: result.metadata }));
      if (!response.ok) break; // No automatic retry or continued spending after errors.
    }
  } finally { await evidence?.close(); }
  if (!passed) process.exitCode = 1;
}

main().catch(error => {
  console.error(error.message.startsWith('HARD BLOCKED:') ? error.message :
    'Spike runner failed; check local configuration, fixtures or protected server status (details suppressed)');
  process.exitCode = 1;
});
