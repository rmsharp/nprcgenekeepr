# Issue #150 Plan — De-Identified Pedigree Export Workflow for Approved Data Sharing

**Status:** Design/architecture only. No `R/`/`tests/`/`man/` content changed this session,
matching the #133/#136/#137/#145/#146/#147/#149/#151 precedent. Ratified via `AskUserQuestion`
(Session 514, 2026-08-10) — see §11.

---

## 1. Context

### 1.1 What issue #150 says (verbatim)

> ## Source
>
> `GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`: cross-center/governance partial finding.
>
> The package has tested de-identification helpers (`obfuscateId()`, `obfuscateDate()`,
> `obfuscatePed()`, `mapIdsToObfuscated()`), but no integrated app workflow or auditable sharing
> export.
>
> Provide an optional curator-controlled export workflow that produces a relationship-preserving
> de-identified pedigree, offers documented date-handling choices, exports a non-sensitive
> transformation manifest, keeps any ID map local to the authorized user, and warns that
> authorization/data-access policy remain institutional responsibilities.

### 1.2 What is already decided (do not re-litigate)

`docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` Finding #3 placed #150 outside
its own priority table entirely — "Policy/external" — because the codebase has **zero** auth/
role/curator-identity infrastructure. Its own recommendation, verbatim: *"the code to build this
is already 90% written and tested; do we want to formalize a curator-controlled de-identified
sharing export, understanding that 'curator-controlled' means a confirmation dialog and warning
text, not real access control?"*

**Session 514 (this session) put exactly that question to the owner via `AskUserQuestion`. Owner
answered: yes, formalize it, on that explicit basis.** This is the one prerequisite decision the
audit gated the entire item on — it is now resolved and is not re-opened by anything below.

### 1.3 What this session's research confirmed

Direct reads of every function in the relevant call graph (not summarized from memory), plus one
empirical verification that overturned an assumption the issue text does not raise at all:

- `obfuscateId()`/`obfuscateDate()`/`obfuscatePed()`/`mapIdsToObfuscated()` are all real,
  `@export`ed, unit-tested, and directly reusable as-is for the id/name/date-scrubbing core.
- `obfuscatePed()` already scrubs `name` to `NA` (issue #136 D8) — the "relationship-preserving,
  no-name-leak" requirement is **already satisfied**, not a new decision.
- **A previously-unflagged, empirically-confirmed defect in `obfuscatePed()`'s existing date
  handling makes "documented date-handling choices" a load-bearing requirement, not a nice-to-have
  UI label** (§2.4, §7 Dragon 1). This is the session's single most consequential finding.
- The closest UI precedent in the codebase, `R/modCrossCenterIdentity.R` (issue #149, S505), is
  file-upload/validate/preview/confirm-gate/multi-export shaped — but issue #150's own shape is
  simpler in one specific way (§2.2): it exports the pedigree **already loaded** in the running
  session, not a pair of freshly uploaded files, so an entire upload+validate stage that #149
  genuinely needed does not apply here.

---

## 2. Evidence-based inventory

### 2.1 The four existing de-identification primitives — verified in full

| Function | Signature | Verified behavior |
|---|---|---|
| `obfuscateId(id, size = 10L, existingIds = character(0L))` | `R/obfuscateId.R` | Returns a named character vector (`names()` = original id) of pseudorandom alphanumeric aliases (no `"O"`, no `"."`), retrying up to 100x per id to avoid collisions against `existingIds` and to keep the `isGeneratedUnknownId()` class consistent between an id and its alias. |
| `obfuscateDate(baseDate, minDate, maxDelta = 30L)` | `R/obfuscateDate.R` | Shifts each date by a *uniform random* offset in `[-maxDelta, +maxDelta]` days, re-drawing (`repeat`) until the result is `>= minDate`. **Each call is independent — no cross-call coordination.** |
| `obfuscatePed(ped, size = 6L, maxDelta = 30L, existingIds = character(0L), map = FALSE)` | `R/obfuscatePed.R` | Aliases `id`/`sire`/`dam` via one shared `obfuscateId()` call (so pedigree structure/relationships survive exactly — the "relationship-preserving" requirement); drops `name` to `NA` if present; **calls `obfuscateDate()` once per `Date`-class column, independently** (`for (col in names(ped)) if (inherits(ped[[col]], "Date")) ped[[col]] <- obfuscateDate(...)`); recomputes `age` from the now-obfuscated `birth`/`exit` via `calcAge()`; returns `list(ped=, map=)` when `map = TRUE`. |
| `mapIdsToObfuscated(ids, map)` | `R/mapIdsToObfuscated.R` | Looks up a vector of original ids against a `obfuscatePed(..., map=TRUE)$map` alias vector. `stop()`s if any id is missing from the map — not used by this design (no downstream re-lookup need), listed for completeness. |

**No new de-identification primitive is required.** The "genetics-hard part" the audit's Finding #3
describes as "already written" is confirmed, not assumed.

### 2.2 `shared$currentPedigree` is the right data source — not a fresh upload

`R/appServer.R:47-54` defines `shared <- reactiveValues(..., currentPedigree = NULL, ...)`,
populated once at `R/appServer.R:307` (`shared$currentPedigree <- pedigreeResults$pedigree()`) after
`modInput`'s QC pipeline runs. Every majority-shape module in the app (`modBreedingGroups`,
`modGeneticValue`, `modMarkerGenetics`, `modMatePair`, `modPotentialParents`, `modGeneticDiversity`,
`modORIPReporting`) consumes it the same way: `pedigree = reactive(shared$currentPedigree)`.

`modCrossCenterIdentity` is the **documented exception** (`R/appServer.R:457-461`: *"a standalone
review/export tool (D3): its own 3 fileInputs, no `shared$...` wiring"*) — but that exception exists
because #149's job is comparing **two different centers' pedigrees**, neither of which is
`shared$currentPedigree`. Issue #150's job is exporting **the one pedigree the curator is already
working with**. There is nothing to compare and nothing to upload — the correct wiring is the
majority pattern, not the #149 exception. (D1, forced — see §3.)

### 2.3 `.nprcColumnSchema$possible` — what a pedigree can carry beyond id/sire/dam/dates/name

`R/columnSchema.R:19-23`: `id, sire, dam, sex, species, gen, birth, exit, death, age, ancestry,
population, origin, status, condition, departure, spf, vasxOvx, pedNum, first, second, first_name,
second_name, recordStatus, affected, name`.

Three observations, all load-bearing for §3:

- **`death` is a second `Date`-class column beyond `birth`/`exit`**, subject to the same
  independent-per-call `obfuscateDate()` treatment as every other Date column — the Dragon in §2.4
  is not a two-column (`birth`/`exit`) special case, it is an *N*-column one.
- **`first_name`/`second_name` are allele names, not personal names** — the exact trap
  `PROJECT_LEARNINGS.md` Learning 485 already named for issues #133/#136. Confirmed via source read
  (not re-derived from memory) so this design does not re-fall into it.
  `obfuscatePed()` correctly leaves them untouched.
  `origin`/`population`/`status`/`condition`/`spf`/`departure` are demographic/business fields, not
  scrubbed by `obfuscatePed()` today, and #150's own issue text does not ask for them to be —
  disclosed as an explicit, documented limitation rather than silently ignored (§3 D8).

### 2.4 A real, empirically-verified defect: independent per-column date obfuscation can invert `birth`/`exit`, producing a negative age

`R/calcAge.R:24-28`: `calcAge(birth, exit)` computes `round((as.double(exit - birth) / 365.25), 1L)`
with no floor at zero. Because `obfuscatePed()` calls `obfuscateDate()` **once per column,
independently** (§2.1), an individual's `birth` and `exit` can each drift by up to `maxDelta` days
in *opposite* directions — a worst case of `2 * maxDelta` days of relative movement — with nothing
enforcing that the obfuscated `exit` still follows the obfuscated `birth`.

**Verified empirically, not assumed** (`Rscript`, seeded, against the bundled `pedGood` fixture with
a realistic tight 10-day birth–exit gap, default `maxDelta = 30L`):

```r
set.seed(42)
ped <- qcStudbook(nprcgenekeepr::pedGood)
ped$exit <- ped$birth + 10        # a realistic short-lived-individual gap
obf <- obfuscatePed(ped, size = 6L, maxDelta = 30L)
# 2 of 8 individuals: obfuscated exit < obfuscated birth
#   id       birth       exit    age
#   FBCVBJ  2012-05-06  2012-04-04  -0.1
#   E7I3LU  2008-05-08  2008-04-05  -0.1
```

25% of a small, realistic-gap fixture produced a **negative recomputed age** in the obfuscated
output. This is not a contrived adversarial input — any individual whose recorded lifespan is
shorter than roughly `2 * maxDelta` days (early mortality, stillbirth, a short-term transfer) is at
risk, and a colony pedigree spanning decades routinely contains such individuals.

No existing test exercises this (`tests/testthat/test_obfuscatePed.R` — read in full, §2.6) — it
predates this session, is not caused by anything in this design, and was never caught because no
prior caller of `obfuscatePed()` needed the output to survive external, scientifically-scrutinized
sharing. Issue #150 is the first caller that does. This is why "documented date-handling choices"
in the issue's own text is not a UI nicety — the *existing* default choice is silently unsafe for
this exact feature's stated purpose. See §3 D3 and §7 Dragon 1.

### 2.5 `R/modCrossCenterIdentity.R` — closest UI precedent, read in full

Upload (3 `fileInput`s) → Validate (`checkCrossCenterMapping()`, a "show every problem at once"
table) → Preview (`.buildCrossCenterLineagePreview()`) → Confirm (`showModal(modalDialog(...))` —
**this app's first-ever use of `modalDialog()`**, per its own S505 commit note) → Export (5
`downloadButton`s, each a `downloadHandler()` writing `write.csv(..., row.names = FALSE)`, filenames
stamped `Sys.Date()`). Server state is 4 `reactiveVal`s plus a `confirmed` gate reactive; re-running
an earlier stage (`observeEvent(input$validate, ...)`) resets `confirmed(FALSE)` so a stale
confirmation can never silently unlock exports for changed input (D5 in that plan). Returns a named
list of reactives (`mergedPedigree`, `issues`, `confirmed`) satisfying module-contract rule 2 even
though nothing in `appServer.R` currently reads them (module-contract rule 4's "the test suite is a
consumer" clause, already an accepted pattern — see §2.7).

**Applicability to #150:** the Confirm→Export shape (modal gate unlocking `downloadButton`s) transfers
directly. The Upload→Validate shape does not apply (§2.2) — #150 has no upload and nothing to
validate; `shared$currentPedigree` arrives already QC'd by `modInput`.

### 2.6 The existing `obfuscatePed()` test suite — read in full

`tests/testthat/test_obfuscatePed.R`, 3 `test_that` blocks (structure preservation + relationship
preservation + a `max(abs(delta)) <= maxDelta` bound on `birth`; map creation and shape; the name-
scrub regression from issue #136 D8). **No test pins independent-vs-linked per-column date
shifting** — nothing asserts that two Date columns for the same individual shift by *different*
amounts. This means §3 D3's recommended fix is not a breaking change against any existing pinned
assertion (verified by reading the file, not inferred from its existence).

### 2.7 Module-contract requirements for a new module

`docs/architecture/module-contract.md`: `modXUI(id) -> tagList`; `modXServer(id, ...) -> named list
of reactive()`s over the stable vocabulary (`pedigree`, `errors`, `isReady`, etc.); every server
argument that carries data is itself a `reactive()`; every returned element is read by *something*,
where "the test suite" counts (rule 4, citing `modCrossCenterIdentity`'s own precedent, §2.5).
`tests/testthat/test_moduleContract.R` mechanically asserts rule 2 via `shiny::testServer()` for
every `mod*Server` — a new module must be added there in the same slice that ships its server
function (Slice 2, §5).

### 2.8 `appUI.R`/`appServer.R` wiring convention

Every recent module (`modMatePair`, `modCrossCenterIdentity`, `modPotentialParents`) follows the
identical pattern: a `tabPanel("<Title>", icon = icon("<fa-icon>"), mod<X>UI("<id>"))` block in
`appUI.R` under a `# ====================` comment banner naming the issue, and a
`mod<X>Server("<id>", <reactive args>)` call in `appServer.R` with a comment block explaining *why*
each argument is wired the way it is (`R/appUI.R:225-275`, `R/appServer.R:444-461`).

### 2.9 The `data-ready`/`setDataReady` E2E-testability convention is universal, not optional

Every `mod*UI` function in `R/` (`modMatePair`, `modCrossCenterIdentity`, `modMarkerGenetics`,
`modBreedingGroups`, `modGeneticValue`, `modInput`, `modGeneticDiversity`, `modPyramid` — verified
via `grep` across all of `R/`, not sampled) sets `` `data-ready` = "false" `` and
`` `data-module` = "<name>" `` on its root `div`, then calls
`session$sendCustomMessage("setDataReady", list(selector = ..., ready = TRUE))` once its primary
content is ready. This is a structural requirement for the project's `shinytest2`/`chromote` E2E
convention (Phase 3E), not a per-module style choice — the new module must follow it.

### 2.10 No existing "institutional responsibility" disclaimer text anywhere in the app

`grep -rn "institutional|authorized|governance"` across `R/*.R` returns zero hits. The issue's
"warns that authorization/data-access policy remain institutional responsibilities" requirement has
no prior wording to reuse or extend — it is drafted fresh in this design (§3 D6) and will be this
app's first such disclaimer.

### 2.11 `getVersion(date = FALSE)` — the existing provenance-stamp helper

`R/getVersion.R`, already used by `.buildCrossCenterMergeProvenance()` (§2.5) for the same purpose:
stamping an exported artifact with the package version that produced it. Directly reusable for the
transformation manifest (§3 D4).

---

## 3. Design decisions

Ten decisions. D1, D2, D7, D9 are **forced** by the evidence above — not owner choices, listed for
completeness and to make the "why" explicit for the implementing session. D3–D6, D8, D10 are
**judgment calls**, ratified via a single `AskUserQuestion` round in §11.

**D1 (forced). Data source is `shared$currentPedigree`, not a file upload.** §2.2. The module takes
no `fileInput`; it reads the pedigree the curator is already working with in the current session.

**D2 (forced). No Validate stage; Preview stage does exist.** §2.2/§2.5. Unlike #149, there is
nothing to validate (`shared$currentPedigree` is already QC'd) — but a Preview stage showing a
sample of the *would-be* de-identified output before committing to export still has real value (the
curator sees exactly what will leave the building) and mirrors the Confirm-gate pattern's own
purpose. Two tabs: **Configure & Preview**, then **Export** (gated).

**D3 (judgment call — the session's central finding, §2.4/§2.6). Fix `obfuscatePed()`'s date
handling so all of one individual's Date columns shift by one shared per-individual offset, not
independent per-column offsets.** Concretely: add a new parameter,
`obfuscatePed(ped, size = 6L, maxDelta = 30L, existingIds = character(0L), map = FALSE, linkedDateShift = TRUE)`.
When `TRUE` (recommended default — §2.6 confirmed no existing test pins the old independent
behavior, so this is a safe default change, not a breaking one), draw **one** random offset per
individual (via `obfuscateDate()` called once against a synthetic single-column input, or an
equivalent per-row `runif()` draw) and apply it uniformly to every Date column for that row —
preserving exact inter-column gaps (`birth`→`exit`→`death`, and therefore `age`) while still moving
every date to an unpredictable absolute position. This directly closes the negative-age defect
found in §2.4. Framed like #149's own D10 ("whether to fix the newly-found data-loss now") — an
in-scope, `NEWS.Rmd`-documented additive behavior change to an already-shipped `@export`ed function,
shipped in the same slice as this design's own new work, not deferred to a separate future session.

**D4 (judgment call). Transformation manifest fields.** A `data.frame` (or a small named list,
matching `.buildCrossCenterMergeProvenance()`'s row-per-artifact shape, §2.5) containing: export
timestamp, package version (`getVersion(date = FALSE)`), the exact parameters used (`size`,
`maxDelta`, `linkedDateShift`), row count exported, and a copy of the D6 warning text — explicitly
**never** the id map itself (D5) and never any raw pre-obfuscation value. This is the "non-sensitive
... auditable" artifact the issue asks for: safe to attach to a data-sharing request as evidence of
*how* the export was produced, without revealing *what* it replaced.

**D5 (judgment call). "Keeps any ID map local to the authorized user" = the map downloads as its
own, separately labeled artifact to the same curator's browser — nothing new to build.** Shiny's
`downloadHandler()` always delivers to the requesting browser session; there is no server-side
persistence, email, or network transmission anywhere in this app to guard against. "Local" is
satisfied by construction. The concrete requirement is **labeling, not infrastructure**: the map
downloads as a distinctly named file (e.g. `reidentification_key_DO_NOT_SHARE_<date>.csv`) with its
own confirmation click separate from the de-identified pedigree's own download, so a curator cannot
mistake it for a shareable artifact.

**D6 (judgment call). Confirm-gate warning text (this app's first institutional-responsibility
disclaimer, §2.10).** Drafted, to be refined in the implementing session's own Pre-RED:
*"This export removes identifying ids, names, and shifts dates — it does not verify or enforce who
you may share it with. Confirming that your institution's data-sharing and authorization policies
permit this export and its intended recipient(s) is your responsibility, not this tool's."* Shown in
the `modalDialog()` confirm gate (mirroring §2.5's pattern) before the Export tab unlocks, and
repeated as static `helpText()` on the Configure tab so it is visible before the curator even
reaches Confirm.

**D7 (forced — already correct, confirmed not a new decision). `name` scrubbing is already handled.**
§2.1/§2.3. `obfuscatePed()` already drops `name` to `NA` (issue #136 D8). No new work.

**D8 (judgment call, recommend: disclose, don't scrub). Non-id/date/name fields
(`origin`/`population`/`status`/`condition`/`spf`/`departure`) pass through unchanged.** §2.3. These
are outside `obfuscatePed()`'s existing, already-ratified scope and outside issue #150's own explicit
ask (id/date/name only). Recommend: **do not silently scrub them** (that would be undisclosed scope
creep past what any prior session or this issue asked for) but **do disclose the limitation
explicitly** in both the D6 warning text and the D4 manifest ("fields other than id, dam, sire,
dates, and name are exported unchanged — review for sensitivity before sharing"), so a curator is
never misled into believing the export is fully sanitized.

**D9 (forced). No new de-identification primitive is needed beyond the D3 fix.**
`obfuscateId()`/`obfuscatePed()`/`obfuscateDate()` are reused as-is.

**D10 (judgment call). Tab placement: a new top-level tab, "De-Identified Export," mounted
immediately after "Cross-Center Identity."** §2.8. Matches the established one-feature-one-tab
convention (every recent feature — Mate Pair Analysis, Cross-Center Identity, Marker Genetics,
Potential Parents — is its own top-level `tabPanel`, never folded into an existing module).
Positioned next to Cross-Center Identity because both are governance/data-sharing-themed tools, a
thematic grouping with no functional dependency between them.

---

## 4. Interface catalog

| Interface | Kind | Input | Output | Error | Consumers |
|---|---|---|---|---|---|
| `obfuscatePed(ped, size, maxDelta, existingIds, map, linkedDateShift = TRUE)` | Modified existing `@export`ed function (D3) | pedigree `data.frame`; existing params; new `linkedDateShift` logical | pedigree (or `list(ped=, map=)` if `map=TRUE`) with `id`/`sire`/`dam` aliased, `name` scrubbed, Date columns shifted (linked or independent per `linkedDateShift`), `age` recomputed | unchanged (delegates to `obfuscateId()`) | The new module (Slice 2); any future/existing script caller; `NEWS.Rmd`-documented additive behavior change to the default |
| `.buildDeidentificationManifest(pedRows, size, maxDelta, linkedDateShift, warningText)` | New internal (`@noRd`) helper, mirrors `.buildCrossCenterMergeProvenance()` (§2.5) | export parameters + row count | one-row `data.frame`, the D4 manifest shape | none (pure) | The new module only |
| `modDeidentifiedExportUI(id)` | New Shiny module UI, `@export` | namespace id | `tagList`/`div` — Configure & Preview tab + Export tab (module-contract rule) | n/a | `appUI.R` |
| `modDeidentifiedExportServer(id, pedigree)` | New Shiny module server, `@export` | `pedigree` — a `reactive()` (D1) | named list of `reactive()`s: `exportedPedigree`, `map`, `manifest`, `confirmed` (module-contract rules 1/2) | `req(pedigree())` — an absent pedigree halts silently, matching every existing module (module-contract rule 5) | `appServer.R`; `tests/testthat/test_moduleContract.R` |

---

## 5. Implementation plan — vertical slices (one session each)

Matches the two-slice shape used by every prior item in this cluster (#146/#147/#149/#151): Slice 1
is core R-function-level work, script-callable only, no UI; Slice 2 is the full module plus
documentation. Each slice is its own future session per `SESSION_RUNNER.md`'s own session-boundary
requirement — **this design session does not implement either slice.**

### Slice 1 — Core function work (R-function level only, no UI)

**Touches:** `R/obfuscatePed.R` (D3's `linkedDateShift` parameter + implementation);
`tests/testthat/test_obfuscatePed.R` (new RED tests: a regression reproducing §2.4's exact
negative-age scenario, proving `linkedDateShift = TRUE` closes it while `linkedDateShift = FALSE`
still reproduces the old independent behavior for anyone who explicitly opts out); a new
`.buildDeidentificationManifest()` helper (D4) in a new `R/modDeidentifiedExport.R` file (internal,
`@noRd`, defined ahead of the Slice-2 module functions in the same file — matching
`.buildCrossCenterLineagePreview()`'s placement precedent in `R/modCrossCenterIdentity.R`, §2.5) with
its own dedicated test file.

**What DONE looks like:** `obfuscatePed(..., linkedDateShift = TRUE)` never produces a negative
`calcAge()` result for any Date-column combination, proven by re-running §2.4's exact reproduction
fixture as a permanent regression test; `linkedDateShift = FALSE` still reproduces the old
(independent, occasionally-negative) behavior, proving the parameter is a real toggle, not a no-op;
`.buildDeidentificationManifest()` returns the D4 field set for a representative input.

**Verification:** full clean regression suite 0 failed/0 error; `lintr::lint_package()` 0 lints on
touched files; `devtools::check()` at the established pre-existing baseline, 0 new; `_pkgdown.yml`
reference-coverage entry for `.buildDeidentificationManifest`'s eventual public sibling if any (none
expected — it's internal); `NEWS.Rmd` entry for `obfuscatePed()`'s new parameter and its default
behavior change (per this project's own "new parameter on an already-documented function" checklist,
`CLAUDE.md`).

**Session boundary:** this phase is one session. Close out when done.

### Slice 2 — Full module: UI, confirm gate, exports, documentation

**Touches:** `R/modDeidentifiedExport.R` (adds `modDeidentifiedExportUI`/`modDeidentifiedExportServer`
to the file Slice 1 started); `R/appUI.R` (new tab, §2.8/D10); `R/appServer.R` (new
`modDeidentifiedExportServer("deidentifiedExport", pedigree = reactive(shared$currentPedigree))`
call, §2.2/D1); `tests/testthat/test_modDeidentifiedExport.R` (new); `tests/testthat/
test_moduleContract.R` (add the new module, §2.7); `_pkgdown.yml` (reference coverage);
`NEWS.Rmd`/`NEWS.md`; a new section in `vignettes/articles/colony-manager-guide.qmd` and/or
`vignettes/manual_components/` (Session 436 tutorial/article checklist — new Shiny tab).

**What DONE looks like:** a curator with a pedigree already loaded can open the new tab, configure
`size`/`maxDelta`/`linkedDateShift`, see a live preview of de-identified sample rows plus the D6
warning text, click through the modal confirm gate, and download 3 artifacts (de-identified
pedigree; re-identification map, distinctly labeled per D5; the D4 manifest) — each only after
confirmation, mirroring §2.5's gate pattern. `data-ready`/`setDataReady` wired per §2.9. Live
`shinytest2`/`chromote` smoke test (Phase 3E) confirms the full configure→preview→confirm→export
sequence against a real running app with 0 console errors, and visually confirms the D3 fix (a
short-lived individual's exported `age` is non-negative).

**Verification:** same matrix as Slice 1, plus the live Phase 3E smoke test; citation checklist
(#120) N/A — no new displayed statistic/estimator, matching the precedent set for #133's `affected`
flag and #136's `name` label (a data transformation, not a genetic metric); `a2interactive.Rmd`
coverage deferred per its own standing rule (a Shiny-UI-only feature, Session 450/478 checklist).

**Session boundary:** this phase is one session, separate from Slice 1. Close out when done.

---

## 6. Impact analysis

| System | Impact | Action required |
|---|---|---|
| `obfuscatePed()` (all existing callers) | New optional parameter, default changes date-shift behavior from independent-per-column to linked-per-individual | `NEWS.Rmd` entry (D3); no existing test breaks (§2.6, verified) |
| `R/appUI.R`/`R/appServer.R` | Additive: one new tab, one new module-server call | No change to any existing tab or reactive |
| `shared$currentPedigree` consumers (every other module) | None | This module only *reads* the shared pedigree; it never writes to `shared` |
| `module-contract.md` guard test | New module must satisfy rule 2 | Add to `test_moduleContract.R` in Slice 2 |
| What does **not** change | The four existing de-identification primitives' core algorithms (aliasing, drop-name); `.nprcColumnSchema`; any other module's wiring | — |

---

## 7. Here be dragons

**Dragon 1 (the session's central finding — §2.4).** Independent per-column date obfuscation can
invert `birth`/`exit`/`death` order and produce a negative `age`, empirically confirmed at 25% on a
small realistic-gap fixture. D3's `linkedDateShift` fix must land in Slice 1, not be deferred —
shipping the module (Slice 2) against the *old* `obfuscatePed()` default would ship a data-sharing
feature whose flagship correctness promise ("relationship-preserving") is demonstrably violated for
a realistic subset of colony pedigrees.

**Dragon 2.** `linkedDateShift`'s implementation must draw genuinely **one** random value per
individual and apply it to every Date column for that row — a naive per-row loop that calls
`obfuscateDate()` once per column with the *same seed state* is not equivalent (R's RNG stream
advances per draw regardless of a fixed seed at the top) and would silently reproduce the original
bug. The implementing session's own Pre-RED should verify this mechanically (a regression test
asserting `exit - birth` is *invariant* under obfuscation, not merely non-negative — invariance is
the stronger, correct claim `linkedDateShift = TRUE` should satisfy).

**Dragon 3.** `obfuscateDate()`'s own re-draw loop (`repeat { ... if (obfuscatedDate >= minDate)
break }`) enforces a *floor* (`minDate`, defaulting to `baseDate - maxDelta`) but not a *ceiling* —
two Date columns for the same individual, even under D3's linked-per-individual offset, must be
verified to preserve their **relative order**, not just each individually satisfy its own floor. The
linked-offset design (§3 D3) achieves this by construction (identical additive shift preserves any
original difference exactly) — but this must be proven by test, not asserted by design-doc prose
alone, per this project's own "verify assumptions" discipline (`ARCHITECTURE_WORKSTREAM.md` Phase 2
Step 7).

**Dragon 4.** `qcStudbook()`'s recorded `age` (pre-obfuscation) and the *recomputed* `age`
`obfuscatePed()` produces post-obfuscation are not required to match the original `age` value — only
to be internally consistent with the (now-shifted) `birth`/`exit` pair. The Preview tab (D2) should
make clear to the curator that displayed ages are recomputed, not the original recorded values,
so a reviewer comparing exported vs. internal records does not mistake an expected discrepancy for a
bug.

---

## 8. Alternatives considered

| Alternative | Pros | Cons | Why rejected |
|---|---|---|---|
| Require a fresh file upload (mirror #149's shape exactly) | Maximal consistency with the one existing precedent | Redundant — the pedigree is already loaded and QC'd; forces a curator to re-export-then-re-import their own already-open data | §2.2 — the two features solve genuinely different problems (compare-two-files vs. export-the-one-I-have) |
| Fix `obfuscatePed()`'s date defect by *clamping* (force `exit >= birth` post-hoc) instead of linked-offset shifting | Smaller code change | Clamping distorts the *shifted* gap non-uniformly (some pairs get compressed, others don't), which is a subtler correctness problem than the one it fixes, and doesn't address `death` as a third column | D3's linked-offset approach preserves gaps exactly, is simpler to reason about, and is provable by invariance (Dragon 2), not just bounds-checking |
| Scrub `origin`/`population`/`status`/`condition` too (maximal de-identification) | More conservative privacy posture | Explicit scope creep past both the issue's own text and `obfuscatePed()`'s existing, already-ratified scope (§2.3); risks silently discarding demographically load-bearing data a legitimate data-sharing agreement may need | D8 — disclose, don't silently over-scrub; a future issue can scope this deliberately if requested |
| Build real role/auth-based access control | Matches the issue's aspirational "curator-controlled" language literally | The audit's own Finding #3 explicitly rules this out as out-of-scope for this item — the codebase has zero identity infrastructure to build on, and inventing one here would be exactly the "astronaut architecture" anti-pattern (`ARCHITECTURE_WORKSTREAM.md` §Common Anti-Patterns) for a single-feature ask | Owner ratified the audit's own framing in §1.2/§11: UX gating + warning text, not real access control |

---

## 9. Close-out checklist mapping

| Checklist (`CLAUDE.md`) | Applies to | When |
|---|---|---|
| Citation coverage (issue #120) | N/A — no new displayed statistic | — |
| Tutorial/article documentation (Session 436) | Yes — new Shiny tab | Slice 2 |
| `NEWS.Rmd` entry | Yes — new module (Slice 2) **and** a new parameter + default-behavior change on `obfuscatePed()` (Slice 1) | Both slices |
| GitHub issue close-out | Issue #150 stays open until both slices ship, matching every other item in this cluster | Slice 2's own close-out |
| Lint | Both slices, touched files only | Both slices |
| `_pkgdown.yml` reference coverage | Slice 2 (new exported `modDeidentifiedExportUI`/`modDeidentifiedExportServer`) | Slice 2 |
| `a2interactive.Rmd` (deferred, Session 450/478) | N/A this feature is Shiny-UI-only, not a new script-callable function beyond `obfuscatePed()`'s existing coverage | Deferred standing item |

---

## 10. Provenance

- Issue: [#150](https://github.com/rmsharp/nprcgenekeepr/issues/150).
- Source audit: `docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` Finding #3 /
  Recommendation 3 (the owner-decision gate this session resolved).
- Closest structural precedent: `docs/planning/issue149-cross-center-identity-mapping-workflow-plan.md`
  (§2.5/§2.7 above cite it directly).
- Session: 514, 2026-08-10. Direct source reads throughout (`R/obfuscatePed.R`,
  `R/obfuscateId.R`, `R/obfuscateDate.R`, `R/mapIdsToObfuscated.R`, `R/calcAge.R`,
  `R/columnSchema.R`, `R/modCrossCenterIdentity.R`, `R/appServer.R`, `R/appUI.R`,
  `docs/architecture/module-contract.md`, `tests/testthat/test_obfuscatePed.R`) plus one seeded
  empirical `Rscript` verification (§2.4) — no finding in this document is asserted from memory or
  from the issue text alone.

---

## 11. Ratification status — forced vs. judgment-call decisions

**Forced (no vote needed, listed for the implementing session's benefit):** D1, D2, D7, D9 (structural
— derived directly from how the codebase already works, §2.2/§2.5/§2.1/§2.1) plus D4 and D5
(mechanical — D4 mirrors `.buildCrossCenterMergeProvenance()`'s existing shape verbatim, §2.5; D5 is
satisfied by Shiny's own `downloadHandler()` delivery mechanics with no new infrastructure, §2.5).

**Genuine judgment calls put to the owner in one `AskUserQuestion` round:** D3 (fix
`obfuscatePed()`'s date handling now, in Slice 1, default `linkedDateShift = TRUE`), D6 (warning
text substance/tone), D8 (disclose non-id/date fields rather than scrub them), D10 (tab placement
after Cross-Center Identity).

### Ratification outcome (2026-08-10, this session)

Owner selected this document's own recommended option in all four cases, via a single
`AskUserQuestion` round:

- **D3 — fix now, default `TRUE`.** `obfuscatePed()` gains `linkedDateShift`, defaulting to the
  safer linked-per-individual shift, shipped in Slice 1 as an additive `NEWS.Rmd`-documented
  behavior change (not deferred, not opt-in-only).
- **D6 — explicit warning text, as drafted.** The full disclosure sentence in §3 D6 ships verbatim
  (subject to the implementing session's own Pre-RED wordsmithing, not a substance change), shown
  both in the modal confirm gate and as static Configure-tab text.
- **D8 — disclose, don't scrub.** `origin`/`population`/`status`/`condition`/`spf`/`departure` stay
  outside `obfuscatePed()`'s scope; the D6 warning text and D4 manifest both carry the disclosure
  note.
- **D10 — mounted immediately after "Cross-Center Identity."** Confirmed as the implementing
  session's `appUI.R` insertion point.

No changes requested to any recommended design. **This design is ratified and ready for Slice 1
implementation in a future session** — matching the #133/#136/#137/#145/#146/#147/#149/#151
precedent of a design-only session with zero `R/`/`tests/`/`man/` changes. Issue #150 stays
intentionally open (design ratified, not yet implemented); no `gh issue close` this session.
