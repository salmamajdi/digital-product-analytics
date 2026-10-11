CREATE TABLE IF NOT EXISTS raw.product_properties (
    sku BIGINT PRIMARY KEY,
    category BIGINT,
    price INTEGER,
    name TEXT
);

CREATE TABLE IF NOT EXISTS raw.product_buy (
    client_id BIGINT,
    event_time TIMESTAMP,
    sku BIGINT
);

CREATE TABLE IF NOT EXISTS raw.add_to_cart (
    client_id BIGINT,
    event_time TIMESTAMP,
    sku BIGINT
);

CREATE TABLE IF NOT EXISTS raw.remove_from_cart (
    client_id BIGINT,
    event_time TIMESTAMP,
    sku BIGINT
);

CREATE TABLE IF NOT EXISTS raw.search_query (
    client_id BIGINT,
    event_time TIMESTAMP,
    query TEXT
);
