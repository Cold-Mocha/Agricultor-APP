-- Structural checks for migration 0020. Runtime parity cases live beside the
-- sync tests and are intentionally not hidden behind frontend behaviour.
begin;
select plan(5);

select ok(
  to_regprocedure('public.operation_allowed(text,text)') is not null,
  'operation_allowed function exists'
);
select has_column('public', 'labors', 'domain_category', 'labors carry a domain category');
select has_column('public', 'soil_measurements', 'labor_id', 'soil measurements link a labor');
select has_column('public', 'apiary_inspections', 'labor_id', 'apiary inspections link a labor');
select ok(
  public.operation_allowed('crop', 'irrigationRecord') is true
    and public.operation_allowed('apiary', 'irrigationRecord') is false
    and public.operation_allowed('legacyUnknown', 'photoAttach') is false,
  'operation_allowed matches the crop/apiary/legacy matrix'
);

select * from finish();
rollback;
