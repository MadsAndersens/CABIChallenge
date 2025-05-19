-- Question 1

-- question 1
-- Use a view to get the conditional time to close based on the case status
-- Use left join since we want to preserve rows from cases even if they dont appear in lost for example then they will exist in won
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
	where c.status in ('Won','Lost')) -- I Assume cases are only closed when they are either won or lost
select
	justify_interval(AVG(time_to_close)::interval)
from closed_case_time


-- Second task
-- The query below finds the maximum case cost per country note to get the single estimate across all outcomment the c.market
-- and the associated group by 
select
	c.market, -- Outcomment this for only the max case, and outcomment group by
	Max(case_value) as max_case_value
from public.cases as c
join public.case_opened_events as coe on coe.case_id = c.case_id
where c.status = 'Won'
GROUP BY c.market -- also this for single number
order by Max(case_value) desc


