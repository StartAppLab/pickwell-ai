-- SYNTHETIC DEMO ONLY: not a real package, provider output, or health endorsement.
-- Barcode is a test identifier, not a claim of GS1 assignment. Never import these
-- facts onto a real product. Only local db reset applies seeds by default.
do $$
declare
  demo_product constant uuid := 'd0000000-0000-4000-8000-000000000001';
  demo_analysis constant uuid := 'd0000000-0000-4000-8000-000000000002';
  demo_finding constant uuid := 'd0000000-0000-4000-8000-000000000003';
begin
  insert into public.products(id, barcode, name, brand, is_demo)
    values (demo_product, '2900000000018', 'DEMO — Fictional oat sample', 'Pickwell test fixture', true)
    on conflict do nothing;
  if not exists (select 1 from public.products where id = demo_product and is_demo
    and barcode = public.pickwell_normalize_barcode('2900000000018')) then
    raise warning 'Demo seed skipped: identifier already belongs to another record';
    return;
  end if;

  insert into public.product_analyses(id, product_id, nutrition, ingredients, summary,
    model_version, prompt_version, rules_version, validated_at)
  values (demo_analysis, demo_product,
    '{"raw":"SYNTHETIC DEMO, per 100 g: Energy 110 kcal; Fat 2 g; Saturated fat 0.5 g; Carbohydrate 18 g; Sugars 1 g; Fiber 3 g; Protein 4 g; Sodium 0 mg.",
      "basis":"per_100g","serving_size":null,"nutrients":[
        {"name":"Energy","value":110,"unit":"kcal","source":"Energy 110 kcal"},
        {"name":"Total fat","value":2,"unit":"g","source":"Fat 2 g"},
        {"name":"Saturated fat","value":0.5,"unit":"g","source":"Saturated fat 0.5 g"},
        {"name":"Carbohydrate","value":18,"unit":"g","source":"Carbohydrate 18 g"},
        {"name":"Sugars","value":1,"unit":"g","source":"Sugars 1 g"},
        {"name":"Fiber","value":3,"unit":"g","source":"Fiber 3 g"},
        {"name":"Protein","value":4,"unit":"g","source":"Protein 4 g"},
        {"name":"Sodium","value":0,"unit":"mg","source":"Sodium 0 mg"}]}',
    '{"raw":"Whole grain oats, water.","items":["Whole grain oats","water"],"declared_allergens":null}',
    'SYNTHETIC DEMO ONLY. Fictional data for cache-hit testing; not a real food analysis. Allergen declarations are unknown.',
    'fixture:no-provider-call', 'fixture-v1', 'demo-notice-v1', '2026-11-02T00:00:00Z')
    on conflict (id) do nothing;

  insert into public.analysis_findings(id, analysis_id, severity, title, explanation, source_details)
  select demo_finding, demo_analysis, 'yellow', 'Demonstration data',
    'This fictional fixture exercises stored results. It is not nutritional advice or a safety certification.',
    '{"rule_id":"demo-notice-v1","evidence":[{"source":"synthetic-fixture-v1","is_demo":true}],"reference":"supabase/seed/04_pickwell_demo.sql"}'::jsonb
  where not exists (select 1 from public.analysis_findings where id = demo_finding);

  -- Do not overwrite an existing publication, correction, or admin invalidation.
  update public.products set current_analysis_id = demo_analysis, status = 'ready',
    published_at = '2026-11-02T00:00:00Z'
    where id = demo_product and is_demo and status = 'processing' and current_analysis_id is null;
end;
$$;
