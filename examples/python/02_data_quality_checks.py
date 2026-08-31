"""Run supply-chain data quality checks that Copilot can help generate and extend."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

import pandas as pd


def get_data_dir() -> Path:
    fabric_files = Path("/lakehouse/default/Files/copilot-demo")
    if fabric_files.exists():
        return fabric_files
    if "__file__" in globals():
        return Path(__file__).resolve().parents[1] / "data"
    return Path.cwd() / "examples" / "data"


@dataclass
class CheckResult:
    name: str
    passed: bool
    failed_rows: int
    message: str


def check_required(df: pd.DataFrame, column: str) -> CheckResult:
    failed = int(df[column].isna().sum() + (df[column].astype(str).str.strip() == "").sum())
    return CheckResult(f"{column} required", failed == 0, failed, f"{failed} missing or blank values")


def check_positive(df: pd.DataFrame, column: str) -> CheckResult:
    failed = int((df[column] <= 0).sum() + df[column].isna().sum())
    return CheckResult(f"{column} positive", failed == 0, failed, f"{failed} values were not positive")


def check_non_negative(df: pd.DataFrame, column: str) -> CheckResult:
    failed = int((df[column] < 0).sum() + df[column].isna().sum())
    return CheckResult(f"{column} non-negative", failed == 0, failed, f"{failed} values were negative or missing")


def check_delivery_dates(shipments: pd.DataFrame) -> CheckResult:
    promised = pd.to_datetime(shipments["promised_date"])
    delivered = pd.to_datetime(shipments["delivered_date"])
    failed = int((delivered < promised - pd.Timedelta(days=5)).sum() + delivered.isna().sum())
    return CheckResult("delivery date sanity", failed == 0, failed, "Delivered date should be present and plausible")


def main() -> None:
    data_dir = get_data_dir()
    purchase_orders = pd.read_csv(data_dir / "purchase_orders.csv")
    shipments = pd.read_csv(data_dir / "shipments.csv")
    inventory = pd.read_csv(data_dir / "inventory_snapshots.csv")

    checks = [
        check_required(purchase_orders, "plant"),
        check_positive(purchase_orders, "quantity_ordered"),
        check_required(shipments, "carrier"),
        check_non_negative(shipments, "freight_cost"),
        check_delivery_dates(shipments),
        check_non_negative(inventory, "on_hand_qty"),
    ]

    results = pd.DataFrame([r.__dict__ for r in checks])
    print(results.to_string(index=False))
    if not results["passed"].all():
        print("\nSome checks failed. Demo prompt: Ask Copilot to create quarantine-table logic for failed supply-chain rows.")


if __name__ == "__main__":
    main()
