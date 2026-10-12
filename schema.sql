-- Run in Supabase SQL Editor on a NEW project.
-- Public SELECT; admin-only writes, enforced in Postgres (not just the UI).
create extension if not exists pgcrypto;
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique check (length(trim(name)) between 1 and 80),
  created_at timestamptz not null default now()
);
create table if not exists public.supplements (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) between 1 and 150),
  subtitle text not null default '',
  category_id uuid references public.categories(id) on delete set null,
  image_url text,
  sections jsonb not null default '[]'::jsonb check (jsonb_typeof(sections)='array'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists supplements_category_idx on public.supplements(category_id);
create index if not exists supplements_created_idx on public.supplements(created_at desc);
-- SECURITY DEFINER is used only for a fixed boolean check, with a safe search_path.
create or replace function public.is_site_admin() returns boolean
language sql stable security definer set search_path = ''
as $$ select exists(select 1 from public.admins where user_id = (select auth.uid())); $$;
revoke all on function public.is_site_admin() from public;
grant execute on function public.is_site_admin() to anon, authenticated;
alter table public.admins enable row level security;
alter table public.categories enable row level security;
alter table public.supplements enable row level security;
-- admins: authenticated user can see only their own row; no client-side writes.
create policy "Read own admin status" on public.admins for select to authenticated using (user_id=(select auth.uid()));
create policy "Public categories read" on public.categories for select to anon, authenticated using (true);
create policy "Admin categories insert" on public.categories for insert to authenticated with check (public.is_site_admin());
create policy "Admin categories update" on public.categories for update to authenticated using (public.is_site_admin()) with check (public.is_site_admin());
create policy "Admin categories delete" on public.categories for delete to authenticated using (public.is_site_admin());
create policy "Public supplements read" on public.supplements for select to anon, authenticated using (true);
create policy "Admin supplements insert" on public.supplements for insert to authenticated with check (public.is_site_admin());
create policy "Admin supplements update" on public.supplements for update to authenticated using (public.is_site_admin()) with check (public.is_site_admin());
create policy "Admin supplements delete" on public.supplements for delete to authenticated using (public.is_site_admin());
-- Public image bucket; only admin may write objects.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values ('supplement-images','supplement-images',true,5242880,array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public=true,file_size_limit=5242880,allowed_mime_types=array['image/jpeg','image/png','image/webp'];
create policy "Public supplement image read" on storage.objects for select to anon,authenticated using (bucket_id='supplement-images');
create policy "Admin supplement image upload" on storage.objects for insert to authenticated with check (bucket_id='supplement-images' and public.is_site_admin());
create policy "Admin supplement image update" on storage.objects for update to authenticated using (bucket_id='supplement-images' and public.is_site_admin()) with check (bucket_id='supplement-images' and public.is_site_admin());
create policy "Admin supplement image delete" on storage.objects for delete to authenticated using (bucket_id='supplement-images' and public.is_site_admin());
-- IMPORTANT: After creating your own auth user in Supabase Dashboard,
-- grant yourself admin using the following command with your actual auth user UUID:
-- insert into public.admins(user_id) values ('YOUR-AUTH-USER-UUID');
-- Disable public signups in Supabase Auth settings; create your own user in Dashboard.
