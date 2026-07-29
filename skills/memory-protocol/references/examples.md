# Examples — bad vs good

> Cases 1-3 and 6 are the ADMISSION axis (does this persist at all). Cases 4, 5, 7 and 8 are the
> WRITING axis (how it is written once it does). Both are defined in the Constitution.

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

## 7. Closed verdict vs reopenable state (NON-CONDITIONING)

❌ `project-no-parallel.md`: "Parallel uploads don't work with this API. Don't try."
✅ `project-upload-concurrency.md`: "Uploads above 4 concurrent returned HTTP 429 (observed N=3 runs, 2026-05-02). **How to apply:** cap at 4. **Reopens if:** the plan changes or the provider publishes a higher limit."

A memory is the text that outlives the reason it was written. "Don't try" costs every future session
the attempt; the second form costs nothing and carries the condition that makes it obsolete.

## 8. Attributed cause vs observed fact (OBJECTIVE)

❌ `feedback-bad-scraper.md`: "The scraper is badly built, that's why it fails."
✅ `project-scraper-timeout.md`: "The scraper returns empty on pages over ~2 MB; the timeout fires before the DOM settles (observed on 4 of 4 large pages). **How to apply:** raise the wait or paginate before scraping."

The first blames and closes. The second describes what happens, under what condition, and leaves the
next session somewhere to act.
