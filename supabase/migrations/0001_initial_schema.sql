create extension if not exists pgcrypto;
create extension if not exists postgis;

create type public.user_role as enum ('user', 'trusted_contact', 'admin');
create type public.privacy_mode as enum ('standard', 'discreet');
create type public.invitation_status as enum ('pending', 'accepted', 'declined', 'revoked');
create type public.alert_type as enum ('immediate_danger', 'being_followed', 'domestic_violence', 'need_accompaniment', 'medical_emergency', 'other');
create type public.alert_status as enum ('active', 'acknowledged', 'closed', 'expired', 'cancelled');
create type public.location_status as enum ('captured', 'location_denied', 'location_unavailable', 'pending_sync');
create type public.delivery_status as enum ('pending', 'sent', 'delivered', 'failed');
create type public.response_status as enum ('none', 'acknowledged', 'watching', 'help_called');
create type public.support_point_category as enum ('police_station', 'specialized_police_station', 'hospital', 'health_unit', 'support_center', 'shelter', 'public_defender', 'other');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null check (char_length(full_name) between 2 and 160),
  phone text not null check (char_length(phone) between 8 and 32),
  avatar_url text,
  role public.user_role not null default 'user',
  emergency_pin_hash text,
  privacy_mode public.privacy_mode not null default 'standard',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.trusted_contacts (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null references public.profiles(id) on delete cascade,
  contact_user_id uuid references public.profiles(id) on delete set null,
  name text not null check (char_length(name) between 2 and 160),
  email text,
  phone text not null check (char_length(phone) between 8 and 32),
  relationship text not null,
  invitation_status public.invitation_status not null default 'pending',
  can_view_exact_location boolean not null default false,
  is_primary boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (owner_user_id <> contact_user_id)
);

create unique index trusted_contacts_one_primary_per_owner
  on public.trusted_contacts(owner_user_id)
  where is_primary;
create index trusted_contacts_owner_idx on public.trusted_contacts(owner_user_id);
create index trusted_contacts_contact_user_idx on public.trusted_contacts(contact_user_id);
create unique index trusted_contacts_owner_phone_idx on public.trusted_contacts(owner_user_id, phone);

create table public.emergency_alerts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  client_request_id uuid not null,
  alert_type public.alert_type not null default 'immediate_danger',
  status public.alert_status not null default 'active',
  is_silent boolean not null default false,
  location_status public.location_status not null default 'location_unavailable',
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  end_reason text,
  public_visibility boolean not null default true,
  public_latitude double precision,
  public_longitude double precision,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, client_request_id),
  check ((ended_at is null and status in ('active', 'acknowledged')) or (ended_at is not null and status in ('closed', 'expired', 'cancelled'))),
  check ((public_latitude is null and public_longitude is null) or (public_latitude between -90 and 90 and public_longitude between -180 and 180))
);

create index emergency_alerts_user_status_idx on public.emergency_alerts(user_id, status);
create index emergency_alerts_status_started_idx on public.emergency_alerts(status, started_at desc);
create index emergency_alerts_public_geo_idx on public.emergency_alerts using gist (st_setsrid(st_makepoint(public_longitude, public_latitude), 4326)) where public_visibility and public_latitude is not null and public_longitude is not null;

create table public.alert_locations (
  id uuid primary key default gen_random_uuid(),
  alert_id uuid not null references public.emergency_alerts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  accuracy double precision not null check (accuracy >= 0),
  altitude double precision,
  source text not null,
  captured_at timestamptz not null,
  created_at timestamptz not null default now()
);

create index alert_locations_alert_captured_idx on public.alert_locations(alert_id, captured_at desc);
create index alert_locations_user_idx on public.alert_locations(user_id);
create index alert_locations_geo_idx on public.alert_locations using gist (st_setsrid(st_makepoint(longitude, latitude), 4326));

create table public.alert_recipients (
  id uuid primary key default gen_random_uuid(),
  alert_id uuid not null references public.emergency_alerts(id) on delete cascade,
  trusted_contact_id uuid not null references public.trusted_contacts(id) on delete cascade,
  delivery_status public.delivery_status not null default 'pending',
  acknowledged_at timestamptz,
  response_status public.response_status not null default 'none',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (alert_id, trusted_contact_id)
);

create index alert_recipients_alert_idx on public.alert_recipients(alert_id);
create index alert_recipients_contact_idx on public.alert_recipients(trusted_contact_id);

create table public.tracking_links (
  id uuid primary key default gen_random_uuid(),
  alert_id uuid not null references public.emergency_alerts(id) on delete cascade,
  trusted_contact_id uuid references public.trusted_contacts(id) on delete cascade,
  token_hash text not null unique,
  expires_at timestamptz not null,
  revoked_at timestamptz,
  created_at timestamptz not null default now(),
  check (expires_at > created_at)
);

create index tracking_links_alert_idx on public.tracking_links(alert_id);

create table public.support_points (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category public.support_point_category not null,
  description text,
  address text not null,
  city text not null,
  state text not null check (char_length(state) between 2 and 32),
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  phone text,
  opening_hours text,
  website text,
  accessibility_info text,
  is_verified boolean not null default false,
  verified_at timestamptz,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index support_points_city_state_idx on public.support_points(city, state);
create index support_points_geo_idx on public.support_points using gist (st_setsrid(st_makepoint(longitude, latitude), 4326));

create table public.safety_contents (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  summary text not null,
  content text not null,
  category text not null,
  is_published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.emergency_services (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text not null,
  description text not null,
  region text not null default 'BR',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (name, region)
);

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid references public.profiles(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index audit_logs_actor_idx on public.audit_logs(actor_user_id, created_at desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_updated_at before update on public.profiles for each row execute function public.set_updated_at();
create trigger trusted_contacts_updated_at before update on public.trusted_contacts for each row execute function public.set_updated_at();
create trigger emergency_alerts_updated_at before update on public.emergency_alerts for each row execute function public.set_updated_at();
create trigger alert_recipients_updated_at before update on public.alert_recipients for each row execute function public.set_updated_at();
create trigger support_points_updated_at before update on public.support_points for each row execute function public.set_updated_at();
create trigger safety_contents_updated_at before update on public.safety_contents for each row execute function public.set_updated_at();
create trigger emergency_services_updated_at before update on public.emergency_services for each row execute function public.set_updated_at();

create or replace function public.current_user_role()
returns public.user_role
language sql
security definer
set search_path = public
stable
as $$
  select coalesce((select role from public.profiles where id = auth.uid()), 'user'::public.user_role);
$$;

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select public.current_user_role() = 'admin'::public.user_role;
$$;

create or replace function public.prevent_frontend_admin_escalation()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.role() = 'authenticated' and new.role is distinct from old.role and not public.is_admin() then
    raise exception 'role_change_not_allowed';
  end if;
  return new;
end;
$$;

create trigger profiles_prevent_role_escalation before update on public.profiles for each row execute function public.prevent_frontend_admin_escalation();

create or replace function public.approximate_coordinate(value double precision, precision_digits integer default 3)
returns double precision
language sql
immutable
as $$
  select round(value::numeric, precision_digits)::double precision;
$$;

create or replace function public.user_can_view_exact_alert(target_alert_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.emergency_alerts alert
    where alert.id = target_alert_id
      and alert.user_id = auth.uid()
  )
  or exists (
    select 1
    from public.emergency_alerts alert
    join public.alert_recipients recipient on recipient.alert_id = alert.id
    join public.trusted_contacts contact on contact.id = recipient.trusted_contact_id
    where alert.id = target_alert_id
      and alert.status in ('active', 'acknowledged')
      and contact.contact_user_id = auth.uid()
      and contact.invitation_status = 'accepted'
      and contact.can_view_exact_location
  );
$$;

create or replace function public.get_public_alerts_in_bounds(
  south double precision,
  west double precision,
  north double precision,
  east double precision,
  max_rows integer default 100
)
returns table (
  id uuid,
  alert_type public.alert_type,
  status public.alert_status,
  latitude double precision,
  longitude double precision,
  radius_meters integer,
  started_at timestamptz
)
language sql
security definer
set search_path = public
stable
as $$
  select
    alert.id,
    alert.alert_type,
    alert.status,
    alert.public_latitude,
    alert.public_longitude,
    500 as radius_meters,
    date_trunc('minute', alert.started_at) as started_at
  from public.emergency_alerts alert
  where alert.public_visibility
    and alert.status in ('active', 'acknowledged')
    and alert.public_latitude between south and north
    and alert.public_longitude between west and east
  order by alert.started_at desc
  limit least(greatest(max_rows, 1), 100);
$$;

create or replace function public.admin_dashboard_metrics()
returns table (
  total_alerts integer,
  active_alerts integer,
  closed_alerts integer,
  verified_support_points integer
)
language sql
security definer
set search_path = public
stable
as $$
  select
    count(*)::integer,
    count(*) filter (where status in ('active', 'acknowledged'))::integer,
    count(*) filter (where status = 'closed')::integer,
    (select count(*)::integer from public.support_points where is_verified)
  from public.emergency_alerts
  where public.is_admin();
$$;

alter table public.profiles enable row level security;
alter table public.trusted_contacts enable row level security;
alter table public.emergency_alerts enable row level security;
alter table public.alert_locations enable row level security;
alter table public.alert_recipients enable row level security;
alter table public.tracking_links enable row level security;
alter table public.support_points enable row level security;
alter table public.safety_contents enable row level security;
alter table public.emergency_services enable row level security;
alter table public.audit_logs enable row level security;

create policy profiles_select_own on public.profiles for select using (id = auth.uid() or public.is_admin());
create policy profiles_insert_own on public.profiles for insert with check (id = auth.uid() and role = 'user');
create policy profiles_update_own on public.profiles for update using (id = auth.uid()) with check (id = auth.uid());

create policy trusted_contacts_owner_crud on public.trusted_contacts for all using (owner_user_id = auth.uid()) with check (owner_user_id = auth.uid());
create policy trusted_contacts_contact_read on public.trusted_contacts for select using (contact_user_id = auth.uid());
create policy trusted_contacts_contact_update_status on public.trusted_contacts for update using (contact_user_id = auth.uid()) with check (contact_user_id = auth.uid());

create policy emergency_alerts_owner_read on public.emergency_alerts for select using (user_id = auth.uid() or public.is_admin());
create policy emergency_alerts_owner_insert on public.emergency_alerts for insert with check (user_id = auth.uid());
create policy emergency_alerts_owner_update on public.emergency_alerts for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy emergency_alerts_contact_read on public.emergency_alerts for select using (
  exists (
    select 1
    from public.alert_recipients recipient
    join public.trusted_contacts contact on contact.id = recipient.trusted_contact_id
    where recipient.alert_id = emergency_alerts.id
      and contact.contact_user_id = auth.uid()
      and contact.invitation_status = 'accepted'
  )
);

create policy alert_locations_owner_insert on public.alert_locations for insert with check (user_id = auth.uid());
create policy alert_locations_exact_read_authorized on public.alert_locations for select using (public.user_can_view_exact_alert(alert_id));

create policy alert_recipients_owner_read on public.alert_recipients for select using (
  exists (select 1 from public.emergency_alerts alert where alert.id = alert_id and alert.user_id = auth.uid())
);
create policy alert_recipients_contact_read on public.alert_recipients for select using (
  exists (
    select 1 from public.trusted_contacts contact
    where contact.id = trusted_contact_id and contact.contact_user_id = auth.uid()
  )
);
create policy alert_recipients_contact_update on public.alert_recipients for update using (
  exists (
    select 1 from public.trusted_contacts contact
    where contact.id = trusted_contact_id and contact.contact_user_id = auth.uid()
  )
) with check (
  exists (
    select 1 from public.trusted_contacts contact
    where contact.id = trusted_contact_id and contact.contact_user_id = auth.uid()
  )
);

create policy tracking_links_owner_read on public.tracking_links for select using (
  exists (select 1 from public.emergency_alerts alert where alert.id = alert_id and alert.user_id = auth.uid())
);

create policy support_points_public_read on public.support_points for select using (true);
create policy support_points_admin_all on public.support_points for all using (public.is_admin()) with check (public.is_admin());

create policy safety_contents_public_published on public.safety_contents for select using (is_published or public.is_admin());
create policy safety_contents_admin_all on public.safety_contents for all using (public.is_admin()) with check (public.is_admin());

create policy emergency_services_public_active on public.emergency_services for select using (is_active or public.is_admin());
create policy emergency_services_admin_all on public.emergency_services for all using (public.is_admin()) with check (public.is_admin());

create policy audit_logs_admin_read on public.audit_logs for select using (public.is_admin());
