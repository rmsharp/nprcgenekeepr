# Phase 8 Sub-Plan — Enable the shinytest2 E2E harness end-to-end

**Parent:** `docs/planning/shiny-module-conversion-plan.md` §9 Phase 8 (the conversion campaign's validation phase).
**Tracks:** GitHub issue **#39** ("Complete & validate the shinytest2 E2E test suite, opt-in via `NPRC_RUN_E2E`").
**Authored:** Session 30 (2026-06-05), planning session. **TDD code-phases INAPPLICABLE** (this is a plan; the implementation sub-phases 8a–8d are each their own strict-TDD session — Learning #21a).
**Evidence base:** every claim below was verified **firsthand** this session (greps + R one-liners against the working tree) and cross-checked by a read-only discovery workflow (`wf_2707f89a-906`: 5-agent per-file census of all 23 E2E files + synthesizer + adversarial completeness-critic; all 16 critic findings re-verified firsthand).

> **⚠ This sub-plan CORRECTS the parent plan §9 Phase 8.** The parent says "author the **3** missing driver helpers" and frames Phase 8 as **one session**. Firsthand discovery found **6 undefined helpers + 1 undefined constant**, ~40 tautological assertions, and a wrong-tab-navigation defect. Phase 8 is a **4-session mini-campaign (8a–8d)**, not one session. After this sub-plan is approved, update the parent plan §9 Phase 8 to point here.

---

## 1. Context

### Problem
A substantial shinytest2 browser E2E environment was built on the module branch (commit `7da01afe`) but never finished or run. Session 19 added the opt-in entry gate `create_test_app()`, so the suite now **skips cleanly** by default instead of erroring. The remaining work (issue #39): make the suite **executable** — author the still-missing test infrastructure — get it green-or-clean-skip opt-in, and wire CI. The modular app (Phases 1–7) is now feature-complete enough to drive (the XARCH-1 dependency #39 flagged is satisfied: Phases 1–7 done).

### Owner decisions (Session 30, via `AskUserQuestion`)
1. **Scope = "Harness-enable" (sub-phases 8a–8d).** Author the 6 helpers + `E2E_TIMEOUT`; get all 23 files green-or-clean-skip opt-in; wire CI. Close #39 on **"executable + CI green opt-in."** Coverage is explicitly accepted as **boot / static-DOM level** (see §2.3 — the tests mostly prove the app boots). **Assertion-strengthening is OUT of #39 scope** and is filed as a separate follow-on (sub-phase 8e, §6).
2. **CI gating = scheduled + manual dispatch.** Run the opt-in E2E tier on a cron schedule + `workflow_dispatch`, **not** per-PR (browser tests are slow and Chrome-flaky; the project's other CI is fast). Drop `continue-on-error` so scheduled-run failures are visible. Keep the existing fast unit CI as the per-PR gate.

### Constraints
- **Browser-dependent**: needs `chromote` + a Chrome/Chromium binary. Verified present locally (chromote 0.5.1; Chrome at `/Applications/Google Chrome.app`). CI must provision Chrome.
- **Opt-in**: every browser test is gated by `create_test_app()` → `testthat::skip()` unless `Sys.getenv("NPRC_RUN_E2E") == "true"` (plus per-test `skip_if_not_installed("shinytest2"|"chromote")` + `skip_on_cran()`). The default `devtools::test()` / CRAN run stays clean.
- **Strict TDD** governs each implementation sub-session (RED→GREEN→REFACTOR with gates); **one sub-phase per session — do NOT bundle** (FM #18/#25).
- **renv is out-of-sync** (13 ggplot2-stack packages installed-but-unrecorded) but `pkgload::load_all(".")` works locally; CI uses `setup-r-dependencies` (DESCRIPTION-driven, not renv) so CI is unaffected. See §9 risk R7.

---

## 2. Verified current state

### 2.1 What already EXISTS (do not rebuild)
| Component | State (verified firsthand) |
|---|---|
| `inst/shinytest/app.R` | ✅ `shinyApp(ui = appUI(), server = appServer)` (the modular app) |
| `inst/www/js/data-ready.js` | ✅ present; `appUI.R:9-14` includes it when it exists |
| 6 modules' `data-ready` instrumentation | ✅ all set `data-ready="false"` on `#<ns>-moduleContainer` and signal readiness on render via `session$ns("moduleContainer")` (modInput.R:343/455, modPedigree.R:318, modPyramid.R:124, modGeneticValue.R:202, modSummaryStats.R:634, modBreedingGroups.R:327) — **signaling uses the correct namespaced id** |
| `create_test_app()` | ✅ `tests/testthat/helper-shinytest2.R:195-202` (S19) — opt-in gate, returns `system.file("shinytest", ...)` |
| `test_create_test_app.R` | ✅ browser-free unit test of the gate (the model for 8a's helper unit tests) |
| data-ready polling helpers (`wait_for_data_ready`/`wait_for_idle`/`wait_for_element`/`get_data_ready_state`/`is_module_ready`/`wait_for_module_ready`/`upload_and_wait`/`get_test_data_path`) | ✅ defined in `helper-shinytest2.R` — but **never CALLED** by any test (only `exists()`-name-checked in `test-e2e-data-ready.R:109-116`); see §2.4 |
| CI `.github/workflows/shinytest2.yaml` | ✅ exists (needs rework — §7) |
| Local toolchain | ✅ shinytest2 + chromote 0.5.1 + Chrome — runnable on this Mac |

### 2.2 What is MISSING — the 6 undefined helpers + 1 constant (the core of #39)
All confirmed undefined repo-wide (no `<- function` def in tree, none in git history). Signatures are **derived from the call sites**:

| Symbol | Call sites (verified count) | Required signature / behavior |
|---|---|---|
| `create_app_driver` | 20 files; **must forward `height`/`width`** (boundary-conditions.R:231 `height=900,width=800`; :244 `height=600,width=1400`; pyramid-module.R:99 name-only) | `create_app_driver(app_dir, name, ...)` → `shinytest2::AppDriver$new(app_dir, name=name, height=800, width=1200, load_timeout=E2E_TIMEOUT, screenshot_args=FALSE, ...)` — defaults overridable via `...` |
| `navigate_to_tab` | **137 calls: 109 three-arg, 27 two-arg** | `navigate_to_tab(app, tab_label, fallback = NULL)` — `app$set_inputs(mainNavbar = tab_label)`; **3rd arg is a no-op** (tab titles == `mainNavbar` values, §2.5); return TRUE only if `app$get_value(input="mainNavbar") == tab_label` after `wait_for_idle` (so silent no-op is caught — finding 15) |
| `get_html_safe` | 153 calls, **always `(app, "body")`** | `get_html_safe(app, selector)` → `tryCatch(app$get_html(selector), error = function(e) "")` |
| `click_element_safe` | 5 calls (home-navigation.R:95/114/133 `#goto_*`; error-states.R:24/250) | `click_element_safe(app, selector)` → `tryCatch({app$click(selector=selector); app$wait_for_idle(); TRUE}, error=function(e) FALSE)` |
| `navigate_to_menu_item` | 4 calls (settings-about.R:15/34/53/72) | `navigate_to_menu_item(app, item)` → reach a `navbarMenu("More")` child (Settings/About/Help, appUI.R:183-211). **Spike required** (§8): confirm whether `set_inputs(mainNavbar=item)` selects a navbarMenu child or a DOM dropdown-open+click is needed |
| `get_values_safe` | 3 calls (workflow-integration.R:76/85/109) | `get_values_safe(app)` → `tryCatch(app$get_values(), error = function(e) list())` |
| `E2E_TIMEOUT` (constant) | 3 refs; **error-states.R:232 is at test top-level → hard ERROR** (the L46 / boundary-conditions.R:44 refs are tryCatch-swallowed) | define in `helper-shinytest2.R` (e.g. `E2E_TIMEOUT <- 30000L`) |

### 2.3 The "hidden-DOM" finding (why coverage is shallow)
`navbarPage` renders **all** tab panels' static UI into the DOM at boot (hidden via CSS). Verified: `as.character(appUI())` is **85,106 chars** and contains `"Sire ID"` (pedigree guidance), `"kinship"` (GV), `"harem"` (breeding), `"Summary Statistics"` — **regardless of selected tab.** So `get_html_safe(app, "body")` returns the whole page, and the dominant test pattern — `navigate_to_tab(...)` → `grepl(keyword, body)` — **passes trivially once the app boots**. The keyword check is any-occurrence-in-body, not selected-tab-specific. **Consequence:** sub-phases 8a–8d deliver a *working harness*, not behavioral validation. (The only content-coupled real assertions: pedigree-detailed.R:57 and pedigree-tutorial.R:169 depend on the always-rendered `pedigree_browser.html` guidance string — flag in 8c triage.)

### 2.4 Test-quality defects (in scope only for 8e, §6)
- **41 `expect_true(TRUE)` tautologies** suite-wide (densest: breeding-groups-tutorial 7/9, summary-statistics-module 7/8, boundary-conditions 7/13).
- **Wrong-tab navigation**: `test-e2e-summary-statistics-module.R` navigates to **"Genetic Value Analysis"** in 7 of 8 tests (L40/61/82/103/124/146/168) — only L17 targets "Summary Statistics" — yet all pass via `expect_true(TRUE)`.
- **Dead `grepl`**: boundary-conditions.R assigns 7 `has_* <- grepl(...)` results that are never asserted.
- These verify nothing; they are 8e candidates, **not** 8a–8d blockers.

### 2.5 Namespace mismatch (real but currently INERT)
- `appUI.R:123` mounts the input module as namespace **`dataInput`** → real container id `#dataInput-moduleContainer`; the module's static `data-module="input"` attribute is a **label, not the namespace**.
- The polling helpers default `module_id="input"` and `upload_and_wait` hardcodes `` `input-pedigreeFileOne` `` / `%s-getData` → would target the wrong `#input-...` ids. **But these helpers are never called** (verified: zero call sites outside the def + the `exists()` name-checks) → the mismatch is **inert today**.
- error-states.R (`#input-getData`, `input-minParentAge`) and boundary-conditions.R (`input-minParentAge`) use `input-` selectors directly, but inside `tryCatch(error=function(e) NULL)` → the intended interactions silently no-op and the shallow assertions still pass.
- **Sequencing:** the namespace fix is deferred to **8e** (where uploads are first actually wired) — fixing it earlier is pure dead-code maintenance with no observable effect. Module-side signaling is already correct, so the live app is unaffected.

### 2.6 CI state (`shinytest2.yaml`)
- Runs **only** `test-app-loading.R` + `test-app-navigation.R` via `test_file` + `CheckReporter`.
- `continue-on-error: true` → failures are invisible (the job is currently decorative).
- **Does NOT set `NPRC_RUN_E2E`** → under the S19 gate, both files **skip** → CI runs nothing meaningful today.
- Installs snap `chromium-browser` and sets `CHROMOTE_CHROME` inside the Rscript block — snap chromium is a known headless-CI friction.

---

## 3. Evidence-based inventory (MANDATORY — per SESSION_RUNNER Planning protocol)

The 23 E2E files (159 `test_that` blocks) and their dependency on the missing symbols. **File→sub-phase assignment is exact and verified** (all 23 accounted for; test counts sum to 159).

| File | tests | uses (beyond create_test_app) | sub-phase |
|---|---|---|---|
| `test-app-loading.R` | 2 | direct `AppDriver$new` | **8b** |
| `test-app-navigation.R` | 2 | direct `AppDriver$new`, `app$click('a[data-value="Input"]')`, `app$get_values` | **8b** |
| `test-e2e-data-ready.R` | 5 | **browser-free** (`testServer`/UI-string/`system.file`); only `exists()`-checks helpers | **8b** (sanity; already passes) |
| `test-e2e-input-{module,detailed,tutorial}.R` | 5+6+8 | `create_app_driver`,`navigate_to_tab`,`get_html_safe` | **8c** |
| `test-e2e-pedigree-{module,detailed,tutorial}.R` | 5+6+8 | (same 3) | **8c** |
| `test-e2e-pyramid-{module,detailed}.R` | 6+6 | (same 3) | **8c** |
| `test-e2e-genetic-value-{module,detailed,tutorial}.R` | 7+7+8 | (same 3) | **8c** |
| `test-e2e-summary-statistics-module.R` | 8 | (same 3) — wrong-tab nav (§2.4) | **8c** |
| `test-e2e-breeding-groups-{module,detailed,tutorial}.R` | 7+7+9 | (same 3) | **8c** |
| `test-e2e-home-navigation.R` | 10 | + `click_element_safe` (`#goto_*`) | **8d** |
| `test-e2e-settings-about.R` | 4 | + `navigate_to_menu_item` (navbarMenu) | **8d** |
| `test-e2e-workflow-integration.R` | 7 | + `get_values_safe` | **8d** |
| `test-e2e-error-states.R` | 13 | + `click_element_safe`, `E2E_TIMEOUT` (top-level), `input-` selectors | **8d** |
| `test-e2e-boundary-conditions.R` | 13 | + `create_app_driver(height/width)`, `E2E_TIMEOUT`, `input-` selectors | **8d** |

**Totals:** 8b = 3 files / 9 tests · 8c = 15 files / 103 tests · 8d = 5 files / 47 tests · = **23 files / 159 tests** ✓
**Verification greps (re-run at each sub-phase start):**
- `for h in create_app_driver navigate_to_tab get_html_safe click_element_safe navigate_to_menu_item get_values_safe; do grep -rl "$h *<- *function" tests/ R/; done` (def presence)
- `grep -rn 'E2E_TIMEOUT' tests/ R/` · `grep -rhoE 'navigate_to_tab\([^)]*\)' tests/testthat | sort | uniq -c`

---

## 4. Helper interface contracts (interface-first — architecture workstream)

Author all 6 helpers + the constant in **`tests/testthat/helper-shinytest2.R`** (auto-sourced by testthat; same home as `create_test_app`).

```r
E2E_TIMEOUT <- 30000L   # ms; shared AppDriver load/idle budget

# Construct the AppDriver. Forwards ... so per-test height/width override the defaults.
create_app_driver <- function(app_dir, name, ...) {
  shinytest2::AppDriver$new(
    app_dir, name = name,
    height = 800, width = 1200,
    load_timeout = E2E_TIMEOUT,
    screenshot_args = FALSE,        # no auto-screenshots → no _snaps churn (finding 13)
    ...                              # explicit height/width/seed override
  )
}

# Switch navbarPage tab. tab_label is the tabPanel TITLE (== mainNavbar value).
# fallback is accepted for call-site compatibility (109/137 calls are 3-arg) but is a
# no-op given titles == values. Returns TRUE only if navigation ACTUALLY occurred.
navigate_to_tab <- function(app, tab_label, fallback = NULL) {
  tryCatch({
    app$set_inputs(mainNavbar = tab_label)
    app$wait_for_idle(timeout = E2E_TIMEOUT)
    identical(app$get_value(input = "mainNavbar"), tab_label)
  }, error = function(e) FALSE)
}

get_html_safe   <- function(app, selector) tryCatch(app$get_html(selector), error = function(e) "")
get_values_safe <- function(app)           tryCatch(app$get_values(),       error = function(e) list())
click_element_safe <- function(app, selector) {
  tryCatch({ app$click(selector = selector); app$wait_for_idle(timeout = E2E_TIMEOUT); TRUE },
           error = function(e) FALSE)
}
# navigate_to_menu_item: reach a navbarMenu("More") child (Settings/About/Help).
# Implementation pending the 8d spike (§8): set_inputs(mainNavbar=item) vs DOM dropdown click.
navigate_to_menu_item <- function(app, item) { ... }   # finalize in 8d
```

**Error contract for all `*_safe` helpers:** never throw — return a safe default (`""`, `list()`, `FALSE`) so a missing selector self-skips rather than erroring (matches the existing test code's `if (!success) skip(...)` idiom).

**Browser-free testability (this is the 8a RED→GREEN):** existence (`exists("create_app_driver")`), arity/signature (`"..." %in% names(formals(create_app_driver))`; `"fallback" %in% names(formals(navigate_to_tab))`), and the `*_safe` error contracts via a **fake app stub** (a list/env whose `get_html`/`get_values`/`click` throw → assert the helper returns the safe default). No browser needed — mirrors S19's `create_test_app` gate TDD.

---

## 5. Sub-phase decomposition (8a–8d) — vertical, risk-ordered, one session each

Each sub-phase: **goal · DONE · verify command · dragons · session boundary.** Strict TDD applies (it is real R code). "If I stop here, is something working?" — yes at every boundary (FM #25).

### 8a — Helper/constant foundation (browser-free RED→GREEN) · risk LOW
- **Goal:** define all 6 helpers + `E2E_TIMEOUT` in `helper-shinytest2.R` per §4; add a browser-free unit-test file (extend `test_create_test_app.R` or new `test_helper_shinytest2.R`).
- **RED:** assert each symbol exists with the correct formals + the `*_safe` error contracts via a fake-app stub — fails ("could not find function") at HEAD.
- **DONE:** all 7 symbols defined + unit-tested browser-free; `Rscript -e 'suppressMessages(pkgload::load_all(".")); for (h in c("create_app_driver","navigate_to_tab","get_html_safe","click_element_safe","navigate_to_menu_item","get_values_safe","E2E_TIMEOUT")) stopifnot(exists(h))'` clean; full non-e2e suite still 0 failed/0 error.
- **Note:** `navigate_to_menu_item` body may be a provisional `set_inputs(mainNavbar=item)` here; finalized in 8d after the spike. Do **not** fix the polling-helper namespace defaults here (deferred to 8e, §2.5).
- **Session boundary:** close out when the helpers/constant are defined + unit-tested and the default suite is clean. **No browser run yet.**

### 8b — Boot-smoke tier + CI wiring (least browser surface) · risk MEDIUM 🐉 (first-ever browser run)
- **Goal:** prove Chrome + chromote + the modular app boot opt-in, with the 3 files that need no derived helpers; wire CI per the owner's scheduled+dispatch decision.
- **Files:** `test-app-loading.R` (2, direct AppDriver), `test-app-navigation.R` (2, direct AppDriver + the `a[data-value="Input"]` click — **the navigation spike, §8**), `test-e2e-data-ready.R` (5, browser-free — confirm still green).
- **DONE:** `NPRC_RUN_E2E=true` → the 3 files run green (or the data-value click cleanly self-skips if the selector doesn't resolve); CI `shinytest2.yaml` updated: `NPRC_RUN_E2E: 'true'` in job-level `env:`, `continue-on-error` removed, schedule + `workflow_dispatch` triggers, reliable Chrome provisioning (prefer `r-lib/actions` browser setup or `google-chrome-stable` over snap chromium; assert `chromote::find_chrome()` resolves before the run).
- **Verify:** `NPRC_RUN_E2E=true NOT_CRAN=true Rscript -e 'suppressMessages(pkgload::load_all(".")); testthat::test_file("tests/testthat/test-app-loading.R", reporter="summary")'` (then `test-app-navigation.R`, `test-e2e-data-ready.R`) — 0 "could not find function", 0 error.
- **Dragons:** first real browser execution — expect to triage Chrome launch/timeout/headless issues; the `a[data-value]` selector must be confirmed against the live bslib navbar.
- **Session boundary:** close out when the smoke tier runs green opt-in **and** CI is wired (scheduled run observed or `workflow_dispatch`-triggered once).

### 8c — Per-module shallow tier (run-and-observe) · risk MEDIUM
- **Goal:** run the 15 shallow `grepl`-body files (~103 tests); they should pass trivially once 8a + a booting app exist (§2.3).
- **DONE:** all 15 files green-or-clean-skip opt-in. Verify firsthand the helper corner cases: (a) `navigate_to_tab`'s 3rd-arg is a tolerant no-op for non-matching sub-tabs (e.g. pyramid files pass `"Pyramid"`, but modPyramid's sub-tabs are "Plot"/"Statistics"); (b) the only content-coupled assertions are pedigree-detailed.R:57 / pedigree-tutorial.R:169 (depend on `pedigree_browser.html` guidance — note, don't fix).
- **Verify:** `NPRC_RUN_E2E=true NOT_CRAN=true Rscript -e 'suppressMessages(pkgload::load_all(".")); testthat::test_dir("tests/testthat", filter="^e2e-(input|pedigree|pyramid|genetic|summary|breeding)", reporter="summary")'` — 0 error. (Run per module-group; browser runtime is the cost.)
- **Dragons:** AppDriver process count (15 files × several drivers) — run grouped, `app$stop()` on.exit already present. Flaky timeouts on slow first renders.
- **Session boundary:** close out when the 15 files are green-or-clean-skip.

### 8d — Interaction/menu tier (secondary helpers + spikes) · risk MEDIUM-HIGH 🐉
- **Goal:** the 5 deep files (47 tests) that need the secondary helpers + the constant + the navbarMenu spike.
- **Files:** home-navigation (10, `click_element_safe`), settings-about (4, `navigate_to_menu_item`), workflow-integration (7, `get_values_safe`), error-states (13, `click_element_safe` + top-level `E2E_TIMEOUT`), boundary-conditions (13, `create_app_driver(height/width)` + `E2E_TIMEOUT`).
- **Spikes (§8):** finalize `navigate_to_menu_item` (does `set_inputs(mainNavbar="Settings")` reach a navbarMenu child, or is a dropdown-open+click required?). Confirm `#goto_*` clicks navigate (the `goto_*` observers ARE wired — appServer.R:73-95).
- **DONE:** the 5 files reach assertions (no "could not find function", no top-level `E2E_TIMEOUT` error) and are green-or-clean-skip opt-in. **The `input-` selectors in error-states/boundary-conditions remain `tryCatch`-swallowed no-ops** — making those interactions *real* is 8e, not here (§2.5).
- **Verify:** `NPRC_RUN_E2E=true NOT_CRAN=true Rscript -e 'suppressMessages(pkgload::load_all(".")); testthat::test_dir("tests/testthat", filter="^e2e-(home|settings|workflow|error|boundary)", reporter="summary")'` — 0 error.
- **Session boundary:** close out when all 5 files are green-or-clean-skip → **issue #39 is satisfied (harness executable + CI wired); close #39.** Run the full `^(app|e2e)-` filter once to confirm 0 "could not find function" suite-wide.

---

## 6. 8e — Assertion-strengthening (OUT of #39 scope — file as a new issue)

Per the owner's scope decision, this is a **separate deliverable**, not part of "enable the harness." File a new GitHub issue at the end of 8d:

> **Title:** Strengthen shinytest2 E2E assertions (replace boot-level tautologies with behavioral checks)
> **Body:** The E2E harness runs (issue #39), but coverage is boot/static-DOM level: **41 `expect_true(TRUE)` tautologies**, ~40 dead `grepl` assignments, `summary-statistics-module` navigates to the **wrong tab** (7/8 tests), and the `navbarPage` hidden-DOM means `grepl(keyword, "body")` passes regardless of the selected tab. This issue: (1) fix the wrong-tab navigation; (2) convert tautologies into selected-tab-specific / rendered-reactive assertions; (3) wire **real upload + GVA + breeding flows** using the existing `data-ready` infra (`upload_and_wait`/`wait_for_module_ready`) — which requires (4) fixing the polling-helper namespace defaults `input`→`dataInput` (inert until now, §2.5) and the `#input-*` selectors in error-states/boundary-conditions; (5) ensure stochastic GVA/breeding determinism — note `AppDriver` `seed` does NOT control the module-internal `set.seed` in `modBreedingGroupsServer`. Reference this sub-plan §2.4 / §2.5.

---

## 7. CI design (owner decision: scheduled + manual) — IMPLEMENTED in 8b (S32)

Rework `.github/workflows/shinytest2.yaml`:
- **Triggers:** replace `push`/`pull_request` with `schedule` (nightly cron `0 7 * * *`) + `workflow_dispatch`. Remove the per-PR triggers (keep the fast unit CI — `R-CMD-check.yaml`, `test-coverage.yaml` — as the per-PR gate). NB: `schedule`/`workflow_dispatch` only fire once this workflow is on the **default branch** (master).
- **Opt-in:** add `NPRC_RUN_E2E: 'true'` to the **job-level `env:`** block (not inside the Rscript) so `create_test_app()` actually returns the app dir. **⚠ ALSO add `NOT_CRAN: 'true'`** (this spec originally omitted it — S32): the 3 smoke files all call `skip_on_cran()`, and `testthat::on_cran()` is TRUE on the **non-interactive `Rscript` runner** unless `NOT_CRAN` is set → every E2E test would **silently skip** (and `stop_on_failure` does NOT catch skips → green-on-nothing). Confirmed firsthand.
- **Visibility:** **remove `continue-on-error: true`** so failures fail the scheduled job. Run the tests via `res <- as.data.frame(testthat::test_dir(..., stop_on_failure = TRUE))` and **also `stop()` if `sum(res$passed) == 0L`** — `stop_on_failure` is blind to an all-skip run, so this guard makes the silent-skip class fail loud.
- **Package install (ADDED, S32 — was missing):** add `R CMD INSTALL --no-multiarch --with-keep.source .` **after** `setup-r-dependencies`. The app subprocess (`inst/shinytest/app.R`) does `library(nprcgenekeepr)` and `create_test_app()` resolves `system.file("shinytest", package = "nprcgenekeepr")`, so the package itself (not just its deps) must be installed. Pure-R package → fast install (no `src/`).
- **renv autoloader (ADDED, S32):** set `RENV_CONFIG_AUTOLOADER_ENABLED: 'false'` at job level. The tracked `.Rprofile` activates renv's autoloader, which forces `.libPaths()[1]` to renv's **private** library; with it disabled, deps + `R CMD INSTALL` + the test run all target the standard **site** library so the AppDriver subprocess (starts in the installed `shinytest/` dir, no project `.Rprofile`) can resolve `library(nprcgenekeepr)`. This realizes R7's "DESCRIPTION-driven, not renv" intent. **⚠ Live-run watch item:** the lib-path / subprocess interaction is the one thing not statically verifiable — confirm on the first GitHub run.
- **Chrome provisioning:** chosen = `browser-actions/setup-chrome@v2` (`install-dependencies: true` → Chrome-for-Testing + system libs; `chrome-path` output → set `CHROMOTE_CHROME` via `$GITHUB_ENV`) over the snap `chromium-browser`; **assert `chromote::find_chrome()` resolves** (single, existing path — not bare `nzchar`, which passes vacuously on `NULL`) before running. Keep the `_snaps/` + `*.png` artifact upload. NB: on CI `chromote` auto-adds `--no-sandbox` (it sets it when `CI` is set), so no manual flag is needed on ubuntu 24.04.
- **What it runs (8a–8d done):** the full opt-in tier (`filter="^(app|e2e)-"`), or at minimum the 8b smoke files; decide final breadth at 8b based on runtime/flake. **8b runs only the 3 smoke files** (`filter="^(app-loading|app-navigation|e2e-data-ready)$"`); broaden the filter as 8c/8d land.

---

## 8. Empirical spikes (browser-only — cannot be settled in planning)

These need a running Chrome; the executor resolves them in 8b/8d (do **not** assume):
1. **Tab navigation actually switches** — does `app$set_inputs(mainNavbar="Input")` flip the tab, or must the test click `a[data-value="Input"]`? The `navigate_to_tab` contract reads back `mainNavbar` to confirm (finding 15) — verify this read-back works for navbarPage. (`test-app-navigation.R` is the canary in 8b.)
2. **navbarMenu child navigation** — does `set_inputs(mainNavbar="Settings")` select a `navbarMenu("More")` child, or is a DOM dropdown-open + item-click required? Determines `navigate_to_menu_item`'s body (8d).
3. **Navigation false-positives** — because of hidden-DOM, a silent no-op navigation still passes `grepl`-body tests (e.g. workflow-integration.R "visits 6 tabs"). The read-back contract mitigates this for `navigate_to_tab`; note it as a known shallow-coverage limit, not a bug to chase in 8a–8d.

---

## 9. Risk register

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| R1 | Phase 8 under-scoped in parent plan (3 helpers / 1 session) | high | This sub-plan: 6 helpers + constant, 4 sessions. Update parent §9. |
| R2 | First-ever browser run floods with Chrome/timeout/headless failures | high | 8b isolates the smallest surface first; triage iteratively; `E2E_TIMEOUT=30000`. |
| R3 | navbarMenu dropdown navigation harder than a plain tab | med | 8d spike (§8.2) before finalizing `navigate_to_menu_item`. |
| R4 | "Green" misread as behavioral validation | med | §2.3/§2.4 state plainly: 8a–8d = boot-level; behavior is 8e. Owner acknowledged. |
| R5 | CI snap-chromium fails headless | med | §7: prefer google-chrome-stable / r-lib browser setup; assert `find_chrome()`. |
| R6 | `continue-on-error` masks failures | med | §7: remove it. |
| R7 | renv out-of-sync → CI restores smaller locked set, ggplot2 deps missing (modPyramid render) | low-med | CI uses DESCRIPTION-driven `setup-r-dependencies`, not renv → unaffected. Locally `load_all` works. Decide `renv::snapshot()` separately (not a Phase-8 blocker). |
| R8 | Duplicate AppDriver names (`e2e_pyramid_bin_size`, `e2e_pyramid_max_age`) | low | Harmless with `screenshot_args=FALSE` + no `expect_snapshot`; matters only if 8e adds snapshots. |
| R9 | Namespace fix done too early = churn | low | Deferred to 8e (§2.5). |

---

## 10. Alternatives considered
| Alternative | Why rejected |
|---|---|
| One-session Phase 8 (parent plan as-is) | Factually impossible: 6 undefined helpers + 1 constant + 4 distinct interaction tiers + first-ever browser triage. |
| Full assertion-strengthening inside #39 | Owner chose harness-enable; behavior validation is a distinct, open-ended deliverable (8e). |
| Per-PR blocking E2E | Owner rejected: slow + Chrome-flaky on every PR; fast unit CI already gates PRs. |
| Delete the E2E suite | Discards ~3,800 LOC of scaffolding + working app instrumentation; the harness is ~85% built (issue #39). |
| Fix namespace defaults now | Inert today; pure churn until uploads are wired (8e). |

---

## 11. Impact / scope boundary
- **Changes:** `tests/testthat/helper-shinytest2.R` (+helpers/constant), `tests/testthat/test_*` (helper unit tests), `.github/workflows/shinytest2.yaml`. The 23 E2E test files are *run/triaged*, not rewritten (rewriting = 8e).
- **Explicitly NOT changed in 8a–8d:** the modular app `R/` code (it already boots + signals data-ready correctly), the analytical pipeline, the 41 tautologies / wrong-tab nav (8e), the polling-helper namespace defaults (8e).
- **Closes:** issue **#39** at the end of 8d. Files the 8e follow-on issue.

---

## 12. Sub-phase / session map (summary)
| Session | Sub-phase | Deliverable | Risk |
|---|---|---|---|
| N+1 | **8a** | 6 helpers + `E2E_TIMEOUT` defined + browser-free unit tests | LOW |
| N+2 | **8b** | Boot-smoke tier green opt-in + CI rewired (scheduled+dispatch) | MED 🐉 (first browser run) |
| N+3 | **8c** | 15 shallow per-module files green-or-skip opt-in | MED |
| N+4 | **8d** | 5 interaction/menu files green-or-skip → **close #39** | MED-HIGH 🐉 |
| later | **8e** | (separate issue) assertion-strengthening + ns fix + real flows | — |

*Then the conversion campaign proceeds to parent-plan **Phase 9** (declare canonical, delete the monolith — irreversible, its own commit). Do not bundle.*
