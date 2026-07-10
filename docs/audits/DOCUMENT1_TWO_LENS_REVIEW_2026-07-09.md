# Document 1 -- Two-Lens Adversarial Review (CLOSED -- 2026-07-09, Session 342)

**Target:** `vignettes/articles/engineering-the-2.0.0-release.qmd` ("Engineering
nprcgenekeepr 2.0.0"), Document 1 of the two-document plan in
`docs/planning/v2-transformation-article-plan.md` (Session 330).

**Date opened:** 2026-07-09 (Session 339) · **Date closed:** 2026-07-09 (Session 342)
**Status:** **CLOSED.** All 15 findings (2 spot-verified by Session 339, 13
independently re-verified by Session 342) have now been independently checked against
the CURRENT article file (`git`/`grep`/CSV re-derivation, not trusted from agent
report). All 15 are **confirmed real and still unfixed** as of this close-out. Per the
owner's explicit scope decision this session (`AskUserQuestion`, Session 342): this
audit report is the deliverable; **no article edits were made this session** — fixing
the findings is the next session's deliverable, prioritized below under
"Recommendations."

**Method:** Two independent forked review agents, matching the review pattern used for
two prior articles (S109 `studbook-quality-control.qmd`, S110 `age-sex-pyramid.qmd`):
- **Lens A** -- figure/table-vs-data fidelity: re-derive every table/figure's numbers
  from its frozen source CSV independently, hunting for the "reversed skew" defect
  class S110 caught (a visualization/claim that shows the OPPOSITE of reality).
- **Lens B** -- editorial/narrative quality: clarity, structure, audience fit, tone
  (especially Section 4's AI-development narrative, checked against dragon #2's
  "candid not promotional" bar).

Both lenses' top findings (A1, B1) were independently spot-verified by Session 339 via
direct `git show`/`git log` before being recorded here as confirmed; the remaining 13
findings were independently verified by Session 342 (see "Session 342 -- Independent
Verification" below) -- none were simply trusted from agent output. See
`PROJECT_LEARNINGS.md` for the established discipline this follows (Learning
#7/#10/312 lineage: re-derive, don't trust).

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

### Finding 2 -- MEDIUM CONFIDENCE, real chart-fidelity issue -- **independently confirmed by Session 342 (see "Session 342 -- Independent Verification" below)**

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

### Finding 3 -- LOW CONFIDENCE / cosmetic, zero reader-visible impact -- **independently confirmed by Session 342**

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

### Other Lens B findings -- **all 11 independently confirmed by Session 342 (see "Session 342 -- Independent Verification" below)**

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

## Session 342 -- Independent Verification of the Remaining 13 Findings

**Gotcha inherited from S341:** the article grew from 724 to 745 lines after S340's
edit (a footnote insertion); every location below is re-anchored against the CURRENT
745-line file via direct `grep -n`, not copied from this document's original
(now-stale) line numbers. Where the original finding cited old line numbers, both are
given.

### Lens A

**Finding 2 -- fig-commit-pace categorical-axis gap (MEDIUM CONFIDENCE -> CONFIRMED,
still present).** Location: `fig-commit-pace` code block, current L105-124; prose at
current L126-131 (was L107-112). Independently re-derived the commit-month counts with
`git log --no-merges --format=%ad --date=format:%Y-%m 4548aa1b..8ca8bb24 | sort | uniq
-c`, bounded to the article's own stated commit range: `2025-12: 7, 2026-04: 2,
2026-05: 30, 2026-06: 375, 2026-07: 98` -- an exact match to
`data/commit-activity-timeline.csv`, confirming the underlying data is correct, but
also independently confirming the defect: the chart's x-axis (`factor(timeline$month,
levels = timeline$month)`) is categorical over only the 5 months that had commits, so
the complete zero-commit gap (2026-01, 2026-02, 2026-03) is invisible -- `2025-12` and
`2026-04` render as adjacent bars. This sits directly under the prose narrating a
transition "from occasional...commits in late 2025 to a sustained pace," which a
reader cannot see is separated by a 3-month silent gap. **Verdict: real, unfixed.**

**Finding 3 -- feature-highlights.csv date/commit mismatch (LOW CONFIDENCE / cosmetic
-> CONFIRMED, still present, still zero reader-visible impact).** `data/
feature-highlights.csv` row 4 ("Gestation-derived parent-candidate window") lists
`date = "2026-06-14"` for commit `0eeee3f6`; `git show -s --format=%ad --date=short
0eeee3f6` independently returns `2026-06-13` -- a one-day, off-by-one discrepancy.
Re-confirmed the `date` column is still excluded from `tbl-features`'s rendered
columns (current L297: `features[, c("feature", "issue", "session_range",
"description")]`) -- the mismatch exists only in the source CSV, never reaches a
reader. **Verdict: real (data-hygiene nit only), unfixed, no reader-visible effect.**

### Lens B

**Finding 2 -- grammar error, subject/verb mismatch (CONFIRMED, still present).**
Current L708-709 (was L687-690): `"Unrecorded action" (the gap the receipt-sha
backfills above illustrate)` -- singular subject "the gap," plural verb "illustrate."
Should read "illustrates." **Verdict: real, unfixed.**

**Finding 3 -- TDD vocabulary used ~500 lines before being explained (CONFIRMED,
still present).** First uses: L32 (Abstract, "strict red-green-refactor TDD") and L101
(Section 1, "one TDD session (RED -> GREEN -> REFACTOR...)"). Not explained until
Section 4's "### Strict TDD, gated by explicit confirmation" heading at L594 -- a
~490-560 line gap during which a reader unfamiliar with TDD terminology has no
definition to anchor to. **Verdict: real, unfixed.**

**Finding 4 -- unglossed internal codename "XARCH-2" (CONFIRMED, still present).**
Current L142: "an explicit, if still informal, module contract (documented as XARCH-2
in the migration plan)." The codename is never expanded or explained for a reader
without access to the internal migration plan. **Verdict: real, unfixed.**

**Finding 5 -- "Phase A data freeze" never defined (CONFIRMED, still present, now
appearing 3x not 1x as originally sampled).** All three occurrences remain caption-only
prose, never explained: L550 (`tbl-process-metrics` caption), L658-659
(`fig-self-score-trend` caption), L701 (Section 4 body, "the same Phase A freeze"). A
reader never learns what step in the session protocol "Phase A" names. **Verdict:
real, unfixed.**

**Finding 6 -- "vertical-slice" jargon never glossed (CONFIRMED, still present, 4
occurrences).** L21, L62, L100, L218. Confirmed via a full section-header sweep
(`grep -n "^##\|^###"`) that the article has no glossary or definitions section where
this term (or "XARCH-2," or "Phase A") could be resolved. **Verdict: real, unfixed.**

**Finding 7 -- "more honest uncertainty reporting" anthropomorphizing framing
(CONFIRMED, still present).** Abstract, current L27 (verbatim, unchanged), echoed as a
subsection title at L335 ("Genetic Value Analysis becomes more honest about
uncertainty"). Statistics do not have honesty; "more accurate" or "more explicit about
its own limits" would be a more precise, less marketing-adjacent framing. **Verdict:
real (subjective/editorial), unfixed.**

**Finding 8 -- self-referential/defensive aside (CONFIRMED, still present).** Current
L519 (was L500-501): "a real gap, not a stale figure this article repeated
uncritically" -- references the article's own unseen drafting history in a way a
reader without that context cannot parse; a plain statement of the fact would read
better. **Verdict: real (editorial), unfixed.**

**Finding 9 -- confusing self-scoring vs. next-session-evaluation sentence
(CONFIRMED, still present, re-anchored to current L681-684).** "The mechanism behind
that self-scoring is a durable receipt...each session writes a `HANDOFFS.md` block
recording...its own score, and the *next* session scores that handoff in turn before
starting its own work" -- presents `self_score` (a session scoring itself) and
`predecessor_score` (the next session scoring the prior handoff's quality) as one
continuous scoring action rather than two distinct numbers/mechanisms, which a
first-time reader could misread as the same score computed twice. **Verdict: real
(clarity), unfixed.**

**Finding 10 -- only one hyperlink despite dozens of plain-text issue/commit citations
(CONFIRMED, still present).** `grep -c '\](http'` returns exactly **1** hyperlink in
the full 745-line article (L531, the workflow-run link) against 7 unique `issue #N`
citations and 15 unique 8-character commit shas cited as inert plain text (22 total
citable references, not hyperlinked). This undercuts the Abstract's own claim
(L35-37) that "every claim traces to a commit, `CHANGELOG.md` entry, or frozen
extraction" for a reader who wants to click through and verify. **Verdict: real,
unfixed.**

**Finding 11 -- `tbl-phases` caption doesn't gloss its "Risk" column (CONFIRMED, still
present).** Caption at L216-219 lists column names without explaining what dimension
"Risk" measures; the only prose gloss anywhere is a single aside at L271-272 ("HIGH
risk rating even though it shipped in a single session") that illustrates but never
defines the dimension (risk of what -- reversibility? blast radius? technical
complexity?). **Verdict: real (minor), unfixed.**

**Finding 12 -- Section 2 has no rhetorical bridge from Section 1 (CONFIRMED, still
present).** Section 2 (current L274) opens directly with "Between the v1.0.8 and
v2.0.0 CRAN submissions, 47 GitHub issues closed..." -- no transition sentence
connecting from Section 1's migration narrative, unlike Section 3 (opens "Growth in
features (@sec-features) is only as trustworthy as...") and Section 4 (opens
"Sections 1 through 3 describe *what* changed..."). **Verdict: real (minor,
structural), unfixed.**

## Final Findings Summary

| # | Lens | Finding | Severity | Location (current) | Status |
|---|------|---------|----------|---------------------|--------|
| A1 | A | `runGeneKeepR()` Phase-9 misattribution | **HIGH** (factual) | L170-172 | Confirmed, unfixed |
| B1 | B | "four sessions...wrote Sections 1-3" contradiction | **HIGH** (factual/internal-consistency) | L687-688 | Confirmed, unfixed |
| A2 | A | Commit-pace chart hides a 3-month zero-commit gap | **MEDIUM** (misleading visual) | L105-131 | Confirmed, unfixed |
| B10 | B | Only 1 hyperlink vs. 22 plain-text citations | **MEDIUM** (undercuts stated promise) | L531 (article-wide) | Confirmed, unfixed |
| B3 | B | TDD vocabulary undefined for ~500 lines | **MEDIUM** (audience fit) | L32/L101 -> L594 | Confirmed, unfixed |
| B5 | B | "Phase A data freeze" never defined (3x) | **LOW-MEDIUM** | L550, L658-659, L701 | Confirmed, unfixed |
| B6 | B | "Vertical-slice" never glossed (4x) | **LOW-MEDIUM** | L21, L62, L100, L218 | Confirmed, unfixed |
| B2 | B | Grammar error (subject/verb mismatch) | **LOW** (mechanical) | L708-709 | Confirmed, unfixed |
| B4 | B | "XARCH-2" unglossed codename | **LOW** | L142 | Confirmed, unfixed |
| B9 | B | Confusing self-score/predecessor-score sentence | **LOW** (clarity) | L681-684 | Confirmed, unfixed |
| B11 | B | `tbl-phases` "Risk" column not glossed | **LOW** | L216-219 | Confirmed, unfixed |
| B12 | B | Section 2 has no bridge from Section 1 | **LOW** (structural) | L274 | Confirmed, unfixed |
| B7 | B | "More honest uncertainty" anthropomorphizing | **LOW** (editorial) | L27, L335 | Confirmed, unfixed |
| B8 | B | Self-referential/defensive aside | **LOW** (editorial) | L519 | Confirmed, unfixed |
| A3 | A | 1-day date mismatch, `0eeee3f6` (data-hygiene only) | **MINOR** (no reader impact) | `data/feature-highlights.csv:4` | Confirmed, unfixed, cosmetic |

**Coverage: 15 of 15 findings independently verified (100%).** No findings were
downgraded or dismissed on re-verification; all 15 are real and still present in the
article as of 2026-07-09.

## Recommendations (priority order for the fix session)

1. **Fix the two HIGH factual findings first** (A1, B1) -- these are the only findings
   that make an incorrect claim about what happened, not just an unclear or
   unpolished one.
2. **Fix the two MEDIUM findings with a concrete mechanism already available**: A2
   (either add the zero-commit months to the CSV/factor levels so the gap renders, or
   note the gap explicitly in the caption) and B10 (hyperlink the existing issue
   #/commit-sha citations -- GitHub issue and commit URLs are mechanical to construct,
   e.g. `https://github.com/rmsharp/nprcgenekeepr/issues/<N>` and
   `.../commit/<sha>`).
3. **B3 (TDD vocabulary)** -- either move a one-sentence TDD gloss earlier (e.g. into
   the Introduction's "Four pillars" paragraph) or add a forward-reference ("see
   Section 4") at first use.
4. **Batch the remaining LOW findings as one editorial pass**: B5/B6 (add
   parenthetical glosses at first use for "Phase A data freeze" and "vertical-slice"),
   B2 (grammar fix), B4 (gloss or drop "XARCH-2"), B9 (split the self-score/
   predecessor-score sentence into two), B11 (one clause in the `tbl-phases` caption),
   B12 (one bridging sentence), B7/B8 (reword both per the finding text above).
5. **A3** is optional -- zero reader-visible impact; fix opportunistically only if the
   fix session is already touching `feature-highlights.csv` for another reason.

## What this session (S339) did NOT do

- Did not write article edits (correct per owner-confirmed "report only" scope).
- Did not independently re-verify Lens A's Findings 2/3 or any of Lens B's findings
  2-12 firsthand -- only the two most consequential findings (Lens A #1, Lens B #1)
  were spot-checked by the parent session before being recorded as confirmed above.
  **Session 342 completed this verification pass; see above.**
- Did not finalize a verdict, priority ranking, or fix recommendation across all
  findings -- interrupted by the owner before that synthesis happened. **Session 342
  completed this synthesis; see Final Findings Summary and Recommendations above.**

## Next steps for the session that picks up the fixes

1. Follow the priority order in "Recommendations" above.
2. Re-render (`quarto render`) after any fix and clean up the render artifacts it
   leaves in `vignettes/articles/` (Learning 314) before staging.
3. After fixes land, do a full corpus sweep (the S340 precedent: `grep` for stale
   echoes of whatever phrasing changed) to confirm no other passage repeats a fixed
   error.
