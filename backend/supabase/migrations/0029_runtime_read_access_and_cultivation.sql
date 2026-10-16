-- Authenticated includes device-scoped anonymous identities. RLS still scopes
-- private rows to auth.uid(); only RPCs perform agricultural writes.
grant usage on schema public to authenticated;
grant select on public.sectors, public.sync_changes, public.sync_operations,
  public.custom_crops, public.official_crops, public.agricultural_seasons,
  public.crop_seasons, public.labors, public.soil_measurements,
  public.irrigation_records, public.irrigation_estimates,
  public.sector_irrigation_configs, public.crop_irrigation_rules,
  public.production_records, public.apiary_inspections, public.reminders,
  public.photo_attachments to authenticated;
revoke all on function public.sync_pull(bigint, integer) from public, anon;
grant execute on function public.sync_pull(bigint, integer) to authenticated;

alter table public.labors drop constraint labors_type_check;
alter table public.labors add constraint labors_type_check check (
  type in ('irrigation','soil','fertilization','diseaseAndPestControl',
    'cultivation','sowing','pruning','harvest','apiary','other')
);

-- Preserve the audited handler and change only its type allowlist.
do $$
declare
  definition text := pg_get_functiondef('public.sync_push_labor_v2(jsonb)'::regprocedure);
  before_types text := '''irrigation'',''soil'',''fertilization'',''diseaseAndPestControl'',''sowing'',''pruning'',''harvest'',''apiary'',''other''';
  after_types text := '''irrigation'',''soil'',''fertilization'',''diseaseAndPestControl'',''cultivation'',''sowing'',''pruning'',''harvest'',''apiary'',''other''';
begin
  if position(before_types in definition) = 0 then
    raise exception 'labor_handler_contract_requires_review';
  end if;
  execute replace(definition, before_types, after_types);
end $$;
