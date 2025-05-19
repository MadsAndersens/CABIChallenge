-- Question 1

-- First Task
with closed_case_time as (
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
select
	case_id,
	time_to_close
from closed_case_time

-- Second task
select
	c.market,
	Max(case_value)
from public.cases as c
join public.case_opened_events as coe on coe.case_id = c.case_id
where c.status = 'Won'
GROUP BY c.market
order by c.market


