# Facilitator Runbook

## Demo Flow

| Sequence | Segment | Action |
|---:|---|---|
| 1 | Thesis | Copilot helps everyone who writes code, including data teams |
| 2 | Workflow map | Show one coherent supply-chain flow from source data to risk prediction |
| 3 | Demo step 1 | Generate supply-chain data and ask Copilot to add an edge case |
| 4 | Demo step 2 | Profile data and ask Copilot for reusable helpers |
| 5 | Demo step 3 | Generate quality checks and quarantine logic for orders, shipments, and inventory |
| 6 | Demo step 4 | Convert supplier and inventory transformations to Fabric PySpark |
| 7 | Demo step 5 | Generate SQL analytics for late shipments and inventory risk |
| 8 | Demo step 6 | Build late-shipment risk features and interpret risk drivers |
| 9 | Close | Prompt framework, governance, measurement, rollout |

## Live Copilot Prompts

### Ingestion

```text
Explain this supply-chain data generator and add one realistic bad-data condition that a data engineer should catch.
```

### Profiling

```text
Create a reusable data profiling function that reports missing values, distinct counts, numeric ranges, and example values.
```

### Quality

```text
Generate validation checks for purchase orders, shipments, and inventory snapshots. Return failed rows in a quarantine dataframe with a reason column.
```

### Fabric Spark

```text
Convert this supplier delivery and inventory-risk aggregation into PySpark code for a Microsoft Fabric Lakehouse and explain where I should write Delta tables.
```

### SQL

```text
Write a Fabric SQL query that shows suppliers, lanes, and parts with rising late-delivery or stockout risk.
```

### Data Science

```text
Suggest useful features for predicting late-shipment risk and explain why each feature matters.
```

## Talk Track

The point of the demo is not that Copilot magically understands the business. The point is that supply-chain data professionals spend a large part of their week writing repeatable code: schema exploration, joins, validation, transformations, SQL, feature engineering, tests, and documentation. Copilot reduces the friction in each of those steps, while the data professional remains responsible for validating correctness, data meaning, governance, and production readiness.
