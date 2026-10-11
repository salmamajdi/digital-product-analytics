-- KPI GLOBAUX
CREATE OR REPLACE VIEW analytics.dashboard_kpis AS

WITH visitors AS (
    SELECT DISTINCT client_id
    FROM analytics.user_daily_activity
),

cart_users AS (
    SELECT DISTINCT client_id
    FROM analytics.product_events
    WHERE event_type = 'add_to_cart'
),

buyers AS (
    SELECT DISTINCT client_id
    FROM analytics.product_events
    WHERE event_type = 'product_buy'
),

retention AS (
    SELECT
        ROUND(
            100.0 * SUM(retained_d1) / SUM(cohort_size),
            2
        ) AS d1_retention,

        ROUND(
            100.0 * SUM(retained_d7) / SUM(cohort_size),
            2
        ) AS d7_retention,

        ROUND(
            100.0 * SUM(retained_d30) / SUM(cohort_size),
            2
        ) AS d30_retention

    FROM analytics.retention_by_cohort

    WHERE cohort_date <= (
        SELECT MAX(activity_date) - 30
        FROM analytics.user_daily_activity
    )
)

SELECT
    (SELECT COUNT(*) FROM visitors) AS total_visitors,

    (
        SELECT SUM(page_views)
        FROM analytics.user_daily_activity
    ) AS total_page_views,

    (SELECT COUNT(*) FROM cart_users) AS total_cart_users,

    (SELECT COUNT(*) FROM buyers) AS total_buyers,

    ROUND(
        100.0 * (
            SELECT COUNT(*)
            FROM cart_users c
            JOIN visitors v
                ON c.client_id = v.client_id
        )
        / (SELECT COUNT(*) FROM visitors),
        2
    ) AS observed_visit_to_cart_rate,

    ROUND(
        100.0 * (
            SELECT COUNT(*)
            FROM buyers b
            JOIN visitors v
                ON b.client_id = v.client_id
        )
        / (SELECT COUNT(*) FROM visitors),
        2
    ) AS observed_visit_to_purchase_rate,

    r.d1_retention,
    r.d7_retention,
    r.d30_retention

FROM retention r;


-- TRAFIC QUOTIDIEN
CREATE OR REPLACE VIEW analytics.daily_traffic AS

SELECT
    activity_date,
    SUM(page_views) AS page_views,
    COUNT(DISTINCT client_id) AS active_users
FROM analytics.user_daily_activity
GROUP BY activity_date;


-- PATTERN HORAIRE
CREATE OR REPLACE VIEW analytics.hourly_pattern AS

SELECT
    EXTRACT(HOUR FROM traffic_hour)::INTEGER AS hour_of_day,
    SUM(page_views) AS page_views,
    ROUND(AVG(active_users), 0) AS avg_active_users
FROM analytics.hourly_traffic
GROUP BY hour_of_day;


-- PATTERN JOUR DE SEMAINE
CREATE OR REPLACE VIEW analytics.weekday_pattern AS

SELECT
    EXTRACT(ISODOW FROM activity_date)::INTEGER AS weekday_number,
    TRIM(TO_CHAR(activity_date, 'Day')) AS weekday,
    SUM(page_views) AS page_views,
    COUNT(DISTINCT client_id) AS active_users
FROM analytics.user_daily_activity
GROUP BY
    EXTRACT(ISODOW FROM activity_date),
    TRIM(TO_CHAR(activity_date, 'Day'));


-- PERFORMANCE CATÉGORIES
CREATE OR REPLACE VIEW analytics.category_performance AS

SELECT
    category,
    SUM(cart_users) AS cart_users,
    SUM(buyers_after_cart) AS buyers_after_cart,

    ROUND(
        100.0 * SUM(buyers_after_cart)
        / NULLIF(SUM(cart_users), 0),
        2
    ) AS conversion_rate

FROM analytics.product_performance
GROUP BY category;


-- PRODUITS À FORTE FRICTION
CREATE OR REPLACE VIEW analytics.product_opportunities AS

SELECT
    sku,
    category,
    price,
    cart_users,
    buyers_after_cart,
    cart_to_purchase_rate

FROM analytics.product_performance

WHERE cart_users >= 100;