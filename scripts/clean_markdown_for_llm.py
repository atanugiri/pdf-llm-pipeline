#!/usr/bin/env python3
"""Clean MinerU-style markdown for LLM ingestion.

Option 1 behavior:
- Remove markdown image links.
- Remove <details>...</details> blocks (including enclosed content).
- Remove standalone HTML tag lines.
- Keep other Mermaid/code content.
- Normalize excessive blank lines.
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path


def clean_markdown(text: str) -> str:
    """Apply cleanup to markdown text."""
    # Remove markdown image links: ![alt](path)
    text = re.sub(r"!\[[^\]]*\]\([^)]+\)", "", text)

    # Remove full <details>...</details> blocks, including nested text/code.
    text = re.sub(r"(?is)<details\b[^>]*>.*?</details>", "", text)

    # Remove standalone HTML tag lines, e.g. <details>, </summary>, <br/>
    text = re.sub(r"(?m)^\s*<[^>]+>\s*$\n?", "", text)

    # Collapse 3+ blank lines down to 2.
    text = re.sub(r"\n{3,}", "\n\n", text)

    return text.strip() + "\n"


def default_output_path(input_path: Path) -> Path:
    stem = input_path.stem
    return input_path.with_name(f"{stem}_llm.md")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Clean markdown for LLM ingestion."
    )
    parser.add_argument("input", type=Path, help="Input markdown file path")
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    input_path = args.input
    if not input_path.exists():
        raise FileNotFoundError(f"Input file not found: {input_path}")

    output_path = default_output_path(input_path)

    raw = input_path.read_text(encoding="utf-8")
    cleaned = clean_markdown(raw)
    output_path.write_text(cleaned, encoding="utf-8")

    print(f"Input : {input_path}")
    print(f"Output: {output_path}")


if __name__ == "__main__":
    main()
