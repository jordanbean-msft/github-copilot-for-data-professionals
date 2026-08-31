"""Profile incoming supply-chain data and produce a compact quality summary."""

from __future__ import annotations

from pathlib import Path

import pandas as pd


def get_data_dir() -> Path:
    fabric_files = Path("/lakehouse/default/Files/copilot-demo")
    if fabric_files.exists():
        return fabric_files
    if "__file__" in globals():
        return Path(__file__).resolve().parents[1] / "data"
    return Path.cwd() / "examples" / "data"


def profile_dataframe(df: pd.DataFrame, name: str) -> pd.DataFrame:
    rows = []
    for column in df.columns:
        values = df[column]
        rows.append(
            {
                "table": name,
                "column": column,
                "dtype": str(values.dtype),
                "rows": len(df),
                "missing": int(values.isna().sum() + (values.astype(str).str.strip() == "").sum()),
                "distinct": int(values.nunique(dropna=True)),
                "sample": str(values.dropna().head(1).iloc[0]) if values.notna().any() else "",
            }
        )
    return pd.DataFrame(rows)


def main() -> None:
    data_dir = get_data_dir()
    purchase_orders = pd.read_csv(data_dir / "purchase_orders.csv")
    shipments = pd.read_csv(data_dir / "shipments.csv", parse_dates=["promised_date", "delivered_date"])
    inventory = pd.read_csv(data_dir / "inventory_snapshots.csv", parse_dates=["snapshot_date"])

    profile = pd.concat(
        [
            profile_dataframe(purchase_orders, "purchase_orders"),
            profile_dataframe(shipments, "shipments"),
            profile_dataframe(inventory, "inventory_snapshots"),
        ],
        ignore_index=True,
    )

    print(profile.to_string(index=False))
    print("\nCopilot prompt: Generate supply-chain data quality rules from this profile and explain why each matters.")


if __name__ == "__main__":
    main()
