from pathlib import Path

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parent
SOURCE = PROJECT_ROOT / "raw_data" / "UserBehavior_sample_1pct.csv"
OUTPUT = PROJECT_ROOT / "raw_data" / "UserBehavior_clean.csv"

DTYPES = {
    "user_id": "int32",
    "item_id": "int32",
    "category_id": "int32",
    "behavior_type": "category",
    "timestamp": "int64",
}

VALID_BEHAVIORS = {"pv", "cart", "fav", "buy"}


def main() -> None:
    if not SOURCE.exists():
        raise FileNotFoundError(f"找不到样本文件：{SOURCE}")

    df = pd.read_csv(SOURCE, dtype=DTYPES)

    print("原始样本行数：", f"{len(df):,}")
    print("\n缺失值：")
    print(df.isna().sum())

    print("\n完全重复行数：", f"{df.duplicated().sum():,}")

    print("\n行为类型分布：")
    print(df["behavior_type"].value_counts())

    invalid_count = (~df["behavior_type"].isin(VALID_BEHAVIORS)).sum()
    print("\n异常行为类型行数：", f"{invalid_count:,}")

    df_clean = df.dropna().drop_duplicates()
    df_clean = df_clean[df_clean["behavior_type"].isin(VALID_BEHAVIORS)].copy()

    df_clean["event_time"] = (
        pd.to_datetime(df_clean["timestamp"], unit="s", utc=True)
        .dt.tz_convert("Asia/Shanghai")
        .dt.tz_localize(None)
    )

    df_clean["event_date"] = df_clean["event_time"].dt.strftime("%Y-%m-%d")
    df_clean["hour"] = df_clean["event_time"].dt.hour.astype("int8")
    df_clean["weekday"] = df_clean["event_time"].dt.dayofweek.astype("int8")

    print("\n清洗后行数：", f"{len(df_clean):,}")
    print("时间范围：", df_clean["event_time"].min(), "至", df_clean["event_time"].max())

    df_clean.to_csv(OUTPUT, index=False, encoding="utf-8")
    print("\n清洗文件已保存：", OUTPUT)


if __name__ == "__main__":
    main()
