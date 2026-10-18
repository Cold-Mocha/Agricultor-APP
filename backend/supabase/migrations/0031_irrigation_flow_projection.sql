-- Keep the already-emitted typed flow in the relational projection.
do $$
declare definition text;
begin
  select pg_get_functiondef('public.sync_push_irrigation_v2(jsonb)'::regprocedure)
    into definition;
  if strpos(definition, 'duration_minutes,estimated_liters,config_id') = 0
     or strpos(definition, 'ceil((irrigation->>''duration_seconds'')::numeric/60)::integer,') = 0
     or strpos(definition, 'duration_minutes=excluded.duration_minutes,applied_volume_ml') = 0 then
    raise exception 'irrigation_projection_contract_unexpected';
  end if;
  definition := replace(definition,
    'duration_minutes,estimated_liters,config_id',
    'flow_liters_per_hour,duration_minutes,estimated_liters,config_id');
  definition := replace(definition,
    'ceil((irrigation->>''duration_seconds'')::numeric/60)::integer,',
    'nullif(payload->''details''->''data''->>''flowLitersPerHour'','''')::double precision,
            ceil((irrigation->>''duration_seconds'')::numeric/60)::integer,');
  definition := replace(definition,
    'duration_minutes=excluded.duration_minutes,applied_volume_ml',
    'flow_liters_per_hour=excluded.flow_liters_per_hour,duration_minutes=excluded.duration_minutes,applied_volume_ml');
  execute definition;
end;
$$;

-- Recover only explicitly recorded numeric values, never infer unknown flow.
update public.irrigation_records r
set flow_liters_per_hour = (l.details->'data'->>'flowLitersPerHour')::double precision
from public.labors l
where r.labor_id=l.id and r.owner_id=l.owner_id and r.sector_id=l.sector_id
  and r.flow_liters_per_hour is null
  and l.type='irrigation'
  and jsonb_typeof(l.details->'data'->'flowLitersPerHour')='number';
