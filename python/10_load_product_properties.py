from pathlib import Path
from getpass import getpass
import io

import pandas as pd
import pyarrow.parquet as pq
import psycopg


PARQUET_PATH = Path(
    r"C:\digital-product-analytics\data\raw\product_properties.parquet"
)

password = getpass("Mot de passe PostgreSQL : ")


with psycopg.connect(
    host="localhost",
    port=5432,
    dbname="digital_product_analytics",
    user="postgres",
    password=password
) as conn:

    with conn.cursor() as cur:

        cur.execute("TRUNCATE TABLE raw.product_properties;")

        parquet_file = pq.ParquetFile(PARQUET_PATH)

        total_rows = 0

        with cur.copy(
            "COPY raw.product_properties (sku, category, price, name) "
            "FROM STDIN WITH (FORMAT CSV)"
        ) as copy:

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

                print(f"Lignes chargées : {total_rows:,}")

    conn.commit()

print("Chargement terminé.")