# Project Guidelines

## Project Purpose

* Maintain this repository as a public demo kit for GitHub Copilot workflows used by data engineers, data scientists, and analytics engineers.
* Keep examples focused on the existing synthetic supply-chain scenario: purchase orders, shipments, inventory, suppliers, plants, and delivery risk.
* Never add customer data, personal data, credentials, Microsoft-internal information, or private URLs. Use synthetic data and public references only.
* Preserve deterministic demo behavior. Keep seeded random generation stable unless a requested scenario requires different output.

## Sources of Truth

* Treat `examples/python/*.py` as the source for generated notebooks in `examples/notebooks/`. Do not edit generated notebook code directly; update the Python source and run `npm run build:notebooks`.
* Treat `scripts/build_deck.js` as the source for the generated PowerPoint deck. Make slide content and layout changes there, then rebuild the deck.
* Treat files under `examples/data/` as generated runtime output. Do not commit generated CSV or database files.
* Keep `README.md`, `facilitator/demo-runbook.md`, `prompts/copilot-demo-prompts.md`, and deck content aligned when a demo workflow changes.

## Python Conventions

* Follow the patterns in `examples/python/`: module docstrings, `from __future__ import annotations`, type hints, small functions, and a `main()` entry point guarded by `if __name__ == "__main__":`.
* Use `pathlib.Path` for filesystem access. Preserve the Microsoft Fabric path `/lakehouse/default/Files/copilot-demo` and the local `examples/data` fallback where applicable.
* Use NumPy's seeded `default_rng` for generated data so demos remain reproducible.
* Prefer clear pandas transformations such as `assign`, `groupby`, and `agg`. Handle nulls, blank strings, invalid dates, and zero denominators explicitly.
* Keep examples readable for live explanation. Favor direct, educational code over unnecessary abstractions.
* Manage Python dependencies in `pyproject.toml` with `uv add`. Use `uv add --dev` for development-only tools, and commit the resulting `uv.lock` changes.
* Use `uv sync` to create or update the environment. Do not maintain `requirements.txt` or document and invoke raw `pip` commands.

## Fabric and Spark Conventions

* Preserve dual execution where an example supports both Microsoft Fabric and local Python.
* Detect Fabric-provided globals such as `spark` without making local execution fail.
* Use Spark DataFrame operations, temporary views, or Spark SQL for distributed work. Avoid collecting full datasets to the driver.
* Keep local pandas behavior semantically aligned with the Fabric implementation.

## SQL Conventions

* Write Microsoft Fabric Warehouse and Azure SQL compatible T-SQL, not MySQL, PostgreSQL, or SQLite syntax.
* Follow `examples/sql/04_fabric_sql_analytics.sql`: use CTEs for staged logic, uppercase SQL keywords, explicit `CAST(... AS date)` for date operations, and `NULLIF` for safe division.
* Use descriptive aliases and deterministic ordering so query output is easy to explain during a demo.
* Retain concise `Copilot prompt:` comments when SQL is intended to demonstrate prompt-driven generation or refinement.

## Deck and Documentation Conventions

* Preserve the deck's existing `pptxgenjs` helpers, theme constants, slide masters, and `CUSTOM_WIDE` layout instead of duplicating style values.
* Use official Microsoft product icons and the existing template and normalization scripts for branded output.
* Write demo prompts as specific, outcome-oriented requests that invite explanation, generation, refinement, or documentation.
* Keep public documentation concise and platform paths correct: backslashes in PowerShell examples and forward slashes in Bash examples.

## Setup and Validation

Use `uv` for Python environment and dependency management:

```bash
uv sync
```

Run Python examples with `uv run`, generating source data before dependent workflows:

```bash
uv run python examples/python/00_generate_sample_data.py
uv run python examples/python/01_ingest_profile.py
uv run python examples/python/02_data_quality_checks.py
uv run python examples/python/03_fabric_spark_transform.py
uv run python examples/python/05_feature_engineering_ml.py
```

Use the existing npm scripts for generated artifacts:

```bash
npm install
npm run build:notebooks
npm run build:deck
npm run build
```

For the complete branded deck workflow on Windows, run `npm run build:deck:windows` from Windows PowerShell, including when accessing the repository through its WSL path.

No automated test, lint, or type-check command is currently configured. Validate the smallest affected workflow, regenerate derived artifacts when their sources change, and inspect the resulting diff for unintended generated output.