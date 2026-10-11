DROP TABLE IF EXISTS analytics.user_first_activity;

CREATE TABLE analytics.user_first_activity AS
SELECT
    client_id,
    MIN(activity_date) AS first_activity_date
FROM analytics.user_daily_activity
GROUP BY client_id;

CREATE UNIQUE INDEX idx_user_first_activity_client
ON analytics.user_first_activity (client_id);

CREATE INDEX idx_user_first_activity_date
ON analytics.user_first_activity (first_activity_date);


DROP TABLE IF EXISTS analytics.retention_by_cohort;

CREATE TABLE analytics.retention_by_cohort AS
SELECT
    f.first_activity_date AS cohort_date,

    COUNT(DISTINCT f.client_id) AS cohort_size,

    COUNT(DISTINCT CASE
        WHEN a.activity_date = f.first_activity_date + 1
        THEN f.client_id
    END) AS retained_d1,

    COUNT(DISTINCT CASE
        WHEN a.activity_date = f.first_activity_date + 7
        THEN f.client_id
    END) AS retained_d7,

    COUNT(DISTINCT CASE
        WHEN a.activity_date = f.first_activity_date + 30
        THEN f.client_id
    END) AS retained_d30

FROM analytics.user_first_activity f

LEFT JOIN analytics.user_daily_activity a
    ON a.client_id = f.client_id
   AND a.activity_date IN (
        f.first_activity_date + 1,
        f.first_activity_date + 7,
        f.first_activity_date + 30
   )

GROUP BY f.first_activity_date;


ALTER TABLE analytics.retention_by_cohort
ADD COLUMN retention_d1 NUMERIC;

ALTER TABLE analytics.retention_by_cohort
ADD COLUMN retention_d7 NUMERIC;

ALTER TABLE analytics.retention_by_cohort
ADD COLUMN retention_d30 NUMERIC;


UPDATE analytics.retention_by_cohort
SET
    retention_d1 = ROUND(
        100.0 * retained_d1 / NULLIF(cohort_size, 0),
        2
    ),

    retention_d7 = ROUND(
        100.0 * retained_d7 / NULLIF(cohort_size, 0),
        2
    ),

    retention_d30 = ROUND(
        100.0 * retained_d30 / NULLIF(cohort_size, 0),
        2
    );


CREATE INDEX idx_retention_cohort_date
ON analytics.retention_by_cohort (cohort_date);

ANALYZE analytics.user_first_activity;
ANALYZE analytics.retention_by_cohort;