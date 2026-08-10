# Issue #145 Plan — Sire/Dam Left-Right Placement Default for the Pedigree Diagram

**Status:** RATIFIED 2026-08-09 — proceed to Slice 1 as written (D1-D9; Slice 2 not created, D8).
Slice 1's own Pre-RED must still empirically verify D2's mechanism live before RED (§6 dragon 1,
§9) — ratification approves the design's intent and scope, not yet a proven implementation
mechanism. No `R/`/`tests/`/`man/` content changed this session. Adversarially reviewed this
session by 3 independent agents (correctness/evidence, contract-vs-#142/#143/#144 scope,
house-style completeness); findings incorporated below before ratification (§9) — see §8
Provenance for what was found and corrected.
**Session:** S499 (2026-08-09). **Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`
(owner-picked this session via `AskUserQuestion` over the literal `DESIGN_WORKSTREAM.md` task
mapping — matching the #136/#142 precedent: this is a positioning/rendering-contract decision inside
`.positionMatingUnitForest()`, not a UI zone-layout design).
**Origin:** [GitHub issue #145](https://github.com/rmsharp/nprcgenekeepr/issues/145) ("Correct the
placement of sire's relative to dam's in the pedigree drawing");
`docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md` Findings #1/#2 (S480);
`docs/research/issue-145-kinship2-sire-dam-placement-spike-2026-08-08.md` (S482); issue #145's own
Tier-1 slot in the owner's standing pedigree-diagram-cluster sequencing (set S480) is now complete,
per `BACKLOG.md`.
**Touches (Slice 1 only — D8 ratified option (b), no UI, so Slice 2 does not exist):**
`R/makePedigreeDiagramData.R` (`.positionMatingUnitForest()` — additive post-hoc step;
`makePedigreeMatingLayout()` — new `orderBySex` parameter), `tests/testthat/test_positionMatingUnitForest.R`
and `tests/testthat/test_makePedigreeMatingLayout.R` (new tests, plus a required update to the
GA204Z/8LKBV9 fixture's existing hard-coded `x` expectations, §6), `NEWS.Rmd`.
Does **not** touch `vignettes/articles/colony-manager-guide.qmd` or
`vignettes/manual_components/_pedigree_browser.Rmd` — no UI change ships in this ratification (the
tutorial/article checklist is Slice-2-only, and Slice 2 is not created); does **not** touch
`.buildMatingUnitForest()`'s anchor-selection tie-break (`preferAnchor()`,
`R/makePedigreeDiagramData.R:396-404`) — modifying it does not reliably produce "male left" (§1.3.2)
and risks disturbing #143/#144's hardcoded fixture expectations for no benefit (§7 Alternative 2);
does not touch `.addRectilinearWaypoints()` (#142) — it re-derives x order fresh from final
coordinates every call, confirmed unaffected (§5); does not attempt the multi-mate/"crowding" case
(§1.3.3, D5) — no existing mechanism to extend safely this session.

> **Scope.** This document is a design/architecture plan only. It changes no `R/`, `tests/`, or
> `man/` content by itself. Implementation happens in a future session against the slice contract
> ratified in §4 — see §6 item 6 for why gate (a) of `SESSION_RUNNER.md`'s Vertical Slice Sessions
> is only conditionally satisfied even after ratification.

---

## 1. Context

### 1.1 What is already decided (do not re-litigate)

- **Issue #145 is new-feature design work, not a bug fix.** S480's audit (Finding #1) and this
  session's own direct source read (§1.3) both independently confirm `nprcgenekeepr` has zero
  sex-based positioning logic today — there is no existing "male-left" behavior to "correct." Do
  not reopen this question.
- **kinship2 implements no male-left rule either, hard or soft.** S482's verification spike
  (`docs/research/issue-145-kinship2-sire-dam-placement-spike-2026-08-08.md`) directly read
  kinship2's `align.pedigree()`/`alignped1()`/`autohint()` source and built 5 reproducible test
  pedigrees; the "sire-left" appearance in the simple case is an artifact of internal
  father/mother-slot indexing, and the multi-mate case centers the shared individual with mates
  split by pure discovery order. Do not reopen this question, and do not cite issue #145's own
  inline citations `[2]`-`[7]` as verified sources — S480 and S482 both independently found they
  don't resolve to anything in this project's own nomenclature reference or to kinship2's actual
  algorithm.
- **This project's own copy of the standardized-nomenclature reference does not textually state a
  male-left rule** (`inst/extdata/reference/pedigree_nomenclature.html`, Bennett, French, Resta &
  Doyle 2008 — S480 Finding #2). Its symbol/placement tables exist only as un-transcribed figure
  images, not extractable text.
- **#143 (S472) and #144 (S474) already settled `.positionMatingUnitForest()`'s generation-row
  (`y`) assignment** for founders/anchors with mismatched effective generations, via `unitGenOf`
  (`R/makePedigreeDiagramData.R:627`)/`effGenOf` (lines 707-719)/`dispGenOf` (lines 856-873).
  **Correction from this session's adversarial review:** describing this as "never touches `x`"
  overstates it — both fixes' own shipped regression tests prove a `gen`-only-looking edit already
  cascaded to *other* nodes' `x` values in the same fixture (`G8EBU9`'s `x` changed from `0.25` to
  `0.00` under #143; two duplicate nodes' `x` changed under the same commit), via the shared
  contour-reservation mechanism `mergeSubtrees()` uses. What actually holds, and is what this
  design relies on: **neither fix touches `preferAnchor()`, and D2 below never calls `effGenOf`/
  `dispGenOf`/`preferAnchor()` itself**, so this design cannot re-enter or regress *their* specific
  mechanism — but "gen and x are orthogonal in this algorithm" is not a true general statement, and
  this document does not rely on it being one (see D2's own safety argument, §3, which is
  independent of this).
- **Tier 1 of the pedigree-diagram backlog-sequencing cluster is complete** (crash bugs + this
  issue's own verification spike + the kinship2-comparison-doc refresh, S481-484). This document is
  the design step the sequencing audit deferred to "a future #145 design session."

### 1.2 What issue #145 says (verbatim)

> The pedigree drawing layout is to follow standard genetic counseling conventions where the male
> (sire/father) is placed to the left and the female (dam/mother) is placed to the right in a
> partnering pair.

The issue's body goes on to describe (in its own four numbered sections) central-sire-placement
with flanking dams for the multi-mate case, a "globalized... rather than strictly localized"
relaxation of the rule under crowding, sibship clustering plus a subject-duplication heuristic, and
manual override via kinship2's `hints`/spouse-matrix mechanism — each citing sources `[2]`-`[7]`
that do not resolve to anything in this repository (§1.1). Two owner comments are already attached
to the issue: the S480 audit flag and the S482 verification spike, both summarized in §1.1. Neither
closes the issue; both explicitly defer the design decision to a future session — this one.

### 1.3 What this session's own research found — and where the issue, the prior spike's own
recommendation, and a third prior document need correcting

This session ran a 3-agent research pass directly against current source and this project's own
prior design documents, then independently re-verified the most load-bearing claims against the
live file this session (every line number below confirmed by direct `Read`, not trusted from an
agent report alone) — and a further 3-agent adversarial review of the resulting draft, whose
findings are folded in throughout (see §8).

1. **`nprcgenekeepr` does not call kinship2 at all.** `grep -n kinship2 DESCRIPTION NAMESPACE`
   returns nothing; kinship2 is not a package dependency. Every kinship2 reference in
   `R/makePedigreeDiagramData.R` (10 lines total: 67, 73, 255, 286, 534, 572, 908, 939, 1156, 1211
   — corrected this session from an initial undercount of 7) is roxygen/plain-comment prose citing
   it as a design *inspiration*, never a function call. **The S482 spike's kinship2-only findings
   do not automatically transfer to nprcgenekeepr's own algorithm** — they had to be, and were,
   independently re-derived against this project's own code (items 2-3 below).

2. **Independently confirmed: nprcgenekeepr's own current default has no sex-based rule either —
   but its incidental behavior is not "coincidentally male-left" the way kinship2's is.** Direct
   trace of the real GA204Z/8LKBV9 fixture (`tests/testthat/test_positionMatingUnitForest.R:120-134,
   199-200`), independently re-verified against a live run by this session's adversarial review:
   sire `5A6DFT` (`sex="M"`) and dam `8DKELJ` (`sex="F"`) are both founders with exactly one mating
   unit each; `preferAnchor()` (`R/makePedigreeDiagramData.R:396-404`) breaks the founder/mate-count
   tie by ascending id string (`"5A6DFT" < "8DKELJ"`), making the **sire** the anchor — yet the
   committed, passing test asserts `8DKELJ` (the dam) at `x = -0.50` (left) and `5A6DFT` (the
   anchor sire) at `x = 0.00` (right of her; their child `8LKBV9` further right at `x = 0.50`).
   `positionUnit()`'s `subIds <- c(fpHere, kidIds)  # free-pass parent leftmost`
   (`R/makePedigreeDiagramData.R:730`) unconditionally places the **non-anchor** ("free-pass")
   parent leftmost among the unit's own children. Anchor status — decided by the id-string
   tie-break, unrelated to sex — does not correspond to "right"; `finalizeNode()`
   (`R/makePedigreeDiagramData.R:668-677`) defines the anchor's own `x` as
   `(xs[1] + xs[n]) / 2` — the midpoint of the *first and last* elements of `subIds`, which for
   this 2-element unit (free-pass dam + 1 child) exactly equals `mean(-0.50, 0.50) = 0.00`.
   **Today's simple-pair default places the dam left of the sire in this canonical fixture — the
   opposite of "male-left."** Whether the anchor happens to be male or female in any given real
   pedigree is an accident of id-string ordering, with no relationship to sex at all.
   **Correction, found by this session's adversarial review:** `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`'s
   own Example 4 summary (its line ~463) currently states the *opposite* — that nprcgenekeepr's
   single-mate default "sire tends to render left of dam... coincidentally similar-looking result
   [to kinship2]." That claim is now stale and directly contradicted by the direct trace above; it
   is not fixed in this document (out of scope — a different file, not touched by this design, per
   this project's own "report an incidentally-discovered, unrelated pre-existing gap, don't fix it
   mid-session" precedent, `PROJECT_LEARNINGS.md` Learning 382). A future session should correct
   that comparison doc's Example 4 summary and re-check whether its own Examples 1-3 make the same
   claim.

3. **Independently confirmed: the multi-mate "crowding" case has no existing "anchor-centered,
   mates flank" mechanism to extend** — the S482 spike's own cross-project recommendation ("the
   natural analog... is already nprcgenekeepr's own existing tie-break convention... for unrelated
   reasons") does not hold up against the actual code, and this document corrects it.
   `preferAnchor()`'s tie-break decides which ONE mate wins anchor for a given unit; the
   `used`-status cascade (`R/makePedigreeDiagramData.R:427-444`) then hands every SUBSEQUENT unit's
   anchor to whichever mate is not yet used elsewhere in the tree — the shared multi-mate
   individual is threaded through those later units as `__dup_`/free-pass occurrences, **not**
   rendered as one centered node with mates as flanking peers. Confirmed directly against the real
   GA204Z/8LKBV9 fixture: `8LKBV9` (3 mates) anchors only his first-discovered unit; his other two
   mates (`8P17E3`, `FJIB3R`) become independent anchors/roots of their own subtrees, with `8LKBV9`
   duplicated into each. **Building a literal centered-flanking visual for the crowding case would
   require new machinery this design does not evidence a need for** — see D5/D9.

### 1.4 Explicit scope boundary: what this design changes and does not

This design is scoped to the **simple pair** case only: one mating unit, both parents real
(non-dangling), each with an unambiguous single-sex code (`"M"` or `"F"` — never `"H"`, `"U"`, or
`NA`), and **neither parent participates in any other mating unit or D5 partial-parentage direct
child** (mate-count exactly 1, no other tree-structural relationship). The multi-mate/crowding case
is explicitly deferred (D5/D9) — this document does not attempt kinship2-style centered flanking,
and a future session picking that up should treat it as a separate, materially larger feature (a
new positioning mechanism), not an extension of what is designed here.

**Why "no D5 direct child" specifically matters (not just cleanliness):** found by this session's
adversarial review by direct construction — a non-anchor parent with a D5 direct child (from a
different, unrecorded partner) is **not nested inside the mating unit's own recursive subtree at
all**; they are positioned as an independent root elsewhere in the tree, and the unit's own
displayed `x` only looks coherent because `finalUnitX = mean(anchorX, nonAnchorX)` reaches into
that unrelated absolute position after the fact. "The unit's own local subtree" that D2 needs to
reason about **does not exist as a contiguous whole** for this excluded case — this is a structural
requirement for D2 to be well-defined, not an optional simplification. This scenario has **zero
existing test coverage** in the suite today (confirmed by this session's grep) — a future session
should not relax this exclusion without adding coverage for it first.

---

## 2. Evidence-based inventory

| Question | Finding | Evidence |
|---|---|---|
| Does `nprcgenekeepr` depend on / call kinship2? | No — zero calls, not a package dependency | `grep -n kinship2 DESCRIPTION NAMESPACE` empty; all 10 in-file mentions are roxygen/comment prose |
| Single-mate default: who ends up left? | Whichever parent is **not** anchor (`preferAnchor()`'s id-string tie-break decides anchor, unrelated to sex) | `R/makePedigreeDiagramData.R:396-404,730`; `tests/testthat/test_positionMatingUnitForest.R:120-134,199-200` |
| Is `ped$sex` already in scope inside `.positionMatingUnitForest()`? | Yes — `sex` is a required input column (`R/makePedigreeDiagramData.R:590-595`), but the function body never reads it today | direct `Read`/grep, this session |
| Multi-mate "crowding": anchor-centered flanking already built? | No — anchor wins one unit; subsequent units cascade to other mates as independent anchors; shared individual is duplicated, not centered | `R/makePedigreeDiagramData.R:427-444`; GA204Z/8LKBV9 fixture trace |
| What do #143/#144 constrain? | Both touch `unitGenOf`/`effGenOf`/`dispGenOf`; neither touches `preferAnchor()`; **but neither is "gen-only" in effect** — their own shipped tests show cascading `x` changes elsewhere in the same fixture (§1.1 correction) | `R/makePedigreeDiagramData.R:627,707-719,856-873`; commits `904d74b7` (#143), `31ce78f4` (#144); `CHANGELOG.md:967-1122` |
| Reserved id prefixes / structural invariants | `^__union_\|^__dup_\|^__drop_\|^__bar_\|^__proj_` (guard at line 343); `anchor`/`nonAnchor` jointly `NA` only for orphan units (issue #154), confirmed `NA` *iff* both parents dangling; fixed duplicate-count and return-row contracts | `R/makePedigreeDiagramData.R:343-349,415-421`, roxygen 309-325, 474-506, 580-583 |
| Determinism | Fully deterministic given fixed `ped` row order — no randomness; input row order (not just edge structure) determines mating-unit processing order and, for a genuinely multi-mate individual, which mate cascades into anchoring which unit | `R/makePedigreeDiagramData.R:358-365,774` |
| Does `sex` reach the diagram pipeline reliably? | Yes as a required column; individual values may be `NA`/unmapped without erroring (falls back to `"diamond"`/"Other Unrecorded" shape/label) | `R/makePedigreeDiagramData.R:44-55`, `R/convertSexCodes.R:39`, `R/qcStudbook.R:22` |
| Does de-identification (`obfuscatePed()`) interact with `sex`? | No — `sex` is never referenced in `R/obfuscatePed.R` (56 lines, full read); passes through unchanged | `grep -n sex R/obfuscatePed.R` → zero hits |
| Does the nomenclature reference state a male-left rule? | No — prose discusses usage/ethics/publication practice; symbol/placement tables are un-transcribed figure images | `inst/extdata/reference/pedigree_nomenclature.html` (Bennett et al. 2008) |
| Does `.addRectilinearWaypoints()` (#142) depend on stale `x` order? | It reads final `x` values and order pervasively (`order(barPointX)`), but has no memory of "before" — every call re-derives sibship-bar/dogleg order fresh from whatever `x` is current, so an upstream reflection/swap is transparent to it | `R/makePedigreeDiagramData.R:1268-1437`, esp. 1290-1303, 1356 |
| Are there other existing fixtures with a D1-qualifying simple pair? | Yes — this session's adversarial review found 9 more qualifying-shape fixtures in the test suite plus 60 in the real bundled 375-individual pedigree; **only the GA204Z/8LKBV9 fixture's two lines are hard-coded `x` assertions** that D3 would flip — every other qualifying-pair fixture asserts only relational/structural properties that survive the change | this session's adversarial review, both test files + `inst/extdata/examples/` bundled pedigree |

---

## 3. Design decisions

**D1 — Scope: exactly the simple pair.** The new rule applies only when a mating unit's two real
parents each have an unambiguous `"M"`/`"F"` sex code and neither parent has any other
tree-structural relationship (no other mating unit, no D5 direct child — §1.4 explains why the
latter is structurally required, not optional). *Forced* by §1.3/§1.4: outside this case, "left of
whom" is not a clean binary (multi-mate) or the sex signal is ambiguous (`"H"`/`"U"`/`NA`), and no
existing mechanism computes the multi-mate visual the issue describes. **Implementation-guard note
(added per this session's adversarial review):** a real implementation must check `!is.na(anchor)`/
both-parents-real *before* indexing `sex` by anchor/nonAnchor id — a dangling parent's `sex` lookup
returns `character(0)`, which crashes R's `if()` rather than evaluating cleanly to `FALSE`; issue
#154's own fix pattern (check realness before touching anchor-dependent data) is the discipline to
follow here.

**D2 — Mechanism: swap the two real parents' own `x` values; do not reflect their subtrees.**
When a qualifying unit's current male-parent `x` is greater than its female-parent `x`, swap
`x[maleParentId]` and `x[femaleParentId]` — nothing else. **This is a revision from this session's
first draft**, which proposed reflecting the whole local subtree about its own center; the
adversarial review constructed a concrete counter-example (a qualifying unit with an asymmetric,
wide multi-child fanout) where that reflection produced an exact-position collision with an
unrelated sibling elsewhere in the tree. The value-swap below is a different, more conservative
operation, reasoned through this session in response to that finding:

- The free-pass (non-anchor) parent is always the group's leftmost element by construction
  (`R/makePedigreeDiagramData.R:730`), and — because `mergeSubtrees()` shifts each subsequent
  `subIds` element only far enough right to clear every prior element's contour — the free-pass
  parent's `x` is provably the *global* leftmost point of the unit's entire subtree, not merely an
  approximation.
- The anchor's own `x` (`finalizeNode()`'s `(xs[1] + xs[n]) / 2`) is the mean of the free-pass
  parent's `x` and the last child's own representative `x` — both of which lie within
  `[global_min, global_max]` of the subtree — so the anchor's `x` always lies within the subtree's
  overall bounding footprint too, regardless of how many children exist or how wide any single
  child's own descendant fanout is.
- Both values being swapped therefore already lie inside the pre-existing footprint before AND
  after the swap; the **set** of occupied positions is unchanged, only which parent's id occupies
  which position changes. No child, duplicate, or ancestor is touched or needs to move.
- The mating-unit's own displayed `x` (`finalUnitX = mean(anchorX, nonAnchorX)`,
  `R/makePedigreeDiagramData.R:817-838`) is invariant under this swap (mean is symmetric in its two
  arguments), so the unit node does not move either.
- D1 already excludes any qualifying pair where either parent has another mating unit, so neither
  swapped parent can have a duplicate node anywhere — the hardcoded `+ minSep * 0.4` rightward
  duplicate offset the adversarial review flagged as a potential complication (§8) **does not apply
  to any unit this design touches**, by scope, not by luck.

**This reasoning is a paper argument from this session, not yet empirically tested against the live
code.** Per this project's own established discipline (matching the S465 rectilinear-waypoint
precedent, `PROJECT_LEARNINGS.md` Learning 460), **Slice 1's Pre-RED must build a live repro and
verify this mechanism empirically before committing to RED assertions** — specifically including a
re-run of the adversarial review's own counter-example fixture (a wide, asymmetric multi-child
fanout) through the *swap* mechanism (not the rejected reflection), to confirm no analogous
collision survives under the new approach.

**D3 — Direction: male left, female right.** *Reclassified this session from an untagged, silently
-forced claim to a genuine judgment call* (found by adversarial review: nothing in D1/D2 requires
*this* direction over its mirror image; the current sex-agnostic default doesn't establish any
precedent either way). Ratified via `AskUserQuestion`, §9.

**D4 — `"H"`/`"U"`/`NA` sex codes never trigger the swap.** If either parent's sex is not exactly
`"M"` or `"F"`, D1's scope excludes the unit entirely and today's existing (sex-agnostic) default
stands, unchanged. *Forced*: §2 found no existing precedent for ordering unknown/ambiguous sex, and
this design does not invent one unrequested.

**D5 — The multi-mate/crowding case is out of scope; today's behavior is unchanged.** No
centered-flanking mechanism is built. *Forced* by §1.3.3: no partial mechanism exists to extend,
and building one from scratch is a materially larger, separately-scoped feature the issue's own
(now-corrected) premise does not require.

**D6 — Testing convention: pin exact input row order in new fixtures.** *Forced/methodological.*
§2 confirms row order (not just edge structure) already determines mating-unit processing order
and, for a genuinely multi-mate individual, which mate cascades into anchoring which unit. Any new
regression test for this rule (and any existing test touched by it) must construct its `ped` data
frame with the exact row order the assertion depends on, not merely "the same relationships."

**D7 — Documentation framing.** *Forced* by §1.1/D1's settled facts. `NEWS.Rmd`/tutorial-article
prose must describe this as a **new, additive default**, not a bug fix, matching the language "the
diagram now defaults to placing the male parent to the left in a simple two-parent mating pair,
matching common pedigree-drawing convention; multi-mate/crowded families keep today's layout,
unaffected." Citation checklist (#120): **N/A** — a rendering/layout default is not a statistic or
estimator. `_pkgdown.yml` reference-coverage checklist: **N/A** — `makePedigreeMatingLayout()`
already has an entry (`_pkgdown.yml:304`); no new export is added, only a parameter (D8). GitHub
issue close-out checklist: `gh issue close 145 --reason completed --comment "..."` citing this
document and the shipping session's `CHANGELOG.md` entry, owed in Slice 1's own close-out (added to
Slice 1's DONE criteria, §4). `a2interactive.Rmd` checklist (deferred, not same-session, per its own
broadened S478/Learning 478 scope): if D8 chooses (b) or (c), the new `orderBySex` parameter is
added to an *already-`a2interactive.Rmd`-documented* function — flagged here as deferred debt for a
future documentation pass, matching issue136's own explicit deferral acknowledgment for the same
checklist, not silently left unmentioned.

**D8 — Toggle shape.** *Genuine judgment call* — three candidate shapes, ratified via
`AskUserQuestion` (§9):
- (a) Always-on, no parameter — the swap simply always applies when D1's scope matches.
- (b) A new `orderBySex = TRUE` parameter on `makePedigreeMatingLayout()` (default on, overridable)
  — future-proofing with no immediate UI, matching the `useLabels`/`edgeStyle` precedent of adding
  the parameter ahead of any UI wiring.
- (c) Same as (b), plus immediate Shiny UI toggle wiring (a new Slice 2 in `R/modPedigree.R`).

**D9 — Whether to file a follow-up issue for the multi-mate/crowding centered-flanking visual.**
*Promoted this session from an embedded, option-free mention under D5 to its own genuine judgment
call* (found by adversarial review: the original text deferred this to "the ratification record"
with zero named alternatives to ratify). Ratified via `AskUserQuestion` (§9):
- (a) File now, as a low-priority, explicitly design-only follow-up issue, noting D5's own finding
  that no partial mechanism exists to extend.
- (b) Don't file — rely on this document's own D5/§1.3.3 finding being discoverable if anyone
  revisits issue #145's history later; avoid adding a speculative backlog item nobody has asked for.
- (c) File only if a user or the owner actually asks for the multi-mate visual in the future — i.e.
  decline for now with no issue filed, same as (b) in the near term.

---

## 4. Implementation plan — vertical slices (one session each)

**Note on Vertical Slice Session gate (a) (`SESSION_RUNNER.md` §Vertical Slice Sessions):** this
document is the pre-declared contract once §9 ratifies it, but gate (a) is only *conditionally*
satisfied even then — see §6 item 6. Slice 1's own Pre-RED is not merely "confirm state unchanged
since approval"; it is a further, narrower verification step (empirically proving D2's mechanism
live, per D2's own dragon) whose outcome could still change Slice 1's exact scope. Treat this
document as the contract for *what* is being built and *why*, not as proof the *how* is already
nailed down.

### Slice 1 — Core positioning behavior (mandatory; contains D8's chosen shape from (a)/(b))

**Scope:** Implement D1-D7 inside `.positionMatingUnitForest()` (and, if D8 chose (b), thread a new
`orderBySex` parameter through `makePedigreeMatingLayout()`). No Shiny UI change. Pre-RED must
live-verify D2's swap mechanism against a minimal repro — including the adversarial review's own
wide-fanout counter-example fixture — before committing to RED test assertions.

**Touches:** `R/makePedigreeDiagramData.R`, `tests/testthat/test_positionMatingUnitForest.R` (new
tests for: a qualifying M+F pair with today's default already correct as a no-op case; a qualifying
pair needing the swap; `"H"`/`"U"`/`NA` pairs asserting no swap; a qualifying pair with 3+ children
including an asymmetric fanout, directly exercising D2's own safety argument; the required update
to the existing GA204Z/8LKBV9 fixture's `5A6DFT`/`8DKELJ` expected `x` values), plus
`tests/testthat/test_makePedigreeMatingLayout.R` if D8 chose (b); `NEWS.Rmd`.

**DONE looks like:**
- For every qualifying (D1) unit, `x[male] < x[female]` after positioning.
- Every non-qualifying unit (crowding, `"H"`/`"U"`/`NA`, more than one mating unit for either
  parent, either parent has a D5 direct child) is byte-identical to today's output.
- The existing GA204Z/8LKBV9 fixture's `5A6DFT`/`8DKELJ` expected `x` values are updated to reflect
  the new default; a Pre-RED re-audit of the 9 other qualifying-shape fixtures this session's
  review found (§2) confirms whether any additionally need an update (none were found to have
  hard-coded `x` assertions this session, but Slice 1 must re-confirm against current source, not
  trust this citation).
- `NEWS.Rmd` gained an entry describing the new default (D7); `gh issue close 145` with a comment
  citing this document and the shipping `CHANGELOG.md` entry.

**Verification:** Full clean regression read, 0 failed/0 error, baseline warning-count unchanged
except the one deliberately-updated fixture; `devtools::check()` baseline unchanged;
`lintr::lint_package()` 0 lints on touched files; live `shinytest2`/`chromote` re-verification
against a real simple-pair fixture (e.g. a family from `obfuscated_rhesus_mhc_ped.csv`), screenshot,
visually confirm male-left/female-right rendering with zero console errors. Phase 3E is **not**
n/a — this changes runtime rendering behavior.

### Slice 2 — Shiny UI toggle (NOT created — D8 ratified option (b), no UI wiring; kept here only as
a reference for a future session that opens UI exposure as its own, separately-scoped pickup)

**Scope:** Expose `orderBySex` as a user-facing control in the Pedigree Diagram tab
(`R/modPedigree.R`), mirroring #142's `edgeStyle` toggle pattern.

**Touches:** `R/modPedigree.R`, its test file, `vignettes/articles/colony-manager-guide.qmd` and/or
`vignettes/manual_components/_pedigree_browser.Rmd`, `NEWS.Rmd` (a new UI control is its own
NEWS-worthy event, distinct from Slice 1's entry).

**DONE looks like:** A visible toggle in the Diagram tab; default state matches D8/Slice 1's
default; toggling it live re-renders the diagram with the opposite behavior.

**Verification:** The Slice 1 matrix (regression suite, `devtools::check()`, `lintr::lint_package()`
on touched files) plus a live `shinytest2`/`chromote` toggle-and-re-render check, screenshots of both
states, 0 console errors.

---

## 5. Impact analysis

| Surface | Impact | Action |
|---|---|---|
| `.positionMatingUnitForest()` | Additive post-hoc value-swap for qualifying simple-pair units only | New internal step; Slice 1 Pre-RED verifies D2's mechanism live before RED |
| `makePedigreeMatingLayout()` | New parameter, if D8 chooses (b)/(c) | Update signature + roxygen |
| `test_positionMatingUnitForest.R` GA204Z/8LKBV9 fixture | Its `5A6DFT`/`8DKELJ` expected `x` values flip (§1.3.2) | Deliberate, required test update |
| Every other existing fixture in the suite | 9 additional qualifying-shape fixtures found this session (§2); none currently carry a hard-coded `x` assertion that would break, but Slice 1 Pre-RED must re-confirm against current source | Re-audit at Slice 1 Pre-RED, not assumed clean from this citation alone |
| `.addRectilinearWaypoints()` (#142) | None — re-derives x order fresh from final coordinates every call, no stale-state dependency (§2) | Re-verify live in Slice 1, no code change expected |
| #143/#144 fixes | None — D2 never calls `effGenOf`/`dispGenOf`/`preferAnchor()`, so it cannot re-enter their mechanism (§1.1) | Re-verify via full regression suite, no code change expected |
| `obfuscatePed()` | None — `sex` is untouched by de-identification (§2) | No change needed |
| `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd` | Its Example 4 summary line is now stale (§1.3.2 correction) | Reported, not fixed this session — a future session should correct it |
| `NEWS.Rmd` / tutorial-article docs | New user-visible default rendering behavior | Owned by Slice 1 (and Slice 2 if it exists) DONE criteria, §4 |
| `a2interactive.Rmd` | If D8 picks (b)/(c), a new parameter on an already-documented function | Deferred debt, named explicitly (D7) — not same-session |
| Issue #145 itself | Its own `[2]`-`[7]` citations remain unresolved/unusable | `gh issue close 145` (Slice 1 DONE criteria) noting the convention is grounded independently (§1.1), not via those citations |

**Close-out checklists triggered** (`CLAUDE.md`): citation (#120, N/A), `_pkgdown.yml` (N/A),
NEWS.Rmd (Slice 1 + Slice 2), tutorial/article (Slice 2 only, if it exists — Slice 1 has no UI
change), lint (both slices), GitHub issue close-out (Slice 1), `a2interactive.Rmd` (deferred, not
same-session).

---

## 6. Here be dragons

1. **D2's mechanism is a paper argument this session, not yet empirically verified.** The
   reasoning in §3 D2 is internally consistent and directly responds to a real counter-example the
   adversarial review constructed against this document's *first* draft (a subtree reflection,
   since rejected) — but it has not been run against the live package. Slice 1's Pre-RED must build
   a minimal repro (matching the S465 rectilinear-waypoint precedent, `PROJECT_LEARNINGS.md`
   Learning 460) and specifically re-test the adversarial review's own wide-fanout fixture through
   the swap mechanism before committing to RED assertions.
2. **`docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`'s Example 4 is now stale**
   (§1.3.2) — flagged, not fixed here. A future session should correct it and check whether Examples
   1-3 make the same now-outdated claim.
3. **No audit was run this session of the real bundled 375-individual pedigree's 60 qualifying
   pairs for anything beyond "does a hard-coded x assertion exist."** The adversarial review's audit
   found none among the 24 that would newly become male-left, but a live `shinytest2` screenshot of
   at least one real multi-child qualifying family (not just the single-child GA204Z/8LKBV9 case) is
   still owed at Slice 1's own Phase 3E, to visually confirm D2's mechanism renders correctly, not
   merely that it doesn't crash.
4. **Resist scope creep toward D5's multi-mate case "since we're already touching this area."**
   §1.3.3 found no partial mechanism to extend; building the centered-flanking visual is a
   materially larger, separately-scoped feature. See D9 for whether to even file it.
5. **Vertical Slice Session gate (a) is only conditionally satisfied by this document.** Even after
   §9 ratifies D1-D9, dragon #1 above (D2's mechanism unverified live) means the "full layer set" a
   Strict-TDD RED phase needs is not fully fixed yet — Slice 1's own Pre-RED is a second, narrower
   planning step that could still change scope (e.g., discover the swap mechanism needs a
   correction, or discover a fixture beyond GA204Z/8LKBV9 needs updating). Do not treat this
   document alone as license to skip straight to RED without that Pre-RED step.
6. **Performance impact is negligible** (a value swap on 2 scalars per qualifying unit) and was not
   benchmarked — not expected to be a real risk, noted for completeness only.

---

## 7. Alternatives considered

| Alternative | Case for it | Why not chosen |
|---|---|---|
| Depend on kinship2's own `align.pedigree()` for alignment | Reuses a published, peer-referenced algorithm | Not a current dependency; kinship2's own algorithm doesn't enforce male-left either (§1.1), so adopting it would not even deliver the requested behavior, and a hard runtime dependency on an academic package for one tie-break rule is disproportionate |
| Modify `preferAnchor()` to prefer male as anchor (seam a) | Touches only one existing tie-break function | Doesn't reliably produce "male left" — anchor does not map to "right" (§1.3.2) — and risks flipping which ids win anchor for currently id-string-tied cases #143/#144's regression tests hardcode |
| Reflect the whole qualifying unit's local subtree about its own center (D2's first-draft mechanism) | Conceptually simple, "just mirror the family" | **Refuted by adversarial review via a constructed counter-example**: an asymmetric, wide multi-child fanout can collide exactly with an unrelated sibling elsewhere in the tree, because a reflection moves every descendant, not just the two parents |
| Build the full kinship2-style centered-flanking visual for the multi-mate case now | Matches the issue's own literal §1/§2 description and the S482 spike's original (now-corrected) recommendation | §1.3.3 found no existing partial mechanism; requires new machinery not evidenced as needed once the issue's "correct a bug" premise is established false (§1.1) — deferred to D5/D9 |
| Decline issue #145 entirely; close as "no defect, working as designed" | The audit already established there is no bug to fix, and the citations don't check out | The issue's underlying request (draw pedigrees in a convention many users expect) remains a legitimate, cheap-to-deliver nice-to-have for the simple-pair case even though the "bug" framing was wrong — a full decline discards that value for no real cost saving over D1-D9's narrow scope |

---

## 8. Provenance

**Research method.** This session ran a 3-agent parallel research pass (current-code mechanics;
house-style precedent from the #136/#142 design documents; cross-reference constraints against the
S480 audit, the kinship2-comparison-doc's Example 4, and #143/#144) via the `Workflow` tool, then
independently re-verified the most load-bearing claims (the GA204Z/8LKBV9 fixture's exact `x`/sex
values; `preferAnchor()`; the free-pass-leftmost line; the required-column and reserved-prefix
guards) against the live source directly, rather than trusting the agents' report at face value.

**Independent adversarial review.** A second, 3-agent pass then reviewed the resulting draft: one
agent re-derived every factual claim against live source/commits and constructed two working
counter-example fixtures (breaking the original D2 mechanism; probing #143/#144's actual `x`
coupling); one agent checked the design against #142/#143/#144/#154's own shipped contracts and
`SESSION_RUNNER.md`'s Vertical Slice gates; one agent checked house-style/completeness fidelity
against the #136/#142 reference documents. Findings incorporated into this revision: D2 was
redesigned from a subtree reflection (refuted) to a two-value swap (reasoned safe, still unverified
live — §6 dragon 1); the #143/#144 "gen-only" characterization was softened to match their own
shipped test diffs; D3 and D9 were promoted from silently-forced/embedded to genuine judgment calls;
D1's "no D5 direct child" exclusion gained its actual structural rationale; a stale claim in
`docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd` was surfaced (not fixed, out of
scope); several line-citation and checklist-coverage gaps were corrected throughout.

**Known gap.** No live `shinytest2` verification of any of this design's claims has happened yet —
by design, since this is a planning document. All empirical confidence above D2's swap-safety
argument (§3) is paper reasoning; Slice 1's Pre-RED is the first point at which any of it touches a
running R session.

---

## 9. Owner ratification record

- [x] **D1 — Scope: exactly the simple pair** (forced, not voted)
- [x] **D2 — Mechanism: swap the two real parents' own `x` values** (forced, not voted; empirical
      verification owed at Slice 1's own Pre-RED, §6 dragon 1)
- [x] **D3 — Direction: male left, female right**
- [x] **D4 — `"H"`/`"U"`/`NA` sex codes never trigger the swap** (forced, not voted)
- [x] **D5 — The multi-mate/crowding case is out of scope; today's behavior is unchanged** (forced,
      not voted)
- [x] **D6 — Testing convention: pin exact input row order in new fixtures** (forced/methodological,
      not voted)
- [x] **D7 — Documentation framing: new additive default, not a bug fix** (forced, not voted)
- [x] **D8 — Toggle shape: (b) a new `orderBySex = TRUE` parameter on `makePedigreeMatingLayout()`,
      default-on, no Shiny UI wiring** — Slice 2 (§4) is therefore **not created** by this
      ratification; a future session may open it separately if UI exposure is ever wanted.
- [x] **D9 — Follow-up issue for the multi-mate/crowding centered-flanking visual: do not file** —
      rely on this document's own D5/§1.3.3 finding being discoverable later if #145's history is
      revisited.

_Ratified via `AskUserQuestion`, S499 (2026-08-09) — D3/D8/D9 (the three genuine judgment calls) all
approved as this document's own recommended option, no changes requested. D1/D2/D4-D7 were not
separately voted, being forced by the evidence in §1-§2 (per the classification this session's own
adversarial review corrected — see §8 Provenance)._
