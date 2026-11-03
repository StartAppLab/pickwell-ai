-- Preserve printed IU, qualified vitamin units and daily-value percentages.
-- Additive validation change only; existing amounts, immutable revisions and grants stay intact.
begin;
create or replace function public.pickwell_valid_nutrition(value jsonb)
returns boolean language plpgsql immutable set search_path = '' as $$
declare nutrient jsonb;
begin
  if value is null or jsonb_typeof(value) <> 'object'
    or coalesce(jsonb_typeof(value->'raw') <> 'string', true)
    or coalesce(length(btrim(value->>'raw')), 0) = 0
    or coalesce(value->>'basis' not in ('per_100g', 'per_100ml', 'per_serving', 'unknown'), true)
    or coalesce(jsonb_typeof(value->'nutrients') <> 'array', true) then return false; end if;
  -- Unconfirmed serving/basis is explicit unknown data, never inferred for findings.
  for nutrient in select * from jsonb_array_elements(value->'nutrients') loop
    if jsonb_typeof(nutrient) <> 'object'
      or coalesce(jsonb_typeof(nutrient->'name') <> 'string', true)
      or coalesce(length(btrim(nutrient->>'name')), 0) = 0
      or coalesce(nutrient->>'unit' not in ('g', 'mg', 'ug', 'kcal', 'kJ', 'IU', 'ug RAE', 'ug DFE', 'mg NE', 'mg α-TE', '%', '%DV', 'unknown'), true)
      or coalesce(jsonb_typeof(nutrient->'value') not in ('number', 'null'), true) then return false; end if;
    if jsonb_typeof(nutrient->'value') = 'number' then
      if (nutrient->>'value')::numeric < 0 or nutrient->>'unit' = 'unknown'
        or coalesce(jsonb_typeof(nutrient->'source') <> 'string', true)
        or coalesce(length(btrim(nutrient->>'source')), 0) = 0 then return false; end if;
    end if;
  end loop;
  return true;
end;
$$;

commit;
