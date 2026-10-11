from pathlib import Path
from getpass import getpass
import io

import pyarrow.parquet as pq
import psycopg


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = PROJECT_ROOT / "data" / "raw"

TABLES = {
    "product_buy.parquet": {
        "table": "raw.product_buy",
        "columns": ["client_id", "timestamp", "sku"],
        "db_columns": ["client_id", "event_time", "sku"]
    },
    "add_to_cart.parquet": {
        "table": "raw.add_to_cart",
        "columns": ["client_id", "timestamp", "sku"],
        "db_columns": ["client_id", "event_time", "sku"]
    },
    "remove_from_cart.parquet": {
        "table": "raw.remove_from_cart",
        "columns": ["client_id", "timestamp", "sku"],
        "db_columns": ["client_id", "event_time", "sku"]
    },
    "search_query.parquet": {
        "table": "raw.search_query",
        "columns": ["client_id", "timestamp", "query"],
        "db_columns": ["client_id", "event_time", "query"]
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

            column_list = ", ".join(config["db_columns"])

            copy_sql = (
                f"COPY {config['table']} ({column_list}) "
                "FROM STDIN WITH (FORMAT CSV)"
            )

            total_rows = 0

            with cur.copy(copy_sql) as copy:

                for batch in parquet_file.iter_batches(
                    batch_size=100000,
                    columns=config["columns"]
                ):

                    df = batch.to_pandas()

                    buffer = io.StringIO()

                    df.to_csv(
                        buffer,
                        index=False,
                        header=False
                    )

                    copy.write(buffer.getvalue())

                    total_rows += len(df)

                    print(
                        f"{config['table']} : "
                        f"{total_rows:,} lignes"
                    )

            print(f"Terminé : {config['table']}")

    conn.commit()

print("\nTous les chargements sont terminés.")