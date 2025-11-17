---
title: "My First Bug Bounty: Authentication Bypass"
summary: "How I discovered an authentication bypass vulnerability that led to unauthorized access to user accounts."
date: "2024-11-10"
tags: ["bug-bounty", "web-security", "authentication"]
draft: false
---

## The Discovery

While testing a web application, I noticed something interesting in how the authentication flow worked...

## The Vulnerability

The application used JWT tokens for authentication, but there was a critical flaw in how they validated the signature.

### Initial Recon

```bash
# Testing the login endpoint
curl -X POST https://target.com/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test123"}'
```

### The Exploit

I found that by manipulating the JWT token's algorithm field from `RS256` to `none`, I could bypass signature verification entirely.

## Impact

This vulnerability allowed:
- Unauthorized access to any user account
- Privilege escalation to admin roles
- Complete account takeover

## Timeline

- **Day 1**: Discovered the vulnerability
- **Day 2**: Reported to the security team
- **Day 7**: Fix deployed
- **Day 14**: Bounty awarded 💰

## Lessons Learned

Always validate JWT signatures properly and never trust client-side algorithm selection!

---

*Note: Details have been modified to protect the affected organization.*
