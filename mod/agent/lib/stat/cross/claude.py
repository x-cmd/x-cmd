"""
cross_claude.py -- cross-session (multi-session) turn-level statistics.

Reuses ``parse/claude.py``'s ``parse_session()`` to parse individual sessions,
then concatenates all turns into a single stream with a ``session_id`` column
for traceability.

The primary consumer is an AI Agent that reads the ``human_message`` column
across sessions, performs semantic task classification, and then aggregates
by task (not by session).  See plan.2.md for the full design.

Output formats:
  * tsv (default) -- header line + one row per turn + session_id column.
  * json           -- JSON array of turn objects, each with a session_id key.

Usage:
    cross_claude.py --session-id id1,id2,id3 [--format tsv|json]
    cross_claude.py --all [--since <ts>] [--until <ts>] [--format tsv|json]
"""

import argparse
import json
import os
import sys
from typing import Any, Dict, Iterable, List, Optional

# -- import from sibling parse/ ---
_PARENT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_PARSE_DIR = os.path.join(_PARENT, "parse")
sys.path.insert(0, _PARSE_DIR)
import claude as _pc  # parse/claude.py  (imported as flat module, no __init__.py)

# --- constants ---
CLAUDE_PROJECTS_ROOT = os.path.expanduser("~/.claude/projects")

# TSV columns: same as parse plus session_id as the last column.
CROSS_TSV_COLUMNS = list(_pc.TSV_COLUMNS) + ["session_id"]


# ---------- helpers ----------

def _tsv_escape(s: str) -> str:
    """Escape tab/newline/CR/backslash for TSV (re-export from parse)."""
    return _pc._tsv_escape(s)


def _extract_session_id(file_path: str) -> str:
    """Extract the session UUID from a JSONL filename."""
    return os.path.splitext(os.path.basename(file_path))[0]


def _session_first_ts(file_path: str) -> Optional[int]:
    """Read the timestamp of the first timestamp-bearing record in a session
    JSONL file.  Returns None if the file is empty or unreadable."""
    try:
        with open(file_path, "r", encoding="utf-8", errors="replace") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    rec = json.loads(line)
                except json.JSONDecodeError:
                    continue
                ts = _pc._iso_to_epoch(rec.get("timestamp") or "")
                if ts is not None:
                    return ts
    except OSError:
        return None
    return None


# ---------- session discovery ----------

def _list_all_sessions(
    since: Optional[int] = None,
    until: Optional[int] = None,
    project: Optional[str] = None,
) -> List[str]:
    """Scan ``~/.claude/projects/`` and return file paths matching filters.

    Args:
        since: Only include sessions whose first timestamp >= this epoch.
        until: Only include sessions whose first timestamp < this epoch.
        project: Only include sessions in this project directory name
                 (exact match on the directory under ``~/.claude/projects/``).

    Returns a list of absolute paths to JSONL files, sorted by first timestamp.
    """
    if not os.path.isdir(CLAUDE_PROJECTS_ROOT):
        return []

    candidates: List[tuple] = []  # [(first_ts, path), ...]

    for entry in os.listdir(CLAUDE_PROJECTS_ROOT):
        proj_dir = os.path.join(CLAUDE_PROJECTS_ROOT, entry)
        if not os.path.isdir(proj_dir):
            continue
        if project is not None and entry != project:
            continue

        for fname in os.listdir(proj_dir):
            if not fname.endswith(".jsonl"):
                continue
            fpath = os.path.join(proj_dir, fname)
            # Only include files that have a UUID-ish name (skip sidecar files).
            if not fname.replace(".jsonl", "").replace("-", "").replace("_", "").isalnum():
                continue

            if since is not None or until is not None:
                first_ts = _session_first_ts(fpath)
                if first_ts is None:
                    continue
                if since is not None and first_ts < since:
                    continue
                if until is not None and first_ts >= until:
                    continue
                candidates.append((first_ts, fpath))
            else:
                # No time filter — still need a sort key; use 0 for unknown.
                first_ts = _session_first_ts(fpath)
                candidates.append((first_ts or 0, fpath))

    candidates.sort(key=lambda x: x[0])
    return [p for _, p in candidates]


def _resolve_session_ids(session_ids: str) -> List[str]:
    """Resolve comma-separated session UUIDs to file paths."""
    paths = []
    for sid in session_ids.split(","):
        sid = sid.strip()
        if not sid:
            continue
        paths.append(_pc._resolve_session_id(sid))
    return paths


# ---------- multi-session processing ----------

def _process_multi(
    file_paths: Iterable[str],
    no_human_message: bool = False,
) -> List[Dict[str, Any]]:
    """Parse multiple session JSONL files and return all turns with session_id.

    Each file is parsed independently via ``parse_session()``, ensuring correct
    turn boundaries per session.  A ``session_id`` key is injected into every
    turn dict.
    """
    all_turns: List[Dict[str, Any]] = []
    for fp in file_paths:
        sid = _extract_session_id(fp)
        try:
            turns = _pc.parse_session(fp, no_human_message=no_human_message)
        except Exception as e:
            # Skip unparseable files but emit a warning to stderr.
            sys.stderr.write(f"[cross] skipping {fp}: {e}\n")
            continue
        for t in turns:
            t["session_id"] = sid
            all_turns.append(t)
    return all_turns


# ---------- formatters ----------

def _format_tsv_cross(turns: List[Dict[str, Any]]) -> str:
    """TSV output with session_id as an extra trailing column."""
    out_lines = ["\t".join(CROSS_TSV_COLUMNS)]
    for t in turns:
        out_lines.append("\t".join(
            _tsv_escape("" if t.get(c) is None else str(t[c]))
            for c in CROSS_TSV_COLUMNS
        ))
    return "\n".join(out_lines) + "\n"


def _format_json_cross(turns: List[Dict[str, Any]]) -> str:
    """JSON output — same as parse's _format_json but session_id is already
    present in each turn dict."""
    return json.dumps(turns, indent=2, ensure_ascii=False) + "\n"


# ---------- CLI ----------

def main(argv: Optional[List[str]] = None) -> int:
    ap = argparse.ArgumentParser(
        description="Cross-session statistics: parse multiple Claude Code "
                    "sessions and emit per-turn data with session_id."
    )
    # Session selection (at least one required)
    ap.add_argument(
        "--session-id", dest="session_ids",
        help="Comma-separated session UUIDs.",
    )
    ap.add_argument(
        "--all", dest="all_sessions",
        action="store_true",
        help="Include all sessions under ~/.claude/projects/.",
    )
    ap.add_argument(
        "--since",
        type=int,
        default=None,
        help="Unix epoch; only sessions whose first turn >= this value "
             "(requires --all).",
    )
    ap.add_argument(
        "--until",
        type=int,
        default=None,
        help="Unix epoch; only sessions whose first turn < this value "
             "(requires --all).",
    )
    ap.add_argument(
        "--project",
        default=None,
        help="Limit --all to a specific project directory name "
             "(exact match, e.g. '-Users-liaoxuanbin-xbash-agent').",
    )
    ap.add_argument(
        "--format",
        choices=("tsv", "json"),
        default="tsv",
        help="Output format: tsv (default, machine-friendly) or json.",
    )
    ap.add_argument(
        "--no-human-message",
        dest="no_human_message",
        action="store_true",
        help="Suppress the human_message field (tsv: empty cell, json: null).",
    )
    args = ap.parse_args(argv)

    # -- resolve file paths --
    if args.session_ids:
        try:
            file_paths = _resolve_session_ids(args.session_ids)
        except FileNotFoundError as e:
            ap.error(str(e))
    elif args.all_sessions:
        file_paths = _list_all_sessions(
            since=args.since,
            until=args.until,
            project=args.project,
        )
        if not file_paths:
            ap.error("No sessions found matching the given filters.")
    else:
        ap.error(
            "Specify one of: --session-id <ids>, --all.  "
            "Use --help for details."
        )

    # -- parse --
    turns = _process_multi(file_paths, no_human_message=args.no_human_message)

    # -- output --
    if args.format == "json":
        out = _format_json_cross(turns)
    else:
        out = _format_tsv_cross(turns)

    sys.stdout.write(out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
