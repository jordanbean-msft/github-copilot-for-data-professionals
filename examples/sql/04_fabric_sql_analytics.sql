-- Microsoft Fabric SQL analytics demo for supply-chain operations.
-- Copilot prompt: Write a query that finds suppliers and lanes with the highest late-delivery risk.

SELECT
    supplier,
    origin,
    destination_plant,
    COUNT(*) AS shipment_count,
    SUM(CASE WHEN late_delivery = 1 THEN 1 ELSE 0 END) AS late_shipments,
    AVG(DATEDIFF(day, CAST(promised_date AS date), CAST(delivered_date AS date))) AS avg_days_late,
    SUM(freight_cost) AS total_freight_cost
FROM shipments
WHERE carrier IS NOT NULL
  AND TRIM(carrier) <> ''
  AND freight_cost >= 0
GROUP BY supplier, origin, destination_plant
ORDER BY late_shipments DESC, avg_days_late DESC;

-- Copilot prompt: Refactor this into a weekly inventory-risk view by plant and part.

WITH weekly_inventory AS (
    SELECT
        plant,
        part_number,
        DATEPART(week, CAST(snapshot_date AS date)) AS inventory_week,
        AVG(on_hand_qty) AS avg_on_hand_qty,
        AVG(daily_demand_qty) AS avg_daily_demand_qty,
        AVG(safety_stock_qty) AS avg_safety_stock_qty
    FROM inventory_snapshots
    WHERE on_hand_qty >= 0
    GROUP BY plant, part_number, DATEPART(week, CAST(snapshot_date AS date))
),
risk_scored AS (
    SELECT
        plant,
        part_number,
        inventory_week,
        avg_on_hand_qty,
        avg_daily_demand_qty,
        avg_safety_stock_qty,
        avg_on_hand_qty / NULLIF(avg_daily_demand_qty, 0) AS days_of_supply,
        CASE
            WHEN avg_on_hand_qty < avg_safety_stock_qty THEN 'below safety stock'
            WHEN avg_on_hand_qty / NULLIF(avg_daily_demand_qty, 0) < 5 THEN 'low days of supply'
            ELSE 'healthy'
        END AS inventory_risk
    FROM weekly_inventory
)
SELECT
    plant,
    part_number,
    inventory_week,
    avg_on_hand_qty,
    avg_daily_demand_qty,
    days_of_supply,
    inventory_risk
FROM risk_scored
ORDER BY
    CASE inventory_risk
        WHEN 'below safety stock' THEN 1
        WHEN 'low days of supply' THEN 2
        ELSE 3
    END,
    days_of_supply ASC;
