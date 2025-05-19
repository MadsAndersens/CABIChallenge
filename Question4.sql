-- Question 4
 --- Construct some fairly basic metrics on the agents(assigned_to)
with won_cases as(
	select 
		assigned_to,
		count(*) as won_cases_count
	from cases
	where status = 'Won'
	group by assigned_to
),
lost_cases as (
	select 
		assigned_to,
		count(*) as lost_cases_count
	from cases
	where status = 'Lost'
	group by assigned_to
),
total_cases as (
	select
		assigned_to,
		count(*) as total_cases_count
	from cases
	group by assigned_to
),
resolve_time as (
	select
		assigned_to,
		justify_interval(Avg(time_to_close)::interval) as avg_resolve_time
	from(
		select
			c.assigned_to,
			case 
				when c.status = 'Won' then cwe.occurred_at - coe.occurred_at
				when c.status = 'Lost' then cle.occurred_at - coe.occurred_at
			end as time_to_close
		from public.cases as c
		left join public.case_opened_events as coe on coe.case_id = c.case_id
		left join public.case_won_events as cwe on cwe.case_id = c.case_id
		left join public.case_lost_events as cle on cle.case_id = c.case_id
		where c.status in ('Won','Lost') -- Since we do no count the currently open cases
		)
	group by assigned_to
),
formatted_table as (
	select
		won_cases.assigned_to,
		won_cases_count,
		lost_cases_count,
		total_cases_count,
		cast(won_cases_count as float) / total_cases_count as win_frequency,
		avg_resolve_time
	from won_cases
	join lost_cases on won_cases.assigned_to = lost_cases.assigned_to
	join total_cases on total_cases.assigned_to = won_cases.assigned_to
	join resolve_time on resolve_time.assigned_to = won_cases.assigned_to
)
select
	assigned_to,
	won_cases_count,
	lost_cases_count,
	total_cases_count,
	win_frequency as win_frequency,
	avg_resolve_time
from formatted_table;


--- Sub Question 2
-- Now analyze the metrics from above over time
with created_month_year as(
	select 
		case_id,
		TO_CHAR(creation_date, 'MM-YYYY') AS month_year
	from cases
),
won_cases as(
	select 
		assigned_to,
		month_year,
		count(*) as won_cases
	from cases
	join created_month_year as cmy on cmy.case_id = cases.case_id
	where status = 'Won'
	group by assigned_to, month_year
),
lost_cases as (
	select 
		assigned_to,
		month_year,
		count(*) as lost_cases
	from cases
	join created_month_year as cmy on cmy.case_id = cases.case_id
	where status = 'Lost'
	group by assigned_to,month_year
),
total_cases as (
	select
		assigned_to,
		month_year,
		count(*) as total_cases
	from cases
	join created_month_year as cmy on cmy.case_id = cases.case_id
	group by assigned_to, month_year
),
per_case_resolve_time as (
	select
		c.assigned_to,
		c.case_id,
		case 
			when c.status = 'Won' then cwe.occurred_at - coe.occurred_at
			when c.status = 'Lost' then cle.occurred_at - coe.occurred_at
		end as time_to_close
	from public.cases as c
	left join public.case_opened_events as coe on coe.case_id = c.case_id
	left join public.case_won_events as cwe on cwe.case_id = c.case_id
	left join public.case_lost_events as cle on cle.case_id = c.case_id
	where c.status in ('Won','Lost') -- Since we do no count the currently open cases
),
resolve_time as (
	select
		assigned_to,
		month_year,
		justify_interval(Avg(time_to_close)::interval) as avg_resolve_time
	from per_case_resolve_time
	join created_month_year on created_month_year.case_id = per_case_resolve_time.case_id
	group by assigned_to,month_year
)
select
	won_cases.assigned_to,
	won_cases.month_year,
	won_cases,
	lost_cases,
	total_cases,
	cast(won_cases as float) / total_cases as win_frequency,
	avg_resolve_time
from won_cases
join lost_cases on won_cases.assigned_to = lost_cases.assigned_to and lost_cases.month_year = won_cases.month_year
join total_cases on total_cases.assigned_to = won_cases.assigned_to and total_cases.month_year = won_cases.month_year
join resolve_time on resolve_time.assigned_to = won_cases.assigned_to and resolve_time.month_year = won_cases.month_year
order by assigned_to, month_year