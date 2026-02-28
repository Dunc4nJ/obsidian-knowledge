---
created: 2026-02-23
description: Instagram allows automated headless login with 2FA, Facebook blocks all automated logins via anti-bot redirect loops, and TikTok rate-limits aggressively after just 2-3 failed attempts — but daily engagement works fine headless once authenticated.
source: internal testing (BananaBanker session 2026-02-23)
type: learning
---

# Social media platform login automation varies dramatically by platform

When building browser automation for social media engagement across brands, the login (authentication) step behaves completely differently from the daily usage step:

**Instagram** allows automated headless login. Fill email + password via CDP, handle 2FA code from email within ~5 minutes, and the session persists in Chrome's `user-data-dir`. Straightforward.

**Facebook** blocks all automated/headless logins. Every attempt hits an `auth_platform/afad` redirect loop that never completes — even when using realistic user-agents, headed mode with Xvfb, or alternative login flows (mobile site, SSO via Instagram). The only reliable path is manual login through a VNC session (noVNC over SSH tunnel to the VPS's virtual display).

**TikTok** has the most aggressive rate limiting. Just 2-3 failed login attempts (automated or manual) trigger "Maximum number of attempts reached" for hours. Never attempt automated login; always do the first attempt manually via VNC.

The key insight: **login is rare (every 30-90 days when cookies expire) but daily engagement works fine in headless mode** once authenticated. Session cookies persist in the Chrome `user-data-dir` across headless restarts. So the architecture is: manual auth via VNC (rare) → headless daily engagement (automated).

This maps to a systemd service pattern: each brand gets a dedicated Chrome instance with `--headless=new` for daily use. For re-auth, stop the service → launch headed Chrome on Xvfb → VNC in → login → restart headless service.
