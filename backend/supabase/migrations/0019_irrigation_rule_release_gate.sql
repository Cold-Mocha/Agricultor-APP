-- Persist every immutable field required by the deterministic drip-rule release gate.
alter table public.crop_irrigation_rules
  add column if not exists reviewer text,
  add column if not exists approved_vector_count integer not null default 0
    check (approved_vector_count >= 0),
  add column if not exists base_ml_per_plant integer not null default 1000
    check (base_ml_per_plant > 0),
  add column if not exists minimum_adjustment_bp integer not null default 5000
    check (minimum_adjustment_bp > 0),
  add column if not exists maximum_adjustment_bp integer not null default 15000
    check (maximum_adjustment_bp >= minimum_adjustment_bp);

alter table public.crop_irrigation_rules
  drop constraint if exists crop_irrigation_rules_release_gate;

alter table public.crop_irrigation_rules
  add constraint crop_irrigation_rules_release_gate check (
    not is_active or (
      approved_at is not null and
      nullif(trim(reviewer), '') is not null and
      approved_vector_count >= 20 and
      nullif(trim(source_title), '') is not null and
      nullif(trim(source_reference), '') is not null
    )
  );
