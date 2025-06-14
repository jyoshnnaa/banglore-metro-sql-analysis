CREATE DATABASE metro_ridership_db;

USE metro_ridership_db;
SHOW TABLES;
DESCRIBE nammametro_ridership_dataset;

CREATE OR REPLACE VIEW metro_ridership_clean AS
SELECT 
    STR_TO_DATE(`Record Date`, '%d-%m-%Y') AS record_date,
    `Total Smart Cards`,
    `Stored Value Card`,
    `One Day Pass`,
    `Three Day Pass`,
    `Five Day Pass`,
    `Total Tokens`,
    `Total NCMC`,
    `Group Ticket`,
    `Total QR`,
    `QR NammaMetro`,
    `QR WhatsApp`,
    `QR Paytm`
FROM nammametro_ridership_dataset;

#1. ---Daily Riderships Trends ----
SELECT 
DATE_FORMAT(record_date, '%d-%m-%Y') AS ride_date,
(`Total Smart Cards` + `One Day Pass` + `Three Day Pass` + `Five Day Pass` + `Total Tokens` + `Total NCMC` + `Group Ticket`
 + `Total QR` + `QR NammaMetro` + `QR WhatsApp` + `QR Paytm`) AS total_ridership
 FROM metro_ridership_clean
 ORDER BY record_date;
 
 # create view
 CREATE OR REPLACE VIEW daily_ridership AS
SELECT 
  DATE_FORMAT(record_date, '%d-%m-%Y') AS record_date,
  (`Total Smart Cards` + `One Day Pass` + `Three Day Pass` + `Five Day Pass` +
   `Total Tokens` + `Total NCMC` + `Group Ticket` + `Total QR`) AS total_ridership
FROM metro_ridership_clean;

#2. Peak Days 
SELECT * 
FROM daily_ridership
ORDER BY total_ridership DESC
LIMIT 3;
#3. Drop Days 
SELECT * 
FROM daily_ridership
ORDER BY total_ridership ASC
LIMIT 1;
 
#4.---- Monthly Ridership Trends---
SELECT
YEAR(record_date) AS year,
MONTH(record_date) AS month,
SUM(`Total Smart Cards` + `One Day Pass` + `Three Day Pass` + `Five Day Pass` + `Total Tokens` + `Total NCMC` + `Group Ticket`
 + `Total QR` + `QR NammaMetro` + `QR WhatsApp` + `QR Paytm`) AS total_monthly_ridership
FROM metro_ridership_clean
GROUP BY month, year
ORDER BY year, month; 
#5. Monthly Riderships Spike
SELECT 
  DATE_FORMAT(record_date, '%Y-%m') AS month,
  SUM(`Total Smart Cards` + `One Day Pass` + `Three Day Pass` + `Five Day Pass` +
      `Total Tokens` + `Total NCMC` + `Group Ticket` + `Total QR`) AS total_ridership
FROM metro_ridership_clean
GROUP BY month 
ORDER BY total_ridership DESC;

#6. Monthly Riderships Drop 
SELECT 
  DATE_FORMAT(record_date, '%Y-%m') AS month,
  SUM(`Total Smart Cards` + `One Day Pass` + `Three Day Pass` + `Five Day Pass` +
      `Total Tokens` + `Total NCMC` + `Group Ticket` + `Total QR`) AS total_ridership
FROM metro_ridership_clean
GROUP BY month 
ORDER BY total_ridership ASC;


#7. Percentage shares
WITH monthly_data AS (
  SELECT 
    DATE_FORMAT(record_date, '%Y-%m') AS month,
    SUM(`Total Smart Cards`) AS smart_cards,
    SUM(`Total Tokens`) AS tokens,
    SUM(`Total NCMC`) AS ncmc,
    SUM(`Group Ticket`) AS group_tickets,
    SUM(`Total QR`) AS qr_total,
    SUM(`One Day Pass`) AS pass_1_day,
    SUM(`Three Day Pass`) AS pass_3_day,
    SUM(`Five Day Pass`) AS pass_5_day
  FROM metro_ridership_clean
  GROUP BY month 
)
SELECT 
  month,
  ROUND((smart_cards / total) * 100, 2) AS pct_smart_cards,
  ROUND((tokens / total) * 100, 2) AS pct_tokens,
  ROUND((ncmc / total) * 100, 2) AS pct_ncmc,
  ROUND((group_tickets / total) * 100, 2) AS pct_group,
  ROUND((qr_total / total) * 100, 2) AS pct_qr,
  ROUND((pass_1_day / total) * 100, 2) AS pct_1day,
  ROUND((pass_3_day / total) * 100, 2) AS pct_3day,
  ROUND((pass_5_day / total) * 100, 2) AS pct_5day
FROM (
  SELECT *,
    (smart_cards + tokens + ncmc + group_tickets + qr_total + pass_1_day + pass_3_day + pass_5_day) AS total
  FROM monthly_data
) AS fare_percentages;


#8. Most widely used Fare type
SELECT fare_type, total_riders
FROM (
    SELECT 'Smart Cards' AS fare_type, SUM(`Total Smart Cards`) AS total_riders FROM metro_ridership_clean
    UNION ALL
    SELECT 'Tokens', SUM(`Total Tokens`) FROM metro_ridership_clean
    UNION ALL
    SELECT 'NCMC', SUM(`Total NCMC`) FROM metro_ridership_clean
    UNION ALL
    SELECT 'Group Ticket', SUM(`Group Ticket`) FROM metro_ridership_clean
    UNION ALL
    SELECT 'QR Tickets', SUM(`Total QR`) FROM metro_ridership_clean
    UNION ALL
    SELECT '1-Day Pass', SUM(`One Day Pass`) FROM metro_ridership_clean
    UNION ALL
    SELECT '3-Day Pass', SUM(`Three Day Pass`) FROM metro_ridership_clean
    UNION ALL
    SELECT '5-Day Pass', SUM(`Five Day Pass`) FROM metro_ridership_clean
) AS fare_totals
ORDER BY total_riders DESC;


#9. ----Pass Usage Trends----
SELECT 
  DATE_FORMAT(record_date, '%Y-%m') AS month,
  SUM(`One Day Pass`) AS one_day_pass,
  SUM(`Three Day Pass`) AS three_day_pass,
  SUM(`Five Day Pass`) AS five_day_pass,
  SUM(`One Day Pass` + `Three Day Pass` + `Five day Pass`) AS total_pass_usage
FROM metro_ridership_clean
GROUP BY month
ORDER BY month;
#10. Highest Pass Usage Month
SELECT 
  DATE_FORMAT(record_date, '%Y-%m') AS month,
  SUM(`One Day Pass` + `Three Day Pass` + `Five Day Pass`) AS total_pass_usage
FROM metro_ridership_clean
GROUP BY month
ORDER BY total_pass_usage DESC
LIMIT 1;
#11. Lowest Pass Usage Month
SELECT 
  DATE_FORMAT(record_date, '%Y-%m') AS month,
  SUM(`One Day Pass` + `Three Day Pass` + `Five Day Pass`) AS total_pass_usage
FROM metro_ridership_clean
GROUP BY month
ORDER BY total_pass_usage ASC
LIMIT 1;

#12. ---QR Platform Comparision---
SELECT 
  DATE_FORMAT(record_date, '%m-%Y') AS month_year,
  SUM(`QR Paytm`) AS paytm,
  SUM(`QR WhatsApp`) AS whatsapp,
  SUM(`QR NammaMetro`) AS app
FROM metro_ridership_clean
GROUP BY month_year
ORDER BY STR_TO_DATE(month_year, '%m-%Y');

#13. Most widely used QR Platform
SELECT 
  'QR Paytm' AS platform, SUM(`QR Paytm`) AS total_rides
FROM metro_ridership_clean
UNION ALL
SELECT 
  'QR WhatsApp' AS platform, SUM(`QR WhatsApp`)
FROM metro_ridership_clean
UNION ALL
SELECT 
  'QR NammaMetro' AS platform, SUM(`QR NammaMetro`)
FROM metro_ridership_clean
ORDER BY total_rides DESC;

#14. ---Smart card vs Tokens---
SELECT 
  DATE_FORMAT(record_date, '%Y-%m') AS month,
  SUM(`Total Smart Cards`) AS total_smart_cards,
  SUM(`Total Tokens`) AS total_tokens
FROM metro_ridership_clean
GROUP BY month
ORDER BY month;

#15. --weekdays vs weekends---
SELECT 
  CASE 
    WHEN DAYOFWEEK(record_date) IN (1, 7) THEN 'Weekend'
    ELSE 'Weekday'
  END AS day_type,
  COUNT(*) AS total_days,
  SUM(`Total Smart Cards` + `Total Tokens` + `Total NCMC` + `Group Ticket` + `Total QR` + 
      `One Day Pass` + `Three Day Pass` + `Five Day Pass`) AS total_ridership
FROM metro_ridership_clean
GROUP BY day_type;

#16. ---Most preffered day of week---
SELECT 
    DAYNAME(record_date) AS week_day,
    ROUND(AVG(`Total Smart Cards` + `Total Tokens` + `Total NCMC` + `Group Ticket` + 
              `Total QR` + `One Day Pass` + `Three Day Pass` + `Five Day Pass`), 0) AS avg_ridership
FROM metro_ridership_clean
GROUP BY week_day
ORDER BY avg_ridership DESC;
 
#17. ---First day and Last day of each month
SELECT *
FROM (
    SELECT 
        record_date,
        `Total Smart Cards` + `Total Tokens` + `Total QR` +
        `Total NCMC` + `Group Ticket` + 
        `One Day Pass` + `Three Day Pass` + `Five Day Pass` AS total_riders,
        ROW_NUMBER() OVER (PARTITION BY DATE_FORMAT(record_date, '%Y-%m') ORDER BY record_date ASC) AS rn_first,
        ROW_NUMBER() OVER (PARTITION BY DATE_FORMAT(record_date, '%Y-%m') ORDER BY record_date DESC) AS rn_last
    FROM metro_ridership_clean
) t
WHERE rn_first = 1 OR rn_last = 1;

#18. ---Most Popular Fare Type on Peak Ridership Days---
 WITH daily_total AS (
    SELECT 
        record_date,
        `Total Smart Cards`,
        `Total Tokens`,
        `Total QR`,
        (
            `Total Smart Cards` + `Total Tokens` + `Total QR` +
            `Total NCMC` + `Group Ticket` + 
            `One Day Pass` + `Three Day Pass` + `Five Day Pass`
        ) AS total_riders
    FROM metro_ridership_clean
),
top_days AS (
    SELECT * FROM daily_total ORDER BY total_riders DESC LIMIT 5
)
SELECT 
    record_date,
    `Total Smart Cards`, 
    `Total Tokens`,
    `Total QR`
FROM top_days
ORDER BY record_date;

#19. Month-over-Month Ridership Growth (with % Change)
SELECT 
  month,
  total_ridership,
  LAG(total_ridership) OVER (ORDER BY month) AS previous_month,
  ROUND(
    (total_ridership - LAG(total_ridership) OVER (ORDER BY month)) 
    / LAG(total_ridership) OVER (ORDER BY month) * 100, 2
  ) AS growth_percent
FROM (
  SELECT 
    DATE_FORMAT(record_date, '%Y-%m') AS month,
    SUM(`Total Smart Cards` + `Total Tokens` + `Total NCMC` + `Group Ticket` + `Total QR` + 
        `One Day Pass` + `Three Day Pass` + `Five Day Pass`) AS total_ridership
  FROM metro_ridership_clean
  GROUP BY month
) t;

#20 ---Minimum & Maximum Riderships Per month---
SELECT 
  DATE_FORMAT(record_date, '%Y-%m') AS month,
  MIN(`Total Smart Cards` + `Total Tokens` + `Total QR` + `Total NCMC` +
      `Group Ticket` + `One Day Pass` + `Three Day Pass` + `Five Day Pass`) AS min_ridership,
  MAX(`Total Smart Cards` + `Total Tokens` + `Total QR` + `Total NCMC` +
      `Group Ticket` + `One Day Pass` + `Three Day Pass` + `Five Day Pass`) AS max_ridership
FROM metro_ridership_clean
GROUP BY month
ORDER BY month;
