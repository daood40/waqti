-- «وقتي» — المخطط الأولي: نسخة سحابية لكل مستخدم + حذف الحساب ذاتيًا.
-- يُطبَّق عبر: supabase db push  (أو لصقه في SQL Editor).

create table if not exists public.user_backups (
  user_id     uuid primary key references auth.users (id) on delete cascade,
  payload     text        not null check (length(payload) <= 2 * 1024 * 1024), -- 2MB حد أعلى
  app_version text        not null default '',
  updated_at  timestamptz not null default now(),
  created_at  timestamptz not null default now()
);

comment on table public.user_backups is 'Full-state JSON snapshot per user (last write wins).';

create index if not exists user_backups_updated_at_idx on public.user_backups (updated_at desc);

alter table public.user_backups enable row level security;

-- المالك فقط: قراءة/إدراج/تعديل/حذف صفه.
drop policy if exists "own row select" on public.user_backups;
create policy "own row select" on public.user_backups
  for select to authenticated using (auth.uid() = user_id);

drop policy if exists "own row insert" on public.user_backups;
create policy "own row insert" on public.user_backups
  for insert to authenticated with check (auth.uid() = user_id);

drop policy if exists "own row update" on public.user_backups;
create policy "own row update" on public.user_backups
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own row delete" on public.user_backups;
create policy "own row delete" on public.user_backups
  for delete to authenticated using (auth.uid() = user_id);

-- لا وصول للمجهولين إطلاقًا (لا سياسة = رفض).
revoke all on public.user_backups from anon;
grant select, insert, update, delete on public.user_backups to authenticated;

-- حذف الحساب من التطبيق (شرط App Store وGoogle Play):
-- دالة بصلاحية المُعرِّف تحذف صف auth.users للمستخدم الحالي فقط؛ الحذف المتسلسل يزيل بياناته.
create or replace function public.delete_own_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_own_account() from public;
grant execute on function public.delete_own_account() to authenticated;
