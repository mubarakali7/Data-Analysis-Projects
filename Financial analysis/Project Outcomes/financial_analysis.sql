use financial_analysis;

select * from domestic_credit_private;

select * from interest_rate;

-- Data Cleaning & Transformation (Unpivot)

-- creating views for analysing data and unpivot the tables

-- view for gdp

CREATE VIEW gdp_view AS
SELECT
    country_name,
    country_code,
    'gdp' AS indicator,
    2015 AS year,
    `2015` AS value
FROM gdp
UNION ALL
SELECT country_name, country_code, 'gdp', 2016, `2016` FROM gdp
UNION ALL
SELECT country_name, country_code, 'gdp', 2017, `2017` FROM gdp
UNION ALL
SELECT country_name, country_code, 'gdp', 2018, `2018` FROM gdp
UNION ALL
SELECT country_name, country_code, 'gdp', 2019, `2019` FROM gdp
UNION ALL
SELECT country_name, country_code, 'gdp', 2020, `2020` FROM gdp
UNION ALL
SELECT country_name, country_code, 'gdp', 2021, `2021` FROM gdp
UNION ALL
SELECT country_name, country_code, 'gdp', 2022, `2022` FROM gdp
UNION ALL
SELECT country_name, country_code, 'gdp', 2023, `2023` FROM gdp
UNION ALL
SELECT country_name, country_code, 'gdp', 2024, `2024` FROM gdp;

-- view for domestic_credit_private
CREATE VIEW domestic_credit_private_view AS
SELECT
    country_name,
    country_code,
    'domestic_credit_private' AS indicator,
    2015 AS year,
    `2015` AS value
FROM domestic_credit_private
UNION ALL
SELECT country_name, country_code, 'domestic_credit_private', 2016, `2016`
FROM domestic_credit_privatecountry_financial_rank
UNION ALL
SELECT country_name, country_code, 'domestic_credit_private', 2017, `2017`
FROM domestic_credit_private
UNION ALL
SELECT country_name, country_code, 'domestic_credit_private', 2018, `2018`
FROM domestic_credit_private
UNION ALL
SELECT country_name, country_code, 'domestic_credit_private', 2019, `2019`
FROM domestic_credit_private
UNION ALL
SELECT country_name, country_code, 'domestic_credit_private', 2020, `2020`
FROM domestic_credit_private
UNION ALL
SELECT country_name, country_code, 'domestic_credit_private', 2021, `2021`
FROM domestic_credit_private
UNION ALL
SELECT country_name, country_code, 'domestic_credit_private', 2022, `2022`
FROM domestic_credit_private
UNION ALL
SELECT country_name, country_code, 'domestic_credit_private', 2023, `2023`
FROM domestic_credit_private
UNION ALL
SELECT country_name, country_code, 'domestic_credit_private', 2024, `2024`
FROM domestic_credit_private;

-- view for inflation

CREATE VIEW inflation_view AS
SELECT
    country_name,
    country_code,
    'inflation' AS indicator,
    2015 AS year,
    `2015` AS value
FROM inflation
UNION ALL
SELECT country_name, country_code, 'inflation', 2016, `2016`
FROM inflation
UNION ALL
SELECT country_name, country_code, 'inflation', 2017, `2017`
FROM inflation
UNION ALL
SELECT country_name, country_code, 'inflation', 2018, `2018`
FROM inflation
UNION ALL
SELECT country_name, country_code, 'inflation', 2019, `2019`
FROM inflation
UNION ALL
SELECT country_name, country_code, 'inflation', 2020, `2020`
FROM inflation
UNION ALL
SELECT country_name, country_code, 'inflation', 2021, `2021`
FROM inflation
UNION ALL
SELECT country_name, country_code, 'inflation', 2022, `2022`
FROM inflation
UNION ALL
SELECT country_name, country_code, 'inflation', 2023, `2023`
FROM inflation
UNION ALL
SELECT country_name, country_code, 'inflation', 2024, `2024`
FROM inflation;

-- for interest_rate
CREATE VIEW interest_rate_view AS
SELECT
    country_name,
    country_code,
    'interest_rate' AS indicator,
    2015 AS year,
    `2015` AS value
FROM interest_rate
UNION ALL
SELECT country_name, country_code, 'interest_rate', 2016, `2016`
FROM interest_rate
UNION ALL
SELECT country_name, country_code, 'interest_rate', 2017, `2017`
FROM interest_rate
UNION ALL
SELECT country_name, country_code, 'interest_rate', 2018, `2018`
FROM interest_rate
UNION ALL
SELECT country_name, country_code, 'interest_rate', 2019, `2019`
FROM interest_rate
UNION ALL
SELECT country_name, country_code, 'interest_rate', 2020, `2020`
FROM interest_rate
UNION ALL
SELECT country_name, country_code, 'interest_rate', 2021, `2021`
FROM interest_rate
UNION ALL
SELECT country_name, country_code, 'interest_rate', 2022, `2022`
FROM interest_rate
UNION ALL
SELECT country_name, country_code, 'interest_rate', 2023, `2023`
FROM interest_rate
UNION ALL
SELECT country_name, country_code, 'interest_rate', 2024, `2024`
FROM interest_rate;
-- creating master data table for the existing view
CREATE VIEW finance_master AS
SELECT * FROM gdp_view
UNION ALL
SELECT * FROM domestic_credit_private_view
UNION ALL
SELECT * FROM inflation_view
UNION ALL
SELECT * FROM interest_rate_view;

-- Data analyze
select indicator,min(value) as min ,max(value) as max from finance_master group by indicator;

-- create a view normalized value
CREATE VIEW finance_normalized AS
SELECT
    fm.country_name,
    fm.country_code,
    fm.indicator,
    fm.year,
    fm.value,
    (fm.value - stats.min_value) /
    (stats.max_value - stats.min_value) AS normalized_value
FROM finance_master fm
JOIN (
    SELECT
        indicator,
        MIN(value) AS min_value,
        MAX(value) AS max_value
    FROM finance_master
    GROUP BY indicator
) stats
ON fm.indicator = stats.indicator;

SELECT  * FROM finance_normalized WHERE country_name='India';

#financial health
CREATE VIEW finance_normalized_final AS
SELECT
	country_name,
    country_code,
    indicator,
    year,
    value,
    normalized_value,
    CASE
        WHEN indicator IN ('inflation', 'interest_rate')
            THEN 1 - normalized_value
        ELSE normalized_value
    END AS final_score
FROM finance_normalized;
select * from finance_normalized_final;

-- creating a financial heath score with the normalized values
CREATE VIEW financial_health_score AS
SELECT
    country_name,
    country_code,
    year,

    -- Final weighted financial health score
    SUM(
        CASE
            WHEN indicator = 'gdp' THEN final_score * 0.30
            WHEN indicator = 'domestic_credit' THEN final_score * 0.20
            WHEN indicator = 'domestic_credit_private' THEN final_score * 0.20
            WHEN indicator = 'inflation' THEN final_score * 0.15
            WHEN indicator = 'interest_rate' THEN final_score * 0.15
        END
    ) AS financial_normalized_final,

    -- Indicator interpretations
    GROUP_CONCAT(
        CASE
            -- GDP
            WHEN indicator = 'gdp' AND normalized_value BETWEEN 0.75 AND 1.00
                THEN 'GDP: Very Strong Economy'
            WHEN indicator = 'gdp' AND normalized_value BETWEEN 0.40 AND 0.74
                THEN 'GDP: Growing Economy'
            WHEN indicator = 'gdp' AND normalized_value BETWEEN 0.01 AND 0.39
                THEN 'GDP: Weak Economy'

            -- Domestic Credit
            WHEN indicator = 'domestic_credit' AND normalized_value BETWEEN 0.70 AND 1.00
                THEN 'Domestic Credit: Strong Access'
            WHEN indicator = 'domestic_credit' AND normalized_value BETWEEN 0.40 AND 0.69
                THEN 'Domestic Credit: Moderate Access'
            WHEN indicator = 'domestic_credit' AND normalized_value BETWEEN 0.01 AND 0.39
                THEN 'Domestic Credit: Poor Access'

            -- Private Credit
            WHEN indicator = 'domestic_credit_private' AND normalized_value BETWEEN 0.70 AND 1.00
                THEN 'Private Credit: Healthy'
            WHEN indicator = 'domestic_credit_private' AND normalized_value BETWEEN 0.40 AND 0.69
                THEN 'Private Credit: Average'
            WHEN indicator = 'domestic_credit_private' AND normalized_value BETWEEN 0.01 AND 0.39
                THEN 'Private Credit: Weak'

            -- Inflation (reversed)
            WHEN indicator = 'inflation' AND final_score BETWEEN 0.75 AND 1.00
                THEN 'Inflation: Price Stable'
            WHEN indicator = 'inflation' AND final_score BETWEEN 0.40 AND 0.74
                THEN 'Inflation: Manageable'
            WHEN indicator = 'inflation' AND final_score BETWEEN 0.01 AND 0.39
                THEN 'Inflation: High'

            -- Interest Rate (reversed)
            WHEN indicator = 'interest_rate' AND final_score BETWEEN 0.75 AND 1.00
                THEN 'Interest Rate: Low Cost'
            WHEN indicator = 'interest_rate' AND final_score BETWEEN 0.40 AND 0.74
                THEN 'Interest Rate: Normal Cost'
            WHEN indicator = 'interest_rate' AND final_score BETWEEN 0.01 AND 0.39
                THEN 'Interest Rate: High Cost'
        END
        SEPARATOR ' | '
    ) AS indicator_status

FROM finance_normalized_final
GROUP BY country_name, country_code, year;

SELECT * from financial_health_score;
-- country raanking with their financial score

CREATE VIEW country_financial_rank AS
SELECT
    country_name,
    country_code,
    indicator_status,
    year,
    financial_normalized_final,
    RANK() OVER (
        PARTITION BY year
        ORDER BY financial_normalized_final DESC
    ) AS financial_rank
FROM financial_health_score;

SELECT * FROM country_financial_rank;

-- Countries finalcial trends over year
CREATE VIEW country_financial_trend AS
SELECT
    country_name,
    country_code,
    year,
    financial_normalized_final,
    year_change,
    CASE
        WHEN year_change > 0 THEN 'Economy Improved'
        WHEN year_change < 0 THEN 'Economy Declined'
        WHEN year_change = 0 THEN 'No Change'
        ELSE 'First Year (No Previous Data)'
    END AS result
FROM (
    SELECT
        country_name,
        country_code,
        year,
        financial_normalized_final as final_score,
        financial_normalized_final -
        LAG(financial_normalized_final) OVER (
            PARTITION BY country_code
            ORDER BY year
        ) AS year_change
    FROM financial_health_score
) t;

select * from country_financial_trend;

-- Country Comparison (Cross-Sectional)
SELECT
    country_name,
    country_code,
    year,
    financial_normalized_final
FROM financial_health_score
ORDER BY year, financial_normalized_final DESC;

-- Trend Insights (Time Series)
SELECT
    country_name,
    SUM(year_change) AS total_change
FROM country_financial_trend
GROUP BY country_name
ORDER BY total_change DESC;

-- Stability vs Volatility
SELECT
    country_name,
    STDDEV(year_change) AS volatility
FROM country_financial_trend
GROUP BY country_name
ORDER BY volatility DESC;


