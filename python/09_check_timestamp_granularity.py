import pandas as pd
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = PROJECT_ROOT / "data" / "raw"

timestamps = pd.read_parquet(
    DATA_DIR / "product_buy.parquet",
    columns=["timestamp"]
)

seconds = timestamps["timestamp"].str[-2:]

print(seconds.value_counts().sort_index())