SELECT
    event_type,
    COUNT(*) AS unique_events,
    SUM(occurrence_count) AS raw_occurrences
FROM analytics.product_events
GROUP BY event_type
ORDER BY event_type;

SELECT COUNT(*) AS products
FROM analytics.products;

SELECT COUNT(*) AS search_events
FROM analytics.search_events;