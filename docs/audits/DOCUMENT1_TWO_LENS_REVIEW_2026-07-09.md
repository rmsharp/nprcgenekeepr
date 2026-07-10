# Document 1 -- Two-Lens Adversarial Review (DRAFT -- INCOMPLETE)

**Target:** `vignettes/articles/engineering-the-2.0.0-release.qmd` ("Engineering
nprcgenekeepr 2.0.0"), Document 1 of the two-document plan in
`docs/planning/v2-transformation-article-plan.md` (Session 330).

**Date:** 2026-07-09 (Session 339)
**Status:** **DRAFT -- session interrupted by the owner before finalizing.** The owner
has material information to add in a future session that will affect this document.
**Do not treat this file as a finished review or act on its findings until a future
session incorporates that information and re-closes this audit.** No changes were
made to the article itself this session (report-only scope, owner-confirmed via
`AskUserQuestion`).

**Method:** Two independent forked review agents, matching the review pattern used for
two prior articles (S109 `studbook-quality-control.qmd`, S110 `age-sex-pyramid.qmd`):
- **Lens A** -- figure/table-vs-data fidelity: re-derive every table/figure's numbers
  from its frozen source CSV independently, hunting for the "reversed skew" defect
  class S110 caught (a visualization/claim that shows the OPPOSITE of reality).
- **Lens B** -- editorial/narrative quality: clarity, structure, audience fit, tone
  (especially Section 4's AI-development narrative, checked against dragon #2's
  "candid not promotional" bar).

Both lenses' top findings were independently spot-verified by the parent session
(this session) via direct `git show`/`git log` before being recorded here as
confirmed -- not simply trusted from agent output. See `PROJECT_LEARNINGS.md` for the
established discipline this follows (Learning #7/#10/312 lineage: re-derive, don't
trust).

---

## Lens A -- Figure/Table-vs-Data Fidelity (full agent report)

### Finding 1 -- HIGH CONFIDENCE, real discrepancy -- **independently confirmed by parent session**

**Location:** `engineering-the-2.0.0-release.qmd:150-153` (prose supporting
`fig-architecture`, lines 125-149).

**The article's text (verified verbatim against the file):**
> "The cutover was declared in Phase 9 (Session 35): `runGeneKeepR()` became the
> canonical launcher via `lifecycle::deprecate_soft()`-aliasing (`3db018d1`)..."

**What actually happened (independently confirmed by this session via `git show
3db018d1:R/runGenekeepr.R` and `git log --oneline --follow -- R/runGenekeepr.R`):** At
Phase 9 (`3db018d1`, 2026-06-06), `runGeneKeepR()` became the **deprecated alias**,
calling the then-canonical `runModularApp()` -- the article's claim is backwards. The
commit's own message confirms it: `"refactor!: Phase 9 -- deprecate runGeneKeepR to a
modular-app alias; remove orphans"`.

`runGeneKeepR()` only became canonical later, via a separate, unrelated commit:
`1e64dd5d` -- `"refactor: issue #110 -- runGeneKeepR() is again the canonical Shiny
entry point; runModularApp() becomes the soft-deprecated alias; close #110 (S276)"` --
roughly 240 sessions after Phase 9, and **never mentioned anywhere in the article**.

The figure caption's "as of 2026-07-09" framing (lines 144-149) is correct for the
*current* state (confirmed directly against the current `R/runGenekeepr.R` /
`R/runModularApp.R`), but the body prose immediately after misattributes that
end-state to the Phase 9 commit specifically -- conflating two separate alias-direction
reversals into one, and omitting issue #110's role entirely.

**Confidence:** High. Independently reproduced by this session, not just the reviewing
agent.

### Finding 2 -- MEDIUM CONFIDENCE, real chart-fidelity issue (not independently re-verified by parent session -- flagged as-is)

**Location:** `fig-commit-pace` (lines 86-105), prose at lines 107-112.

The chart's x-axis is categorical (`factor(timeline$month, levels = timeline$month)`),
built only from months that had commits. The agent's independent re-derivation via
`git log --no-merges --format=%ad --date=format:%Y-%m` reproduced the CSV exactly
(2025-12: 7, 2026-04: 2, 2026-05: 30, 2026-06: 375, 2026-07: 98) and found a genuine,
complete 3-calendar-month gap (Jan-Mar 2026) plotted as if `2025-12` and `2026-04` were
adjacent -- right at the point where prose narrates a transition "from occasional...
commits in late 2025 to a sustained pace." A reader cannot see the all-zero stretch
from the chart. Does not contradict the literal prose, but is a genuine
mislabeled/misleading-axis defect in the strict sense this review was scoped to catch.

### Finding 3 -- LOW CONFIDENCE / cosmetic, zero reader-visible impact (not independently re-verified)

`feature-highlights.csv`'s "Gestation-derived parent-candidate window" row lists
`date = 2026-06-14` for commit `0eeee3f6`; `git show -s --format=%ad --date=short
0eeee3f6` gives `2026-06-13`. The `date` column is never rendered in `tbl-features`
(only `feature, issue, session_range, description` are selected) -- pure data-hygiene
nit, no reader-visible effect.

### What checked out cleanly (agent's own account, not independently re-verified line-by-line by parent session)

`tbl-modules` (LOC sum 4,731 matches caption; all 10 `test_file_count` values matched
an actual `ls tests/testthat/`), `tbl-phases` (spot-checked shas for phases 1, 2, 9 all
exist/in-range/correctly dated), `tbl-features` (13/47 = 27.66% -> "28%" correct; 3
shas spot-checked, all real/in-range), `tbl-testing-growth`/`fig-testing-growth` (full
re-derivation via `git ls-tree` at all 5 checkpoints reproduced 132/175/181/182/257
exactly; 95% increase claim correct), `tbl-process-metrics` (512 = 502+10 arithmetic
holds; 99.3% stakeholder-agreement figure matches), `fig-self-score-trend` (mean of
7 scores = 8.571 -> "8.57" matches; "roughly 2%" of 328 sessions = 2.13% checks out).

---

## Lens B -- Editorial/Narrative Quality (full agent report)

**Overall rating: 7/10** (agent's own assessment, not independently re-scored by
parent session).

### Finding 1 -- Internal contradiction on session count -- **independently confirmed and sharpened by parent session**

- **Location A:** line 617-618 -- "Documentation and article-drafting sessions --
  including **the three sessions that produced Sections 1-3** and the session that
  produced this one -- are an explicitly declared exception..."
- **Location B:** line 668-669 -- "each of **the four sessions that wrote Sections
  1-3** closed out with a `commit: pending` placeholder..." followed by a 4-item sha
  chain: `cc0f7798` (S331's fix, logged by S332), `2278b46f` (S332's fix, logged by
  S333), `ee690776` (S333's fix, logged by S334), `5f0b81d2` (S334's fix, logged by
  S336).

**Parent-session verification (both passages read verbatim against the file,
confirmed as quoted above) and a sharper diagnosis than the agent's own:** Line 617's
"three sessions" is actually the CORRECT framing -- S332, S333, S334 drafted Sections
1, 2, 3 respectively (three sessions). Line 668-669's "four sessions... wrote Sections
1-3" is the actual error: it conflates "sessions that had a `commit: pending` receipt
gap" (S331, S332, S333, S334 -- four sessions) with "sessions that wrote Sections
1-3" (only three -- S331 did Phase A, the evidence-freeze, not a section). **The fix
is not simply "make both say the same number"** (the agent's suggested direction) --
it is specifically: keep line 617's "three," and reword line 668-669 to describe four
sessions having the receipt-gap pattern without claiming all four "wrote Sections
1-3."

### Other Lens B findings (agent's account, not independently re-verified by parent session)

2. Grammar error at lines 687-690 ("the gap the receipt-sha backfills above
   illustrate" -- subject/verb mismatch).
3. TDD vocabulary (RED/GREEN/REFACTOR, "session," "phase gates") used starting line 82
   but not explained until Section 4 (~line 557+), asking readers to hold undefined
   terms for ~500 lines.
4. Unglossed internal codename "XARCH-2" at lines 122-123.
5. "Phase A data freeze" (lines 531, 639, 682) used repeatedly, never defined.
6. "Vertical-slice" jargon (lines 21, 50, 81, 199) not glossed.
7. "More honest uncertainty reporting" (Abstract, line ~316) -- anthropomorphizing
   framing, slightly marketing-adjacent; suggests "more accurate" instead.
8. Self-referential/defensive aside at lines 500-501 ("a real gap, not a stale figure
   this article repeated uncritically") -- references the article's own unseen draft
   history; suggested to state plainly instead.
9. Confusing sentence at lines 661-664 conflating self-scoring vs. next-session
   evaluation as if they were the same number.
10. Only one hyperlink in the entire 724-line article despite dozens of issue
    numbers/commit shas cited as plain text -- undercuts the Abstract's "every claim
    traces to..." promise for a reader who wants to click through and verify.
11. `tbl-phases` caption doesn't gloss what its "Risk" column measures (risk of what?).
12. Section 2 (line 257) has no rhetorical bridge from Section 1, unlike Sections 3-4.

### Sections Lens B called out as genuinely strong

Introduction's "Scope" paragraph (lines 59-63), Section 2's curation transparency
(lines 257-269, explicitly naming what was excluded and why), Section 3's
self-contained table/figure captions (`tbl-testing-growth`, `fig-testing-growth`), the
`navbarPage`/CSS testing-pitfall explanation (lines 461-469), Section 4's avoidance of
AI-hype framing (explicitly hedged, e.g. lines 694-701's caveat about imprecise
stakeholder-correction figures), and the Conclusion's tight, non-repetitive close.

---

## What this session did NOT do

- Did not write article edits (correct per owner-confirmed "report only" scope).
- Did not independently re-verify Lens A's Findings 2/3 or any of Lens B's findings
  2-12 firsthand -- only the two most consequential findings (Lens A #1, Lens B #1)
  were spot-checked by the parent session before being recorded as confirmed above.
  Findings 2/3 (Lens A) and 2-12 (Lens B) should be treated as agent-reported, not yet
  independently verified, when a future session picks this up.
- Did not finalize a verdict, priority ranking, or fix recommendation across all
  findings -- interrupted by the owner before that synthesis happened.

## Next steps for the session that resumes this

1. Incorporate whatever material information the owner adds.
2. Independently re-verify the not-yet-checked findings (Lens A #2/#3, Lens B #2-12)
   before acting on any of them, per this project's standing discipline.
2. Decide, with the owner, whether findings get fixed in that session or a further one
   (this file itself did not make that call -- see the original scope question's
   options).
4. Re-render (`quarto render`) after any fix and clean up the render artifacts it
   leaves in `vignettes/articles/` (Learning 314) before staging.
5. Once resolved, update this file's header from DRAFT to a final status (or fold its
   content into a dated close-out entry) so it stops reading as incomplete.
