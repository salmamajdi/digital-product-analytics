DROP TABLE IF EXISTS analytics.product_performance;

CREATE TABLE analytics.product_performance AS

WITH first_cart AS (
    SELECT
        client_id,
        sku,
        MIN(event_time) AS first_cart_time
    FROM analytics.product_events
    WHERE event_type = 'add_to_cart'
    GROUP BY client_id, sku
),

buyers_after_cart AS (
    SELECT DISTINCT
        c.client_id,
        c.sku
    FROM first_cart c
    JOIN analytics.product_events p
        ON p.client_id = c.client_id
       AND p.sku = c.sku
       AND p.event_type = 'product_buy'
       AND p.event_time >= c.first_cart_time
),

cart_metrics AS (
    SELECT
        sku,
        COUNT(*) AS cart_users
    FROM first_cart
    GROUP BY sku
),

purchase_metrics AS (
    SELECT
        sku,
        COUNT(*) AS buyers_after_cart
    FROM buyers_after_cart
    GROUP BY sku
)

SELECT
    p.sku,
    p.category,
    p.price,

    COALESCE(c.cart_users, 0) AS cart_users,
    COALESCE(b.buyers_after_cart, 0) AS buyers_after_cart,

    ROUND(
        100.0 * COALESCE(b.buyers_after_cart, 0)
        / NULLIF(c.cart_users, 0),
        2
    ) AS cart_to_purchase_rate

FROM analytics.products p

LEFT JOIN cart_metrics c
    ON p.sku = c.sku

LEFT JOIN purchase_metrics b
    ON p.sku = b.sku;


CREATE INDEX idx_product_performance_category
ON analytics.product_performance (category);

CREATE INDEX idx_product_performance_conversion
ON analytics.product_performance (cart_to_purchase_rate);

ANALYZE analytics.product_performance;