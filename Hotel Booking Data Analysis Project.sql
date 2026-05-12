/* =========================================================
   PROJECT: HOTEL BOOKING DATA ANALYSIS
   COMPANY: Elite Hotels International
   DATABASE: MySQL
   AUTHOR: Senior Data Analyst
========================================================= */

-- =====================================================
-- 1. CREATE DATABASE
-- =====================================================

DROP DATABASE IF EXISTS hotel_booking_analysis;

CREATE DATABASE hotel_booking_analysis;

USE hotel_booking_analysis;

-- =====================================================
-- 2. CREATE TABLE
-- =====================================================

DROP TABLE IF EXISTS hotel_bookings;

CREATE TABLE hotel_bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    hotel VARCHAR(50),
    is_canceled TINYINT,
    lead_time INT,
    arrival_date_year INT,
    arrival_date_month VARCHAR(20),
    arrival_date_week_number INT,
    arrival_date_day_of_month INT,
    stays_in_weekend_nights INT,
    stays_in_week_nights INT,
    adults INT,
    children INT,
    babies INT,
    meal VARCHAR(20),
    country VARCHAR(10),
    market_segment VARCHAR(50),
    distribution_channel VARCHAR(50),
    is_repeated_guest TINYINT,
    previous_cancellations INT,
    previous_bookings_not_canceled INT,
    reserved_room_type VARCHAR(10),
    assigned_room_type VARCHAR(10),
    booking_changes INT,
    deposit_type VARCHAR(50),
    agent VARCHAR(20),
    company VARCHAR(20),
    days_in_waiting_list INT,
    customer_type VARCHAR(50),
    adr DECIMAL(10,2),
    required_car_parking_spaces INT,
    total_of_special_requests INT,
    reservation_status VARCHAR(50),
    reservation_status_date DATE
);

-- =====================================================
-- 3. IMPORT CSV FILE
-- =====================================================

/*
NOTE:
1. Put CSV file inside MySQL uploads folder.
2. Example path:
   C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/hotel_bookings.csv

3. Enable:
   SET GLOBAL local_infile = 1;
*/

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/hotel_bookings.csv'
INTO TABLE hotel_bookings
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
hotel,
is_canceled,
lead_time,
arrival_date_year,
arrival_date_month,
arrival_date_week_number,
arrival_date_day_of_month,
stays_in_weekend_nights,
stays_in_week_nights,
adults,
@children,
babies,
meal,
country,
market_segment,
distribution_channel,
is_repeated_guest,
previous_cancellations,
previous_bookings_not_canceled,
reserved_room_type,
assigned_room_type,
booking_changes,
deposit_type,
agent,
company,
days_in_waiting_list,
customer_type,
adr,
required_car_parking_spaces,
total_of_special_requests,
reservation_status,
reservation_status_date
)
SET children = NULLIF(@children,'');

-- =====================================================
-- 4. DATA CLEANING
-- =====================================================

-- Replace NULL children with 0

UPDATE hotel_bookings
SET children = 0
WHERE children IS NULL;

-- Replace NULL country values

UPDATE hotel_bookings
SET country = 'Unknown'
WHERE country IS NULL;

-- Remove rows where adults, children and babies are all 0

DELETE FROM hotel_bookings
WHERE adults = 0
AND children = 0
AND babies = 0;

-- =====================================================
-- 5. DATA UNDERSTANDING
-- =====================================================

-- Total Records

SELECT COUNT(*) AS total_records
FROM hotel_bookings;

-- Hotel Types

SELECT DISTINCT hotel
FROM hotel_bookings;

-- Reservation Status Types

SELECT DISTINCT reservation_status
FROM hotel_bookings;

-- =====================================================
-- 6. EXPLORATORY DATA ANALYSIS
-- =====================================================

-- =====================================================
-- A. TOTAL BOOKINGS
-- =====================================================

SELECT 
    COUNT(*) AS total_bookings
FROM hotel_bookings;

-- =====================================================
-- B. HOTEL-WISE BOOKINGS
-- =====================================================

SELECT 
    hotel,
    COUNT(*) AS total_bookings
FROM hotel_bookings
GROUP BY hotel
ORDER BY total_bookings DESC;

-- =====================================================
-- C. CANCELLATION RATE
-- =====================================================

SELECT 
    ROUND(
        SUM(is_canceled) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate_percentage
FROM hotel_bookings;

-- =====================================================
-- D. CANCELLATION RATE BY HOTEL
-- =====================================================

SELECT 
    hotel,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS canceled_bookings,
    ROUND(
        SUM(is_canceled) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate
FROM hotel_bookings
GROUP BY hotel;

-- =====================================================
-- E. MONTHLY BOOKING TREND
-- =====================================================

SELECT 
    arrival_date_month,
    COUNT(*) AS total_bookings
FROM hotel_bookings
GROUP BY arrival_date_month
ORDER BY total_bookings DESC;

-- =====================================================
-- F. YEARLY BOOKING TREND
-- =====================================================

SELECT 
    arrival_date_year,
    COUNT(*) AS total_bookings
FROM hotel_bookings
GROUP BY arrival_date_year
ORDER BY arrival_date_year;

-- =====================================================
-- G. AVERAGE DAILY RATE BY HOTEL
-- =====================================================

SELECT 
    hotel,
    ROUND(AVG(adr),2) AS average_daily_rate
FROM hotel_bookings
GROUP BY hotel;

-- =====================================================
-- H. TOP 10 COUNTRIES
-- =====================================================

SELECT 
    country,
    COUNT(*) AS total_guests
FROM hotel_bookings
GROUP BY country
ORDER BY total_guests DESC
LIMIT 10;

-- =====================================================
-- I. MARKET SEGMENT ANALYSIS
-- =====================================================

SELECT 
    market_segment,
    COUNT(*) AS total_bookings,
    ROUND(AVG(adr),2) AS avg_room_rate,
    ROUND(
        SUM(is_canceled) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate
FROM hotel_bookings
GROUP BY market_segment
ORDER BY total_bookings DESC;

-- =====================================================
-- J. CUSTOMER TYPE ANALYSIS
-- =====================================================

SELECT 
    customer_type,
    COUNT(*) AS total_customers,
    ROUND(AVG(adr),2) AS avg_adr
FROM hotel_bookings
GROUP BY customer_type
ORDER BY total_customers DESC;

-- =====================================================
-- K. REPEATED GUEST ANALYSIS
-- =====================================================

SELECT 
    is_repeated_guest,
    COUNT(*) AS total_guests
FROM hotel_bookings
GROUP BY is_repeated_guest;

-- =====================================================
-- L. LEAD TIME ANALYSIS
-- =====================================================

SELECT
    CASE
        WHEN lead_time <= 7 THEN '0-7 Days'
        WHEN lead_time <= 30 THEN '8-30 Days'
        WHEN lead_time <= 90 THEN '31-90 Days'
        ELSE '90+ Days'
    END AS lead_time_category,
    COUNT(*) AS total_bookings
FROM hotel_bookings
GROUP BY lead_time_category
ORDER BY total_bookings DESC;

-- =====================================================
-- M. SPECIAL REQUEST ANALYSIS
-- =====================================================

SELECT 
    total_of_special_requests,
    COUNT(*) AS total_customers
FROM hotel_bookings
GROUP BY total_of_special_requests
ORDER BY total_of_special_requests;

-- =====================================================
-- N. MEAL PREFERENCE ANALYSIS
-- =====================================================

SELECT 
    meal,
    COUNT(*) AS total_orders
FROM hotel_bookings
GROUP BY meal
ORDER BY total_orders DESC;

-- =====================================================
-- O. DEPOSIT TYPE ANALYSIS
-- =====================================================

SELECT 
    deposit_type,
    COUNT(*) AS total_bookings,
    ROUND(
        SUM(is_canceled) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate
FROM hotel_bookings
GROUP BY deposit_type;

-- =====================================================
-- P. ROOM TYPE ANALYSIS
-- =====================================================

SELECT 
    reserved_room_type,
    assigned_room_type,
    COUNT(*) AS total_cases
FROM hotel_bookings
WHERE reserved_room_type <> assigned_room_type
GROUP BY reserved_room_type, assigned_room_type
ORDER BY total_cases DESC;

-- =====================================================
-- Q. STAY DURATION ANALYSIS
-- =====================================================

SELECT 
    ROUND(
        AVG(stays_in_weekend_nights + stays_in_week_nights),
        2
    ) AS avg_stay_duration
FROM hotel_bookings;

-- =====================================================
-- R. WEEKEND VS WEEKDAY STAY
-- =====================================================

SELECT 
    hotel,
    ROUND(AVG(stays_in_weekend_nights),2) AS avg_weekend_stay,
    ROUND(AVG(stays_in_week_nights),2) AS avg_weekday_stay
FROM hotel_bookings
GROUP BY hotel;

-- =====================================================
-- S. GUEST COMPOSITION ANALYSIS
-- =====================================================

SELECT 
    CASE
        WHEN babies > 0 THEN 'Family With Babies'
        WHEN children > 0 THEN 'Family With Children'
        WHEN adults = 1 THEN 'Solo Travelers'
        WHEN adults = 2 THEN 'Couples'
        ELSE 'Group Travelers'
    END AS guest_category,
    COUNT(*) AS total_bookings
FROM hotel_bookings
GROUP BY guest_category
ORDER BY total_bookings DESC;

-- =====================================================
-- T. PARKING SPACE ANALYSIS
-- =====================================================

SELECT 
    required_car_parking_spaces,
    COUNT(*) AS total_customers
FROM hotel_bookings
GROUP BY required_car_parking_spaces
ORDER BY required_car_parking_spaces;

-- =====================================================
-- 7. REVENUE ANALYSIS
-- =====================================================

-- =====================================================
-- TOTAL ESTIMATED REVENUE
-- =====================================================

SELECT 
    ROUND(
        SUM(
            adr * 
            (stays_in_weekend_nights + stays_in_week_nights)
        ),
        2
    ) AS total_revenue
FROM hotel_bookings
WHERE is_canceled = 0;

-- =====================================================
-- HOTEL-WISE REVENUE
-- =====================================================

SELECT 
    hotel,
    ROUND(
        SUM(
            adr *
            (stays_in_weekend_nights + stays_in_week_nights)
        ),
        2
    ) AS hotel_revenue
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel
ORDER BY hotel_revenue DESC;

-- =====================================================
-- MONTH-WISE REVENUE
-- =====================================================

SELECT 
    arrival_date_month,
    ROUND(
        SUM(
            adr *
            (stays_in_weekend_nights + stays_in_week_nights)
        ),
        2
    ) AS monthly_revenue
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY arrival_date_month
ORDER BY monthly_revenue DESC;

-- =====================================================
-- TOP PROFITABLE CUSTOMER TYPES
-- =====================================================

SELECT 
    customer_type,
    ROUND(
        AVG(
            adr *
            (stays_in_weekend_nights + stays_in_week_nights)
        ),
        2
    ) AS avg_customer_value
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY customer_type
ORDER BY avg_customer_value DESC;

-- =====================================================
-- 8. ADVANCED BUSINESS ANALYSIS
-- =====================================================

-- =====================================================
-- HIGH CANCELLATION MARKET SEGMENTS
-- =====================================================

SELECT 
    market_segment,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS cancellations,
    ROUND(
        SUM(is_canceled) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate
FROM hotel_bookings
GROUP BY market_segment
ORDER BY cancellation_rate DESC;

-- =====================================================
-- LONG LEAD TIME CANCELLATION ANALYSIS
-- =====================================================

SELECT
    CASE
        WHEN lead_time <= 30 THEN 'Short Lead Time'
        WHEN lead_time <= 90 THEN 'Medium Lead Time'
        ELSE 'Long Lead Time'
    END AS lead_time_group,
    
    COUNT(*) AS total_bookings,
    
    ROUND(
        SUM(is_canceled) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate

FROM hotel_bookings
GROUP BY lead_time_group
ORDER BY cancellation_rate DESC;

-- =====================================================
-- SPECIAL REQUEST VS CANCELLATION
-- =====================================================

SELECT 
    total_of_special_requests,
    COUNT(*) AS total_bookings,
    
    ROUND(
        SUM(is_canceled) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate

FROM hotel_bookings
GROUP BY total_of_special_requests
ORDER BY total_of_special_requests;

-- =====================================================
-- REPEATED GUEST REVENUE
-- =====================================================

SELECT 
    is_repeated_guest,
    
    ROUND(
        SUM(
            adr *
            (stays_in_weekend_nights + stays_in_week_nights)
        ),
        2
    ) AS total_revenue

FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY is_repeated_guest;

-- =====================================================
-- 9. KPI DASHBOARD QUERIES
-- =====================================================

-- Total Bookings KPI

SELECT 
    COUNT(*) AS total_bookings
FROM hotel_bookings;

-- Confirmed Bookings KPI

SELECT 
    COUNT(*) AS confirmed_bookings
FROM hotel_bookings
WHERE is_canceled = 0;

-- Cancellation KPI

SELECT 
    COUNT(*) AS canceled_bookings
FROM hotel_bookings
WHERE is_canceled = 1;

-- Average ADR KPI

SELECT 
    ROUND(AVG(adr),2) AS avg_daily_rate
FROM hotel_bookings;

-- Average Stay KPI

SELECT 
    ROUND(
        AVG(
            stays_in_week_nights +
            stays_in_weekend_nights
        ),
        2
    ) AS average_stay
FROM hotel_bookings;

-- =====================================================
-- 10. CREATE VIEWS FOR DASHBOARD
-- =====================================================

-- Revenue View

CREATE OR REPLACE VIEW vw_hotel_revenue AS
SELECT 
    hotel,
    ROUND(
        SUM(
            adr *
            (stays_in_weekend_nights + stays_in_week_nights)
        ),
        2
    ) AS revenue
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel;

-- Cancellation View

CREATE OR REPLACE VIEW vw_cancellation_summary AS
SELECT 
    hotel,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS canceled_bookings,
    
    ROUND(
        SUM(is_canceled) * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate

FROM hotel_bookings
GROUP BY hotel;

-- Monthly Revenue View

CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT 
    arrival_date_year,
    arrival_date_month,

    ROUND(
        SUM(
            adr *
            (stays_in_weekend_nights + stays_in_week_nights)
        ),
        2
    ) AS monthly_revenue

FROM hotel_bookings
WHERE is_canceled = 0

GROUP BY 
    arrival_date_year,
    arrival_date_month;

-- =====================================================
-- 11. INDEX CREATION FOR PERFORMANCE
-- =====================================================

CREATE INDEX idx_hotel ON hotel_bookings(hotel);

CREATE INDEX idx_country ON hotel_bookings(country);

CREATE INDEX idx_market_segment 
ON hotel_bookings(market_segment);

CREATE INDEX idx_arrival_year 
ON hotel_bookings(arrival_date_year);

CREATE INDEX idx_reservation_status
ON hotel_bookings(reservation_status);

-- =====================================================
-- 12. FINAL BUSINESS INSIGHTS
-- =====================================================

/*

KEY INSIGHTS:

1. City hotels generally receive more bookings.
2. Long lead-time bookings have higher cancellation risk.
3. Repeated guests generate stable revenue.
4. Certain market segments contribute maximum revenue.
5. Peak months can be used for surge pricing.
6. Deposit policy reduces cancellations.
7. Families and couples are major customer groups.
8. Special requests indicate higher customer engagement.

BUSINESS RECOMMENDATIONS:

1. Implement dynamic pricing strategy.
2. Focus on customer loyalty programs.
3. Introduce partial non-refundable deposits.
4. Improve guest personalization services.
5. Optimize staffing during peak months.
6. Target high-value countries and segments.
7. Reduce cancellation risk through predictive analytics.

*/

-- =====================================================
-- END OF PROJECT
-- =====================================================