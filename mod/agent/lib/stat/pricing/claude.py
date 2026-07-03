"""
Output the built-in model pricing table in TSV format for AI Agent consumption.

Usage:
    x agent stat pricing [--format tsv|json]
"""

import argparse
import json
import os
import sys
from typing import Optional

_PARENT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_PARSE_DIR = os.path.join(_PARENT, "parse")
sys.path.insert(0, _PARSE_DIR)
import claude as _pc  # parse/claude.py


PRICING_TSV_COLUMNS = [
    "model", "input_price_cny_per_mtok", "cache_read_price_cny_per_mtok",
    "output_price_cny_per_mtok",
]


def _format_tsv_pricing(pricing: dict) -> str:
    out_lines = ["\t".join(PRICING_TSV_COLUMNS)]
    for model, prices in pricing.items():
        out_lines.append(
            f"{model}\t{prices['input']}\t{prices['cache_read']}\t{prices['output']}"
        )
    return "\n".join(out_lines) + "\n"


def _format_json_pricing(pricing: dict) -> str:
    return json.dumps(
        [{"model": m, **p} for m, p in pricing.items()],
        indent=2, ensure_ascii=False,
    ) + "\n"


def main(argv: Optional[list[str]] = None) -> int:
    ap = argparse.ArgumentParser(
        description="Output built-in model pricing table."
    )
    ap.add_argument(
        "--format",
        choices=("tsv", "json"),
        default="tsv",
        help="Output format: tsv (default) or json.",
    )
    args = ap.parse_args(argv)

    pricing = _pc.PRICING_CNY_PER_MTOK

    if args.format == "json":
        sys.stdout.write(_format_json_pricing(pricing))
    else:
        sys.stdout.write(_format_tsv_pricing(pricing))
    return 0


if __name__ == "__main__":
    sys.exit(main())
