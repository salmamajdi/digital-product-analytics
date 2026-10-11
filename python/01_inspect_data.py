from pathlib import Path 
import pyarrow.parquet as pq

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = PROJECT_ROOT / "data" / "raw"

for file in sorted(DATA_DIR.glob("*.parquet")):
    parquet_file = pq.ParquetFile(file)

    print("\n" + "=" *70)
    print(f"Fichier : {file.name}")
    print(f"Taille : {file.stat().st_size / (1024**2):,.2f}")
    print(f"Nombre de lignes : {parquet_file.metadata.num_rows:,}")
    print(f"Nombre de colonnes : {parquet_file.metadata.num_columns}")

    print("\nColonnes :")
    for column in parquet_file.schema_arrow:
        print(f" - {column.name} : {column.type}")