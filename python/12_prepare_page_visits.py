from pathlib import Path
import duckdb

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = PROJECT_ROOT / "data" / "raw"
OUTPUT_DIR = PROJECT_ROOT / "data" / "processed"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

source = str(DATA_DIR / "page_visit.parquet").replace("\\", "/")
daily_output = str(OUTPUT_DIR / "user_daily_activity.parquet").replace("\\", "/")
hourly_output = str(OUTPUT_DIR / "hourly_traffic.parquet").replace("\\", "/")

con = duckdb.connect()

print("Création de user_daily_activity...")

con.execute(f"""
COPY (
    SELECT
        client_id,
        CAST(timestamp AS DATE) AS activity_date,
        COUNT(*) AS page_views,
        COUNT(DISTINCT url) AS unique_urls,
        MIN(CAST(timestamp AS TIMESTAMP)) AS first_visit_time,
        MAX(CAST(timestamp AS TIMESTAMP)) AS last_visit_time
    FROM read_parquet('{source}')
    GROUP BY
        client_id,
        CAST(timestamp AS DATE)
)
TO '{daily_output}'
(FORMAT PARQUET, COMPRESSION ZSTD);
""")

print("Création de hourly_traffic...")

con.execute(f"""
COPY (
    SELECT
        DATE_TRUNC('hour', CAST(timestamp AS TIMESTAMP)) AS traffic_hour,
        COUNT(*) AS page_views,
        COUNT(DISTINCT client_id) AS active_users,
        COUNT(DISTINCT url) AS unique_urls
    FROM read_parquet('{source}')
    GROUP BY
        DATE_TRUNC('hour', CAST(timestamp AS TIMESTAMP))
)
TO '{hourly_output}'
(FORMAT PARQUET, COMPRESSION ZSTD);
""")

con.close()

print("Terminé.")