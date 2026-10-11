import pandas as pd
from pathlib import Path

DATA_DIR = Path(r"C:\digital-product-analytics\data\raw")

buys = pd.read_parquet(DATA_DIR / "product_buy.parquet")

duplicates = buys.duplicated()

print("Nombre de lignes :", len(buys))
print("Doublons exacts :", duplicates.sum())
duplicate_rows = buys[buys.duplicated(keep=False)]

print(duplicate_rows.head(20))
group_sizes = buys.groupby(
    ["client_id", "timestamp", "sku"]
).size()

print(group_sizes.value_counts().sort_index())

five_times = group_sizes[group_sizes == 5]

print(five_times.head())