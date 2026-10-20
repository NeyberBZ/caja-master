-- CajaMaster initial schema.
-- Review project target before executing. Only caja_* tables are created.
create extension if not exists pgcrypto;

create table if not exists public.caja_sessions (
  id uuid primary key default gen_random_uuid(),
  opened_by uuid references auth.users(id) on delete set null,
  opened_at timestamptz not null default now(),
  opening_fund numeric(12,2) not null default 0 check (opening_fund >= 0),
  closed_at timestamptz,
  expected_cash numeric(12,2),
  counted_cash numeric(12,2),
  difference numeric(12,2),
  status text not null default 'open' check (status in ('open','closed')),
  notes text,
  created_at timestamptz not null default now(),
  check ((status = 'open' and closed_at is null) or (status = 'closed' and closed_at is not null))
);

create table if not exists public.caja_movements (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.caja_sessions(id) on delete cascade,
  created_by uuid references auth.users(id) on delete set null,
  movement_type text not null check (movement_type in ('sale','expense')),
  amount numeric(12,2) not null check (amount > 0),
  description text not null check (length(trim(description)) between 1 and 160),
  payment_method text not null check (payment_method in ('cash','yape','plin','card','transfer')),
  category text,
  created_at timestamptz not null default now()
);

create index if not exists caja_sessions_opened_at_idx on public.caja_sessions (opened_at desc);
create index if not exists caja_movements_session_created_idx on public.caja_movements (session_id, created_at desc);

alter table public.caja_sessions enable row level security;
alter table public.caja_movements enable row level security;

-- Intentionally closed by default: no anon/authenticated policies yet.
-- Add owner/operator policies only after choosing the app's authentication model.
revoke all on public.caja_sessions from anon, authenticated;
revoke all on public.caja_movements from anon, authenticated;
grant select, insert, update, delete on public.caja_sessions to authenticated;
grant select, insert, update, delete on public.caja_movements to authenticated;

comment on table public.caja_sessions is 'CajaMaster: apertura, arqueo y cierre diario.';
comment on table public.caja_movements is 'CajaMaster: ventas y egresos de cada sesión.';
