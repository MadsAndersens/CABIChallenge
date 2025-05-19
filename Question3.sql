-- Question 3 anwer identifying market trends
-- First since we work with time I choose to aggregate on month-year level
WITH created_month_year AS (
    SELECT 
        case_id,
        market,
        status,
		case_value,
        TO_CHAR(creation_date, 'MM-YYYY') AS month_year -- use this to to create a month year column 
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
		-- lag the values so the pct diff can be calculated. 
        LAG(mc.total_case_value) OVER (PARTITION BY mc.market, mc.status ORDER BY mc.month_year) AS prev_case_value,
		LAG(mc.case_count) OVER (PARTITION BY mc.market, mc.status ORDER BY mc.month_year) AS prev_case_count
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
            WHEN prev_case_value > 0 THEN -- this tp handle 0 division errors
                (total_case_value - prev_case_value) * 100.0 / prev_case_value
            ELSE NULL
        END AS pct_growth_case_value,
		CASE 
            WHEN prev_case_count > 0 THEN 
                (case_count - prev_case_count) * 100.0 / prev_case_count
            ELSE NULL
        END AS pct_growth_case_count
    FROM monthly_growth
)
SELECT 
    market,
    status,
    round(AVG(pct_growth_case_value),1) AS avg_monthly_pct_growth_value,
	round(AVG(pct_growth_case_count),1) AS avg_monthly_pct_growth_count,
	SUM(case_count) as total_cases
FROM growth_pct
GROUP BY market, status
ORDER BY market, status;

------ this is just for potentially  seing the trends over the time --- Not as such part of the exercise
-- Over time growth for visual analysis
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
        LAG(mc.total_case_value) OVER (PARTITION BY mc.market, mc.status ORDER BY mc.month_year) AS prev_case_value,
		LAG(mc.case_count) OVER (PARTITION BY mc.market, mc.status ORDER BY mc.month_year) AS prev_case_count
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
        END AS pct_growth_case_value,
		CASE 
            WHEN prev_case_count > 0 THEN 
                (case_count - prev_case_count) * 100.0 / prev_case_count
            ELSE NULL
        END AS pct_growth_case_count
    FROM monthly_growth
)
SELECT 
    market,
    status,
	month_year,
    pct_growth_case_value,
	pct_growth_case_count,
	case_count
FROM growth_pct
ORDER BY market,month_year, status;


------- Test with auto regressive approach------
--- Again not a cocrete part of the exercise but if there had been more data an auto regressive model 
--had probably been a good trend indicator. 

WITH weekly_counts AS (
  SELECT
    market,
    status,
    date_trunc('week', creation_date)::date AS week_start, -- i tried to change to week 
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
  REGR_SLOPE(case_count, prev_week_count) AS ar_weekly_slope, -- this calulates the slop of line
  REGR_INTERCEPT(case_count, prev_week_count) AS ar_weekly_intercept, -- intercept
  REGR_R2(case_count, prev_week_count) AS ar_weekly_r_squared, -- Goodness of fit statistic r2
  COUNT(*) AS weeks_included -- this was for deebuggin 
FROM lagged_counts
WHERE prev_week_count IS NOT NULL
GROUP BY market, status
ORDER BY market, status;
