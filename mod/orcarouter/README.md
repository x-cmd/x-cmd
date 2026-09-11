# `x orcarouter`

[OrcaRouter](https://www.orcarouter.ai) as a first-class x-cmd model provider,
with two independent ways to authenticate.

## Origins

| Purpose | Default |
| --- | --- |
| Authentication + code exchange | `https://www.orcarouter.ai` |
| Inference + model catalogue | `https://api.orcarouter.ai/v1` |

These are different hosts and are never derived from one another. The relay is
on `api.orcarouter.ai/v1`; the auth endpoints are on `www.orcarouter.ai/api/v1/auth`.
`https://api.orcarouter.ai/v1/auth/keys` is a 404.

Overrides, explicit first:

1. the module config (`endpoint`, `authbase`)
2. `ORCA_API_BASE_URL` / `ORCA_AUTH_BASE_URL`
3. `ORCA_BASE_URL` (shared, for single-origin self-hosted deployments)
4. the public defaults above

HTTPS is required for remote origins; plain HTTP is accepted only for loopback.

## Authentication

### API key

```sh
x orcarouter --cfg apikey=<sk-orca-...>
```

Or export `ORCAROUTER_API_KEY` / `ORCA_KEY`. Keys are created in the
[OrcaRouter console](https://www.orcarouter.ai/console/keys).

### Account login (OAuth 2.0 + PKCE)

```sh
x orcarouter connect
```

Opens the consent screen and accepts the code it displays (out-of-band flow),
then exchanges it for an OrcaRouter API key bound to your own account. No
client secret and no pre-registered redirect URI are involved: PKCE binds the
authorization code to this process.

The returned key is **durable, not refreshable**. It is stored in x-cmd's normal
config store and reused on every later run; nothing refreshes it and nothing
re-authorizes on launch (OrcaRouter caps PKCE-issued keys at 10 per user per
24 hours). Re-run with `--force` to mint a new one, or:

```sh
x orcarouter disconnect
```

A `401` from the relay is terminal for the credential generation that made the
request: that exact account generation is marked as needing reauthentication
and the client is told to sign in again. Revoke the app at any time from
<https://www.orcarouter.ai/console/authorized-apps>.

Both paths produce the same credential record, so `x chat`, the model catalogue,
`x claude orcarouter` and `x agent` do not care which one you used.

```sh
x orcarouter credits     # show the credential's source, generation and state
```

## Models

```sh
x orcarouter model ls              # interactive browser
x orcarouter model ls --csv        # for scripting
x orcarouter model ls --vision     # chat models that declare image input
x orcarouter model set <model-id>
```

The list is read live from `GET <inference origin>/v1/models` with your own key,
so it reflects what your workspace can actually call. Add `?capability=` to
filter by capability:

| Flag | Catalogue query | Rule applied |
| --- | --- | --- |
| *(default)* / `--chat` | `?capability=chat` | speaks `openai`/`anthropic`/`gemini`/`openai-response`, and is not an image/video/rerank-only model |
| `--vision`, `--audio`, `--file` | `?capability=chat` | the above, plus `architecture.input_modalities` must declare that modality — models that declare nothing are excluded |
| `--embedding` | `?capability=embedding` | `embeddings` endpoint |
| `--image` | `?capability=image` | `image-generation` endpoint |
| `--video` | *(strict match)* | `openai-video` endpoint |
| `--rerank` | *(strict match)* | `jina-rerank` endpoint |

Capabilities come from catalogue metadata only, never from a model's name.
Model IDs keep their `vendor/model` namespace.

If live discovery fails, a small verified fallback catalogue is shown and
explicitly labelled as degraded; it is never mixed into a successful live
result.

## Chat

```sh
x orcarouter chat request "Explain sed in one paragraph"
x chat --provider orcarouter "..."      # or: @orc "..."
x claude orcarouter                     # Claude Code against the gateway
```

## Related

- `<https://www.orcarouter.ai>` — console, API keys, authorized apps
- `<https://api.orcarouter.ai/v1>` — OpenAI-compatible relay
- Discord: <https://discord.gg/YEubt8enRA> · X: <https://x.com/OrcaRouter>
