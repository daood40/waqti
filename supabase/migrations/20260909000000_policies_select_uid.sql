-- «وقتي» — تحسين السياسات (data-supabase-backend):
-- (select auth.uid()) يُقيَّم مرة واحدة لكل استعلام بدل كل صف.
drop policy if exists "own row select" on public.user_backups;
create policy "own row select" on public.user_backups
  for select to authenticated using ((select auth.uid()) = user_id);

drop policy if exists "own row insert" on public.user_backups;
create policy "own row insert" on public.user_backups
  for insert to authenticated with check ((select auth.uid()) = user_id);

drop policy if exists "own row update" on public.user_backups;
create policy "own row update" on public.user_backups
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "own row delete" on public.user_backups;
create policy "own row delete" on public.user_backups
  for delete to authenticated using ((select auth.uid()) = user_id);

-- updated_at يُضبط من الخادم لا من العميل (لا تزوير للطابع الزمني في LWW).
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists user_backups_set_updated_at on public.user_backups;
create trigger user_backups_set_updated_at
  before insert or update on public.user_backups
  for each row execute function public.set_updated_at();
