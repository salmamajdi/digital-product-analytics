from pathlib import Path
import pyarrow.parquet as pq

DATA_DIR = Path(r"C:\digital-product-analytics\data\raw")

for file in sorted(DATA_DIR.glob("*.parquet")):
    parquet_file = pq.ParquetFile(file)

    print("\n" + "=" * 70)
    print(f"Fichier : {file.name}")

    for column_index, column_name in enumerate(parquet_file.schema.names):

        null_count = 0
        min_value = None
        max_value = None
    
        for row_group_index in range(parquet_file.metadata.num_row_groups):
            column = parquet_file.metadata.row_group(row_group_index).column(column_index)
            stats = column.statistics

            if stats is not None:
                if stats.null_count is not None:
                    null_count += stats.null_count

                if stats.has_min_max:
                    if min_value is None or stats.min < min_value:
                        min_value = stats.min

                    if max_value is None or stats.max > max_value:
                        max_value = stats.max

        print(f"\nColonne : {column_name}")
        print(f"Valeurs nulles : {null_count:,}")

        if column_name == "timestamp":
            print(f"Date minimum : {min_value}")
            print(f"Date maximum : {max_value}")