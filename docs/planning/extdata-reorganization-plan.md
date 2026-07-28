# Plan — Reorganizing `inst/extdata/`

**Status:** Plan written Session 414 (DRAFT). Owner-directed (not from `BACKLOG.md`):
triggered by adding `Master_Genetic_metrics_2_14_15.pdf` to the folder, which prompted
the owner to ask for reorganization suggestions, explicitly flagging that "any changes
will affect the use of those files by the package." Owner picked scope via
`AskUserQuestion`: **"Cleanup + subfolder the used files"** — both relocating
non-shipped content out of `inst/extdata/` AND moving the genuinely-used example/config
data into a subfolder, updating every call site. This plan is that scoping; no code has
been touched.

**Workstream:** General Planning Sessions guidance (`SESSION_RUNNER.md` §Phase 2
"Planning Sessions") — no `*_WORKSTREAM.md` document maps cleanly onto a file-layout
migration, so this plan follows the master framework's Evidence-Based Inventory and
Per-Phase Completion Criteria requirements directly, mirroring the structure of
`docs/planning/issue122-module-contract-plan.md` (the project's own prior
migration-shaped plan).

---

## 1. Executive summary

`inst/extdata/` has accreted 43 items (2.5MB) over the package's history, mixing three
unrelated things in one flat directory: (a) genuine example/config data that ships with
the package and is read via `system.file()`, (b) UI-guidance HTML the Shiny app serves
(already its own well-organized `ui_guidance/` subfolder — a working example of the
pattern this plan extends), and (c) developer/session scratch material with zero
runtime reference, most of which is already `.Rbuildignore`'d but still clutters the
directory and confuses anyone browsing it. One dev script
(`create_nprcgenekeepr_hexbadge.R`) currently escapes the ignore net and ships in the
built tarball unintentionally.

**The decision:** split `inst/extdata/` into `examples/` (the 10 load-bearing files,
subfoldered the same way `ui_guidance/` already is) and `reference/` (the new PDF, once
its intended audience is confirmed — open decision, §10); relocate everything else
(11 dev-scratch items + 9 zero-reference orphaned files + 3 empty, never-tracked
directories) to the existing top-level `dev/` directory, which is **already**
`.Rbuildignore`'d (`.Rbuildignore:59`, `^dev$`) and already holds one other file
(`dev/config_attachment.yaml`, tracked since `774db157`) — so this reuses an
established convention rather than inventing a new one.

**Why this needs a plan, not a quick fix:** moving the 10 load-bearing files touches
every `system.file()`/hardcoded-path call site that names them — confirmed by direct
grep at **~50 distinct call sites across 3 `R/` files, ~15 test files, 2 `data-raw/`
provenance scripts, 2 vignette sources, and 4 generated `man/*.Rd` files**, several of
which are prose path mentions or rendered-artifact hrefs that `R CMD check` and the
test suite cannot catch if missed (see §7 Dragon 1). This is squarely "refactor across
module boundaries" territory (`SAFEGUARDS.md` Blast Radius Limits) and exceeds the
5-file-per-commit cap by a wide margin, so it needs multiple checkpoint commits across
multiple sessions, not one sitting.

## 2. Context — current state, verified firsthand

Full inventory, verified by direct `grep -rn`/`grep -rln` across `R/`, `tests/`,
`vignettes/`, `man/`, `data-raw/`, `README.Rmd`, `.Rbuildignore`, `.gitignore` (not
assumed from an initial single-pass research agent, which — see §7 Dragon 1 — missed
real references on its first attempt):

| Category | Count | Disposition this plan proposes |
|---|---|---|
| Load-bearing example/config data | 10 files | → `inst/extdata/examples/` |
| UI-guidance HTML (`ui_guidance/`) | 8 files | **Unchanged** — already correctly organized |
| Dev/session scratch | 11 files + `code_under_development/` (1 file) | → `dev/extdata-scratch/` |
| Orphaned (zero references anywhere) | 9 files | → `dev/extdata-scratch/` |
| Empty, never-tracked directories | `claude/`, `dev_scripts/`, `uat/` | Delete (no git effect — never tracked) |
| New, untracked-until-this-session | `Master_Genetic_metrics_2_14_15.pdf` | → `inst/extdata/reference/` **pending owner confirmation of intended audience** (§10) |

**DESCRIPTION and NAMESPACE contain zero `extdata` references** — nothing there
constrains this reorg.

**The hard constraint:** anything read via `system.file()` at runtime must stay under
`inst/` — that is the R-package mechanism for shipping installed data. Subfolders under
`inst/extdata/` are fine (`ui_guidance/` already proves the pattern); moving a
load-bearing file *out* of `inst/` entirely is not an option without changing how it's
read (e.g. converting it to a `data/*.rda` object instead — out of scope here, not
requested).

## 3. Issue claim re-verification

N/A — this is an owner-directed plan, not a GitHub issue.

## 4. Decision — the proposed layout

```
inst/extdata/
├── examples/                          # the 10 load-bearing files (system.file())
│   ├── ExamplePedigree.csv
│   ├── ExamplePedigree.txt
│   ├── focalAnimals.csv
│   ├── focalAnimalsShortList.csv
│   ├── obfuscated_rhesus_mhc_ped.csv
│   ├── obfuscated_rhesus_mhc_breeder_genotypes.csv
│   ├── rhesusPedigree_fromCenter.csv
│   ├── deidentified_jmac_ped.csv
│   ├── 2022-05-02_Deidentified_Pedigree.xlsx
│   └── example_nprcgenekeepr_config
├── ui_guidance/                        # unchanged (8 .html files)
└── reference/                          # new; standalone docs, not read by code
    └── Master_Genetic_metrics_2_14_15.pdf   (pending §10 decision)

dev/
├── config_attachment.yaml              # pre-existing, unrelated
└── extdata-scratch/
    ├── .Rapp.history
    ├── claude_code.qmd
    ├── code_under_development/combinerKinshipTriangles.R
    ├── create_nprcgenekeepr_hexbadge.R
    ├── example_usage.R
    ├── meeting_notes.qmd
    ├── meeting_notes.html
    ├── README_modules.md
    ├── script_used_to_look_for_gdata_dependency.R
    ├── software_design_doc.qmd
    ├── submission.txt
    ├── trulyUnknownParents.R
    ├── 2022-05-02_Deidentified_Pedigree_focal_animals.csv
    ├── deidentified_jmac_ped_edited.csv
    ├── emptyFocalAnimals.csv
    ├── ExamplePedigree_bad_dates.txt
    ├── jsslogo.jpg
    ├── no_animals.csv
    └── pedOne.csv, pedTwo.csv, pedThree.csv, pedFour.csv, pedFive.csv, pedSix.csv
```

`examples/` was chosen over `fixtures/`/`sample-data/` as a name because these files are
literally the data behind roxygen `@examples` blocks and vignette walkthroughs — but the
exact name is an open decision for the owner (§10), not asserted here as final.

## 5. Alternatives considered

- **Leave load-bearing files flat, only relocate dev-scratch/orphaned content.** This
  was Option 1 in the scoping question — zero `system.file()` call-site risk, could ship
  in a single low-risk session. **Rejected by the owner's choice** of the fuller option,
  but it remains the natural fallback if Phase 2+ below turns out riskier than estimated
  (see §7 Dragon 3 on the revert path).
- **Convert load-bearing CSVs to `data/*.rda` objects instead of `inst/extdata/`
  subfolders.** Would remove the `system.file()` indirection entirely, but changes the
  *access pattern* (`data(x)` vs. reading a real file path) — several tests and
  vignettes deliberately exercise the file-reading code path itself (e.g.
  `getFileDirectRelatives()`, `loadSiteConfig()`), so this would change what's being
  tested, not just where the bytes live. Out of scope; not requested.
- **One flat rename pass with a mechanical `sed` across the repo.** Rejected — several
  references are prose (roxygen `@description` text, GitHub blob URLs in rendered
  vignettes) that a blind path-string replace would technically "fix" but which need
  human eyes to confirm the resulting sentence still reads correctly (e.g.
  `defaultSiteParams.R:16`'s `\code{inst/extdata/example_nprcgenekeepr_config}` becomes
  `\code{inst/extdata/examples/example_nprcgenekeepr_config}` — mechanically correct,
  but each prose site should be visually confirmed, not blindly sedded).

## 6. Migration path — 4 phases, each ONE session

### Phase 1 — Relocate non-shipped content out of `inst/extdata/`

**What DONE looks like:** the 11 dev-scratch items + 9 orphaned items are `git mv`'d
into `dev/extdata-scratch/`; the 3 empty untracked directories (`claude/`,
`dev_scripts/`, `uat/`) are removed; `.Rbuildignore` lines 41-45 and 103-107 (the
now-obsolete `inst/extdata/`-scoped ignore patterns — full list in §8.3) are deleted (no
replacement needed — `dev/` is already covered by `.Rbuildignore:59`); `.gitignore`
lines 8-13 and 30-33 (dead entries naming files that no longer exist anywhere in the
tree — confirmed by `ls inst/extdata/`, §8.4) are deleted.

**Verification commands:**
```r
devtools::check()   # confirm clean build with the new .Rbuildignore
```
```bash
R CMD build . && tar tzf nprcgenekeepr_*.tar.gz | grep -E "extdata/(\.Rapp|claude_code|code_under_development|create_nprcgenekeepr_hexbadge|example_usage|meeting_notes|README_modules|script_used_to_look_for|software_design_doc|submission|trulyUnknownParents)"
# must return NOTHING -- confirms create_nprcgenekeepr_hexbadge.R (the file that
# currently ships unintentionally) is gone from the tarball, along with everything else
```
```r
pkgload::load_all(".", quiet=TRUE); as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE))
# 0 failed / 0 error / 0 warning -- nothing in this phase is read by any test, so the
# baseline (S412: 3198 passed, 179 skipped) must hold exactly
```

**Session boundary:** this phase is fully self-contained — zero `system.file()` call
sites change, since nothing in `R/`, `tests/`, or `vignettes/` references any of these
19 items (verified, §8.4). Close out after this phase; do not proceed to Phase 2 in the
same session (FM #18).

### Phase 2 — Create `inst/extdata/examples/`, migrate the 10 files, update code/test call sites

**What DONE looks like:** `git mv` each of the 10 load-bearing files into
`inst/extdata/examples/`. Update:
- The central `get_test_data_path()` helper (`tests/testthat/helper-shinytest2.R:177-178`)
  to insert the `examples` segment — this single change fixes every caller that goes
  through the wrapper rather than calling `system.file()` directly.
- Every remaining raw `system.file("extdata", "<name>", ...)` call site individually —
  full list in §8.1/§8.2 (~35 call sites across ~15 test files plus 3 `R/` files).
- The one **hardcoded, non-`system.file()`** relative path:
  `vignettes/a2interactive.Rmd:90` and its purled `vignettes/a2interactive.R:31`
  (`pedigreeFile <- "../inst/extdata/ExamplePedigree.csv"` →
  `"../inst/extdata/examples/ExamplePedigree.csv"`) — confirm whether `.R` is purled
  from `.Rmd` by a build step or hand-maintained separately before editing both.
- The two `data-raw/*.R` provenance-comment path mentions
  (`data-raw/rhesusGenotypes.R:18`, `data-raw/rhesusPedigree.R:9`) — not executed by any
  check, but load-bearing for future reproducibility.
- Prose path mentions in `R/defaultSiteParams.R:16`, `R/loadSiteConfig.R:11` (roxygen
  `\code{}` text, not code).
- Run `devtools::document()` to regenerate `man/examplePedigree.Rd`,
  `man/rhesusPedigree.Rd`, `man/rhesusGenotypes.Rd`, `man/loadSiteConfig.Rd`,
  `man/exampleNprcgenekeeprConfig.Rd` — **do not hand-edit these `.Rd` files**; they are
  generated from the roxygen comments above.

**Verification commands:**
```r
pkgload::load_all(".", quiet=TRUE); as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE))
# must match the pre-move baseline exactly (0/0/0, same pass/skip counts) -- any new
# failure means a call site was missed
devtools::check()
```
```bash
grep -rn "extdata/ExamplePedigree\.csv\|extdata/ExamplePedigree\.txt\|extdata/focalAnimals\.csv\|extdata/focalAnimalsShortList\.csv\|extdata/obfuscated_rhesus_mhc_ped\.csv\|extdata/obfuscated_rhesus_mhc_breeder_genotypes\.csv\|extdata/rhesusPedigree_fromCenter\.csv\|extdata/deidentified_jmac_ped\.csv\|extdata/2022-05-02_Deidentified_Pedigree\.xlsx\|extdata/example_nprcgenekeepr_config" R/ tests/ vignettes/ man/ data-raw/ README.Rmd
# every remaining hit must show the NEW examples/ segment -- any hit without it is a
# missed call site
```

**Session boundary:** this phase alone touches well over the 5-file blast-radius cap —
land it as multiple checkpoint commits within the session (e.g. one for `R/` +
`data-raw/`, one for the test-file batch, one for the regenerated `man/` files, one for
the vignette source), never all in a single commit. Do not proceed to Phase 3 in the
same session.

### Phase 3 — Re-render rendered artifacts that embed the old path

**What DONE looks like:** the rendered outputs whose *source* Phase 2 already fixed are
regenerated so the shipped/published copy matches:
- `vignettes/manual_components/_summary_of_major_functions.Rmd:66` (source — GitHub
  blob URL to `example_nprcgenekeepr_config`) → re-render `vignettes/a3manual.Rmd`,
  producing updated `vignettes/a3manual.md` and `.html`.
- `vignettes/a2interactive.Rmd` (source, fixed in Phase 2) → re-render to regenerate
  `vignettes/a2interactive.html`.
- `vignettes/articles/offline-focal-animal-workflow.qmd` → re-render (pkgdown article;
  confirm the `.quarto/idx/*.json` build cache doesn't need manual clearing).

**Verification commands:**
```bash
grep -rln "inst/extdata/example_nprcgenekeepr_config\|inst/extdata/ExamplePedigree" vignettes/*.html vignettes/*.md
# must return NOTHING -- every rendered artifact should show the new examples/ path
```
Manually click through the regenerated `a3manual.html`'s GitHub-blob-URL link and
confirm it resolves (grep alone won't catch a link that's syntactically present but
points at a 404 — see §7 Dragon 1).

**Session boundary:** self-contained once Phase 2's sources are fixed; do not fold into
Phase 2 (rendering tools/verification are a distinct surface — mirrors
`docs/planning/document2-colony-manager-guide-plan.md`'s Phase B/C split precedent).

### Phase 4 — Place the new PDF; final full-repo sweep

**What DONE looks like:** once §10's open decision is resolved, `git mv` the PDF to its
final location (`inst/extdata/reference/` or elsewhere). Run one last repo-wide grep for
any straggler reference to the old flat `inst/extdata/<name>` paths across every file
type touched by Phases 1-3 (not just the targeted searches above) to catch anything the
phase-by-phase verification missed.

**Verification commands:**
```bash
grep -rn "inst/extdata/" --include="*.R" --include="*.Rmd" --include="*.qmd" --include="*.md" --include="*.Rd" . | grep -v "inst/extdata/examples/\|inst/extdata/ui_guidance/\|inst/extdata/reference/\|docs/planning/extdata-reorganization-plan.md\|CHANGELOG.md\|SESSION_NOTES.md\|PROJECT_LEARNINGS.md\|HANDOFFS.md"
# every remaining hit is either a false positive (dev-log prose describing history) or
# a missed call site -- triage each one
devtools::check()
```

**Session boundary:** final phase; close-out here completes the migration.

## 7. Dragons — where this plan is dangerous

**Dragon 1 — a single-pass, filename-only research grep is not enough.** This plan's
first evidence pass (a general-purpose search agent) reported `ExamplePedigree.csv`'s
references as "extensive... many other E2E/module tests" without full enumeration, and
missed entirely: `test_modInput_incomplete_final_line.R`, a whole test file
(`test-e2e-input-incomplete-final-line.R`), and — most importantly — a **hardcoded,
non-`system.file()` relative path** in `vignettes/a2interactive.Rmd`/`.R`
(`"../inst/extdata/ExamplePedigree.csv"`). A direct `grep -rn` for the exact filename
string across every relevant directory, run afterward, caught all of it. **The
implementing session must re-run its own exhaustive grep immediately before touching
any file** (§6 Phase 2's verification commands) rather than trusting §8's inventory as
final — this plan's inventory is the strongest available starting map, not a
substitute for that final grep, exactly per the Evidence-Based Inventory requirement.

**Dragon 2 — prose and rendered-artifact references break silently.** Roxygen
`\code{inst/extdata/...}` text, `data-raw/*.R` provenance comments, and GitHub blob URLs
in rendered vignettes are not exercised by `R CMD check` or the test suite at all — a
missed one produces a documentation page or manual that reads correctly but links to a
404, discoverable only by a human clicking through or a dedicated link-check pass (this
project already has precedent for exactly this kind of miss — see `CLAUDE.md`'s
`BACKLOG.md` history on issue #124's broken `.qmd`-vs-`.html` vignette links). Phase 3's
verification explicitly calls for a manual link click, not just a grep.

**Dragon 3 — the revert boundary is Phase 1, not Phase 2.** Per the Vertical Slice
Sessions gate (d), if Phase 2's verification comes back with test failures the
implementing session can't resolve in-session, the correct move is to revert Phase 2's
changes and close out at Phase 1's last clean checkpoint commit — not push forward with
a half-migrated `system.file()` call-site set. Phase 1 stands alone and delivers real
value (a cleaner `inst/extdata/`, the hexbadge-shipping defect fixed) even if Phase 2+
never happens.

**Dragon 4 — `vignettes/a2interactive.R` may be a generated artifact, not hand-maintained.**
If it's `knitr::purl()`'d from `a2interactive.Rmd` by a build step this plan didn't find,
hand-editing both is redundant at best and divergent at worst (mirrors this project's
own `NEWS.Rmd`-not-`NEWS.md` and `README.Rmd`-not-`README.md` lesson — edit the source,
regenerate the artifact). Confirm which before Phase 2 touches it.

## 8. Evidence-based inventory (grep-derived, not assumed)

### 8.1 Files moving into `inst/extdata/examples/`, with every reference found

| File | R/ references | Test references | Other references |
|---|---|---|---|
| `ExamplePedigree.csv` | `R/data.R:18,21` (prose) | `test-e2e-potential-parents-module.R:141,143`; `test_modInput_incomplete_final_line.R:21,25`; `test_modInput.R:825`; `test-e2e-input-incomplete-final-line.R:9,31,39,59,94` | `man/examplePedigree.Rd:6,15` (generated); `vignettes/a2interactive.R:31` + `.Rmd:86,90` (**hardcoded path**, not `system.file()`) + `.html:1671` (rendered); `vignettes/articles/offline-focal-animal-workflow.qmd:106` |
| `ExamplePedigree.txt` | — | `test-shinytest2-debug.R:46` | — |
| `focalAnimals.csv` | — | `test_getFocalAnimalPed.R:536,537,540,542` | — |
| `focalAnimalsShortList.csv` | — | `test_getFocalAnimalPed.R:121,122,294,297,299`; `test_modInput.R:724,776,822,866,909` | `vignettes/articles/offline-focal-animal-workflow.qmd:104` |
| `obfuscated_rhesus_mhc_ped.csv` | `R/data.R:369` (prose) | `test-e2e-breeding-groups-detailed.R:98`; `test-e2e-pedigree-tutorial.R:34,178`; `test-e2e-breeding-groups-tutorial.R:144,208`; `test-e2e-pedigree-module.R:69`; `test-e2e-pedigree-detailed.R:72`; `test-e2e-genetic-value-tutorial.R:111,169`; `test_modInput_qcStudbook.R:512,686` | `man/rhesusPedigree.Rd:16` (generated) |
| `obfuscated_rhesus_mhc_breeder_genotypes.csv` | `R/data.R:355` (prose) | `test_modInput_qcStudbook.R:515` | `man/rhesusGenotypes.Rd:20` (generated); `data-raw/rhesusGenotypes.R:18` (provenance comment) |
| `rhesusPedigree_fromCenter.csv` | — | `test-e2e-potential-parents-module.R:16,78` (`get_test_data_path()`) | `data-raw/rhesusPedigree.R:9` (provenance comment) |
| `deidentified_jmac_ped.csv` | — | `test_species_first_class.R:68` | — |
| `2022-05-02_Deidentified_Pedigree.xlsx` | — | `test_modInput_coverage.R:72` | `dev/extdata-scratch/trulyUnknownParents.R:8-9` (frozen dev script, hardcoded path — will go stale; acceptable since it's an archived, non-runnable artifact, but flag rather than silently ignore per Learning #7's spirit) |
| `example_nprcgenekeepr_config` | `R/data.R:7` (prose); `R/defaultSiteParams.R:16` (prose); `R/loadSiteConfig.R:11` (prose) | `test_getSiteInfo.R:32`; `test_loadSiteConfig.R:5,24,43,71` | `man/loadSiteConfig.Rd:20`, `man/exampleNprcgenekeeprConfig.Rd:15` (generated); `vignettes/a3manual.md:147`, `.html:206` (rendered, GitHub blob URL); `vignettes/manual_components/_summary_of_major_functions.Rmd:66` (**source** — GitHub blob URL) |

### 8.2 The central test helper

`tests/testthat/helper-shinytest2.R:177-178`:
```r
get_test_data_path <- function(filename) {
  system.file("extdata", filename, package = "nprcgenekeepr")
}
```
Update to `system.file("extdata", "examples", filename, package = "nprcgenekeepr")` —
fixes every caller using this wrapper (confirmed callers include
`test-e2e-potential-parents-module.R:78`, `test-e2e-input-incomplete-final-line.R:59,94`)
without touching those call sites individually.

### 8.3 `.Rbuildignore` lines that become obsolete after Phase 1

Lines 41-45 and 103-107 (current numbering) all scope patterns to
`^inst/extdata/...` paths that Phase 1 empties out:
```
41:^inst/extdata/.*\.docx$                          (already dead -- no .docx exists)
42:^inst/extdata/code_under_development$
43:^inst/extdata/script_used_to_look_for_gdata_dependency\.R$
44:^inst/extdata/meeting_notes\.
45:^inst/extdata/rhesus_studbook*$                   (already dead -- no such file exists)
103:^inst/extdata/.*\.qmd$
104:^inst/extdata/README_modules\.md$
105:^inst/extdata/example_usage\.R$
106:^inst/extdata/trulyUnknownParents\.R$
107:^inst/extdata/submission\.txt$
```
No replacement pattern is needed — `dev/` is already covered by `.Rbuildignore:59`
(`^dev$`).

### 8.4 `.gitignore` lines naming files that no longer exist anywhere in the tree

Confirmed via `ls inst/extdata/` (current, S414) — none of these filenames are present:
```
8:inst/extdata/BaboonLivingForMetrics.csv
9:inst/extdata/RhesusMasterForMetrics.csv
10:inst/extdata/Notes.txt
11:inst/extdata/PSCPO*.*
12:inst/extdata/notes.*
13:!inst/extdata/notes.Rmd
30:inst/extdata/meeting_notes.html    (moot after Phase 1 -- also already git-tracked, so this line is currently a no-op)
31:inst/extdata/meeting_notes.tex     (no .tex file exists)
32:inst/extdata/meeting_notes.pdf     (no such file exists)
33:inst/extdata/simulatedKValues.pdf  (no such file exists)
```

### 8.5 Files with zero references anywhere (orphaned) and empty/never-tracked directories

Orphaned (confirmed via targeted `grep -rln` across `R/`, `tests/`, `vignettes/`,
`man/`, `data-raw/`, `README.Rmd`, `docs/` — no hits for any of these as a filename or
via variable indirection): `2022-05-02_Deidentified_Pedigree_focal_animals.csv`,
`deidentified_jmac_ped_edited.csv`, `emptyFocalAnimals.csv`,
`ExamplePedigree_bad_dates.txt`, `jsslogo.jpg`, `no_animals.csv`, `pedOne.csv`,
`pedTwo.csv`, `pedThree.csv`, `pedFour.csv`, `pedFive.csv`, `pedSix.csv`. Note: the
package's `pedOne`/`pedSix` **data objects** (`data/pedOne.RData`, `data/pedSix.RData`)
are generated programmatically by `R/createPedOne.R`/`R/createPedSix.R`
(`data.frame()` construction with a fixed seed) and do **not** read these CSVs — the
name collision is coincidental, not a hidden dependency.

Empty, never-tracked directories (`git log -- <dir>` returns nothing for any of these):
`claude/`, `dev_scripts/`, `uat/`.

### 8.6 `ui_guidance/` — confirmed unchanged, listed for completeness

Each of the 8 files is read via `system.file("extdata", "ui_guidance", "<file>.html", ...)`
from exactly one `R/mod*.R` caller: `modGeneticValue.R:99`, `modBreedingGroups.R:123`,
`modGvAndBgDesc.R:31`, `modInput.R:190`, `modPedigree.R:44`, `modSummaryStats.R:44,224-225`,
`modPyramid.R:60`. No change proposed; cited here so the inventory is complete.

## 9. Impact analysis

- **Package users:** none who read these files via `system.file()` are affected by
  Phase 1 (nothing they'd call is moving). Phase 2's file moves are purely internal path
  changes behind the same exported functions — no user-facing API or behavior changes.
- **CRAN tarball size/contents:** Phase 1 removes one currently-unintentional inclusion
  (`create_nprcgenekeepr_hexbadge.R`) and confirms (via the `tar tzf` check) that the
  rest of the dev-scratch cluster, already `.Rbuildignore`'d, truly isn't shipping.
- **Git history:** using `git mv` (not delete+recreate) preserves file history/blame
  across the move for every relocated file.
- **CI / `R CMD check`:** both phases are designed to leave `devtools::check()` and the
  full regression suite exactly as clean as the pre-migration baseline (S412: 0 failed/0
  error/0 warning, 3198 passed, 179 skipped) — any deviation signals a missed call site.

## 10. Open decisions for the implementing sessions

1. **Where does `Master_Genetic_metrics_2_14_15.pdf` actually belong?** This plan
   defaults to `inst/extdata/reference/` (shipped with the package, discoverable via
   `system.file()`), but that's only correct if the PDF is meant to be
   **end-user-facing** reference material analogous to `ui_guidance/`. If it's instead a
   personal/research reference with no intended package-user audience, it belongs in a
   non-shipped location (e.g. `dev/` or a top-level `docs/reference-material/`) instead.
   **Ask the owner directly before Phase 4 places it** — do not assume either answer.
2. **Subfolder naming: `examples/` vs. alternatives** (`fixtures/`, `sample-data/`,
   `package-data/`). This plan uses `examples/` because the files back roxygen
   `@examples` blocks and vignette walkthroughs, but the name is a style choice, not a
   technical constraint — confirm with the owner before Phase 2, since renaming a
   subfolder after Phase 2's call sites are written is exactly the kind of rework this
   plan exists to avoid.
3. **Whether to delete the 9 orphaned files outright rather than archive them to
   `dev/extdata-scratch/`.** They're safely recoverable via git history either way
   (`SAFEGUARDS.md` "Never delete a file without verifying it's committed" is satisfied
   — all are already committed); this plan defaults to archive-not-delete as the more
   conservative choice, but the owner may prefer outright deletion given zero references
   were found anywhere.
4. **Confirm `vignettes/a2interactive.R`'s generation status** (Dragon 4) before Phase 2
   touches it — hand-maintained companion script, or `knitr::purl()` output that should
   be regenerated instead of hand-edited?
