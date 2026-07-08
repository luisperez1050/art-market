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
  env_variables jsonb default '{}'::jsonb not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on Projects
alter table public.projects enable row level security;

-- 4. Create Assets Table (media files)
create table public.assets (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  storage_path text not null,
  file_name text not null,
  size text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on Assets
alter table public.assets enable row level security;

create or replace function public.handle_new_user()
returns trigger as $$
declare
  is_admin_flag boolean := false;
begin
  if new.email = 'admin@gmail.com' then
    is_admin_flag := true;
  else
    is_admin_flag := coalesce((new.raw_user_meta_data->>'is_admin')::boolean, false);
  end if;

  insert into public.profiles (id, full_name, is_admin)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    is_admin_flag
  )
  on conflict (id) do update set
    full_name = excluded.full_name,
    is_admin = excluded.is_admin;
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

-- 8. Seeding Mock Data Mapped Dynamically to Preset Auth Users

-- Seed dummy users that are not used for logins but are needed for foreign key constraints
insert into auth.users (id, email, email_confirmed_at, role, aud)
values 
  ('00000000-0000-0000-0000-000000000003', 'apex@mktg.com', now(), 'authenticated', 'authenticated')
on conflict (id) do nothing;

-- Seed profiles explicitly (just in case they already existed and trigger did not fire)
insert into public.profiles (id, full_name, is_admin)
values
  ((select id from auth.users where email = 'admin@gmail.com'), 'System Admin', true),
  ((select id from auth.users where email = 'chloe@gmail.com'), 'Chloe', false),
  ('00000000-0000-0000-0000-000000000003', 'Apex Marketing Group', false)
on conflict (id) do update set
  full_name = excluded.full_name,
  is_admin = excluded.is_admin;

-- Seed subscriptions
insert into public.subscriptions (user_id, tier_name, status, current_period_end)
values 
  ((select id from auth.users where email = 'chloe@gmail.com'), 'Standard Hosting Tier', 'active', now() + interval '1 month'),
  ((select id from auth.users where email = 'apex@mktg.com'), 'Standard Hosting Tier', 'delinquent', now() - interval '5 days')
on conflict (user_id) do update set
  tier_name = excluded.tier_name,
  status = excluded.status,
  current_period_end = excluded.current_period_end;

-- Seed projects
insert into public.projects (user_id, name, subdomain, domain, git_branch, repo, last_deployment, status)
values
  ((select id from auth.users where email = 'chloe@gmail.com'), 'Chloe''s Portfolio Gallery', 'chloes-art', 'chloes-art-portfolio.com', 'main', 'chloe/portfolio', '2 hours ago', 'active')
on conflict (subdomain) do update set
  user_id = excluded.user_id,
  name = excluded.name,
  domain = excluded.domain,
  git_branch = excluded.git_branch,
  repo = excluded.repo,
  last_deployment = excluded.last_deployment,
  status = excluded.status;

-- Seed assets
insert into public.assets (user_id, storage_path, file_name, size)
values
  ((select id from auth.users where email = 'chloe@gmail.com'), 'assets/abstract_canvas_oil.png', 'abstract_canvas_oil.png', '1.4 MB'),
  ((select id from auth.users where email = 'chloe@gmail.com'), 'assets/ocean_impression_watercolor.png', 'ocean_impression_watercolor.png', '2.1 MB')
on conflict do nothing;
