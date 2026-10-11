from pathlib import Path
import pyarrow.parquet as pq

DATA_DIR = Path(r"C:\digital-product-analytics\data\raw")

for file in sorted(DATA_DIR.glob("*.parquet")):
    parquet_file = pq.ParquetFile(file)

    first_batch = next(parquet_file.iter_batches(batch_size=5))
    preview = first_batch.to_pandas()

    print("\n" + "=" * 70)
    print(f"Fichier : {file.name}")
    print(preview.to_string(index=False))