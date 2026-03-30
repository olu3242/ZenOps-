-- ZenOps: 003_security_access.sql

create or replace function public.current_user_id() returns uuid language sql stable as $$ select auth.uid(); $$;
create or replace function public.current_user_organization_id() returns uuid language sql stable as $$ select u.organization_id from public.users u where u.id = auth.uid(); $$;
create or replace function public.current_user_role_id() returns uuid language sql stable as $$ select u.role_id from public.users u where u.id = auth.uid(); $$;
create or replace function public.current_user_profile_id() returns uuid language sql stable as $$ select u.profile_id from public.users u where u.id = auth.uid(); $$;
create or replace function public.is_org_owner() returns boolean language sql stable as $$
  select exists (
    select 1 from public.organizations o
    where o.id = public.current_user_organization_id() and o.owner_user_id = auth.uid()
  );
$$;
create or replace function public.has_permission(permission_key text) returns boolean language sql stable as $$
  select exists (
    select 1
    from public.user_permission_assignments upa
    join public.permission_sets ps on ps.id = upa.permission_set_id
    where upa.user_id = auth.uid()
      and coalesce((ps.permissions_json ->> permission_key)::boolean, false) = true
  ) or public.is_org_owner();
$$;
create or replace function public.can_view_team_record(record_team_id uuid) returns boolean language sql stable as $$
  select case
    when public.is_org_owner() then true
    when record_team_id is null then false
    else exists (
      select 1
      from public.users u
      join public.roles r on r.id = u.role_id
      where u.id = auth.uid() and u.team_id = record_team_id and r.can_view_team_records = true
    )
  end;
$$;
create or replace function public.log_audit_event(
  p_organization_id uuid,
  p_user_id uuid,
  p_object_type text,
  p_record_id uuid,
  p_action_type text,
  p_field_name text default null,
  p_old_value_json jsonb default null,
  p_new_value_json jsonb default null,
  p_context_json jsonb default '{}'::jsonb
) returns void language plpgsql security definer as $$
begin
  insert into public.audit_logs (organization_id,user_id,object_type,record_id,action_type,field_name,old_value_json,new_value_json,context_json)
  values (p_organization_id,p_user_id,p_object_type,p_record_id,p_action_type,p_field_name,p_old_value_json,p_new_value_json,p_context_json);
end;
$$;
create or replace function public.handle_new_auth_user() returns trigger language plpgsql security definer as $$
begin
  insert into public.users (id,organization_id,profile_id,role_id,email,first_name,last_name)
  values (
    new.id,
    (new.raw_user_meta_data ->> 'organization_id')::uuid,
    (new.raw_user_meta_data ->> 'profile_id')::uuid,
    (new.raw_user_meta_data ->> 'role_id')::uuid,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'first_name', 'New'),
    coalesce(new.raw_user_meta_data ->> 'last_name', 'User')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_auth_user();
