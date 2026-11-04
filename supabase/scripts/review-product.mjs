// Protected operator workflow. No provider calls. Approval is dry-run unless --apply.
import {readFileSync,writeFileSync,mkdirSync,chmodSync,statSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {pathToFileURL} from 'node:url';
import {spawnSync} from 'node:child_process';
import {readAnalysisInput} from '../functions/_shared/analysis_input.mjs';
export const TRUST_POLICY='trust-publication-v1';
export function reviewDecisionPlan(review,evidenceDigest,{decision,reference,basis,resolution}={}){
 if(!review||review.state!=='pending'||review.policy_version!==TRUST_POLICY||!review.candidate||
  !/^[0-9a-f-]{36}$/i.test(review.review_id??'')||!/^\d{14}$/.test(review.barcode??'')||
  !/^[0-9a-f]{64}$/.test(review.input_digest??'')||!/^[0-9a-f]{64}$/.test(review.candidate_digest??'')||
  !Number.isFinite(Date.parse(review.expires_at))||Date.parse(review.expires_at)<=Date.now())throw Error('Current pending review required');
 if(!['approve','reject'].includes(decision)||!/^[A-Za-z0-9][A-Za-z0-9._-]{7,99}$/.test(reference??'')||
  !['package_barcode_evidence','trusted_product_reference','controlled_demo_evidence'].includes(basis)||
  !['no_discrepancy','wording_variation_reviewed','conflict_unresolved'].includes(resolution))throw Error('Explicit operator decision and opaque reference required');
 if(decision==='approve'&&(evidenceDigest!==review.input_digest||resolution==='conflict_unresolved'||
  review.candidate.validation?.provenance?.cross_image_consistency==='review_required'&&resolution!=='wording_variation_reviewed'))throw Error('Review the exact evidence and resolve discrepancies before approval');
 return {p_review:review.review_id,p_barcode:review.barcode,p_input_digest:review.input_digest,p_candidate_digest:review.candidate_digest,
  p_policy_version:review.policy_version,p_decision:decision,p_review_ref:reference,p_review_basis:basis,p_resolution:resolution};
}
function privatePath(path){
 if(!path)throw Error('Ignored private file path required');const p=resolve(path);
 if(spawnSync('git',['check-ignore','--quiet','--',p]).status!==0)throw Error('Review and evidence files must be Git-ignored');return p;
}
const stable=value=>Array.isArray(value)?value.map(stable):value&&typeof value==='object'?Object.fromEntries(Object.keys(value).sort().map(k=>[k,stable(value[k])])):value;
export async function runOperatorReview(args,env=process.env,fetcher=fetch){
 const arg=name=>{const n=args.indexOf(name);return n>=0?args[n+1]:undefined;};
 if(args.includes('--help')){console.log('review-product: --list | --inspect UUID --out .secrets/review.json | --review-file FILE --decision approve|reject --ref OPAQUE_REFERENCE --basis package_barcode_evidence|trusted_product_reference|controlled_demo_evidence --resolution no_discrepancy|wording_variation_reviewed|conflict_unresolved [--evidence-manifest FILE] [--apply]. Server-only SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY required. Approval requires the three exact processed evidence files; no automatic identity verification.');return;}
 const url=new URL(env.SUPABASE_URL);if((url.protocol!=='https:'&&!['127.0.0.1','localhost'].includes(url.hostname))||url.username||url.password||url.pathname!=='/'||!env.SUPABASE_SERVICE_ROLE_KEY)throw Error('Explicit server environment required');
 const rpc=async(name,body)=>{const r=await fetcher(url.origin+'/rest/v1/rpc/'+name,{method:'POST',headers:{apikey:env.SUPABASE_SERVICE_ROLE_KEY,Authorization:`Bearer ${env.SUPABASE_SERVICE_ROLE_KEY}`,'content-type':'application/json'},body:JSON.stringify(body),redirect:'error',signal:AbortSignal.timeout(10000)});if(!r.ok)throw Error('Protected review operation failed');return r.json();};
 if(args.includes('--list')){console.log(JSON.stringify(await rpc('pickwell_inspect_product_review',{p_review:null})));return;}
 if(arg('--inspect')){
  const value=await rpc('pickwell_inspect_product_review',{p_review:arg('--inspect')});if(!value)throw Error('Review not found');
  const out=privatePath(arg('--out'));mkdirSync(dirname(out),{recursive:true});writeFileSync(out,JSON.stringify(value,null,2),{mode:0o600});chmodSync(out,0o600);console.log('Private review inspection saved. Inspect the label facts and exact package/barcode evidence before any approval.');return;
 }
 const review=JSON.parse(readFileSync(privatePath(arg('--review-file')),'utf8'));let digest=null;
 if(arg('--decision')==='approve'){
  const manifestPath=privatePath(arg('--evidence-manifest')),manifest=JSON.parse(readFileSync(manifestPath,'utf8'));
  if(manifest.barcode!==review.barcode)throw Error('Evidence barcode mismatch');
  const form=new FormData();form.set('barcode',manifest.barcode);form.set('idempotency_key',crypto.randomUUID());
  for(const photo of ['front','nutrition','ingredients']){
   const path=privatePath(resolve(dirname(manifestPath),manifest[photo])),size=statSync(path).size;
   if(size<1||size>5*1024*1024)throw Error('Bounded processed evidence required');
   form.set(photo+'_image',new Blob([readFileSync(path)]),photo);
  }
  const input=await readAnalysisInput(new Request('https://local-review.invalid',{method:'POST',body:form}));digest=input.digest;input.images=null;
 }
 const plan=reviewDecisionPlan(review,digest,{decision:arg('--decision'),reference:arg('--ref'),basis:arg('--basis'),resolution:arg('--resolution')});
 if(!args.includes('--apply')){console.log(JSON.stringify({status:'dry_run',decision:plan.p_decision,review_id:plan.p_review,barcode:plan.p_barcode,evidence_matches:arg('--decision')==='approve'}));return;}
 const current=await rpc('pickwell_inspect_product_review',{p_review:review.review_id});
 if(JSON.stringify(stable(current))!==JSON.stringify(stable(review)))throw Error('Inspection changed; inspect and review again');
 console.log(JSON.stringify(await rpc('pickwell_decide_product_review',plan)));
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
 try{await runOperatorReview(process.argv.slice(2));}catch{console.error('Review failed. Check the private inspection, exact evidence, expiry and operator server access. No credentials or database payload printed.');process.exitCode=1;}
}
