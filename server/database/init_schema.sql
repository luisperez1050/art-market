-- Recreate all tables cleanly to overwrite old mock or template columns
drop table if exists public.assets cascade;
drop table if exists public.projects cascade;
drop table if exists public.subscriptions cascade;
drop table if exists public.profiles cascade;

-- 1. Create Profiles Table (extends Supabase auth.users)
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  updated_at timestamp with time zone,
  full_name text,
  is_admin boolean default false not null
);

-- Enable RLS on Profiles
alter table public.profiles enable row level security;

-- 2. Create Subscriptions Table
create table public.subscriptions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade unique not null,
  tier_name text not null,
  status text not null check (status in ('active', 'trialing', 'past_due', 'canceled', 'delinquent')),
  current_period_end timestamp with time zone
);

-- Enable RLS on Subscriptions
alter table public.subscriptions enable row level security;

-- 3. Create Projects Table (stores hosted sites)
create table public.projects (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  name text not null,
  subdomain text not null unique,
  domain text not null unique,
  git_branch text default 'main' not null,
  repo text not null,
  last_deployment text not null,
  status text not null check (status in ('active', 'building', 'failed')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on Projects
alter table public.projects enable row level security;

-- 4. Create Assets Table (media files)
create table if not exists public.assets (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  storage_path text not null,
  file_name text not null,
  size text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on Assets
alter table public.assets enable row level security;

-- 5. Trigger Function for syncing auth.users -> profiles
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, is_admin)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce((new.raw_user_meta_data->>'is_admin')::boolean, false)
  );
  return new;
end;
$$ language plpgsql security definer;

-- Bind Sync Trigger
create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 6. Security Definer Helper Function for Non-Recursive Admin Checks
create or replace function public.is_admin()
returns boolean as $$
begin
  return exists (
    select 1 from public.profiles
    where id = auth.uid() and is_admin = true
  );
end;
$$ language plpgsql security definer;

-- 7. Define RLS Policies

-- Profiles Policies
create policy "Allow profile access to self" on public.profiles 
  for select using (auth.uid() = id);

create policy "Allow profile updates to self" on public.profiles 
  for update using (auth.uid() = id);

create policy "Allow profile override to admins" on public.profiles 
  using (public.is_admin());

-- Subscriptions Policies
create policy "Allow subscription access to self" on public.subscriptions 
  for select using (auth.uid() = user_id);

create policy "Allow subscription override to admins" on public.subscriptions 
  using (public.is_admin());

-- Projects Policies
create policy "Allow project access to self" on public.projects 
  using (auth.uid() = user_id);

create policy "Allow project read globally (needed for routing resolution)" on public.projects 
  for select using (true);

create policy "Allow project override to admins" on public.projects 
  using (public.is_admin());

-- Assets Policies
create policy "Allow asset access to self" on public.assets 
  using (auth.uid() = user_id);

create policy "Allow asset override to admins" on public.assets 
  using (public.is_admin());

-- 8. Seeding Mock Data

-- Seed auth.users records
insert into auth.users (id, email, encrypted_password, email_confirmed_at, role, aud, raw_user_meta_data)
values 
  ('00000000-0000-0000-0000-000000000001', 'admin@gmail.com', '$2b$12$jVqGvsvxVGcNWhMRKv6bAOl1JTTcktQxx/F.H.tiRsV8dgPOcbxLe', now(), 'authenticated', 'authenticated', '{"full_name": "System Admin", "is_admin": true}'),
  ('00000000-0000-0000-0000-000000000002', 'chloe@gmail.com', '$2b$12$jVqGvsvxVGcNWhMRKv6bAOl1JTTcktQxx/F.H.tiRsV8dgPOcbxLe', now(), 'authenticated', 'authenticated', '{"full_name": "Chloe"}'),
  ('00000000-0000-0000-0000-000000000003', 'apex@mktg.com', '$2b$12$jVqGvsvxVGcNWhMRKv6bAOl1JTTcktQxx/F.H.tiRsV8dgPOcbxLe', now(), 'authenticated', 'authenticated', '{"full_name": "Apex Marketing Group"}')
on conflict (id) do nothing;

-- Update profiles admin flag (trigger creates record automatically, we force status here)
update public.profiles set is_admin = true where id = '00000000-0000-0000-0000-000000000001';

-- Seed subscriptions
insert into public.subscriptions (user_id, tier_name, status, current_period_end)
values 
  ('00000000-0000-0000-0000-000000000002', 'Standard Hosting Tier', 'active', now() + interval '1 month'),
  ('00000000-0000-0000-0000-000000000003', 'Standard Hosting Tier', 'delinquent', now() - interval '5 days')
on conflict (user_id) do nothing;

-- Seed projects
insert into public.projects (user_id, name, subdomain, domain, git_branch, repo, last_deployment, status)
values
  ('00000000-0000-0000-0000-000000000002', 'Chloe''s Portfolio Gallery', 'chloes-art', 'chloes-art-portfolio.com', 'main', 'chloe/portfolio', '2 hours ago', 'active')
on conflict (subdomain) do nothing;

-- Seed assets
insert into public.assets (user_id, storage_path, file_name, size)
values
  ('00000000-0000-0000-0000-000000000002', 'assets/abstract_canvas_oil.png', 'abstract_canvas_oil.png', '1.4 MB'),
  ('00000000-0000-0000-0000-000000000002', 'assets/ocean_impression_watercolor.png', 'ocean_impression_watercolor.png', '2.1 MB')
on conflict do nothing;
