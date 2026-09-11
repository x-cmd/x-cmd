#!/usr/bin/env python3
"""Local fake OrcaRouter authentication origin, for the PKCE regression tests.

This stands in for https://www.orcarouter.ai/api/v1/auth/keys so the real
connect adapter can be exercised end to end (authorize URL -> code ->
exchange -> persist) without a human approving a real consent screen.

It is a test fixture only. It never touches the real service and it only ever
sees the synthetic verifier the test generates.

Usage:  fake_auth_server.py <port> <mode> <record-file>

  mode = ok         200 {"key": "...", "user_id": "...", "scope": "api"}
       = scope_down 200 with scope "connector" (narrower than requested)
       = deny       403 (code rejected: unknown / expired / already used)
       = badmethod  400 (code_challenge_method unrecognised / downgraded)
       = ratelimit  429 (too many PKCE keys issued recently)
       = corrupt    200 with a malformed key field
       = noread     200 with no key field at all

The record file receives the raw request body so the test can prove which
verifier actually went over the wire.
"""

import hashlib
import json
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(sys.argv[1])
MODE = sys.argv[2]
RECORD = sys.argv[3]

MODE_STATUS = {
    "ok": 200,
    "scope_down": 200,
    "corrupt": 200,
    "noread": 200,
    "deny": 403,
    "badmethod": 400,
    "ratelimit": 429,
}


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass  # keep the test output clean

    def do_POST(self):
        length = int(self.headers.get("Content-Length") or 0)
        raw = self.rfile.read(length).decode("utf-8", "replace")

        # Record exactly what the adapter sent. The verifier legitimately
        # appears here -- this is the exchange request body, its only
        # permitted destination.
        with open(RECORD, "w", encoding="utf-8") as fh:
            fh.write(self.path + "\n" + raw)

        status = MODE_STATUS.get(MODE, 200)

        if status == 200:
            if MODE == "corrupt":
                body = {"key": "not-a-valid-key", "user_id": "1", "scope": "api"}
            elif MODE == "noread":
                body = {"user_id": "1", "scope": "api"}
            elif MODE == "scope_down":
                body = {"key": "sk-orca-" + "t" * 24, "user_id": "1", "scope": "connector"}
            else:
                body = {"key": "sk-orca-" + "t" * 24, "user_id": "1", "scope": "api"}
        elif status == 403:
            body = {"error": "invalid_grant", "error_description": "code unknown, expired or already used"}
        elif status == 400:
            body = {"error": "invalid_request", "error_description": "code_challenge_method mismatch"}
        else:
            body = {"error": "rate_limited", "error_description": "too many keys issued"}

        payload = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)


def main():
    # Sanity: the fixture must be able to reproduce the S256 transform the
    # adapter is expected to use, so a mismatch is a real failure and not a
    # fixture artefact.
    probe = hashlib.sha256(b"probe").digest()
    assert len(probe) == 32

    HTTPServer(("127.0.0.1", PORT), Handler).serve_forever()


if __name__ == "__main__":
    main()
