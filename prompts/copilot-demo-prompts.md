# Copilot Demo Prompt Gallery

Use these prompts live in GitHub Copilot Chat. Each prompt maps to one of the sample workflows in this repo.

## 1. Explain an Unknown Data Workflow

```text
You are a senior Microsoft Fabric data engineer. Explain what this script does, identify the input and output datasets, and call out any assumptions I should validate before using it in production.
```

## 2. Generate Edge Cases

```text
Add realistic bad-data scenarios to this synthetic supply-chain data generator: duplicate PO numbers, missing plants or carriers, late shipments, negative freight costs, and impossible inventory balances. Keep the examples easy to explain in a live demo.
```

## 3. Create Data Quality Checks

```text
Create reusable validation checks for this dataframe. Return a summary table and a quarantine dataframe with failed rows and reason codes.
```

## 4. Translate Pandas to PySpark

```text
Convert this pandas transformation into PySpark for a Microsoft Fabric Lakehouse. Avoid collect operations, keep the code readable, and show where to write a Delta table.
```

## 5. Write Fabric SQL

```text
Write a Fabric SQL query that answers: Which suppliers, lanes, and parts have rising late-delivery or stockout risk? Include comments that explain each step.
```

## 6. Generate Tests

```text
Generate unit tests for this data quality function. Include positive cases, negative cases, null handling, and boundary values.
```

## 7. Improve Performance

```text
Review this PySpark transformation for performance risks. Suggest improvements for partitioning, filtering, joins, and avoiding driver bottlenecks.
```

## 8. Document Lineage

```text
Create a short data lineage note for this notebook: source files, transformations, output tables, quality checks, and downstream consumers.
```

## 9. Feature Engineering

```text
Suggest features for predicting late-shipment risk from purchase orders, shipments, and inventory snapshots. Explain the intuition, possible leakage risks, and how each feature should be validated.
```

## 10. Responsible AI Review

```text
Review this generated code before production use. Identify correctness risks, data privacy risks, governance considerations, and tests I should add.
```
