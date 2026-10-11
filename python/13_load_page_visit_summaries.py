from pathlib import Path
from getpass import getpass
import io

import pyarrow.parquet as pq
import psycopg


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = PROJECT_ROOT / "data" / "processed"

TABLES = {
    "user_daily_activity.parquet": {
        "table": "analytics.user_daily_activity",
        "columns": [
            "client_id",
            "activity_date",
            "page_views",
            "unique_urls",
            "first_visit_time",
            "last_visit_time"
        ]
    },
    "hourly_traffic.parquet": {
        "table": "analytics.hourly_traffic",
        "columns": [
            "traffic_hour",
            "page_views",
            "active_users",
            "unique_urls"
        ]
    }
}

password = getpass("Mot de passe PostgreSQL : ")

with psycopg.connect(
    host="localhost",
    port=5432,
    dbname="digital_product_analytics",
    user="postgres",
    password=password
) as conn:

    with conn.cursor() as cur:

        for file_name, config in TABLES.items():

            print(f"\nChargement de {file_name}")

            cur.execute(f"TRUNCATE TABLE {config['table']};")

            parquet_file = pq.ParquetFile(DATA_DIR / file_name)

            column_list = ", ".join(config["columns"])

            copy_sql = (
                f"COPY {config['table']} ({column_list}) "
                "FROM STDIN WITH (FORMAT CSV)"
            )

            total_rows = 0

            with cur.copy(copy_sql) as copy:

                for batch in parquet_file.iter_batches(batch_size=100000):

                    df = batch.to_pandas()

                    buffer = io.StringIO()

                    df.to_csv(
                        buffer,
                        index=False,
                        header=False
                    )

                    copy.write(buffer.getvalue())

                    total_rows += len(df)

                    print(f"{config['table']} : {total_rows:,} lignes")

    conn.commit()

print("\nChargement terminé.")