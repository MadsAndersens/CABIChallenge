-- Question 3 anwer identifying market trends

select
	market,
	status,
	count(*)
from public.cases
group by market, status
order by market


select
	market, 
	status, 
	case_value,
	occurred_at
from public.cases as c
join public.case_won_events as cwe on cwe.case_id = c.case_id
order by market