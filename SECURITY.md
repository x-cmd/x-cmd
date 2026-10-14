# Security Policy

## Supported Versions

The x-cmd project provides security updates for the following release lines:

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |
| older   | :x:                |

We ship x-cmd as a single rolling `X` branch — the latest commit on `X` is the supported version. We do not maintain backports to older commits; please stay on `X`.

## Reporting a Vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**

Report privately via one of these channels (in order of preference):

1. **GitHub private vulnerability reporting** — use the "Report a vulnerability" button on the x-cmd/x-cmd Security tab. This creates a private advisory visible only to maintainers.
2. **Email** — send to `security@x-cmd.com` (PGP key available on request).
3. **Direct message** — reach out to a maintainer on the official channels listed on https://x-cmd.com.

### What to include

To help us triage quickly, please include:

- Description of the vulnerability and its impact (what an attacker can do)
- Affected component / module (e.g. `mod/foo`, `adv/foo`, a specific `x <module>` subcommand)
- Reproduction steps or a minimal proof-of-concept
- Affected version (commit SHA on `X`, or release tag)
- Your contact info and whether you want public credit

### What to expect

- **Acknowledgement** within 3 business days.
- **Triage & impact assessment** within 7 business days. We'll either confirm and start working, or ask for more info.
- **Fix timeline** depends on severity:
  - Critical (RCE, credential leak, sandbox escape): patch within 14 days
  - High (privilege escalation, command injection in default config): patch within 30 days
  - Medium / Low: addressed in the next regular release cycle
- **Coordinated disclosure**: we'll work with you on a disclosure date. Default embargo is 90 days from report, or until a fix ships — whichever comes first.
- **Credit**: we'll add you to the advisory credits unless you prefer anonymity.

## Scope

In scope:

- Code under `mod/`, `adv/`, `script/`, `lib/` shipped in this repo
- Shell functions and modules distributed via `x pkg install ...` that originate from x-cmd authors
- Build / packaging issues that affect shipped artifacts

Out of scope:

- Issues in third-party modules that x-cmd wraps but does not own (please report upstream — these are bundled as-is)
- Issues requiring an attacker to already control the user's account or shell environment
- Social-engineering attacks

## Security Best Practices for x-cmd Users

- Always pin to a specific commit SHA or release tag when scripting against x-cmd
- Review `x pkg` install scripts before running in production
- Avoid pasting untrusted shell snippets directly into your terminal — x-cmd itself does not protect against arbitrary shell execution
- Keep your shell environment (bash/zsh) updated independently

## Acknowledgements

We thank the security community for responsible disclosure. A list of reporters who have helped improve x-cmd will be added to release notes as advisories ship.