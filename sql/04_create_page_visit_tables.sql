DROP TABLE IF EXISTS analytics.user_daily_activity;

CREATE TABLE analytics.user_daily_activity (
    client_id BIGINT,
    activity_date DATE,
    page_views BIGINT,
    unique_urls BIGINT,
    first_visit_time TIMESTAMP,
    last_visit_time TIMESTAMP
);

DROP TABLE IF EXISTS analytics.hourly_traffic;

CREATE TABLE analytics.hourly_traffic (
    traffic_hour TIMESTAMP,
    page_views BIGINT,
    active_users BIGINT,
    unique_urls BIGINT
);

CREATE INDEX idx_daily_activity_client_date
ON analytics.user_daily_activity (client_id, activity_date);

CREATE INDEX idx_daily_activity_date
ON analytics.user_daily_activity (activity_date);

CREATE INDEX idx_hourly_traffic_time
ON analytics.hourly_traffic (traffic_hour);
