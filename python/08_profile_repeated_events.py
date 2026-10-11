import pandas as pd
from pathlib import Path

DATA_DIR = Path(r"C:\digital-product-analytics\data\raw")

files = [
    "add_to_cart.parquet",
    "remove_from_cart.parquet"
]

for file_name in files:
    events = pd.read_parquet(DATA_DIR / file_name)

    group_sizes = events.groupby(
        ["client_id", "timestamp", "sku"]
    ).size()

    print("\nFichier :", file_name)
    print(group_sizes.value_counts().sort_index())