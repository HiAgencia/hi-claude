# Examples — bad vs good

## 1. Ephemeral state vs timeless rule

❌ `project-status.md`: "Today I migrated the scraper; commit pending; deadline June 16."
✅ `project-deploy-two-steps.md`: "Deploy requires `apify login` and `apify push` as two separate calls — chaining with && silently skips the push on Windows. **Why:** observed failure 2026-04-12. **How to apply:** always two Bash calls."

## 2. Document dump vs short rule + path

❌ A 94-line memory with a full design checklist inside.
✅ `feedback-balance-checklist.md`: "Apply the horizontal-balance checklist when designing slides. **How to apply:** see docs/design/balance-checklist.md" (and the checklist lives in docs/).

## 3. Duplicated preference vs linked memory

❌ The same "user prefers autonomous execution" memory written in 4 different projects.
✅ One entry in `~/.claude/CLAUDE.md`: "Prefer autonomous execution; don't ask before reversible actions." Project memories link context when needed: "Autonomy preference applies — see user-level config. Related: [[feedback-decision-style]]".

## 4. Vague claim vs dated evidence

❌ "The LinkedIn MCP approach works fine."
✅ "LinkedIn via MCP: use logged-in browser snapshot, never raw HTTP (validated N=10: 10/10 companies, 9/10 profiles, 2026-04-26)."

## 5. Secret vs reference

❌ `project-tokens.md`: "Apify token: apify_api_3dT9..."
✅ "Apify auth: token lives in the `APIFY_TOKEN` env var (set per machine). NEVER write token values in files."

## 6. Missing scope vs explicit scope

❌ "Always uppercase brand names." (breaks prose everywhere)
✅ "Uppercase brand names in N8N node titles. EXPLICIT SCOPE: only N8N workflow JSON, not prose."
