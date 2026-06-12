#!/usr/bin/env python3
# shellcheck shell=python
"""
parse_claude.py -- extract per-turn statistics from a Claude Code session JSONL.

Implements the rules defined in `plan.md` (in this repository):
  * Start of a turn: first `type=user` record whose `content` is not a
    `tool_result` array (i.e., real user text / slash-command input).
  * End of a turn:   the last `type=assistant` record before the next such
    user record, or end-of-file.
  * `message.model == "<synthetic>"` records are excluded from token/model
    accounting (Claude Code client-side synthetic messages).
  * `human_duration` uses the LAST `type=assistant` timestamp (synthetic or
    not) minus the turn-start user timestamp.

Output formats:
  * text (default) -- human-readable summary, per-turn table, highlights.
  * tsv            -- header line + one row per turn, machine-friendly.
  * json           -- JSON array of turn objects.

Usage:
    parse_claude.py --file <path> [--offset <bytes>] [--format text|tsv|json]

The `--offset` is a byte offset into the input file; lines that straddle
the boundary are skipped (treated as already-processed).
"""

import argparse
import json
import os
import sys
from datetime import datetime, timezone
from typing import Any, Dict, Iterable, List, Optional, TextIO


# ---------- helpers ----------

def _iso_to_epoch(s: str) -> Optional[int]:
    """Parse an ISO-8601 timestamp string to a Unix epoch (seconds, int).

    Returns None for empty / unparseable input.
    """
    if not s:
        return None
    s = s.replace("Z", "+00:00")
    try:
        dt = datetime.fromisoformat(s)
    except (TypeError, ValueError):
        return None
    # The JSONL timestamps are UTC ("...Z"); anchor them explicitly so that
    # naive `datetime.fromisoformat` does not assume local time.
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return int(dt.timestamp())


def _epoch_to_local(epoch: int) -> datetime:
    """Convert an epoch second to a tz-aware local datetime."""
    return datetime.fromtimestamp(epoch).astimezone()


def _is_user_record(rec: Dict[str, Any]) -> bool:
    return rec.get("type") == "user"


def _is_assistant_record(rec: Dict[str, Any]) -> bool:
    return rec.get("type") == "assistant"


def _user_content(rec: Dict[str, Any]) -> Any:
    return (rec.get("message") or {}).get("content")


def _is_tool_result_user(rec: Dict[str, Any]) -> bool:
    if not _is_user_record(rec):
        return False
    content = _user_content(rec)
    if not isinstance(content, list):
        return False
    return all(isinstance(c, dict) and c.get("type") == "tool_result" for c in content)


def _is_real_user_text(rec: Dict[str, Any]) -> bool:
    """Per plan: `content` 非 `tool_result` 数组 -- the negation of tool-result."""
    if not _is_user_record(rec):
        return False
    return not _is_tool_result_user(rec)


def _is_synthetic_assistant(rec: Dict[str, Any]) -> bool:
    if not _is_assistant_record(rec):
        return False
    msg = rec.get("message") or {}
    return msg.get("model") == "<synthetic>"


def _assistant_msg(rec: Dict[str, Any]) -> Dict[str, Any]:
    return rec.get("message") or {}


def _assistant_usage(rec: Dict[str, Any]) -> Dict[str, Any]:
    return _assistant_msg(rec).get("usage") or {}


def _assistant_model(rec: Dict[str, Any]) -> str:
    return _assistant_msg(rec).get("model") or ""


def _assistant_content_type(rec: Dict[str, Any]) -> str:
    """Return the content type of the first (and only) content block.

    Claude Code JSONL assistant records each contain exactly one content item.
    Returns the ``type`` field (``"thinking"``, ``"text"``, ``"tool_use"``),
    or an empty string if the content array is missing/empty.
    """
    content = _assistant_msg(rec).get("content") or []
    if isinstance(content, list) and content:
        return content[0].get("type") or ""
    return ""


def _record_ts(rec: Dict[str, Any]) -> Optional[int]:
    return _iso_to_epoch(rec.get("timestamp") or "")


# ---------- core parser ----------

TSV_COLUMNS: List[str] = [
    "timestamp",
    "model",
    "input_tokens",
    "output_tokens",
    "thinking_tokens",
    "output_text_tokens",
    "cache_read_tokens",
    "api_call_count",
    "human_input_tokens",
    "human_duration",
    "human_ratio",
]


def _new_turn(start_ts: Optional[int]) -> Dict[str, Any]:
    return {
        "start_ts": start_ts,
        "end_ts": None,
        "model": "",
        "input_tokens": 0,
        "output_tokens": 0,
        "thinking_tokens": 0,
        "cache_read_tokens": 0,
        "api_call_count": 0,
        "synthetic_count": 0,
        "human_input_tokens": None,
    }


def _flush_turn(turn: Optional[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
    """Convert in-memory turn state into the public turn-dict shape."""
    if turn is None:
        return None

    out_tokens = int(turn["output_tokens"])
    thinking = int(turn["thinking_tokens"])
    out_text = out_tokens - thinking if out_tokens >= thinking else out_tokens

    start = turn["start_ts"]
    end = turn["end_ts"]
    dur: Optional[int] = None
    if start is not None and end is not None and end >= start:
        dur = end - start

    human_in = turn["human_input_tokens"]
    ratio: Optional[float] = None
    if out_tokens > 0 and human_in is not None:
        ratio = human_in / out_tokens

    return {
        "timestamp": start,
        "model": turn["model"],
        "input_tokens": int(turn["input_tokens"]),
        "output_tokens": out_tokens,
        "thinking_tokens": thinking,
        "output_text_tokens": out_text,
        "cache_read_tokens": int(turn["cache_read_tokens"]),
        "api_call_count": int(turn["api_call_count"]),
        "synthetic_count": int(turn["synthetic_count"]),
        "human_input_tokens": int(human_in) if human_in is not None else None,
        "human_duration": dur,
        "human_ratio": round(ratio, 4) if ratio is not None else None,
    }


def _process(lines: Iterable[str]) -> List[Dict[str, Any]]:
    """Stream a sequence of JSONL lines and return one dict per turn."""
    rows: List[Dict[str, Any]] = []
    cur: Optional[Dict[str, Any]] = None

    def flush() -> None:
        nonlocal cur
        row = _flush_turn(cur)
        if row is not None:
            rows.append(row)
        cur = None

    for raw in lines:
        raw = raw.strip()
        if not raw:
            continue
        try:
            rec = json.loads(raw)
        except json.JSONDecodeError:
            continue
        if not isinstance(rec, dict):
            continue

        rtype = rec.get("type")

        if rtype == "user":
            if _is_real_user_text(rec):
                flush()
                cur = _new_turn(_record_ts(rec))
            else:
                if cur is not None:
                    ts = _record_ts(rec)
                    if ts is not None:
                        cur["end_ts"] = ts

        elif rtype == "assistant":
            if cur is None:
                continue
            ts = _record_ts(rec)
            if ts is not None:
                cur["end_ts"] = ts
            if _is_synthetic_assistant(rec):
                cur["synthetic_count"] += 1
                continue
            usage = _assistant_usage(rec)
            model = _assistant_model(rec)
            if not cur["model"] and model:
                cur["model"] = model
            cur["input_tokens"] += int(usage.get("input_tokens") or 0)
            cur["output_tokens"] += int(usage.get("output_tokens") or 0)
            if _assistant_content_type(rec) == "thinking":
                cur["thinking_tokens"] += int(usage.get("output_tokens") or 0)
            cur["cache_read_tokens"] += int(usage.get("cache_read_input_tokens") or 0)
            cur["api_call_count"] += 1
            if cur["human_input_tokens"] is None:
                cur["human_input_tokens"] = int(usage.get("input_tokens") or 0)

        elif rtype in ("system", "last-prompt", "attachment"):
            if cur is not None:
                ts = _record_ts(rec)
                if ts is not None:
                    cur["end_ts"] = ts

    flush()
    return rows


# ---------- formatters ----------

def _format_tsv(turns: List[Dict[str, Any]]) -> str:
    out_lines = ["\t".join(TSV_COLUMNS)]
    for t in turns:
        out_lines.append("\t".join("" if t[c] is None else str(t[c]) for c in TSV_COLUMNS))
    return "\n".join(out_lines) + "\n"


def _format_json(turns: List[Dict[str, Any]]) -> str:
    return json.dumps(turns, indent=2, ensure_ascii=False) + "\n"


# ---- shared analysis helpers (used by both brief and text formatters) ----

def _percentile(values: List[float], p: float) -> float:
    """Linear-interpolation percentile, p in [0, 100]."""
    if not values:
        return 0.0
    s = sorted(values)
    k = (len(s) - 1) * (p / 100.0)
    lo = int(k)
    hi = min(lo + 1, len(s) - 1)
    if lo == hi:
        return float(s[lo])
    return float(s[lo] + (s[hi] - s[lo]) * (k - lo))


def _median(values: List[float]) -> float:
    return _percentile(values, 50)


def _short_model(model: str) -> str:
    """Compact model id for one-line display ('claude-opus-4-8' → 'opus-4-8')."""
    if not model:
        return "-"
    s = model
    # 'us.anthropic.claude-opus-4-8-v1:0' → 'claude-opus-4-8-v1:0'
    if "claude-" in s:
        s = s[s.index("claude-") + len("claude-"):]
    return s


# Per-vendor pricing in CNY (人民币) per 1M tokens. Snapshot 2026-06-11;
# vendors update prices periodically. Cache-read rate is vendor-specific
# (Anthropic = 10% of input, others vary). Keys are matched as a prefix
# against the recorded model id, longest-prefix first, so 'claude-opus-4'
# covers 4.0/4.5/4.6/4.7/4.8.
PRICING_CNY_PER_MTOK: Dict[str, Dict[str, float]] = {
    # --- Anthropic Claude (claude-api skill 2026-05-26; USD→CNY at $1≈¥7.15) ---
    "claude-opus-4":     {"input": 35.75, "cache_read": 3.58, "output": 178.75},
    "claude-sonnet-4":   {"input": 21.45, "cache_read": 2.15, "output": 107.25},
    "claude-haiku-4":    {"input":  7.15, "cache_read": 0.72, "output":  35.75},
    # --- DeepSeek (api-docs.deepseek.com/zh-cn/quick_start/pricing, 2026-06-11)
    # V4 series; V4-Flash absorbs legacy deepseek-chat / deepseek-reasoner.
    "deepseek-v4-pro":   {"input":  3.0,  "cache_read": 0.025, "output":  6.0},
    "deepseek-v4-flash": {"input":  1.0,  "cache_read": 0.02,  "output":  2.0},
    "deepseek-chat":     {"input":  1.0,  "cache_read": 0.02,  "output":  2.0},
    "deepseek-reasoner": {"input":  1.0,  "cache_read": 0.02,  "output":  2.0},
    # Legacy V3 / R1:
    "deepseek-v3":       {"input":  2.0,  "cache_read": 0.50, "output":  8.0},
    "deepseek-r1":       {"input":  4.0,  "cache_read": 1.00, "output": 16.0},
    # --- Z.ai GLM (bigmodel.cn) ---
    "glm-4.6":           {"input":  4.0,  "cache_read": 0.80, "output": 16.0},
    "glm-4.5":           {"input":  4.0,  "cache_read": 0.80, "output": 16.0},
    # --- MiniMax (platform.minimaxi.com/docs/guides/pricing-paygo, 2026-06-11)
    # M3 has tiered pricing by input length; ≤512k tier shown (永久五折,
    # covers most turns). >512k tier doubles.
    "MiniMax-M3":              {"input": 2.10, "cache_read": 0.42, "output":  8.40},
    "MiniMax-M2.7":            {"input": 2.10, "cache_read": 0.42, "output":  8.40},
    "MiniMax-M2.7-highspeed":  {"input": 4.20, "cache_read": 0.42, "output": 16.80},
    "MiniMax-M2":              {"input": 2.10, "cache_read": 0.21, "output":  8.40},
}


def _lookup_price(model: str) -> Optional[Dict[str, float]]:
    """Find a price entry by prefix match; longest prefix wins. None = unknown.
    Case-insensitive on both sides."""
    if not model:
        return None
    m = model.lower()
    for key in sorted(PRICING_CNY_PER_MTOK.keys(), key=len, reverse=True):
        klow = key.lower()
        if m == klow or m.startswith(klow) or f"/{klow}" in m or f".{klow}" in m:
            return PRICING_CNY_PER_MTOK[key]
    return None


def _cost_cny(turn: Dict[str, Any]) -> Optional[float]:
    """Estimate CNY cost for one turn. None if model pricing isn't internal."""
    p = _lookup_price(turn.get("model") or "")
    if p is None:
        return None
    return (
        turn["input_tokens"]       / 1_000_000 * p["input"]
        + turn["cache_read_tokens"] / 1_000_000 * p["cache_read"]
        + turn["output_tokens"]     / 1_000_000 * p["output"]
    )


def _detect_anomalies(turns: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Flag each turn against the thresholds documented in plan.md.

    A single turn may produce multiple anomaly rows. Returned dicts carry the
    1-based turn index, the metric name, the value, and a context string.
    """
    real = [t for t in turns if (t.get("api_call_count") or 0) > 0]
    api_counts = [t["api_call_count"] for t in real]
    fresh_inputs = [t["input_tokens"] for t in real if t["input_tokens"] > 0]
    p95_api = _percentile(api_counts, 95) if api_counts else 0.0
    med_in = _median(fresh_inputs) if fresh_inputs else 0.0

    out: List[Dict[str, Any]] = []
    for i, t in enumerate(turns, 1):
        api = t.get("api_call_count") or 0
        if api >= 10 and api > p95_api:
            out.append({
                "turn": i,
                "metric": "api_call_count",
                "value": api,
                "turn_data": t,
            })
        if med_in > 0 and t["input_tokens"] > 5 * med_in:
            out.append({
                "turn": i,
                "metric": "input_tokens",
                "value": t["input_tokens"],
                "turn_data": t,
            })
        ratio = t.get("human_ratio")
        if ratio is not None and 0 < ratio < 0.001:
            out.append({
                "turn": i,
                "metric": "human_ratio",
                "value": ratio,
                "turn_data": t,
            })
        if (t.get("synthetic_count") or 0) > 0 and (t.get("api_call_count") or 0) == 0:
            out.append({
                "turn": i,
                "metric": "model",
                "value": "<synthetic>",
                "turn_data": t,
            })
    return out


def _trends(turns: List[Dict[str, Any]], bucket: int = 5
            ) -> Optional[Dict[str, List[float]]]:
    """Compute cache_hit_rate and output_text_ratio per N-turn bucket.

    Returns None when there aren't enough turns to make at least two buckets
    (a single point isn't a trend).
    """
    real = [t for t in turns if (t.get("api_call_count") or 0) > 0]
    if len(real) < bucket * 2:
        return None

    cache_series: List[float] = []
    text_series: List[float] = []
    for start in range(0, len(real), bucket):
        chunk = real[start:start + bucket]
        in_sum = sum(t["input_tokens"] for t in chunk)
        cache_sum = sum(t["cache_read_tokens"] for t in chunk)
        out_sum = sum(t["output_tokens"] for t in chunk)
        text_sum = sum(t["output_text_tokens"] for t in chunk)
        denom = cache_sum + in_sum
        cache_series.append(cache_sum / denom if denom > 0 else 0.0)
        text_series.append(text_sum / out_sum if out_sum > 0 else 0.0)

    return {
        "cache_hit_rate": cache_series,
        "output_text_ratio": text_series,
    }


def _model_usage(turns: List[Dict[str, Any]]) -> List[tuple]:
    """List of (model, api_call_count) sorted descending. Synthetic-only turns
    have model='' and api_call_count=0, so they don't show up here."""
    counts: Dict[str, int] = {}
    for t in turns:
        m = t.get("model") or ""
        c = t.get("api_call_count") or 0
        if m and c:
            counts[m] = counts.get(m, 0) + c
    return sorted(counts.items(), key=lambda x: -x[1])


def _highlighted_turn_indices(turns: List[Dict[str, Any]]) -> set:
    """1-based turn indices that the Highlights section will reference.

    Pulled out here so the per-turn table can show only the rows the rest of
    the report mentions (anomalies + highlights). Mirror of the selection
    logic in `_format_text`'s Highlights block — keep them in sync.
    """
    refs: set = set()

    def has_ai(t: Dict[str, Any]) -> bool:
        return (t.get("api_call_count") or 0) > 0 or (t.get("output_tokens") or 0) > 0

    real = [(i, t) for i, t in enumerate(turns, 1) if has_ai(t)]
    if not real:
        return refs

    # Largest by total tokens
    refs.add(max(real, key=lambda it: it[1]["input_tokens"]
                                       + it[1]["cache_read_tokens"]
                                       + it[1]["output_tokens"])[0])
    # Cache hit champion
    cached = [(i, t) for i, t in real if t["cache_read_tokens"] > 0]
    if cached:
        refs.add(max(cached, key=lambda it: it[1]["cache_read_tokens"])[0])
    # Longest wait
    waited = [(i, t) for i, t in real if t["human_duration"]]
    if waited:
        refs.add(max(waited, key=lambda it: it[1]["human_duration"])[0])
    # Highest leverage (smallest positive human_ratio)
    leveraged = [(i, t) for i, t in real
                 if t.get("human_ratio") is not None and t["human_ratio"] > 0]
    if leveraged:
        refs.add(min(leveraged, key=lambda it: it[1]["human_ratio"])[0])

    return refs


# ---- human text formatter ----

def _visual_len(s: str) -> int:
    """Approximate display width on a monospace terminal.

    CJK ideographs and full-width punctuation take 2 columns; everything else
    takes 1. We avoid an external dependency on `wcwidth` because the table is
    the only place this matters and the ranges below cover everything our
    Chinese output uses (Han, kana, Hangul, full-width ASCII).
    """
    w = 0
    for ch in s:
        cp = ord(ch)
        if (
            0x1100 <= cp <= 0x115F or          # Hangul Jamo
            0x2E80 <= cp <= 0xA4CF or          # CJK Radicals through Yi
            0xAC00 <= cp <= 0xD7A3 or          # Hangul Syllables
            0xF900 <= cp <= 0xFAFF or          # CJK Compatibility Ideographs
            0xFE30 <= cp <= 0xFE4F or          # CJK Compatibility Forms
            0xFF00 <= cp <= 0xFF60 or          # Full-width ASCII variants
            0xFFE0 <= cp <= 0xFFE6 or          # Full-width signs
            0x20000 <= cp <= 0x2FFFD or        # CJK Extension B–F
            0x30000 <= cp <= 0x3FFFD           # CJK Extension G+
        ):
            w += 2
        else:
            w += 1
    return w


def _pad_left(s: str, width: int) -> str:
    """ljust counterpart that respects CJK display width."""
    return s + " " * max(0, width - _visual_len(s))


def _pad_right(s: str, width: int) -> str:
    """rjust counterpart that respects CJK display width."""
    return " " * max(0, width - _visual_len(s)) + s


def _fmt_tokens(n: int) -> str:
    """Format a token count with a unit suffix and a thousands separator."""
    if n is None:
        return "-"
    sign = "-" if n < 0 else ""
    n = abs(n)
    if n < 1_000:
        return f"{sign}{n}"
    if n < 1_000_000:
        v = n / 1_000
        return f"{sign}{v:.1f}k"
    v = n / 1_000_000
    return f"{sign}{v:.2f}M"


def _fmt_int(n: int) -> str:
    if n is None:
        return "-"
    return f"{n:,}"


def _fmt_duration(secs: int) -> str:
    if secs is None:
        return "-"
    if secs < 60:
        return f"{secs}s"
    if secs < 3600:
        m, s = divmod(secs, 60)
        return f"{m}m{s:02d}s"
    h, rem = divmod(secs, 3600)
    m = rem // 60
    return f"{h}h{m:02d}m"


def _fmt_when(epoch: Optional[int], all_epochs: List[Optional[int]]) -> str:
    """Format a turn-start timestamp; pick a precision matching the data.

    All turns on the same day -> HH:MM:SS
    All turns in the same month -> MM-DD HH:MM
    Otherwise -> YYYY-MM-DD HH:MM
    """
    if epoch is None:
        return "-"

    valid = [e for e in all_epochs if e is not None]
    if not valid:
        return "-"

    local_dt = _epoch_to_local(epoch)
    same_year = all(_epoch_to_local(e).year == local_dt.year for e in valid)
    same_month = same_year and all(_epoch_to_local(e).month == local_dt.month for e in valid)
    same_day = same_month and all(_epoch_to_local(e).day == local_dt.day for e in valid)

    if same_day:
        return local_dt.strftime("%H:%M:%S")
    if same_month:
        return local_dt.strftime("%m-%d %H:%M")
    if same_year:
        return local_dt.strftime("%m-%d %H:%M")
    return local_dt.strftime("%Y-%m-%d %H:%M")


def _has_ai_response(t: Dict[str, Any]) -> bool:
    return (t.get("api_call_count") or 0) > 0 or (t.get("output_tokens") or 0) > 0


def _format_text(turns: List[Dict[str, Any]], file_path: str, show_all: bool = False) -> str:
    if not turns:
        return (
            f"会话:    {file_path}\n"
            f"未找到任何会话轮次。文件可能为空，或只包含元数据。\n"
        )

    base = os.path.basename(file_path)
    epochs: List[Optional[int]] = [t["timestamp"] for t in turns]
    valid_epochs = [e for e in epochs if e is not None]
    span_start = min(valid_epochs) if valid_epochs else None
    span_end = max(valid_epochs) if valid_epochs else None
    span_secs = (span_end - span_start) if (span_start is not None and span_end is not None) else None

    # Aggregates
    total_in = sum(t["input_tokens"] for t in turns)
    total_out = sum(t["output_tokens"] for t in turns)
    total_thinking = sum(t["thinking_tokens"] for t in turns)
    total_cache = sum(t["cache_read_tokens"] for t in turns)
    total_api = sum(t["api_call_count"] for t in turns)
    total_wait = sum((t["human_duration"] or 0) for t in turns)
    turns_with_ai = sum(1 for t in turns if _has_ai_response(t))
    cache_hit_pct = (100.0 * total_cache / (total_cache + total_in)) if (total_cache + total_in) > 0 else 0.0
    models = sorted({t["model"] for t in turns if t["model"]})

    # ---- header block ----
    lines: List[str] = []
    lines.append(f"会话:    {base}")
    if span_start is not None and span_end is not None:
        start_str = _epoch_to_local(span_start).strftime("%Y-%m-%d %H:%M:%S")
        end_str = _epoch_to_local(span_end).strftime("%Y-%m-%d %H:%M:%S")
        lines.append(f"时段:    {start_str} → {end_str}  (总时长 {_fmt_duration(span_secs or 0)})")
    else:
        lines.append("时段:    -")
    ai_label = f"{turns_with_ai} 轮 AI 对话, {len(turns) - turns_with_ai} 轮系统事件"
    lines.append(f"轮次:    {len(turns)}  ({ai_label})")

    # ---- aggregate block ----
    lines.append("")
    lines.append("Token 用量")
    lines.append(f"  新输入:      {_fmt_int(total_in):>12}     "
                 f"(按完整 input 价格计费)")
    lines.append(f"  缓存命中:    {_fmt_int(total_cache):>12}     "
                 f"(从 prompt 缓存读取, 价格更低)")
    total_output_text = total_out - total_thinking
    if total_out > 0:
        text_pct = 100.0 * total_output_text / total_out
        think_pct = 100.0 * total_thinking / total_out
        lines.append(f"  可见输出:    {_fmt_int(total_output_text):>12}     "
                     f"(AI 真正写给你的文本, 占输出 {text_pct:4.1f}%)")
        lines.append(f"  思考:        {_fmt_int(total_thinking):>12}     "
                     f"(模型自言自语, 占输出 {think_pct:4.1f}%)")
    else:
        lines.append(f"  可见输出:    {_fmt_int(total_output_text):>12}")
        lines.append(f"  思考:        {_fmt_int(total_thinking):>12}")
    total_in_with_cache = total_in + total_cache
    lines.append(f"  输入合计:    {_fmt_int(total_in_with_cache):>12}     "
                 f"(缓存占 {cache_hit_pct:4.1f}%)")
    grand_total = total_in_with_cache + total_out
    lines.append(f"  总计:        {_fmt_int(grand_total):>12}     "
                 f"(input + output, 双向之和)")
    lines.append("")
    lines.append(f"  API 调用:    {total_api:>12}")
    lines.append(f"  AI 等待:     {_fmt_duration(total_wait):>12}     "
                 f"(你从提问到 AI 完成响应所等待的时长)")

    # ---- cost estimate ----
    # Per-model breakdown in CNY. Turns whose model isn't in our pricing table
    # are counted separately so the total stays honest about coverage.
    costs_by_model: Dict[str, float] = {}
    unknown_count = 0
    for t in turns:
        if not _has_ai_response(t):
            continue
        c = _cost_cny(t)
        if c is None:
            unknown_count += 1
        else:
            m = t.get("model") or "-"
            costs_by_model[m] = costs_by_model.get(m, 0.0) + c

    if costs_by_model or unknown_count > 0:
        lines.append("")
        lines.append("成本估算 (人民币, 公开价格快照)")
        if costs_by_model:
            name_width = max(_visual_len(_short_model(m)) for m in costs_by_model)
            name_width = max(name_width, _visual_len("总计"))
            for m, c in sorted(costs_by_model.items(), key=lambda x: -x[1]):
                name = _pad_left(_short_model(m), name_width)
                lines.append(f"  {name}  ¥{c:>8.2f}")
            total_cost = sum(costs_by_model.values())
            lines.append(f"  {_pad_left('总计', name_width)}  ¥{total_cost:>8.2f}")
        if unknown_count > 0:
            lines.append(
                f"  注: {unknown_count} 轮使用了未内置定价的模型, 未计入"
            )

    # ---- model usage ----
    # Histogram by API calls (which is what the model actually got billed for),
    # not by turn count -- a single long tool-use turn can drown out many
    # short turns.
    usage = _model_usage(turns)
    if usage:
        lines.append("")
        lines.append("模型使用占比 (按 API 调用次数)")
        total_calls = sum(c for _, c in usage)
        name_width = max(len(_short_model(m)) for m, _ in usage)
        bar_width = 28
        for m, c in usage:
            pct = 100.0 * c / total_calls
            filled = int(round(pct / 100 * bar_width))
            bar = "█" * filled + "░" * (bar_width - filled)
            lines.append(
                f"  {_short_model(m).ljust(name_width)}  {bar}  "
                f"{pct:4.0f}%  ({c} 次调用)"
            )

    # ---- per-turn table ----
    # Default view shows only turns referenced by Anomalies or Highlights —
    # the rest is noise once aggregates and gold-tags are already on screen.
    # `--all` shows every turn including housekeeping (slash commands etc.).
    # Anomalies are detected once here and reused by the Anomalies section
    # below so the indices line up.
    anomalies = _detect_anomalies(turns)
    lines.append("")
    ref_indices = {a["turn"] for a in anomalies} | _highlighted_turn_indices(turns)
    if not show_all:
        lines.append(
            f"明细 ({len(ref_indices)} 轮被异常/亮点引用; "
            f"全部 {len(turns)} 轮, 用 --all 查看全部)"
        )
    else:
        lines.append(f"明细 (全部 {len(turns)} 轮)")

    # Build the per-turn rows and pick widths dynamically.
    rows = []  # list of (cells: list[str], raw_turn: dict)
    for i, t in enumerate(turns, 1):
        if not show_all and i not in ref_indices:
            continue
        when = _fmt_when(t["timestamp"], epochs)
        if _has_ai_response(t):
            model = t["model"] or "-"
            fresh_s = _fmt_tokens(t["input_tokens"])
            cached_s = _fmt_tokens(t["cache_read_tokens"])
            out_s = _fmt_tokens(t["output_tokens"])
            total_s = _fmt_tokens(t["input_tokens"] + t["cache_read_tokens"])
            api_s = str(t["api_call_count"])
            wait_s = _fmt_duration(t["human_duration"])
            ratio = t.get("human_ratio")
            ratio_s = f"{ratio:.4f}" if ratio is not None else "-"
        else:
            # Incomplete / system-only turn: show dashes so the eye can
            # immediately skip these rows. Only reached under --all.
            model = "-"
            fresh_s = "-"
            cached_s = "-"
            out_s = "-"
            total_s = "-"
            api_s = "-"
            wait_s = "-"
            ratio_s = "-"
        cells = [
            str(i),
            when,
            model,
            fresh_s,
            cached_s,
            out_s,
            total_s,
            api_s,
            wait_s,
            ratio_s,
        ]
        rows.append((cells, t))

    headers = ["#", "时间(本地)", "模型", "新输入", "缓存", "输出", "合计", "API", "等待", "人/AI"]
    widths = [_visual_len(h) for h in headers]
    for cells, _ in rows:
        for j, c in enumerate(cells):
            vl = _visual_len(c)
            if vl > widths[j]:
                widths[j] = vl

    def render(cells: List[str]) -> str:
        # Left-align # / 时间 / 模型, right-align the numeric columns.
        out = []
        for j, c in enumerate(cells):
            if j < 3:
                out.append(_pad_left(c, widths[j]))
            else:
                out.append(_pad_right(c, widths[j]))
        return "  ".join(out)

    lines.append("  " + render(headers))
    lines.append("  " + "  ".join("-" * w for w in widths))
    for cells, _ in rows:
        lines.append("  " + render(cells))

    # ---- anomalies ----
    # Fact-only: surface turns that crossed the thresholds defined in
    # `_detect_anomalies`. `anomalies` was already computed above to gate
    # the per-turn table. Deliberately no "you should ..." advice — that's
    # for the reader to decide.
    if anomalies:
        lines.append("")
        lines.append("异常")
        for a in anomalies:
            t = a["turn_data"]
            metric = a["metric"]
            idx = a["turn"]
            if metric == "api_call_count":
                lines.append(
                    f"  • T{idx:<3} API 调用 {a['value']} 次 / "
                    f"等待 {_fmt_duration(t['human_duration'])} / "
                    f"输出 {_fmt_tokens(t['output_tokens'])} tokens"
                )
            elif metric == "input_tokens":
                ratio = t.get("human_ratio")
                ratio_s = f"{ratio:.4f}" if ratio is not None else "-"
                lines.append(
                    f"  • T{idx:<3} 新输入 {_fmt_tokens(a['value'])} "
                    f"(≥ 全会话中位数的 5 倍) / human_ratio={ratio_s}"
                )
            elif metric == "human_ratio":
                lines.append(
                    f"  • T{idx:<3} human_ratio={a['value']:.4f} "
                    f"(输入 {_fmt_tokens(t['input_tokens'])} → "
                    f"输出 {_fmt_tokens(t['output_tokens'])})"
                )
            else:  # synthetic
                lines.append(
                    f"  • T{idx:<3} AI 调用失败 "
                    f"(鉴权/网络/限流 等; 未产生计费, 共 {t['synthetic_count']} 条记录)"
                )

    # ---- highlights ----
    lines.append("")
    lines.append("亮点")

    if turns_with_ai == 0:
        lines.append("  • 本会话无 AI 回复。")
    else:
        # Largest turn by total model input (fresh + cached) -- the most
        # "expensive" interaction in terms of model context.
        def context_size(t: Dict[str, Any]) -> int:
            if not _has_ai_response(t):
                return -1
            return t["input_tokens"] + t["cache_read_tokens"] + t["output_tokens"]
        biggest = max(turns, key=context_size)
        if _has_ai_response(biggest):
            i = turns.index(biggest) + 1
            sz = biggest["input_tokens"] + biggest["cache_read_tokens"] + biggest["output_tokens"]
            lines.append(f"  • 最大轮次:    #{i} "
                         f"(读写共 {_fmt_tokens(sz)} tokens, "
                         f"{biggest['api_call_count']} 次 API 调用, "
                         f"{_fmt_duration(biggest['human_duration'])})")

        # Cache hit champion = max cache_read_tokens
        if total_cache > 0:
            champion = max(turns, key=lambda t: t["cache_read_tokens"])
            if champion["cache_read_tokens"] > 0:
                i = turns.index(champion) + 1
                hit = (100.0 * champion["cache_read_tokens"] /
                       max(1, champion["cache_read_tokens"] + champion["input_tokens"]))
                lines.append(f"  • 缓存最优:    #{i} "
                             f"(命中 {_fmt_tokens(champion['cache_read_tokens'])} tokens, "
                             f"占输入 {hit:.1f}%)")

        # Longest wait
        waited = [t for t in turns if t["human_duration"]]
        if waited:
            slowest = max(waited, key=lambda t: t["human_duration"])
            i = turns.index(slowest) + 1
            lines.append(f"  • 等待最久:    #{i} "
                         f"(等了 {_fmt_duration(slowest['human_duration'])}, "
                         f"换回 {_fmt_tokens(slowest['output_tokens'])} tokens 输出)")

        # Highest leverage = smallest positive human_ratio (you typed least
        # input to elicit the most output, i.e. "one prompt and AI got it").
        leveraged = [t for t in turns
                     if t.get("human_ratio") is not None and t["human_ratio"] > 0]
        if leveraged:
            sharpest = min(leveraged, key=lambda t: t["human_ratio"])
            i = turns.index(sharpest) + 1
            lines.append(f"  • 交互最高效:  #{i} "
                         f"(human_ratio={sharpest['human_ratio']:.4f}: "
                         f"输入 {_fmt_tokens(sharpest['human_input_tokens'])} "
                         f"→ 输出 {_fmt_tokens(sharpest['output_tokens'])})")

    # ---- notes about model behaviour ----
    # Models that don't use extended thinking (e.g. DeepSeek, standard
    # Haiku) produce only text/tool_use content blocks — no "thinking"
    # blocks. Output tokens are then all classified as visible text,
    # and thinking_tokens stays at 0. Surface this so the user
    # understands the numbers.
    if total_thinking == 0 and total_out > 0 and models:
        non_anthropic = [m for m in models if "claude" not in m.lower()]
        if non_anthropic:
            lines.append("")
            lines.append("备注")
            lines.append(f"  thinking_tokens = 0: 模型 '{', '.join(non_anthropic)}' 不会产生独立的")
            lines.append("  thinking 内容块, 推理过程 (如果有) 会被合并进可见的 output_tokens,")
            lines.append("  无法单独区分。")

    lines.append("")
    return "\n".join(lines)


# ---- brief formatter (compact summary for AI agents) ----

def _format_brief(turns: List[Dict[str, Any]], file_path: str) -> str:
    """Render a token-dense summary aimed at LLM consumption.

    Fixed-line shape (no JSON) so the reader doesn't need to deserialize and
    pay for whitespace. Anomalies are pre-labelled so the reader doesn't have
    to redo the percentile / threshold work itself. Deliberately no
    'suggestions' section: those bias whoever reads this next.
    """
    base = os.path.basename(file_path)
    if not turns:
        return f"会话 {base} | 0 轮\n"

    total_in = sum(t["input_tokens"] for t in turns)
    total_out = sum(t["output_tokens"] for t in turns)
    total_thinking = sum(t["thinking_tokens"] for t in turns)
    total_cache = sum(t["cache_read_tokens"] for t in turns)
    total_api = sum(t["api_call_count"] for t in turns)
    total_wait = sum((t["human_duration"] or 0) for t in turns)
    cache_pct = (
        100.0 * total_cache / (total_cache + total_in)
        if (total_cache + total_in) > 0 else 0.0
    )

    epochs = [t["timestamp"] for t in turns if t["timestamp"] is not None]
    wall = (max(epochs) - min(epochs)) if len(epochs) >= 2 else 0

    models_str = " ".join(
        f"{_short_model(m)}({c})" for m, c in _model_usage(turns)
    ) or "-"

    # Cost estimate — total CNY across turns with known pricing, plus a
    # tail-tag for any turns whose model isn't in the internal price table.
    cost_total = 0.0
    cost_unknown = 0
    for t in turns:
        if not _has_ai_response(t):
            continue
        c = _cost_cny(t)
        if c is None:
            cost_unknown += 1
        else:
            cost_total += c
    cost_str = f"cost=¥{cost_total:.2f}"
    if cost_unknown > 0:
        cost_str += f"(+{cost_unknown}_unpriced)"

    lines: List[str] = []
    lines.append(
        f"会话 {base} | {len(turns)} 轮 | "
        f"时长 {_fmt_duration(wall)} | 模型: {models_str}"
    )
    lines.append(
        f"用量: in={_fmt_tokens(total_in)} "
        f"cache={_fmt_tokens(total_cache)}({cache_pct:.0f}%) "
        f"out={_fmt_tokens(total_out)}(think={_fmt_tokens(total_thinking)}) | "
        f"api={total_api} | wait={_fmt_duration(total_wait)} | {cost_str}"
    )

    anomalies = _detect_anomalies(turns)
    if anomalies:
        lines.append("")
        lines.append("异常 (轮次 / 指标 / 值 / 上下文):")
        for a in anomalies:
            t = a["turn_data"]
            metric = a["metric"]
            if metric == "api_call_count":
                ctx = f"out={t['output_tokens']} wait={_fmt_duration(t['human_duration'])}"
                value = str(a["value"])
            elif metric == "input_tokens":
                ratio = t.get("human_ratio")
                ratio_s = f"{ratio:.4f}" if ratio is not None else "-"
                ctx = f"5x_session_median human_ratio={ratio_s}"
                value = _fmt_tokens(a["value"])
            elif metric == "human_ratio":
                ctx = (
                    f"input={_fmt_tokens(t['input_tokens'])} "
                    f"out={_fmt_tokens(t['output_tokens'])}"
                )
                value = f"{a['value']:.4f}"
            else:  # synthetic
                ctx = "usage=zero"
                value = "<synthetic>"
            lines.append(
                f"  T{a['turn']:<3} {metric:<18} {value:<12} {ctx}"
            )

    trends = _trends(turns, bucket=5)
    if trends:
        lines.append("")
        lines.append("趋势 (每 5 轮):")
        cache_line = " / ".join(f"{v:.2f}" for v in trends["cache_hit_rate"])
        text_line = " / ".join(f"{v:.2f}" for v in trends["output_text_ratio"])
        lines.append(f"  cache_hit_rate:    {cache_line}")
        lines.append(f"  output_text_ratio: {text_line}")

    lines.append("")
    return "\n".join(lines)


# ---------- session-id resolution ----------

CLAUDE_PROJECTS_ROOT = os.path.expanduser("~/.claude/projects")


def _resolve_session_id(session_id: str) -> str:
    """Locate the JSONL file for a Claude Code session UUID.

    Search order:
      1. The project directory derived from the current working directory
         (Claude Code names project dirs by replacing '/' with '-' in cwd).
      2. Failing that, scan every immediate subdirectory of
         ``~/.claude/projects/`` — session UUIDs are globally unique.

    Raises FileNotFoundError with a useful message if nothing matches.
    """
    if not os.path.isdir(CLAUDE_PROJECTS_ROOT):
        raise FileNotFoundError(
            f"Claude projects directory not found: {CLAUDE_PROJECTS_ROOT}"
        )

    filename = f"{session_id}.jsonl"
    cwd_project = os.getcwd().replace("/", "-")
    primary = os.path.join(CLAUDE_PROJECTS_ROOT, cwd_project, filename)
    if os.path.isfile(primary):
        return primary

    for entry in os.listdir(CLAUDE_PROJECTS_ROOT):
        candidate = os.path.join(CLAUDE_PROJECTS_ROOT, entry, filename)
        if os.path.isfile(candidate):
            return candidate

    raise FileNotFoundError(
        f"Session not found under {CLAUDE_PROJECTS_ROOT}: {session_id}"
    )


# ---------- CLI ----------

def main(argv: Optional[List[str]] = None) -> int:
    ap = argparse.ArgumentParser(
        description="Parse a Claude Code session JSONL into per-turn statistics."
    )
    src = ap.add_mutually_exclusive_group(required=True)
    src.add_argument("--file", help="Path to the JSONL session file.")
    src.add_argument(
        "--session-id", dest="session_id",
        help="Claude Code session UUID; located under ~/.claude/projects/. "
             "Searches the cwd-derived project first, then all projects.",
    )
    ap.add_argument(
        "--offset",
        type=int,
        default=0,
        help="Byte offset to start reading from (default: 0). Useful for "
             "incremental processing of an append-only JSONL.",
    )
    ap.add_argument(
        "--format",
        choices=("text", "tsv", "json", "brief"),
        default="text",
        help="Output format: text (default, human-readable), tsv (machine), "
             "json (machine), or brief (compact AI-agent summary).",
    )
    ap.add_argument(
        "--all",
        dest="show_all",
        action="store_true",
        help="In text format, also show housekeeping turns "
             "(slash commands / system events with no AI response).",
    )
    args = ap.parse_args(argv)

    if args.offset < 0:
        ap.error("--offset must be >= 0")

    if args.session_id:
        try:
            args.file = _resolve_session_id(args.session_id)
        except FileNotFoundError as e:
            ap.error(str(e))

    with open(args.file, "r", encoding="utf-8", errors="replace") as f:
        if args.offset:
            f.seek(args.offset)
        turns = _process(f)

    if args.format == "tsv":
        out = _format_tsv(turns)
    elif args.format == "json":
        out = _format_json(turns)
    elif args.format == "brief":
        out = _format_brief(turns, args.file)
    else:
        out = _format_text(turns, args.file, show_all=args.show_all)

    sys.stdout.write(out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
