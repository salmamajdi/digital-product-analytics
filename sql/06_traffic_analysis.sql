-- 1. KPIs globaux trafic
SELECT
    COUNT(DISTINCT client_id) AS total_users,
    SUM(page_views) AS total_page_views,
    ROUND(
        SUM(page_views)::NUMERIC / COUNT(DISTINCT client_id),
        2
    ) AS avg_page_views_per_user,
    COUNT(DISTINCT activity_date) AS active_days
FROM analytics.user_daily_activity;


-- 2. Trafic quotidien + moyenne mobile 7 jours
WITH daily_metrics AS (
    SELECT
        activity_date,
        SUM(page_views) AS page_views,
        COUNT(DISTINCT client_id) AS active_users
    FROM analytics.user_daily_activity
    GROUP BY activity_date
)

SELECT
    activity_date,
    page_views,
    active_users,
    ROUND(
        AVG(page_views) OVER (
            ORDER BY activity_date
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        0
    ) AS page_views_7d_avg
FROM daily_metrics
ORDER BY activity_date;


-- 3. Heures avec le plus de trafic
SELECT
    EXTRACT(HOUR FROM traffic_hour)::INTEGER AS hour_of_day,
    SUM(page_views) AS page_views,
    ROUND(AVG(active_users), 0) AS avg_active_users
FROM analytics.hourly_traffic
GROUP BY hour_of_day
ORDER BY page_views DESC;


-- 4. Trafic par jour de la semaine
SELECT
    EXTRACT(ISODOW FROM activity_date)::INTEGER AS weekday_number,
    TO_CHAR(activity_date, 'Day') AS weekday,
    SUM(page_views) AS page_views,
    COUNT(DISTINCT client_id) AS active_users
FROM analytics.user_daily_activity
GROUP BY
    EXTRACT(ISODOW FROM activity_date),
    TO_CHAR(activity_date, 'Day')
ORDER BY weekday_number;