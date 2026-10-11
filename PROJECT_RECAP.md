# Digital Product Analytics — Project Recap & Revision Sheet

## 1. Project in one sentence

An end-to-end e-commerce product analytics platform that transforms large Parquet behavioral datasets into a PostgreSQL analytical model and Power BI dashboard using Python, DuckDB and SQL.

## 2. End-to-end pipeline

```text
Raw Parquet files
        ↓
Python profiling and validation
        ↓
Raw PostgreSQL tables
        ↓
Analytical SQL model
        ↓
DuckDB aggregation for 199M page views
        ↓
PostgreSQL analytics tables
        ↓
Business analyses
        ↓
BI serving tables
        ↓
Power BI dashboard
```

## 3. Why each technology was used

**Python:** profiling, validation, ingestion and orchestration.

**Pandas:** targeted exploration, duplicates, grouping and counts.

**PyArrow:** Parquet access.

**DuckDB:** direct aggregation of the ~199M-row page-view Parquet file without first loading every row into PostgreSQL.

**PostgreSQL:** raw layer, analytics layer, indexes, reusable SQL logic and BI connectivity.

**Power BI:** dashboard and business reporting.

## 4. Database architecture

Two main schemas:

**raw** = minimally transformed source data.

**analytics** = business-ready analytical structures and BI serving tables.

## 5. SQL syntax to remember

```sql
CREATE SCHEMA IF NOT EXISTS analytics;

SELECT column_1, column_2
FROM table_name
WHERE value >= 100;

SELECT
    category,
    COUNT(*) AS events
FROM table_name
GROUP BY category;

COUNT(DISTINCT client_id)
```

CTE:

```sql
WITH first_cart AS (
    SELECT
        client_id,
        MIN(event_time) AS first_cart_time
    FROM analytics.product_events
    WHERE event_type = 'add_to_cart'
    GROUP BY client_id
)
SELECT *
FROM first_cart;
```

Join:

```sql
SELECT *
FROM table_a a
LEFT JOIN table_b b
    ON a.id = b.id;
```

Index:

```sql
CREATE INDEX idx_example
ON analytics.product_events (client_id, event_time);
```

## 6. Python syntax to remember

```python
import pandas as pd
import pyarrow.parquet as pq
import psycopg

df = pd.read_parquet("file.parquet")
print(df.head())
print(df.isna().sum())
print(df.duplicated().sum())
```

Group and count:

```python
counts = (
    df.groupby(["client_id", "timestamp", "sku"])
      .size()
      .reset_index(name="occurrence_count")
)
```

## 7. Data-quality investigation

No nulls were detected in the main source datasets through Parquet metadata checks.

Product integrity:

- 1,534,050 rows
- 1,534,050 unique SKUs
- 0 duplicate SKU
- 0 unknown SKU in cart/purchase/remove events

Repeated events:

`product_buy` contained **380,903 duplicate rows** according to pandas `.duplicated()`.

Decision: do not blindly delete them. Aggregate exact event repetitions and preserve the frequency in `occurrence_count`.

## 8. Page-view processing decision

The page-view file contains **199,451,980 rows**.

DuckDB created:

- `user_daily_activity`: 46,321,799 rows
- `hourly_traffic`: 4,033 rows

Both reconcile to exactly **199,451,980 page views**.

Interview point: process at the granularity required by the use case instead of moving hundreds of millions of rows unnecessarily.

## 9. Traffic analysis

- Visitors: **21,993,998**
- Page views: **199,451,980**
- Avg views / visitor: **9.07**
- Active days: **169**
- Peak hour: **19:00**
- Highest weekday: **Sunday**
- Lowest weekday: **Saturday**

## 10. Funnel analysis

Observed funnel:

- Visitors observed in page visits: **21,993,998**
- Cart users among observed visitors: **2,295,307**
- Buyers among observed visitors: **640,340**
- Visit → Cart: **10.44%**
- Visit → Purchase: **2.91%**

Chronological cart-to-purchase:

- Users with cart: **2,333,463**
- Bought after first cart: **565,203**
- Cart → Purchase: **24.22%**

Important validation:

- All buyers: **909,210**
- Buyers without page visit: **268,870**

Therefore 2.91% must be described as an observed conversion rate, not an absolute platform-wide conversion rate.

## 11. Product performance

For each SKU:

- `cart_users`
- `buyers_after_cart`
- `cart_to_purchase_rate`

Formula:

```text
buyers_after_cart / cart_users × 100
```

Leading category examples with meaningful cart volume:

- Category 5039: **33.51%**
- Category 4736: **33.25%**
- Category 3486: **32.77%**
- Category 1096: **32.39%**
- Category 2964: **31.42%**

## 12. Retention analysis

Cohort = first activity date.

Exact-return retention:

- D1: **5.95%**
- D7: **2.31%**
- D30: **1.19%**

Only mature cohorts are used when enough future observation time exists.

## 13. BI serving layer

Power BI querying heavy analytical views caused stream/ODBC instability.

Solution: create small physical BI tables from the analytical views.

- `bi_dashboard_kpis`: 1 row
- `bi_daily_traffic`: 169 rows
- `bi_hourly_pattern`: 24 rows
- `bi_weekday_pattern`: 7 rows
- `bi_category_performance`: 6,912 rows
- `bi_product_opportunities`: 5,622 rows
- `bi_retention_by_cohort`: 169 rows

These are serving tables derived from the full analysis, not a reduction in analytical scope.

## 14. Power BI lessons

- Use the raw date field instead of the automatic Year/Quarter/Month/Day hierarchy when needed.
- Numeric category IDs may need a categorical axis.
- Check whether numeric fields are being Counted, Summed, Averaged or not summarized.
- Rates already stored as 10.44 should not be formatted again as Power BI percentage, otherwise they become 1044%.

## 15. Dashboard pages

### Overview

- Visitors: 21.99M
- Page Views: 199.45M
- Cart Users: 2.33M
- Buyers: 909K
- Visit → Cart: 10.44
- Visit → Purchase: 2.91
- Daily Page Views
- Page Views by Hour
- Page Views by Weekday

### Conversion & Retention

- D1 Retention: 5.95
- D7 Retention: 2.31
- D30 Retention: 1.19
- Retention by Cohort
- Top Categories by Conversion Rate
- Product Opportunities

## 16. Interview talking points

**Why DuckDB?**  
The page-view source contains ~199M rows and the BI use case only required daily/hourly aggregates. DuckDB queried Parquet directly and avoided an unnecessary full PostgreSQL load.

**Why preserve repeated events?**  
Identical events were not automatically assumed to be errors. They were grouped into `occurrence_count` so frequency information was preserved.

**Why raw and analytics schemas?**  
To separate ingestion from business logic and make lineage, debugging and future changes easier.

**Why BI tables instead of views?**  
Heavy views were expensive to recompute from Power BI. Small serving tables improved performance and stability.

**Most important validation finding?**  
Many buyers had no corresponding page-view record, so observed visit-to-purchase conversion is not equivalent to global platform conversion.

## 17. Strong CV bullets

**Digital Product Analytics Platform — Python, SQL, PostgreSQL, DuckDB, Power BI**

- Built an end-to-end analytics pipeline over an e-commerce behavioral dataset containing more than 200M page-view events.
- Profiled and validated Parquet data, investigated repeated events and designed PostgreSQL raw and analytical schemas.
- Used DuckDB to aggregate a 199M-row page-view dataset efficiently before loading business-ready summaries into PostgreSQL.
- Developed SQL analyses for traffic, conversion funnels, product performance and D1/D7/D30 cohort retention.
- Created a Power BI dashboard covering 21.99M observed visitors, 199.45M page views, conversion KPIs, retention and product opportunities.
- Added validation logic to distinguish observed funnel conversion from platform-wide conversion where source coverage was incomplete.

## 18. Short interview pitch

I built a product analytics platform using a real large-scale e-commerce behavior dataset. The project starts with raw Parquet files, includes Python-based profiling and quality checks, PostgreSQL raw and analytics layers, and SQL analyses for traffic, conversion, product performance and cohort retention. The page-view file alone had about 199 million rows, so instead of loading it blindly into PostgreSQL, I used DuckDB to aggregate it directly from Parquet at the granularity needed by the dashboard. I then created a lightweight BI serving layer and a two-page Power BI dashboard. One of the most important findings was that many buyers had no corresponding page-view record, so I explicitly separated observed visit-to-purchase conversion from true platform-wide conversion.
