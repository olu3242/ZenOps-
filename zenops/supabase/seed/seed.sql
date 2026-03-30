-- ZenOps: seed.sql
create unique index if not exists uq_profiles_system_name on public.profiles (name) where organization_id is null and is_system = true;
create unique index if not exists uq_permission_sets_system_name on public.permission_sets (name) where organization_id is null;
insert into public.profiles (organization_id, name, description, is_system, object_permissions, field_permissions)
values
  (null,'Owner Admin','Full admin access',true,'{"all":{"create":true,"read":true,"update":true,"delete":true}}'::jsonb,'{}'::jsonb),
  (null,'Operations Manager','Operations management access',true,'{"leads":{"create":true,"read":true,"update":true,"delete":false},"opportunities":{"create":true,"read":true,"update":true,"delete":false}}'::jsonb,'{}'::jsonb),
  (null,'Intake Rep','Lead and scheduling access',true,'{"leads":{"create":true,"read":true,"update":true,"delete":false},"contacts":{"create":true,"read":true,"update":true,"delete":false},"appointments":{"create":true,"read":true,"update":true,"delete":false}}'::jsonb,'{"campaigns.budget_amount":{"read":false,"update":false},"revenue_events.amount":{"read":false,"update":false}}'::jsonb),
  (null,'Sales Rep','Sales pipeline and proposal access',true,'{"opportunities":{"create":true,"read":true,"update":true,"delete":false},"proposals":{"create":true,"read":true,"update":true,"delete":false}}'::jsonb,'{}'::jsonb),
  (null,'Marketing Analyst','Campaign and attribution read access',true,'{"campaigns":{"create":true,"read":true,"update":true,"delete":false},"lead_sources":{"create":true,"read":true,"update":true,"delete":false}}'::jsonb,'{"revenue_events.amount":{"read":true,"update":false}}'::jsonb),
  (null,'Provider','Appointment and customer summary access',true,'{"appointments":{"create":false,"read":true,"update":true,"delete":false},"contacts":{"create":false,"read":true,"update":false,"delete":false}}'::jsonb,'{}'::jsonb),
  (null,'Read Only Executive','Dashboard and report access only',true,'{"dashboard":{"create":false,"read":true,"update":false,"delete":false}}'::jsonb,'{}'::jsonb)
on conflict do nothing;
insert into public.permission_sets (organization_id, name, description, permissions_json, is_active)
values
  (null,'manage_automations','Can manage automation rules','{"manage_automations":true}'::jsonb,true),
  (null,'export_revenue_reports','Can export revenue data','{"export_revenue_reports":true,"view_revenue":true}'::jsonb,true),
  (null,'manage_integrations','Can manage integrations','{"manage_integrations":true}'::jsonb,true),
  (null,'view_all_conversations','Can view all conversations','{"view_all_conversations":true}'::jsonb,true),
  (null,'manage_users','Can manage users and access','{"manage_users":true,"view_audit_logs":true}'::jsonb,true),
  (null,'manage_custom_fields','Can manage custom fields','{"manage_custom_fields":true}'::jsonb,true),
  (null,'view_all_leads','Can view all leads','{"view_all_leads":true}'::jsonb,true),
  (null,'view_all_tasks','Can view all tasks','{"view_all_tasks":true}'::jsonb,true),
  (null,'view_all_opportunities','Can view all opportunities','{"view_all_opportunities":true}'::jsonb,true),
  (null,'manage_revenue','Can manage revenue events','{"manage_revenue":true,"view_revenue":true}'::jsonb,true)
on conflict do nothing;
