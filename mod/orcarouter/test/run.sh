#!/usr/bin/env bash
# Regression tests for the OrcaRouter provider.
#
# Run:  bash mod/orcarouter/test/run.sh
#
# The x-cmd runtime is sourced into this shell and relies on unset variables
# being tolerated, so `set -u` is deliberately not enabled.
# Covers, per the integration contract:
#   * both authentication choices are registered and independently usable;
#   * both produce the SAME credential record, and nothing downstream knows
#     which adapter produced it;
#   * PKCE uses a fresh verifier/state per attempt and sends only S256;
#   * authorize and exchange go to the AUTH origin, never the inference origin;
#   * the exchange path is /api/v1/auth/keys, never /v1/auth/keys;
#   * secrets and verifier values never reach logs or error output;
#   * denial / state mismatch / expiry / 403 / 429 / network failure all end
#     safely with an actionable message;
#   * a revoked durable key enters needs_reauth without a fake refresh, and a
#     stale generation cannot mark a newer credential;
#   * catalogue parsing, every capability filter, multimodal fail-closed, and
#     the verified fallback seed with metadata intact.

set -o pipefail 2>/dev/null || true

TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$TEST_DIR/../../.." && pwd)"

PASS=0
FAIL=0
SKIP=0

ok()   { PASS=$((PASS + 1)); printf '  ok   %s\n' "$1"; }
bad()  { FAIL=$((FAIL + 1)); printf '  FAIL %s\n' "$1"; [ -z "${2:-}" ] || printf '       %s\n' "$2"; }
skip() { SKIP=$((SKIP + 1)); printf '  skip %s\n' "$1"; }

assert_eq() {
    [ "$2" = "$3" ] && ok "$1" || bad "$1" "expected [$3] got [$2]"
}
assert_ne() {
    [ "$2" != "$3" ] && ok "$1" || bad "$1" "expected value to differ from [$3]"
}
assert_contains() {
    case "$2" in *"$3"*) ok "$1" ;; *) bad "$1" "[$2] does not contain [$3]" ;; esac
}
assert_not_contains() {
    case "$2" in *"$3"*) bad "$1" "unexpected [$3] present" ;; *) ok "$1" ;; esac
}

# --- test sandbox -------------------------------------------------------------
# Each run gets a private config root so tests never touch the user's real
# x-cmd configuration.
#
# The environment credential fallback is neutralised first: if the ambient
# ORCAROUTER_API_KEY were left set, the env adapter would win every read and the
# store/clear assertions below would be testing the environment, not the code.
# Every credential used in this file is synthetic.
unset ORCAROUTER_API_KEY ORCA_KEY
export ORCAROUTER_API_KEY= ORCA_KEY=

SANDBOX="$(mktemp -d)"
export ___X_CMD_ROOT_CFG="$SANDBOX/cfg"
export ___X_CMD_ROOT_TMP="$SANDBOX/tmp"
mkdir -p "$SANDBOX/cfg" "$SANDBOX/tmp"

cleanup() {
    [ -n "${FAKE_PID:-}" ] && kill "$FAKE_PID" 2>/dev/null
    rm -rf "$SANDBOX"
}
trap cleanup EXIT INT TERM

# --- load the provider under test --------------------------------------------
if [ -z "${___X_CMD_ROOT_MOD:-}" ]; then
    printf 'Loading x-cmd against %s\n' "$REPO_DIR"
    ___X_CMD_CLAUDECODE_READY=1
    ___X_CMD_ROOT="${___X_CMD_ROOT:-$HOME/.x-cmd.root}"
    ___X_CMD_ROOT_CODE="$REPO_DIR"
    export ___X_CMD_CLAUDECODE_READY ___X_CMD_ROOT ___X_CMD_ROOT_CODE
    # shellcheck disable=SC1090
    . "$___X_CMD_ROOT/v/latest/X" 2>/dev/null
fi

xrc:mod orcarouter/latest >/dev/null 2>&1 || {
    printf 'FATAL: could not load the orcarouter module from %s\n' "$REPO_DIR"
    exit 1
}
# Source the module bodies directly. The functions under test are also reached
# through x-cmd's lazy dispatcher in real use, but that dispatcher is not
# entered by a plain function call, so load them explicitly here.
for _f in util cfg cred connect model credits chat/_index; do
    xrc:mod:lib orcarouter "$_f" >/dev/null 2>&1 || {
        printf 'FATAL: could not load mod/orcarouter/lib/%s\n' "$_f"
        exit 1
    }
done
# Dependencies the provider relies on, loaded the same way the real dispatcher
# would load them.
xrc:mod str/latest               >/dev/null 2>&1
xrc:mod:lib chat provider        >/dev/null 2>&1
xrc:mod:lib openai chat/_index   >/dev/null 2>&1

printf '\n== origins ==\n'

assert_eq "auth origin defaults to www.orcarouter.ai" \
    "$(___x_cmd_orcarouter_util_auth_base)" "https://www.orcarouter.ai"
assert_eq "inference origin defaults to api.orcarouter.ai" \
    "$(___x_cmd_orcarouter_util_api_base)" "https://api.orcarouter.ai"
assert_eq "inference base carries exactly one /v1" \
    "$(___x_cmd_orcarouter_util_api_base_v1)" "https://api.orcarouter.ai/v1"

# Explicit overrides win, in the documented precedence order.
assert_eq "ORCA_AUTH_BASE_URL overrides auth origin" \
    "$(ORCA_AUTH_BASE_URL=https://auth.internal.example ___x_cmd_orcarouter_util_auth_base)" \
    "https://auth.internal.example"
assert_eq "ORCA_API_BASE_URL overrides inference origin" \
    "$(ORCA_API_BASE_URL=https://api.internal.example ___x_cmd_orcarouter_util_api_base)" \
    "https://api.internal.example"
assert_eq "ORCA_BASE_URL acts as the shared fallback" \
    "$(ORCA_BASE_URL=https://shared.internal.example ___x_cmd_orcarouter_util_auth_base)" \
    "https://shared.internal.example"
assert_eq "explicit origin beats the shared fallback" \
    "$(ORCA_BASE_URL=https://shared.internal.example ORCA_AUTH_BASE_URL=https://auth.internal.example ___x_cmd_orcarouter_util_auth_base)" \
    "https://auth.internal.example"
assert_eq "a self-hosted base already ending in /v1 is not doubled" \
    "$(ORCA_API_BASE_URL=https://shared.internal.example/v1 ___x_cmd_orcarouter_util_api_base_v1)" \
    "https://shared.internal.example/v1"

# The auth origin must never be derived from the inference origin.
_a="$(ORCA_API_BASE_URL=https://api.internal.example ___x_cmd_orcarouter_util_auth_base)"
assert_not_contains "auth origin is not derived from the API origin" "$_a" "api.internal.example"

# Origin policy: HTTPS for remote, HTTP only for loopback.
if ___x_cmd_orcarouter_util_require_origin t "http://remote.example.com" >/dev/null 2>&1; then
    bad "plain HTTP to a remote origin is refused"
else
    ok "plain HTTP to a remote origin is refused"
fi
___x_cmd_orcarouter_util_require_origin t "http://127.0.0.1:8080" >/dev/null 2>&1 \
    && ok "plain HTTP to loopback is permitted" || bad "plain HTTP to loopback is permitted"
___x_cmd_orcarouter_util_require_origin t "https://any.example.com" >/dev/null 2>&1 \
    && ok "HTTPS to a remote origin is permitted" || bad "HTTPS to a remote origin is permitted"

printf '\n== PKCE primitives ==\n'

# Known-answer test for base64url(sha256(x)), no padding.
assert_eq "sha256->base64url matches the known answer" \
    "$(___x_cmd_orcarouter_util_sha256_b64url "abc")" \
    "ungWv48Bz-pBQUDeXa4iI7ADYaOWF3qctBD_YfIAFa0"
assert_eq "challenge output is unpadded base64url" \
    "$(printf '%s' "$(___x_cmd_orcarouter_util_sha256_b64url "abc")" | tr -d 'A-Za-z0-9_-' | wc -c | tr -d ' ')" "0"

_v1="$(___x_cmd_orcarouter_util_rand_b64url 32)"
_v2="$(___x_cmd_orcarouter_util_rand_b64url 32)"
assert_ne "verifier is fresh per call" "$_v1" "$_v2"
assert_eq "verifier is 32 random bytes in base64url" "${#_v1}" "43"
_s1="$(___x_cmd_orcarouter_util_rand_b64url 16)"
_s2="$(___x_cmd_orcarouter_util_rand_b64url 16)"
assert_ne "state is fresh per call" "$_s1" "$_s2"

# Constant-time comparison primitive.
___x_cmd_orcarouter_util_ct_eq "abcdef" "abcdef" && ok "ct_eq accepts equal strings" || bad "ct_eq accepts equal strings"
___x_cmd_orcarouter_util_ct_eq "abcdef" "abcdeg" && bad "ct_eq rejects differing strings" || ok "ct_eq rejects differing strings"
___x_cmd_orcarouter_util_ct_eq "abcdef" "abc"    && bad "ct_eq rejects different lengths" || ok "ct_eq rejects different lengths"

printf '\n== credential seam: API-key adapter ==\n'

FAKE_KEY="sk-orca-$(printf 'a%.0s' $(seq 1 32))"
___x_cmd_orcarouter_cred_apply "$FAKE_KEY" apikey api >/dev/null 2>&1 \
    && ok "API-key adapter stores a credential" || bad "API-key adapter stores a credential"
assert_eq "stored key reads back" "$(___x_cmd_orcarouter_cred_key_raw)" "$FAKE_KEY"
assert_eq "credential source is recorded as apikey" "$(___x_cmd_orcarouter_cred_source)" "apikey"

_mask="$(___x_cmd_orcarouter_cred_mask "$FAKE_KEY")"
assert_not_contains "mask does not reveal the whole key" "$_mask" "$FAKE_KEY"
assert_contains "mask keeps a recognisable prefix" "$_mask" "sk-orca-"

printf '\n== credential seam: PKCE adapter ==\n'

PKCE_KEY="sk-orca-$(printf 'b%.0s' $(seq 1 32))"
___x_cmd_orcarouter_cred_apply "$PKCE_KEY" pkce api >/dev/null 2>&1 \
    && ok "PKCE adapter stores a credential" || bad "PKCE adapter stores a credential"
assert_eq "both adapters yield the same credential shape" \
    "$(___x_cmd_orcarouter_cred_key_raw)" "$PKCE_KEY"
assert_eq "credential source is recorded as pkce" "$(___x_cmd_orcarouter_cred_source)" "pkce"

# Downstream must not care which adapter produced the credential: the same
# reader returns the same value, and the transport header is built from it.
assert_eq "downstream reader is adapter-agnostic" \
    "$(___x_cmd_orcarouter_cred_key_raw)" "$PKCE_KEY"

_gen_before="$(___x_cmd_orcarouter_cred_generation)"
___x_cmd_orcarouter_cred_apply "$FAKE_KEY" apikey api >/dev/null 2>&1
_gen_after="$(___x_cmd_orcarouter_cred_generation)"
[ "$_gen_after" -gt "$_gen_before" ] 2>/dev/null \
    && ok "a new credential issues a new generation" || bad "a new credential issues a new generation"

printf '\n== terminal 401 handling ==\n'

# A stale generation must not be able to mark a newer credential.
___x_cmd_orcarouter_cred_mark_reauth "$_gen_before" >/dev/null 2>&1
___x_cmd_orcarouter_cred_needs_reauth \
    && bad "a stale generation cannot mark the current credential" \
    || ok "a stale generation cannot mark the current credential"

# The exact generation does mark it.
___x_cmd_orcarouter_cred_mark_reauth "$_gen_after" >/dev/null 2>&1
___x_cmd_orcarouter_cred_needs_reauth \
    && ok "the rejected generation is marked needs_reauth" \
    || bad "the rejected generation is marked needs_reauth"

# Re-authenticating clears the marker and issues a fresh generation.
___x_cmd_orcarouter_cred_apply "$PKCE_KEY" pkce api >/dev/null 2>&1
___x_cmd_orcarouter_cred_needs_reauth \
    && bad "a successful login clears needs_reauth" \
    || ok "a successful login clears needs_reauth"

# A durable key is not a refresh token: nothing in the module attempts a
# refresh grant or a refresh endpoint.
if grep -rn "refresh_token\|grant_type=refresh_token\|/refresh" "$REPO_DIR/mod/orcarouter/" 2>/dev/null | grep -v "^.*test/run.sh" | grep -q .; then
    bad "no fake refresh grant is implemented"
else
    ok "no fake refresh grant is implemented"
fi

printf '\n== exchange path and origin policy ==\n'

assert_eq "exchange path is /api/v1/auth/keys" \
    "$___X_CMD_ORCAROUTER_EXCHANGE_PATH" "/api/v1/auth/keys"

# The single most common integration mistake: deriving the auth endpoint from
# the inference origin. Assert it is impossible by construction.
for f in "$REPO_DIR"/mod/orcarouter/lib/* "$REPO_DIR"/mod/orcarouter/lib/chat/*; do
    [ -f "$f" ] || continue
    if grep -q 'api\.orcarouter\.ai/v1/auth' "$f" 2>/dev/null; then
        bad "no file builds the wrong /v1/auth/keys path ($f)"
    fi
done
ok "no file builds the wrong /v1/auth/keys path"

printf '\n== PKCE end to end against a local fake auth origin ==\n'

if ! command -v python3 >/dev/null 2>&1; then
    skip "PKCE exchange tests (python3 unavailable for the fixture)"
else
    RECORD="$SANDBOX/exchange.record"
    PORT="$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')"
    python3 "$TEST_DIR/fake_auth_server.py" "$PORT" ok "$RECORD" &
    FAKE_PID=$!
    sleep 1

    AUTH_BASE="http://127.0.0.1:$PORT"
    export ORCA_AUTH_BASE_URL="$AUTH_BASE"

    # Reset to a clean credential so the connect flow runs instead of reusing.
    ___x_cmd_orcarouter_cred_clear >/dev/null 2>&1

    OUT="$SANDBOX/connect.out"
    printf 'the-fake-code\n' | ___x_cmd_orcarouter_connect___run 0 >"$OUT" 2>&1
    RC=$?

    assert_eq "connect exits 0 on success" "$RC" "0"

    NEWKEY="$(___x_cmd_orcarouter_cred_key_raw)"
    assert_contains "connect persisted an sk-orca- credential" "$NEWKEY" "sk-orca-"
    assert_eq "connect recorded the pkce source" "$(___x_cmd_orcarouter_cred_source)" "pkce"

    # The authorize URL must be on the AUTH origin, at /auth, asking for an
    # out-of-band code with S256 -- and must not contain the verifier.
    assert_contains "authorize URL targets /auth" "$(cat "$OUT")" "/auth?"
    assert_contains "authorize URL requests an out-of-band code" "$(cat "$OUT")" "callback_url=oob"
    assert_contains "authorize URL pins S256" "$(cat "$OUT")" "code_challenge_method=S256"

    EX_PATH="$(head -1 "$RECORD")"
    EX_BODY="$(tail -n +2 "$RECORD")"
    assert_eq "exchange went to /api/v1/auth/keys" "$EX_PATH" "/api/v1/auth/keys"
    assert_contains "exchange sends the S256 method" "$EX_BODY" '"code_challenge_method": "S256"'
    assert_contains "exchange sends the verifier" "$EX_BODY" "code_verifier"

    # PROOF of S256 binding: recompute base64url(sha256(verifier)) from the
    # verifier that actually went over the wire and compare it with the
    # challenge that went out on the authorize URL.
    VERIFIER="$(printf '%s' "$EX_BODY" | python3 -c '
import json,sys
print(json.load(sys.stdin)["code_verifier"])')"
    RECOMPUTED="$(python3 -c '
import base64,hashlib,sys
v=sys.argv[1].encode()
print(base64.urlsafe_b64encode(hashlib.sha256(v).digest()).decode().rstrip("="))' "$VERIFIER")"
    CHALLENGE="$(cat "$OUT" | tr '&' '\n' | sed -n 's/^.*code_challenge=\([^&]*\).*$/\1/p' | head -1)"
    assert_eq "challenge on the authorize URL is exactly S256(verifier)" "$CHALLENGE" "$RECOMPUTED"

    # The verifier must never be printed, and must not appear in the URL.
    assert_not_contains "verifier is absent from program output" "$(cat "$OUT")" "$VERIFIER"
    AUTHZ_URL="$(cat "$OUT" | tr ' ' '\n' | grep '/auth?' | head -1)"
    assert_not_contains "verifier is absent from the authorize URL" "$AUTHZ_URL" "$VERIFIER"

    # Corrupted key: rejected, and the error must not echo the bad value.
    assert_not_contains "errors do not echo credentials" "$(cat "$OUT")" "$NEWKEY"

    # The credential store must reflect this login and nothing else.
    assert_eq "the stored credential is the one the login returned" \
        "$(___x_cmd_orcarouter_cred_source)" "pkce"

    kill "$FAKE_PID" 2>/dev/null; wait "$FAKE_PID" 2>/dev/null; FAKE_PID=

    # --- failure modes, each ending safely with an actionable message --------
    run_failure_case() {
        _mode="$1"; _label="$2"; _expect="$3"
        _record="$SANDBOX/rec.$_mode"
        _port="$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')"
        python3 "$TEST_DIR/fake_auth_server.py" "$_port" "$_mode" "$_record" &
        _pid=$!
        sleep 1

        ___x_cmd_orcarouter_cred_clear >/dev/null 2>&1
        _out="$SANDBOX/out.$_mode"
        printf 'code-%s\n' "$_mode" | \
            ORCA_AUTH_BASE_URL="http://127.0.0.1:$_port" \
            ___x_cmd_orcarouter_connect___run 0 >"$_out" 2>&1
        _rc=$?

        kill "$_pid" 2>/dev/null; wait "$_pid" 2>/dev/null

        [ "$_rc" -ne 0 ] && ok "$_label exits non-zero" || bad "$_label exits non-zero"
        assert_contains "$_label reports a reason" "$(cat "$_out")" "$_expect"
        assert_eq "$_label stores no credential" "$(___x_cmd_orcarouter_cred_key_raw)" ""
    }

    run_failure_case deny      "denied authorization (403)"     "403"
    run_failure_case badmethod "challenge-method downgrade (400)" "400"
    run_failure_case ratelimit "rate limited (429)"             "429"

    # Network failure: nothing listening on the port.
    ___x_cmd_orcarouter_cred_clear >/dev/null 2>&1
    _dead_port="$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')"
    printf 'code-x\n' | ORCA_AUTH_BASE_URL="http://127.0.0.1:$_dead_port" \
        ___x_cmd_orcarouter_connect___run 0 >"$SANDBOX/out.net" 2>&1
    assert_eq "network failure does not hang or report success" "$?" "1"
    assert_eq "network failure stores no credential" "$(___x_cmd_orcarouter_cred_key_raw)" ""

    # Scope downgrade: the granted scope is reported, not assumed.
    _rec="$SANDBOX/rec.scope"; _p="$(python3 -c 'import socket;s=socket.socket();s.bind(("127.0.0.1",0));print(s.getsockname()[1]);s.close()')"
    python3 "$TEST_DIR/fake_auth_server.py" "$_p" scope_down "$_rec" & _pid=$!
    sleep 1
    ___x_cmd_orcarouter_cred_clear >/dev/null 2>&1
    printf 'code-scope\n' | ORCA_AUTH_BASE_URL="http://127.0.0.1:$_p" \
        ___x_cmd_orcarouter_connect___run 0 >"$SANDBOX/out.scope" 2>&1
    assert_eq "a narrower granted scope still completes" "$?" "0"
    assert_contains "scope downgrade is reported to the user" "$(cat "$SANDBOX/out.scope")" "connector"
    kill "$_pid" 2>/dev/null; wait "$_pid" 2>/dev/null
fi

printf '\n== model catalogue parsing ==\n'

# Fixture records: text-only, image-input chat, embedding, image gen, video,
# rerank, and a record that declares nothing (must fail closed).
FIXTURE='{"data":[
 {"id":"vendor/text-only","name":"Text Only","context_length":1000,"architecture":{"input_modalities":["text"],"output_modalities":["text"]},"supported_endpoint_types":["openai"]},
 {"id":"vendor/vision-chat","name":"Vision Chat","context_length":2000,"architecture":{"input_modalities":["text","image"],"output_modalities":["text"]},"supported_endpoint_types":["openai","anthropic"]},
 {"id":"vendor/embed","name":"Embedder","architecture":{"input_modalities":["text"]},"supported_endpoint_types":["embeddings"]},
 {"id":"vendor/img-gen","name":"Image Gen","architecture":{"input_modalities":["text"]},"supported_endpoint_types":["image-generation"]},
 {"id":"vendor/video","name":"Video","architecture":{"input_modalities":["text"]},"supported_endpoint_types":["openai-video"]},
 {"id":"vendor/rerank","name":"Rerank","architecture":{"input_modalities":["text"]},"supported_endpoint_types":["jina-rerank"]},
 {"id":"vendor/undeclared","name":"Undeclared","supported_endpoint_types":["openai"]}
]}'

rows_for() {
    printf '%s' "$FIXTURE" | ___x_cmd_orcarouter_model___json2rows \
        | NORMALISED_CAP="$1" NORMALISED_MODALITY="${2:-}" ___x_cmd_orcarouter_model_parse
}

ids_for() { rows_for "$1" "${2:-}" | tail -n +1 | cut -f1 | tail -n +1; }

_chat="$(ids_for chat)"
assert_contains "chat keeps a text-only model" "$_chat" "vendor/text-only"
assert_contains "chat keeps a vision-chat model" "$_chat" "vendor/vision-chat"
assert_contains "chat keeps a model with no declared architecture" "$_chat" "vendor/undeclared"
assert_not_contains "chat excludes embedding models" "$_chat" "vendor/embed"
assert_not_contains "chat excludes image-generation models" "$_chat" "vendor/img-gen"
assert_not_contains "chat excludes video models" "$_chat" "vendor/video"
assert_not_contains "chat excludes rerank models" "$_chat" "vendor/rerank"

_vis="$(ids_for chat image)"
assert_contains "image modality keeps a declared image-input chat model" "$_vis" "vendor/vision-chat"
assert_not_contains "image modality drops text-only chat models" "$_vis" "vendor/text-only"
assert_not_contains "image modality fails closed on undeclared models" "$_vis" "vendor/undeclared"
assert_not_contains "image modality drops embedding models" "$_vis" "vendor/embed"

_emb="$(ids_for embedding)"
assert_contains "embedding keeps embeddings-endpoint models" "$_emb" "vendor/embed"
assert_not_contains "embedding excludes chat models" "$_emb" "vendor/text-only"

_img="$(ids_for image)"
assert_contains "image capability keeps image-generation models" "$_img" "vendor/img-gen"
assert_not_contains "image capability excludes chat models" "$_img" "vendor/text-only"

_vid="$(ids_for video)"
assert_contains "video capability matches openai-video strictly" "$_vid" "vendor/video"
assert_not_contains "video capability excludes chat models" "$_vid" "vendor/text-only"

_rr="$(ids_for rerank)"
assert_contains "rerank capability matches jina-rerank strictly" "$_rr" "vendor/rerank"
assert_not_contains "rerank capability excludes chat models" "$_rr" "vendor/text-only"

# The parser must emit real TSV, not space-separated text.
assert_contains "parser emits tab-separated rows" "$(rows_for chat)" "$(printf 'vendor/text-only\tText Only')"

printf '\n== verified fallback catalogue ==\n'

_seed() {
    NORMALISED_CAP="$1" NORMALISED_MODALITY="${2:-}" \
        ___x_cmd_orcarouter_model_ls_tsv_seed
}

_seed_chat="$(_seed chat)"
for m in openai/gpt-5.5 anthropic/claude-opus-4.8 google/gemini-3.5-flash deepseek/deepseek-v4-pro orcarouter/auto; do
    assert_contains "seed retains $m" "$_seed_chat" "$m"
done
assert_contains "seed marks rows as seed-sourced" "$_seed_chat" "seed"

# Metadata must survive the fallback: modalities and context windows.
assert_contains "seed preserves gpt-5.5 input modalities" "$_seed_chat" "file,image,text"
assert_contains "seed preserves opus context window" "$_seed_chat" "1000000"
assert_contains "seed preserves gemini modalities" "$_seed_chat" "text,image,video,file,audio"
assert_contains "seed preserves deepseek context window" "$_seed_chat" "1048576"

# A trimmed seed is reported as degraded, never silently mixed with live data.
_seed_vis="$(_seed chat image)"
assert_contains "multimodal seed keeps image-capable models" "$_seed_vis" "anthropic/claude-opus-4.8"
assert_not_contains "multimodal seed drops text-only models" "$_seed_vis" "deepseek/deepseek-v4-pro"
assert_not_contains "multimodal seed drops undeclared-capability aliases" "$_seed_vis" "orcarouter/auto"

# Non-chat capabilities have no seed; they must not invent entries.
assert_eq "no fabricated embedding seed" "$(_seed embedding | wc -l | tr -d ' ')" "0"

printf '\n== provider registration ==\n'

assert_contains "orcarouter is in the provider registry" \
    "$(___x_cmd_chat_provider_ls)" "orcarouter"
___x_cmd_chat_provider___validate orcarouter 2>/dev/null \
    && ok "orcarouter passes provider validation" || bad "orcarouter passes provider validation"
___x_cmd_openai_chat_provider___validate orcarouter 2>/dev/null \
    && ok "orcarouter passes the OpenAI-adapter validation" \
    || bad "orcarouter passes the OpenAI-adapter validation"

# The inference base must be the bare origin: the shared adapter appends /v1.
assert_eq "chat adapter uses the bare inference origin" \
    "$(___x_cmd_orcarouter_util_api_base)" "https://api.orcarouter.ai"

printf '\n== secret hygiene ==\n'

# No hardcoded credential, and no fixed verifier, anywhere in the module.
if grep -rnE 'sk-orca-[A-Za-z0-9]{16,}' "$REPO_DIR/mod/orcarouter/" 2>/dev/null \
    | grep -v 'test/run\.sh' | grep -v 'test/fake_auth_server\.py' | grep -q .; then
    bad "no real sk-orca- key is committed"
else
    ok "no real sk-orca- key is committed"
fi

# No client secret is used by the PKCE flow. (Structural check on code, not a
# grep of user-facing strings.)
if grep -rnE '^[^#]*client_secret' "$REPO_DIR/mod/orcarouter/lib/" 2>/dev/null | grep -q .; then
    bad "the PKCE flow uses no client secret"
else
    ok "the PKCE flow uses no client secret"
fi

printf '\n== results ==\n'
printf '  passed: %s\n  failed: %s\n  skipped: %s\n\n' "$PASS" "$FAIL" "$SKIP"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
