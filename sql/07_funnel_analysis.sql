-- Funnel global utilisateurs

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

funnel AS (
    SELECT
        v.client_id,
        CASE WHEN c.client_id IS NOT NULL THEN 1 ELSE 0 END AS added_to_cart,
        CASE WHEN b.client_id IS NOT NULL THEN 1 ELSE 0 END AS purchased
    FROM visitors v
    LEFT JOIN cart_users c
        ON v.client_id = c.client_id
    LEFT JOIN buyers b
        ON v.client_id = b.client_id
)

SELECT
    COUNT(*) AS visitors,
    SUM(added_to_cart) AS cart_users,
    SUM(purchased) AS buyers,

    ROUND(
        100.0 * SUM(added_to_cart) / COUNT(*),
        2
    ) AS visit_to_cart_rate,

    ROUND(
        100.0 * SUM(purchased) / COUNT(*),
        2
    ) AS visit_to_purchase_rate,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN added_to_cart = 1 AND purchased = 1
                THEN 1 ELSE 0
            END
        ) / NULLIF(SUM(added_to_cart), 0),
        2
    ) AS cart_to_purchase_rate

FROM funnel;
WITH first_cart AS (
    SELECT
        client_id,
        MIN(event_time) AS first_cart_time
    FROM analytics.product_events
    WHERE event_type = 'add_to_cart'
    GROUP BY client_id
),

buyers_after_cart AS (
    SELECT DISTINCT
        c.client_id
    FROM first_cart c
    JOIN analytics.product_events p
        ON p.client_id = c.client_id
       AND p.event_type = 'product_buy'
       AND p.event_time >= c.first_cart_time
)

SELECT
    COUNT(*) AS users_with_cart,

    COUNT(b.client_id) AS users_who_bought_after_cart,

    ROUND(
        100.0 * COUNT(b.client_id) / COUNT(*),
        2
    ) AS cart_to_purchase_after_cart_rate

FROM first_cart c
LEFT JOIN buyers_after_cart b
    ON c.client_id = b.client_id;