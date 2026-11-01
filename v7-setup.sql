-- Blackstore V7. Ejecutar DESPUÉS de supabase-setup.sql y admin-setup.sql.
create table if not exists public.stores (
 id uuid primary key default gen_random_uuid(), owner_id uuid not null unique references auth.users(id) on delete cascade,
 application_id uuid not null unique references public.vendor_applications(id),
 name text not null, city text not null, category text not null,
 created_at timestamptz not null default now()
);
create table if not exists public.products (
 id uuid primary key default gen_random_uuid(), store_id uuid not null references public.stores(id) on delete cascade,
 name text not null check (char_length(name) between 2 and 100),
 description text not null default '' check (char_length(description)<=1000),
 price numeric(12,2) not null check (price>0),
 image_path text, active boolean not null default true,
 created_at timestamptz not null default now()
);
create index if not exists products_store_idx on public.products(store_id);
alter table public.stores enable row level security;
alter table public.products enable row level security;
revoke all on public.stores, public.products from anon, authenticated;
grant select on public.stores, public.products to anon, authenticated;
grant insert, update, delete on public.products to authenticated;
create policy "public store catalog" on public.stores for select to anon,authenticated using (true);
create policy "public products" on public.products for select to anon,authenticated using (active or exists(select 1 from public.stores s where s.id=store_id and s.owner_id=(select auth.uid())));
create policy "owner insert" on public.products for insert to authenticated with check (exists(select 1 from public.stores s where s.id=store_id and s.owner_id=(select auth.uid())));
create policy "owner update" on public.products for update to authenticated using (exists(select 1 from public.stores s where s.id=store_id and s.owner_id=(select auth.uid()))) with check (exists(select 1 from public.stores s where s.id=store_id and s.owner_id=(select auth.uid())));
create policy "owner delete" on public.products for delete to authenticated using (exists(select 1 from public.stores s where s.id=store_id and s.owner_id=(select auth.uid())));
-- Admin vincula una solicitud aprobada con el correo del usuario registrado.
create or replace function public.admin_activate_store(p_application_id uuid,p_vendor_email text)
returns uuid language plpgsql security definer set search_path='' as $$
declare v_owner uuid; v_app public.vendor_applications%rowtype; v_store uuid;
begin
 if not exists(select 1 from auth.users u where u.id=auth.uid() and u.raw_app_meta_data->>'role'='admin') then raise exception 'Acceso denegado'; end if;
 select * into v_app from public.vendor_applications where id=p_application_id and status='approved';
 if not found then raise exception 'Primero aprueba la solicitud'; end if;
 select id into v_owner from auth.users where lower(email)=lower(trim(p_vendor_email)) and email_confirmed_at is not null;
 if v_owner is null then raise exception 'El vendedor debe registrarse y confirmar su correo'; end if;
 insert into public.stores(owner_id,application_id,name,city,category)
 values(v_owner,v_app.id,v_app.business_name,v_app.city,v_app.category)
 on conflict(application_id) do update set name=excluded.name,city=excluded.city,category=excluded.category
 returning id into v_store;
 return v_store;
end $$;
revoke all on function public.admin_activate_store(uuid,text) from public,anon;
grant execute on function public.admin_activate_store(uuid,text) to authenticated;
-- Almacenamiento: imágenes públicas, escritura restringida a carpeta del dueño.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('blackstore-products','blackstore-products',true,5242880,array['image/jpeg','image/png','image/webp'])
on conflict(id) do update set public=true,file_size_limit=5242880,allowed_mime_types=array['image/jpeg','image/png','image/webp'];
create policy "public product images" on storage.objects for select to public using(bucket_id='blackstore-products');
create policy "vendor upload images" on storage.objects for insert to authenticated
with check(bucket_id='blackstore-products' and (storage.foldername(name))[1]=(select auth.uid())::text
 and exists(select 1 from public.stores where owner_id=(select auth.uid())));
create policy "vendor delete images" on storage.objects for delete to authenticated
using(bucket_id='blackstore-products' and (storage.foldername(name))[1]=(select auth.uid())::text);
