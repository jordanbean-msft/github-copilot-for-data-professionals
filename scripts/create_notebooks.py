"""Create lightweight Fabric-ready notebooks from the Python demo scripts."""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PYTHON_DIR = ROOT / "examples" / "python"
NOTEBOOK_DIR = ROOT / "examples" / "notebooks"


INTRO = {
    "cell_type": "markdown",
    "metadata": {},
    "source": [
        "# GitHub Copilot for Data Professionals\n",
        "\n",
        "Run this notebook in Microsoft Fabric or locally in Jupyter. Use the embedded Copilot prompts to demonstrate common data workflows.\n",
    ],
}


def notebook_for(script: Path) -> dict:
    source = script.read_text(encoding="utf-8").splitlines(keepends=True)
    return {
        "cells": [
            INTRO,
            {
                "cell_type": "markdown",
                "metadata": {},
                "source": [f"## {script.stem.replace('_', ' ').title()}\n"],
            },
            {
                "cell_type": "code",
                "execution_count": None,
                "metadata": {},
                "outputs": [],
                "source": source,
            },
        ],
        "metadata": {
            "kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"},
            "language_info": {"name": "python", "version": "3.11"},
        },
        "nbformat": 4,
        "nbformat_minor": 5,
    }


def main() -> None:
    NOTEBOOK_DIR.mkdir(parents=True, exist_ok=True)
    for script in sorted(PYTHON_DIR.glob("*.py")):
        output = NOTEBOOK_DIR / f"{script.stem}.ipynb"
        output.write_text(json.dumps(notebook_for(script), indent=2), encoding="utf-8")
        print(f"Wrote {output}")


if __name__ == "__main__":
    main()

