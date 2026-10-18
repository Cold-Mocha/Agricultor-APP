-- Sólo funciones temporales para fixtures ficticios. No objetos de producto.
create function pg_temp.fid(n integer) returns uuid language sql immutable as $$
  select ('ac100000-0000-4000-8000-' || lpad(n::text,12,'0'))::uuid
$$;
create function pg_temp.sector(n integer, num integer, category text default 'crop')
returns jsonb language sql as $$ select jsonb_build_object(
  'id',pg_temp.fid(n),'number',num,'name','FICTICIO QA Sector '||num,'kind',category,
  'polygon','[{"lat":-38.74,"lng":-72.60},{"lat":-38.74,"lng":-72.59},{"lat":-38.73,"lng":-72.59},{"lat":-38.73,"lng":-72.60}]'::jsonb,
  'updated_at','2026-10-10T12:00:00Z') $$;
create function pg_temp.op(n integer, category text, data jsonb,
  mutation text default 'create', base bigint default null) returns jsonb language sql as $$
  select jsonb_build_object('operation_id',pg_temp.fid(n),'aggregate_type',category,
    'aggregate_id',data->>'id','mutation_kind',mutation,'protocol_version',2,
    'payload_schema_version',1,'request_hash',md5(data::text||mutation||coalesce(base::text,'')),
    'base_version',base,'payload',data)
$$;
create function pg_temp.push(n integer, category text, data jsonb,
  mutation text default 'create', base bigint default null) returns jsonb language sql as $$
  select public.sync_push(jsonb_build_array(pg_temp.op(n,category,data,mutation,base)))->'results'->0
$$;
create function pg_temp.season(n integer, sector_n integer) returns jsonb language sql as $$
  select jsonb_build_object('id',pg_temp.fid(n),'sector_id',pg_temp.fid(sector_n),
    'name','FICTICIO QA Temporada','starts_on','2026-01-01','status','active',
    'updated_at','2026-10-10T12:00:00Z')
$$;
create function pg_temp.assignment(n integer, sector_n integer, season_n integer)
returns jsonb language sql as $$ select jsonb_build_object('id',pg_temp.fid(n),
  'sector_id',pg_temp.fid(sector_n),'agricultural_season_id',pg_temp.fid(season_n),
  'crop_id','maiz','is_custom_crop',false,'status','active','starts_on','2026-01-01',
  'updated_at','2026-10-10T12:00:00Z') $$;
create function pg_temp.labor(n integer, category text default 'fertilization',
  sector_n integer default 101, season_n integer default 301, assignment_n integer default 401)
returns jsonb language sql as $$ select jsonb_build_object('id',pg_temp.fid(n),
  'sector_id',pg_temp.fid(sector_n),'agricultural_season_id',pg_temp.fid(season_n),
  'crop_assignment_id',pg_temp.fid(assignment_n),'type',category,'domain_category','crop',
  'details',jsonb_build_object('schemaVersion',1,'type',category,
    'data',jsonb_build_object('amount',10.5,'unit','kg','measured',true)),
  'details_schema_version',1,'status','recorded','notes','FICTICIO QA',
  'occurred_at','2026-10-10T12:00:00Z','updated_at','2026-10-10T12:00:00Z') $$;
insert into auth.users(id,aud,role,email,created_at,updated_at) values
  (pg_temp.fid(1),'authenticated','authenticated','qa-persistence-a@example.invalid',now(),now()),
  (pg_temp.fid(2),'authenticated','authenticated','qa-persistence-b@example.invalid',now(),now());
