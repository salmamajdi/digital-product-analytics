DROP TABLE IF EXISTS analytics.bi_dashboard_kpis;
CREATE TABLE analytics.bi_dashboard_kpis AS
SELECT * FROM analytics.dashboard_kpis;


DROP TABLE IF EXISTS analytics.bi_daily_traffic;
CREATE TABLE analytics.bi_daily_traffic AS
SELECT * FROM analytics.daily_traffic;


DROP TABLE IF EXISTS analytics.bi_hourly_pattern;
CREATE TABLE analytics.bi_hourly_pattern AS
SELECT * FROM analytics.hourly_pattern;


DROP TABLE IF EXISTS analytics.bi_weekday_pattern;
CREATE TABLE analytics.bi_weekday_pattern AS
SELECT * FROM analytics.weekday_pattern;


DROP TABLE IF EXISTS analytics.bi_category_performance;
CREATE TABLE analytics.bi_category_performance AS
SELECT * FROM analytics.category_performance;


DROP TABLE IF EXISTS analytics.bi_product_opportunities;
CREATE TABLE analytics.bi_product_opportunities AS
SELECT * FROM analytics.product_opportunities;


DROP TABLE IF EXISTS analytics.bi_retention_by_cohort;
CREATE TABLE analytics.bi_retention_by_cohort AS
SELECT *
FROM analytics.retention_by_cohort;

SELECT 'dashboard_kpis' AS table_name, COUNT(*) FROM analytics.bi_dashboard_kpis
UNION ALL
SELECT 'daily_traffic', COUNT(*) FROM analytics.bi_daily_traffic
UNION ALL
SELECT 'hourly_pattern', COUNT(*) FROM analytics.bi_hourly_pattern
UNION ALL
SELECT 'weekday_pattern', COUNT(*) FROM analytics.bi_weekday_pattern
UNION ALL
SELECT 'category_performance', COUNT(*) FROM analytics.bi_category_performance
UNION ALL
SELECT 'product_opportunities', COUNT(*) FROM analytics.bi_product_opportunities
UNION ALL
SELECT 'retention_by_cohort', COUNT(*) FROM analytics.bi_retention_by_cohort;