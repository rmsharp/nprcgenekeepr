# Issue #155 Plan — Fix `markerParentageLikelihood()`'s Auto-Detect Candidate Lookup for a Recorded-but-Wrong Parent

**Status:** RATIFIED (2026-08-10, via `AskUserQuestion` — see §6). Design/planning only this
session; Slice implementation is a separate future session.
**Session:** S501 (2026-08-10).
**Origin:** GitHub issue [#155](https://github.com/rmsharp/nprcgenekeepr/issues/155), filed S498
(2026-08-09) during issue #147 Slice 2's own Phase 3E live smoke test.
**Workstream:** `ARCHITECTURE_WORKSTREAM.md` (owner-picked via `AskUserQuestion` over the literal
`DESIGN_WORKSTREAM.md` mapping, matching the #136/#142/#145 precedent for a shared-function-contract
decision).
**Touches:** `R/markerParentageLikelihood.R` only (one new internal helper, two call-site edits).
**Does NOT touch:** `R/getPotentialParents.R` (zero lines — the design's own central property, §3
D1), `R/modPotentialParents.R`, `R/modMarkerGenetics.R`, `R/markerParentageExclusion.R`.

> **Scope.** A single-file, internal-behavior-only bug fix: `markerParentageLikelihood()`'s
> auto-detect and explicit-`id`/`role` candidate lookup both currently return zero candidates
> whenever the flagged animal's recorded parent is present-but-wrong (both pedigree slots
> non-`NA`), because they source candidates from `getPotentialParents()`, which only searches for
> animals with an actually-missing (`NA`) slot. This plan fixes the candidate-sourcing gap without
> changing `getPotentialParents()`'s own contract or `markerParentageLikelihood()`'s exported
> signature/return shape.

## 1. Context

### 1.1 What issue #155 says (summarized; full text in the GitHub issue)

Found during issue #147 Slice 2's own Phase 3E live smoke test (Session 498, 2026-08-09).
`markerParentageLikelihood()`'s auto-detect default (`id`/`role`/`candidates` all `NULL`) sources
each flagged pair's candidate list via `getPotentialParents(pedigree)`. `getPotentialParents()`
only ever builds a candidate list for an animal in its internal `pUnknown` set — defined as
`ped[fromCenter & (is.na(sire) | is.na(dam)), ]`, i.e. an animal with **at least one missing**
parent slot. `markerParentageExclusion()` flags an animal whose recorded parent is **present but
Mendelian-inconsistent** — by definition both slots are non-`NA` (an `NA` slot has nothing to
compare against genotypes and is never flagged). So the exact case issue #147 exists to address — a
wrongly-recorded, not missing, parent — never appears in `pUnknown`, and auto-detect silently
returns zero candidates. In practice most real flagged pairs have BOTH slots recorded (one right,
one wrong), so this is the common case, not an edge case. Confirmed directly in the issue (not
inferred): a 3-individual fixture with animal `C`'s dam correct and sire falsely recorded produces
`character(0)` candidates via the real, non-mocked `getPotentialParents()`; the identical fixture
with the dam ALSO unrecorded correctly surfaces the true candidate. Every existing automated test of
this interaction mocks `getPotentialParents()`, so the gap was never exercised until a live,
non-mocked smoke test.

### 1.2 What is already decided (do not re-litigate)

- `getPotentialParents()`'s own demographic-eligibility engine (breeding-age floor, gestation
  window, proven-breeder preference, presence-at-conception/birth) is correct and validated —
  issue #155 is a **candidate-sourcing** gap (which animals get a candidate search run at all), not
  a defect in that engine. Nothing about the engine's own filtering logic is in question.
- D8 of `docs/planning/issue147-likelihood-parentage-assignment-plan.md` (auto-detect defaults to
  `getPotentialParents(pedigree)`'s own `sires`/`dams` list) stands; this plan fixes what pedigree
  object that call effectively searches against, not the fact that it's `getPotentialParents()`
  being called at all.
- `markerParentageExclusion()` itself, and the LOD-scoring math in `scoreOnePair()`, are unaffected
  and untouched by this plan (confirmed by direct read, §2 below) — this is purely a
  candidate-sourcing fix upstream of the scoring step.

### 1.3 What this session's research confirmed

- **Three real (non-doc, non-test) call sites of `getPotentialParents()` exist in the whole
  package, confirmed via `grep -rn "getPotentialParents(" R/*.R`**: `R/markerParentageLikelihood.R:285`
  (auto-detect) and `:298` (explicit `id`/`role`/`candidates = NULL`) — both **in scope** for this
  fix — plus `R/modPotentialParents.R:273` (the separate, general-purpose "Potential Parents" Shiny
  tab, unrelated to marker genetics) — **out of scope**, untouched (§5).
- **The explicit `id`/`role`/`candidates = NULL` branch (`markerParentageLikelihood.R:298`) has the
  identical bug**, not just the auto-detect path issue #155's own text names. It is untested against
  a real (non-mocked) `getPotentialParents()` today (confirmed by reading every test file below) and
  is part of the same exported function's documented contract (its own roxygen already describes
  this branch as for "a curator's proactive check on an animal that is not (yet) flagged" — exactly
  a recorded-but-not-missing-parent scenario).
- **`modMarkerGenetics.R`'s Candidate Parent Assignment tab only ever calls
  `markerParentageLikelihood(gmat, ped)`** (`:263`, auto-detect, no `id`/`role`) — the Shiny-UI-visible
  half of this bug is entirely the auto-detect path; the explicit-branch half is currently
  script-callable only.
- **Every existing test of this interaction mocks `getPotentialParents()`** entirely
  (`test_markerParentageLikelihood.R:305,334,356`; `test_modMarkerGenetics.R:342`) — none exercises
  the real function against a fixture with the demographic columns (`birth`/`sex`/`exit`/
  `fromCenter`) it requires. `test_modMarkerGenetics.R:322-326`'s own comment states the mock exists
  *because* "this minimal fixture's pedigree has none of `getPotentialParents()`'s own required
  demographic columns" — the shipped test suite's own fixture shape is why this gap was invisible
  until a live smoke test.
- **Live-verified, twice, against two independent prototype fixes** (§3, not just read from source)
  using a 6-individual fixture reconstructing issue #155's own repro shape (animal `C`: dam correct,
  sire falsely recorded; animal `D`: a genuinely missing-parent control to confirm no regression):
  today's code returns zero candidates for `C` (bug reproduced); both prototypes correctly surface
  `C`'s true sire as a candidate, and leave `D`'s own candidate lists byte-identical to before.

---

## 2. Evidence-based inventory

### 2.1 `getPotentialParents()`'s `pUnknown` filter — the exact gate at issue

`R/getPotentialParents.R:111-113` (the two comment lines immediately above, `:109-110`, are
explanatory prose, not code):
```r
pUnknown <- ped[fromCenter &
  (is.na(ped$sire) | is.na(ped$dam)), ]
pUnknown <- pUnknown[!is.na(pUnknown$id), ]
```
Every row surviving this filter gets **both** a `sires` and a `dams` candidate list computed
unconditionally (`:150-199`), regardless of which specific slot was actually `NA` — confirmed by
direct read: there is no per-row branching on *which* slot is missing, only whether *at least one*
is. This matters for the fix design (§3 D1): including an id in `pUnknown` for one flagged role
automatically yields a usable candidate list for the *other* role too, at no extra cost, exactly
matching the function's existing behavior for a genuinely-one-slot-missing animal.

### 2.2 `markerParentageLikelihood()`'s two `getPotentialParents()` call sites

`R/markerParentageLikelihood.R:279-301` (both branches reproduced in full in §1.3 above; not
re-quoted here). Auto-detect (`:279-293`) computes `flags` from `markerParentageExclusion()`
**first**, using the real, unmodified `pedigree` (required — the exclusion check needs the real
recorded parent to compare against genotypes), then calls `getPotentialParents(pedigree)` once
(`:285`, outside the per-flag loop) and looks up each flagged pair's candidates via
`lookupCandidates()`. The explicit branch (`:294-299`) calls `getPotentialParents(pedigree)` inline
when `candidates` is `NULL`. **Both calls pass `pedigree` — the function's own, real, unmodified
input — with no per-flag pedigree transformation of any kind.** This is the exact mechanism gap:
nothing between "know which (id, role) needs a candidate search" and "ask `getPotentialParents()`
for one" ever tells `getPotentialParents()` to search for that particular id.

### 2.3 Required demographic columns — confirmed, not assumed

`getPotentialParents()` requires `id`/`sire`/`dam`/`sex`/`birth`/`exit`/`fromCenter` (and optionally
`species`) on its `ped` argument (§ full read, `R/getPotentialParents.R:64-213`).
`markerParentageLikelihood()`'s own roxygen (`:94-96`) only documents `pedigree` as needing "(at
least) columns `id`, `sire`, and `dam`" — silent on the additional columns its own internal
`getPotentialParents()` call actually requires whenever a fixture lacks them (confirmed
`getPotentialParents()` returns `NULL` outright when `fromCenter` is absent, `:88-91`, cascading to
`lookupCandidates()`'s `character(0L)` fallback, `:181-183` — a fail-soft, not a crash — but
silently, which is exactly how issue #155's underlying gap escaped every existing mocked test).
**Not fixed by this plan** (a pre-existing documentation gap, orthogonal to the candidate-sourcing
bug) — flagged here for a future session, not actioned (`PROJECT_LEARNINGS.md` Learning 382's
"report, don't fix mid-session" precedent).

### 2.4 Live verification (this session's Pre-RED-style empirical check)

A 6-individual scratch fixture (`SireTrue`/`SireWrong`/`Dam`/`C`/`D`/`DamD`, matching issue #155's
own "dam correct, sire falsely recorded" shape plus a control) confirmed, against the real, unmodified
`getPotentialParents()`:

- **Today:** `C` (both slots recorded) returns no `pUnknown` entry at all — zero candidates,
  reproducing the bug exactly as described. `D` (dam missing) correctly returns candidates.
- **Prototype A** (§3 Alternative B below — add a `forceIncludeIds` parameter to
  `getPotentialParents()`): `C` now returns candidate sires including `SireTrue` (the true sire) and
  `SireWrong` (the flagged/wrong recorded sire, included harmlessly — §3 D3). `D`'s own result is
  byte-identical to before (`identical()` confirmed).
- **Prototype B — the recommended shadow-pedigree approach (§3 D1):** blanking only `C`'s `sire`
  slot in a **local copy** of the pedigree before calling the completely **unmodified**
  `getPotentialParents()` produces an *identical* candidate set to Prototype A (`identical()`
  confirmed on both `sires` and `dams`), while leaving `D`'s result byte-identical and
  `getPotentialParents()`'s own formals (`ped`, `minSireAge`, `minDamAge`, `minParentAge`,
  `maxGestationalPeriod`, `gestationTable`) completely unchanged.

---

## 3. Design decisions

### D1 — Fix mechanism: a local "shadow pedigree" that blanks exactly the flagged slot(s), passed only to the internal `getPotentialParents()` call. Recommended; requires ratification (§6 Q1) against the viable alternative in §4.

Add one new internal (`.`-prefixed, non-exported), well-tested helper in `R/markerParentageLikelihood.R`:

```r
.markerFlaggedSlotPedigree <- function(pedigree, ids, roles) {
  ## Returns a COPY of pedigree with each (id, role) pair's own sire/dam slot
  ## set to NA, so getPotentialParents()'s existing pUnknown filter naturally
  ## includes that id -- reusing its full demographic-eligibility engine
  ## unmodified. Does not mutate the caller's pedigree (plain R copy-on-modify
  ## `[<-` assignment). A duplicated pedigree$id is left un-blanked (mirrors
  ## scoreOnePair()'s own defensive "nrow(pedRow) == 1L" pattern, :201, for
  ## an ambiguous id match) -- which row would be "the" flagged animal is
  ## undefined, so this falls through to the same fail-soft, zero-candidates
  ## posture as an id genuinely absent from pedigree, rather than silently
  ## blanking every matching row.
  unambiguous <- names(which(table(pedigree$id) == 1L))
  sireIds <- unique(ids[roles == "sire"])
  sireIds <- sireIds[sireIds %in% unambiguous]
  damIds  <- unique(ids[roles == "dam"])
  damIds  <- damIds[damIds %in% unambiguous]
  if (length(sireIds) > 0L) pedigree$sire[pedigree$id %in% sireIds] <- NA
  if (length(damIds)  > 0L) pedigree$dam[pedigree$id %in% damIds]   <- NA
  pedigree
}
```

Wire it into both existing call sites:
- Auto-detect (`:285`): `ppList <- getPotentialParents(.markerFlaggedSlotPedigree(pedigree, flags$id, flags$role))`.
- Explicit branch (`:298`): `getPotentialParents(.markerFlaggedSlotPedigree(pedigree, id, role))` in place of `getPotentialParents(pedigree)`.

**Why this is the smallest correct fix:** `getPotentialParents()` is a shared, independently-tested,
independently-consumed function (§2.2's `modPotentialParents.R` "Potential Parents" tab) — this
mechanism requires **zero changes to it**: no new parameter, no new branch, no risk to its own 40
existing assertions (18 `test_that` blocks, `tests/testthat/test_getPotentialParents.R`) or its
other caller. The full demographic-eligibility engine (breeding-age floor,
gestation window, proven-breeder preference — none of which this plan should re-derive) is reused
at 100% fidelity, because `getPotentialParents()` is called completely unmodified against a pedigree
object that merely *looks like* a genuinely-missing-parent case to it. This directly matches this
project's own established reuse-over-duplication discipline (`docs/planning/
issue147-likelihood-parentage-assignment-plan.md` D7: "reuse/generalize... rather than a second,
independently written... routine — a duplication/divergence risk").

**Ordering is safe:** `flags` (used to build the shadow copy) is computed from the REAL,
unmodified `pedigree` (needed to detect Mendelian inconsistency in the first place) *before* the
shadow copy is built — the existing code's own ordering already does this; no change needed. The
shadow copy is local to the `getPotentialParents()` call; `scoreOnePair()`'s own trio-conditioning
read of `pedigree[pedigree$id == focalId, ]` (`:201`) — which needs the REAL recorded other-parent,
not a blanked one — continues to use the untouched `pedigree` parameter, unaffected. The function's
own "never mutates its pedigree input" contract (D8/§7 Dragon 12 of the #147 plan, already tested)
is preserved by construction: `.markerFlaggedSlotPedigree()` returns a new object via `[<-`
copy-on-modify; the caller's `pedigree` binding is never touched.

### D2 — Scope covers BOTH `getPotentialParents()` call sites, not just the UI-visible auto-detect path. Forced by consistency — same root cause, same function, and the explicit branch is currently untested against this exact interaction (§1.3).

Leaving the explicit `id`/`role`/`candidates = NULL` branch unfixed would ship a function whose two
near-identical code paths behave inconsistently for the identical input shape, contradicting its own
roxygen's stated purpose for that branch ("a curator's proactive check on an animal that is not (yet)
flagged" — necessarily a case where the check itself might reveal both slots are non-`NA`). The
marginal implementation cost is one extra call-site edit, already covered by D1's helper.

### D3 — The flagged/wrong recorded parent is left in the candidate output, not filtered out. Judgment call; requires ratification (§6 Q2).

`.markerFlaggedSlotPedigree()`'s shadow copy does not remove the wrong recorded parent's own id from
the candidate pool it produces — it becomes just another demographically-eligible candidate, scored
by `scoreOnePair()` like any other. This is not a new risk: `scoreOnePair()`'s existing, already-
tested LOD math (`R/markerParentageLikelihood.R:226-261`, unchanged by this plan) drives `LOD` to
exactly `-Inf` for any candidate with a genuine opposite-homozygote (Mendelian-incompatible) locus —
already directly confirmed against a real fixture in `test_modMarkerGenetics.R:316-371`'s own
"computes a candidate-parent-assignment table for a flagged pair" test (`U`'s `LOD == -Inf`,
`excluded == TRUE`). Two options, both technically sound:

- **(a) Leave it in (recommended).** No extra filtering code; the flagged parent's own row in the
  output doubles as a visible, self-verifying confirmation ("here is exactly why this parent was
  flagged — its LOD is `-Inf`/it is `excluded`"), consistent with D5 of the #147 plan's own
  transparency stance (report raw signal, not a filtered/curated view).
- **(b) Filter it out.** Exclude the pedigree's own currently-recorded value for that role from the
  candidate id vector before scoring (one extra line in `.markerFlaggedSlotPedigree()`'s call sites:
  `setdiff(candidateIds, pedigree$sire[pedigree$id == fid])` or equivalent). Produces a slightly
  cleaner curator-facing table (one fewer row the curator already knows is wrong) at the cost of
  removing a free sanity-check signal and adding filtering logic with its own edge cases (what if the
  wrong recorded parent is ALSO independently a demographically-valid candidate for a *different*,
  unrelated flagged pair in the same auto-detect batch? — filtering must be scoped per-(id,role), not
  global).

### D4 — Helper placement and naming: a single new internal function in `R/markerParentageLikelihood.R` (not a new file, not exported). Author's call, not requiring ratification — mirrors D9's "smaller blast radius" precedent (`docs/planning/issue147-...-plan.md` D9) for a small, single-caller helper.

---

## 4. Alternatives considered

| Alternative | Pros | Cons | Why not recommended |
|---|---|---|---|
| **A — Add candidate ids directly to `markerParentageExclusion()`'s own `flags` output** (have the exclusion check itself compute and attach a candidate list per flagged row) | Single function call for a curator/caller; no second lookup step | Conflates two independently-tested, independently-scoped concerns — Mendelian-exclusion detection (`markerParentageExclusion()`) and demographic-eligibility candidate sourcing (`getPotentialParents()`) — into one function's output, contradicting issue #147's own D7/D8 "retain the existing exclusion check independently" framing (§1.2); `markerParentageExclusion()` has no pedigree-demography dependency today (confirmed: zero `fromCenter`/`birth`/`exit` references in that file) and this would introduce one solely to serve `markerParentageLikelihood()`'s own need | Breaks an established separation-of-concerns boundary for no benefit over D1 |
| **B — Extend `getPotentialParents()` with a new optional parameter** (e.g. `forceIncludeIds = character(0L)`, additively OR'd into the `pUnknown` filter: `fromCenter & (is.na(sire) \| is.na(dam) \| id %in% forceIncludeIds)`) | Discoverable on the shared function's own signature; could serve a hypothetical future general caller (e.g. a curator override in the Potential Parents tab) | Touches a second, independently-tested, independently-consumed function whose own contract (§2.1) is otherwise stable and unrelated to marker genetics; couples a general pedigree-demography function to a marker-genetics-shaped need, however thin the coupling; larger blast radius (a 4th column in `test_getPotentialParents.R`'s existing 15+ tests to reason about, even though none would need to change) for no behavioral benefit over D1 — empirically confirmed identical output (§2.4) | Same result, strictly larger surface touched |
| **C — Independent broader-fallback candidate pool inside `markerParentageLikelihood()`** (issue #155's own "suggested direction 2": bypass `getPotentialParents()` entirely for flagged pairs, re-deriving "any demographically-eligible, not-already-the-recorded-parent" candidates) | Avoids touching `getPotentialParents()` in any form | Re-implements a second, independently-written copy of the exact breeding-age/gestation-window/proven-breeder engine `getPotentialParents()` already implements and this package already tests — precisely the duplication/divergence risk `docs/planning/issue147-...-plan.md` D7 flags as a dragon (§7 #10 there); doubles the surface area for the two engines to silently drift apart over time | Violates this project's established reuse-over-duplication discipline for no offsetting benefit |
| **D1 — Shadow pedigree (recommended)** | Zero changes to `getPotentialParents()` or its tests; 100% reuse of its existing, already-tested engine; smallest possible blast radius (one new internal helper, two call-site edits, all in one already-owned file) | Slightly less "discoverable" than a named parameter — a future reader must open `markerParentageLikelihood.R` to see the mechanism, not `getPotentialParents()`'s own signature | (adopted) |
| **E — UI-only workaround in `R/modMarkerGenetics.R`** (pre-blank the flagged slot(s) in a local pedigree copy before calling `markerParentageLikelihood()`, entirely inside the Shiny module) | Touches only one already-Shiny-specific file; `markerParentageLikelihood()`'s own source stays untouched | Leaves the explicit `id`/`role`/`candidates = NULL` script-callable branch (§1.3, D2) broken for exactly the same input shape — undermines the very rationale (§3 D2, "same root cause, same function") for fixing both call sites together; duplicates blanking logic outside the function whose own contract needs it, which a future non-Shiny caller (e.g. a batch script) would not get for free | Fixes only the UI symptom, not the underlying function's contract |

---

## 5. Impact analysis

| System | Impact | Action required |
|---|---|---|
| `R/getPotentialParents.R` | **None.** Zero lines changed. | None. |
| `R/modPotentialParents.R` ("Potential Parents" tab) | **None** — its own `getPotentialParents()` call (`:273`) is untouched and this plan adds no new parameter for it to ignore or misuse. | None. |
| `R/markerParentageLikelihood.R` | New internal helper (`.markerFlaggedSlotPedigree()`); both existing `getPotentialParents()` call sites (`:285`, `:298`) updated to pass the shadow copy instead of the real `pedigree`. Public signature, documented contract, and return shape **all unchanged** — this is a pure internal-behavior fix, not an interface change. | Implement per §7 test list. |
| `R/modMarkerGenetics.R` (Candidate Parent Assignment tab) | **No code change** — the tab already calls `markerParentageLikelihood(gmat, ped)` in auto-detect mode; it will simply start receiving non-empty results for the previously-broken case. | None (verify via Phase 3E live smoke test against a real recorded-but-wrong fixture, mirroring the exact scenario S498 found broken). |
| Existing tests | `test_getPotentialParents.R` (40 assertions, 18 `test_that` blocks, confirmed via `grep -c` on `expect_*(` calls) — **unaffected**, function untouched. `test_markerParentageLikelihood.R`'s existing mocked tests (`:305,334,356`) — **unaffected**: each mock ignores its `ped` argument entirely (`function(ped, ...) { ... }`), so passing a shadow copy instead of the real `pedigree` changes nothing observable to them. `test_modMarkerGenetics.R:342`'s mock — same, unaffected. | Add new tests per §7; do not need to modify existing ones (confirmed, not assumed, by reading each mock's own body — none inspects `ped`). |
| Performance | Negligible: `.markerFlaggedSlotPedigree()` is one `table()` call plus two vectorized `%in%`-indexed assignments, called once per `markerParentageLikelihood()` invocation (auto-detect already calls `getPotentialParents()` exactly once outside its per-flag loop, `:285` — this plan preserves that, §8 dragon 4) or once per explicit-branch call. No new loop, no new per-candidate cost inside `scoreOnePair()`. | None. |

### 5.1 Close-out checklist disposition (`CLAUDE.md` "Additional close-out checks")

| Checklist | Applies? | Disposition |
|---|---|---|
| Citation checklist (issue #120) | No | No new displayed statistic/estimator — the LOD math and its citations are untouched. |
| Tutorial/article documentation checklist (S436) | No | No new tab, control, or interaction pattern — the existing Candidate Parent Assignment tab just stops returning empty for a case it always intended to cover. |
| `NEWS.Rmd` entry checklist (S448) | No (not mandated) | Triggers on a new exported function or new UI control, neither of which this plan adds. A bug-fix entry is still good R-package practice — left to the implementing session. |
| `a2interactive.Rmd` checklist (S450, broadened S478) | No | `markerParentageLikelihood()`'s exported signature and documented parameters are unchanged; the new helper is internal/non-exported. |
| `_pkgdown.yml` reference-coverage checklist (S496) | No | No new exported function. (Named explicitly here per the checklist's own citation of `markerParentageLikelihood()` as a prior near-miss — see `CLAUDE.md`.) |
| GitHub issue close-out checklist (S475) | **Yes** | The implementing session must `gh issue close 155 --reason completed --comment ...` citing its `CHANGELOG.md` entry, in the same session it ships (§7 DONE criteria). |
| Lint close-out checklist (S477) | **Yes** | `lintr::lint_package()` (package loaded) on the touched file before closing out (§7 Verification). |
| `CHANGELOG.md` ledger entry (Phase 3F, all sessions) | **Yes** | A dated `[issue #155]` entry is owed at close-out, matching the #145/#147 precedent format. |

---

## 6. Ratification — judgment calls requiring an explicit choice

**Q1 (D1 vs. Alternative B, §4).** Recommended: **D1, the shadow-pedigree approach** — empirically
verified identical output to Alternative B, strictly smaller blast radius (zero changes to
`getPotentialParents()`).

**Q2 (D3).** Recommended: **(a) leave the flagged/wrong recorded parent in the candidate output** —
no new filtering logic, and its already-tested `LOD = -Inf`/`excluded = TRUE` behavior is itself a
useful, free confirmation signal for the curator.

**Ratification outcome (2026-08-10, this session, via a single `AskUserQuestion` round):** owner
selected this document's own recommended option in both cases, no changes requested — **Q1: D1**
(shadow pedigree); **Q2: (a)** (leave the flagged/wrong recorded parent in the output). Both design
decisions (§3 D1, §3 D3) stand as written above; no revision needed post-ratification.

---

## 7. Implementation plan — one vertical slice (single future session)

**Scope:** `R/markerParentageLikelihood.R` only (new internal helper + two call-site edits).
No UI change (the Candidate Parent Assignment tab already calls the fixed code path). Script
-callable improvement only, matching D2's UI/script-callable split.

**Required tests** (new, in `tests/testthat/test_markerParentageLikelihood.R` unless noted). Per this
project's TDD contract, RED-phase failures must be confirmed as genuine (the assertion fails because
the fix doesn't exist yet, not because of a setup/fixture typo) — run each new test against
unmodified `HEAD` first and read the actual failure message before writing any implementation code,
matching `docs/planning/issue147-...-plan.md` Slice 1's own explicit RED-verification step:
1. `.markerFlaggedSlotPedigree()` unit tests: blanks exactly the named (id, role) pairs; leaves all
   other cells (including the *other* role for the same id, and every other id) untouched; does not
   mutate its own `pedigree` argument; handles both slots flagged for the same id (§8 dragon 1); a
   duplicated `pedigree$id` is left un-blanked, not acted on for every matching row (§8 dragon 5,
   found in this session's adversarial review).
2. A **non-mocked**, real-`getPotentialParents()` regression test reproducing issue #155's own
   fixture shape (recorded-but-wrong parent, all required demographic columns present) — confirms
   the auto-detect path now returns a non-empty candidate list including the true parent. This is the
   test class every existing test file was missing (§1.3) — the RED-phase proof this bug is actually
   fixed, not just that a mock still returns what it's told to.
3. Same non-mocked regression for the explicit `id`/`role`/`candidates = NULL` branch (D2).
4. A mocked test asserting `getPotentialParents()` (still mocked, per this file's own established
   convention for the LOD-formula-focused tests) is called with a pedigree object whose flagged
   slot(s) are `NA` — verifying the *mechanism*, not just the downstream effect.
5. A dedicated regression test locking in D3(a): the flagged/wrong recorded parent's own id appears
   in the ranked candidate output (not silently filtered), with its already-established `LOD = -Inf`/
   `excluded = TRUE` behavior — so a future session cannot silently start filtering it without a
   visible test failure (this was a ratified judgment call, §6 Q2, not an incidental side effect that
   should go untested).
6. `test_modMarkerGenetics.R`: update or add a live/near-live scenario confirming the Candidate
   Parent Assignment tab now surfaces a non-empty table for a recorded-but-wrong-parent fixture with
   real demographic columns (closing the exact gap `:322-326`'s own comment describes).

**Phase 3E (runtime smoke test):** live `shinytest2`/`chromote` run against the Candidate Parent
Assignment tab with a fixture matching S498's own original repro (a flagged animal whose recorded
parent is present-but-wrong) — confirm the table now renders non-empty, closing the loop on the
defect exactly as originally observed.

**Verification:** full clean regression read (0 failed/0 error, matching current baseline);
`lintr::lint_package()` on the touched file; `devtools::check()` unchanged baseline;
`devtools::document()` if any roxygen changes (none anticipated — no exported signature changes).

**DONE criteria (§5.1):** all §7 tests pass, live Phase 3E smoke test confirms the previously-empty
table now renders non-empty; a dated `[issue #155]` `CHANGELOG.md` entry citing the verification
summary; `gh issue close 155 --reason completed --comment ...` in the same session, citing that
`CHANGELOG.md` entry (GitHub issue close-out checklist, S475).

---

## 8. Here be dragons

1. **Both slots flagged for the same offspring.** `markerParentageExclusion()` can flag both
   `(id, "sire")` and `(id, "dam")` for one offspring (two separate rows in `flags`).
   `.markerFlaggedSlotPedigree()` must blank both slots in that case — the vectorized
   `sireIds`/`damIds` split in D1's implementation already handles this correctly (confirmed by
   construction, not yet by a dedicated test — added to §7's test list).
2. **A flagged animal missing a `birth` date.** `getPotentialParents()` drops any row with `is.na(birth)`
   *before* building `pUnknown` (`R/getPotentialParents.R:87`) — a flagged animal with no birth date
   would still return zero candidates even after this fix, an inherent, pre-existing limitation of
   `getPotentialParents()`'s own demographic engine (not introduced or worsened by this plan).
3. **A flagged animal that is not `fromCenter`.** The shadow-pedigree approach does not, and should
   not, bypass the `fromCenter` gate (§2.1) — a non-`fromCenter` flagged animal will still return zero
   candidates, matching `getPotentialParents()`'s existing, unmodified invariant. Not investigated
   further here (no evidence this occurs in practice for genotyped, actively-managed animals); a
   future session should revisit only if a real case surfaces.
4. **Auto-detect calls `getPotentialParents()` once for the whole flagged batch** (`:285`, outside the
   per-flag loop) — `.markerFlaggedSlotPedigree()` must be built from the FULL `flags$id`/`flags$role`
   vectors in one call, not per-flag inside the loop, to preserve this existing efficiency
   characteristic (already reflected in D1's proposed call-site edit). Live-verified this session
   (adversarial review): a second, independently-flagged offspring in the same batch that is itself a
   demographically-eligible candidate for a different flagged offspring's search is unaffected by its
   own slot being blanked — no cross-contamination between flagged pairs in one batch.
5. **A duplicated `pedigree$id`.** `.markerFlaggedSlotPedigree()`'s `id %in% sireIds`/`id %in% damIds`
   matching would, without a guard, blank every row sharing that id — found in this session's
   adversarial review as a real, previously-unaddressed inconsistency with `scoreOnePair()`'s own
   defensive `nrow(pedRow) == 1L` pattern a few lines away in the same file. D1's implementation (§3)
   now includes an explicit `unambiguous` guard: a duplicated id is left un-blanked, falling through to
   the same fail-soft, zero-candidates posture as an id genuinely absent from `pedigree`. Real-world
   risk is low (duplicate pedigree ids already violate assumptions used throughout the rest of the
   package), but the guard costs one `table()` call and closes the gap regardless.
6. **The empty-`ids`/`roles` no-op path is reachable only defensively, not via either real call site
   as currently wired** (found in this session's adversarial review): auto-detect always short-circuits
   on `nrow(flags) == 0L` before reaching the helper, and the explicit branch only reaches it with a
   non-`NULL` scalar `id`/`role` (enforced by the function's own `xor()` validation, `:167-170`). Not a
   bug — worth keeping the no-op safe regardless, since a future refactor of either call site could
   change this — but §7's unit test for it (already covered under test 1's "handles... " coverage)
   should note in its own comment that it is defensive, not currently reachable in practice.

---

## 9. Provenance

This session (S501, 2026-08-10) built the design directly from source: read `R/getPotentialParents.R`
and `R/markerParentageLikelihood.R` in full, `docs/planning/issue147-likelihood-parentage-assignment-plan.md`
in full, every existing test file exercising either function, and `R/modMarkerGenetics.R`'s Candidate
Parent Assignment tab wiring. The recommended mechanism (D1) was prototyped and live-verified twice
before this document was drafted (§2.4): once as the rejected Alternative B (`forceIncludeIds`
parameter) and once as the recommended shadow-pedigree approach, confirming `identical()` output
between them on a 6-individual scratch fixture reconstructing issue #155's own repro shape.

After drafting, two independent adversarial-review agents (`general-purpose`, run in parallel) audited
the draft against live source — one focused on correctness-vs-source (re-verifying every citation,
stress-testing the fix mechanism against both-slots-flagged and cross-offspring-batch scenarios,
checking `data.table`-by-reference risk, checking pedigree-id-duplicate risk), the other on
completeness and house-style consistency against the issue147/issue145 precedent documents and
`CLAUDE.md`'s own close-out checklists. Both reviews confirmed the core mechanism (D1) is correct and
that no simpler fix exists; both surfaced real, concrete gaps — three citation-accuracy corrections, a
real missing defensive guard (duplicate `pedigree$id`), a missing header/metadata block, two missing
alternatives in §4, and several missing close-out-checklist dispositions — all incorporated into this
revision. Neither review found a defect in the recommended design itself.
