# Issue #30 Plan — Resolve the `.lintr` line-specific exclusions (and the residual lint backlog)

**Tracks:** GitHub issue **#30** ("work on use of lintr until satisfied with code style").
**Authored:** Session 53 (2026-06-11), **planning session**. The TDD code-phases (RED/GREEN/REFACTOR) are **inapplicable to this document** — it is a plan. Each implementation phase below is its own strict-TDD session (mostly REFACTOR — behavior-preserving — with one RED→GREEN→REFACTOR for an exported-function contract).
**Evidence base:** every line number, lint, and fix below was verified **firsthand** this session — a project-config `lintr::lint_package(parse_settings = FALSE)` run that *bypasses* the `.lintr` exclusions (so the suppressed lints are visible), cross-checked by an 18-file parallel examination workflow (`wf_c7863094-8f1`: one agent per excluded file proposing the exact fix + rating behavior-change risk, then an adversarial verifier on every behavior-affecting fix and every commented-code deletion). **Three agent conclusions were corrected by adversarial verification or my own reproduction** — see §6 (here-be-dragons); the dispositions in §4 are the corrected ones.

> **Scope.** This is the planning deliverable. **No `R/`, `tests/`, or `.lintr` content is changed by writing it.** Implementation happens in the subsequent sessions, one phase at a time (FM #18/#25 — do **not** bundle plan + implementation, and do **not** bundle phases). The user's explicit ask was the **line-specific exclusions** (§4); the residual backlog (§7) is the broader #30 campaign and is planned but lower-priority.

---

## 1. Context

### What issue #30 says
> `.lintr` has `commented_code_linter` commented out because it reports not finding it in the available linters. Obviously it is available. Many pieces of lint remain. Several places should be excluded from specific linters.

Three distinct asks: (a) the `commented_code_linter` confusion, (b) "many lint remain," (c) "several places should be excluded from specific linters." This plan addresses all three, with the **line-specific exclusions** (the user's focus this session) as the primary deliverable.

### How `.lintr` suppresses lints today
`.lintr` (lines 14-37) has an `exclusions: list(...)` with two kinds of entries:
- **Directory excludes** — `"inst/application"`, `"inst/extdata"`, `"tests"`, `"vignettes"`. These are wholesale and intentional (e.g. `tests` is lint-exempt by design — [lint-net-zero]). **Out of scope; leave as-is.**
- **18 `"file" = line(s)` excludes** — hardcoded line numbers in `R/` files that suppress a specific lint at a specific line. **These are the deliverable.**

### The load-bearing hazard: the line-number shift trap ([lint-net-zero], Learning #7)
Hardcoded line-number exclusions are fragile: any edit that inserts/removes lines *above* a suppressed line shifts it, resurfacing a pre-existing intentionally-suppressed lint (or, conversely, leaving the exclusion pointing at the wrong line — **already happened twice in this repo**, see §4). **Consequence for this plan:** each phase must **fix a file's code and delete that file's exclusion entry in the same commit**, so no stale line numbers are ever left behind. Never "fix the code but keep the exclusion" and never "renumber" — remove.

### Current lint counts (firsthand, project linter config)
- **41 lints** are suppressed by the 18 line-specific exclusions (the audit target).
- **152 lints** currently fire *despite* `.lintr` (the "many lint remain" residual — §7).
- **193 lints total** in `R/` if every line-specific exclusion were removed (= 41 + 152).
- CI `lint.yaml` runs `lintr::lint_package()` with `LINTR_ERROR_ON_LINT: true` → **any** lint reds the `lint` check. This is the last non-green check on the master CI matrix (per Session 52 handoff).

### Reproduction commands (firsthand, re-runnable)
```r
# All R/ lints with the project linter config, IGNORING the line excludes
# (parse_settings = FALSE => .lintr not read; supply linters + dir-excludes):
library(lintr)
linters <- linters_with_tags(
  tags = c("style","best_practices","package_development","readability"),
  condition_call_linter = NULL, cyclocomp_linter = NULL, indentation_linter = NULL,
  line_length_linter(80), object_length_linter = NULL,
  object_name_linter(styles = c("snake_case","CamelCase","camelCase")),
  object_overwrite_linter = NULL, todo_comment_linter = NULL,
  undesirable_operator_linter = NULL)
lint_package(".", linters = linters,
             exclusions = list("inst","tests","vignettes"),
             parse_settings = FALSE)            # => 193 in R/ (exclusions bypassed)
lint_package(".")                               # => 152 residual (full .lintr)
```
**⚠ Auditing trap:** a single-file `lint("R/foo.R")` defaults to `parse_settings = TRUE`, which *reads `.lintr` and applies the very exclusion you are auditing*, so it reports "No lints found" and looks stale. **Always pass `parse_settings = FALSE` when probing an excluded line.** (One examination agent was fooled by exactly this — §6.)

---

## 2. `commented_code_linter` — the issue #30 confusion, resolved

`.lintr:4` has `#commented_code_linter = NULL,` (commented out). The linter **is active** — it fires 27 times in `R/` (all currently at excluded lines). The author's "reports not finding it in the available linters" was a `linters_with_tags()` modify error (referencing a linter not in the selected tag set, or a version artifact); commenting the line out left the linter **enabled** via the tag set. **Resolution:** keep `commented_code_linter` on, clean the commented-out code (Phase 1/4), and **delete the dead `#commented_code_linter = NULL` line** from `.lintr` for clarity (it does nothing). No decision needed — this is a no-op cleanup folded into Phase 1.

---

## 3. Two pre-existing `.lintr` config bugs (independent of any code fix)

| Bug | Evidence | Fix | Phase |
|---|---|---|---|
| **Filename case mismatch** — `.lintr:18` lists `"R/CheckRequiredCols.R"` but the file is `R/checkRequiredCols.R` (lowercase `c`). | Matches on case-insensitive macOS (so it "works" locally) but **not on the case-sensitive Linux CI runner** → the `sapply` lint at L34 fires in the CI `lint` job. | **✅ Casing FIXED in Session 55** (`R/CheckRequiredCols.R` → `R/checkRequiredCols.R`) at the owner's request; the entry itself is deleted in Phase 4 once L34's code is refactored. | ~~1 or 3~~ → **done S55** |
| **Stale exclusion** — `.lintr:28` `"R/getPyramidPlot.R" = 25L:27L` suppresses **zero** lints (lines 25-27 are roxygen `@examples`). The file's real lints are at L16, L38, L41-43. | `parse_settings=FALSE` lint of the file shows lints only at 16/38/41-43; none at 25-27. A [lint-net-zero] line-shift orphaned this entry. | Delete the `25:27` entry; handle the real lints (Phase 2). | 2 |

---

## 4. The deliverable — disposition of all 18 line-specific exclusions

41 suppressed lints across 18 entries. After examination + adversarial verification + firsthand reproduction, the dispositions are:

- **FIX (15 entries, ~38 lints):** clean the code, then delete the exclusion. 10 are behavior-none; 5 are low-risk and were verified behavior-safe.
- **KEEP-EXCLUDE (1 entry, 14 lints):** `makeGeneticDiversityDashboard.R` — an explicit author won't-delete decision (§6).
- **REMOVE-STALE + FIX real lints (1 entry):** `getPyramidPlot.R` (§3).
- **FIX-not-stale (set_seed):** the exclusion looks stale but removing it alone re-fires the lint — a stray `#'` must be stripped (§6).

### 4A. Behavior-NONE fixes (REFACTOR; existing tests guard; safest)

| # | File:line | Suppressed lint | Fix | Notes |
|---|---|---|---|---|
| 1 | `checkRequiredCols.R:34` | `undesirable_function` (`sapply`) | Replace the ragged `as.character(unlist(sapply(...)))` with `requiredCols[!requiredCols %in% cols]` | **⚠ RECLASSIFIED to Phase 4 by Session 55.** Adversarial verification + firsthand repro proved this is NOT behavior-none: on out-of-contract `NA`-in-`cols` the old `sapply`/`if` throws `"missing value where TRUE/FALSE needed"` while `%in%` returns the missing cols cleanly. Exported fn → RED→GREEN→REFACTOR with an NA-contract test first (§5 Phase 4). Non-NA output IS byte-identical. **Also fixes the §3 casing bug.** |
| 2 | `convertFromCenter.R:37` | `unnecessary_nesting` | The `if` branch always `stop()`s → drop `} else {`, de-indent the two assignments. | Identical control flow. |
| 3 | `fillGroupMembers.R:46` | `unnecessary_nesting` | `if`-branch ends in `return(groupMembers)` → drop the `else`, de-indent `available <- makeAvailable(...)`. | Identical. |
| 4 | `hasGenotype.R:38` | `unnecessary_nesting` | Collapse `else { if (...) ... }` → `else if (...)`. Preserve the existing `# nolint: if_not_else_linter`. | Logically identical (prior conditions short-circuit). |
| 5 | `getLkDirectAncestors.R:26,29,35` | `undesirable_function` (`source`) | **Rename the local string variable `source`** (e.g. `msgSource`) and its two uses. | **NOT stale** (§6) — `undesirable_function_linter` flags the *symbol* `source` shadowing the base fn. Pure local rename, zero behavior change. |
| 6 | `getLkDirectRelatives.R:31` | `undesirable_function` (`source`) | Same rename as #5; **also delete the now-redundant inline `# nolint: undesirable_function_linter` at L34/L40**. | Unifies the two sibling files (currently handled inconsistently — one via `.lintr`, one via inline nolint). |
| 7 | `saveDataframesAsFiles.R:23` | `unnecessary_lambda` | Replace `function(df) inherits(df, "data.frame")` with `inherits` passed directly to `vapply(..., FUN.VALUE = logical(1L), what = "data.frame")`. | Exactly equivalent. |
| 8 | `getErrorTab.R:15-19,22` | `commented_code` (×6) | **Delete the dead commented UI block (lines 14-25 in full**, incl. the linter-unflagged fragment lines). | Abandoned alternative `tabPanel`/`tags$style` layout; the CSS is **already live** in `modInput.R:34-40`, so nothing is lost (verifier-confirmed). |
| 9 | `get_elapsed_time_str.R:19,21` | `commented_code` (×2) | Delete the two commented-out R lines (duplicate the `@examples` block); reword the L18/L20 usage note as prose. | Information preserved in `@examples`. |
| 10 | `print.summary.nprcgenekeeprErr.R:23,36,50,55` | `commented_code` (×4) | Delete the commented debug `cat()` (23/50) and `NextMethod()` (36/55). | **Preserve the design intent of 36/55 as a prose comment** — they document that the method *deliberately does not delegate* to `NextMethod` (verifier flag). |

### 4B. Behavior-SENSITIVE fixes (verified safe, low risk; REFACTOR, but see #11)

| # | File:line | Lint | Fix | Why low-risk |
|---|---|---|---|---|
| 11 | `addSexAndAgeToGroup.R:21` | `undesirable_function` (`sapply`) | **Recommended:** `ped$sex[match(ids, ped$id)]` (vectorized, preserves the factor + levels). *(The agent's `vapply`-rebuild-factor also works but is clumsier.)* | **⚠ Exported fn.** Happy path is `identical()` to current (agent-verified, 5 tests pass), but `sapply`→`vapply` *changes error semantics on out-of-contract input* (character `sex` column, duplicate ids). `match()` avoids the `vapply` error divergence. **Pin the contract with a RED test first** (see §5 Phase 4 — this is the one RED→GREEN→REFACTOR). |
| 12 | `correctParentSex.R:75` | `unnecessary_nesting` | Invert to `if (!reportErrors) { ...correction...; return(sex) }`, then fall through to the report-collection body (its trailing `list(...)` stays the implicit return). Update the `Mirror the report branch above`→`below` comment. | **Verified safe** (verifier ran all 14 `test_correctParentSex.R` assertions identical; return types, the `stop()` conflict path, and the NEW-37 H/U exemption all preserved). |
| 13 | `create_wkbk.R:55` | `unnecessary_nesting` | Invert the inner `if (replace)` to a guard clause: handle `!replace` (`warning` + `return(FALSE)`) first, then `file.remove(file)` as the tail. **Keep the outer `if (file.exists(file))` wrapper.** | **Verified safe** (return value + warning text identical for both `replace` branches). The outer guard is load-bearing — without it `file.remove` runs unconditionally. |
| 14 | `fillGroupMembersWithSexRatio.R:101` | `unnecessary_nesting` | Collapse `else { if (...) ... }` → `else if (...)`. **Also delete the inline `# nolint unnecessary_nesting_linter` at L100** (double-suppressed today). | **Verified safe** (`else { if }` ≡ `else if` in R; both `sample()`/`removeSelectedAnimalFromAvailableAnimals()` side effects and the condition preserved verbatim). |
| 15 | `setExit.R:56` | `undesirable_function` (`mapply`) | `as.Date(unlist(Map(chooseDate, ...)), origin = timeOrigin)`. **Keep the `unlist()` wrapper** (reproduces `mapply`'s `SIMPLIFY=TRUE` flattening that strips the Date class for re-coercion). **Reword the L51-55 comment** (it narrates `mapply` by name). | **Verified safe** (`identical()` across mixed-NA / single-row / all-NA cases; 10 `test_setExit.R` assertions green; the `nrow==0` guard at L46 rules out the empty-input divergence). |

### 4C. KEEP-EXCLUDE / stale-config

| # | File:line | Lint | Disposition | Why |
|---|---|---|---|---|
| 16 | `makeGeneticDiversityDashboard.R:12-55` | `commented_code` (×14) | **KEEP-EXCLUDE — leave the entry and the file untouched.** | **Author won't-delete decision (NEW-20).** SESSION_NOTES repeatedly states "Do NOT delete" — the file is retained early-dev scaffolding (the whole function body is commented; `getProportionLow` is its entangled retained consumer). It is `.Rbuildignore`'d → ships in no built package, and the 14 lints are already neutralized by the live `12L:55L` exclusion. The examination agent recommended deleting the file; **adversarial verification overrode it** as an author-decision reversal (and a deletion would trigger the namespace-fallout of PROJECT_LEARNINGS #35). *Optional:* convert the line-range exclusion to a single inline `# nolint start` / `# nolint end` block at the top/bottom of the commented region to make it line-shift-proof — but lowest priority. |
| 17 | `getPyramidPlot.R:25-27` | **stale (0 lints)** + real lints at 16/38/41-43 | **REMOVE the `25:27` entry; FIX L16 + L38; KEEP-EXCLUDE L41-43.** | §3. Real lints: **L16** `line_length` (81 chars → wrap the roxygen `@param`); **L38** `implicit_integer` (`12` → `12.0`, preserving the double age product — *not* `12L`); **L41-43** `undesirable_function` (`par`) → **keep**: the `opar <- par(no.readonly=TRUE); on.exit(par(opar)); par(...)` save/restore is the CRAN-standard dependency-free idiom; `withr::with_par` would add a dependency + restructure control flow (the `@return` documents `par("mar")`). Use an **inline `# nolint: undesirable_function_linter`** on L41-43 (robust) instead of a new hardcoded line-number exclusion. |
| 18 | `set_seed.R:11` | `commented_code` | **FIX (not stale) — strip the stray trailing `#'`.** | Looks like a stale roxygen-line exclusion, **but removing the exclusion alone re-fires the lint** (verifier reproduced): line 11 ends with a stray `#'` after `do.call().` that fools `commented_code_linter` *and* leaks literally into `man/set_seed.Rd` `\details{}` as `...do.call().#'`. Stripping the trailing `#'` removes the lint **and** fixes the rendered man-page bug. Pure documentation change. |

---

## 5. Implementation phasing (vertical slices — one session each)

Each phase is a **separate session** (FM #18/#25). Each file is a **vertical slice**: fix code → delete/adjust its `.lintr` exclusion in the **same commit** → re-lint that file (`parse_settings=FALSE`) shows 0 → run the file's `testthat` test → close out. Ordered safest-first so confidence compounds.

> **Per-phase DONE = (a)** every targeted exclusion entry removed from `.lintr`; **(b)** `lint_package(".")` shows **no new** lints vs the phase's starting residual (and fewer overall); **(c)** the touched functions' `testthat` files pass; **(d)** `devtools::check()` clean (no new NOTE/WARNING). **Verification commands** are identical each phase — see §8.

### Phase 1 — Comment/doc-only cleanup + config hygiene *(behavior-none; no logic touched)*
- **Files:** `getErrorTab.R` (#8), `get_elapsed_time_str.R` (#9), `print.summary.nprcgenekeeprErr.R` (#10), `set_seed.R` (#18 — strip `#'`).
- **`.lintr`:** remove those 4 exclusion entries; delete the dead `#commented_code_linter = NULL` line (§2); **keep** the `makeGeneticDiversityDashboard` entry (#16).
- **TDD:** REFACTOR (comments only). No new tests needed; `devtools::document()` after the `set_seed.R` `#'` strip (it changes `man/set_seed.Rd`).
- **DONE:** 4 `commented_code` exclusions gone; `man/set_seed.Rd` no longer contains `#'`; check clean.

### Phase 2 — `getPyramidPlot.R` (the mixed stale/real-lint file) *(#17)*
- Remove the stale `25:27` exclusion; wrap L16; `12`→`12.0` at L38; inline `# nolint` for the `par` save/restore at L41-43.
- **TDD:** REFACTOR. Guard: the pyramid-plot tests (`test_getPyramidPlot*` / `test_modPyramid`) stay green.
- **DONE:** `getPyramidPlot.R` lint-clean (0 lints under `parse_settings=FALSE`); no `25:27` entry.

### Phase 3 — Behavior-none logic refactors *(§4A #2-7; existing tests guard)* — **DONE (Session 55)**
- **Files (6 done):** `getLkDirectAncestors.R`, `getLkDirectRelatives.R`, `saveDataframesAsFiles.R`, `convertFromCenter.R`, `fillGroupMembers.R`, `hasGenotype.R`. **`checkRequiredCols.R` (§4A #1) was RECLASSIFIED to Phase 4** mid-session: adversarial verification proved its `%in%` fix changes exported NA-edge error semantics (owner-approved deferral via `AskUserQuestion`).
- **TDD:** REFACTOR. Each file's `test_*` stayed green; all 6 adversarially verified behavior-preserving; full suite 2140/0/0/159 (S49 baseline); `lint_package()` = 0.
- **DONE:** 6 exclusions gone; the two `source`-rename siblings unified (inline nolints at `getLkDirectRelatives.R:34/40` deleted). `checkRequiredCols`'s exclusion retained for Phase 4 (its code refactor is deferred there); its **§3 casing bug WAS fixed this session** at the owner's request (`R/CheckRequiredCols.R` → `R/checkRequiredCols.R`), so the entry now correctly suppresses the L34 lint on case-sensitive CI too.

### Phase 4 — Behavior-sensitive refactors *(§4B #11-15 + `checkRequiredCols` #1; verified safe)*
- **Files:** `correctParentSex.R` (#12), `create_wkbk.R` (#13), `fillGroupMembersWithSexRatio.R` (#14), `setExit.R` (#15) — all **REFACTOR** (verified behavior-preserving; existing tests guard).
- **TWO RED→GREEN→REFACTOR slices (both exported; the refactor changes error semantics on out-of-contract input):**
  - **`addSexAndAgeToGroup.R` (#11):** **RED:** test pinning the current contract (factor `sex` output + levels on the happy path; documented behavior on a missing id). **GREEN/REFACTOR:** apply `match()`; confirm the new test + the 5 existing pass.
  - **`checkRequiredCols.R` (#1 — reclassified from Phase 3 by Session 55):** `sapply`→`%in%` turns an `NA`-in-`cols` error (`"missing value where TRUE/FALSE needed"`) into a clean missing-cols return (proven by S55 adversarial verify + firsthand repro; non-NA output byte-identical). **RED:** test pinning the desired NA behavior — decide whether to preserve the error or adopt the more-robust return (recommend the latter, documented as intentional). **GREEN/REFACTOR:** apply the chosen form, then **delete the `.lintr` entry** (its casing was already fixed in S55 → `R/checkRequiredCols.R = 34L`).
- **TDD gate:** declare phase at top; `AskUserQuestion` at `PRE-RED→RED` and `RED→GREEN` for EACH of the two slices (per the project TDD contract).
- **DONE:** 6 exclusions gone (5 §4B + `checkRequiredCols`); `.lintr` line-specific excludes reduced to just `makeGeneticDiversityDashboard` (kept) — every other R-file line exclusion removed.

### Phase 5 (optional / broader #30) — the residual 152 — see §7.

---

## 6. ⚠ Here be dragons (Learning #3 — not all sites are equally tractable)

1. **`makeGeneticDiversityDashboard.R` — do NOT delete (#16).** It is all commented-out code and *looks* deletable, but the author explicitly retained it (NEW-20, "Do NOT delete" in SESSION_NOTES). Keep the file **and** its exclusion. The examination agent got this wrong; adversarial verification caught it. If a future session "tidies" this, it reverses an author decision and triggers namespace fallout (Learning #35).
2. **`set_seed.R:11` is NOT a stale exclusion (#18).** Removing the entry alone re-fires the lint. The fix is stripping a stray `#'`. Verify with `lint("R/set_seed.R", linters=<project>, parse_settings=FALSE)` *after* the strip → must be "No lints found."
3. **`getLkDirectAncestors.R:26/29/35` is NOT stale (#5).** An examination agent ran `lint()` with `.lintr` active (default `parse_settings=TRUE`), so the exclusion hid the lints and it reported "stale." Reproduced with `parse_settings=FALSE`: the `source` symbol **is** flagged. The fix is a variable rename, not an exclusion deletion. **General rule:** when auditing any exclusion, always use `parse_settings=FALSE` (§1).
4. **`addSexAndAgeToGroup.R:21` is the only real behavior risk (#11).** Exported; `sapply`→`vapply` diverges on out-of-contract input. Use `match()` and a RED contract test. This is the single "load-bearing assumption" of the whole cleanup.
5. **Line-shift discipline ([lint-net-zero]).** Always fix-code-and-delete-exclusion in the *same* commit. When a file fix changes line counts, *other files'* exclusions are unaffected (they're per-file), but never leave a fixed file's own entry pointing at a moved line.
6. **`checkRequiredCols.R` (#1) is a SECOND behavior risk, found by Session 55 — not just `addSexAndAgeToGroup`.** Its `sapply`→`%in%` fix *looks* behavior-none but changes exported error semantics on `NA`-in-`cols` (error → clean return), and there is no clean lint-passing rewrite that preserves the exact NA-error (it is inherent to the `sapply`/`if` structure). Treat as RED→GREEN→REFACTOR with an NA-contract test, exactly like #11. **General lesson:** an "obviously equivalent" `*apply`/`%in%` swap on an EXPORTED function can still diverge on NA / duplicate / out-of-contract input — verify adversarially before classifying behavior-none.

---

## 7. The residual 152 lints (broader #30 — "many lint remain")

These fire today despite `.lintr`, concentrated in the Shiny `mod*.R` files. Not the user's primary ask this session, but planned for completeness. **Phase by file** (each `mod*.R` a vertical slice), after Phases 1-4.

| Linter | Count | Where (top) | Fix shape | Note |
|---|---|---|---|---|
| `implicit_integer` | **74** | `modInput` 22, `modORIPReporting` 16, `modPedigree` 15, `modBreedingGroups` 8, `appServer` 6, `modGeneticValue` 5 | add `L` (e.g. `column(width = 12L)`) **or disable the linter** | **⚠ AUTHOR DECISION — §9.** 49% of the residual; all in Shiny UI layout (`column(width=)`, `colspan=`). |
| `line_length` | 21 | `modInput` 11, `modBreedingGroups` 5, `modPedigree` 3 | wrap to ≤80 | mechanical |
| `brace` | 16 | `modSummaryStats` 10, `modPyramid` 2, `modBreedingGroups` 2 | brace placement | `styler` can auto-apply |
| `keyword_quote` | 10 | `modInput`, `modBreedingGroups`, `modPyramid` | drop unnecessary quotes on arg names | mechanical |
| `paste` | 7 | `processQcStudbookResult` 5, `modInput`, `runQcStudbook` | `paste0`/`toString` idioms | per Learning #13 use `toString()` |
| `object_usage` | 6 | `appServer`, `calcFE/FEFG/FG`, `modBreedingGroups`, `modGeneticValue` | **investigate** — may be real unused/undefined vars | **not purely cosmetic** — check each before "fixing" |
| `return` | 5 | `mod*` | drop redundant `return()` | mechanical |
| `undesirable_function` | 4 | `getPyramidPlot` `par` ×3 (Phase 2 keeps), `modBreedingGroups` 1 | per-site | `par` lines = keep |
| `nonportable_path` | 3 | `modInput`, `modPedigree` | use `file.path()` | check the path literals |
| `object_name` | 2 | `runGenekeepr:24`, `runModularApp:38` | rename to an allowed style | check exported API impact |
| `if_switch` 1 / `nzchar` 1 / `quotes` 1 / `unnecessary_nesting` 1 | 4 | `logModuleEvent`, `modGeneticValue`, `modBreedingGroups` | trivial | — |

---

## 8. Verification commands (every phase)

```r
# 1. Targeted: the touched file is now lint-clean (bypass .lintr to be sure):
lintr::lint("R/<file>.R", linters = <project linters from §1>, parse_settings = FALSE)
# 2. Whole-package residual dropped and nothing new appeared:
lintr::lint_package(".")
# 3. The touched functions' tests pass (fast single-file form):
Rscript -e 'suppressMessages(pkgload::load_all(".", quiet=TRUE)); testthat::test_file("tests/testthat/test_<fn>.R", reporter="summary")'
# 4. Build-equivalent (per CLAUDE.md): no new NOTE/WARNING/ERROR:
devtools::check()      # or R CMD check
# 5. CI parity (what lint.yaml runs): zero lints => green:
Rscript -e 'lintr::lint_package()'   # LINTR_ERROR_ON_LINT=true reds on ANY lint
```
**Final goal:** after Phases 1-4, the only `R/`-file line exclusion left is `makeGeneticDiversityDashboard` (justified). After Phase 5 (or the implicit_integer decision), `lint_package()` → 0 → the CI `lint` check goes **green** → #30 can close (or stay open scoped to any deliberately-deferred residual).

---

## 9. Open decisions for the author (pose via `AskUserQuestion` at implementation time)

1. **`implicit_integer_linter`: fix all 74 or disable the linter?** *Recommendation: disable it* — it is pedantic for Shiny UI (`column(width = 12)` reads better than `12L`), it is 49% of the residual, and `.lintr` already disables comparably-pedantic linters (`cyclocomp`, `indentation`, `object_length`, `object_overwrite`). Disabling clears 74 lints with zero code churn. *(If the author prefers literal-correctness, fixing is mechanical but touches 6 files.)*
2. **`addSexAndAgeToGroup.R` (#11): `match()` vs accept the small error-semantic change.** Recommendation: `match()` + a contract test (preserves everything).
3. **`makeGeneticDiversityDashboard` (#16):** confirm keep-exclude (recommended) vs convert to an inline `# nolint start/end` block. Default: leave as-is.
4. **Scope of this campaign:** close #30 after the exclusions (Phases 1-4) and file the residual as a follow-up, or drive all the way to a green `lint_package()` (through Phase 5) before closing. Recommendation: Phases 1-4 are the committed deliverable; the residual is opt-in.

---

## 10. Planning-session checklist (SESSION_RUNNER Phase 2)

- [x] Plan document written with file paths and line numbers.
- [x] Evidence-based inventory completed for all affected symbols (firsthand `parse_settings=FALSE` lint + 18-file examination workflow + adversarial verification; 3 agent errors corrected).
- [x] Each phase has explicit completion criteria (§5 per-phase DONE) and verification commands (§8).
- [x] Each phase marked "separate session" with a STOP point (§5).
- [x] Here-be-dragons / load-bearing assumptions called out (§6).
- [x] Author decisions surfaced, not pre-decided (§9).
