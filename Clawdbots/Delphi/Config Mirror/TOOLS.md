# TOOLS.md - Delphi Local Notes

## Oracle Pool
- Project: `/data/projects/oracle-pool/`
- Spec: `/data/projects/oracle-pool/SPEC.md`
- Runtime data: `~/.oracle-pool/`
- Config: `~/.oracle-pool/config.yaml`
- Database: `~/.oracle-pool/pool.db`
- Job outputs: `~/.oracle-pool/jobs/<job-id>/`

## Oracle CLI
- Binary: `oracle`
- Sessions: `~/.oracle/sessions/`
- Browser profile: `~/.oracle/browser-profile/`

## Key Commands (once oracle-pool is built)
```bash
oracle-pool status              # Pool health
oracle-pool submit -p "..." --file "..." --model gpt-5.2-pro
oracle-pool list                # All jobs
oracle-pool result <id>         # Get output
oracle-pool refresh-auth        # Re-login when cookies expire
```

---

*Updated: 2026-01-31*

## Web Navigation (agent-browser)

This workspace can use the **agent-browser** CLI for real browser automation on the VPS (click/scroll/type/screenshot).

Quick start:
```bash
agent-browser open <url>
agent-browser snapshot -i      # get interactive elements with refs
agent-browser click @e1
agent-browser fill @e2 "text"
agent-browser scroll down 800
agent-browser screenshot page.png
agent-browser close
```

Note: Some sites may still present CAPTCHAs/2FA.
