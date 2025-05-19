-- Partition the customers into the 3 groups. 
WITH client_values AS (
    SELECT 
        c.client_id,
        client_name,
        SUM(c.case_value) AS client_value
    FROM public.cases AS c
    JOIN public.clients ON public.clients.client_id = c.client_id
    WHERE c.status = 'Won'
    GROUP BY c.client_id, client_name
),
ranked_clients AS (
    SELECT *,
           NTILE(3) OVER (ORDER BY client_value DESC) AS value_group -- Use the Ntile for grouping based on their value
    FROM client_values
)
SELECT 
    client_id,
    client_name,
    client_value,
    CASE -- conditional based on the previous view: 
        WHEN value_group = 1 THEN 'High'
        WHEN value_group = 2 THEN 'Medium'
        WHEN value_group = 3 THEN 'Low'
    END AS CLTV_group
FROM ranked_clients;


-- Predicting future value. 
-- to make take the temporal relevane of cases into account we crete a recency rank and use that to make
-- a weighted avg. with negative exponetial decaying weights which will then be our simplified prediction. 
WITH won_cases AS (
    SELECT 
        c.client_id,
        client_name,
        case_value,
        cwe.occurred_at
    FROM public.cases AS c
    JOIN public.clients ON public.clients.client_id = c.client_id
    JOIN public.case_won_events AS cwe ON cwe.case_id = c.case_id
    WHERE c.status = 'Won'
),
recency_cases AS (
    SELECT
        client_id,
        client_name,
        case_value,
        occurred_at,
        RANK() OVER (PARTITION BY client_id ORDER BY occurred_at DESC) AS recency_rank -- this is the inital weigth
    FROM won_cases
),
weighted_values AS (
    SELECT
        client_id,
        client_name,
        case_value,
        recency_rank,
        EXP(-0.5 * (recency_rank - 1)) AS weight, -- Exponential transform of the weight
        case_value * EXP(-0.5 * (recency_rank - 1)) AS weighted_value -- get the weighted value
    FROM recency_cases
),
final_weighted_avg AS (
    SELECT
        client_id,
        client_name,
        round(SUM(weighted_value) / SUM(weight),2) AS weighted_avg_case_value -- gets the weighted average
    FROM weighted_values
    GROUP BY client_id, client_name
)
SELECT
	*
FROM final_weighted_avg
ORDER BY weighted_avg_case_value DESC;



