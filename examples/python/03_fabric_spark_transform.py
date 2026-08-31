"""Fabric Lakehouse supply-chain transformation example with a local pandas fallback."""

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


def run_with_spark() -> bool:
    try:
        spark  # type: ignore[name-defined]
    except NameError:
        return False

    purchase_orders_path = "Files/copilot-demo/purchase_orders.csv"
    shipments_path = "Files/copilot-demo/shipments.csv"
    inventory_path = "Files/copilot-demo/inventory_snapshots.csv"

    purchase_orders = spark.read.option("header", "true").option("inferSchema", "true").csv(purchase_orders_path)  # type: ignore[name-defined]
    shipments = spark.read.option("header", "true").option("inferSchema", "true").csv(shipments_path)  # type: ignore[name-defined]
    inventory = spark.read.option("header", "true").option("inferSchema", "true").csv(inventory_path)  # type: ignore[name-defined]

    purchase_orders.createOrReplaceTempView("purchase_orders")
    shipments.createOrReplaceTempView("shipments")
    inventory.createOrReplaceTempView("inventory_snapshots")

    spark.sql(  # type: ignore[name-defined]
        """
        CREATE OR REPLACE TEMP VIEW supplier_delivery_scorecard AS
        SELECT
            supplier,
            COUNT(*) AS shipments,
            SUM(CASE WHEN late_delivery THEN 1 ELSE 0 END) AS late_shipments,
            AVG(DATEDIFF(delivered_date, promised_date)) AS avg_days_late
        FROM shipments
        WHERE carrier IS NOT NULL AND TRIM(carrier) <> ''
        GROUP BY supplier
        """
    )

    spark.sql(  # type: ignore[name-defined]
        """
        CREATE OR REPLACE TEMP VIEW inventory_stockout_risk AS
        SELECT
            plant,
            part_number,
            AVG(on_hand_qty) AS avg_on_hand_qty,
            AVG(daily_demand_qty) AS avg_daily_demand_qty,
            AVG(on_hand_qty / NULLIF(daily_demand_qty, 0)) AS avg_days_of_supply
        FROM inventory_snapshots
        WHERE on_hand_qty >= 0
        GROUP BY plant, part_number
        """
    )

    display(spark.sql("SELECT * FROM supplier_delivery_scorecard ORDER BY late_shipments DESC"))  # type: ignore[name-defined]
    display(spark.sql("SELECT * FROM inventory_stockout_risk ORDER BY avg_days_of_supply ASC LIMIT 10"))  # type: ignore[name-defined]
    return True


def run_with_pandas() -> None:
    data_dir = get_data_dir()
    shipments = pd.read_csv(data_dir / "shipments.csv", parse_dates=["promised_date", "delivered_date"])
    inventory = pd.read_csv(data_dir / "inventory_snapshots.csv")

    shipments["days_late"] = (shipments["delivered_date"] - shipments["promised_date"]).dt.days
    supplier_scorecard = (
        shipments[shipments["carrier"].astype(str).str.strip() != ""]
        .groupby("supplier", as_index=False)
        .agg(
            shipments=("shipment_id", "count"),
            late_shipments=("late_delivery", "sum"),
            avg_days_late=("days_late", "mean"),
        )
        .sort_values("late_shipments", ascending=False)
    )

    inventory_risk = (
        inventory[inventory["on_hand_qty"] >= 0]
        .assign(days_of_supply=lambda df: df["on_hand_qty"] / df["daily_demand_qty"].clip(lower=1))
        .groupby(["plant", "part_number"], as_index=False)
        .agg(
            avg_on_hand_qty=("on_hand_qty", "mean"),
            avg_daily_demand_qty=("daily_demand_qty", "mean"),
            avg_days_of_supply=("days_of_supply", "mean"),
        )
        .sort_values("avg_days_of_supply")
    )

    print(supplier_scorecard.to_string(index=False))
    print(inventory_risk.head(10).to_string(index=False))


if __name__ == "__main__":
    if not run_with_spark():
        run_with_pandas()
