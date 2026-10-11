import pandas as pd
from pathlib import Path

DATA_DIR = Path(r"C:\digital-product-analytics\data\raw")

products = pd.read_parquet(DATA_DIR / "product_properties.parquet")

print(products.shape)
print(products["sku"].nunique())
print(products["sku"].duplicated().sum())

buys = pd.read_parquet(
    DATA_DIR / "product_buy.parquet",
    columns=["sku"]
)
unknown_skus = ~buys["sku"].isin(products["sku"])
print("Achats avec SKU inconnu :", unknown_skus.sum())

event_files = [
    "product_buy.parquet",
    "add_to_cart.parquet",
    "remove_from_cart.parquet"
]
for file_name in event_files:
    events = pd.read_parquet(
        DATA_DIR / file_name,
        columns=["sku"]
    )

    unknown_skus = ~events["sku"].isin(products["sku"])

    print(file_name, ":", unknown_skus.sum(), "SKU inconnus")