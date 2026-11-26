-- CampConnect — Slice 1: Auth + profiles (Supabase)
-- Run in the Supabase dashboard: SQL Editor -> paste -> Run.
-- Same Supabase project as the MAD practical ("first-mad") by the user's
-- choice. These tables do NOT collide with the practical's `users` table.
-- Run this file ONCE. It is idempotent where marked (IF NOT EXISTS /
-- DROP ... IF EXISTS), so re-running it after a fix is safe.

-- ---------------------------------------------------------------------------
-- Helper: is the signed-in user an admin?
-- SECURITY DEFINER so the check itself is not blocked by RLS (a policy that
-- queries `profiles` directly would recurse). Used by admin_activity policies
-- and the role-escalation guard below.
-- ---------------------------------------------------------------------------
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- ---------------------------------------------------------------------------
-- profiles — one row per auth user, id = auth.users.id
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null unique,
  full_name text not null default '',
  cms_id text unique,
  role text not null default 'student'
    check (role in ('student', 'senior', 'alumni', 'admin')),
  program text default '',
  semester text default '',
  location text default '',
  bio text default '',
  university text default '',
  department text default '',
  academic_session text default '',
  cgpa text default '',
  skills text[] not null default '{}',
  interests text[] not null default '{}',
  account_status text not null default 'active'
    check (account_status in ('active', 'suspended')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Keep updated_at fresh.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Nobody may promote themselves: only an admin may change `role`.
-- (auth.uid() IS NULL means the change comes from the dashboard SQL Editor
-- or a service key, not from an app user — allow that, so the very first
-- admin can be promoted with the UPDATE at the bottom of this file.)
create or replace function public.prevent_role_escalation()
returns trigger
language plpgsql
as $$
begin
  if old.role is distinct from new.role
    and auth.uid() is not null
    and not public.is_admin() then
    raise exception 'Only an admin can change a profile role.';
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_prevent_role_escalation on public.profiles;
create trigger profiles_prevent_role_escalation
  before update of role on public.profiles
  for each row execute function public.prevent_role_escalation();

-- Auto-create a profile row on signup, from the metadata the app sends
-- (signUp data: full_name, cms_id). Runs as the trigger owner, so RLS
-- does not block it.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into public.profiles (id, email, full_name, cms_id)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    nullif(new.raw_user_meta_data ->> 'cms_id', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- admin_activity — audit log of admin actions
-- ---------------------------------------------------------------------------
create table if not exists public.admin_activity (
  id uuid primary key default gen_random_uuid(),
  admin_id uuid not null references public.profiles (id) on delete cascade,
  action text not null,
  target_user_id uuid references public.profiles (id) on delete set null,
  details text,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.admin_activity enable row level security;

-- profiles: any signed-in user can read profiles (campus directory,
-- public profiles, alumni list). Anonymous users read nothing.
drop policy if exists "Profiles readable by signed-in users" on public.profiles;
create policy "Profiles readable by signed-in users"
  on public.profiles for select to authenticated using (true);

-- profiles: a user can create only their own row (id = their auth id).
drop policy if exists "Users can insert their own profile" on public.profiles;
create policy "Users can insert their own profile"
  on public.profiles for insert to authenticated
  with check (auth.uid() = id);

-- profiles: a user can update only their own row. (The trigger above stops
-- non-admins changing `role`.)
drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile"
  on public.profiles for update to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- No delete policy on profiles: rows are removed only via the dashboard.

-- admin_activity: only admins can read or write the audit log.
drop policy if exists "Admins can read activity" on public.admin_activity;
create policy "Admins can read activity"
  on public.admin_activity for select to authenticated
  using (public.is_admin());

drop policy if exists "Admins can log activity" on public.admin_activity;
create policy "Admins can log activity"
  on public.admin_activity for insert to authenticated
  with check (public.is_admin() and auth.uid() = admin_id);

-- ---------------------------------------------------------------------------
-- Promoting the first admin (run AFTER that user has signed up once, so
-- their profiles row exists). Replace the email, then run just this line:
-- ---------------------------------------------------------------------------
-- update public.profiles set role = 'admin'
--   where email = 'admin@your-university.edu';
