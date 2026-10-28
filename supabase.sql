-- Fresh installation; this does not alter the original gsa_batch_students table.
-- First create a dedicated shared staff user in Supabase Authentication.
-- Replace the UUID placeholder below, then run this entire script.
begin;
create table if not exists public.gsa_scheduler_staff (
 user_id uuid primary key references auth.users(id) on delete cascade
);
alter table public.gsa_scheduler_staff enable row level security;
revoke all on public.gsa_scheduler_staff from anon, authenticated;
grant select on public.gsa_scheduler_staff to authenticated;
drop policy if exists "Read own staff membership" on public.gsa_scheduler_staff;
create policy "Read own staff membership" on public.gsa_scheduler_staff for select to authenticated using (user_id=auth.uid());
insert into public.gsa_scheduler_staff(user_id) values ('REPLACE_WITH_STAFF_USER_UUID'::uuid) on conflict do nothing;
create or replace function public.gsa_valid_batches(value jsonb) returns boolean
language plpgsql immutable set search_path=public as $$
declare b jsonb; seen text[] := '{}'; slot text;
begin
 if jsonb_typeof(value) <> 'array' or jsonb_array_length(value)>70 then return false; end if;
 for b in select jsonb_array_elements(value) loop
  if jsonb_typeof(b)<>'object' or not (b ? 'day' and b ? 'hour') then return false; end if;
  if jsonb_typeof(b->'day')<>'string' or (b->>'day') not in ('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') then return false; end if;
  if jsonb_typeof(b->'hour')<>'number' or (b->>'hour')::numeric not between 10 and 19 or (b->>'hour')::numeric<>trunc((b->>'hour')::numeric) then return false; end if;
  slot := (b->>'day') || ':' || (b->>'hour')::numeric::integer;
  if slot=any(seen) then return false; end if;
  seen := array_append(seen,slot);
 end loop;
 return true;
end $$;
create table if not exists public.gsa_students (
 id uuid primary key default gen_random_uuid(),
 center text not null check(center in ('Lucknow','Noida')),
 student_name text not null check(char_length(trim(student_name)) between 1 and 120),
 age integer not null check(age between 1 and 18),
 batches jsonb not null default '[]'::jsonb check(public.gsa_valid_batches(batches)),
 created_at timestamptz not null default now()
);
alter table public.gsa_students enable row level security;
revoke all on public.gsa_students from anon, authenticated;
grant select, insert, update on public.gsa_students to authenticated;
drop policy if exists "Scheduler staff read" on public.gsa_students;
drop policy if exists "Scheduler staff insert" on public.gsa_students;
drop policy if exists "Scheduler staff update" on public.gsa_students;
create policy "Scheduler staff read" on public.gsa_students for select to authenticated using (exists(select 1 from public.gsa_scheduler_staff where user_id=auth.uid()));
create policy "Scheduler staff insert" on public.gsa_students for insert to authenticated with check(exists(select 1 from public.gsa_scheduler_staff where user_id=auth.uid()));
create policy "Scheduler staff update" on public.gsa_students for update to authenticated using(exists(select 1 from public.gsa_scheduler_staff where user_id=auth.uid())) with check(exists(select 1 from public.gsa_scheduler_staff where user_id=auth.uid()));
commit;
