import {test} from 'node:test';
import assert from 'node:assert/strict';
import {sanitizeRetakeDetails} from '../functions/_shared/retake_details.mjs';
test('closed retake projection excludes arbitrary fields/text and unrelated photos',()=>{
 const result=sanitizeRetakeDetails([
  {photo:'nutrition',source:'model',code:'cropped_label',field:'fat',raw:'PRIVATE data:image; bearer secret'},
  {photo:'ingredients',source:'model',code:'unreadable_text',field:'ingredients_list'},
  {photo:'nutrition',source:'provider-key',code:'unreadable_text',field:'fat'},
 ],['nutrition']);
 assert.deepEqual(result,[{photo:'nutrition',source:'model',code:'cropped_label',field:'fat'}]);
 assert.ok(!JSON.stringify(result).includes('PRIVATE'));
});
test('legacy, invalid, duplicate and excessive reason payloads stay bounded with one reason per target',()=>{
 const d={photo:'nutrition',source:'validation',code:'numeric_source',field:'fat'};
 const result=sanitizeRetakeDetails(Array(100).fill(d),['nutrition','ingredients']);
 assert.equal(result.length,2);assert.equal(result[1].code,'reason_unavailable');
 assert.deepEqual(sanitizeRetakeDetails([{photo:'nutrition',source:'model',code:'invented',field:'other'}],['nutrition']),
  [{photo:'nutrition',source:'legacy',code:'reason_unavailable',field:'other'}]);
});
