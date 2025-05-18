-- Question 4

with won_cases as(
	select 
		assigned_to,
		count(*) as won_cases
	from cases
	where status = 'Won'
	group by assigned_to
),
lost_cases as (
	select 
		assigned_to,
		count(*) as lost_cases
	from cases
	where status = 'Lost'
	group by assigned_to
),
total_cases as (
	select
		assigned_to,
		count(*) as total_cases
	from cases
	group by assigned_to
),
resolve_time as (
	select
		c.case_id,
		case 
			when c.status = 'Won' then cwe.occurred_at - coe.occurred_at
			when c.status = 'Lost' then cle.occurred_at - coe.occurred_at
		end as time_to_close
	from public.cases as c
	left join public.case_opened_events as coe on coe.case_id = c.case_id
	left join public.case_won_events as cwe on cwe.case_id = c.case_id
	left join public.case_lost_events as cle on cle.case_id = c.case_id
	where c.status in ('Won','Lost'))
)
select
	won_cases.assigned_to,
	won_cases,
	lost_cases,
	total_cases,
	cast(won_cases as float) / total_cases as win_frequency
from won_cases
join lost_cases on won_cases.assigned_to = lost_cases.assigned_to
join total_cases on total_cases.assigned_to = won_cases.assigned_to