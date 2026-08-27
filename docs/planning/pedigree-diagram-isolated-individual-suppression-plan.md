# Plan — Suppress Fully-Isolated Individuals in `makePedigreeMatingLayout()` (entangled with issue #164)

**Status:** RATIFIED (2026-08-26, this session, S643). Both judgment-call decisions (Dragon 3, Dragon 4) were ratified via `AskUserQuestion`; the owner selected this document's own recommended option for both, with no changes requested. See §10 for the recorded outcome. This plan is ready for Phase 1 implementation in a future session.
**Session:** S643 (2026-08-26)
**Origin:** `BACKLOG.md` "Up Next" — found live 2026-08-26 (S641/S642), owner-directed via direct visual review of `kinship2-fidelity-validation.qmd`'s Track B full fixture. The owner has explicitly ruled `P5`'s inclusion an error ("`P5`... is erroneously included"), reversing S641's own Verdict text ("the more useful default, not a bug to reconcile away"). Entangled with [issue #164](https://github.com/rmsharp/nprcgenekeepr/issues/164) (`makePedigreeMatingLayout()` crashes outright on a pedigree where every individual has zero parent-child edges).
**Touches (planned, future session(s)):** `R/makePedigreeDiagramData.R` (`makePedigreeMatingLayout()`, new `.findIsolatedIds()`), `tests/testthat/test_makePedigreeMatingLayout.R`, `tests/testthat/test_comparePedigreeStructure.R` (2 blocks flip), `vignettes/articles/kinship2-fidelity-validation.qmd` (4 passages + 2 fig-alt captions + 1 table row), `data-raw/kinship2FidelityValidation.R` (regenerate Track B full images) — and, if §3 Dragon 4 is ratified in scope, `R/modPedigree.R` (Shiny messaging) + `tests/testthat/test_modPedigree.R` / `test-e2e-pedigree-module.R`.
**Does NOT touch:** the Table tab, CSV/data import, or any tab other than the Diagram tab — suppression is a diagram-rendering concept only, every loaded individual (isolated or not) stays fully visible and editable everywhere else. `.buildMatingUnitForest()`'s own internals are not modified under the recommended design (§3 Dragon 2) — it continues to receive an already-filtered `ped`.
**Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` — a rendering-contract/data-flow design question (where does filtering happen, what does the function's return contract promise its callers), not a pure UI layout question.

> **Scope.** Design (not implement) a single rule that (a) stops `makePedigreeMatingLayout()` from rendering a fully-isolated individual, matching kinship2's own `align.pedigree()` convention, and (b) resolves what happens when suppression would leave nothing to draw — the exact shape of issue #164's crash, reachable both from a whole-colony all-founder load and, a narrower trigger this session's research newly surfaced, from a user deliberately focal-trimming to one isolated individual. This document identifies the isolation predicate, the correct hook point, every test/doc site the fix touches, and separates decisions the evidence already forces from genuine judgment calls the owner must ratify (§10).

---

## 1. Context

### 1.1 What the triggering finding says

> **Source:** `BACKLOG.md` "Up Next", S641/S642 (2026-08-26); `vignettes/articles/kinship2-fidelity-validation.qmd` §Track B.
>
> The article's own published Track B "full" 16-subject fixture contains `P5`, an individual with no sire, no dam, never named as anyone's sire or dam. kinship2's own `align.pedigree()` never places `P5` on the plot grid — confirmed live via `al$nid`. `makePedigreeMatingLayout()` renders `P5` as a disconnected node regardless. S641's own structural comparator (`.comparePedigreeStructures()`) had a blind spot that let this reach publication as "structurally identical" — fixed S641 to at least *detect* the discrepancy, but the article framed the result as an acceptable, even preferable, difference. The owner overrode that framing directly this session.

### 1.2 What is already decided (do not re-litigate)

- **The isolation predicate.** All three design angles this session explored, independently, converged on the identical predicate: an individual is isolated iff `is.na(sire) & is.na(dam)` (no parent edge) **and** their id never appears in anyone else's `sire`/`dam` column (never a parent themselves, hence never in a mating union — this file's model only recognizes a union via a shared child). This is also exactly `BACKLOG.md`'s own pre-existing "narrow-rule scoping note": *"literally zero edges... NOT 'no mate and no children' alone, which would wrongly hide a real individual with known parents who simply hasn't been mated/bred yet."* Verified directly against `P5`'s own fixture row (§2.2) — no other row in the 16-subject Track B fixture references `P5` as a parent, confirming `P5` is genuinely zero-edge, not assumed from prose.
- **The predicate needs one addition beyond the three designs' first draft: exclude `twinRelations`-connected ids.** Found empirically (not theoretically) by patching and running the minimal-guard design against the live test suite: a twin whose own sire/dam are unknown and who has no children is structurally isolated by the parent/child predicate alone, but is genuinely connected via the `twinRelations` sidecar — `.buildTwinConnectorEdges()` still emits an edge referencing their id, producing a dangling edge to a suppressed node. `makePedigreeMatingLayout()` already takes `twinRelations` as a parameter (line 895), so this exclusion costs nothing structurally — it just must not be forgotten. Any future sidecar-edge type (there are none today besides twins) would need the identical treatment.
- **Issue #164's crash is a special case of the same predicate, not a separate bug.** `childEdges` (from `.buildMatingUnitForest()`) gets a row only when some individual has at least one known parent. If *every* row in `ped` is isolated, `childEdges` is 0-row — exactly the condition `data.frame(childEdges, dashes = FALSE, ...)` (lines 1172–1175) cannot handle (R's recycling rule fills short-to-long, never long-to-zero, so a 0-row frame can't absorb scalar columns). `nrow(childEdges) == 0` **iff** `all(isIsolated)` — proven by construction, not merely observed on the crash's own 2-row minimal repro. Whatever this design ships as the "would empty the diagram" fallback (§3 Dragon 3) is simultaneously the fix for #164.
- **A second, narrower trigger for the identical degenerate case exists and was not in the original `BACKLOG.md` scoping note.** `R/modPedigree.R`'s Focal Animals textarea (lines 65–70, 261–329) plus its "Trim pedigree based on focal animals" checkbox (lines 116–119, 366–378) lets a user type one isolated individual's id directly and trim to it — `getDescendantPedigree()`/`trimPedigree()` both resolve to just that one row, so `diagramLayout()` (lines 567–590) hands `makePedigreeMatingLayout()` a **1-row, 100%-isolated `ped`** with no whole-colony involvement at all. Any fallback design must treat "the trimmed/focal-filtered input is entirely composed of individuals the rule would drop" as a first-class case, not an edge case only reachable via a pathological whole-colony load.

### 1.3 What this session's research confirmed

Four parallel research agents read the actual source (not documentation) and, independently, three parallel design agents proposed concrete, evidence-grounded fixes — one of which was patched into the live file, run against the real fixtures and the full test suite, and reverted (working tree confirmed clean afterward, `git status --short`/`git diff --stat` both empty of `R/`/`tests/` changes). Full findings archived in this session's workflow transcript (`wf_7e5447f1-206`); the load-bearing facts are reproduced in §2.

---

## 2. Evidence-based inventory

### 2.1 `makePedigreeMatingLayout()` — flow and the two relevant lines

`R/makePedigreeDiagramData.R:893–1236`. Relevant steps, in order:

1. Validate `ped` columns (896–904); `edgeStyle <- match.arg(edgeStyle)` (905).
2. `forest <- .buildMatingUnitForest(ped)` (907) → `matingUnits`, `duplicates`, `childEdges`. This function **does not build node tables** — its own roxygen says so (330–332). It returns edge/unit structure only.
3. `pos <- .positionMatingUnitForest(ped, forest)` (908) → per-node `x`/`gen`. An isolated individual has no parent edge, lands in `founderIds`/`rootIds`, and gets a valid trivial one-node-root position today (585–809).
4. `realIds <- as.character(ped$id)` (**line 914**) — **every row of `ped`, unconditionally, becomes a node id.** This is the single point where "which ids become nodes" is decided; `realNodes` (1026–1036) is built directly from `realIds`, with no connectivity check anywhere in between.
5. `childEdgesOut <- data.frame(childEdges, dashes = FALSE, smooth.enabled = NA, smooth.type = NA_character_, smooth.roundness = NA_real_, stringsAsFactors = FALSE)` (**lines 1172–1175**) — issue #164's exact crash site. Reproduced directly against this code this session:
   ```
   Error in data.frame(childEdges, dashes = FALSE, smooth.enabled = NA,  :
     arguments imply differing number of rows: 0, 1
   ```

### 2.2 The existing 0-row-guard convention already used two blocks earlier — this fix's own house style

`mateEdges` (1096, 1128–1133) and `dupEdges` (1155, 1165–1170) already guard the identical shape of problem:

```r
mateEdges <- if (nrow(matingUnits) > 0L) {
  ...
} else {
  data.frame(from = character(), to = character(), dashes = logical(),
             color = character(), width = numeric(),
             smooth.enabled = logical(), smooth.type = character(),
             smooth.roundness = numeric(), stringsAsFactors = FALSE)
}
```

`childEdgesOut` is the one construction of the three that has no such guard. Whatever this plan ships mirrors this exact pattern — a `nrow(...) > 0L` branch with a hand-typed, pre-declared 0-row fallback — rather than inventing a new idiom.

### 2.3 `P5`'s row, confirmed directly (not assumed from the article's prose)

`tests/testthat/test_comparePedigreeStructure.R:693–711`, `.pedTrackBFixture()`:

```r
id   = c("P1", "P2", "P3", "P4", "P5", "P6", "C1", "C2", "C3", "C4", "C4a", "G3", "M1", "L1", "L2", "L3"),
sire = c(NA,   NA,   NA,   NA,   NA,   NA,  "P1", "P1", "P1", "P3", "C4",  NA,  "P1", "M1", "M1", "M1"),
dam  = c(NA,   NA,   NA,   NA,   NA,   NA,  "P2", "P2", "P2", "P4", "P6",  NA,  "P2", "G3", "G3", "G3"),
```

`P5` (5th position): `sire = NA`, `dam = NA`. Checked against every other row's `sire`/`dam` values (`P1, P2, P3, P4, P6, C4, M1, G3` are the only values used) — `P5` never appears. Confirmed zero-edge by direct data inspection.

### 2.4 Test call sites that break, and the ones that don't

Two `test_that()` blocks in `tests/testthat/test_comparePedigreeStructure.R` call `.pedTrackBFixture()` and assert the current (soon-to-be-wrong) behavior:

| Lines | Assertion today | Becomes, once `P5` is suppressed |
|---|---|---|
| 1009–1033 ("Block A") | `expect_false(result$identical)`; `expect_equal(result$individualsOnlyInB, "P5")` | `identical` → `TRUE`; `individualsOnlyInB` → `character(0)`. The `expect_false("P5" %in% pedK2$id[placedIdx])` assertion (about kinship2's own placement, independent of nprcgenekeepr) is unaffected and stays. |
| 1133–1144 ("Block B") | `expect_match(report, "P5", fixed = TRUE)` | `.formatStructuralDiscrepancy()` returns `NULL`/no discrepancy — needs rewriting to assert a clean report instead of erroring on a `NULL` match target. |

**Not affected** (confirmed by call-site grep, not assumed): the standalone `ISO` unit test (lines 740–768) and the two hand-built `.formatStructuralDiscrepancy()` unit tests (1073–1107) — neither calls `.pedTrackBFixture()`. Doc-comment prose at lines 684–692, 1010–1017, 1037–1050, 1134–1138 narrates the historical bug and goes stale (not a test failure) — should be reworded in the same implementing pass for accuracy.

An empirical full-suite run against the live "minimal-guard" patch (this session, reverted after) reported **failed: 6, error: 1, all confined to `test_comparePedigreeStructure.R`**, no other file regressed — consistent with this table (a single `test_that()` block with multiple `expect_*()` calls contributes multiple failed assertions). One unrelated pre-existing failure (`test_wordlist_coverage.R`, flags "comparator" — untouched by this fix) was also present and confirmed pre-existing via the same run.

### 2.5 Article passages that carry the now-wrong framing

`vignettes/articles/kinship2-fidelity-validation.qmd` — four distinct passages assert "more useful default / not a bug / not a defect / correctly-detected, not silent," not just the one obvious sentence:

| Lines | Passage (abridged) |
|---|---|
| 133–135 | *"kinship2's own `plot.pedigree()` did not plot subject `P5`... expected behavior for a disconnected singleton, not an error."* |
| 240–245 | *"Track B's full fixture is the one genuine, real, and expected discrepancy... For colony-management use, showing every declared individual... is the more useful default, not a bug to reconcile away."* (the primary instance) |
| 286–289 | *"This is a real difference in what gets drawn, not a defect in either package"* |
| 297–299 | *"Track B's full fixture is cleared as an *understood, correctly-detected* difference, not a silent one."* |

Plus: the Structural verification results table row (line 232, `Track B, full (16 subjects) | **No**`), and both Track B full fig-alt captions (lines 138, 140, describing "16 declared subjects including... `P5`"). All become factually wrong once the renderer changes and must be corrected in the same implementing session, per this project's own stale-docs convention (`CLAUDE.md` tutorial/article checklist). `data-raw/kinship2FidelityValidation.R`'s generated Track-B-full images (lines ~243–286) will change and need regenerating.

### 2.6 Blast-radius: every production call site, and the one that matters most

Single production (non-test, non-vignette) call site: `R/modPedigree.R:588`, inside the `diagramLayout` reactive (567–590), feeding the Diagram tab's `visNetwork` render. Everywhere else is the function's own test suite (`test_makePedigreeMatingLayout.R`, ~60 call sites), sibling structural tests (`test_resolveEdgeNodeCollisions.R`, `test_addRectilinearWaypoints.R`, `test_positionMatingUnitForest.R`), `test_comparePedigreeStructure.R` (§2.4), and non-executable references (roxygen `@examples`, doc prose, `vignettes/a2interactive.Rmd`, `data-raw/kinship2FidelityValidation.R`).

**The one call site that matters for design purposes is `R/modPedigree.R:588`,** because `R/modPedigree.R` also owns the Focal Animals / Trim-pedigree mechanism (§1.2) that can independently manufacture a 100%-isolated input. Three distinct mechanisms interact with focal selection there (textarea/file entry, click-to-navigate, and a `visOptions(nodesIdSelection=...)` search dropdown at lines 727–733 whose candidate list is sourced from `layout$nodes$id` — meaning it will automatically stop offering a suppressed id, with no separate code change needed, but also with no explanation shown to a user who goes looking for one).

---

## 3. Design decisions

Three full candidate designs were produced independently this session (transcripts in `wf_7e5447f1-206`): **minimal-guard** (patch `makePedigreeMatingLayout()` in two places, fallback = render everyone when 100% isolated), **principled-filter-stage** (new shared `.findIsolatedIds()` primitive, pre-filter `ped` at the top of the function, fallback = return nothing + a caller-facing signal), and **ux-first** (same data-flow shape as principled-filter-stage, with fully worked-out user-facing copy for Shiny and script-callable use). They agree on Dragons 1 and 2 below; they genuinely disagree on Dragon 3, which is this plan's central judgment call.

### Dragon 1 — the isolation predicate (RATIFIED by convergence, no disagreement across all 3 designs)

```r
isIsolated <- is.na(ped$sire) & is.na(ped$dam) &
  !(ped$id %in% ped$sire) & !(ped$id %in% ped$dam) &
  !(ped$id %in% twinConnectedIds)   # twinConnectedIds from twinRelations$id1/id2, §1.2
```

No opt-out parameter — this is a correctness fix (kinship2's own unconditional convention), matching this function's own existing posture on the consanguineous-mate marker (already unconditional, "not gated behind a UI toggle," `R/makePedigreeDiagramData.R:916–923`).

### Dragon 2 — where the fix hooks in (RECOMMENDED: pre-filter `ped`, new `.findIsolatedIds()` helper)

**Recommended, from the principled-filter-stage design:**

```r
## R/makePedigreeDiagramData.R, @noRd, alongside .buildMatingUnitForest()
.findIsolatedIds <- function(ped, twinRelations = NULL) {
  ids  <- as.character(ped$id)
  sire <- as.character(ped$sire)
  dam  <- as.character(ped$dam)
  hasParent <- (!is.na(sire) & nzchar(sire)) | (!is.na(dam) & nzchar(dam))
  isParent  <- ids %in% c(sire[!is.na(sire) & nzchar(sire)], dam[!is.na(dam) & nzchar(dam)])
  twinIds <- if (!is.null(twinRelations)) {
    c(as.character(twinRelations$id1), as.character(twinRelations$id2))
  } else character()
  ids[!hasParent & !isParent & !(ids %in% twinIds)]
}
```

Called once, at the very top of `makePedigreeMatingLayout()`, before `forest <- .buildMatingUnitForest(ped)`:

```r
isolatedIds <- .findIsolatedIds(ped, twinRelations)
ped <- ped[!ped$id %in% isolatedIds, , drop = FALSE]
```

**Why this beats filtering `realIds`/`realNodes` post-hoc (the minimal-guard design's approach):** pre-filtering `ped` means `.buildMatingUnitForest()` and `.positionMatingUnitForest()` — and therefore every downstream table (`matingUnits`, `duplicates`, `childEdges`, `pos`) — never see an isolated row at all. The alternative (filter only `realIds` at line 914, leave `pos` computed from the unfiltered `ped`) works, but leaves `.positionMatingUnitForest()` computing positions for ids that will never become nodes, and requires remembering to correspondingly exclude those ids from every downstream `x`/`y` lookup (1086–1088) rather than getting that exclusion for free. Pre-filtering also makes issue #164's fix a *consequence* of this same change (see Dragon 3), not a second, independently-implemented guard living in a different part of the function.

**Cost beyond the minimal-guard alternative:** one new `@noRd` function with its own dedicated unit tests (a small, cheap-to-test-exhaustively pure predicate: no-sire/no-dam/never-a-parent → isolated; has-sire-only; has-dam-only; a dangling parent reference — no own row in `ped` — still counts as *having* a parent edge, so a child of a trimmed-away parent is correctly not isolated; appears only as a parent, never as a child → not isolated; twin-connected → not isolated regardless of parent/child status). Judged worth it — see §7 for the full alternatives comparison.

**Defense-in-depth, cheap regardless of Dragon 3's outcome:** also wrap `childEdgesOut`'s construction (§2.2's pattern) in the same `nrow(childEdges) > 0L` guard. Under the recommended pre-filter design this becomes unreachable in the all-isolated case (Dragon 3 intercepts first) — but it costs one line, protects any other future path into a 0-row `childEdges`, and was independently identified as necessary by every design.

### Dragon 3 — what happens when suppression would empty the diagram (OPEN — the owner must ratify this)

This is simultaneously issue #164's fix and the single biggest behavioral fork between the three designs.

**Option 3A — render everyone, unfiltered, when `all(isIsolated)`** (minimal-guard design). Simple, one extra condition. But: it is an unprincipled carve-out from the very rule motivating this whole fix — "we suppress isolated individuals to match kinship2, except when literally everyone is isolated, in which case we show them all anyway." Concretely, it means a user who focal-trims to the single individual `P5` (§1.2's second trigger) **would see `P5` rendered alone** — the exact outcome the owner has just ruled an error, reproduced by construction whenever an isolated individual happens to be the entirety of what's being rendered. No caller-facing signal that suppression logic even ran (no `isolatedIds` field in this design), so `R/modPedigree.R` has no way to explain the all-founders-shown-disconnected result to a colony manager either.

**Option 3B — render nothing, return an explicit signal, let the caller message it** (principled-filter-stage / ux-first designs, converged independently). `nrow(ped) == 0L` after the pre-filter returns an early, fully-typed empty result (`nodes`/`edges` both 0-row, `duplicateToReal` empty) **plus** a new, always-populated return field `isolatedIds` (`character(0)` when nothing was suppressed). `R/modPedigree.R`'s `diagramLayout` reactive checks `nrow(layout$nodes) == 0L && length(layout$isolatedIds) > 0L` and shows an explicit message instead of a blank/crashed widget — worked-out copy from the ux-first design:
- Exactly one individual in the rendered set: *"`[ID]` has no recorded parents, mates, or offspring in this data, so there is no pedigree relationship to diagram."*
- More than one, all isolated (the whole-colony/#164 case): *"None of the N loaded individuals have any recorded parent, mate, or offspring relationships, so there is nothing to diagram. (See the Table tab.)"*

**Recommendation: 3B.** kinship2 itself would have nothing sensible to draw for an all-isolated input either — 3A's "show them all anyway" isn't actually more kinship2-faithful, it's an inconsistency the fix's own rationale doesn't support. 3B is also the only option that resolves the Focal-Animal-trim-to-one-isolated-individual case without silently reproducing the exact bug this plan exists to fix. 3A is smaller (no return-contract change, no Shiny messaging work), and is documented here as a legitimate lower-cost fallback if the owner prefers to defer messaging work to a later session — but it should be understood as re-introducing a narrower version of today's defect, not as a neutral simplification.

### Dragon 4 — user-facing messaging scope (RECOMMENDED: in scope, contingent on 3B)

If 3B is ratified, does this session's eventual implementation include the `R/modPedigree.R` UI messaging (banner for the "some isolated" case, empty-state message for the "all isolated" case), or does it stop at the `makePedigreeMatingLayout()` contract change and leave messaging for a follow-up session? The ux-first design's concrete proposal: a non-blocking `alert-info` banner (matching the existing `alert-warning` "N animals exceeds the cap" pattern at `R/modPedigree.R:505–515`) for the partial case — *"N individual(s) with no recorded parents, mates, or offspring are not shown in this diagram: id1, id2, id3 (see the Table tab to find them)"* — and the empty-state replacement text above for the all-isolated case, reusing the same `if/else` shape `output$pedigreeDiagramUI` (500–561) already has for the cap-exceeded case.

**Recommendation:** in scope, same implementation session/slice as Dragon 2/3 — `isolatedIds` existing on the return contract with no caller ever reading it is a half-finished fix, and per §1.2 the Focal-Animal-trim case makes silence here a real, reachable user-facing regression, not a hypothetical one.

### Dragon 5 — script-callable signal (RECOMMENDED, low stakes)

The ux-first design proposes `makePedigreeMatingLayout()` also emit a single `message()` (not `warning()` — expected, correct behavior) whenever `length(isolatedIds) > 0`, for console/script use outside Shiny. Low cost, `suppressMessages()`-able, doesn't interrupt a script. Recommended but not load-bearing — a future implementing session can drop it without affecting the rest of this design if it doesn't match this codebase's existing conventions for this class of signal (not independently verified this session).

---

## 4. Implementation plan — phases (one session each, unless pre-declared as a vertical slice)

Each phase below states completion criteria and verification commands per `SESSION_RUNNER.md` §Planning Sessions. A future session may execute all three as one pre-declared vertical slice (gate (a) satisfied by this document, per `SESSION_RUNNER.md` §Vertical Slice Sessions) with a checkpoint commit at each phase boundary — or run them as separate sessions. This project's own TDD contract (`CLAUDE.md`) governs each phase's own RED→GREEN→REFACTOR gates regardless of which grouping is chosen.

### Phase 1 — Core renderer fix

**Done looks like:** `.findIsolatedIds()` exists with its own unit tests (§3 Dragon 2's enumerated cases, including the twin exclusion and the dangling-parent-reference case); `makePedigreeMatingLayout()` pre-filters `ped` and, per the ratified Dragon 3 outcome, either falls back to unfiltered (3A) or returns an explicit empty result plus `isolatedIds` (3B); `childEdgesOut` gets the `nrow(childEdges) > 0L` guard regardless of outcome. Issue #164's own minimal repro (2-row all-founder `ped`) no longer crashes.
**Verification:** `devtools::test_file("tests/testthat/test_makePedigreeMatingLayout.R")` and the new `.findIsolatedIds()` test file green; issue #164's exact repro from its own issue text run manually and confirmed non-crashing; `lintr::lint_package()` 0 lints on touched files.

### Phase 2 — Test and article correction

**Done looks like:** `tests/testthat/test_comparePedigreeStructure.R`'s two blocks (§2.4) updated to assert the new, correct behavior; stale doc-comment prose (§2.4) reworded; all 4 `kinship2-fidelity-validation.qmd` passages + the results-table row + both fig-alt captions (§2.5) corrected to state nprcgenekeepr now matches kinship2 on Track B full; `data-raw/kinship2FidelityValidation.R` re-run and its generated Track-B-full images regenerated and confirmed changed (15 nodes, not 16).
**Verification:** full clean regression (`NOT_CRAN=true`, `load_all()` first, `test_dir(..., reporter="silent")`) 0 failed/0 error attributable to this phase's files; `quarto render` on the article clean; live re-run of `data-raw/kinship2FidelityValidation.R` confirmed printing the corrected structural comparison.

### Phase 3 — Shiny UX messaging (only if Dragon 4 is ratified in scope)

**Done looks like:** `output$pedigreeDiagramUI` (`R/modPedigree.R:500–561`) gains the empty-state branch and the partial-suppression `alert-info` banner, both reading `diagramLayout()$isolatedIds`, per §3 Dragon 4's worked copy.
**Verification:** new/updated `test_modPedigree.R` and `test-e2e-pedigree-module.R` coverage for both the partial- and all-isolated cases, including the Focal-Animal-trim-to-one-isolated-individual scenario (§1.2); live `shinytest2::AppDriver` smoke test (Phase 3E, `SESSION_RUNNER.md`) confirming the banner/message actually renders in the running app, not just that the reactive computes the right value.

---

## 5. Impact analysis

| System | Impact | Action required |
|---|---|---|
| `makePedigreeMatingLayout()` return contract | Gains `isolatedIds` field (3B only) | Every caller enumerating return fields (`.extractNprcStructure()` in `helper-comparePedigreeStructure.R`) should be checked for whether it needs to account for the new field — not expected to break (additive), but not independently verified this session |
| Diagram tab (`R/modPedigree.R`) | Isolated individuals no longer rendered; all-isolated selections show a message instead of a blank/crashed widget (3B) | Phase 3 UI change, plus e2e coverage |
| "Select by id" search dropdown (`R/modPedigree.R:729–733`) | Automatically stops offering suppressed ids (sourced from `layout$nodes$id`) | No code change needed; a consequence worth documenting, not a defect |
| Table tab, CSV import, every other tab | No change | Suppression is diagram-only |
| `tests/testthat/test_comparePedigreeStructure.R` | 2 blocks flip expected values | Phase 2 |
| `vignettes/articles/kinship2-fidelity-validation.qmd` | 4 passages + 1 table row + 2 captions become factually wrong | Phase 2 |
| `data-raw/kinship2FidelityValidation.R` | Generated images change | Phase 2, regenerate |
| Script-callable use (no Shiny) | Silent behavior change (fewer nodes rendered) unless Dragon 5's `message()` ships | Phase 1 (predicate) + optional Phase 1 addition (Dragon 5) |

---

## 6. Here be dragons (open questions, summarized)

1. **Dragon 3 — render-everyone (3A) vs. render-nothing-with-message (3B) when 100% isolated.** Recommendation: 3B. See §3.
2. **Dragon 4 — is Shiny messaging in this implementation's scope, or a follow-up session?** Recommendation: in scope. See §3.
3. **Dragon 5 — script-callable `message()` emission.** Recommendation: include, low stakes. See §3.
4. **Not resolved by this document:** whether `.extractNprcStructure()` (`helper-comparePedigreeStructure.R`) needs updating for the new `isolatedIds` field — flagged in §5, not independently verified. A future implementing session's Phase 1 RED step should check this directly rather than assume either way.

---

## 7. Alternatives considered

| Alternative | Pros | Cons | Why (recommendation) |
|---|---|---|---|
| **Minimal-guard** (post-hoc filter of `realIds`/`realNodes`, no new function, fallback = render everyone) | Smallest diff; no return-contract change; empirically validated against the live test suite this session | Two independent "isolated" computations (crash-guard's forest-derived mask vs. suppression's raw-`ped`-derived mask) that can drift apart; no caller-facing signal, so the Focal-Animal-trim-to-isolated case degrades from "crash" to "silent blank canvas" rather than being genuinely handled; 3A's fallback reproduces a narrower version of the very bug being fixed | Not recommended as the primary design, but its empirically-verified predicate and its 0-row `childEdgesOut` guard are reused directly (§2.2, §3 Dragon 1) |
| **Principled-filter-stage** (shared `.findIsolatedIds()`, pre-filter `ped`, explicit empty-result + `isolatedIds` signal) | One shared computation reused by both defects; caller gets a real signal to build messaging on; issue #164 becomes a consequence of the design rather than a second patch | One new function + its own tests; changes the return contract (additive) | **Recommended hook point (Dragon 2)** |
| **UX-first** (same data-flow as principled-filter-stage, plus fully worked Shiny/script-callable copy) | Concrete, ready-to-implement messaging; distinguishes single-focal-individual wording from whole-colony wording; reuses existing `alert-warning`/`alert-info` UI conventions | Adds Shiny-layer scope (Dragon 4) on top of the core fix | **Recommended messaging design (Dragon 4/5)**, contingent on 3B |

---

## 8. Close-out checklist mapping

Per `CLAUDE.md`'s project-specific checklists, a future implementing session must, in the same session it ships:
- Update `NEWS.Rmd` (plain-language entry, per the 2026-08-23 criterion — describe what colony managers see differently, not the predicate/algorithm).
- Update `vignettes/articles/pedigree-diagram.qmd` and/or `a2interactive.Rmd` if Phase 3 changes user-visible Diagram-tab behavior (tutorial/article checklist).
- Add `_pkgdown.yml` reference coverage only if any new function is exported (`.findIsolatedIds()` is `@noRd`/internal — not expected to need this, but confirm before closing out).
- Run `lintr::lint_package()` with the package loaded first (`pkgload::load_all()`), per the Learning 224 methodology this project's own CI just re-demonstrated the cost of skipping (S642/S643's `lint.yaml` finding, `CHANGELOG.md` 2026-08-26).
- Close [issue #164](https://github.com/rmsharp/nprcgenekeepr/issues/164) in the same session that ships Phase 1, citing the implementing commit (per the GitHub issue close-out checklist).

---

## 9. Provenance

Research and candidate designs produced by a 7-agent background workflow this session (run id `wf_7e5447f1-206`, 4 parallel "Understand" readers → 3 parallel "Design" proposals, ~520k subagent tokens, 71 tool calls, ~10.5 minutes wall-clock). One design agent (minimal-guard) empirically patched `R/makePedigreeDiagramData.R`, ran the real test suite and the issue #164 repro against the patch, and reverted — confirmed via `git status --short`/`git diff --stat` (both empty of `R/`/`tests/` changes) after the workflow returned, before this document was written. All line numbers and quoted code in §2 are from that research; verify against current `HEAD` before implementing, since this document does not itself change any source file.

---

## 10. Ratification status — forced vs. judgment-call decisions

**Forced by evidence (not judgment calls):** Dragon 1 (isolation predicate, including the twin exclusion) — all three independent designs converged, and the twin exclusion was empirically demonstrated necessary, not merely argued for. Dragon 2 (pre-filter `ped` via a shared `.findIsolatedIds()`) is presented as a strong recommendation with a clearly cheaper, empirically-validated alternative on record (§7) — a judgment call, but a lopsided one.

**Genuine judgment calls requiring owner ratification:** Dragon 3 (3A vs. 3B — the render-everyone vs. render-nothing-with-message fork) and, contingent on 3B, Dragon 4 (whether Shiny messaging ships in the same implementation as the core fix) and Dragon 5 (script-callable `message()`).

### Ratification outcome (2026-08-26, this session)

Presented via `AskUserQuestion`, 2 questions, both with this document's own recommendation as the first (labeled "Recommended") option:

- **Dragon 3: RATIFIED as 3B** — render nothing + explicit message when suppression would empty the diagram, not 3A's "render everyone anyway" fallback. Owner selected the recommended option, no changes requested.
- **Dragon 4: RATIFIED as "same implementation"** — the `R/modPedigree.R` Shiny messaging ships in the same implementation session/slice as the core renderer fix, not deferred to a follow-up session. Owner selected the recommended option, no changes requested.

Dragon 5 (script-callable `message()` emission) was not put to a separate ratification question — it was flagged in §3/§6 as low-stakes and non-load-bearing, left to the implementing session's own judgment.

**Consequence for Phase 3 (§4):** with Dragon 4 ratified as "same implementation," a future implementing session should treat Phases 1–3 as one pre-declared vertical-slice contract (gate (a) satisfied by this document) rather than three separate planning-then-implementing rounds — per-phase checkpoint commits and full verification at each boundary (`SESSION_RUNNER.md` §Vertical Slice Sessions gates (b)/(c)) still apply.
