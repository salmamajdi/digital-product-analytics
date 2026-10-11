SELECT
    COUNT(*) AS daily_activity_rows,
    COUNT(DISTINCT client_id) AS users,
    MIN(activity_date) AS first_date,
    MAX(activity_date) AS last_date,
    SUM(page_views) AS total_page_views
FROM analytics.user_daily_activity;

SELECT
    COUNT(*) AS hourly_rows,
    MIN(traffic_hour) AS first_hour,
    MAX(traffic_hour) AS last_hour,
    SUM(page_views) AS total_page_views
FROM analytics.hourly_traffic;
