-- Question 3 anwer identifying market trends
WITH created_month_year AS (
    SELECT 
        case_id,
        market,
        status,
		case_value,
        TO_CHAR(creation_date, 'MM-YYYY') AS month_year
    FROM cases
),
monthly_counts AS (
    SELECT 
        market,
        status,
        month_year,
		count(*) as case_count,
        sum(case_value) AS total_case_value
    FROM created_month_year
    GROUP BY market, status, month_year
),
monthly_growth AS (
    SELECT 
        mc.market,
        mc.status,
        mc.month_year,
		mc.case_count,
        mc.total_case_value,
        LAG(mc.total_case_value) OVER (PARTITION BY mc.market, mc.status ORDER BY mc.month_year) AS prev_case_value
    FROM monthly_counts mc
),
growth_pct AS (
    SELECT 
        market,
        status,
        month_year,
		case_count,
        total_case_value,
        prev_case_value,
        CASE 
            WHEN prev_case_value > 0 THEN 
                (total_case_value - prev_case_value) * 100.0 / prev_case_value
            ELSE NULL
        END AS pct_growth
    FROM monthly_growth
)
SELECT 
    market,
    status,
    AVG(pct_growth) AS avg_monthly_pct_growth,
	SUM(case_count) as total_cases
FROM growth_pct
GROUP BY market, status
ORDER BY market, status;





-- Over time growth for visual analysis

with created_month_year as(
	select 
		case_id,
		TO_CHAR(creation_date, 'MM-YYYY') AS month_year
	from cases
),











--- Test with auto regressive approach

WITH weekly_counts AS (
  SELECT
    market,
    status,
    date_trunc('week', creation_date)::date AS week_start,
    COUNT(*) AS case_count
  FROM public.cases
  GROUP BY market, status, week_start
),
lagged_counts AS (
  SELECT
    market,
    status,
    week_start,
    case_count,
    LAG(case_count) OVER (
      PARTITION BY market, status
      ORDER BY week_start
    ) AS prev_week_count
  FROM weekly_counts
)
SELECT
  market,
  status,
  REGR_SLOPE(case_count, prev_week_count) AS ar_weekly_slope,
  REGR_INTERCEPT(case_count, prev_week_count) AS ar_weekly_intercept,
  REGR_R2(case_count, prev_week_count) AS ar_weekly_r_squared,
  COUNT(*) AS weeks_included
FROM lagged_counts
WHERE prev_week_count IS NOT NULL
GROUP BY market, status
ORDER BY market, status;
