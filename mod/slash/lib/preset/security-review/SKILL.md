---
name: security-review
description: Security audit for code changes. Triggered by "/security-review" when reviewing auth, crypto, input handling, or when user explicitly requests a security audit.
tools: Bash, Read
---

# Security Reviewer

## Trigger

Use when:
- User says `/security-review`
- Changes involve authentication, authorization, cryptography, or input handling
- User explicitly asks for a security audit

Do NOT use when:
- General code review without security focus (use `/review`)
- Performance concerns (use `/optimize`)

## Steps

### Step 1: Gather Context

```bash
git diff main..HEAD
git diff --name-only main..HEAD
```

Check dependency changes if relevant:
```bash
cat package.json  # or pyproject.toml, go.mod, etc.
```

### Step 2: Scan for Risk Patterns

| Pattern | Risk |
|---------|------|
| User input without validation | Injection |
| `eval()`, `exec()`, `shell_exec()` | Command injection |
| SQL concatenation | SQL injection |
| `innerHTML`, `dangerouslySetInnerHTML` | XSS |
| Weak crypto (MD5, SHA1 for passwords) | Cryptographic failure |
| Hardcoded secrets | Secret exposure |
| File ops with user paths | Path traversal |
| Missing rate limiting | Brute force |

### Step 3: Verify Checklist

- [ ] All user inputs validated/sanitized
- [ ] Authentication flow proper
- [ ] Authorization checks present
- [ ] No weak cryptography
- [ ] No hardcoded credentials
- [ ] Output encoded to prevent XSS
- [ ] Rate limiting on APIs
- [ ] Sensitive data not logged

### Step 4: Generate Report

Use the output format below.

## Output Format

```markdown
## Security Review

### Scope
Files: N | Lines changed: +N/-N

### Findings

#### 🔴 Critical
[Description, location, exploit scenario, fix]

#### 🟠 High
[...]

#### 🟡 Medium
[...]

#### 🟢 Info
[...]

### Summary
Total: N | Critical: N | High: N | Medium: N

## Recommendations
1. [Priority fix]
2. [Next steps]
```

## Constraints

- If no vulnerabilities found, state "No critical or high severity issues found" explicitly
- Do NOT attempt to exploit; only static analysis
- Flag for deeper audit if architecture-level security concerns found
