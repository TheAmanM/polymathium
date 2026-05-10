create or replace function private.sync_auth_user_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, primary_email)
  values (new.id, new.email)
  on conflict (id) do update
    set primary_email = excluded.primary_email,
        updated_at = timezone('utc', now());

  return new;
end;
$$;

create or replace function private.sync_auth_user_update()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.users
     set primary_email = new.email,
         updated_at = timezone('utc', now())
   where id = new.id;

  return new;
end;
$$;
