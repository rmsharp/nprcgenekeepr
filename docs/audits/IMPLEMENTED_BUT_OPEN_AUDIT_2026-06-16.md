# Implemented-but-Open Audit — Open GitHub Issues

**Date:** 2026-06-16 · **Session:** 95 · **Branch:** `add-methodology`
**Workstream:** `docs/methodology/workstreams/AUDIT_WORKSTREAM.md`
**Auditor:** Claude (14-agent classify→adversarial-verify workflow; every "criteria met" call re-verified firsthand by the session)

---

## Audit Summary

- **Scope:** All **14 open** GitHub issues (`gh issue list --state open`), checked against the *current* code on `add-methodology` (HEAD `d06552ec`).
- **Motivation (Learning 90 follow-through):** Issue **#49** (gate the ORIP Reporting tab to ONPRC-only) was discovered in Session 94 to have been *fully implemented in Session 84* (commit `b980f998`) yet left OPEN for ~10 sessions — invisible to the handoff chain. Implemented-but-unclosed is a recurring repo pattern (#4, #33, #49 were all closed administratively in S90/S93/S94 after the work had shipped earlier). **The issue tracker lags the code.** This audit asks, for every remaining open issue: *is the work it requests already done but simply never closed?*
- **Criterion (single dimension — implementation status):**
  - **fully-implemented-open** — every acceptance criterion is met by present, *tested* code (a #49-style closeable candidate).
  - **partially-implemented** — some but not all criteria have landed.
  - **not-implemented** — no implementation exists; the cited TODO/hack is still present or the feature is absent.
  - **ambiguous** — the issue has no single concrete checkable deliverable (open research question, standing inventory).
  - **policy-hold** — on the standing do-not-close list (#45/#1/#5/#9); real status is still reported, but closure is the owner's call.
- **Coverage:** **14 of 14 (100%).** No issue skipped.
- **Method:** one read-only classifier agent per issue read the cited code (searching by *content* — `grep`/`git log -S`/`git log --grep` — not stale line numbers), restated the acceptance criteria, and classified. Any `fully-implemented-open` close candidate would have been handed to an independent skeptic agent told to **refute** the close (default to refuted on uncertainty). The session then re-verified every "criteria appear met" finding firsthand against the source and GitHub.

### Headline result

| Status | Count | Issues |
|---|---|---|
| **fully-implemented-open → close candidate** | **0** | — (the Learning 90 concern is NOT borne out) |
| **owner-judgment → surface, do not auto-close** | **2** | #45 (umbrella; own criteria met), #37 (inventory; actionable surface resolved) |
| **partially-implemented (incl. policy-hold)** | **3** | #1, #5, #9 — genuinely partial, correctly open |
| **not-implemented → correctly open** | **9** | #2, #10, #11, #12, #13, #28, #29, #36, #46 |

**Bottom line: there is no second #49.** No open issue is a fully-implemented-but-unclosed close candidate. Zero candidates survived to the verification stage (none reached it). The two owner-judgment items below are *not* #49-style auto-closes — each turns on a deliberate owner decision, not a verifiable "the work shipped" fact.

---

## Findings

### Owner-judgment items (surfaced, NOT auto-close candidates)

#### Finding #1 — Issue #45: umbrella's own 4 acceptance criteria appear MET

- **Severity:** Owner-judgment (policy-hold issue)
- **Classification:** policy-hold (real status: own criteria met; intentionally linked sub-task open)
- **Evidence (re-verified firsthand this session):**
  - **AC1** (no parallel parameter) — `R/getPotentialParents.R:31` signature is unchanged: `getPotentialParents <- function(ped, minParentAge, maxGestationalPeriod)`. The dam-exclusion window reuses the same scalar applied sire-side. ✓
  - **AC2** (dam selection responds to `maxGestationalPeriod`) — `tests/testthat/test_getPotentialParents.R:171-190` asserts `d165 ≠ d210` and `d210 ⊂ d165`; `:131-170` asserts `DAM_IN` excluded at 210 d, retained at 180 d. ✓
  - **AC3** (the `:92-93` "hack" TODO resolved, documented) — `grep -niE "hack|TODO" R/getPotentialParents.R` → no matches; replaced by a documented gestation-derived window. ✓
  - **AC4** (a written data-model spec recorded on #28) — recorded + ratified on #28 (commits `78009fd3`, `4cb5a63e`). ✓
  - Sub-task **#31 CLOSED** (`2026-06-14`); wire-in **#48 CLOSED**; consumer wired at `R/modPotentialParents.R`.
- **Why not auto-close:** #45 is on the do-not-close list and is an *umbrella* that deliberately links sub-task **#28** (still OPEN, gated on #11/#12/#37/#46). AC4 scopes #28 to a *written spec* (done), not implementation. The umbrella's own criteria read as satisfied, but whether the umbrella closes while #28 remains deferred is the owner's call.
- **Recommendation:** Present to owner: "all four written ACs of #45 are met; close the umbrella, or keep it open as the tracking parent of deferred #28?" (This matches S94's standing note verbatim.)

#### Finding #2 — Issue #37: actionable wire-in surface is resolved; the rest is intended steady-state

- **Severity:** Owner-judgment
- **Classification:** ambiguous (no single checkable deliverable — a standing inventory, not a feature)
- **Evidence (re-verified firsthand this session):**
  - #37 is an owner-maintained inventory of exported functions not reachable from `runModularApp()`. Its S78 triage assigned: **2 wire-in, 37 keep-as-public-API, 0 retire.**
  - Both wire-ins are **shipped and their tracking issues CLOSED:** ORIP module — `R/appUI.R:181` / `R/appServer.R:286` (#47 **CLOSED**); `getPotentialParents` surface — `R/appUI.R:200` / `R/appServer.R:302` (#48 **CLOSED**).
  - The 37 keep-as-public-API exports are *intentionally* unwired (the explicit owner decision, not a backlog).
- **Why not auto-close:** There is no concrete artifact whose existence means "#37 is done." Closing it means the owner choosing to *retire the standing inventory*. The owner has repeatedly chosen to keep it open as living bookkeeping (S65, S78).
- **Recommendation:** Present to owner: "the only actionable items #37 surfaced (#47, #48) are both shipped and closed; the remaining 37 are keep-as-public-API by your decision — retire the inventory issue, or keep it open as the catalog?"

### Partially-implemented (policy-hold — correctly open)

#### Finding #3 — Issue #9 (policy-hold): owner's specified remedy not wired into the report path
- **Location:** `R/reportGV.R:66-158`, `R/rankSubjects.R:38-49`, `R/modGeneticValue.R:237-242`
- **Status:** The "different classification" remedy (`noParentage` bucket → value `"Undetermined"`, rank `NA`) exists — but that shipped under the *separate, closed* issue **#8** (animals missing **both** parents). The owner's clarifying comment narrowed #9 to *substituting sex-specific breeding-age mean kinship for the missing parent*; that is implemented **nowhere** in the GV report path. A Monte-Carlo kinship-imputation toolkit exists with tests (`createSimKinships`/`makeSimPed`/`cumulateSimKinships`/…) but is **not invoked** by `reportGV()`/`modGeneticValue`/`appServer`. Sire/Dam result columns (remedy #3) are absent.
- **Recommendation:** Keep open. To close, owner must decide whether #8's classification + the standalone (unwired) imputation utilities satisfy #9, or whether integration into `reportGV` and/or Sire/Dam columns is required.

#### Finding #4 — Issue #5 (policy-hold): 1 of 4 criteria met (error reporting); 3 feedback affordances absent
- **Location:** `R/modInput.R:225,309-356`, `R/getFocalAnimalPed.R:59-67`
- **Status:** Criterion 4 (errors → Error tab) is **implemented and tested** (`getFocalAnimalPed` → `storedErrorLst` → dynamic Error tab; `test_getFocalAnimalPed.R:244-258`, `test_modInput.R:1006-1032`; commit `bb7f2be6`). Criteria 1–3 (forewarn the query may take seconds / completion notification / optional pre-flight connection check) are **not** implemented on the LabKey path — `withProgress`/`incProgress` are imported in `modInput.R:225` but never called there (live usage is only in the breeding-groups and genetic-value modules).
- **Recommendation:** Keep open. Narrow the issue to the three missing feedback affordances.

#### Finding #5 — Issue #1 (policy-hold): ID-clear works; file-browser clear (the owner's explicit caveat) does not
- **Location:** `R/modPedigree.R:84-88,205-212,226-243`
- **Status:** The "Clear Focal Animals" control empties the ID list and is **tested** (`test_modPedigree.R:377-417`, passing). But the owner's 2020 caveat — that clearing must also reset the file-browser (`input$focalAnimalFile`) — is **unresolved**: the clear branch returns early without clearing the `fileInput`, so the prior upload's filename/datapath persists and re-reads on the next update. No `shinyjs::reset()`; no test for the file-clear behavior.
- **Recommendation:** Keep open. The remaining work is the file-browser reset + a test.

### Not-implemented (correctly open — no action)

| # | Issue | Why genuinely open (firsthand grep + `git log`) |
|---|---|---|
| #2 | Evidence-based GVA iteration-count advice | The `guIter` knob exists (`reportGV.R`/`calcGU.R`/`geneDrop.R`), but none of the 3 deliverables (reproducibility definition, automated needed-iteration finder, variance-vs-iterations advice). `ColonyManagerTutorial.Rmd:457-464` carries the *verbatim request* as a still-open `<!-- TODO -->` and disclaims having done the study. |
| #10 | Predict future GVA via breeding simulation | No function consumes a group configuration to project future offspring + recompute GVA. The only "simulation" code (`createSimKinships`/`makeSimPed`) is a Monte-Carlo for *unknown existing* parents — a different feature. |
| #11 | Pull demographic data from Oracle | Zero Oracle/ROracle/DBI/odbc code; `getDemographics()` is a LabKey (`Rlabkey`) wrapper. Only "Oracle" mention is the 2020 user request in `meeting_notes.Rmd:52`. |
| #12 | Pull data from ARMS | Zero ARMS code/export/test. Only mention is `meeting_notes.Rmd:51` ("ARMS connectivity" as a long-term plan). Repeatedly recorded as an "empty stub." |
| #13 | Assign kinship from outside information | `kinship()` (`R/kinship.R:69-111`) builds the matrix purely from pedigree; no parameter/logic to inject external coefficients. Empty issue body. |
| #28 | Colocation-based parent ID | Owner pinned a 7-point acceptance list; **none** implemented (no `location` arg, no colocation entity, no `exampleLocations`, no LabKey wrapper). Only design/spec groomed; explicitly gated on #11/#12/#37/#46. |
| #29 | Rename `makeGrpNum`→`makeGroupNum` | `makeGroupNum` appears nowhere in `R/`/`tests/`/`man/`; every reference is still `makeGrpNum`. The 2026-06-12 staleness audit already marked it "keep open." (A rename — needs a cross-reference grep inventory before any execution.) |
| #36 | Chimpanzee age-pyramid settings | The exact TODO the issue quotes is still verbatim at `R/agePyramidPlot.R:60-63`; no `species` parameter, no PT/RM switch, no tests. |
| #46 | Species as a first-class attribute | `species` not in `getPossibleCols()` (`R/getPossibleCols.R:48-55`) — survives only as an unused `novelCol` (`qcStudbook.R:282-283`); `getPotentialParents` still takes a scalar `maxGestationalPeriod`; no postnatal co-housing window; zero species tests. |

---

## Items Audited (coverage map)

| Issue | Classification | Closeable? | Verified firsthand by session? |
|---|---|---|---|
| #46 | not-implemented | No | — (negative; agent grep + prior audit corroborated) |
| #45 | policy-hold (criteria met) | No (owner-judgment) | **Yes** — signature, no-hack, AC2 test, #31/#48 state |
| #37 | ambiguous (surface resolved) | No (owner-judgment) | **Yes** — #47/#48 state, app wiring |
| #36 | not-implemented | No | — |
| #29 | not-implemented | No | — |
| #28 | not-implemented | No | — |
| #13 | not-implemented | No | — |
| #12 | not-implemented | No | — |
| #11 | not-implemented | No | — |
| #10 | not-implemented | No | — |
| #9  | policy-hold (partial) | No | — |
| #5  | policy-hold (partial) | No | — |
| #2  | not-implemented | No | — |
| #1  | policy-hold (partial) | No | — |

**14 of 14 audited (100%).** The two findings carrying a "criteria appear met" claim (#45, #37) were re-verified firsthand; the 9 not-implemented findings rest on exhaustive negative `grep` + `git log -S`/`--grep` evidence (several independently corroborated by the 2026-06-12 staleness audit), where a false "not done" merely keeps an issue correctly open (low risk).

---

## Structural Observations

1. **The implemented-but-unclosed backlog is now drained.** #4, #33, #49 (and earlier #34, #14, #8, #47, #48, #31) have all been closed as their work was confirmed shipped. This audit finds **no remaining** #49-style ghost. Learning 90's risk — a hidden done-but-open issue mis-scoped as "needs work" — currently has zero instances.
2. **The open backlog has cleanly bifurcated** into (a) genuinely-unbuilt large features blocked on external systems (#10/#11/#12/#13/#28 — Oracle/ARMS/colocation data) or open methodology (#2), and (b) small well-scoped enhancements (#29 rename, #36 chimp pyramid, #46 species). None is secretly done.
3. **Two "tracking" issues read as administratively closeable but are owner-judgment by design:** #45 (umbrella whose own ACs are met but which parents deferred #28) and #37 (inventory whose actionable wire-ins all shipped). These are the *closest* things to a close candidate, but neither is a fact-based auto-close — both turn on whether the owner wants to retire a tracking artifact while its intended steady-state (deferred sub-task / keep-as-public-API exports) persists.
4. **Policy-hold issues #1/#5/#9 are each genuinely partial** — a real first increment shipped and tested, with a specific owner-named criterion still unmet. They are correctly open; each could be *narrowed* to its remaining slice rather than left as the original broad request.

---

## Comparison with Prior Audit (Session 62, 2026-06-12)

| Metric | S62 (2026-06-12) | S95 (2026-06-16) | Trend |
|---|---|---|---|
| Open issues audited | 21 | 14 | ↓ 7 (closed since) |
| Close candidates (stale/implemented-but-open) | 2 (#14, #8) | **0** | ↓ backlog drained |
| Partial → keep open | 5 (#1, #5, #9, #35, #37) | 3 (#1, #5, #9) | #35 closed; #37 now "ambiguous/owner-judgment" |
| Not-implemented / genuinely open | rest | 9 | stable core (external-system + methodology features) |
| Coverage | 21/21 (100%) | 14/14 (100%) | maintained |

- **Consistency check:** S62's PARTIAL set {#1, #5, #9, #37} re-confirmed firsthand here (#35 has since closed). No issue regressed or flipped classification in a way that contradicts S62 — the two audits agree on every issue both examined. This cross-validation raises confidence in the "0 close candidates" headline.
- **What changed:** S62's 2 close candidates (#14, #8) were both closed; the #49 ghost that motivated *this* audit was a *new* discovery (S94) that S62 had marked correctly (#49 did not exist as an open issue at S62 — it was opened later, S84). The pattern S62 named ("the tracker lags the code") held again with #49, but is now fully reconciled.

---

## Recommendations

1. **No administrative closes are owed.** Unlike the #4/#33/#49 sequence, there is no open issue whose work has demonstrably shipped and merely needs closing on confirmation. Do not look for one — this audit is the firsthand evidence it does not exist.
2. **Owner decision on two tracking issues (optional, low-stakes):**
   - **#45** — close the umbrella now that its four written ACs are met, or keep it open as the parent of deferred #28? (Recommend: keep open until #28 lands, since the umbrella's stated purpose is to track that work — but it is a clean close if you prefer to track #28 standalone.)
   - **#37** — retire the standing inventory now that its actionable wire-ins (#47, #48) are shipped, or keep it as the living catalog of keep-as-public-API exports? (Recommend: owner's preference; no code action either way.)
3. **Structural fix to prevent the next #49:** adopt Learning 90 as a handoff rule — any session that *implements but leaves an issue OPEN* must carry "impl SXX, OPEN pending close" in its handoff until the issue closes. (#49 went invisible precisely because no handoff recorded "implemented S84, not yet closed.") This audit is cheaper to *not need* than to run.
4. **Next actionable engineering work** (owner's pick, all genuinely unbuilt): the small well-scoped enhancements #36 (chimp pyramid) or #29 (rename — grep inventory first) are the lowest-lift TDD candidates; #46 (species first-class) is the keystone unblocking #28's multi-species path.
