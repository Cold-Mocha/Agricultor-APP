-- Structural checks for migration 0020. Runtime parity cases live beside the
-- sync tests and are intentionally not hidden behind frontend behaviour.
do $$
begin
  if to_regprocedure('public.operation_allowed(text,text)') is null then
    raise exception 'operation_allowed_missing';
  end if;
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'labors'
      and column_name = 'domain_category'
  ) then raise exception 'labors_domain_category_missing'; end if;
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'soil_measurements'
      and column_name = 'labor_id'
  ) then raise exception 'soil_labor_id_missing'; end if;
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'apiary_inspections'
      and column_name = 'labor_id'
  ) then raise exception 'apiary_labor_id_missing'; end if;
  if public.operation_allowed('crop', 'irrigationRecord') is not true
     or public.operation_allowed('apiary', 'irrigationRecord') is not false
     or public.operation_allowed('legacyUnknown', 'photoAttach') is not false then
    raise exception 'operation_matrix_mismatch';
  end if;
end $$;
