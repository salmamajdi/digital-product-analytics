import pandas as pd
from pathlib import Path

DATA_DIR = Path(r"C:\digital-product-analytics\data\raw")

timestamps = pd.read_parquet(
    DATA_DIR / "product_buy.parquet",
    columns=["timestamp"]
)

seconds = timestamps["timestamp"].str[-2:]

print(seconds.value_counts().sort_index())