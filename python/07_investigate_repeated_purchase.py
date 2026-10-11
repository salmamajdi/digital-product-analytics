import pandas as pd
from pathlib import Path

DATA_DIR = Path(r"C:\digital-product-analytics\data\raw")

client_id = 787276
sku = 782583
event_files = [
    "add_to_cart.parquet",
    "remove_from_cart.parquet",
    "product_buy.parquet"
]
for file_name in event_files:
    events = pd.read_parquet(
        DATA_DIR / file_name,
        filters=[
            ("client_id", "==", client_id),
            ("sku", "==", sku)
        ]
    )

    print("\n", file_name)
    print(events.sort_values("timestamp").to_string(index=False))