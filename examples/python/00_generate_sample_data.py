"""Generate synthetic supply-chain data for the Copilot data demo."""

from __future__ import annotations

from pathlib import Path

import numpy as np
import pandas as pd


RNG = np.random.default_rng(42)


def get_data_dir() -> Path:
    fabric_files = Path("/lakehouse/default/Files/copilot-demo")
    if fabric_files.parent.exists():
        return fabric_files
    if "__file__" in globals():
        return Path(__file__).resolve().parents[1] / "data"
    return Path.cwd() / "examples" / "data"


def generate_purchase_orders(days: int = 90, orders_per_day: int = 45) -> pd.DataFrame:
    dates = pd.date_range("2026-05-01", periods=days, freq="D")
    suppliers = ["Northwind Metals", "Contoso Components", "Fabrikam Packaging", "Adventure Works Logistics"]
    parts = ["battery-cell", "sensor-board", "aluminum-casing", "packing-kit", "control-chip"]
    rows = []
    po_number = 700000

    for order_date in dates:
        for _ in range(orders_per_day):
            supplier = RNG.choice(suppliers, p=[0.28, 0.32, 0.22, 0.18])
            part = RNG.choice(parts)
            quantity = int(RNG.integers(50, 750))
            promised_days = int(RNG.choice([5, 7, 10, 14], p=[0.25, 0.35, 0.25, 0.15]))
            promised_date = order_date + pd.Timedelta(days=promised_days)
            rows.append(
                {
                    "po_number": f"PO-{po_number}",
                    "order_date": order_date.date().isoformat(),
                    "supplier": supplier,
                    "part_number": part,
                    "plant": RNG.choice(["Dallas", "Chicago", "Phoenix"], p=[0.42, 0.33, 0.25]),
                    "quantity_ordered": quantity,
                    "promised_date": promised_date.date().isoformat(),
                    "expedite_flag": bool(RNG.choice([False, True], p=[0.86, 0.14])),
                    "unit_cost": float(RNG.choice([12.5, 18.75, 24.0, 31.5, 48.0])),
                }
            )
            po_number += 1

    df = pd.DataFrame(rows)
    df.loc[RNG.choice(df.index, size=14, replace=False), "plant"] = ""
    df.loc[RNG.choice(df.index, size=8, replace=False), "quantity_ordered"] = -1
    return df


def generate_shipments(purchase_orders: pd.DataFrame) -> pd.DataFrame:
    carriers = ["Blue Yonder Freight", "Tailspin Trucking", "Wide World Express"]
    lanes = {
        "Dallas": ["Laredo", "Memphis", "Kansas City"],
        "Chicago": ["Detroit", "Cleveland", "Milwaukee"],
        "Phoenix": ["Los Angeles", "Salt Lake City", "Denver"],
    }
    rows = []

    for _, po in purchase_orders.sample(frac=0.78, random_state=7).iterrows():
        plant = po["plant"] if str(po["plant"]).strip() else RNG.choice(list(lanes.keys()))
        promised = pd.to_datetime(po["promised_date"])
        delay_days = int(RNG.choice([-1, 0, 1, 2, 5, 9], p=[0.14, 0.38, 0.2, 0.14, 0.09, 0.05]))
        if po["supplier"] == "Adventure Works Logistics" and po["part_number"] == "control-chip":
            delay_days += int(RNG.choice([2, 4, 6], p=[0.45, 0.35, 0.2]))
        delivered = promised + pd.Timedelta(days=delay_days)
        rows.append(
            {
                "shipment_id": f"SHP-{po['po_number'].split('-')[1]}",
                "po_number": po["po_number"],
                "supplier": po["supplier"],
                "part_number": po["part_number"],
                "origin": RNG.choice(lanes[plant]),
                "destination_plant": plant,
                "carrier": RNG.choice(carriers),
                "promised_date": promised.date().isoformat(),
                "delivered_date": delivered.date().isoformat(),
                "quantity_delivered": max(0, int(po["quantity_ordered"]) - int(RNG.integers(0, 25))),
                "freight_cost": round(float(RNG.normal(850, 180)), 2),
                "late_delivery": bool(delay_days > 0),
            }
        )

    df = pd.DataFrame(rows)
    df.loc[RNG.choice(df.index, size=10, replace=False), "carrier"] = ""
    df.loc[RNG.choice(df.index, size=7, replace=False), "freight_cost"] = -25
    return df


def generate_inventory_snapshots(days: int = 90) -> pd.DataFrame:
    parts = ["battery-cell", "sensor-board", "aluminum-casing", "packing-kit", "control-chip"]
    plants = ["Dallas", "Chicago", "Phoenix"]
    dates = pd.date_range("2026-05-01", periods=days, freq="D")
    rows = []

    for snapshot_date in dates:
        for plant in plants:
            for part in parts:
                demand = int(RNG.integers(35, 180))
                on_hand = int(RNG.normal(850, 220) - demand * (snapshot_date.day % 9))
                if part == "control-chip" and plant == "Phoenix" and snapshot_date.day >= 20:
                    on_hand -= int(RNG.integers(250, 450))
                rows.append(
                    {
                        "snapshot_date": snapshot_date.date().isoformat(),
                        "plant": plant,
                        "part_number": part,
                        "on_hand_qty": on_hand,
                        "daily_demand_qty": demand,
                        "safety_stock_qty": int(RNG.choice([180, 225, 275, 320])),
                    }
                )

    df = pd.DataFrame(rows)
    df.loc[RNG.choice(df.index, size=9, replace=False), "on_hand_qty"] = -10
    return df


def main() -> None:
    data_dir = get_data_dir()
    data_dir.mkdir(parents=True, exist_ok=True)
    purchase_orders = generate_purchase_orders()
    shipments = generate_shipments(purchase_orders)
    inventory = generate_inventory_snapshots()

    purchase_orders.to_csv(data_dir / "purchase_orders.csv", index=False)
    shipments.to_csv(data_dir / "shipments.csv", index=False)
    inventory.to_csv(data_dir / "inventory_snapshots.csv", index=False)
    print(
        f"Wrote {len(purchase_orders):,} purchase orders, "
        f"{len(shipments):,} shipments, and {len(inventory):,} inventory snapshots to {data_dir}"
    )


if __name__ == "__main__":
    main()
