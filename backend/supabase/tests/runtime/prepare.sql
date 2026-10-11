-- Exclusivamente cuentas ficticias para GoTrue local. Identidades deterministas.
begin;
insert into auth.users(instance_id,id,aud,role,email,encrypted_password,
  email_confirmed_at,raw_app_meta_data,raw_user_meta_data,created_at,updated_at,
  confirmation_token,email_change,email_change_token_new,recovery_token)
select '00000000-0000-0000-0000-000000000000'::uuid,
  ('ac200000-0000-4000-8000-'||lpad(n::text,12,'0'))::uuid,
  'authenticated','authenticated','qa-persistence-'||n||'@example.invalid',
  extensions.crypt('Ficticio-QA-2026-Only!',extensions.gen_salt('bf')),
  now(),'{"provider":"email","providers":["email"]}'::jsonb,
  '{"display_name":"FICTICIO QA persistencia"}'::jsonb,now(),now(),'','','',''
from generate_series(1,2) n;
insert into auth.identities(id,user_id,provider_id,identity_data,provider,created_at,updated_at)
select gen_random_uuid(),id,id::text,jsonb_build_object('sub',id,'email',email,'email_verified',true),
  'email',now(),now() from auth.users
where id in ('ac200000-0000-4000-8000-000000000001','ac200000-0000-4000-8000-000000000002');
commit;
