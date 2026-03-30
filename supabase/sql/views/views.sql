-- ZenOps: views.sql
create or replace view public.v_revenue_by_source as
select sa.organization_id, ls.name as lead_source_name, sum(coalesce(sa.attributed_amount, re.amount * (sa.weight_percent / 100.0))) as revenue_amount
from public.source_attributions sa
join public.lead_sources ls on ls.id = sa.lead_source_id
join public.revenue_events re on re.opportunity_id = sa.opportunity_id
group by sa.organization_id, ls.name;

create or replace view public.v_pipeline_stage_totals as
select o.organization_id, p.name as pipeline_name, ps.name as stage_name, count(*) as opportunity_count, sum(coalesce(o.amount_estimated, 0)) as estimated_amount
from public.opportunities o
join public.pipelines p on p.id = o.pipeline_id
join public.pipeline_stages ps on ps.id = o.current_stage_id
group by o.organization_id, p.name, ps.name;

create or replace view public.v_lead_response_performance as
select l.organization_id, l.id as lead_id, l.created_at, l.first_response_due_at, l.first_response_at,
  case when l.first_response_at is null then null else extract(epoch from (l.first_response_at - l.created_at)) / 60 end as response_minutes
from public.leads l;

create or replace view public.v_campaign_roi as
select c.organization_id, c.id as campaign_id, c.name as campaign_name, c.budget_amount,
  coalesce(sum(sa.attributed_amount), 0) as attributed_revenue,
  case when c.budget_amount is null or c.budget_amount = 0 then null else round(((coalesce(sum(sa.attributed_amount), 0) - c.budget_amount) / c.budget_amount) * 100, 2) end as roi_percent
from public.campaigns c
left join public.source_attributions sa on sa.campaign_id = c.id
group by c.organization_id, c.id, c.name, c.budget_amount;

create or replace view public.v_user_task_load as
select t.organization_id, t.owner_user_id,
  count(*) filter (where t.status = 'open') as open_task_count,
  count(*) filter (where t.status = 'open' and t.due_at < now()) as overdue_task_count
from public.tasks t
group by t.organization_id, t.owner_user_id;
