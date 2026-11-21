-- Casa de vânzări: schema bazei de date Supabase.
-- Se rulează o singură dată: Supabase → SQL Editor → New query → lipești tot fișierul → Run.
-- Poate fi rulat din nou fără să strice datele (folosește "if not exists" / "or replace").

-- ============ TABELE ============

-- Nomenclatorul: îl încarcă administratorul din Excel; îl citește oricine (modul „Verificare preț”).
create table if not exists public.products (
  code        text primary key,                       -- cod de bare
  sku         text not null default '',               -- articol
  name        text not null,                          -- denumire
  price       numeric(12,2) not null default 0,       -- preț
  disc        numeric(5,2)  not null default 0 check (disc between 0 and 100), -- reducere %
  updated_at  timestamptz   not null default now()
);

-- Utilizatorii aplicației: se creează automat când adaugi un utilizator în Authentication.
create table if not exists public.profiles (
  id      uuid primary key references auth.users on delete cascade,
  name    text not null,
  role    text not null default 'seller' check (role in ('admin','seller')),  -- admin = tu, seller = vânzător
  active  boolean not null default true                                       -- false = nu mai poate vinde
);

-- Vânzările (bonurile). Nu se pot modifica sau șterge din aplicație.
create table if not exists public.sales (
  id           bigint generated always as identity primary key,  -- nr. bon
  created_at   timestamptz not null default now(),
  seller_id    uuid not null default auth.uid() references auth.users,
  seller_name  text,
  pay          text not null check (pay in ('numerar','card')),
  gross        numeric(12,2) not null,   -- sumă fără reducere
  discount     numeric(12,2) not null,   -- reducere
  total        numeric(12,2) not null,   -- sumă cu reducere
  items        jsonb not null            -- produsele din bon
);
create index if not exists sales_created_at_idx on public.sales (created_at);

-- ============ FUNCȚII AJUTĂTOARE ============

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'admin' and active);
$$;

create or replace function public.is_seller() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and active);
$$;

-- Profil automat pentru fiecare utilizator nou (nume = partea dinainte de @).
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, name) values (new.id, split_part(new.email, '@', 1))
  on conflict (id) do nothing;
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- La fiecare vânzare: vânzătorul e cel logat (nu se poate falsifica), ora e a serverului
-- (sau ora vânzării făcute offline, dacă e din ultimele 7 zile).
create or replace function public.sales_before_insert() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  new.seller_id := auth.uid();
  new.seller_name := (select name from public.profiles where id = auth.uid());
  if new.created_at is null or new.created_at > now() + interval '5 minutes'
     or new.created_at < now() - interval '7 days' then
    new.created_at := now();
  end if;
  return new;
end $$;
drop trigger if exists sales_bi on public.sales;
create trigger sales_bi before insert on public.sales
  for each row execute function public.sales_before_insert();

-- Încărcarea nomenclatorului (doar admin). replace = true șterge întâi tot catalogul.
create or replace function public.load_products(items jsonb, replace boolean default true) returns integer
language plpgsql security definer set search_path = public as $$
declare n integer;
begin
  if not public.is_admin() then
    raise exception 'Doar administratorul poate încărca nomenclatorul';
  end if;
  if replace then
    delete from public.products where true;
  end if;
  insert into public.products (code, sku, name, price, disc, updated_at)
  select x->>'code', coalesce(x->>'sku', ''), x->>'name',
         coalesce((x->>'price')::numeric, 0), coalesce((x->>'disc')::numeric, 0), now()
  from jsonb_array_elements(items) as x
  where coalesce(x->>'code', '') <> '' and coalesce(x->>'name', '') <> ''
  on conflict (code) do update
    set sku = excluded.sku, name = excluded.name, price = excluded.price,
        disc = excluded.disc, updated_at = now();
  get diagnostics n = row_count;
  return n;
end $$;

-- ============ REGULI DE ACCES (RLS) ============

alter table public.products enable row level security;
alter table public.profiles enable row level security;
alter table public.sales    enable row level security;

drop policy if exists "produse: citire publica" on public.products;
create policy "produse: citire publica" on public.products for select using (true);
drop policy if exists "produse: admin adauga" on public.products;
create policy "produse: admin adauga" on public.products for insert to authenticated with check (public.is_admin());
drop policy if exists "produse: admin modifica" on public.products;
create policy "produse: admin modifica" on public.products for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "produse: admin sterge" on public.products;
create policy "produse: admin sterge" on public.products for delete to authenticated using (public.is_admin());

drop policy if exists "profil: propriu sau admin" on public.profiles;
create policy "profil: propriu sau admin" on public.profiles for select to authenticated using (id = auth.uid() or public.is_admin());
drop policy if exists "profil: admin modifica" on public.profiles;
create policy "profil: admin modifica" on public.profiles for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "vanzari: vanzator adauga" on public.sales;
create policy "vanzari: vanzator adauga" on public.sales for insert to authenticated with check (public.is_seller());
drop policy if exists "vanzari: ale mele sau admin" on public.sales;
create policy "vanzari: ale mele sau admin" on public.sales for select to authenticated using (seller_id = auth.uid() or public.is_admin());

-- Drepturi pentru API (anon = fără login, authenticated = logat).
grant usage on schema public to anon, authenticated;
grant select on public.products to anon, authenticated;
grant insert, update, delete on public.products to authenticated;
grant select, update on public.profiles to authenticated;
grant select, insert on public.sales to authenticated;
revoke execute on function public.load_products(jsonb, boolean) from public, anon;
grant execute on function public.load_products(jsonb, boolean) to authenticated;
grant execute on function public.is_admin(), public.is_seller() to anon, authenticated;
