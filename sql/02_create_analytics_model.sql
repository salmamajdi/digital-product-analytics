DROP TABLE IF EXISTS analytics.products CASCADE;

CREATE TABLE analytics.products AS
SELECT
    sku,
    category,
    price,
    name
FROM raw.product_properties;

ALTER TABLE analytics.products
ADD PRIMARY KEY (sku);


DROP TABLE IF EXISTS analytics.product_events;

CREATE TABLE analytics.product_events AS

SELECT
    client_id,
    event_time,
    sku,
    'add_to_cart' AS event_type,
    COUNT(*)::INTEGER AS occurrence_count
FROM raw.add_to_cart
GROUP BY client_id, event_time, sku

UNION ALL

SELECT
    client_id,
    event_time,
    sku,
    'remove_from_cart' AS event_type,
    COUNT(*)::INTEGER AS occurrence_count
FROM raw.remove_from_cart
GROUP BY client_id, event_time, sku

UNION ALL

SELECT
    client_id,
    event_time,
    sku,
    'product_buy' AS event_type,
    COUNT(*)::INTEGER AS occurrence_count
FROM raw.product_buy
GROUP BY client_id, event_time, sku;


CREATE INDEX idx_product_events_client_time
ON analytics.product_events (client_id, event_time);

CREATE INDEX idx_product_events_sku
ON analytics.product_events (sku);

CREATE INDEX idx_product_events_type_time
ON analytics.product_events (event_type, event_time);


DROP TABLE IF EXISTS analytics.search_events;

CREATE TABLE analytics.search_events AS
SELECT
    client_id,
    event_time,
    query,
    COUNT(*)::INTEGER AS occurrence_count
FROM raw.search_query
GROUP BY client_id, event_time, query;

CREATE INDEX idx_search_events_client_time
ON analytics.search_events (client_id, event_time);


ANALYZE analytics.products;
ANALYZE analytics.product_events;
ANALYZE analytics.search_events;