-- ZenOps: functions.sql
create or replace function public.assign_role_and_profile(p_user_id uuid,p_role_id uuid,p_profile_id uuid)
returns void language plpgsql security definer as $$
begin
  update public.users set role_id = p_role_id, profile_id = p_profile_id, updated_at = now() where id = p_user_id;
end;
$$;

create or replace function public.send_proposal(proposal_id uuid)
returns void language plpgsql security definer as $$
begin
  update public.proposals set status = 'sent', sent_at = now(), updated_at = now() where id = proposal_id;
end;
$$;
