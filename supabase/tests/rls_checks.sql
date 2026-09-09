-- فحص RLS كمستخدمين حقيقيين داخل معاملة تُلغى (qa-database-testing).
-- التشغيل: psql "$DB_URL" -v ON_ERROR_STOP=1 -f supabase/tests/rls_checks.sql
begin;

-- مستخدمان وهميان
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'a@test.local'),
  ('00000000-0000-0000-0000-00000000000b', 'b@test.local')
on conflict do nothing;

-- المستخدم A يكتب صفه
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';
insert into public.user_backups (user_id, payload) values ('00000000-0000-0000-0000-00000000000a', '{"owner":"a"}');

-- A يرى صفًا واحدًا فقط
do $$
declare n int;
begin
  select count(*) into n from public.user_backups;
  if n <> 1 then raise exception 'A should see exactly 1 row, saw %', n; end if;
end $$;

-- المستخدم B لا يرى صف A ولا يستطيع تعديله أو حذفه
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}';
do $$
declare n int;
begin
  select count(*) into n from public.user_backups;
  if n <> 0 then raise exception 'B must see 0 rows, saw %', n; end if;
  update public.user_backups set payload = '{"hacked":true}' where user_id = '00000000-0000-0000-0000-00000000000a';
  if found then raise exception 'B updated A row'; end if;
  delete from public.user_backups where user_id = '00000000-0000-0000-0000-00000000000a';
  if found then raise exception 'B deleted A row'; end if;
end $$;

-- B لا يستطيع إدراج صف باسم A
do $$
begin
  begin
    insert into public.user_backups (user_id, payload) values ('00000000-0000-0000-0000-00000000000a', '{"spoof":1}');
    raise exception 'B inserted as A';
  exception when insufficient_privilege or check_violation then
    null; -- متوقع
  end;
end $$;

-- المجهول لا يرى شيئًا
set local role anon;
do $$
begin
  begin
    perform * from public.user_backups;
    raise exception 'anon could select';
  exception when insufficient_privilege then null;
  end;
end $$;

rollback;
select 'RLS checks passed' as result;
