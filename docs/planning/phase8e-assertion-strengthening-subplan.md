# Phase 8e Sub-Plan — Strengthen the shinytest2 E2E assertions (boot-level → behavioral)

**Parent:** `docs/planning/phase8-e2e-harness-subplan.md` §6 (the deferred "8e" follow-on) → `docs/planning/shiny-module-conversion-plan.md` §9 Phase 8.
**Tracks:** GitHub issue **#40** ("Strengthen shinytest2 E2E assertions (replace boot-level tautologies with behavioral checks)") + its CI-stability follow-up comment.
**Authored:** Session 36 (2026-06-07), planning session. **TDD code-phases INAPPLICABLE to this document** (it is a plan; each implementation slice 8e-1…8e-7 is its own strict-TDD session — see the per-slice TDD classification, and Learning #21a).
**Evidence base:** every count and line number below was verified **firsthand** this session (greps + R one-liners against the working tree on branch `add-methodology`) and cross-checked by a read-only discovery workflow (`wf_4ebcdb7f-f4b`: a 23-agent per-file census of all 23 E2E files + 3 deep-dives [active-pane spike, namespace inventory, determinism inventory] + an adversarial completeness critic). The critic's corrections to the census aggregates are incorporated below (the headline counts are the **firsthand** numbers, not the census's inflated ones).

> **Scope.** This sub-plan is the decomposition of issue #40 into vertical, one-session-each TDD slices. It is the planning deliverable; **no test or app code is changed by writing it.** Implementation happens in the subsequent sessions, one slice at a time (FM #18/#25 — do NOT bundle).
>
> **⚠ One slice (8e-5) changes PRODUCTION code** (`R/modGeneticValue.R`, `R/modBreedingGroups.R`) — the first 8e work to do so. 8a–8d and the rest of 8e are test-/CI-only. 8e-5 therefore carries a different risk profile, needs explicit owner approval, and gets full RED→GREEN→REFACTOR + `devtools::check()`. See §7 and §11.

---

## 1. Context

### Problem
Issue #39 (sub-phases 8a–8d) made the shinytest2 E2E harness **executable + CI-wired**, with coverage **explicitly accepted as boot/static-DOM level** (the owner's Phase-8 scope decision). The harness boots the modular app and runs 23 `test-{app,e2e}-*` files green-or-clean-skip opt-in, but the assertions mostly prove only that *the app booted* — not that any feature *behaves*. Issue #40 (this sub-phase, 8e) converts the assertions into real behavioral checks and wires the analytical pipeline end-to-end.

### Why coverage is shallow today (the root cause)
`navbarPage` renders **all** tab panels' static HTML into the DOM at boot (hidden via CSS). `appUI.R` builds a single `navbarPage(id = "mainNavbar", theme = bslib::bs_theme(version = 4L, ...))` → **Bootstrap 4** → one `<div class="tab-content">` holding every pane, each `<div class="tab-pane" data-value="<Title>">` with only the initially-selected Home pane carrying `active`. Consequently:

- `get_html(app, "body")` (and `get_text`/`textContent`) serialize the **entire** pre-rendered tree, including hidden panes. So the dominant test idiom — `navigate_to_tab(...)` → `grepl(keyword, body)` — **passes once the app boots, regardless of which tab is selected.**
- `navigate_to_tab()` only `set_inputs(mainNavbar = label)` then reads back the **input value** (`get_value(input = "mainNavbar")`). It never inspects the DOM, so a silent no-op navigation still "passes" the body-grepl assertions (sub-plan §8.3 / risk R3 — the navigation false-positive).

### Owner decision (Session 36, via `AskUserQuestion`)
This session's single deliverable = **this plan** (decompose #40 + evidence inventory), not implementation. Implementation follows in slices 8e-1…8e-7.

### Constraints
- **Browser-dependent** (chromote 0.5.1 + Chrome; shinytest2 0.5.0 — `get_js`/`wait_for_js`/`get_value`/`get_html` all confirmed present locally). Opt-in via `NPRC_RUN_E2E=true` + `NOT_CRAN=true` (the §7 baked-in CI facts from 8b–8d still hold).
- **Strict TDD** governs each implementation slice. The conversion slices are mostly **run-and-observe + mutation-check** (the app already behaves; the new assertion must be *discriminating* — proven by a mutation check, Learning #3/#20), while **8e-1's helper** and **8e-5's production change** are RED→GREEN(→REFACTOR). Each slice classifies its TDD phase at its pre-RED gate (as 8b–8d did — Learnings #21a/#32/#33).
- **One slice per session — do NOT bundle** (FM #18/#25).

---

## 2. Verified current state (the inventory)

### 2.1 Tautology / dead-assertion census (firsthand counts; branch `add-methodology`)

| Class | Count | Where | Verified by |
|---|---|---|---|
| **Literal `expect_true(TRUE)`** | **41** | 12 files: summary-statistics-module 7, pedigree-tutorial 7, breeding-groups-tutorial 7, boundary-conditions 7, genetic-value-tutorial 3, breeding-groups-detailed 3, genetic-value-detailed 2, pyramid-detailed 1, pedigree-detailed 1, input-tutorial 1, input-detailed 1, error-states 1 | `grep -rc 'expect_true(TRUE'` |
| **`expect_true(nchar(html) > 100)`** near-tautologies (2nd tautology class) | **≈18** | boundary-conditions 6, error-states 12 | `grep -c 'nchar(html) > 100'` |
| **Dead `has_* <- grepl(...)`** (computed, never asserted) | **41 blocks** | densest: boundary-conditions, summary-statistics-module, breeding-groups-tutorial, pedigree-tutorial (7 each) | census + spot-verify |
| **`<- grepl(` assignments total** | 88–97 | 18–22 files (pattern-dependent) | `grep -rE '<- *grepl('` |
| **Wrong-tab navigation** | **7 blocks** | `test-e2e-summary-statistics-module.R` tests 2–8 (lines 40/61/82/103/124/146/168) navigate to **"Genetic Value Analysis"** though named "Summary Statistics has X" | firsthand + critic |
| **Hidden-DOM `grepl(body)` ASSERTED** (genuine assertion, content-blind) | ~majority of the rest | e.g. genetic-value-module 7/7, breeding-groups-module 7/7, home-navigation 8/10 (+2 navbar-label asserts), input-module 5/5, pedigree-module 5/5, pyramid-module 6/6, settings-about 4/4 | census per-file |
| **`interaction-noop-tryCatch`** (real interaction swallowed) | ~6 blocks | boundary-conditions 1, error-states 4, app-navigation 1 | census |
| **Genuinely browser-free** (leave as-is) | 5 | `test-e2e-data-ready.R` (testServer/UI-string/system.file) | census |

**Honesty note (critic correction):** the discovery workflow's headline "49 tautologies" **conflated** the 41 literal `expect_true(TRUE)` with ~8 of the `nchar>100` near-tautologies under one label. The faithful framing is **41 literal `expect_true(TRUE)` + ≈18 `nchar>100` near-tautologies = ≈58 content-blind assertions**, plus **41 dead-grepl blocks** and **7 wrong-tab blocks**. Do not cite "49" as a literal count.

**"Wrong-tab" is a real defect, not a workaround:** "Summary Statistics" is its own top-level `tabPanel` (`appUI.R:156-159`, `modSummaryStatsUI("summaryStats")` at :159). The test file's comment "Summary Statistics may be embedded in another tab" is false. Suite-wide, "Summary Statistics" appears as a `navigate_to_tab` target **exactly once** (vs "Genetic Value Analysis" 37×) — strong corroboration.

### 2.2 The "content-coupled REAL" assertions (genuine, but STILL hidden-DOM)
These assert a real domain keyword (not `TRUE`) and the grepl IS passed to `expect_true`, so they are *not* tautologies/dead — but they still grepl the **whole hidden body**, so they pass regardless of the selected pane and must also be converted to active-pane assertions:
- `test-e2e-pedigree-detailed.R:57` — `expect_true(grepl("sire|dam|parent|offspring|ancestor|descendant", html))`.
- `test-e2e-pedigree-tutorial.R:174` — `expect_true(has_columns)` (the `has_columns <- grepl(...)` is at lines 169–173; **the sub-plan §2.3 citation "169" points at the assignment, not the assertion at 174**).
- `test-app-loading.R:57` — `expect_true(grepl("Input|Pedigree|Pyramid", html))`.
- `test-e2e-breeding-groups-tutorial.R:48` (`has_sex_ratio_opts`) and `:69` (`has_make_groups`) — the only 2 asserted grepls in that file; the other 7 blocks are tautologies with dead vars.
- `test-e2e-home-navigation.R:155-156` — `expect_true(grepl("Home", html))` / `grepl("Input", html)` (always-rendered navbar labels).

### 2.3 The active-pane assertion mechanism (the load-bearing spike — RESOLVED on the static DOM, browser-confirm pending)
**Confirmed by rendering the navbarPage (deep-dive `spike:active-pane`, cross-checked firsthand against `appUI.R`):**
- One `<div class="tab-content">` holds every pane (top-level + the `navbarMenu("More")` children Settings/About/Help). Each pane is `<div class="tab-pane" data-value="<Title>">`; `data-value` == the `tabPanel` title == the `mainNavbar` input value (so a pane is addressable by its known title — **no auto-generated `#tab-NNNN` id guessing**). `appServer.R` also `insertTab`s two runtime panes ("Error List", "Changed Columns") into the same container.
- **`get_html`/`get_text` are the trap:** the *static markup* only ever has `.active` on Home and **never** the BS4 runtime `.show` — and even when present they serialize hidden subtrees. Any `.active`/visibility check **must** go through `get_js` against the **live** DOM.
- **`innerText` is the key primitive:** unlike `get_html`/`textContent`, `innerText` honors CSS visibility → it returns **only the visible pane's text** and is empty for `display:none` panes. So `grepl(keyword, get_active_pane_text(app))` is a *true* active-pane assertion.

**Recommended mechanism (single, reusable, drop-in for the body-grepl idiom):**
1. Synchronize: `app$wait_for_js("document.querySelector('.tab-content > .tab-pane.active')?.getAttribute('data-value')==='<title>'")` (resolves the BS4 fade-transition race).
2. Assert against the active pane's runtime `innerText`, gated on the expected `data-value` so it asserts the **specific** pane (catches a wrong-pane activation), not merely "something is active".

See §4 for the helper contracts. A **strictly stronger** second tier — asserting a **rendered reactive output** (`app$get_value(output = "<ns>-<id>")`; Shiny's `suspendWhenHidden` leaves hidden-tab outputs empty) — is used for the data-bearing assertions in **8e-6** (it proves the analytical pipeline actually rendered), once the output id per module is confirmed and data is loaded.

**Browser-spike items (cannot be settled by reading code; the first slice 8e-1 confirms these against the running `inst/shinytest/app.R`):**
1. After `navigate_to_tab(app, "Input")` + idle, the **live** DOM moves `active` (BS4 also adds `show`) onto the `data-value="Input"` pane and off Home — i.e. `querySelector('.tab-content > .tab-pane.active').getAttribute('data-value')` reads back `"Input"`. (Bootstrap-bundle JS behavior — observe, don't infer.)
2. `innerText` of the active pane is non-empty (visible module text) while the previously-active Home pane's `innerText` is empty under `display:none` — i.e. `innerText` truly discriminates panes here.
3. There is exactly **one** `.tab-content > .tab-pane.active` at read time (no mid-fade double-active); if a race exists, `wait_for_active_pane` / an extra `wait_for_idle` resolves it.
4. `navbarMenu("More")` children (Settings/About/Help) **and** the runtime-inserted panes (Error List / Changed Columns) land in the **same** single `.tab-content` and become the lone `.active` when selected (the one-container assumption holds for dropdown + inserted tabs).
5. (For 8e-6's output tier) `suspendWhenHidden` actually leaves a hidden tab's output empty via `get_value(output=...)`, and the chosen module output ids exist/populate once data is loaded.
6. `get_js`/`wait_for_js` evaluate `?.` optional chaining through the bundled Chrome (any modern Chrome — confirm no transpilation surprise). *(Method surface already confirmed present in shinytest2 0.5.0.)*

### 2.4 Namespace mismatch (becomes real in 8e-4/8e-6 — the upload prerequisite)
The input module is mounted under namespace **`dataInput`** (`appUI.R:123` `modInputUI("dataInput")`; `appServer.R:102` `modInputServer("dataInput", ...)`), so real ids are `#dataInput-pedigreeFileOne`, `#dataInput-getData`, `#dataInput-minParentAge`, `#dataInput-moduleContainer` (all from `modInput.R` via `ns()`). The `data-module="input"` attribute (`modInput.R:31`) is a **label, not the namespace** — do not confuse it.

**Sites to FIX (verified firsthand):**
| File | Line | Current (wrong) | Corrected |
|---|---|---|---|
| `tests/testthat/helper-shinytest2.R` | 150 | `module_id = "input"` (default in `upload_and_wait`) | `module_id = "dataInput"` |
| `tests/testthat/helper-shinytest2.R` | 154 | `` app$upload_file(`input-pedigreeFileOne` = file_path) `` (hardcoded; ignores params) | `` `dataInput-pedigreeFileOne` `` (ideally derived from `module_id`/`file_input_id`) |
| `tests/testthat/test-e2e-error-states.R` | 24 | `click_element_safe(app, "#input-getData")` | `"#dataInput-getData"` |
| `tests/testthat/test-e2e-error-states.R` | 45 | `` app$set_inputs(`input-minParentAge` = "0") `` | `` `dataInput-minParentAge` `` |
| `tests/testthat/test-e2e-boundary-conditions.R` | 43 | `` app$set_inputs(`input-minParentAge` = "abc") `` | `` `dataInput-minParentAge` `` |

`is_module_ready`/`wait_for_module_ready` (`helper:119/133`) are parameterized (`sprintf("#%s-moduleContainer", module_id)`) — correct **iff** callers pass `"dataInput"`; no change needed beyond the `upload_and_wait` default.

**DO NOT change (verified — these are correct as-is):**
- `test-e2e-data-ready.R:27-32` — bare `minParentAge`/`fileContent`/`fileType` inside `testServer(modInputServer, ...)` (moduleServer strips the namespace).
- `test-e2e-data-ready.R:43` — `expect_match(ui_html, 'data-module="input"')` asserts the literal label attribute, not a namespace.
- `test-e2e-home-navigation.R:95` — `#goto_input` is an app-level bare `actionButton` (`appUI.R:52`), not in the module namespace.

### 2.5 Stochastic determinism (8e-5 — production change)
**Both module files contain ZERO `set.seed`/`sample` calls** (firsthand-confirmed — the issue's "set.seed in `modBreedingGroupsServer`" phrasing is imprecise: there is none; it must be **added**). All stochasticity is delegated:
- **GVA:** `modGeneticValue.R:177` `reportGV(...)` → `reportGV.R:92` `geneDrop(..., n = guIter)` → `geneDrop.R:138` `assignAlleles` → `chooseAlleles.R:17` `sample(c(0L,1L), ...)` / `chooseAllelesChar.R:21` `sample.int(...)`. Drives `gu` → the rank column (`modGeneticValue.R:196`).
- **Breeding:** `modBreedingGroups.R:272` `groupAddAssign(..., iter = input$nIterations)` → `groupAddAssign.R:166` MIS loop → `fillGroupMembers.R:68/71` / `fillGroupMembersWithSexRatio.R:88/97/107/111` / `initializeHaremGroups.R:50` (`sample(...)`).

**`AppDriver$new(seed=)` does NOT control these** — it seeds the server subprocess once at startup; the click-triggered `reportGV`/`groupAddAssign` fire many reactive flushes later, after nondeterministic intervening RNG consumption (upload/QC/kinship/DT), with no re-pin. The reliable lever is a seed set **immediately before** the engine call, inside the module, gated so production is unaffected. The project **already has `R/set_seed.R`** (`set_seed <- function(seed = 1L)`, pins `sample.kind = "Rounding"` for cross-R-version reproducibility; **exported**, used by deterministic unit tests) — use **`set_seed()`, not `set.seed()`**.

---

## 3. Evidence-based inventory — per-file → slice assignment (MANDATORY)

All 23 E2E files + the helper + 2 modules + the CI yaml are accounted for. Block counts sum to **159** (matches 8a–8d's total). **Note:** the 8th top-level tab `"Genetic Value Analysis and Breeding Group Description"` (`modGvAndBgDesc`, `appUI.R:174-178`) has **no test file** and stays boot-only — "accounted for" means all *tested* panes.

| File | blocks | dominant classes (block-level) | wrong-tab | input-ns sels | slice |
|---|---|---|---|---|---|
| `test-e2e-summary-statistics-module.R` | 8 | 7 tautology(+dead), 1 hidden-DOM | **7** | — | **8e-1** |
| `test-e2e-input-module.R` | 5 | 5 hidden-DOM | — | — | 8e-2 |
| `test-e2e-input-detailed.R` | 6 | 5 hidden-DOM, 1 tautology | — | — | 8e-2 |
| `test-e2e-input-tutorial.R` | 8 | 7 hidden-DOM, 1 tautology | — | — | 8e-2 |
| `test-e2e-pedigree-module.R` | 5 | 5 hidden-DOM | — | — | 8e-2 |
| `test-e2e-pedigree-detailed.R` | 6 | 5 hidden-DOM (incl. real :57), 1 tautology | — | — | 8e-2 |
| `test-e2e-pedigree-tutorial.R` | 8 | 7 tautology(+dead), 1 hidden-DOM (real :174) | — | — | 8e-2 |
| `test-e2e-pyramid-module.R` | 6 | 6 hidden-DOM | — | — | 8e-2 |
| `test-e2e-pyramid-detailed.R` | 6 | 4 hidden-DOM, 1 tautology, 1 other | — | — | 8e-2 |
| `test-e2e-home-navigation.R` | 10 | 10 hidden-DOM (3 real `#goto_*` clicks; 2 navbar-label asserts :155-156) | — | — (goto_* OK) | 8e-2 |
| `test-e2e-genetic-value-module.R` | 7 | 7 hidden-DOM | — | — | 8e-3 |
| `test-e2e-genetic-value-detailed.R` | 7 | 5 hidden-DOM, 2 tautology | — | — | 8e-3 |
| `test-e2e-genetic-value-tutorial.R` | 8 | 5 hidden-DOM, 3 tautology | — | — | 8e-3 |
| `test-e2e-breeding-groups-module.R` | 7 | 7 hidden-DOM | — | — | 8e-3 |
| `test-e2e-breeding-groups-detailed.R` | 7 | 4 hidden-DOM, 3 tautology | — | — | 8e-3 |
| `test-e2e-breeding-groups-tutorial.R` | 9 | 7 tautology(+dead), 2 hidden-DOM (real :48/:69) | — | — | 8e-3 |
| `test-e2e-settings-about.R` | 4 | 4 hidden-DOM (navbarMenu false-switch) | — | — | 8e-3 |
| `test-e2e-workflow-integration.R` | 7 | 5 hidden-DOM, 2 tautology (nav false-positive) | — | — | 8e-3 |
| `test-e2e-error-states.R` | 13 | 7 tautology, 4 interaction-noop, 1 hidden-DOM, 1 dead | — | `#input-getData`, `input-minParentAge` | **8e-4** |
| `test-e2e-boundary-conditions.R` | 13 | 7 dead-grepl, 5 tautology, 1 interaction-noop | — | `input-minParentAge` | **8e-4** |
| `R/modGeneticValue.R`, `R/modBreedingGroups.R` | — | (production: add gated `set_seed()`) | — | — | **8e-5** |
| `test-app-loading.R` | 2 | 1 tautology, 1 hidden-DOM (real :57) | — | — | 8e-2 (light) |
| `test-app-navigation.R` | 2 | 1 interaction-noop, 1 tautology | — | `a[data-value="Input"]` (tab anchor — OK) | 8e-2 (light) |
| `test-e2e-data-ready.R` | 5 | 5 browser-free | — | — | LEAVE (no change) |
| (real flows: upload+QC / GVA / breeding) | new | data-bearing output + structural-invariant assertions | — | uses §2.4 fix | **8e-6** |
| `.github/workflows/shinytest2.yaml` | — | per-module-group fresh-process run | — | — | **8e-7** |

**Re-run these greps at each slice start (the inventory IS the verification step):**
```sh
grep -rc 'expect_true(TRUE'              tests/testthat/test-e2e-*.R tests/testthat/test-app-*.R
grep -rn  'nchar(html) > 100'            tests/testthat/test-e2e-*.R
grep -rnE '\b[a-z_]+ *<- *grepl'         tests/testthat/test-e2e-*.R          # candidate dead vars
grep -rn  'navigate_to_tab'              tests/testthat/test-e2e-summary-statistics-module.R
grep -rnE '(#?input-|dataInput)'         tests/testthat/*.R                   # namespace sites
grep -rn  'set.seed\|set_seed\|sample('  R/modGeneticValue.R R/modBreedingGroups.R
```

---

## 4. Helper interface contracts (interface-first — author in `tests/testthat/helper-shinytest2.R`)

Add alongside the existing `E2E_TIMEOUT`/`navigate_to_tab`/`*_safe` helpers. All follow the established **never-throw** convention (return a safe default so a missing selector self-skips). **Author in 8e-1; the browser-free unit tests are the 8e-1 RED→GREEN; the live-Chrome spike (§2.3 items) is the integration verify.**

```r
# JS for the navbar's single active visible pane. One navbarPage(id="mainNavbar")
# => one <div class="tab-content"> with exactly one .tab-pane.active at a time;
# data-value == tabPanel title == mainNavbar value.
.ACTIVE_PANE_JS <- "document.querySelector('.tab-content > .tab-pane.active')"

#' innerText of the active/visible navbar pane ("" on error/none).
#' innerText (NOT get_html/textContent) honors CSS visibility, so hidden panes
#' contribute nothing -- this is the REAL active-pane content.
get_active_pane_text <- function(app) {
  tryCatch(app$get_js(paste0(.ACTIVE_PANE_JS, "?.innerText || ''")),
           error = function(e) "")
}

#' data-value (== title) of the active pane, or "" if none/error.
get_active_pane_value <- function(app) {
  tryCatch(app$get_js(paste0(.ACTIVE_PANE_JS, "?.getAttribute('data-value') || ''")),
           error = function(e) "")
}

#' Block until the pane with data-value == tab_label is the active one.
#' @return TRUE on success, FALSE on timeout/error (never throws).
wait_for_active_pane <- function(app, tab_label, timeout = E2E_TIMEOUT) {
  # Quote the (safe, literal) title with base-R encodeString -- NOT jsonlite
  # (jsonlite is not a package dependency; do not add one just to quote a label).
  q <- encodeString(tab_label, quote = "'")
  js <- sprintf("%s?.getAttribute('data-value')===%s", .ACTIVE_PANE_JS, q)
  tryCatch({ app$wait_for_js(js, timeout = timeout); TRUE },
           error = function(e) FALSE)
}

#' Assert the EXPECTED pane is active+visible AND (optionally) contains `pattern`.
#' Drop-in replacement for the get_html(app,"body") + grepl(...) tautology.
#' @return TRUE iff the named pane is the active/visible one and (if given) its
#'   visible innerText matches `pattern`. FALSE otherwise.
assert_active_pane <- function(app, tab_label, pattern = NULL, ignore.case = TRUE) {
  if (!wait_for_active_pane(app, tab_label)) return(FALSE)
  if (!identical(get_active_pane_value(app), tab_label)) return(FALSE)
  if (is.null(pattern)) return(TRUE)
  grepl(pattern, get_active_pane_text(app), ignore.case = ignore.case)
}
```

**`get_js`/`wait_for_js` contract (shinytest2 0.5.0, confirmed):** `get_js(expr)` evaluates a **bare** JS expression and returns it **by value** (no `return`/IIFE wrapper needed — `?.` optional chaining and `|| ''` work as written); `wait_for_js(expr, timeout)` **aborts on timeout**, which is why `wait_for_active_pane` wraps it in `tryCatch(..., error = function(e) FALSE)`. `encodeString(tab_label, quote = "'")` is base R (no `jsonlite` dep) and safely single-quotes the literal tab titles for embedding in the JS string.

**Call-site transformation (the conversion idiom for 8e-2/8e-3):**
```r
# BEFORE (hidden-DOM tautology):
navigate_to_tab(app, "Summary Statistics")
html <- get_html_safe(app, "body")
expect_true(grepl("Export.*Kinship|Kinship.*Matrix", html, ignore.case = TRUE))
# (or worse: has_x <- grepl(...); expect_true(TRUE))

# AFTER (active-pane behavioral):
navigate_to_tab(app, "Summary Statistics")
expect_true(assert_active_pane(app, "Summary Statistics",
                               "Export.*Kinship|Kinship.*Matrix"))
```

**Browser-free testability (8e-1 RED→GREEN, mirrors 8a's `create_app_driver`/`*_safe` fake-app stub tests):** existence + formals of the 4 new symbols; the never-throw contracts via a fake-app stub whose `get_js`/`wait_for_js` throw → assert `get_active_pane_text`→`""`, `get_active_pane_value`→`""`, `wait_for_active_pane`→`FALSE`, `assert_active_pane`→`FALSE`; and a *recording* stub whose `get_js` returns a scripted `data-value`/`innerText` → assert `assert_active_pane` returns TRUE only when value matches AND pattern matches, FALSE when the value mismatches (proving it discriminates a wrong/failed nav — the whole point). No browser needed for the unit layer.

---

## 5. Slice decomposition (8e-1 … 8e-7) — vertical, risk-ordered, one session each

Each slice: **goal · DONE · verify · dragons · TDD classification · session boundary.** "If I stop here, is something working?" — yes at every boundary (FM #25).

### 8e-1 — Active-pane foundation + spike + wrong-tab fix + first conversion · risk MED-HIGH 🐉 (the load-bearing mechanism)
- **Goal:** add the 4 active-pane helpers (§4) with browser-free unit tests; **confirm §2.3 browser-spike items 1–4,6** against the live app — this is a **HARD GATE: confirm the spike BEFORE writing any conversion.** If `.active`/`innerText` don't behave as assumed, STOP (the helper design changes for every later slice; closing out with just the helper + spike finding is still a valid 8e-1 deliverable — re-plan the mechanism). Only after the spike passes, convert `test-e2e-summary-statistics-module.R` end-to-end — **fix the 7/8 wrong-tab nav** (item 1) and replace its 7 tautologies/dead-grepls with `assert_active_pane(app, "Summary Statistics", ...)`.
- **DONE:** 4 helpers defined + browser-free-unit-tested (RED→GREEN); the spike items observed TRUE in a real Chrome (documented in the session notes); summary-statistics-module navigates to **"Summary Statistics"** and genuinely asserts that pane is active+visible+contains the expected static UI; green opt-in; non-e2e suite still 0 failed/0 error.
- **Verify:** browser-free: `Rscript -e 'pkgload::load_all("."); testthat::test_file("tests/testthat/test_helper_shinytest2.R", reporter="summary")'`. Browser: `NPRC_RUN_E2E=true NOT_CRAN=true Rscript -e 'pkgload::load_all("."); testthat::test_file("tests/testthat/test-e2e-summary-statistics-module.R", reporter="summary")'` — 0 error; **mutation check:** point one assertion at the wrong tab → it must FAIL (proves it discriminates).
- **🐉 Dragons:** (1) The whole 8e program rests on the active-pane mechanism working in the live browser — **if spike item 1/2 fails** (e.g. BS4 doesn't move `active` as expected, or `innerText` doesn't honor visibility here), STOP and re-orient: the helper design changes for every later slice. (2) **Summary Statistics is partly data-dependent** — its plots/tables render only after a GVA run; pre-data, only static UI (export-button labels, headings) is in the pane. So 8e-1 asserts the **static** SS-pane content; the **data-bearing** SS assertions belong to 8e-6. Check `R/modSummaryStats.R` to see which labels are static UI vs `renderUI`-conditional before choosing the `pattern`.
- **TDD:** RED→GREEN for the helpers (browser-free) + RED→GREEN for the wrong-tab fix (write the `assert_active_pane(app,"Summary Statistics",...)` first → it FAILS while nav still targets GVA → fix the nav target → GREEN). Conversions of the other blocks = run-and-observe + mutation-check. Classify at the pre-RED gate.
- **Session boundary:** close out when the helpers are unit-tested, the spike is browser-confirmed, and summary-statistics-module is green + behavioral. **No other files.**

### 8e-2 — Convert the static-UI shallow tier, part A (input/pedigree/pyramid + home-nav) · risk MED
- **Goal:** convert the body-grepl tautologies in the 9 files (input-module/detailed/tutorial, pedigree-module/detailed/tutorial, pyramid-module/detailed, home-navigation) to `assert_active_pane` against the relevant pane. These are static-UI keyword checks (module labels, guidance, column names) that hold **without data**. For **home-navigation**, convert the 3 `#goto_*` clicks to assert the active pane switched (e.g. click `#goto_input` → `assert_active_pane(app, "Input")`) — the highest-value genuine-behavioral wins. **Carve-out:** home-navigation:155-156 assert navbar *labels* (`grepl("Home"/"Input", body)`) that live in the navbar `<ul>`, NOT inside any tab-pane — `assert_active_pane` would (correctly) fail for them; **leave those as whole-DOM grepl** and only convert the pane-*content* asserts. Optionally lightly strengthen `test-app-loading.R:57` / `test-app-navigation.R`.
- **DONE:** the 9 (+2 light) files green-or-clean-skip opt-in, each assertion now active-pane-scoped; mutation check on a sample (break nav → fail).
- **Verify:** `NPRC_RUN_E2E=true NOT_CRAN=true Rscript -e 'pkgload::load_all("."); testthat::test_dir("tests/testthat", filter="^e2e-(input|pedigree|pyramid|home)", reporter="summary")'` — 0 error.
- **Dragons:** the `pedigree-detailed:57` / `pedigree-tutorial:174` "real" assertions are content-coupled to always-rendered guidance — keep their keywords, just rescope to the active pane. AppDriver process count across 11 files (run grouped; `on.exit(app$stop())` already present). **If this is too large for one session, split input | pedigree | pyramid into separate sessions** (do NOT bundle past the comfortable single-session boundary — re-scope rather than rush).
- **TDD:** run-and-observe + mutation-check (the app already behaves; the new assertion must be discriminating). Classify at the pre-RED gate.
- **Session boundary:** close out when the assigned files are behavioral + green.

### 8e-3 — Convert the static-UI shallow tier, part B (genetic-value/breeding-groups + menu + workflow) · risk MED
- **Goal:** convert genetic-value-module/detailed/tutorial + breeding-groups-module/detailed/tutorial (static-UI keywords). Convert **settings-about** (4 blocks) to assert a **true visible-pane switch** for the `navbarMenu("More")` children (Settings/About/Help) via `assert_active_pane` — **this resolves the §8.3 navbarMenu false-positive and finalizes `navigate_to_menu_item`** as a genuine check (item 2). Convert **workflow-integration**'s "visits N tabs" to assert each pane becomes active in turn (kills the navigation false-positive).
- **DONE:** the 8 files green + behavioral; `navigate_to_menu_item` now asserts visible-pane truth (update its docstring's "shallow-coverage limit" note); mutation check on the menu switch.
- **Verify:** `... filter="^e2e-(genetic-value|breeding-groups|settings|workflow)" ...` — 0 error.
- **Dragons:** breeding-groups/genetic-value module content is largely data-dependent (results render post-formation/post-GVA) — assert the **static** UI here (control labels, tab titles); data-bearing assertions → 8e-6. The navbarMenu spike (§2.3 item 4) must have confirmed in 8e-1 that a "More" child becomes the lone `.active`.
- **TDD:** run-and-observe + mutation-check. May split into 2 sessions if oversized.
- **Session boundary:** close out when the assigned files are behavioral + green.

### 8e-4 — Namespace fix + interaction-no-op revival (error-states / boundary-conditions) · risk MED · **prerequisite for 8e-6**
- **Goal:** apply the §2.4 namespace fixes (helper `upload_and_wait` default + hardcode; error-states:24/45; boundary:43 `input-*`→`dataInput-*`). Then convert the `nchar>100` near-tautologies + `interaction-noop-tryCatch` blocks in error-states (13) + boundary-conditions (13) into **real input interactions** (set `dataInput-minParentAge`, click `#dataInput-getData`) + active-pane / error-state assertions. The `tryCatch`-swallow becomes a genuine pass/fail.
- **DONE:** the polling helpers + both files target the correct `dataInput-` ids; the 2 files green + behavioral; mutation check (wrong id → fail, proving the interaction is real, not swallowed).
- **Verify:** `... filter="^e2e-(error|boundary)" ...` — 0 error; grep shows no remaining `input-minParentAge`/`#input-getData` in those files / the helper.
- **Dragons:** these files probe **invalid input** (non-numeric/zero parent age) — confirm the modInput validation path actually surfaces a visible error/state to assert against (read `modInput.R` observeEvent(getData) validation ~301–419). Some boundary blocks need data loaded first → those data-dependent ones may defer to 8e-6.
- **TDD:** namespace fix = RED→GREEN (the corrected-id interaction newly succeeds where the swallowed one did nothing — write the assertion that requires the real interaction first). Conversions = run-and-observe + mutation-check.
- **Session boundary:** close out when the namespace is correct everywhere and the 2 files are behavioral.

### 8e-5 — Stochastic determinism hook (PRODUCTION change) · risk MED-HIGH 🐉 · own session, owner-gated
- **Goal:** add an **env/option-gated `set_seed()` hook** (Option A, §7) inside both `eventReactive`s, at the **top of the reactive body, ahead of the `withProgress`/`tryCatch` wrapper** (so no intervening RNG is consumed before the engine call) — `modGeneticValue.R` ahead of the `reportGV` path (the call is at ~177, inside `withProgress`) and `modBreedingGroups.R` ahead of the `groupAddAssign` path (the call is at ~272, inside `tryCatch`) — using the existing exported `set_seed()` (pins `sample.kind="Rounding"`). Gate: `seed <- getOption("nprcgenekeepr.gva_seed", as.integer(Sys.getenv("NPRC_GVA_SEED", NA))); if (!is.na(seed)) set_seed(seed)` (and `nprcgenekeepr.bg_seed` / `NPRC_BG_SEED`). **Default path unchanged** (gate unset → no-op → zero behavior change for real users).
- **DONE:** both modules deterministic-on-demand; default path provably unchanged; new unit tests prove the gate (seed set → identical output across 2 runs; unset → no `set_seed` call); `devtools::check()` 0/0/(0); full regression 0 failed/0 error.
- **Verify:** unit tests for the gate (can run **without a browser** via `testServer`/direct module-server calls with the option set); full `devtools::check()`; Phase-3E runtime smoke (`runModularApp()` still HTTP 200, GVA/breeding still produce output with the gate unset).
- **🐉 Dragons:** **this is the only 8e slice that edits `R/` production code** — it changes two **exported** server functions. Requires explicit **owner approval** (`AskUserQuestion` go/no-go: env+option gate vs the Option-B UI seed input vs Option-C-only/no production change). Must NOT alter the default (no-gate) numeric output. Watch `NAMESPACE`/`document()` (likely no change — no new roxygen export — but re-`document()` and diff). The `[deletion-namespace-fallout]` reflex's cousin: check that adding `set_seed` usage needs no new import (it's same-package, exported).
- **TDD:** full **RED→GREEN→REFACTOR**, all gated (real production change). RED = a test that, with the option set, asserts byte-identical GVA ranks / group composition across two invocations (fails today — no seed). GREEN = the gated hook. REFACTOR = factor the gate into a tiny internal helper if both modules share it.
- **Session boundary:** close out when the hook is in, gated, tested, default-path-unchanged, and `check()` clean. **Decoupling note:** 8e-6 structural-invariant assertions (Option C) do NOT require this slice — 8e-5 enables the *optional exact-value* tier. Sequence 8e-5 before 8e-6 only if exact-value assertions are wanted first.

### 8e-6 — Wire the real analytical flows end-to-end · risk HIGH 🐉🐉 · depends on 8e-4 (+ optionally 8e-5)
- **Goal:** the deepest slice — drive the real pipeline opt-in: **upload + QC** (the now-correct `upload_and_wait` → `#dataInput-getData` → `wait_for_module_ready(app, "dataInput")`), then **GVA** (`#geneticValue-runAnalysis`), then **breeding-group formation** (`#breedingGroups-formGroups`). Assert **rendered reactive outputs** (`get_value(output="<ns>-<id>")`; `suspendWhenHidden` makes hidden outputs empty) + **structural invariants** (Option C: GVA rank column is a permutation of `seq_len(n)`, `gu ∈ [0,1]`, nrow == probands; breeding: `nGroups == numGp`, assigned+unassigned partition candidates with no dupes, within-group max kinship ≤ threshold, harem ⇒ one male per group). With 8e-5's hook, optionally add exact-value assertions.
- **DONE:** at least the upload+QC, GVA, and breeding flows each have ≥1 genuinely end-to-end test asserting real rendered output / structural invariants, green-or-clean-skip opt-in.
- **Verify:** dedicated filter for the new real-flow tests — 0 error; the asserted outputs are non-empty only after the flow runs (confirm via a negative: pre-flow the output is empty/suspended).
- **🐉🐉 Dragons:** (1) **longest browser runtime + most flake-prone** (full pipeline per test; the §7/8c Chrome process-count dragon bites hardest here — run grouped, fresh processes). (2) Needs a known-good fixture studbook in `inst/extdata` that flows cleanly through QC→GVA→breeding (pick one the unit tests already trust). (3) Confirm each module's stable output id firsthand (`get_value(output=...)`). (4) GVA `nIterations` default 1000 → slow; consider setting a small `nIterations` via `set_inputs` for E2E speed. (5) Stochastic assertions: use Option C invariants unless 8e-5 landed.
- **TDD: RED→GREEN** (firm, not run-and-observe) — the asserted reactive outputs / structural invariants genuinely are not reached or asserted today (a true failing-first state), unlike the 8e-2/8e-3 conversions. Write the output/invariant assertion first (RED — fails because the flow isn't driven / output is suspended-empty), then drive the flow (GREEN).
- **Session boundary:** close out per-flow if needed (upload+QC could be one session, GVA another, breeding another — vertical slices within 8e-6). Do NOT bundle all three if they don't fit one session.

### 8e-7 — CI-stability hardening (the #40 comment follow-up) · risk MED · live-runner-only validation · orthogonal (can be scheduled anytime)
- **Goal:** make the scheduled run robust to the **23-in-one-process Chrome flake** (~1 transient error / 5 full-tier runs; §5/8c R2 "AppDriver process-count dragon"). Run the 23 files in **per-module groups, each in a fresh R process** (the §5/8c "run grouped" guidance), optionally with a transient-error retry, so no single process accumulates enough Chrome instances to time out.
- **DONE:** `.github/workflows/shinytest2.yaml` runs grouped fresh processes; the silent-skip guard (`sum(passed)==0` → `stop()`) and `stop_on_failure` preserved; documented that this is validated on the **live GitHub runner** only.
- **Verify:** locally the YAML/grouping logic is statically checkable (the regex/group partition selects all 23 with no overlap/gap); the flake fix itself **can only be confirmed on the live runner** (environmental). Pair with finally pushing `add-methodology` → master (the two S34 live-run watch items: renv lib-path + the flake both first exercise then).
- **Dragons:** ships **unvalidated locally** (state this in the handoff — failure mode #24's cousin; do NOT claim it fixes the flake until a live run shows it). Independent of the assertion work → can run before/after/parallel to 8e-1…8e-6.
- **TDD:** CI config / run-and-observe (TDD code-phases inapplicable — like 8b–8d's CI work).
- **Session boundary:** close out when the grouped-run YAML is in and statically verified; flag the live-runner validation as a watch item.

---

## 6. TDD classification summary (per slice)
| Slice | Touches | TDD phase shape | Owner gate? |
|---|---|---|---|
| 8e-1 | helper + 1 test file | RED→GREEN (helper + wrong-tab) + run-and-observe (conversions) | spike go/no-go if mechanism fails |
| 8e-2 | test files (≤11) | run-and-observe + mutation-check | — |
| 8e-3 | test files (8) | run-and-observe + mutation-check | — |
| 8e-4 | helper + 2 test files | RED→GREEN (ns fix) + run-and-observe | — |
| **8e-5** | **`R/` production (2 modules)** | **full RED→GREEN→REFACTOR + check()** | **YES — go/no-go on production change + option design** |
| 8e-6 | new test flows | RED→GREEN (flows reach real outputs) | — (may need fixture choice confirm) |
| 8e-7 | CI yaml | config / run-and-observe | — |

---

## 7. Determinism design detail (8e-5)
- **Option A (preferred, implemented in 8e-5):** env/option-gated `set_seed()` immediately before `reportGV` (modGeneticValue) and `groupAddAssign` (modBreedingGroups). Gate unset in production → no-op. In E2E, set the env var with `withr::local_envvar(NPRC_GVA_SEED = "42")` **around** `AppDriver$new()` (the subprocess inherits the parent env — the **reliable** channel; `AppDriver$new(seed=)` is **not**, §2.5).
- **Option C (always-on baseline, no production change):** assert **structural invariants** (GVA: rank = permutation of `seq_len(n)`, `gu ∈ [0,1]`, nrow == probands, FE/FG > 0; breeding: `nGroups == numGp`, partition with no dupes/out-of-pedigree, within-group max kinship ≤ threshold, harem ⇒ one male). Robust to RNG/R-version drift. **Use these by default in 8e-6 regardless of whether 8e-5 lands.**
- **Option B (alternative):** a `numericInput(ns("rngSeed"))` in each module UI (hidden behind a "reproducible mode" checkbox), driven by `app$set_inputs()`. Cleaner test plumbing, but adds user-facing UI surface — owner's call at the 8e-5 gate.

---

## 8. CI-stability design detail (8e-7)
The 8d broaden runs all 23 files in **one** R process via `filter="^(app|e2e)-"`. Under `stop_on_failure=TRUE` a single transient Chrome error reds the scheduled job, so the signal can't distinguish flake from regression. Fix: partition the 23 files into per-module groups and run each group in a **fresh R subprocess** (separate run step or a loop spawning `Rscript` per group), preserving the job env (`NPRC_RUN_E2E`/`NOT_CRAN`/`RENV_CONFIG_AUTOLOADER_ENABLED=false`/the `R CMD INSTALL` + Chrome provisioning from 8b), `stop_on_failure`, and the `sum(passed)==0` silent-skip guard. Optional: retry a group once on a transient error. **Environmental — only the live GitHub runner can confirm the flake is gone.**

---

## 9. Risk register
| # | Risk | Severity | Mitigation |
|---|---|---|---|
| R1 | **Active-pane mechanism fails in the live browser** (BS4 `active` toggling / `innerText` visibility) — invalidates every conversion slice | **high** | 8e-1 spikes §2.3 items 1–4,6 FIRST in a single-file slice; STOP + re-orient if it fails. Method surface already confirmed (shinytest2 0.5.0). |
| R2 | 8e-5 alters default GVA/breeding numeric output | high | Gate is unset-by-default no-op; RED test pins default-path output unchanged; `devtools::check()` + Phase-3E smoke; owner go/no-go. |
| R3 | Conversion slices oversized (11/8 files) → bundling temptation (FM #18/#25) | med | Split by module family; re-scope rather than rush; one comfortable session each. |
| R4 | 8e-6 full-pipeline flake (Chrome process count) | high | Run grouped/fresh processes; small `nIterations`; Option C invariants; pairs with 8e-7. |
| R5 | "New assertion green-on-arrival" misread as RED→GREEN when it's run-and-observe | med | Per-slice TDD classification (§6) at the pre-RED gate; **mutation-check** every conversion (break nav/id → must fail) to prove discrimination (Learning #3/#20). |
| R6 | Namespace fix misses a `data-module="input"` / bare-id site and "fixes" a correct one | med | §2.4 DO-NOT-CHANGE list is explicit (data-ready:27-32/43; home-nav:95; tab anchors). |
| R7 | 8e-7 ships unvalidated (flake env-only) | med | State explicitly in handoff (FM #24 cousin); don't claim the fix works until a live run shows it. |
| R8 | `jsonlite::toJSON` quoting in the spike's helper sketch adds an undeclared dep | low | Use base-R `encodeString(tab_label, quote="'")` (§4) — tab labels are safe literals. |
| R9 | Summary-statistics / breeding / GVA panes are data-dependent → 8e-1/2/3 over-assert pre-data | med | Assert STATIC UI in 8e-1/2/3; data-bearing assertions → 8e-6 (noted per slice). |

---

## 10. Alternatives considered
| Alternative | Why rejected |
|---|---|
| Do all of #40 in one session | 5 work items + CI-stability, a production change, and a browser spike — infeasible and violates "1 and done". |
| `grepl` against `.active` via `get_html` | `get_html` serializes hidden subtrees and the static markup never has the runtime `.show`; only `get_js`+`innerText` honors visibility (§2.3). |
| `AppDriver$new(seed=)` for determinism | Seeds startup only; click-triggered RNG fires many flushes later with intervening consumption — necessary-but-insufficient (§2.5). |
| Fix the namespace defaults before they're used | Inert until uploads are wired; 8e-4 does it exactly when 8e-6 needs it (sub-plan §2.5 sequencing). |
| Delete the shallow tests | They become genuinely behavioral with a one-line call-site swap once the helper exists; deletion discards working scaffolding. |

---

## 11. Impact / scope boundary
- **Changes (test/CI):** `tests/testthat/helper-shinytest2.R` (+4 active-pane helpers, namespace fix), `tests/testthat/test_helper_shinytest2.R` (helper unit tests), 20 `test-e2e-*`/`test-app-*` files (assertion conversion), `.github/workflows/shinytest2.yaml` (8e-7).
- **Changes (PRODUCTION — 8e-5 ONLY):** `R/modGeneticValue.R`, `R/modBreedingGroups.R` (gated `set_seed()` hook). **This is the first 8e work to touch `R/`** — explicit deviation from 8a–8d's "test-only" boundary; owner-gated; default path unchanged.
- **Explicitly NOT changed:** the analytical pipeline numerics (8e-5 is gated/no-op by default), `test-e2e-data-ready.R` (browser-free, leave), the correct `data-module="input"` label assertion, the `#goto_*` app-level buttons.
- **Closes:** issue **#40** at the end of the last slice (8e-7 or whichever completes the set). Resolves the §8.3 navigation false-positive and the §2.5 namespace mismatch.

---

## 12. Slice / session map (summary)
| Session | Slice | Deliverable | Risk | Depends on |
|---|---|---|---|---|
| N+1 | **8e-1** | 4 active-pane helpers + browser spike + wrong-tab fix + summary-statistics behavioral | MED-HIGH 🐉 | — |
| N+2 | **8e-2** | input/pedigree/pyramid + home-nav → active-pane (may split) | MED | 8e-1 |
| N+3 | **8e-3** | genetic-value/breeding-groups + settings-about (navbarMenu) + workflow → active-pane | MED | 8e-1 |
| N+4 | **8e-4** | namespace fix + error-states/boundary interaction revival | MED | 8e-1 |
| N+5 | **8e-5** | gated `set_seed()` hook (PRODUCTION) | MED-HIGH 🐉 | owner gate |
| N+6 | **8e-6** | real upload+QC / GVA / breeding flows (may split per flow) | HIGH 🐉🐉 | 8e-4 (+ opt. 8e-5) |
| any | **8e-7** | CI per-module fresh-process grouping (live-runner-validated) | MED | orthogonal |

*8e-1 is load-bearing — do it first. 8e-2/8e-3/8e-4 are independent of each other (all need only 8e-1). 8e-5 is owner-gated and decoupled from 8e-6 (which can use Option-C invariants without it). 8e-7 is orthogonal. After #40, the conversion campaign + its validation are fully complete.*

---

**Evidence artifacts (this planning session):** discovery workflow `wf_4ebcdb7f-f4b` (output `…/tasks/w8yc4nofm.output`; 23-file census + spike/namespace/determinism deep-dives + completeness critic); firsthand greps + R one-liners recorded in Session 36 notes. **Not committed** (transient).
