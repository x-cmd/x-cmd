##x engine: python
##x pip: tomlkit

"""Write ~/.codex/config.toml to use the deepseek provider.

Usage: python3 <this_file> [tty] [model] [base_url]

  tty       '1' / 'yes' to enable ANSI color in summary
  model     model name (default: deepseek-v4-flash)
  base_url  API base URL (default: https://api.deepseek.com/)

Env vars honored:
  CODEX_HOME          codex config dir (default: ~/.codex)
  DEEPSEEK_MODEL      override default model
  DEEPSEEK_BASE_URL   override default base URL

Uses tomlkit to preserve comments, key order, and table style.
Trade-off discussion: .x-cmd/story/260814.dasel写作config.toml.md
"""

import os
import shutil
import sys
import time

import tomlkit


tty = len(sys.argv) > 1 and sys.argv[1] in ("1", "yes")

model = (
    (sys.argv[2] if len(sys.argv) > 2 and sys.argv[2] else None)
    or os.environ.get("DEEPSEEK_MODEL")
    or "deepseek-v4-flash"
)

base_url = (
    (sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] else None)
    or os.environ.get("DEEPSEEK_BASE_URL")
    or "https://api.deepseek.com/"
)


def p(k, v, color="1;36"):
    if v is None:
        return
    line = "%-25s: %s" % (k, v)
    if tty:
        print("\033[%sm%s\033[0m" % (color, line))
    else:
        print(line)


def err(msg):
    print("error:", msg, file=sys.stderr)
    sys.exit(1)


def deep_set(doc, path, value):
    """Set a dotted-path key in a tomlkit document, creating tables as needed."""
    keys = path.split(".")
    cur = doc
    for k in keys[:-1]:
        if k not in cur or not isinstance(cur[k], dict):
            cur[k] = tomlkit.table()
        cur = cur[k]
    cur[keys[-1]] = value


# ── resolve config path ───────────────────────────────────────────
config_dir  = os.environ.get("CODEX_HOME") or os.path.expanduser("~/.codex")
config_file = os.path.join(config_dir, "config.toml")

os.makedirs(config_dir, exist_ok=True)

# ── read existing doc (or empty) ──────────────────────────────────
if os.path.exists(config_file) and os.path.getsize(config_file) > 0:
    with open(config_file, "r") as f:
        doc = tomlkit.parse(f.read())
else:
    doc = tomlkit.document()

# ── backup ────────────────────────────────────────────────────────
backup = f"{config_file}.bak.{int(time.time())}"
if os.path.exists(config_file) and os.path.getsize(config_file) > 0:
    shutil.copy2(config_file, backup)

# ── resolve API key ───────────────────────────────────────────────
api_key = os.environ.get("DEEPSEEK_API_KEY", "").strip()
if not api_key:
    err("DEEPSEEK_API_KEY is not set")
if not api_key.startswith("sk-"):
    err("DEEPSEEK_API_KEY must start with 'sk-'")

# ── link models.json to bundled catalog ───────────────────────────
mod_root = os.environ.get("___X_CMD_ROOT_MOD")
if not mod_root:
    err("___X_CMD_ROOT_MOD is not set")
bundled_catalog = os.path.join(mod_root, "codex", "lib", "other", "ds.models.json")
if not os.path.isfile(bundled_catalog):
    err(f"Missing bundled catalog: {bundled_catalog}")

models_json = os.path.join(config_dir, "models.json")
if os.path.islink(models_json):
    os.remove(models_json)
elif os.path.exists(models_json):
    shutil.copy2(models_json, f"{models_json}.bak.{int(time.time())}")
    os.remove(models_json)
try:
    os.symlink(bundled_catalog, models_json)
except OSError as e:
    err(f"Failed to create symlink {models_json} -> {bundled_catalog}: {e}")

# ── write fields ─────────────────────────────────────────────────
deep_set(doc, "model",                                              model)
deep_set(doc, "model_provider",                                     "deepseek")
deep_set(doc, "preferred_auth_method",                              "apikey")
deep_set(doc, "forced_login_method",                                "api")
deep_set(doc, "model_reasoning_effort",                             "high")
deep_set(doc, "model_catalog_json",                                 "~/.codex/models.json")
deep_set(doc, "model_providers.deepseek.name",                      "deepseek")
deep_set(doc, "model_providers.deepseek.base_url",                  base_url)
deep_set(doc, "model_providers.deepseek.wire_api",                  "responses")
deep_set(doc, "model_providers.deepseek.experimental_bearer_token", api_key)

# ── write back ────────────────────────────────────────────────────
with open(config_file, "w") as f:
    f.write(tomlkit.dumps(doc))

# ── summary ───────────────────────────────────────────────────────
ok = "\033[1;32m✓\033[0m" if tty else "✓"
print("%s wrote %s" % (ok, config_file))
if os.path.exists(backup):
    print("  backup: %s" % backup)
print()
p("model",                                  model)
p("model_provider",                         "deepseek")
p("model_reasoning_effort",                 "high")
p("model_providers.deepseek.base_url",      base_url)
p("model_providers.deepseek.wire_api",      "responses")
p("model_providers.deepseek.bearer_token",  api_key[:8] + "...")
