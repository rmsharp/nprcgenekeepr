# Issue #122 (XARCH-2) — Module contract: architecture plan

**Status:** PLAN (not implemented). Written Session 372, 2026-07-12.
**Issue:** https://github.com/rmsharp/nprcgenekeepr/issues/122
**Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`
**Predecessor:** `docs/planning/shiny-module-conversion-plan.md` §5 explicitly deferred this
work ("the full typed-contract / column-standardize-at-source work (XARCH-2) is deferred to a
separate issue after the monolith is gone"). The monolith is gone; this is that follow-up.

> **The plan is the deliverable.** Implementation is separate session(s) — one per phase in §6.
> Do not implement any phase in the session that produced this document (FM #18).

---

## 1. Executive summary — what the research changed

The issue's four claims are all **CONFIRMED** against current source (§3). But the research pass
(10 module readers + 6 adversarial claim-verifiers + 8 symbol-level grep inventories, all
re-derived from current source at HEAD `d4787ce6`) found that **the issue understates the
problem in one direction and overstates the fix in another**:

| | Issue #122 says | What the source actually shows |
|---|---|---|
| **Severity** | An internal style inconsistency ("ad hoc data shape") | A **user-facing bug in the exported API**: two exported functions carry incompatible vocabularies for the same quantities, so composing them silently returns an all-`NA` table (§2.1). Empirically reproduced. |
| **Breeding groups** | "re-derives kinship... instead of reusing a shared one" (redundant) | The reuse branch is **unreachable dead code** — it has never once returned a matrix (§2.2). Not redundant; mis-wired. |
| **The fix** | "pass the real kinship matrix to summary/breeding modules" | Would **silently change which animals the app describes** — the GV matrix is population-filtered, the consumers are full-pedigree (§2.3, **Dragon 1**). |
| **`kinshipMatrix = NULL`** | An oversight | **Deliberate and load-bearing** — the comment at `R/appServer.R:309-312` records why (issue #13 override threading must hold regardless of tab order). |
| **Contract surface** | (not mentioned) | Modules declare **~47 returned reactives; `appServer` consumes 14**. Six of ten modules have their *entire* return discarded (§2.4). |
| **Recommended vocabulary** | Standardize at source on `meanKinship` / `genomeUniqueness` | That **breaks the exported `reportGV()` contract**, breaks its pinned contract test, changes the user's downloaded CSV, and collides with the exported **function** `meanKinship()` (§4, Alternative A — rejected). |
| **`modInput` as reference impl.** | "Make `modInput` the reference implementation" | `modInput` has a **dead `config` parameter** and an `@return` documenting 6 of its 10 elements — omitting the 4 `appServer` actually uses. There is no reference implementation to anoint; Phase 5 must *build* one (§4.4). |
| **Site config** | (not mentioned) | `loadSiteConfig() → shared$config → {modInput, modPedigree}` is **dead end to end** — both modules ignore the `config` param (§2.6). A bigger, cleaner win than either half of #122, sitting *between* two of its findings. |

**Net:** the issue correctly identifies the seam. Its prescription, followed literally, would break
the public API of a package that is mid-CRAN-resubmission. §4 proposes a backward-compatible
alternative that fixes strictly more (including the user-facing bug) and breaks strictly less.

> **⚠ Read §7 (Dragons) before implementing any phase.** Two of them will bite on contact: the kinship
> matrices are *scope*-different, not *value*-different (Dragon 1), and **the test suite structurally
> pins the very error-swallowing this issue asks you to remove** (Dragon 2).

---

## 2. Context — current state, verified firsthand

### 2.1 The disease: the public API has two vocabularies for the same quantities

Two **exported** functions disagree about what the genetic-value columns are called:

| Exported function | NAMESPACE | Direction | Vocabulary | Documented at |
|---|---|---|---|---|
| `reportGV()` | `NAMESPACE:171` | **emits** `$report` | `indivMeanKin`, `gu` | `R/reportGV.R:52-60` (`@return`) |
| `makeGeneticSummaryTable()` | `NAMESPACE:129` | **consumes** a data frame | `meanKinship`, `genomeUniqueness` | `R/makeGeneticSummaryTable.R:9-24` (`@param` + worked `@examples`) |

The natural composition — feeding the flagship analysis function's output into the summary-table
helper — **silently produces an all-`N/A` table, with no error and no warning**:

```r
gv <- data.frame(id = 1:3, indivMeanKin = c(.1,.2,.3), gu = c(.9,.8,.7))  # reportGV()'s vocabulary
makeGeneticSummaryTable(gv)
#> <table ...><tr><td><strong>Mean Kinship</strong></td><td>N/A</td>...  # every cell N/A
```

Verified by execution, not inference. The mechanism: `geneticValues$meanKinship` is `NULL` on a
frame that has no such column, and `R/makeGeneticSummaryTable.R:33-38` falls through to
`rep(NA, 6L)` rather than erroring. **This is the defect a user hits.** The module-contract mess is
how it stays hidden.

The only bridge between the two vocabularies is a private rename closure buried inside a Shiny
module's return value — `R/modGeneticValue.R:470-482`:

```r
geneticValues = reactive({
  gv <- gvResults()
  if (is.null(gv)) return(NULL)
  # Rename columns to standard names expected by other modules
  if ("indivMeanKin" %in% names(gv)) names(gv)[names(gv) == "indivMeanKin"] <- "meanKinship"
  if ("gu"          %in% names(gv)) names(gv)[names(gv) == "gu"]          <- "genomeUniqueness"
  gv
}),
```

Consequences, all verified:

- **The same data leaves the module under two different names depending on which door it uses.**
  Downstream *modules* get the renamed vocabulary; but the module's **own** outputs — the displayed
  rankings table (`R/modGeneticValue.R:332-337`) and the user's downloaded CSV
  (`R/modGeneticValue.R:458-461`, `write.csv(gvResults(), ...)`) — serve the **original**
  `indivMeanKin`/`gu`, because they read `gvResults()` upstream of the rename.
- **The ambiguity has already leaked back into the module.** `R/modGeneticValue.R:348-349` and
  `:449-450` contain defensive dual-vocabulary probes
  (`guCol <- if ("gu" %in% names(results)) "gu" else "genomeUniqueness"`) — the code no longer knows
  which vocabulary it is holding.
- **`meanKinship` is also an exported _function_** (`NAMESPACE:136`, `R/meanKinship.R:28`). The
  issue's proposed "standard" column name collides with a function name in the same package.

### 2.2 `modBreedingGroups`' kinship-reuse branch is unreachable dead code

`R/modBreedingGroups.R:189-196`:

```r
getKinshipMatrix <- function(ped, gvReactive, overrides = NULL) {
  if (!is.null(gvReactive) && is.function(gvReactive)) {
    gvData <- tryCatch(gvReactive(), error = function(e) NULL)
    if (!is.null(gvData) && "kinship" %in% names(gvData)) {   # <-- never TRUE
      return(gvData$kinship)
    }
  }
  # ... falls through to a full recompute at :204-208
```

`gvReactive` is the `geneticValues` parameter, which `appServer.R:341` supplies as
`reactive(shared$geneticValues)`; `appServer.R:306` writes `gvResults$geneticValues()` — the GV
**report data frame** — into that slot. `names()` on a data frame returns its **column** names, and
the report has no `kinship` column (it has `id`, `meanKinship`, `genomeUniqueness`, `rank`, …).
The guard is a column-name test against a matrix-shaped expectation. **It has never once returned a
matrix; breeding groups always recomputes.** The issue calls this "redundant"; it is dead.

### 2.3 Two modules recompute kinship — and the "obvious" fix is a trap

| Site | What it computes | Over which animals |
|---|---|---|
| `R/reportGV.R:140` (inside `modGeneticValue`) | `filterKinMatrix(probands, kinship(...))` | **population/proband subset only** |
| `R/modSummaryStats.R:382` | `kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)` | **full pedigree** |
| `R/modBreedingGroups.R:207` | `kinship(ped$id, ped$sire, ped$dam, ped$gen)` | **full pedigree** |

See **Dragon 1** (§7). The GV matrix is *not* a drop-in for the other two.

### 2.4 Two-thirds of the declared contract surface is dead

`appServer` assigns only 4 of 10 module returns; the other 6 are discarded entirely:

| Module | Returns | `appServer` consumes |
|---|---|---|
| `modInputServer` | 10 reactives | 8 (`appServer.R:105`) |
| `modPedigreeServer` | 6 reactives | **1** — `pedigree` (`:278`) |
| `modGeneticValueServer` | 8 reactives | 4 (`:297`) |
| `modBreedingGroupsServer` | 5 reactives | **1** — `groups` (`:338`) |
| `modPyramidServer` | 2 reactives | **0 — return discarded** (`:291`) |
| `modSummaryStatsServer` | **12 reactives** | **0 — return discarded** (`:313`) |
| `modORIPReportingServer` | 1 reactive | **0 — return discarded** (`:327`) |
| `modGeneticDiversityServer` | 2 reactives | **0 — return discarded** (`:355`) |
| `modPotentialParentsServer` | 3 reactives | **0 — return discarded** (`:370`) |
| `modGvAndBgDescServer` | **bare `NULL`** — no contract at all | n/a (`:380`) |
| **Total** | **~47 declared** | **14 consumed** |

`modSummaryStatsServer` constructs **twelve** reactives that nothing can ever read. The
`# nolint: object_usage_linter` on `appServer.R:313` is suppressing the very lint that would have
flagged the discarded return.

### 2.5 Other verified contract defects

- **Errors swallowed wholesale.** `appServer.R:142, 146, 158, 207, 208, 210` wrap every cross-module
  read in `tryCatch(..., error = function(e) NULL)`. A shape mismatch is indistinguishable from
  "no data yet."
- **A dead write.** `shared$qcResults` is written at `appServer.R:146` and **never read anywhere**
  (`rg 'shared\$qcResults' R/` → one hit, the write). Flagged in the predecessor plan; still true.
- **A load-bearing lazy promise.** `appServer.R:375-376` passes
  `gestationTable = shared$speciesOverrides$gestationTable` — a bare `reactiveValues` read, *not*
  wrapped in `reactive()` like every other module argument. It is **not** a bug: it survives only
  because R's lazy argument evaluation defers the read until the promise is forced inside a reactive
  context, and `R/modPotentialParents.R:237-240` documents exactly this ("it must stay a lazily
  forced promise"). But a promise forces **once** and caches — it is a one-shot snapshot wearing a
  reactive's clothes, indistinguishable from a real reactive at the call site, and it will silently
  serve stale data forever the day the config becomes re-loadable. See **Dragon 3**.
- **No shared error vocabulary.** Six different upstream-failure idioms across ten modules: `req()`
  (`modSummaryStats`, 10 sites), `tryCatch→NULL` (`modPotentialParents`), a private `safeRead()`
  (`modGeneticDiversity.R:84`), `req()` on the *parameter object* rather than its value
  (`modORIPReporting.R:169, 202, 314`), `showNotification` + `NULL` (`modInput`), and nothing at all
  (`modGvAndBgDesc`, `modPyramid`'s data-ready path).

### 2.6 The site-config chain is dead end to end

Not in the issue; found by the research pass and verified firsthand. **`loadSiteConfig()` →
`shared$config` → `{modInput, modPedigree}` computes a value that nothing ever reads.**

| Link | Evidence |
|---|---|
| `shared$config` is populated at boot | `R/appServer.R:64` — `shared$config <- loadSiteConfig()` |
| …and threaded into two modules | `R/appServer.R:105` (`modInputServer(config = reactive(shared$config))`), `:281` (`modPedigreeServer(config = ...)`) |
| **`modInput` never reads it** | `grep -n config R/modInput.R` → **two hits only**: the `@param` (`:245`) and the signature (`:266`). Zero reads in the 440-line body. |
| **`modPedigree` never reads it** | `grep -n config R/modPedigree.R` → the `@param` (`:171`) and the signature (`:198`). Zero reads. |

So every site-specific configuration value the app believes it is threading into the Input and
Pedigree modules is **silently discarded at the door**. This is a larger, cleaner win than either half
of issue #122 — and it sat *between* two of the issue's findings, each of which saw only one half.

**It is not free to remove:** `test_modSiteConfig.R:132-141` asserts only that the `config` formal
*exists* (via `formals()` + a deparsed source grep), never that it is consumed — so the test suite
stays green over a dead parameter and will go **red** when the parameter is removed.
`test_loadSiteConfig.R:80-81` and `test_modSiteConfig.R:12,25,141` pin the chain the same way. See
**Dragon 2**.

---

## 3. Issue claim re-verification (all line numbers re-derived at HEAD `d4787ce6`)

The issue was written 2026-07-11; S367–S370 have since modified `R/`. Every citation below was
re-derived from current source, not copied from the issue.

| # | Claim | Verdict | Current refs |
|---|---|---|---|
| 1 | GV renames at the consumer boundary, not the source | **CONFIRMED** | `R/modGeneticValue.R:470-482` (rename); `:266-277` (`reportGV` call). Issue's `:471-482` / `:266-284` — near-exact, no material drift. |
| 2 | `kinshipMatrix = NULL` → summary stats always recomputes | **CONFIRMED** | `R/appServer.R:313-320`; `R/modSummaryStats.R:357-385`; the self-documenting comment is at `:369-371`. **But the NULL is deliberate** — see `appServer.R:309-312`. |
| 3 | Breeding groups gets no `kinshipMatrix` and re-derives | **CONFIRMED, and worse** | `R/appServer.R:338-343`; `R/modBreedingGroups.R:181-182` (no such param); `:189-208`. The reuse branch is **dead**, not merely bypassed (§2.2). |
| 4 | `appServer` swallows cross-module reads in `tryCatch` | **CONFIRMED** | `R/appServer.R:142, 146, 158, 207, 208, 210` — exact. |
| 5 | *(new, tested)* GV already exposes a reusable kinship matrix, so the fix is "merely un-wired" | **PARTIALLY STALE** | The reactive is real (`R/modGeneticValue.R:489-492`) and *does* carry overrides. But it is **population-filtered** and the consumers are **full-pedigree** — not a drop-in. **Dragon 1.** |
| 6 | *(new, tested)* the unwrapped `gestationTable` read is a live bug | **REFUTED** | Lazy-promise semantics make it correct today; it is a latent trap, not a defect. **Dragon 3.** |

---

## 4. Decision — the proposed contract

### 4.1 Canonical vocabulary: adopt `reportGV()`'s, do not fight it

**Decision: `indivMeanKin` / `gu` are canonical. Delete the rename. Make the consumers tolerant.**

Rationale — the vocabulary is already decided by the public API, and the issue picked the losing side:

- `reportGV()` is the package's flagship exported analysis function. Its `@return` **documents**
  `indivMeanKin`/`gu` (`R/reportGV.R:52-60`); `tests/testthat/test_reportGV.R:15,40` **pins the exact
  column-name vector** as a deliberate contract test; the GV tab already **displays** and
  **downloads** those names. Renaming at source breaks a documented export, a pinned test, a
  user-visible CSV, and every user script — while the package is mid-CRAN-resubmission.
- `meanKinship` is *already an exported function* (`NAMESPACE:136`). Standardizing a column on that
  name is actively confusing.
- The renamed vocabulary exists only to serve `makeGeneticSummaryTable()` and three modules. It is
  the cheaper side to move.

### 4.2 The seam: one internal normalizer, applied once

Introduce a single internal (`@noRd`) normalizer that maps *either* vocabulary onto the canonical
one, and apply it at the one place data crosses into a consumer:

```r
# R/normalizeGvReport.R  (internal, @noRd)
# Accepts a genetic-value report in EITHER vocabulary and returns it in the canonical
# reportGV() vocabulary (indivMeanKin, gu). Idempotent.
normalizeGvReport <- function(gv) { ... }
```

This is deliberately **additive and backward-compatible in both directions**:

- `reportGV()`'s output contract is untouched → no exported break, no CRAN risk, no test churn.
- `makeGeneticSummaryTable()` gains dual-vocabulary tolerance → **its existing documented contract
  still works**, *and* the §2.1 composition bug is fixed. Both `makeGeneticSummaryTable(reportGV(ped)$report)`
  and the legacy `meanKinship`/`genomeUniqueness` frame produce a correct table.
- The rename closure at `R/modGeneticValue.R:470-482` is **deleted**; the module returns canonical
  names; consumers (`modSummaryStats`, `modORIPReporting`) read canonical names.

### 4.3 The kinship seam: share the *full-pedigree* matrix, not GV's

**Do not wire `gvResults$kinshipMatrix` into summary stats or breeding groups** (Dragon 1). Instead:

1. **Delete** `modBreedingGroups`' dead reuse branch (`R/modBreedingGroups.R:191-196`) — pure dead-code
   removal, provably zero behavior change (§2.2).
2. **Hoist one shared, memoized, full-pedigree kinship reactive into `appServer`**, computed from
   `shared$currentPedigree` with `kinshipOverrides` applied — i.e. *exactly* what the two consumers
   compute today — and pass it to both. Same animals, same overrides, same values; computed once
   instead of twice. The recompute fallback stays (summary stats must render before GV is ever run).
3. Leave `reportGV`'s internal population-filtered matrix alone. It is correct *for GV*.

The win is deduplication with **provably identical output** (`identical()`-gated, §6 Phase 2), not a
semantic change.

### 4.4 The module contract (the architecture note this issue asks for)

```
modXUI(id)                      -> a tagList. No exceptions.
modXServer(id, <named args>)    -> a NAMED LIST OF REACTIVES, over a stable vocabulary.
```

Rules, in the order they bind:

1. **Every server argument that carries data is a `reactive()`.** No bare `reactiveValues` reads at
   the call site (kills the Dragon-3 promise trap). No plain values.
2. **Every returned element is a `reactive()`.** No plain values, no bare `NULL` returns.
3. **The returned vocabulary is stable:** `pedigree`, `gvReport`, `kinship`, `errors`, `isReady`.
   Data-frame columns use the canonical vocabulary (§4.1) — never a per-consumer rename.
4. **Return only what a consumer reads.** A returned reactive with no consumer is dead weight
   (§2.4) — delete it or wire it.
5. **Upstream absence is `req()`; upstream *malformedness* is an error that surfaces.** A blanket
   `tryCatch(..., error = function(e) NULL)` at the seam is forbidden — it makes a shape mismatch
   look like "no data yet" (§2.5).
6. **Every declared parameter is read, and every returned element is documented.** A parameter the
   body never reads is a lie the call site keeps telling (§2.6).

> **There is no reference implementation today — and issue #122's suggestion to make `modInput` one
> does not survive contact with the source.** `modInput` has the *shape* closest to the target (10
> named reactives, 8 consumed), but its `config` parameter is **dead** (§2.6) and its `@return`
> documents **6** of its **10** elements — omitting `debugMode`, `changedCols`, `errorLst`, and
> `pedigreeFileName`, which are precisely the four `appServer` actually depends on
> (`appServer.R:122-123, 207, 208, 210`). Its documented contract describes a module no caller uses.
> **Phase 5 must *make* a reference implementation, not anoint one.** Fix `modInput` to the contract
> first, then cite it.

---

## 5. Alternatives considered

| Alternative | Pros | Cons | Verdict |
|---|---|---|---|
| **A. Rename at source in `reportGV()`** (the issue's literal recommendation) | One vocabulary; matches the issue text; downstream modules unchanged | **Breaks the exported `reportGV()` `@return` contract**; breaks `test_reportGV.R:15,40`'s pinned column vector; changes the user's downloaded GVA CSV and the displayed table; collides with the exported `meanKinship()` **function**; lands during a CRAN resubmission | **Rejected** — breaks public API to fix an internal seam |
| **B. Keep both vocabularies, centralize the rename in one named function** | Cheapest; low risk; the bridge becomes named and testable | Leaves two vocabularies in the public API; **does not fix the §2.1 composition bug** — `makeGeneticSummaryTable(reportGV(...)$report)` still returns all-`NA` | **Rejected** — treats the symptom, leaves the user-facing bug |
| **C. Adopt `reportGV()`'s vocabulary; consumers migrate; normalizer keeps the old one working** | Fixes the §2.1 user-facing bug; **breaks no exported contract**; net code *removal* (the rename closure dies); aligns internal names with the documented public contract; CRAN-safe | Touches `modSummaryStats`/`modORIPReporting` (~15 call sites) and their tests | **ADOPTED** (§4.1-4.2) |
| **D. Wire `gvResults$kinshipMatrix` into the consumers** (the issue's kinship recommendation) | Removes a duplicate computation; no new code | **Silently changes which animals the app describes** — population-filtered vs full-pedigree (Dragon 1); `convertRelationships()` tolerates the mismatch without erroring, so the divergence is invisible | **Rejected** — a semantic change disguised as a refactor |
| **E. Shared full-pedigree kinship reactive in `appServer`** | Removes the duplicate computation with **provably identical** output; preserves the deliberate `#13` override threading | One more reactive in `appServer` | **ADOPTED** (§4.3) |
| **F. A formal S3/S7 class for the module contract** | Type-checkable; self-documenting | Astronaut architecture for a 10-module app; large blast radius; no consumer is asking for it | **Rejected** — not proportional |

---

## 6. Migration path — 5 phases, each ONE session

Every phase is independently valuable and independently stoppable ("if I stop here, is something
working?" — yes, at every boundary). Phases are ordered so the **user-facing bug ships first**.

> **TDD applies to every phase** (`CLAUDE.md` Development Process Contract): RED → GREEN → REFACTOR,
> with an `AskUserQuestion` phase gate at each transition.

> **⚠ Step 0 of EVERY phase — structural-test triage (Dragon 2).** Before writing a line, run:
> ```sh
> rg -n 'deparse\((appServer|mod[A-Za-z]+Server)\)' tests/testthat/
> ```
> and read every hit that names a function this phase touches. These tests assert **source text**, not
> behavior; they are invisible to a normal "which tests cover this module" search, and several of them
> **pin the exact anti-pattern the phase is removing**. Decide up front, per hit: rewrite it to assert
> behavior (usually right), or narrow it. Do **not** discover them by turning the suite red.

---

### Phase 1 — Fix the public-API composition bug (the normalizer seam)

**Why first:** it is the only phase a *user* can currently feel, and it unblocks Phase 3.

**Scope:** new internal `R/normalizeGvReport.R` (`@noRd`); `makeGeneticSummaryTable()` gains
dual-vocabulary tolerance via it. **No module touched.** No exported signature changed.

**DONE looks like:** `makeGeneticSummaryTable(reportGV(ped)$report)` returns a correctly populated
table instead of all-`N/A`, *and* the legacy `meanKinship`/`genomeUniqueness` frame still works
(both pinned by tests).

**Verification:**
```r
# the RED test, before the fix, must fail:
gv <- data.frame(id = 1:3, indivMeanKin = c(.1,.2,.3), gu = c(.9,.8,.7))
expect_false(grepl("N/A", makeGeneticSummaryTable(gv)))
```
```sh
Rscript -e 'suppressMessages(pkgload::load_all(".", quiet=TRUE)); testthat::test_file("tests/testthat/test_makeGeneticSummaryTable.R", reporter="summary")'
Rscript -e 'as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE))'  # sum(failed)/sum(error)/sum(warning) == baseline
Rscript -e 'lintr::lint_package()'   # no new lints; <=80 cols
```
**Session boundary: this phase is one session. Close out when done.**

---

### Phase 2 — Kill the dead branch; share one full-pedigree kinship matrix

**Scope:** delete `R/modBreedingGroups.R:191-196` (dead reuse branch); add a `kinshipMatrix` param to
`modBreedingGroupsServer`; hoist a shared full-pedigree kinship reactive into `appServer` and pass it
to **both** `modSummaryStatsServer` and `modBreedingGroupsServer`. Recompute fallback retained
(Dragon 3).

**⚠ This phase trips Dragon 2 immediately.** `modSummaryStats`' *only* `tryCatch` lives in the branch
this phase touches (`R/modSummaryStats.R:363`), and `test_modErrorHandling.R:186-192` asserts
`deparse(modSummaryStatsServer)` contains the string `"tryCatch"`. `test_modErrorHandling.R:180-184`
similarly pins `tryCatch` **and** `showNotification` in `modBreedingGroupsServer`. Triage both **before**
touching source; expect to rewrite them as behavioral tests (feed a malformed kinship input, assert
graceful degradation) rather than source greps.

**DONE looks like:** kinship is computed **once** per pedigree instead of twice, and both consumers'
outputs are **`identical()`** to their pre-change values.

**Verification — the `identical()` gate is mandatory, not optional:**
```r
# Same pedigree, same seed. Capture BEFORE the change, compare AFTER.
identical(before$relationships, after$relationships)      # modSummaryStats relationship table
identical(before$kinshipExportCsv, after$kinshipExportCsv)
identical(before$groups, after$groups)                    # modBreedingGroups formation
```
Run it **both** with and without focal animals entered on the Pedigree tab — that is the exact axis
Dragon 1 says the two matrices diverge on, and a no-focal-animals-only test would pass while the
focal path silently rescoped.

Plus: affected-file suite at a **literal zero** (Dragon 6) — failed, error, **and warning**;
**Phase 3E live smoke test** (this changes runtime wiring — `callr::r_bg()` + `shiny::runApp()`, per
the S369 precedent).
**Session boundary: this phase is one session. Close out when done.**

---

### Phase 3 — Collapse to one vocabulary

**Scope:** delete the rename closure (`R/modGeneticValue.R:470-482` → return `gvResults()` directly);
delete the dual-vocabulary probes (`:348-349`, `:449-450`); migrate `modSummaryStats` (~13 sites,
`R/modSummaryStats.R:421,483,507-511,570-571,594,599,721-723,765,872,903-904,916`) and
`modORIPReporting` (4 sites, `R/modORIPReporting.R:210-211,284-285`) to canonical names; update the
`@param` docs at `R/modSummaryStats.R:253-254`.

**Depends on Phase 1** (the normalizer keeps `makeGeneticSummaryTable`'s old contract alive).

**DONE looks like:** `rg 'meanKinship|genomeUniqueness' R/mod*.R` returns **zero** hits outside
`normalizeGvReport`'s tolerance path. The GV tab's displayed table and downloaded CSV are
**byte-identical** to before (they already used canonical names — this must be re-proved, not assumed).

**Verification:** full suite; the 15 test files asserting the renamed vocabulary (§8) updated;
`devtools::document()` **standalone** (Learning 341 — never bundled with another roxygen edit);
Phase 3E live smoke test.
**Session boundary: this phase is one session. Close out when done.**

---

### Phase 4 — Prune the dead surface; replace the `tryCatch` swallow

**Scope — four dead things and one anti-pattern:**
1. **The dead site-config chain** (§2.6): `config` params on `modInputServer`/`modPedigreeServer`, and
   `shared$config` itself. *Decide first:* delete the chain, or **wire it** (does either module have a
   config value it *should* be honoring?). Deleting is honest; wiring may be what was intended. This is
   a real design decision, not a cleanup — see §10.
2. **The dead write** `shared$qcResults` (`appServer.R:51,146`; read nowhere).
3. **The discarded return contracts** (§2.4) — start with `modSummaryStatsServer`'s 12 unread
   reactives; remove the `# nolint: object_usage_linter` at `appServer.R:313` once its return is
   consumed or trimmed.
4. **`modInput`'s `@return` doc/code mismatch** — document the 4 undocumented, load-bearing elements
   (`debugMode`, `changedCols`, `errorLst`, `pedigreeFileName`).
5. **The blanket swallow:** replace `appServer`'s six `tryCatch(..., error = function(e) NULL)` reads
   (`:142, 146, 158, 207, 208, 210`) with explicit `req()`/contract guards, so a shape mismatch
   surfaces instead of masquerading as "no data yet."

**⚠ Dragon 2 again, hardest here.** `test_modErrorHandling.R:240-246` asserts `deparse(appServer)`
contains `"tryCatch"` — item 5 removes every one of them. `test_modSiteConfig.R:132-141` asserts the
`config` formal *exists* — item 1 removes it. `test_loadSiteConfig.R:80-81` greps the deparsed
`appServer` source for `"loadSiteConfig"`. **All three go red by design.** Triage them in the RED step
and rewrite them to assert behavior.

**⚠ Scope check before deleting a return element:** `mod*Server` functions are `@export`ed, so a
returned element is *technically* public. `rg` across `tests/`, `vignettes/`, and `docs/` before
removing — and prefer wiring over deleting where a consumer *should* exist.

**DONE looks like:** every declared parameter is read; every returned reactive has a consumer; no
blanket error-swallowing at the `appServer` seam; affected-file suite at a literal zero; app boots clean
(Phase 3E — this changes runtime wiring).
**Session boundary: this phase is one session. Close out when done.** *(If the config decision in item 1
proves contentious, split it out — it is independently valuable and independently stoppable.)*

---

### Phase 5 — Write the contract down and make it enforceable

**Scope:** an architecture note (`docs/architecture/module-contract.md`) capturing §4.4; `@family Shiny
modules` roxygen updated to cite it; **`modInput` brought *up to* the contract and then documented as
the reference implementation** — it is not one today (§4.4: dead `config` param, `@return` documenting
6 of 10 elements). Ship a lightweight guard test asserting every `mod*Server` returns a named list of
reactives whose elements are all functions.

**The guard test is the point of this phase.** A contract nothing checks is the contract that rots —
this issue *is* that rot, five sessions of good intentions after the module-conversion plan deferred
it. A document alone would earn the same fate.

**DONE looks like:** the contract exists as a document a future session can be held to **and** as a
test that fails when a module violates it; `modInput` actually satisfies it.
**Session boundary: this phase is one session. Close out when done.**

---

## 7. Dragons — where this plan is dangerous

> Not all phases are equally risky (SESSION_RUNNER Learning #3). These are the load-bearing
> assumptions; an executor who ignores them will ship a silent regression.

**🐉 Dragon 1 — the kinship matrices are the same *values* at different *scopes*. (Phase 2)**
*Measured, not reasoned.* `reportGV()`'s matrix is **proband-filtered**: `R/reportGV.R:134` sets
`probands <- ped$id[ped$population]` and `:140` applies `filterKinMatrix(probands, ...)`. `population`
is set by the **Pedigree tab's focal-animal selection** (`R/modPedigree.R:305` → `R/setPopulation.R:29-36`).
The consumers compute over the **full** pedigree (`modSummaryStats.R:382`, `modBreedingGroups.R:207`).
Run against `qcPed` (280 animals, 191 of them exited):

| Scenario | consumers' kmat | GV's kmat | Same values? |
|---|---|---|---|
| **no focal animals (the default path)** | 280 × 280 | **280 × 280** | **bit-identical** |
| 20 focal animals entered | 280 × 280 | 20 × 20 | identical on the 20 shared IDs |

So the two are **never numerically different — only differently scoped.** On the default path they
are literally *the same matrix computed twice*, and issue #122's "redundant" charge is exactly right.
The risk is narrower than it first appears, but real: **threading GV's matrix in would silently
rescope the Summary-Stats relationship table and kinship CSV export from the full pedigree to the
focal subset — and only for users who entered focal animals.** It would not error:
`convertRelationships()` tolerates `kmat ⊂ ped` without complaint (`R/convertRelationships.R:34-39`),
and `countFirstOrder()` (`modSummaryStats.R:407-411`) would stay full-pedigree, leaving the tab
internally inconsistent for exactly those users. → Phase 2 sidesteps this entirely by sharing a
*full-pedigree* matrix (not GV's) and gating on `identical()`.

> **Provenance note, because it matters for how much you trust this doc:** two independent verifiers
> contradicted each other here — one claimed GV's matrix is *living-animals-only*, the other that it
> is *focal-derived*. The second is correct (`modGeneticValue.R:232`'s `if (!"population" %in% names(ped))`
> guard never fires, because `modPedigree.R:305` always sets `population`), and the first agent's
> `is.na(ped$exit)` branch (`modGeneticValue.R:234-238`) is **dead on the app path**. The table above is
> the settled, executed answer. Do not re-derive it from either agent's prose.

**🐉 Dragon 2 — the test suite pins the anti-pattern this issue asks you to remove. (Phases 2 & 4)**
There is a class of ~40 **structural `deparse()` source-grep tests** that assert the *source text* of a
server function contains a given string. They are invisible to any "which tests exercise this module"
search, they test no behavior, and they fail on a semantically perfect refactor:

```r
# tests/testthat/test_modErrorHandling.R:186-192
server_source <- deparse(modSummaryStatsServer)
server_text   <- paste(server_source, collapse = "\n")
expect_true(grepl("tryCatch", server_text))          # <-- pins the smell
```

`R/modSummaryStats.R` contains **exactly one** `tryCatch` in 920 lines — line 363, *inside the dead
`kinshipMatrix` branch*. **Deleting that branch turns this test RED.** Likewise
`test_modErrorHandling.R:180-184` requires `modBreedingGroupsServer` to contain **both** `tryCatch`
*and* `showNotification`; `:240-246` requires `deparse(appServer)` to contain `tryCatch` — which
Phase 4 removes by design. Other source-grep pins: `test_loadSiteConfig.R:80-81`,
`test_modSiteConfig.R:12,25,141`, `test_loadSpeciesOverrides.R:216-218`, `test_modORIPReporting.R:59-62`,
`test_appServer_dynamicTabs.R:159`, `test_modGvAndBgDesc.R:83`, `test_modPotentialParents.R:593-595`,
`test_modSummaryStats_popovers.R:44,158,224`, `test_modPlotDownload.R:130-260` (10 sites),
`test_modFounderStats.R:140,164`.

**Every phase must begin with a structural-test triage step** (§6). These tests are the real constraint
on any module-body refactor, and *a phase-verification command that only runs the module's own test
file will not catch them.* When one of them goes red, the correct response is usually to **rewrite the
test to assert behavior instead of source text** — not to preserve the anti-pattern to keep it green.

**🐉 Dragon 3 — `kinshipMatrix = NULL` is deliberate; do not "fix" it by deleting the fallback. (Phase 2)**
`R/appServer.R:309-312` records *why*: summary stats must recompute so issue #13's kinship overrides
hold **regardless of tab order**, and the tab must render **before GV is ever run**. Worse,
`gvResults$kinshipMatrix` opens with `req(fullResults())` (`R/modGeneticValue.R:490`), which raises a
**silent Shiny error** — it does *not* return `NULL`. Any consumer reading it must be
`tryCatch`-guarded (as `modGeneticDiversity.R:84`'s `safeRead()` already is). The recompute fallback
**stays**.

**🐉 Dragon 4 — `gestationTable` is a lazy promise, and it looks exactly like a reactive. (Phase 4)**
`appServer.R:375-376` reads `shared$speciesOverrides$gestationTable` bare, *not* wrapped in
`reactive()`. This is correct **only** by R's lazy-argument semantics: the read is deferred until the
promise is forced inside a reactive context, after boot has populated it —
`R/modPotentialParents.R:237-240` documents this and warns against shadowing it. But a promise forces
**once**. Normalizing it to `reactive(shared$speciesOverrides$gestationTable)` (contract rule 1) is
the *right* fix and is behavior-preserving today — but **do not** "tidy" it into an eager read, and
**do** re-read that comment before touching it.

**🐉 Dragon 5 — CRAN timing.** v2.0.0 is mid-resubmission (`BACKLOG.md`; archived over an unrelated
policy violation, fix landed S349, pre-submission gate clean as of S363). Phases 1-5 as designed break
**no exported contract** — that is a deliberate constraint, not a coincidence (§4.2), and it is why
Alternative A was rejected. **If a future session reopens the "rename at source" option, it must not
land before the resubmission completes.** Related: `tests/testthat/test_pkgdown_reference_config.R:32-50`
asserts that **every** `getNamespaceExports()` entry appears in `_pkgdown.yml`'s `reference:` block —
so any *new* export (a deprecation shim, a shared-kinship helper) fails that test unless `_pkgdown.yml`
is edited in the same commit, and any *removed* export needs its `_pkgdown.yml` line deleted or pkgdown
errors on a missing topic. Prefer internal (`@noRd`) helpers, which sidestep this entirely.

**🐉 Dragon 6 — the baseline for *these* files is clean, so demand a literal zero.** The project-wide
"`test-app-*`/`test-e2e-*` are baseline noise" caveat (`CLAUDE.md`) **does not apply to this issue's
blast radius**: all 26 such files carry skip guards and none sit in the affected surface. Measured on
the affected files (`modSummaryStats|modGeneticValue|modBreedingGroups|modErrorHandling|appServer|reportGV`):
**0 failed, 0 error, 0 warning, 1 skip.** Per-phase verification can therefore require a literal zero
rather than "matches baseline." Still check the **`warning`** column, not just `failed`/`error`
(Learning, S313).

---

## 8. Evidence-based inventory (grep-derived, not assumed)

*Per `SESSION_RUNNER.md` §Planning Sessions: the files-to-change list comes from search results.
Re-run these before each phase — this inventory is a snapshot at HEAD `d4787ce6`.*

### 8.1 Source files

| Symbol | Where it lives | Public API? |
|---|---|---|
| `indivMeanKin` (canonical) | `R/reportGV.R:156`, `R/modGeneticValue.R:284,294,475`, `R/correctUnknownParentMeanKinship.R`, `R/gvaConvergence.R:151`, `R/headerDisplayNames.R` | **YES** — `reportGV()` `@return`, `R/reportGV.R:52-60` |
| `gu` (canonical) | `R/reportGV.R` (emitter), `R/modGeneticValue.R:294,349,450,478-479` | **YES** — same `@return` |
| `meanKinship` (renamed) | `R/modGeneticValue.R:348,449,476`; `R/modSummaryStats.R:421,483,507-511,570-571,594,599,721-723,765,872,903-904,916`; `R/modORIPReporting.R:210,284`; `R/makeGeneticSummaryTable.R:11,21,33` | **YES, twice over** — `makeGeneticSummaryTable()` `@param`, **and** an exported **function** (`NAMESPACE:136`, `R/meanKinship.R:28`) |
| `genomeUniqueness` (renamed) | `R/modGeneticValue.R:349,365-366,450,479`; `R/modSummaryStats.R:483,570-571,599,723,904`; `R/modORIPReporting.R:211,285`; `R/makeGeneticSummaryTable.R:12,22,41` | **YES** — `makeGeneticSummaryTable()` `@param` + `@examples` |
| `kinshipMatrix` | `R/appServer.R:317,360`; `R/modGeneticValue.R:489`; `R/modSummaryStats.R:309,362-363`; `R/modGeneticDiversity.R` | Exported **module** signatures (`modSummaryStatsServer`, `modGeneticDiversityServer`) |

### 8.2 Test files that a contract change breaks

**Assert the renamed vocabulary** (Phase 3 must update): `test_modSummaryStats.R`,
`test_modSummaryStats_coverage.R`, `test_modSummaryStats_ggplots.R`, `test_modSummaryStats_parity.R`,
`test_modSummaryStats_relationships.R`, `test_modGeneticValue.R`, `test_modGeneticValue_coverage.R`,
`test_modORIPReporting_server.R`, `test_modBreedingGroups.R`, `test_modFounderStats.R`,
`test_makeGeneticSummaryTable.R`, `test-e2e-genetic-value-tutorial.R`.
*(`test_meanKinship.R`, `test_cumulateSimKinships.R` match the string but test the **function** —
not affected. Verify before editing.)*

**Assert the canonical vocabulary** (must stay green — these are the contract tests):
`test_reportGV.R` (**`:15,40` pin `$report`'s exact column vector**),
`test_correctUnknownParentMeanKinship.R`, `test_modGeneticValue_kinshipOverrides.R`,
`test_modGeneticValue_coverage.R`, `test_modSummaryStats_ggplots.R`.

**Exercise the wiring** (Phase 2/4): `test_appServer_server.R`, `test_appServer_dynamicTabs.R`,
`test_modBreedingGroups_kinshipOverrides.R`, `test_modSummaryStats_kinshipOverrides.R`,
`test_modGeneticDiversity.R`, `test_modErrorHandling.R`.

### 8.3 Structural `deparse()` source-grep tests — the hidden constraint (Dragon 2)

**~40 tests assert the _source text_ of a server function, not its behavior.** They are invisible to a
"which tests cover this module" search and several pin the exact anti-pattern this plan removes. Find
them with `rg -n 'deparse\((appServer|mod[A-Za-z]+Server)\)' tests/testthat/`. The ones that **will go
red**, and why:

| Test | Asserts | Broken by |
|---|---|---|
| `test_modErrorHandling.R:186-192` | `deparse(modSummaryStatsServer)` contains `"tryCatch"` | **Phase 2** — its *only* `tryCatch` (`R/modSummaryStats.R:363`) is in the branch being changed |
| `test_modErrorHandling.R:180-184` | `modBreedingGroupsServer` contains `"tryCatch"` **and** `"showNotification"` | **Phase 2** |
| `test_modErrorHandling.R:240-246` | `deparse(appServer)` contains `"tryCatch"` | **Phase 4** — which removes all 6-7 of them |
| `test_modSiteConfig.R:132-141` | the `config` formal exists in `modInputServer` | **Phase 4** — which removes it (§2.6) |
| `test_loadSiteConfig.R:80-81` | `deparse(appServer)` contains `"loadSiteConfig"`, and no `read.table` | **Phase 4** |

Others to triage (not obviously broken, but source-pinned): `test_loadSpeciesOverrides.R:216-218`,
`test_modSiteConfig.R:12,25`, `test_modORIPReporting.R:59-62`, `test_appServer_dynamicTabs.R:159`,
`test_modGvAndBgDesc.R:83`, `test_modPotentialParents.R:593-595`,
`test_modSummaryStats_popovers.R:44,158,224`, `test_modPlotDownload.R:130-260` (10 sites),
`test_modFounderStats.R:140,164`.

**When one goes red, rewrite it to assert behavior — do not preserve the anti-pattern to keep it green.**

### 8.4 Non-source references, and three useful clean negatives

`_pkgdown.yml:267` references `` `meanKinship` `` — the exported **function**'s Reference entry, **not** a
column. Leave it alone. `man/*.Rd` for `reportGV`, `makeGeneticSummaryTable`, `meanKinship`, and every
`mod*Server` regenerate from roxygen — run `devtools::document()` **standalone** (Learning 341).

Clean negatives, stated so no one goes hunting:

- **`inst/extdata/` carries none of these column names.** `rg -l 'indivMeanKin|genomeUniqueness' inst/extdata/`
  → **0 files**. No bundled data file encodes the vocabulary; a rename touches no data. The only `inst/`
  exposure is *prose* in `inst/extdata/ui_guidance/population_genetics_terms.html` ("Genome Uniqueness
  (GU)") — help text, not a schema.
- **The affected-file test baseline is clean** — 0 failed, 0 error, 0 warning, 1 skip (Dragon 6).
- **`.lintr` sets `line_length_linter(80)` and excludes `tests/` and `vignettes/`.** `R/appServer.R`,
  `R/modSummaryStats.R`, and `R/reportGV.R` currently have **zero** over-80 lines. Do not let this plan
  introduce the first one. Test-file edits are unconstrained.

---

## 9. Impact analysis

| Surface | Impact | Action required |
|---|---|---|
| `reportGV()` exported contract | **None** — deliberately preserved | Re-prove with `test_reportGV.R:15,40` after every phase |
| `makeGeneticSummaryTable()` exported contract | **Widened, not broken** — old input still works, new input starts working | Phase 1; pin both with tests |
| GV tab displayed table + downloaded CSV | **None** (already canonical) — but must be *re-proved*, not assumed | Phase 3 |
| Summary Stats relationship table / kinship CSV | **None intended** — `identical()`-gated | Phase 2 (**Dragon 1**) |
| Breeding-group formation | **None intended** — `identical()`-gated | Phase 2 |
| CRAN resubmission | **None** — no exported contract breaks (Dragon 4) | Keep it that way |
| `mod*Server` exported signatures | `modBreedingGroupsServer` gains `kinshipMatrix` (additive, defaulted) | Phase 2 |

**Explicit scope boundary — what this plan does NOT change:** `reportGV()`'s algorithm or output;
the population/proband semantics of the GV analysis; issue #123 (XARCH-5, the string-keyed pipeline
seam) — related, separately tracked, **not** in scope; the app's UI or user-visible workflow.

---

## 10. Open decisions for the implementing sessions

1. **The dead site-config chain — delete, or wire? (Phase 4, §2.6.)** The *only* genuine design
   question in this plan, and it is the owner's call, not the implementer's. `loadSiteConfig()` loads a
   real site configuration; `appServer` threads it into `modInput` and `modPedigree`; **both discard
   it.** Either (a) it was never needed → delete the chain, or (b) those modules were *supposed* to
   honor a site config (species defaults? column mappings? min-parent-age floors?) and the wiring was
   simply never finished → **this is a latent missing feature, not dead code.** Answering (b) requires
   knowing what the site config was *for* — which is domain knowledge, not code knowledge. **Ask before
   deleting.**
2. **Phase 4's pruning depth.** `mod*Server` returns are technically public (`@export`). Delete the
   ~33 unread reactives, or wire the ones that *should* have consumers? Recommend: delete
   `modSummaryStats`' 12 (nothing has ever read them), wire nothing new, note the rest.
3. **`modGvAndBgDescServer` returning bare `NULL`.** Leave (it is genuinely stateless) or return
   `list()` for uniformity? Recommend: leave, and let the Phase 5 guard test carve out the exception
   explicitly rather than silently.
4. **Do the redundancy fixes even matter at colony scale?** Phase 2 removes one duplicate kinship
   computation. Nobody has measured what that costs on a real (~10k-animal) colony pedigree. If it is
   milliseconds, Phase 2's value is *correctness* (the dead branch) and clarity, not speed — and the
   plan should say so honestly rather than implying a perf win it never measured.
