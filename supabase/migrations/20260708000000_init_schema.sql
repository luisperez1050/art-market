-- Create profiles table
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  full_name text,
  avatar_url text,
  updated_at timestamp with zone
);

-- Enable RLS on profiles
alter table public.profiles enable row level security;

create policy "Users can view own profile" on public.profiles 
  for select using (auth.uid() = id);

create policy "Users can update own profile" on public.profiles 
  for update using (auth.uid() = id);

-- Create profile sync trigger function
create or replace function public.handle_new_user()
returns trigger as $$
declare
  is_admin_flag boolean := false;
begin
  if new.email = 'admin@gmail.com' then
    is_admin_flag := true;
  end if;

  insert into public.profiles (id, full_name, avatar_url, is_admin)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'avatar_url', ''),
    is_admin_flag
  )
  on conflict (id) do update set
    is_admin = excluded.is_admin;
  return new;
end;
$$ language plpgsql security definer;

-- Bind trigger to auth.users
create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Create organizations table
create table public.organizations (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  slug text not null unique,
  owner_id uuid references public.profiles(id) on delete set null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on organizations
alter table public.organizations enable row level security;

create policy "Users can view organizations they own" on public.organizations 
  for select using (auth.uid() = owner_id);

create policy "Users can insert organizations they own" on public.organizations 
  for insert with check (auth.uid() = owner_id);

create policy "Users can update organizations they own" on public.organizations 
  for update using (auth.uid() = owner_id);

-- Create subscriptions table
create table public.subscriptions (
  id uuid default gen_random_uuid() primary key,
  org_id uuid references public.organizations(id) on delete cascade unique not null,
  stripe_subscription_id text unique,
  status text not null check (status in ('active', 'trialing', 'past_due', 'canceled', 'incomplete')),
  price_id text,
  current_period_end timestamp with time zone
);

-- Enable RLS on subscriptions
alter table public.subscriptions enable row level security;

create policy "Users can view subscriptions of their organizations" on public.subscriptions 
  for select using (
    exists (
      select 1 from public.organizations 
      where organizations.id = subscriptions.org_id and organizations.owner_id = auth.uid()
    )
  );

-- Create projects table (the hosting projects)
create table public.projects (
  id uuid default gen_random_uuid() primary key,
  org_id uuid references public.organizations(id) on delete cascade not null,
  name text not null,
  subdomain text not null unique,
  repository_url text,
  branch text default 'main' not null,
  env_variables jsonb default '{}'::jsonb not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on projects
alter table public.projects enable row level security;

create policy "Users can manage projects of their organizations" on public.projects 
  using (
    exists (
      select 1 from public.organizations 
      where organizations.id = projects.org_id and organizations.owner_id = auth.uid()
    )
  );

create policy "Anyone can view projects (needed for routing resolution)" on public.projects 
  for select using (true);

-- Create deployments table
create table public.deployments (
  id uuid default gen_random_uuid() primary key,
  project_id uuid references public.projects(id) on delete cascade not null,
  status text not null default 'queued' check (status in ('queued', 'building', 'ready', 'failed')),
  commit_sha text,
  build_log_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on deployments
alter table public.deployments enable row level security;

create policy "Users can manage deployments of their projects" on public.deployments 
  using (
    exists (
      select 1 from public.projects
      join public.organizations on projects.org_id = organizations.id
      where projects.id = deployments.project_id and organizations.owner_id = auth.uid()
    )
  );

create policy "Anyone can view deployments" on public.deployments 
  for select using (true);

-- Create custom domains table
create table public.custom_domains (
  id uuid default gen_random_uuid() primary key,
  project_id uuid references public.projects(id) on delete cascade not null,
  hostname text not null unique,
  verified boolean default false not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on custom domains
alter table public.custom_domains enable row level security;

create policy "Users can manage custom domains of their projects" on public.custom_domains 
  using (
    exists (
      select 1 from public.projects
      join public.organizations on projects.org_id = organizations.id
      where projects.id = custom_domains.project_id and organizations.owner_id = auth.uid()
    )
  );

create policy "Anyone can view custom domains" on public.custom_domains 
  for select using (true);
