import { TRUST_POLICY_VERSION } from './analysis_validation.mjs';
export async function publicationReview(rpc,identity){
 const result=await rpc('pickwell_publication_gate',identity);
 if(!result||!['approved','review_required','already_exists','processing','analysis_failed','review_cancelled'].includes(result.status))throw Error('review_unavailable');
 if(result.status==='approved'&&(!/^[0-9a-f-]{36}$/i.test(result.review_id??'')||
  !/^\d{14}$/.test(result.barcode??'')||! /^[0-9a-f]{64}$/.test(result.input_digest??'')||
  !/^[0-9a-f]{64}$/.test(result.candidate_digest??'')||result.policy_version!==TRUST_POLICY_VERSION))throw Error('invalid_review_binding');
 return result;
}
