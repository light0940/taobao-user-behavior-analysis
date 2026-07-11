from pathlib import Path

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parent
SOURCE = PROJECT_ROOT / "raw_data" / "UserBehavior.csv"
OUTPUT = PROJECT_ROOT / "raw_data" / "UserBehavior_sample_1pct.csv"

COLUMNS = [
    "user_id",
    "item_id",
    "category_id",
    "behavior_type",
    "timestamp",
]

DTYPES = {
    "user_id": "int32",
    "item_id": "int32",
    "category_id": "int32",
    "behavior_type": "category",
    "timestamp": "int64",
}

CHUNK_SIZE = 500_000


def main() -> None:
    if not SOURCE.exists():
        raise FileNotFoundError(f"找不到原始文件：{SOURCE}")

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    if OUTPUT.exists():
        OUTPUT.unlink()

    processed_rows = 0
    selected_rows = 0
    first_chunk = True

    for chunk in pd.read_csv(
        SOURCE,
        header=None,
        names=COLUMNS,
        dtype=DTYPES,
        chunksize=CHUNK_SIZE,
    ):
        sample = chunk[chunk["user_id"] % 100 == 0]

        sample.to_csv(
            OUTPUT,
            mode="w" if first_chunk else "a",
            header=first_chunk,
            index=False,
            encoding="utf-8",
        )

        processed_rows += len(chunk)
        selected_rows += len(sample)
        first_chunk = False

        print(f"已处理 {processed_rows:,} 行，保留 {selected_rows:,} 行")

    print("\n抽样完成")
    print(f"输出文件：{OUTPUT}")
    print(f"样本记录数：{selected_rows:,}")
    print(f"文件大小：{OUTPUT.stat().st_size / 1024 / 1024:.2f} MB")


if __name__ == "__main__":
    main()
