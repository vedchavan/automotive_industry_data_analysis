-- ============================================
-- AUTOMOTIVE INDUSTRY DATA ANALYSIS
-- ============================================

-- ============================================
-- CREATE TABLE
-- ============================================

-- Car Model Table
CREATE TABLE car_model (
    car_id INT PRIMARY KEY,
    model VARCHAR(20)
);

-- Dealer Table
CREATE TABLE dealers (
    dealer_id INT PRIMARY KEY,
    country VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    zip_code VARCHAR(20),
    address VARCHAR(255),
    dealer_name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    contact_phone_number VARCHAR(20),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6)
);

-- Sale Table
CREATE TABLE car_sales (
    sales_id INT PRIMARY KEY,
    sale_count INT,
    open_date DATE,
    sale_year INT,
    sale_month VARCHAR(20),
    month_order INT,
    days_to_make_sale INT,

    car_id INT NOT NULL,
    dealer_id INT NOT NULL,

    temperature_f DECIMAL(5,2),
    temperature_category VARCHAR(20),
    weather_condition VARCHAR(50),

    humidity_percent DECIMAL(5,2),
    wind_speed_mph DECIMAL(5,2),
    wind_gust_mph DECIMAL(5,2),
    wind_direction VARCHAR(10),

    visibility_mi DECIMAL(5,2),
    wind_chill_f DECIMAL(5,2),
    precipitation_in DECIMAL(5,2),

    fog BOOLEAN,
    rain BOOLEAN,
    snow BOOLEAN,

    CONSTRAINT fk_car
        FOREIGN KEY (car_id)
        REFERENCES car_model(car_id),

    CONSTRAINT fk_dealer
        FOREIGN KEY (dealer_id)
        REFERENCES dealers(dealer_id)
);

-- Recalls Table
CREATE TABLE recalls (
    recall_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    recall_date DATE NOT NULL,
    car_id INT NOT NULL,
    system_affected VARCHAR(100) NOT NULL,
    units INT NOT NULL,
    model VARCHAR(50),

    CONSTRAINT fk_recall_car
        FOREIGN KEY (car_id)
        REFERENCES car_model(car_id)
);

-- Optional: monthly aggregated sales/profit table (separate grain from car_sales,
-- profit data only covers 2022, car_sales covers 2023-2025 -- kept separate, not joined)
CREATE TABLE monthly_sales_summary (
    summary_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_year INT,
    sale_month VARCHAR(20),
    sale_date DATE,
    model VARCHAR(50),
    dealer_id INT REFERENCES dealers(dealer_id),
    quantity_sold INT,
    profit DECIMAL(10,2)
);


-- ============================================
-- EDA ANALYSIS
-- ============================================

-- Quick look
SELECT * FROM car_model;
SELECT * FROM car_sales LIMIT 10;
SELECT * FROM dealers LIMIT 10;
SELECT * FROM recalls LIMIT 10;

-- Row counts
SELECT COUNT(*) FROM dealers;
SELECT COUNT(*) FROM car_sales;
SELECT COUNT(*) FROM car_model;
SELECT COUNT(*) FROM recalls;

-- Duplicate checks (on primary keys)
-- car_sales table
SELECT sales_id, COUNT(*) AS duplicate_count
FROM car_sales
GROUP BY sales_id
HAVING COUNT(*) > 1;

-- recalls table
SELECT recall_id, COUNT(*) AS duplicate_count
FROM recalls
GROUP BY recall_id
HAVING COUNT(*) > 1;

-- car_model table
SELECT car_id, COUNT(*) AS duplicate_count
FROM car_model
GROUP BY car_id
HAVING COUNT(*) > 1;

-- dealers table
SELECT dealer_id, COUNT(*) AS duplicate_count
FROM dealers
GROUP BY dealer_id
HAVING COUNT(*) > 1;

-- Null value checks
-- car_sales table
SELECT
    COUNT(*) FILTER (WHERE sales_id IS NULL) AS null_sales_id,
    COUNT(*) FILTER (WHERE sale_count IS NULL) AS null_sale_count,
    COUNT(*) FILTER (WHERE open_date IS NULL) AS null_open_date,
    COUNT(*) FILTER (WHERE sale_year IS NULL) AS null_sale_year,
    COUNT(*) FILTER (WHERE sale_month IS NULL) AS null_sale_month,
    COUNT(*) FILTER (WHERE month_order IS NULL) AS null_month_order,
    COUNT(*) FILTER (WHERE car_id IS NULL) AS null_car_id,
    COUNT(*) FILTER (WHERE dealer_id IS NULL) AS null_dealer_id,
    COUNT(*) FILTER (WHERE rain IS NULL) AS null_rain,
    COUNT(*) FILTER (WHERE snow IS NULL) AS null_snow,
    COUNT(*) FILTER (WHERE fog IS NULL) AS null_fog
FROM car_sales;

-- recalls table
SELECT
    COUNT(*) FILTER (WHERE recall_id IS NULL) AS null_recall_id,
    COUNT(*) FILTER (WHERE recall_date IS NULL) AS null_recall_date,
    COUNT(*) FILTER (WHERE car_id IS NULL) AS null_car_id,
    COUNT(*) FILTER (WHERE units IS NULL) AS null_units,
    COUNT(*) FILTER (WHERE model IS NULL) AS null_model,
    COUNT(*) FILTER (WHERE system_affected IS NULL) AS null_system_affected
FROM recalls;

-- car_model table
SELECT
    COUNT(*) FILTER (WHERE car_id IS NULL) AS null_car_id,
    COUNT(*) FILTER (WHERE model IS NULL) AS null_model
FROM car_model;

-- dealers table
SELECT
    COUNT(*) FILTER (WHERE dealer_id IS NULL) AS null_dealer_id,
    COUNT(*) FILTER (WHERE country IS NULL) AS null_country,
    COUNT(*) FILTER (WHERE state IS NULL) AS null_state,
    COUNT(*) FILTER (WHERE city IS NULL) AS null_city,
    COUNT(*) FILTER (WHERE zip_code IS NULL) AS null_zip_code,
    COUNT(*) FILTER (WHERE address IS NULL) AS null_address,
    COUNT(*) FILTER (WHERE dealer_name IS NULL) AS null_dealer_name,
    COUNT(*) FILTER (WHERE contact_name IS NULL) AS null_contact_name,
    COUNT(*) FILTER (WHERE contact_phone_number IS NULL) AS null_contact_phone_number
FROM dealers;

-- Distinct value checks (categorical columns)
SELECT DISTINCT weather_condition FROM car_sales;
SELECT DISTINCT temperature_category FROM car_sales;
SELECT DISTINCT wind_direction FROM car_sales;
SELECT DISTINCT sale_month FROM car_sales;
SELECT DISTINCT system_affected FROM recalls;

-- Min/Max checks
-- car_sales table
SELECT
	MIN(sale_count) AS min_sale_count,
	MAX(sale_count) AS max_sale_count,
	MIN(open_date) AS min_open_date,
	MAX(open_date) AS max_open_date,
	MIN(sale_year) AS min_sale_year,
	MAX(sale_year) AS max_sale_year
FROM
	car_sales;

-- recalls table
SELECT
	MIN(recall_date) AS min_recall_date,
	MAX(recall_date) AS max_recall_date,
	MIN(units) AS min_units,
	MAX(units) AS max_units
FROM
	recalls;
-- NOTE: recall_date range = 2016-01-18 to 2020-04-29
-- NOTE: open_date range = 2023-01-01 to 2025-12-31
-- These do NOT overlap -- important limitation

-- Test joins -- confirm foreign keys match cleanly across tables
SELECT
	s.sales_id,
	cm.model,
	d.dealer_name
FROM
	car_sales s
	LEFT JOIN car_model cm ON cm.car_id = s.car_id
	LEFT JOIN dealers d ON d.dealer_id = s.dealer_id
WHERE
	cm.car_id IS NULL
	OR d.dealer_id IS NULL;
-- Result: 0 rows returned -- all car_id and dealer_id values in car_sales match cleanly


-- ============================================
-- BUSINESS ANALYSIS
-- ============================================
/*
 Business problem: A car dealer needs to decide which car models to
 prioritize in inventory and sales push, but doesn't currently have
 visibility into which models are most profitable, best-selling, or
 carry the most recall risk, because sales, dealer, and recall data
 live in separate systems.
*/
-- Q1: Which car model gets the most recalls, and what's the most common issue?
SELECT
	model,
	SUM(units) AS total_units_recalled,
	COUNT(*) AS recall_count
FROM
	recalls
GROUP BY
	model
ORDER BY
	total_units_recalled DESC
LIMIT
	1;

-- Most common issue for the top recalled model
SELECT
	system_affected,
	COUNT(*) AS occurrence_count
FROM
	recalls
WHERE
	model = 'Beaufort'  
GROUP BY
	system_affected
ORDER BY
	occurrence_count DESC
LIMIT
	1;
-- Result: Beaufort, Airbag (most common issue)

-- Q2: Which car model sells the most units overall?
SELECT
	s.car_id,
	cm.model,
	SUM(s.sale_count) AS total_sales
FROM
	car_sales s
	LEFT JOIN car_model cm ON cm.car_id = s.car_id
GROUP BY
	s.car_id,
	cm.model
ORDER BY
	total_sales DESC
LIMIT
	1;

-- Q3: Which dealers have the highest total sales?
SELECT
	s.dealer_id,
	d.dealer_name,
	SUM(s.sale_count) AS total_sales
FROM
	car_sales s
	LEFT JOIN dealers d ON d.dealer_id = s.dealer_id
GROUP BY
	s.dealer_id,
	d.dealer_name
ORDER BY
	total_sales DESC
LIMIT
	1;

-- Q4: Which dealers sell the highest volume of recalled models?
-- NOTE: since all models have recall history, this will effectively
-- match Q3's answer -- expected given the data, documented as such.
SELECT
	s.dealer_id,
	d.dealer_name,
	SUM(s.sale_count) AS total_units_sold
FROM
	car_sales s
	JOIN dealers d ON d.dealer_id = s.dealer_id
WHERE
	s.car_id IN (
		SELECT DISTINCT
			car_id
		FROM
			recalls
	)
GROUP BY
	s.dealer_id,
	d.dealer_name
ORDER BY
	total_units_sold DESC
LIMIT
	1;

-- Q5: Does weather (rain/snow/fog) affect daily sales volume?
-- NOTE: sale_count is always 1 per row (one row = one sale), so use
-- COUNT(*) for volume, not AVG(sale_count).

-- Rain
SELECT
	rain,
	COUNT(*) AS total_sales,
	COUNT(DISTINCT open_date) AS num_days,
	ROUND(COUNT(*)::NUMERIC / COUNT(DISTINCT open_date), 2) AS avg_sales_per_day
FROM
	car_sales
WHERE
	rain IS NOT NULL
GROUP BY
	rain;
-- Result: false = 159,397 total sales | true = 7,455 total sales | 1,082 NULL rows excluded

-- Snow
SELECT
	snow,
	COUNT(*) AS total_sales,
	COUNT(DISTINCT open_date) AS num_days,
	ROUND(COUNT(*)::NUMERIC / COUNT(DISTINCT open_date), 2) AS avg_sales_per_day
FROM
	car_sales
WHERE
	snow IS NOT NULL
GROUP BY
	snow;
-- Result: false =  1,61,287 total sales | true = 5,565 total sales |

-- Fog
SELECT
	fog,
	COUNT(*) AS total_sales,
	COUNT(DISTINCT open_date) AS num_days,
	ROUND(COUNT(*)::NUMERIC / COUNT(DISTINCT open_date), 2) AS avg_sales_per_day
FROM
	car_sales
WHERE
	fog IS NOT NULL
GROUP BY
	fog;
-- Result: false =  1,65,508 total sales | true = 1,698 total sales |


-- Temperature buckets
SELECT
	CASE
		WHEN temperature_f < 32 THEN 'freezing'
		WHEN temperature_f BETWEEN 32 AND 60  THEN 'cold'
		WHEN temperature_f BETWEEN 61 AND 80  THEN 'mild'
		ELSE 'hot'
	END AS temp_bucket,
	COUNT(*) AS total_sales,
	COUNT(DISTINCT open_date) AS num_days,
	ROUND(COUNT(*)::NUMERIC / COUNT(DISTINCT open_date), 2) AS avg_sales_per_day
FROM
	car_sales
GROUP BY
	temp_bucket
ORDER BY
	avg_sales_per_day DESC;

-- Q6: Which month/year had the highest number of recalls?
SELECT
	DATE_TRUNC('month', recall_date) AS recall_month,
	COUNT(*) AS recall_count
FROM
	recalls
GROUP BY
	recall_month
ORDER BY
	recall_count DESC
	limit 1;
-- Result:  March 2019 was the month with most recall


SELECT
	DATE_TRUNC('YEAR', recall_date) AS recall_Year,
	COUNT(*) AS recall_count
FROM
	recalls
GROUP BY
	recall_year
ORDER BY
	recall_count DESC
	limit 1;
-- Result: 2018-01-01 was the year with most recall





