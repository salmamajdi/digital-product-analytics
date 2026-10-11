from pathlib import Path
import pyarrow.parquet as pq

DATA_DIR = Path(r"C:\digital-product-analytics\data\raw")

product_file = pq.ParquetFile(DATA_DIR / "product_properties.parquet")
search_file = pq.ParquetFile(DATA_DIR / "search_query.parquet")

product_sample = next(product_file.iter_batches(batch_size=1)).to_pandas()
search_sample = next(search_file.iter_batches(batch_size=1)).to_pandas()

print("PRODUCT NAME")
print(product_sample["name"].iloc[0])
print(type(product_sample["name"].iloc[0]))
print(repr(product_sample["name"].iloc[0]))

print("\nSEARCH QUERY")
print(search_sample["query"].iloc[0])
print(type(search_sample["query"].iloc[0]))
print(repr(search_sample["query"].iloc[0]))