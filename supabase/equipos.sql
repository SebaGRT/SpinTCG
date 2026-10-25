create table public.equipos (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid()
    references auth.users (id) on delete cascade,
  nombre text not null check (char_length(trim(nombre)) between 1 and 24),
  cartas text[] not null check (cardinality(cartas) = 3),
  creado timestamptz not null default now()
);

alter table public.equipos enable row level security;

create policy "Ver mis equipos" on public.equipos
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "Crear mis equipos" on public.equipos
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Editar mis equipos" on public.equipos
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Borrar mis equipos" on public.equipos
  for delete to authenticated
  using ((select auth.uid()) = user_id);

grant select, insert, update, delete on public.equipos to authenticated;
