# docs/planning -- design plans and ratification records

These are **dated design records**, written before the work they describe. They are kept as
written so the reasoning stays on file; they are not kept up to date.

- **A status line near the top may lag.** A plan whose work shipped can still say "DRAFT",
  "PLAN (not implemented)", "Pre-RED" or "ready for RED". Where a later session checked, a
  `Status banner` (a blockquote right after the title) says what shipped, with commit hashes and
  the issue's close date. The banner wins over any older status line below it.
- **`CHANGELOG.md` is the authority** for what was done and when (older entries are in
  `docs/archive/CHANGELOG-through-*.md`), and `BACKLOG.md` for what is still open.
- **Bodies are not rewritten.** Line numbers, counts, signatures and file names inside a plan
  describe the code as it was then. Check the code before relying on them.
- A plan with no banner has not been swept; do not read that as "current".

The S860 audit (`docs/audits/DOCS_STALENESS_AUDIT_SLICE7C_2026-10-02.md`) lists the sweep.
