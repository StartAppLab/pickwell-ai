import { validateAnalysis, PROMPT_VERSION } from './analysis_validation.mjs';
// Candidate reads and publication are server-only. Never accept this payload from Flutter.
export async function publishAnalysis(rpc,identity,settle) {
 const handoff=await rpc('pickwell_read_analysis_candidate',identity);
 if(!handoff)return rpc('pickwell_analysis_reply',identity);
 let validated;
 try {
  const candidate=handoff.candidate;
  if(handoff.prompt_version!==PROMPT_VERSION||!candidate.validation?.provenance?.validated_at)throw Error();
  const {validation,...raw}=candidate;
  validated=validateAnalysis(raw,{model:handoff.model_version,now:validation.provenance.validated_at});
  if(validated.status==='needs_retake')return settle('retake',null,validated.retake.length===1?validated.retake[0]:'both',validated.reason_details);
  // Compare JSON semantically: PostgreSQL JSONB need not preserve object key order.
  const stable=v=>Array.isArray(v)?v.map(stable):v&&typeof v==='object'?
   Object.fromEntries(Object.keys(v).sort().map(k=>[k,stable(v[k])])):v;
  if(JSON.stringify(stable(validated))!==JSON.stringify(stable(validation)))throw Error();
 } catch { return settle('failed','invalid_model_output'); }
 return rpc('pickwell_publish_analysis',{...identity,p_validated:validated});
}
