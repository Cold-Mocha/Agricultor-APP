begin;
select plan(2);
select policies_are('public', 'apiary_inspections', array['apiary_inspections_owner_all'], 'apiary access is owner-scoped');
select col_is_fk('public', 'apiary_inspections', 'sector_id', 'apiary inspection belongs to a sector');
select * from finish();
rollback;
