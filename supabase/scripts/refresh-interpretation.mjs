// Authenticated operator CLI, never imported into Edge/mobile. No provider call.
// Dry run by default; --apply writes one immutable compare-and-swap revision.
import {mkdtempSync,writeFileSync,rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {spawnSync} from 'node:child_process';
import {normalizeBarcode} from '../functions/_shared/get_product.mjs';
import {refreshInterpretationRecord} from '../functions/_shared/interpretation.mjs';
const args=process.argv.slice(2),arg=name=>args[args.indexOf(name)+1];
const project=arg('--project-ref'),barcode=normalizeBarcode(arg('--barcode')??'');
if(!args.includes('--project-ref')||!/^[a-z0-9]{20}$/.test(project)||!args.includes('--barcode'))throw Error('Explicit project and valid barcode required');
const folder=mkdtempSync(join(tmpdir(),'pickwell-interpretation-'));
const literal=value=>value===null?'null':"'"+String(value).replaceAll("'","''")+"'";
try{
 const query=sql=>{
  const path=join(folder,'query.sql');writeFileSync(path,sql,{mode:0o600});
  const r=spawnSync('npx',['--yes','supabase@2.122.0','db','query','--linked','--project-ref',project,'--file',path],{encoding:'utf8',timeout:30000,maxBuffer:1048576});
  if(r.status!==0)throw Error('Operator SQL failed');
  return JSON.parse(r.stdout).rows;
 };
 const product=query('select * from public.published_products where barcode='+literal(barcode)+';')[0];
 if(!product)throw Error('Published product not found');
 const payload=refreshInterpretationRecord(product);
 if(!args.includes('--apply')){
  console.log(JSON.stringify({status:'dry_run',barcode,analysis_id:product.analysis_id,version:payload.provenance.interpretation_version,
   explanations:payload.explanations.length,summary:payload.summary,missing_information:payload.missing_information}));
 }else{
  const sql='select public.pickwell_refresh_interpretation('+literal(product.id)+'::uuid,'+literal(product.analysis_id)+'::uuid,'+
   literal(product.provenance?.interpretation_version??null)+','+literal(JSON.stringify(payload))+'::jsonb) as result;';
  console.log(JSON.stringify(query(sql)[0].result));
 }
}catch{
 console.error('Interpretation refresh failed. Check operator project access, barcode, and current revision. No credentials or database error payload printed.');process.exitCode=1;
}finally{rmSync(folder,{recursive:true,force:true});}
