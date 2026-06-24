# Issue #73 Part 2 Plan — User-configurable species reproductive-parameter overrides (config file)

**Status: RATIFIED (Session 185, 2026-06-23) -- ready to RED.** Session 184 drafted this plan; Session 185 verified the load-bearing claims (D1/D4/R2) firsthand and the owner ratified all open decisions via `AskUserQuestion` (Ratification record below). Implementation is a separate strict-TDD session per slice -- do NOT bundle ratification with implementation, nor Slice 1 with Slice 2 (FM #18/#25). Slice 1 may now declare RED.

**Ratification record (Session 185, 2026-06-23 -- owner, via `AskUserQuestion`; all decisions ratified as recommended):**
- **D1 = CSV file path.** One optional config key points to a CSV carrying the bundled table's four columns; read by a `getConfigApiKey`-style soft-lookup. No `getSiteInfo` change.
- **D2 = four bundled columns, header required**, column order matched by name; a colony lists only the rows (species) it wants to change. No column-level partial in v1.
- **D3 = two optional fallback keys**, `minBreedingAgeDefault` (numeric, built-in 2.0) and `gestationDefault` (integer, built-in 210).
- **D4 = MERGE.** The user CSV overrides only the species it lists; every unlisted species keeps its bundled value. Merge in the reader; the accessors stay unchanged.
- **D5 = prefill the suggested gestation window only** (Potential Parents tab). Per-animal species windows deferred to a follow-up.
- **D6 = GVA tab first (Slice 1), Potential Parents second (Slice 2).**
- **D7 = sibling `shared$speciesOverrides`** (separate from `shared$config`), passed to the modules as a reactive (per the `modInputServer` precedent).
- **Confirmed (S184 orientation, reaffirmed):** config file only -- no Settings-tab UI (`appUI.R:223-228` stays a placeholder); scope = all three value groups (breeding ages, gestation, fallbacks); the backward-compat invariant (no config => identical to today) is a hard acceptance test in each slice.

**Two owner decisions already made at orientation (S184):**
- **Mechanism = config file** (extend `~/.nprcgenekeepr_config`, already loaded at boot via `loadSiteConfig()` into `shared$config`). The Settings-tab UI (`appUI.R:223-228` placeholder) is **out of scope**.
- **Scope = all three value groups**: per-species minimum male/female breeding ages, per-species gestation, and the absent-species fallbacks (currently 2 years / 210 days). The issue's note that "the fallback should be reviewable" is honored.

---

## 1. Context

### What issue #73 Part 2 says

> 2. **Make the values user-configurable** — let the user override the table values (config and/or UI), rather than relying solely on the bundled defaults, so a colony can tune the minimum breeding ages to its own management practice.
> - The unknown / absent-species fallback (currently 2) should also be reviewable as part of the configurable behavior.

### What Part 1 already delivered (S182–S183, live on `master`)

The bundled `speciesGestation` table now carries 14 common colony NHP species with four columns: `species` (character), `gestation` (integer days), `minMaleBreedingAge` and `minFemaleBreedingAge` (numeric years, so fractional minima like rhesus female 2.5 are exact). Two accessors read it and **already accept an override table + a configurable fallback**:

- `getSpeciesMinBreedingAge(species, sex, breedingTable = NULL, default = 2.0)` — `R/getSpeciesMinBreedingAge.R:37`
- `getSpeciesGestation(species, gestationTable = NULL, default = 210L)` — `R/getSpeciesGestation.R:28`

**So the leaf accessors are done.** Part 2 is entirely about *supplying* an override from the config file and *threading* it from the app down to those two accessors. The override path is half-built upstream and the gaps are precise (§2).

### Two consumer chains both ultimately call the accessors

1. **GVA / mean-kinship chain** (Genetic Value tab): `modGeneticValueServer` → `reportGV` → `correctUnknownParentMeanKinship` → `getBreedingPeerCohort` → **both** `getSpeciesMinBreedingAge` (breeding-age cutoff) **and** `getSpeciesGestation` (conception window). This chain uses *both* tables.
2. **Potential Parents chain** (Potential Parents tab): `modPotentialParentsServer` → `pedigreeGestationDefault` / `getPotentialParents` → `getSpeciesGestation` only.

The config-loading infrastructure (a CSV reader + soft-lookup helpers) is shared by both.

---

## 2. Evidence-based inventory (firsthand — every signature/line read this session)

### 2A. Config subsystem — how the config file is parsed and reaches the app

- `R/getSiteInfo.R:30` — `getSiteInfo <- function(expectConfigFile = TRUE)`. Reads the file → `getTokenList()` → extracts a **fixed, hardcoded set of keys** via `getParamDef()` (center, baseUrl, schemaName, folderPath, queryName, lkPedColumns, mapPedColumns) + ~10 system-info keys. **There is no passthrough of arbitrary keys.**
- `R/getParamDef.R:11` — `getParamDef(tokenList, param)` **STOPS with an error if the param is not found.** A required key absent from the file crashes parsing.
- `R/defaultSiteParams.R:23` — the single source of truth for the no-config ONPRC fallback (same 7 keys). Any new *required* key must be added here too.
- `R/loadSiteConfig.R:28` — `loadSiteConfig()` wraps `getSiteInfo(expectConfigFile = FALSE)` in `tryCatch`; returns the named list, or **`NULL`** (with a warning) on a missing/malformed file. Never crashes boot.
- `R/appServer.R:69` — `shared$config <- loadSiteConfig()`. When no config file exists, `shared$config` is **`NULL`**.
- **Precedent for an *optional* key** — `R/getConfigApiKey.R`: a separate soft-lookup that reads the config file for `apiKey`, returns `""` if absent, is **NOT** part of `getSiteInfo`/`defaultSiteParams`. Pinned by `test_setLabKeyDefaults.R`. **This is the pattern an optional override key must follow.**
- `R/getConfigFileName.R` — platform path: `~/.nprcgenekeepr_config` (Unix) / `~/_nprcgenekeepr_config` (Windows).
- `inst/extdata/example_nprcgenekeepr_config` — documented format: `key = value`, with multi-line / quoted / comma-separated list values (e.g. `lkPedColumns = (...)`). Parentheses are readability only (stripped by `getTokenList`).

**Implication:** adding *inline per-species table keys* to the config means modifying `getSiteInfo` + the `getParamDef`-STOP behavior (they'd need soft-lookup anyway). Adding *one optional scalar key* (a CSV path) needs **zero** `getSiteInfo` changes — just a `getConfigApiKey`-style helper. This drives **D1**.

### 2B. Breeding-age GVA chain — signatures and the exact threading gaps

| Function | File:line | Override state today |
|---|---|---|
| `getSpeciesMinBreedingAge(species, sex, breedingTable = NULL, default = 2.0)` | `R/getSpeciesMinBreedingAge.R:37` | **DONE** — accepts table + default |
| `getBreedingPeerCohort(focalBirth, focalSpecies, missingSex, candidatePed, gestationTable = NULL, breedingTable = NULL)` | `R/correctUnknownParentMeanKinship.R:31` | threads both **tables** (→ accessors at `:43-44`, `:47-49`); **no** configurable `default` param |
| `correctUnknownParentMeanKinship(indivMeanKin, ped, gestationTable = NULL, breedingTable = NULL)` | `R/correctUnknownParentMeanKinship.R:96` | threads both **tables** (→ cohort at `:131-138`); **no** configurable `default` param |
| `reportGV(ped, guIter = 5000L, guThresh = 1L, pop = NULL, byID = TRUE, updateProgress = NULL)` | `R/reportGV.R:72` | **GAP** — no override params; calls `correctUnknownParentMeanKinship(indivMeanKin, ped)` with no overrides at **`R/reportGV.R:103`** |
| `modGeneticValueServer(id, pedigree)` | `R/modGeneticValue.R:121` | **GAP** — no config param; `reportGV(...)` call at `R/modGeneticValue.R:185-191` threads no override |

### 2C. Gestation / Potential-Parents chain — signatures and gaps

| Function | File:line | Override state today |
|---|---|---|
| `getSpeciesGestation(species, gestationTable = NULL, default = 210L)` | `R/getSpeciesGestation.R:28` | **DONE** |
| `getPotentialParents(ped, minParentAge, maxGestationalPeriod = NULL, gestationTable = NULL)` | `R/getPotentialParents.R:39` | accepts `gestationTable`; consults it **only when `maxGestationalPeriod` is NULL** (`:63-69`); otherwise the supplied scalar is used for every animal (`:70-72`) |
| `pedigreeGestationDefault(ped, gestationTable = NULL)` | `R/modPotentialParents.R:83` | calls `getSpeciesGestation(..., gestationTable)` at `:84-85`; **no** `default` param (hardcodes the accessor's 210) |
| `modPotentialParentsServer(id, pedigree = NULL, minParentAge = 2.0, gestationTable = NULL)` | `R/modPotentialParents.R:208` | accepts `gestationTable`; uses it **only** for the prefill default (`gestationDefault` reactive `:216-219`). The `getPotentialParents(...)` call at **`:242-245` passes `maxGestationalPeriod = maxGest` and NO `gestationTable`** — and since `maxGest` is forced non-NULL (`:239-240`), `getPotentialParents` never reaches its per-animal branch in the app. **So the live effect of `gestationTable` in the app is the prefill only.** |

### 2D. Module wiring in `appServer` — the established pattern and the gap

- **Precedent 1:** `R/appServer.R:106` — `modInputServer("dataInput", config = reactive(shared$config))`. A module already receives the parsed config as a reactive.
- **Precedent 2:** `R/appServer.R:291-296` — `modORIPReportingServer(..., siteConfig = reactive(getSiteInfo(expectConfigFile = FALSE)))`.
- **GAP:** `R/appServer.R:266-269` — `modGeneticValueServer("geneticValue", pedigree = reactive(shared$currentPedigree))` — **no config**.
- **GAP:** `R/appServer.R:307-310` — `modPotentialParentsServer("potentialParents", pedigree = reactive(shared$currentPedigree))` — **no `gestationTable`/config** (so `gestationTable` is always NULL in the running app today).

### 2E. Tests that pin current behavior (TDD anchors / must-update)

| Test | What it pins | Touched by |
|---|---|---|
| `test_getSpeciesMinBreedingAge.R` | accessor: table injection, `default=2.0`, rhesus M=4/F=2.5, numeric type | none (accessor done) — **regression guard** |
| `test_getSpeciesGestation.R` | accessor: table injection, `default=210L`, integer type | none — **regression guard** |
| `test_correctUnknownParentMeanKinship.R` | cohort selection + `sexMean/2` correction; uses NULL tables (implicit defaults); fixtures `cohortPedNoSpecies`, `orchPed` | Slice 1 (new `default` param + table-threading tests) |
| `test_reportGV.R` | `reportGV` on `qcPed` (no species column → default cutoff 2, gestation 210); independently recomputes the Slice-2 correction (`dYear=365`, `minAge=2`, `gest=210` hardcoded ~`:87`) | Slice 1 (new override-threading tests; the hardcoded baseline stays valid for the no-override path) |
| `test_modGeneticValue.R` | `testServer(modGeneticValueServer, ...)`; `skip_on_cran()`; `makeValidTestPed()` factory | Slice 1 (new config-threading testServer test) |
| `test_getPotentialParents.R` | `maxGestationalPeriod` effect; per-animal `gestationTable` injection (RHESUS=210, TESTSP=90) | Slice 2 (regression; injection pattern is the model) |
| `test_modPotentialParents.R` | `testServer(modPotentialParentsServer, ...)`; already **injects `gestationTable`** into the module and tests the `gestationDefault` prefill; `prefillGuardAllows` guard | Slice 2 (new config-threading test) |
| `test-e2e-potential-parents-module.R` | browser-driven; hardcodes `maxGestationalPeriod = 210` | Slice 2 (optional e2e) — baseline `test-e2e-*` noise applies |
| `test_loadSiteConfig.R` | parses documented format; **`NULL` on missing/malformed**; uses `withr::local_tempdir()` + `withr::local_envvar(HOME = tmp)` isolation | **Copy this isolation pattern** for new reader tests; add the override-CSV cases |
| `test_getSiteInfo.R`, `test_defaultSiteParams.R`, `test_getConfigFileName.R` | fixed 7-key schema | none if D1 = CSV-path (no `getSiteInfo` change) |
| `test_setLabKeyDefaults.R` | `getConfigApiKey` optional soft-lookup (returns `""` if absent) | **the reader's design template** |

**Gap:** no existing test writes a config file containing *override* values and asserts they reach an analysis. That is the new coverage Part 2 adds.

---

## 3. Design decisions — RATIFIED (Session 185, 2026-06-23)

All decisions below were ratified **as recommended** (owner, via `AskUserQuestion`; see the Ratification record near the top and the resolved checklist in §7). The inline "*Ratify ...*" notes are now **settled** — they record what was decided, not open questions. Original options/rationale kept for the executor's context.

**D1 — How the override is expressed in the config file (load-bearing).**
Options: (a) a single optional key giving a **path to a CSV** of the species table; (b) **inline per-species keys** in the existing multi-line list format (e.g. `breedingTable = ("RHESUS", 4, 2.5) ("CYNOMOLGUS", 4, 2.5) ...`).
**Recommend (a) CSV path.** Rationale: (1) `getSiteInfo` is a fixed hardcoded-key schema and `getParamDef` *stops* on missing keys (§2A) — inline keys force changes to `getSiteInfo` + the strict-lookup behavior; a CSV-path key needs **zero** `getSiteInfo` changes and follows the proven `getConfigApiKey` optional-soft-lookup precedent. (2) The CSV header mirrors the bundled `speciesGestation` schema exactly (`species, gestation, minMaleBreedingAge, minFemaleBreedingAge`), so a colony can **export the bundled table, edit a few rows, and point at it** — self-documenting, no fiddly parenthesized-list syntax for tabular data. (3) Keeps `getSiteInfo` lean. *Load-bearing — ratify. The mappers split on this; the config-subsystem specialist made the stronger case for (a).*

**D2 — CSV schema.**
**Recommend:** one CSV with the four `speciesGestation` columns; a header row required; column order irrelevant (match by name). Numeric parsing: `gestation` → integer, breeding-age columns → numeric (preserve fractional minima). *Ratify whether a partial CSV (a subset of columns, e.g. only the two breeding-age columns) is allowed — see D4 merge semantics.*

**D3 — The fallbacks (absent-species defaults).**
**Recommend:** two optional scalar config keys, soft-looked-up like `apiKey`: `minBreedingAgeDefault` (numeric, default 2.0 when absent) and `gestationDefault` (integer, default 210 when absent). They flow to the accessors' `default =` argument. *Ratify the key names.*

**D4 — Replace vs. merge semantics (the deepest decision — affects user-facing results).**
The accessors treat a non-NULL table as a **full replacement**: a species absent from the supplied table falls to `default`, **not** to the bundled value. So if a user CSV lists only RHESUS, all other species would silently lose their bundled values and fall to 2.0 / 210.
Options: (a) **merge** the user CSV onto the bundled `speciesGestation` in the *reader* (user rows override matching species; unlisted species keep bundled values), passing a complete table to the accessors; (b) **replace** — the CSV is the entire table.
**Recommend (a) merge.** A colony tuning a few species almost certainly wants to keep the bundled values for the rest. Merge lives in the reader; the accessors stay unchanged. *Load-bearing — ratify. This is the #1 dragon: the wrong choice silently mis-ages every unlisted species.*

**D5 — Gestation override scope in the Potential Parents tab.**
Today `gestationTable` drives only the **prefill default** of the `maxGestationalPeriod` numeric input (§2C); the actual `getPotentialParents` call uses the user's scalar window, so per-animal species gestation is not applied in the app.
**Recommend:** Part 2 scope = the **prefill default** (the user's species gestation becomes the suggested window). Driving a true *per-animal* window would require a UI "auto/per-species" mode (let `maxGestationalPeriod` be NULL) **and** passing `gestationTable` at `R/modPotentialParents.R:242` — a deeper change. *Ratify keeping per-animal out of scope; note it as a possible follow-up.*

**D6 — Slice ordering.** GVA first (Slice 1), Potential Parents second (Slice 2). Slice 1 builds the shared reader; Slice 2 reuses it. *Ratify.*

**D7 — How the config reaches the modules.**
**Recommend:** load the overrides at boot alongside `loadSiteConfig()` and pass them to the two module servers as a reactive, exactly like `modInputServer("dataInput", config = reactive(shared$config))` (`appServer.R:106`). *Ratify whether the overrides ride inside `shared$config` or a sibling `shared$speciesOverrides`.*

---

## 4. Implementation plan — vertical slices (one session each)

Vertical, not horizontal (FM #25): each slice ships a working end-to-end path — config file → app → accessor — for one consumer. "If I stop after this slice, does something work?" Yes for each. The shared config-reader is built in Slice 1 (its first consumer), not as a standalone infrastructure slice (that would be a horizontal slice — infrastructure with no consumer).

### Slice 1 (first) = GVA tab configurable end-to-end
**Why first:** it is the chain tied to issue #9's mean-kinship correction (the original motivation), it uses *both* tables + *both* fallbacks, and it builds the reader reused by Slice 2.
**Scope:** (1) new config-reader: a `getConfigApiKey`-style `getSpeciesOverridesPath()` soft-lookup + a `loadSpeciesOverrides()` that reads the CSV, validates it, **merges onto bundled `speciesGestation` per D4**, and returns `list(breedingTable, gestationTable, breedingAgeDefault, gestationDefault)` (each `NULL`/built-in default when absent), failing soft (warn + return built-ins) like `loadSiteConfig`. (2) Add `breedingAgeDefault = NULL` + `gestationDefault = NULL` params to `getBreedingPeerCohort` and `correctUnknownParentMeanKinship`, threading them to the accessors' `default =`. (3) Add `breedingTable = NULL, gestationTable = NULL, breedingAgeDefault = NULL, gestationDefault = NULL` to `reportGV`; thread to `correctUnknownParentMeanKinship` at `R/reportGV.R:103`. (4) Add a config param to `modGeneticValueServer` (mirror `modInputServer`); read the overrides; pass to `reportGV` at `R/modGeneticValue.R:185-191`. (5) Load the overrides at boot in `appServer` and pass to `modGeneticValueServer` at `:266-269`. (6) Document the CSV + keys in `inst/extdata/example_nprcgenekeepr_config` (commented).
**RED:** (a) reader unit tests (copy `test_loadSiteConfig.R`'s `withr::local_tempdir()` + `local_envvar(HOME)` isolation): a temp CSV → merged tables + parsed fallbacks; missing path → NULL/built-ins; malformed CSV → soft-fail to built-ins; merge keeps bundled species (D4). (b) `test_reportGV.R`: `reportGV(qcPed, breedingTable = custom, breedingAgeDefault = 5)` changes the cohort/correction vs. the no-override baseline (independently recomputed). (c) `test_modGeneticValue.R`: a `testServer` test with a mocked config reactive carrying overrides → `reportGV` is called with them and the result reflects the custom cutoff.
**GREEN:** implement (1)–(6) minimally. **Backward-compat invariant:** every new param defaults to `NULL`; `NULL` ⇒ bundled table + built-in 2.0/210; no config file ⇒ `shared$config`/overrides `NULL` ⇒ identical to today. Test the no-config path explicitly.
**DONE looks like:** a colony's config-file CSV + fallback keys change the GVA mean-kinship correction (script *and* app); with no config file, output is byte-identical to today.
**Verify:** `Rscript -e 'suppressMessages(pkgload::load_all(".", quiet=TRUE)); testthat::test_file("tests/testthat/test_reportGV.R", reporter="summary")'` (+ the reader test, `test_correctUnknownParentMeanKinship.R`, `test_modGeneticValue.R` with `NOT_CRAN=true`); clean regression read (`as.data.frame(testthat::test_dir(...))`, check `sum(failed)`+`sum(error)`, isolate `!grepl("test-app-|test-e2e-", file)`); build-equivalent `devtools::check(vignettes = FALSE)` → 0/0/0 (Learning 161); **Phase-3E runtime smoke required** (it changes Shiny wiring): launch `runModularApp()` with a test config CSV, confirm the GVA reflects it and the no-config launch is unaffected.
**Session boundary:** one session. This is the **heavy** slice (reader + 3 function signatures + module + appServer). Close out when done.
**Dragons:** D4 merge (silent mis-aging if replace); the `NULL`-default-not-2.0 rule (Mapper B — a configurable default must default to `NULL` so the accessor's built-in is respected; never hardcode 2.0/210 at the `reportGV` layer); `modGeneticValueServer` gains a param — update its one call site (`appServer.R:266`) and `testServer` args; do not mutate the bundled `speciesGestation`.

### Slice 2 = Potential Parents tab configurable end-to-end
**Scope:** reuse Slice 1's reader. (1) Pass the override `gestationTable` + `gestationDefault` from `appServer` to `modPotentialParentsServer` at `R/appServer.R:307-310` (today it passes neither). (2) Add a `gestationDefault` param to `modPotentialParentsServer` and `pedigreeGestationDefault` (`R/modPotentialParents.R:83`, `:208`); thread to `getSpeciesGestation`. (3) Confirm the prefill (`gestationDefault` reactive `:216-219`) now reflects the user's gestation values.
**RED:** `test_modPotentialParents.R` (the file already injects `gestationTable` into the module) — add a `testServer` test that a config-carried override changes the `maxGestationalPeriod` prefill to the user's species value; a fallback test that a custom `gestationDefault` is honored for a species-less pedigree.
**GREEN:** implement (1)–(3) minimally. Backward-compat: no config ⇒ NULL ⇒ bundled prefill, identical to today; respect the existing `prefillGuardAllows` manual-edit guard.
**DONE looks like:** with an override CSV, the Potential Parents gestation-window prefill uses the colony's gestation values; no config file ⇒ unchanged.
**Verify:** the targeted test green (`NOT_CRAN=true` for the `testServer` file); clean regression read; build-equivalent 0/0/0; **Phase-3E runtime smoke** (Shiny wiring change): launch the app, load a species-bearing pedigree with a test config, confirm the prefill.
**Session boundary:** one session. Close out when done. **Closes #73** when published (the last part).
**Dragons:** the §2C subtlety — `gestationTable` only affects the prefill, not the computed window (D5); do not silently expand scope to per-animal windows. The `prefillGuardAllows` guard must still protect a user's manual edit.

---

## 5. Cross-slice notes

- **Ordering rationale:** Slice 1 (GVA) builds the reader + the `reportGV`/correction threading; Slice 2 (Potential Parents) reuses the reader and adds only module wiring. Independent enough that order could flip, but GVA-first gives the bigger tracer bullet first.
- **Each slice is a full RED → GREEN → REFACTOR session** with the phase-gate `AskUserQuestion` at every transition (Development Process Contract). Publish (PR → CI → merge) is the standard separate step; a **NEWS entry is user-facing and required** for each slice, folded into the same PR (Learning 157a). Slice 1's PR uses **"Relates to #73"**; Slice 2's (the last part) uses **"Closes #73"**.
- **Backward-compatibility is the load-bearing invariant across both slices:** all new params default to `NULL`; no config file ⇒ behavior identical to today. The no-config path must be an explicit test in each slice.
- **The two accessors are NOT modified** — they already accept overrides. All work is in the reader, the threading functions, the modules, and `appServer`.

## 6. Here be dragons (consolidated load-bearing risks)

- **R1 — Replace vs. merge (D4).** The accessors *replace*; a user CSV listing a few species would silently fall every other species to the fallback. Merge in the reader, and test that a one-row CSV keeps the other 13 bundled species.
- **R2 — `NULL`-default, not 2.0/210.** A configurable `default` threaded through `reportGV`/`correctUnknownParentMeanKinship` must default to `NULL` so the accessor's built-in is respected; hardcoding 2.0/210 at an upper layer breaks the no-config invariant (Mapper B). **Firsthand caveat (S185, verified at `getSpeciesMinBreedingAge.R:42,55` / `getSpeciesGestation.R:33,39-40):** the accessors do NOT handle `default = NULL` — `out <- rep(default, n)` with a `NULL` default yields `numeric(0)`/`integer(0)`. So the upper layers must translate "no configured default" into *not passing* `default` to the accessor (omit the argument, or compute `breedingAgeDefault %||% <accessor built-in>` **at** the accessor call), never thread a bare `NULL` into the accessor's `default`. The accessors are NOT modified (R7 / §5).
- **R3 — `getSiteInfo` is fixed-schema (D1).** `getParamDef` STOPS on missing keys; only the optional-soft-lookup (`getConfigApiKey`) pattern is safe for new keys. Do not add the override to the hardcoded list.
- **R4 — Gestation override is prefill-only in the app (D5).** Threading `gestationTable` to `getPotentialParents:242` is a no-op while `maxGestationalPeriod` is non-NULL; don't claim per-animal windows without the UI change.
- **R5 — Soft-fail like `loadSiteConfig`.** A missing/malformed override CSV must warn + fall back to bundled, never crash boot (the `tryCatch → NULL` philosophy; issue #50 regression guard).
- **R6 — Module signature changes ripple to call sites + `testServer` args.** `modGeneticValueServer` gains a param (one call site `appServer.R:266`; the `test_modGeneticValue.R` `testServer` args); `modPotentialParentsServer`/`pedigreeGestationDefault` gain a `gestationDefault`.
- **R7 — Do not mutate bundled `speciesGestation`.** Always merge into a copy / inject a table; never write the package data object.
- **R8 — Phase-3E is required for both slices** — they change Shiny runtime wiring (module params, boot loading). Build-clean is necessary but not sufficient (FM #24); launch the app with and without a test config.

## 7. Owner ratification checklist — RESOLVED (Session 185, 2026-06-23, owner via `AskUserQuestion`)

- [x] **D1** — config representation = **CSV path** (a single optional key, `getConfigApiKey`-style soft-lookup; no `getSiteInfo` change).
- [x] **D2** — CSV schema = the four `speciesGestation` columns, header row required, column order matched by name; a colony lists only the rows it wants to change (no column-level partial in v1).
- [x] **D3** — fallbacks = two optional scalar keys named `minBreedingAgeDefault` (numeric, built-in 2.0) and `gestationDefault` (integer, built-in 210).
- [x] **D4** — **merge** semantics: the user CSV overrides only listed species; unlisted species keep bundled values (merge in the reader; accessors unchanged).
- [x] **D5** — gestation override scope = **prefill default only**; per-animal window deferred to a follow-up.
- [x] **D6** — slice order = GVA (Slice 1) → Potential Parents (Slice 2).
- [x] **D7** — overrides ride in a **sibling `shared$speciesOverrides`** (separate from `shared$config`), passed to modules as a reactive (per the `modInputServer` precedent).
- [x] **No Settings-tab UI** this work (config-file only; `appUI.R:223-228` stays a placeholder).
- [x] **Backward-compat invariant** (no config ⇒ identical to today) is a hard acceptance test in each slice.
