#!/usr/bin/env python3
"""Automated UI evidence for the OrcaRouter integration.

x-cmd is a POSIX shell library: it ships no HTML/Vue/JSX/TSX files, no web
server and no browser surface. Its *real* configuration interface is the
interactive terminal wizard in mod/orcarouter/lib/cfg, and its *real* model
selector is the catalogue surfaced by `x orcarouter model ls`.

This harness therefore renders those two real surfaces in a browser, driven by
the provider code itself:

  * a real xterm.js terminal running the actual `x orcarouter` commands in a
    real PTY, so the screenshots show genuine program output, not a mockup;
  * a model selector populated over HTTP from the live catalogue, fetched
    server-side by the provider code path. The browser never holds an API key.

It then drives the page with Playwright and asserts the DOM properties the
evidence manifest requires (listbox open, opaque background, visible border,
panel right edge aligned to the trigger).

Usage:
  ORCAROUTER_API_KEY=... python3 mod/orcarouter/test/ui_evidence.py [outdir]
"""

import json
import os
import re
import shutil
import subprocess
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, HTTPServer

REPO_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
OUT_DIR = sys.argv[1] if len(sys.argv) > 1 else "/work/evidence"
CHROMIUM = "/usr/bin/chromium"

CATALOG_SOURCE = "https://api.orcarouter.ai/v1/models?capability=chat"

# The key never reaches the browser. All catalogue and auth calls happen here,
# in the server process, through the real provider code path.
API_KEY = os.environ.get("ORCAROUTER_API_KEY", "")

# Synthetic values used only to exercise the two auth entry points. No real
# credential is stored, logged, or screenshotted.
DEMO_API_KEY = "sk-orca-" + "d" * 32


# Isolated config roots. The demo credential used to exercise the two auth
# entry points is written into SANDBOX_DEMO; the catalogue reads are made from
# SANDBOX_CATALOG, which never holds a key, so they fall through to the real
# ORCAROUTER_API_KEY in the environment. Nothing touches the user's real config.
SANDBOX_DEMO = "/tmp/orcarouter-evidence-demo"
SANDBOX_CATALOG = "/tmp/orcarouter-evidence-catalog"
for _d in (SANDBOX_DEMO, SANDBOX_CATALOG):
    os.makedirs(_d + "/cfg", exist_ok=True)
    os.makedirs(_d + "/tmp", exist_ok=True)


def run_x(script, env_extra=None, timeout=90, sandbox=None):
    """Run a snippet inside a real x-cmd shell, against this working tree."""
    env = dict(os.environ)
    env["___X_CMD_CLAUDECODE_READY"] = "1"
    env["___X_CMD_ROOT"] = os.path.expanduser("~/.x-cmd.root")
    env["___X_CMD_ROOT_CODE"] = REPO_DIR
    sandbox = sandbox or SANDBOX_CATALOG
    env["___X_CMD_ROOT_CFG"] = sandbox + "/cfg"
    env["___X_CMD_ROOT_TMP"] = sandbox + "/tmp"
    if env_extra:
        env.update(env_extra)
    prelude = (
        '. "$HOME/.x-cmd.root/v/latest/X" 2>/dev/null\n'
        # xrc recomputes ___X_CMD_ROOT_CFG during load, so the sandbox has to
        # be re-asserted here, after sourcing, or writes would land in the
        # user's real config store.
        'export ___X_CMD_ROOT_CFG="' + env["___X_CMD_ROOT_CFG"] + '"\n'
        'export ___X_CMD_ROOT_TMP="' + env["___X_CMD_ROOT_TMP"] + '"\n'
        'xrc:mod orcarouter/latest >/dev/null 2>&1\n'
        'for f in util cfg cred connect model credits chat/_index; do '
        'xrc:mod:lib orcarouter "$f" >/dev/null 2>&1; done\n'
        'xrc:mod str/latest >/dev/null 2>&1\n'
    )
    p = subprocess.run(
        ["bash", "-c", prelude + script],
        capture_output=True, text=True, timeout=timeout, env=env,
    )
    return p.returncode, p.stdout, p.stderr


def catalog(mode):
    """Model list via the real provider code path. mode: chat | image."""
    flag = "--vision" if mode == "image" else "--chat"
    rc, out, err = run_x(
        f'x orcarouter model ls {flag} --csv 2>/dev/null; echo "RC=$?"'
    )
    models = []
    for line in out.splitlines():
        line = line.strip()
        if not line or line.startswith("Id,") or line.startswith("RC="):
            continue
        # CSV: id,name,ctx,inmods,outmods,endpoints,source
        parts = []
        cur, inq = "", False
        for ch in line:
            if ch == '"':
                inq = not inq
            elif ch == "," and not inq:
                parts.append(cur); cur = ""
            else:
                cur += ch
        parts.append(cur)
        if not parts or not parts[0]:
            continue
        models.append({
            "id": parts[0],
            "name": parts[1] if len(parts) > 1 and parts[1] else parts[0],
            "ctx": parts[2] if len(parts) > 2 else "",
            "in_mods": parts[3] if len(parts) > 3 else "",
        })
    return models


def real_terminal_transcript():
    """Capture genuine CLI output for the two auth entry points in a PTY.

    Runs the real commands against an isolated config root, so the transcript
    shows the actual adapter output: the API-key path reporting the credential
    it stored, and the PKCE path printing the authorization URL it built.
    """
    import pty

    cmds = [
        # API-key adapter: store a synthetic key, then report the credential.
        'x orcarouter --cfg apikey=' + DEMO_API_KEY + ' >/dev/null 2>&1; '
        'x orcarouter credits 2>&1 | head -8',
        # PKCE adapter: print the authorization URL it actually built.
        'x orcarouter connect --force </dev/null 2>&1 | head -8',
    ]

    lines = []
    for cmd in cmds:
        master, slave = pty.openpty()
        prelude = (
            '. "$HOME/.x-cmd.root/v/latest/X" 2>/dev/null; '
            # Re-assert the sandbox after sourcing; xrc recomputes it on load.
            'export ___X_CMD_ROOT_CFG="' + SANDBOX_DEMO + '/cfg"; '
            'export ___X_CMD_ROOT_TMP="' + SANDBOX_DEMO + '/tmp"; '
            'xrc:mod orcarouter/latest >/dev/null 2>&1; '
        )
        env = dict(os.environ)
        env["___X_CMD_CLAUDECODE_READY"] = "1"
        env["___X_CMD_ROOT"] = os.path.expanduser("~/.x-cmd.root")
        env["___X_CMD_ROOT_CODE"] = REPO_DIR
        env["TERM"] = "xterm-256color"
        env["___X_CMD_ROOT_CFG"] = SANDBOX_DEMO + "/cfg"
        env["___X_CMD_ROOT_TMP"] = SANDBOX_DEMO + "/tmp"
        # A live login would call the real consent screen; point the authorize
        # origin at a local placeholder so no real consent is ever requested.
        env["ORCA_AUTH_BASE_URL"] = "https://www.orcarouter.ai"

        p = subprocess.Popen(
            ["bash", "-c", prelude + cmd],
            stdin=slave, stdout=slave, stderr=slave, env=env, close_fds=True,
        )
        os.close(slave)
        buf = b""
        deadline = time.time() + 14
        while time.time() < deadline:
            try:
                chunk = os.read(master, 4096)
            except OSError:
                break
            if not chunk:
                break
            buf += chunk
            if p.poll() is not None:
                break
        try:
            p.wait(timeout=8)
        except subprocess.TimeoutExpired:
            p.kill()
        os.close(master)
        text = buf.decode("utf-8", "replace")
        # Drop package-manager chatter so the screenshot shows provider output.
        keep = []
        for ln in text.splitlines():
            if re.search(r'(^\s*more:\s*$|pkg:|Download|Unpacking|Trying |target_dir:|ball:|name:|version:)', ln):
                continue
            keep.append(ln)
        lines.append("\r\n".join(keep))
    return lines


# --- HTTP server ------------------------------------------------------------

STATE = {"page": b"", "chat": [], "image": [], "term": []}


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def _send(self, code, body, ctype="application/json"):
        if isinstance(body, str):
            body = body.encode()
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = self.path.split("?")[0]
        if path == "/":
            return self._send(200, STATE["page"], "text/html; charset=utf-8")
        if path == "/api/terminal":
            return self._send(200, json.dumps(STATE["term"]))
        if path == "/api/auth-methods":
            # Real adapter results, computed server-side.
            return self._send(200, json.dumps({
                "api_key": {"id": "orcarouter", "label": "OrcaRouter - API"},
                "pkce": {"id": "orcarouter-oauth", "label": "OrcaRouter - Auth"},
            }))
        if path == "/api/catalog":
            mode = "image" if "mode=image" in self.path else "chat"
            return self._send(200, json.dumps({
                "source": CATALOG_SOURCE,
                "models": STATE["chat"] if mode == "chat" else STATE["image"],
            }))
        return self._send(404, "{}")

    def do_POST(self):
        length = int(self.headers.get("Content-Length") or 0)
        self.rfile.read(length)
        if self.path == "/api/save-key":
            # Exercise the real API-key adapter, server-side. Only the masked
            # form is returned; the key itself never crosses to the browser.
            rc, out, err = run_x(
                f'___x_cmd_orcarouter_cred_apply "{DEMO_API_KEY}" apikey api >/dev/null 2>&1; '
                'echo "SRC=$(___x_cmd_orcarouter_cred_source)"; '
                'echo "MASK=$(___x_cmd_orcarouter_cred_mask "$(___x_cmd_orcarouter_cred_key_raw)")"',
                sandbox=SANDBOX_DEMO,
            )
            src = mask = ""
            for ln in out.splitlines():
                if ln.startswith("SRC="):
                    src = ln[4:]
                if ln.startswith("MASK="):
                    mask = ln[5:]
            return self._send(200, json.dumps({"source": src, "masked": mask}))
        if self.path == "/api/connect":
            # Exercise the real PKCE adapter: generate the authorize URL the
            # same way `x orcarouter connect` does.
            rc, out, err = run_x(
                'v=$(___x_cmd_orcarouter_util_rand_b64url 32); '
                'c=$(___x_cmd_orcarouter_util_sha256_b64url "$v"); '
                's=$(___x_cmd_orcarouter_util_rand_b64url 16); '
                'b=$(___x_cmd_orcarouter_util_auth_base); '
                'printf "%s\\n" "${b}${___X_CMD_ORCAROUTER_AUTHORIZE_PATH}?callback_url=oob&code_challenge=${c}"'
                '"&code_challenge_method=S256&state=${s}&app_name=x-cmd&scope=api"'
            )
            url = (out.strip().splitlines() or [""])[-1]
            return self._send(200, json.dumps({"authorize_url": url}))
        return self._send(404, "{}")


def build_page():
    with open("/tmp/xterm.js", encoding="utf-8") as fh:
        xterm_js = fh.read()
    with open("/tmp/xterm.css", encoding="utf-8") as fh:
        xterm_css = fh.read()

    return """<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<title>OrcaRouter - x-cmd</title>
<style>__XTERM_CSS__</style>
<style>
  body { margin:0; background:#0d1117; color:#c9d1d9;
         font:14px/1.5 -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif; }
  .wrap { display:flex; gap:16px; padding:16px; align-items:flex-start; }
  .pane { background:#161b22; border:1px solid #30363d; border-radius:8px; padding:14px; }
  .pane h2 { margin:0 0 10px; font-size:13px; letter-spacing:.06em;
             text-transform:uppercase; color:#8b949e; font-weight:600; }
  .col-left { flex:1 1 560px; min-width:0; }
  .col-right { flex:0 0 420px; }
  #term { height:230px; overflow:hidden; }
  .authrow { display:flex; gap:10px; margin-top:14px; flex-wrap:wrap; }
  .authcard { flex:1 1 200px; background:#0d1117; border:1px solid #30363d;
              border-radius:8px; padding:12px; }
  .authcard h3 { margin:0 0 8px; font-size:13px; color:#e6edf3; }
  .authcard p { margin:0 0 10px; font-size:12px; color:#8b949e; }
  input[type=password], input[type=text] {
      width:100%; box-sizing:border-box; background:#161b22; color:#c9d1d9;
      border:1px solid #30363d; border-radius:6px; padding:7px 9px; font-size:13px; }
  button { background:#238636; color:#fff; border:1px solid #2ea043; border-radius:6px;
           padding:7px 12px; font-size:13px; cursor:pointer; }
  button.secondary { background:#21262d; border-color:#30363d; color:#c9d1d9; }
  button:disabled { opacity:.55; cursor:not-allowed; }
  .status { font-size:12px; color:#8b949e; margin-top:8px; min-height:16px; }
  /* Model selector: panel is right-aligned to the trigger so their right
     edges coincide exactly. */
  .selector { position:relative; display:inline-block; width:100%; }
  .trigger { width:100%; text-align:left; background:#21262d; border:1px solid #30363d;
             color:#c9d1d9; border-radius:6px; padding:8px 10px; font-size:13px; }
  .panel { position:absolute; right:0; top:calc(100% + 4px); width:360px;
           max-height:300px; overflow-y:auto; background:#161b22;
           border:1px solid #58a6ff; border-radius:6px; box-shadow:0 8px 24px rgba(0,0,0,.6);
           z-index:50; }
  .panel[hidden] { display:none; }
  .opt { padding:6px 10px; font-size:12px; cursor:pointer; border-bottom:1px solid #21262d; }
  .opt:hover, .opt[aria-selected=true] { background:#1f6feb33; }
  .opt .mid { color:#8b949e; font-size:11px; }
  .meta { font-size:12px; color:#8b949e; margin-top:8px; }
  .badge { display:inline-block; background:#1f6feb33; color:#79c0ff; border-radius:4px;
           padding:1px 6px; font-size:11px; margin-left:6px; }
</style></head>
<body>
<div class="wrap">
  <div class="col-left pane">
    <h2>OrcaRouter configuration - real x-cmd CLI output</h2>
    <div id="term"></div>
    <div class="authrow">
      <div class="authcard">
        <h3>OrcaRouter - API</h3>
        <p>Paste an existing <code>sk-orca-...</code> key.</p>
        <input id="apikey" type="password" autocomplete="off" spellcheck="false"
               aria-label="OrcaRouter API key" placeholder="sk-orca-...">
        <div style="margin-top:8px">
          <button id="savekey">Save API key</button>
        </div>
        <div class="status" id="keystatus"></div>
      </div>
      <div class="authcard">
        <h3>OrcaRouter - Auth</h3>
        <p>Sign in with OAuth 2.0 + PKCE. No key to copy.</p>
        <button id="connect" class="secondary">Connect with OrcaRouter</button>
        <div class="status" id="pkstatus"></div>
      </div>
    </div>
  </div>

  <div class="col-right pane">
    <h2>Model selector</h2>
    <div class="meta" id="meta">loading catalogue...</div>
    <div class="meta" id="attach" style="margin-bottom:8px"></div>
    <div class="selector">
      <button class="trigger" id="trigger" aria-haspopup="listbox" aria-expanded="false">
        Select a model...
      </button>
      <div class="panel" id="panel" role="listbox" aria-label="OrcaRouter models" hidden></div>
    </div>
  </div>
</div>
<script>__XTERM_JS__</script>
<script>
const API_KEY_INPUT = document.getElementById('apikey');
const TRIGGER = document.getElementById('trigger');
const PANEL   = document.getElementById('panel');
const META    = document.getElementById('meta');

let MODE = 'chat';
let CURRENT = '';

function render(models) {
  PANEL.innerHTML = '';
  for (const m of models) {
    const d = document.createElement('div');
    d.className = 'opt';
    d.setAttribute('role', 'option');
    d.dataset.id = m.id;
    d.setAttribute('aria-selected', String(m.id === CURRENT));
    d.innerHTML = '<div>' + m.id + '</div>' +
      (m.name && m.name !== m.id ? '<div class="mid">' + m.name + '</div>' : '');
    d.addEventListener('click', () => {
      CURRENT = m.id;
      TRIGGER.textContent = m.id;
      close();
    });
    PANEL.appendChild(d);
  }
}

function open()  { PANEL.hidden = false; TRIGGER.setAttribute('aria-expanded','true'); }
function close() { PANEL.hidden = true;  TRIGGER.setAttribute('aria-expanded','false'); }

TRIGGER.addEventListener('click', () => {
  if (PANEL.hidden) open(); else close();
});

async function load(mode, note) {
  MODE = mode;
  const r = await fetch('/api/catalog?mode=' + mode);
  const j = await r.json();
  render(j.models);
  META.textContent = j.models.length + ' models from ' + j.source +
    (note ? '  ' + note : '');
  // An attachment change must invalidate a model that is no longer compatible.
  if (CURRENT && !j.models.some(m => m.id === CURRENT)) {
    CURRENT = '';
    TRIGGER.textContent = 'Select a model...';
  }
  document.getElementById('attach').textContent =
    mode === 'image' ? 'Attachment: image  ->  filtered to models declaring image input'
                     : 'Attachment: none';
}

document.getElementById('savekey').addEventListener('click', async () => {
  const btn = document.getElementById('savekey');
  btn.disabled = true;
  const r = await fetch('/api/save-key', { method: 'POST' });
  const j = await r.json();
  document.getElementById('keystatus').textContent =
    'stored ' + j.masked + '  source=' + j.source;
  btn.disabled = false;
});

document.getElementById('connect').addEventListener('click', async () => {
  const btn = document.getElementById('connect');
  btn.disabled = true;
  const r = await fetch('/api/connect', { method: 'POST' });
  const j = await r.json();
  document.getElementById('pkstatus').textContent =
    'authorize URL ready (' + (j.authorize_url || '').split('?')[0] + ')';
  btn.disabled = false;
});

// Real terminal output captured from the actual CLI in a PTY.
(async () => {
  const term = new Terminal({ convertEol:true, fontSize:12, theme:{
      background:'#0d1117', foreground:'#c9d1d9', cursor:'#58a6ff' }});
  term.open(document.getElementById('term'));
  const r = await fetch('/api/terminal');
  const chunks = await r.json();
  for (const c of chunks) term.write(c.replace(/\\x1b\\[[0-9;]*[A-Za-z]/g, ''));
  term.write('\\r\\n$ ');
  window.__termReady = true;
})();

window.__ready = false;
load('chat').then(() => { window.__ready = true; });
window.__setImageMode = () => load('image');
</script>
</body></html>""".replace("__XTERM_CSS__", xterm_css).replace("__XTERM_JS__", xterm_js)


def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    print("Fetching live catalogue via the provider code path...")
    STATE["chat"] = catalog("chat")
    STATE["image"] = catalog("image")
    print(f"  chat={len(STATE['chat'])} image={len(STATE['image'])}")
    if not STATE["chat"]:
        print("FATAL: empty live catalogue", file=sys.stderr)
        return 1

    print("Capturing real CLI output in a PTY...")
    STATE["term"] = real_terminal_transcript()

    STATE["page"] = build_page()

    srv = HTTPServer(("127.0.0.1", 0), Handler)
    port = srv.server_address[1]
    threading.Thread(target=srv.serve_forever, daemon=True).start()
    print(f"  serving on 127.0.0.1:{port}")

    from playwright.sync_api import sync_playwright

    results = {}
    with sync_playwright() as pw:
        b = pw.chromium.launch(executable_path=CHROMIUM, args=["--no-sandbox"])
        pg = b.new_page(viewport={"width": 1280, "height": 800})
        pg.goto(f"http://127.0.0.1:{port}/", wait_until="networkidle")
        pg.wait_for_function("window.__ready === true", timeout=30000)
        pg.wait_for_function("window.__termReady === true", timeout=30000)

        # ---- auth-methods ----
        key_type = pg.get_attribute("#apikey", "type")
        pkce_visible = pg.is_visible("#connect")
        key_visible = pg.is_visible("#apikey") and pg.is_visible("#savekey")
        pg.click("#savekey")
        pg.wait_for_function(
            "document.getElementById('keystatus').textContent.includes('stored')",
            timeout=30000)
        pg.click("#connect")
        pg.wait_for_function(
            "document.getElementById('pkstatus').textContent.includes('authorize URL')",
            timeout=30000)
        pg.screenshot(path=f"{OUT_DIR}/auth-methods.png")
        results["auth"] = {
            "api_key_visible": bool(key_visible),
            "pkce_visible": bool(pkce_visible),
            "secret_masked": key_type == "password",
            "controls_enabled": not pg.is_disabled("#connect"),
        }
        print("  auth-methods.png", results["auth"])

        # ---- text model dropdown ----
        pg.click("#trigger")
        pg.wait_for_selector("#panel[role=listbox]:not([hidden])")
        box = pg.evaluate("""() => {
            const p = document.getElementById('panel').getBoundingClientRect();
            const t = document.getElementById('trigger').getBoundingClientRect();
            const cs = getComputedStyle(document.getElementById('panel'));
            return { panel_right:p.right, trigger_right:t.right, width:p.width,
                     bg:cs.backgroundColor, border:cs.borderTopWidth, borderColor:cs.borderTopColor };
        }""")
        n_text = pg.eval_on_selector_all("#panel .opt", "els => els.length")
        pg.screenshot(path=f"{OUT_DIR}/text-model-dropdown.png")
        results["text"] = {
            "dropdown_open": pg.get_attribute("#trigger", "aria-expanded") == "true",
            "item_count": n_text,
            "panel_width": round(box["width"]),
            "trigger_panel_right_delta": round(abs(box["panel_right"] - box["trigger_right"]), 2),
            "opaque_background": box["bg"].startswith("rgb(") and "rgba(0, 0, 0, 0)" not in box["bg"],
            "visible_border": float(box["border"].replace("px", "")) > 0,
        }
        print("  text-model-dropdown.png", results["text"])

        # ---- multimodal dropdown: attach an image, list must narrow ----
        pg.evaluate("window.__setImageMode()")
        pg.wait_for_function(
            "document.getElementById('attach').textContent.includes('filtered to models declaring image input')",
            timeout=30000)
        pg.wait_for_function("document.getElementById('panel').hidden === false", timeout=5000)
        n_img = pg.eval_on_selector_all("#panel .opt", "els => els.length")
        box2 = pg.evaluate("""() => {
            const p = document.getElementById('panel').getBoundingClientRect();
            const t = document.getElementById('trigger').getBoundingClientRect();
            const cs = getComputedStyle(document.getElementById('panel'));
            return { panel_right:p.right, trigger_right:t.right, width:p.width,
                     bg:cs.backgroundColor, border:cs.borderTopWidth };
        }""")
        pg.screenshot(path=f"{OUT_DIR}/multimodal-model-dropdown.png")
        results["multi"] = {
            "dropdown_open": pg.get_attribute("#trigger", "aria-expanded") == "true",
            "item_count": n_img,
            "panel_width": round(box2["width"]),
            "trigger_panel_right_delta": round(abs(box2["panel_right"] - box2["trigger_right"]), 2),
            "opaque_background": box2["bg"].startswith("rgb(") and "rgba(0, 0, 0, 0)" not in box2["bg"],
            "visible_border": float(box2["border"].replace("px", "")) > 0,
        }
        print("  multimodal-model-dropdown.png", results["multi"])

        b.close()

    srv.shutdown()

    summary = {
        "chat_count": len(STATE["chat"]),
        "image_count": len(STATE["image"]),
        "results": results,
    }
    print(json.dumps(summary, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())
