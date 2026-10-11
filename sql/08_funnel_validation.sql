WITH visitors AS (
    SELECT DISTINCT client_id
    FROM analytics.user_daily_activity
),

cart_users AS (
    SELECT DISTINCT client_id
    FROM analytics.product_events
    WHERE event_type = 'add_to_cart'
),

buyer_users AS (
    SELECT DISTINCT client_id
    FROM analytics.product_events
    WHERE event_type = 'product_buy'
)

SELECT
    (SELECT COUNT(*) FROM visitors) AS page_visitors,

    (SELECT COUNT(*) FROM cart_users) AS all_cart_users,

    (
        SELECT COUNT(*)
        FROM cart_users c
        JOIN visitors v
            ON c.client_id = v.client_id
    ) AS cart_users_with_page_visit,

    (
        SELECT COUNT(*)
        FROM cart_users c
        LEFT JOIN visitors v
            ON c.client_id = v.client_id
        WHERE v.client_id IS NULL
    ) AS cart_users_without_page_visit,

    (SELECT COUNT(*) FROM buyer_users) AS all_buyers,

    (
        SELECT COUNT(*)
        FROM buyer_users b
        JOIN visitors v
            ON b.client_id = v.client_id
    ) AS buyers_with_page_visit,

    (
        SELECT COUNT(*)
        FROM buyer_users b
        LEFT JOIN visitors v
            ON b.client_id = v.client_id
        WHERE v.client_id IS NULL
    ) AS buyers_without_page_visit;