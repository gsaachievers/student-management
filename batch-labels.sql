create table public.gsa_batch_labels (
 center text not null check(center in ('Lucknow','Noida')),
 day text not null check(day in ('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')),
 hour integer not null check(hour between 10 and 19),
 age_range text not null check(age_range in ('','3–6','6–9','9–12')),
 primary key(center,day,hour)
);
alter table public.gsa_batch_labels enable row level security;
revoke all on public.gsa_batch_labels from anon,authenticated;
grant select,insert,update on public.gsa_batch_labels to authenticated;
create policy "Staff read batch labels" on public.gsa_batch_labels for select to authenticated using(exists(select 1 from public.gsa_scheduler_staff where user_id=(select auth.uid())));
create policy "Staff insert batch labels" on public.gsa_batch_labels for insert to authenticated with check(exists(select 1 from public.gsa_scheduler_staff where user_id=(select auth.uid())));
create policy "Staff update batch labels" on public.gsa_batch_labels for update to authenticated using(exists(select 1 from public.gsa_scheduler_staff where user_id=(select auth.uid()))) with check(exists(select 1 from public.gsa_scheduler_staff where user_id=(select auth.uid())));