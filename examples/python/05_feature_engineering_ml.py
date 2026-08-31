"""Feature engineering and late-shipment risk model for supply-chain data scientists."""

from __future__ import annotations

from pathlib import Path

import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report
from sklearn.model_selection import train_test_split


def get_data_dir() -> Path:
    fabric_files = Path("/lakehouse/default/Files/copilot-demo")
    if fabric_files.exists():
        return fabric_files
    if "__file__" in globals():
        return Path(__file__).resolve().parents[1] / "data"
    return Path.cwd() / "examples" / "data"


def build_features(shipments: pd.DataFrame, purchase_orders: pd.DataFrame, inventory: pd.DataFrame) -> pd.DataFrame:
    shipments = shipments[shipments["freight_cost"] >= 0].copy()
    shipments["promised_date"] = pd.to_datetime(shipments["promised_date"])
    shipments["delivered_date"] = pd.to_datetime(shipments["delivered_date"])
    shipments["days_late"] = (shipments["delivered_date"] - shipments["promised_date"]).dt.days

    inventory_features = (
        inventory[inventory["on_hand_qty"] >= 0]
        .assign(days_of_supply=lambda df: df["on_hand_qty"] / df["daily_demand_qty"].clip(lower=1))
        .groupby(["plant", "part_number"], as_index=False)
        .agg(
            avg_days_of_supply=("days_of_supply", "mean"),
            min_on_hand_qty=("on_hand_qty", "min"),
            avg_safety_stock_qty=("safety_stock_qty", "mean"),
        )
    )

    order_features = purchase_orders[["po_number", "quantity_ordered", "expedite_flag", "unit_cost"]].copy()
    features = shipments.merge(order_features, on="po_number", how="left").merge(
        inventory_features,
        left_on=["destination_plant", "part_number"],
        right_on=["plant", "part_number"],
        how="left",
    )
    features["is_expedited"] = features["expedite_flag"].fillna(False).astype(int)
    features["inventory_below_safety_stock"] = (
        features["min_on_hand_qty"].fillna(0) < features["avg_safety_stock_qty"].fillna(0)
    ).astype(int)
    features["late_delivery"] = features["late_delivery"].astype(int)
    return features.fillna(0)


def main() -> None:
    data_dir = get_data_dir()
    purchase_orders = pd.read_csv(data_dir / "purchase_orders.csv")
    shipments = pd.read_csv(data_dir / "shipments.csv")
    inventory = pd.read_csv(data_dir / "inventory_snapshots.csv")

    features = build_features(shipments, purchase_orders, inventory)
    model_input = pd.get_dummies(
        features[
            [
                "supplier",
                "part_number",
                "destination_plant",
                "carrier",
                "quantity_ordered",
                "freight_cost",
                "is_expedited",
                "avg_days_of_supply",
                "min_on_hand_qty",
                "inventory_below_safety_stock",
            ]
        ],
        drop_first=True,
    )
    target = features["late_delivery"]

    x_train, x_test, y_train, y_test = train_test_split(
        model_input,
        target,
        test_size=0.35,
        random_state=42,
        stratify=target,
    )
    model = RandomForestClassifier(n_estimators=100, random_state=42, class_weight="balanced")
    model.fit(x_train, y_train)
    predictions = model.predict(x_test)

    print(
        features[
            [
                "supplier",
                "part_number",
                "destination_plant",
                "carrier",
                "days_late",
                "avg_days_of_supply",
                "inventory_below_safety_stock",
            ]
        ]
        .sort_values("days_late", ascending=False)
        .head(8)
        .to_string(index=False)
    )
    print("\nLate-shipment risk model report")
    print(classification_report(y_test, predictions, zero_division=0))
    print(
        "\nCopilot prompt: Explain which supply-chain features are likely driving late-delivery risk "
        "and suggest two additional features."
    )


if __name__ == "__main__":
    main()
