---
name: secure-code-review
description: Use after writing or modifying code to check for security vulnerabilities, insecure patterns, and common mistakes before committing
---

# Secure Code Review

## Overview

AI-generated code frequently contains security vulnerabilities. This skill forces a
structured security review before code is considered complete.

**Core principle:** Every piece of code you write or modify gets a security check before
it ships. No exceptions.

## When to Use

**Always, automatically:**
- After implementing any feature that handles user input
- After writing authentication, authorization, or session code
- After creating API endpoints or routes
- After writing database queries
- After handling file uploads, downloads, or filesystem operations
- After implementing cryptographic operations
- After modifying security-sensitive configuration
- Before any commit that touches security-relevant code

**Trigger phrases that should activate this skill:**
- "review this for security"
- "is this secure?"
- "check my code"
- "before I commit"

## The Security Checklist

Run through ALL applicable categories. Do not skip categories — check each one and
explicitly confirm "not applicable" if it does not apply.

### 1. Input Validation & Injection

```
[ ] All user input is validated/sanitized before use
[ ] SQL queries use parameterized statements (NEVER string concatenation)
[ ] NoSQL queries avoid operator injection ($gt, $ne, etc.)
[ ] Command execution never includes unsanitized user input
[ ] Template rendering uses auto-escaping (no raw/safe/unescaped output)
[ ] File paths are validated against directory traversal (../)
[ ] XML parsing disables external entities (XXE prevention)
[ ] Regular expressions are not vulnerable to ReDoS
[ ] HTTP headers from user input are sanitized
```

### 2. Authentication & Sessions

```
[ ] Passwords are hashed with bcrypt/scrypt/argon2 (NEVER MD5/SHA1/SHA256 alone)
[ ] Password comparison uses constant-time comparison
[ ] Session tokens are cryptographically random (min 128 bits entropy)
[ ] Session tokens are not exposed in URLs or logs
[ ] Failed login attempts are rate-limited
[ ] Password reset tokens expire and are single-use
[ ] Multi-factor authentication is not bypassable
[ ] JWT tokens validate signature, issuer, audience, and expiration
[ ] JWT secret keys are not hardcoded
```

### 3. Authorization & Access Control

```
[ ] Every endpoint checks authorization (not just authentication)
[ ] Authorization checks happen server-side (never trust client)
[ ] Object-level authorization prevents IDOR (user A cannot access user B's data)
[ ] Admin/privileged operations have separate authorization checks
[ ] API keys and tokens follow least-privilege principle
[ ] Role checks cannot be bypassed by modifying request parameters
[ ] Default deny: access is denied unless explicitly granted
```

### 4. Data Exposure & Secrets

```
[ ] No hardcoded secrets, API keys, passwords, or tokens in source code
[ ] Sensitive data is not logged (passwords, tokens, PII, credit cards)
[ ] Error messages do not leak internal details (stack traces, SQL, paths)
[ ] API responses do not include unnecessary fields (password hashes, internal IDs)
[ ] Sensitive data in transit uses TLS (no HTTP for sensitive operations)
[ ] Sensitive data at rest is encrypted
[ ] .env files, key files, and credentials are in .gitignore
[ ] Debug/development endpoints are disabled in production
```

### 5. Cross-Site Scripting (XSS)

```
[ ] All dynamic content in HTML is escaped by default
[ ] User input in JavaScript contexts is JSON-encoded, not string-interpolated
[ ] URLs from user input are validated (scheme whitelisting: https only)
[ ] Content-Security-Policy headers are set
[ ] innerHTML/dangerouslySetInnerHTML is avoided or input is sanitized
[ ] SVG uploads are sanitized (can contain script)
```

### 6. Cross-Site Request Forgery (CSRF)

```
[ ] State-changing operations require CSRF tokens
[ ] CSRF tokens are validated server-side
[ ] SameSite cookie attribute is set
[ ] Custom headers required for API calls (X-Requested-With)
```

### 7. Cryptography

```
[ ] Using well-known libraries (not hand-rolled crypto)
[ ] Using current algorithms (AES-256-GCM, not DES/3DES/ECB)
[ ] Random values use cryptographically secure RNG (not Math.random)
[ ] IVs/nonces are unique per encryption operation
[ ] Keys are of sufficient length (RSA >= 2048, ECC >= 256)
[ ] Certificate validation is not disabled
[ ] Hashing for integrity uses HMAC, not plain hash
```

### 8. Dependencies & Configuration

```
[ ] Dependencies are pinned to specific versions
[ ] No known vulnerable dependencies (check with npm audit / pip audit / etc.)
[ ] CORS is not set to allow all origins (*) in production
[ ] HTTP security headers are set (X-Frame-Options, X-Content-Type-Options, etc.)
[ ] Rate limiting is configured for public endpoints
[ ] File upload size limits are enforced
[ ] Timeouts are set for external HTTP calls
```

### 9. Race Conditions & State

```
[ ] Financial/inventory operations use database transactions
[ ] Check-then-act patterns use atomic operations or locks
[ ] Concurrent requests cannot double-spend or duplicate resources
[ ] Shared state modifications are thread-safe
```

## Output Format

When performing a review, produce:

### Findings

For each issue found:
```
**[SEVERITY: CRITICAL/HIGH/MEDIUM/LOW]** Category — Brief description
- File: path/to/file.ts:line
- Problem: What the vulnerability is
- Impact: What an attacker could do
- Fix: Specific code change to remediate
```

### Summary

```
Security Review Summary:
- Categories checked: X/9
- Critical findings: N
- High findings: N
- Medium findings: N
- Low findings: N
- Verdict: PASS / NEEDS FIXES
```

## Anti-Patterns to Watch For

These are common AI-generated insecure patterns:

| Pattern | Why it's dangerous |
|---------|-------------------|
| `eval()` or `exec()` with user input | Remote code execution |
| `SELECT * FROM users WHERE id = '${id}'` | SQL injection |
| `res.send(userInput)` without escaping | Reflected XSS |
| `jwt.verify(token, 'secret')` | Hardcoded JWT secret |
| `bcrypt.compare` without awaiting | Auth bypass |
| `Math.random()` for tokens | Predictable tokens |
| `cors({ origin: '*' })` | CSRF/data theft |
| `fs.readFile(userPath)` without sanitizing | Path traversal |
| `child_process.exec(userCmd)` | Command injection |
| `JSON.parse(body)` without try/catch | DoS via malformed input |
| `console.log(req.body)` | Logging sensitive data |
| Disabling SSL verification | Man-in-the-middle |
