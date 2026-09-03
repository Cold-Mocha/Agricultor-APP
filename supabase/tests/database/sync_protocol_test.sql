begin;
select plan(5);

select has_table('public', 'parcels', 'parcel slice exists');
select has_table('public', 'sync_operations', 'idempotency ledger exists');
select has_table('public', 'sync_changes', 'pull change stream exists');
select has_function('public', 'sync_push', array['jsonb'], 'push RPC exists');
select has_function('public', 'sync_pull', array['bigint', 'integer'], 'pull RPC exists');

select * from finish();
rollback;
