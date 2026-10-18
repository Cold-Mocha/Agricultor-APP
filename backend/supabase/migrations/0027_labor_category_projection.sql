-- F05: derive omitted legacy categories exclusively from the matching sector.
-- Diagnose ambiguous or incompatible legacy rows before any backfill.
do $$
declare invalid_count bigint;
begin
  select count(*) into invalid_count from public.labors l left join public.sectors s
    on s.id=l.sector_id and s.owner_id=l.owner_id
    where s.kind is null or s.kind not in ('crop','apiary')
      or (l.domain_category is not null and l.domain_category <> s.kind)
      or (l.type='apiary') <> (s.kind='apiary');
  if invalid_count > 0 then
    raise exception 'labor_category_backfill_ambiguous: % rows; explicit repair required', invalid_count;
  end if;
end $$;

update public.labors l set domain_category=s.kind from public.sectors s
  where l.sector_id=s.id and l.owner_id=s.owner_id and l.domain_category is null;
-- Pull is an event log: enrich only an omitted category using immutable context.
update public.sync_changes c set payload=c.payload || jsonb_build_object('domain_category',l.domain_category)
  from public.labors l where c.aggregate_type='labor' and c.aggregate_id=l.id
    and c.owner_id=l.owner_id and c.payload->>'domain_category' is null;

create or replace function public.check_labor_category()
returns trigger language plpgsql security definer set search_path=public,pg_temp as $$
declare category text;
begin
  select kind into category from public.sectors where id=new.sector_id and owner_id=new.owner_id;
  if category is null or (new.domain_category is not null and new.domain_category <> category)
    or (new.type='apiary') <> (category='apiary') then
    raise exception 'labor_category_mismatch' using errcode='23514';
  end if;
  new.domain_category := coalesce(new.domain_category,category);
  return new;
end $$;
create trigger labors_category_valid before insert or update on public.labors
  for each row execute function public.check_labor_category();
alter table public.labors alter column domain_category set not null;
revoke all on function public.check_labor_category() from public,anon,authenticated;
