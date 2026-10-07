# Docs-audit slice 2: scoping plan for the guide screenshots

**Status: DRAFT plan, written S927 (2026-10-06). Nothing in it has been executed.** No image, script or `R/` file was changed
to write it. Every number below was measured this session unless it says "S821" (the audit this plan acts on,
`docs/audits/DOCS_STALENESS_AUDIT_SLICE2_2026-09-30.md`) or "not measured".

> **Update S928 (2026-10-06): Phase 1 is DONE; the crash is fixed** (RED `2ceb443dd`, GREEN `79e54d7d4`). **The cause was
> not what "The tail failure, explained" items 2 and 6 below suspected** (not the kinship matrix, not S923-S925's changes;
> the app's matrix was complete, 3,694 x 3,694). A group member with no birth date has age `NA`;
> `group$id[sex == "F" & age >= 3]` then held an `NA` id, and `kmat[NA, males]` stops with `subscript out of bounds`
> (`R/getKinshipWithMaleStatus.R:51-53` before the fix; the lines date from 2026-07-05). The shipped example has 1,432 of
> 3,694 animals with no birth date, and the app's default Top ranked group (20 animals) has a birth date on none of them.
> A Genetic Value run only matters because the diversity heat map needs its values. The trigger table below describes
> symptoms, not the cause. The Genetic Diversity module's background "ready" step also can no longer end a session.
> Phase 3c, which needed Phases 1 and 2, now waits only on Phase 2 (Phases 2, 3a and 3b never waited on Phase 1); the
> by-hand browser check this plan asked for was done S929 (the owner, in Chrome, Top ranked source: the page stayed live and
> the heat map drew).

## What this plan is for

The colony-manager guide (`vignettes/articles/colony-manager-guide.qmd`) and the Diagram article
(`vignettes/articles/pedigree-diagram.qmd`) show 50 screenshots in `vignettes/articles/shiny_app_use/`. S821 found about two
thirds of the regenerable ones no longer match the app, and that the capture script fails near its end. It left two
questions open: which images to redo, and why the script fails. This plan answers both and orders the work into sessions.

## The one finding that changes the order of work

**Forming breeding groups after a Genetic Value Analysis run, on the shipped 3,694-animal example pedigree, ends the
user's session.** The page turns grey with Shiny's "disconnected" overlay. That is exactly the colony-manager guide's
walkthrough. It is a bug in the app, not in the screenshot script; the script only exposed it. Nine of the 38 regenerable
images cannot be captured correctly until it is fixed. Details are in "The tail failure, explained" below.

## Decisions for the owner

Each has a recommendation first. None is needed to start Phase 1; D2 to D5 are needed before the phase that uses them.

1. **Order: fix the session-ending crash first (Phases 1-2), or redo the 27 images that already capture correctly first
   (Phases 3a-3b)?** The two are independent. *Recommend the crash first:* it is a bug a user can hit, it costs one or two
   sessions, and until it is fixed 9 of the 38 images cannot be redone at all.
2. **`pb_unknown_displayed.png`: delete it and its capture line, or keep it?** Nothing in the repo uses it (measured), and
   the script's own comment (`colony-manager-guide-screenshots.R:236-241`) says it is the same view as
   `pb_10_rows_display_unknown_ids.png`. *Recommend delete.*
3. **Home screenshot: accept that it shows the install date?** The Home page prints the version and the date the package
   was installed (`R/appUI.R:85`, `R/getVersion.R:15-24`), so this image differs after every reinstall. *Recommend accept*:
   redo it with the others and do not count its date line as staleness.
4. **The three spreadsheet pictures (`ss_kinship_matrix.png`, `ss_first_order_relationships.png`, `ss_female_founders.png`):
   retake by hand, or replace each with a table the article builds from the real export code so it cannot go stale?**
   Two of the three are out of date from the code alone (below). *Recommend the second if the article can call the same
   package functions* (not checked yet; Phase 4a checks it first and falls back to retaking by hand).
5. **The nine Marker Genetics pictures: script them, or leave them as hand-captured pictures?** The article describes four as
   using example data that matches files shipped in the package; five show a small made-up trio and two-center data set
   that I found no file for in the repo (details below). *Recommend script all nine, last,* after the other phases, because they are the least known to be stale.

## What was measured

### The 50 images

| Group | Images | Result today |
|---|---|---|
| Written by `colony-manager-guide-screenshots.R` | 33 | 1 identical, 3 same size but pixels differ, 29 differ in height |
| Written by `pedigree-diagram-screenshots.R` | 5 | all 5 are exactly 147 px taller than the committed image |
| Written by no script | 12 | not re-captured; see "The 12 images with no script" |

So **37 of the 38 images a script writes differ from the app today** (S821 counted 31). The one identical image is
`read_and_check_pedigree.png`. The sizes moved between S821 and today (Input +128 px then, +57 px now; Summary Statistics
+1,319 px then, +1,342 px now), so the app is still changing under the images: **re-measure at the start of every
regeneration session; do not trust this table's numbers then.**

Of the 37 that differ:

- **28 were captured before the session ended and can be judged now:** the 15 Pedigree Browser and Diagram images (+147 px),
  the 4 Input images (+57 px), Home, the Age-Sex Pyramid image (0.24% of pixels, one text line), the 3 Summary Statistics
  images (+1,342 px), the 3 Genetic Value Analysis images (+158 px) and `breeding_group_first_view.png` (+180 px).
- **9 cannot be judged until the crash is fixed:** `breeding_group_1`, `_6_infants_with_dam`,
  `_first_group_no_kinship_seeds_indicated`, `_6_seed_grps_grp_6_kinship`, `_sex_ratio_specification`,
  `genetic_diversity_heatmap` (a grey overlay), `potential_parents_results` (900 px tall against 7,121 px committed) and
  the two Mate Pair images. Three of the Breeding Groups captures are exactly the height of the empty first view (1,953 px), and the
  one I viewed (`breeding_group_6_seed_grps_grp_6_kinship.png`) is the grey, disconnected page with empty group selectors.

### Why the images differ: text and new controls, not layout bugs

Viewed side by side (committed above, fresh below):

- **Input (+57 px):** the "Input File Handling" guidance gained a longer paragraph about placeholder IDs.
- **Pedigree Browser and Diagram (+147 px):** the "Display Unknown IDs" help text is longer, and the Diagram legend has a new
  dashed row, "Same animal, again" (S921). The committed `pb_diagram_legend.png` has neither, so it **is** one of the stale
  images (S921 left that unchecked).
- **Summary Statistics:** the "Kinship overrides" paragraph was reworded and the page is 1,342 px taller (the extra height
  was located, not itemized).
- **Breeding Groups:** the panel gained an **Ancestry** sub-tab (issue #168). The guide's prose already covers ancestry
  guardrails (`colony-manager-guide.qmd:535`), so this is an image gap, not a prose gap.
- **Home:** the navbar has more tabs, and the install date line changes (Decision 3).

One cause repeats: help text and new controls shift a whole panel, so every image of a module changes together. That is
why the plan regenerates **by module**.

### The tail failure, explained

S821 saw the colony script fail the same five steps every time. This session's full run did too: **76 of 81 steps, the same
five failures** (select group 6, Potential Parents results, Marker Genetics navigation, the Mate Pair exclude-list box,
Mate Pair completion). The cause, with each step measured:

1. **The Genetic Diversity module has an `observe()` that evaluates the whole diversity-statistics chain whenever groups
   form** (`R/modGeneticDiversity.R:135-141`; its only stated purpose is to send the "data ready" message for tests). It
   runs even when that tab is not open.
2. **On the example pedigree with a Genetic Value Analysis run first, that chain throws** `Error in [: subscript out of
   bounds`, at `R/getKinshipWithMaleStatus.R:62` (`any(kmat[f, males] <= threshold)`), reached through
   `getGeneticDiversityStats()` (`R/getGeneticDiversityStats.R:101`) and `modGeneticDiversity.R:104`. The guard just above
   it (`R/getKinshipWithMaleStatus.R:46-50`) checks the matrix's row names only. **Why the index is out of bounds is not
   determined** (Phase 1's first job).
3. **An unhandled error in an observer ends a Shiny session** (Shiny's standard behavior). Measured: the grey
   `shiny-disconnected-overlay` is present, `Shiny.shinyapp.$socket` is gone, the app server process sits at 0.0% CPU with
   its main thread in the normal event wait (`sample` of the process), and three visible outputs stay `.recalculating`
   for as long as they were watched (95 s). After a further tab switch the browser's input value changed but the visible tab
   pane held only 408 characters (no baseline was taken for that figure).
4. **Which setups trigger it** (all runs on this Mac, Shiny 1.14.0, shinytest2 0.5.1; "idle" = Shiny reports idle for
   3 s):

   | Setup | Result |
   |---|---|
   | Example pedigree (3,694), Genetic Value run first, "Top ranked", default 10 simulations | ends the session |
   | Example pedigree, Genetic Value run first, "All available", 5 simulations (run 3 times) | ends the session |
   | Example pedigree, **no** Genetic Value run, "All available", 5 simulations | fine: ready at 5 s, idle at 7 s |
   | Rhesus fixture (375 animals), Genetic Value run first, "Top ranked" | fine: ready at 1 s, idle at 3 s |
   | `test-e2e-breeding-groups-tutorial.R` (rhesus, no Genetic Value run, "All available", 5 simulations) | passes: 11 tests, none skipped |

   So the trigger is *Genetic Value run, then form groups, on the large example*. It does not need the Pedigree Browser
   steps (the diagnostic skipped them) and does not depend on the simulation count.
5. **The CI blind spot:** the end-to-end tests that would catch this use the small fixture, so they pass.
6. **When it started is not determined.** The Breeding Groups images committed 2026-08-10 are far taller than the empty
   first view, so groups were displayed then; the crash is probably newer. Suspects (not tested): the shape-preserving
   changes to `filterKinMatrix()` (S923), `kinship()` and `calcA()` (S925). No bisect was run.

### A second, smaller finding: the readiness flag never resets

`data-ready` on the Breeding Groups container is set to `"true"` after the first formation
(`R/modBreedingGroups.R:742-745`) and **nothing in `R/` ever sets it back** (there is no `setDataLoading` caller anywhere;
the handler is `inst/www/js/data-ready.js`). So `wait_for_module_ready(app, "breedingGroups")` returned in **0.0 s** for the
second and third formations in the diagnostic, and the script's "wait for 6-group formation" does not wait. The script's
other waits hide this: `click_element_safe()` turns its own timeout into `FALSE` (`tests/testthat/helper-shinytest2.R:280-286`)
and `do_step()` ignores that value (`colony-manager-guide-screenshots.R:116-123`), so a timed-out step is logged as a success.

### The 12 images with no script

- **Three spreadsheet pictures** of exported CSV files. By the code alone: `ss_first_order_relationships.png` and
  `ss_female_founders.png` show a leading row-number column that the app no longer writes (`row.names = FALSE`,
  `R/modSummaryStats.R:850,860,871`), so both are stale; `ss_kinship_matrix.png` still has the right shape (the kinship
  export keeps row names, `:840`). All three show old file names (`FirstOrder.csv`, `Kinship.csv`); the app now writes
  `first_order_relationships_<date>.csv`, `kinship_matrix_<date>.csv` and so on (`:838-866`).
- **Nine Marker Genetics pictures.** Four are described in the article as using example data that matches files shipped in
  `inst/extdata/examples/` (counts checked, tab not re-run on them): `marker_genetics_linkage_coverage` and
  `_linkage_ldblock` ("12-locus example STR panel": `example_locus_metadata.csv` has 12 rows, `example_str_marker_genotypes.csv`
  has 10 animals x 12 loci), `_genomic_roh` ("50-individual, 1,000-locus": `example_sequence_genotypes.csv`) and
  `_mhc_haplotype` ("31-animal": `obfuscated_rhesus_mhc_breeder_genotypes.csv`, 31 rows). Five (`_comparison`, `_heterozygosity`,
  `_parentage_exclusion`, `_cross_center`, `_candidate_assignment`) show a made-up trio (animals P, C, U, Q; loci L1-L10)
  or two made-up centers; I found no file for them in `inst/`, `tests/testthat/` or `vignettes/` (the tests build similar
  data in code, e.g. `test_modMarkerGenetics.R:183`). Whether any of the nine is stale is **not measured**.

## Alternatives considered

| Alternative | For | Against | Verdict |
|---|---|---|---|
| Regenerate all 37 now with the script as it is | One session | 9 captures would show a grey, dead page; the waits do not wait | Rejected |
| Redo only the 27 that capture correctly, leave the rest | Fast; no code change | Leaves the guide's Breeding Groups chapter wrong and the crash unfound | Partly adopted: Phases 3a-3b can run first (Decision 1) |
| Fix the crash and the script, then regenerate by module | Fixes the cause; each session has a reviewable, bounded diff | More sessions (7-8) | **Recommended** |
| Crop screenshots to a viewport instead of whole panels, so help-text changes stop moving them | Less drift | Changes the script's recorded framing decision (whole panel for context, `colony-manager-guide-screenshots.R:50-59`); not asked for | Not proposed; say if wanted |
| A CI check that flags stale images | Catches drift | Pixel checks are fragile (this session's runs differ between machines and states); CI does not run the capture scripts today | Not proposed |

## The plan (each phase is its own session; close out when it is done)

**Surface for every phase below:** shinytest2 driving a headless Chrome against this Mac's local app (the same surface that
produced S821's and this session's numbers), with `NOT_CRAN=true Rscript` from the repo root. It can show that a capture
completed and what it looked like; it **cannot** show how the app behaves on a user's real data in a real browser, and it
does not exercise the published website. Where a phase needs more, it says so.

### Phase 1: diagnose and fix the session-ending error (expect 1-2 sessions; strict TDD for the fix)

- **Do:** (a) reproduce it with function calls and no browser (build the Genetic Value result and a formed group from
  `examplePedigree`, call `getGeneticDiversityStats()`); (b) find why `kmat[f, males]` is out of bounds; (c) bisect with the
  Appendix B snippet if (b) is unclear, starting at the S923-S925 shape changes; (d) fix it at the cause; (e) decide whether
  the test-only `observe()` at `modGeneticDiversity.R:135-141` should be able to end a session at all (recommend it should
  not); (f) pre-RED scope gate with the owner before any code, per `CLAUDE.md`.
- **DONE looks like:** a test that failed for the right reason and now passes; the Appendix B snippet reports the page idle
  with no disconnected overlay; the full suite and `devtools::check()` clean; `lintr::lint_package()` 0.
- **Verify:** single-file tests, then the full suite and check one at a time; the Appendix B snippet.
- **Also owed:** a short check by hand in a real browser (Claude in Chrome is available), since the harness cannot prove
  what a person sees. The Shiny disconnect overlay is the same one a person sees, which is why the harness result is
  credible, but it is not the same as watching it.
- **STOP:** close out after the fix. Phase 2 is separate.

### Phase 2: make the capture script's waits mean something (script only; one session)

- **Do:** (a) reset `data-ready` to `"false"` in the page just before each Form Groups click (script-side, one JS line), or
  have the app send `ready = FALSE` when `formGroups` fires (app-side; only if Phase 1 left that file open); (b) make
  `do_step()` count a `FALSE` from `click_element_safe()` as a failure; (c) list idle-wait timeouts in the end-of-run
  summary; (d) take the output folder from an environment variable so a run can write to a scratch folder and be reviewed
  before anything is overwritten (this session did that with a copy); (e) give `potential_parents_results.png` a capture
  that can reproduce its 7,121-px height (today it captures the 1300 x 900 window); (f) the toast "Updated focal animals: 3
  IDs" overlaps the "Twin/Zygosity Relations" heading in the fresh `pb_diagram_legend.png`, so make the script wait for it
  to clear.
- **DONE looks like:** a full run on the fixed app, into a scratch folder, with all 81 steps succeeding and no idle-wait
  timeouts; `git status` clean for `shiny_app_use/`.
- **Verify:** the run's own summary; `git status --short vignettes/articles/shiny_app_use`; `lintr::lint_package()` if any
  tracked `.R` file changed.
- **Cannot enforce:** that the images are right, only that the captures completed. CI never runs these scripts (no workflow
  mentions them), so nothing but a person running them will notice a regression here.
- **STOP:** close out; no image is replaced in this session.

### Phase 3a: Pedigree Browser and Diagram, 15 images (14 if Decision 2 deletes the orphan; one session)

- **Do:** re-measure; run both scripts into a scratch folder; view every old/new pair side by side; replace the images that
  are right; add the sentence naming "Same animal, again" to the article's dashed-line paragraph
  (`pedigree-diagram.qmd:50-55`; the manual `_pedigree_browser.Rmd:91-92` already has it); check every caption and number
  the article ties to these images (for example "54 animals total", "962 animals total").
- **DONE looks like:** the 15 (or 14) images match a fresh capture within the toast and install-date noise; the article page
  renders with no broken image link.
- **Verify:** the compare script (Appendix A) reports the same size for each; `quarto render` of both articles; after the
  next push, open the published pages (the script header at `colony-manager-guide-screenshots.R:6-14` records a past
  incident of 33 broken links on the published site that a local render did not show).
- **Can start before Phase 1.** Phase 3a does not touch the crash.

### Phase 3b: Input, Home, Age-Sex Pyramid, Summary Statistics, Genetic Value Analysis, 12 images (one session)

- **Do:** as in 3a. For Genetic Value Analysis, check that the article prose does not name specific animals from the ranking
  tables (the ranking depends on tie order; S821 finding 5). Leave `age_plot.png` if its one differing line is a date or a
  seed. Apply Decision 3 to Home.
- **DONE / Verify / Cannot enforce:** as in 3a. **Can start before Phase 1.**

### Phase 3c: Breeding Groups, Genetic Diversity, Potential Parents, Mate Pair, 10 images (one session; needs Phases 1 and 2)

- **Do:** as in 3a, on the fixed app and the fixed script. Include the new Ancestry sub-tab in
  `breeding_group_first_view.png`. Re-check every Breeding Groups caption against the new results (group counts, "Group 6").
- **DONE / Verify:** as in 3a; plus the Phase 2 run shows 81/81.

### Phase 4a: the three spreadsheet pictures (one session; Decision 4)

- **Do:** first check whether the article can call the same package functions as the export buttons; if so replace the three
  pictures with tables built at render time and update the three captions; if not, retake them by hand with today's file names.
- **DONE:** no picture shows a column or file name the app no longer writes (compare against `R/modSummaryStats.R:837-890`).

### Phase 4b: the nine Marker Genetics pictures (one to two sessions; Decision 5)

- **Do:** view each against the live tab first (this is the "unverified" half of S821 finding 3). Script the four that use
  shipped files. For the other five, add one small data file under `vignettes/articles/data/` (it already holds the article
  data files) and script them too, or record the capture date beside each picture if the owner chooses to leave them.
- **DONE:** each of the nine is either captured by the script and matches the live tab, or carries a recorded date.

## What this plan does not change

No image, no R file, no test and no article text changed to write it. It does not decide the owner decisions about code
that slices 6-8 found (`BACKLOG.md`, docs-audit item, part 2); those stay where they are. It does not re-audit the article
prose (slice 3 did).

## Risks

- **The images keep moving.** The app changed between S821 and today. Run each regeneration phase soon after its
  re-measurement, and run Phases 3a-3c close together if the owner wants the guide consistent.
- **A fix for the crash can hide the next one.** Phase 2's end-of-run summary exists so a quiet failure shows up as a line.
- **Regenerating can expose prose gaps.** The fresh Breeding Groups image shows an Ancestry tab; other fresh images may
  show controls the text does not mention. Each phase checks its captions and notes gaps rather than rewriting prose.

## Appendix A: how the measurements were made (repeat at the start of each phase)

1. Copy a capture script to a scratch folder and change only its `SHOT_DIR <-` line to a scratch folder, so the committed
   images are never overwritten (S821 overwrote and restored them). Run from the repo root:
   `NOT_CRAN=true Rscript <scratch copy>`.
2. Compare each fresh PNG with the committed one with the `png` package. Different size = "differs"; same size = count a
   pixel as different when any channel differs by more than 0.1.
3. To find where two images start to differ, find the first row that differs from the top and from the bottom, then crop
   and stack the old and new rows to look at them.
4. Run the diagram script the same way. All its steps succeeded this session.

## Appendix B: minimal reproduction of the crash

Repo root, `NOT_CRAN=true`, package loadable. Expect the page to stay busy and the disconnected overlay to appear; the
server's stderr shows `Error in [: subscript out of bounds` with the stack in "The tail failure, explained".

```r
suppressMessages(pkgload::load_all(".", quiet = TRUE)); library(shinytest2)
source("tests/testthat/helper-shinytest2.R")
f <- makeExamplePedigreeFile(file.path(tempdir(), "Example_Pedigree.csv"), fileType = "csv")
app <- AppDriver$new(system.file("shinytest", package = "nprcgenekeepr"), height = 900, width = 1300, load_timeout = 30000)
app$wait_for_idle(timeout = 30000)
app$set_inputs(mainNavbar = "Input")
do.call(app$upload_file, setNames(list(f), "dataInput-pedigreeFileOne"))
app$set_inputs(`dataInput-minSireAge` = "2", `dataInput-minDamAge` = "2")
app$click("dataInput-getData"); app$wait_for_idle(timeout = 30000)
app$set_inputs(mainNavbar = "Genetic Value Analysis")
click_element_safe(app, "#geneticValue-runAnalysis")           # returns FALSE at 30 s; normal
stopifnot(wait_for_module_ready(app, "geneticValue", timeout = 300000))
app$set_inputs(mainNavbar = "Breeding Groups"); Sys.sleep(1)
app$set_inputs(`breedingGroups-nGroups` = 1, `breedingGroups-animalSource` = "all",
               `breedingGroups-nIterations` = 5, wait_ = FALSE)
app$click(selector = "#breedingGroups-formGroups"); Sys.sleep(20)
app$get_js("document.querySelector('html').classList.contains('shiny-busy')")            # TRUE
app$get_js("document.getElementById('shiny-disconnected-overlay') !== null")             # TRUE
print(app$get_logs()[app$get_logs()$location == "shiny", "message"])                     # the error and stack
app$stop()
```

## Appendix C: the 50 images

"Written by" gives the line in the capture script that writes the image; "Used in" gives the article line that embeds it.
"Fresh capture" is this session's scratch capture (nothing was written to `shiny_app_use/`).

| Image | Module | Written by | Used in | Committed | Fresh capture (S927) | Result |
|---|---|---|---|---|---|---|
| `age_plot.png` | Age-Sex Pyramid | colony-manager-guide-screenshots.R:351 | colony-manager-guide.qmd:372 | 1270x923 | 1270x923 | same size, 0.24% of pixels differ |
| `breeding_group_1.png` | Breeding Groups | colony-manager-guide-screenshots.R:443 | colony-manager-guide.qmd:484 | 1270x1819 | 1270x1999 | size differs (+180 px tall); **capture unreliable** (taken after the session ended) |
| `breeding_group_6_infants_with_dam.png` | Breeding Groups | colony-manager-guide-screenshots.R:460 | colony-manager-guide.qmd:521 | 1270x2541 | 1270x1953 | size differs (-588 px tall); **capture unreliable** (taken after the session ended) |
| `breeding_group_6_seed_grps_grp_6_kinship.png` | Breeding Groups | colony-manager-guide-screenshots.R:496 | colony-manager-guide.qmd:529 | 1270x2541 | 1270x1953 | size differs (-588 px tall); **capture unreliable** (taken after the session ended) |
| `breeding_group_first_group_no_kinship_seeds_indicated.png` | Breeding Groups | colony-manager-guide-screenshots.R:477 | colony-manager-guide.qmd:527 | 1270x2541 | 1270x1953 | size differs (-588 px tall); **capture unreliable** (taken after the session ended) |
| `breeding_group_first_view.png` | Breeding Groups | colony-manager-guide-screenshots.R:430 | colony-manager-guide.qmd:479 | 1270x1773 | 1270x1953 | size differs (+180 px tall) |
| `breeding_group_sex_ratio_specification.png` | Breeding Groups | colony-manager-guide-screenshots.R:569 | colony-manager-guide.qmd:511 | 1270x3073 | 1270x2036 | size differs (-1037 px tall); **capture unreliable** (taken after the session ended) |
| `diagram_affected_shading.png` | Pedigree Browser (Diagram) | pedigree-diagram-screenshots.R:198 | pedigree-diagram.qmd:202 | 1270x1434 | 1270x1581 | size differs (+147 px tall) |
| `diagram_rectilinear_edge_style.png` | Pedigree Browser (Diagram) | pedigree-diagram-screenshots.R:160 | pedigree-diagram.qmd:67 | 1270x1434 | 1270x1581 | size differs (+147 px tall) |
| `diagram_show_names.png` | Pedigree Browser (Diagram) | pedigree-diagram-screenshots.R:182 | pedigree-diagram.qmd:216 | 1270x1434 | 1270x1581 | size differs (+147 px tall) |
| `diagram_twin_connectors.png` | Pedigree Browser (Diagram) | pedigree-diagram-screenshots.R:229 | pedigree-diagram.qmd:239 | 1270x1434 | 1270x1581 | size differs (+147 px tall) |
| `genetic_diversity_heatmap.png` | Genetic Diversity | colony-manager-guide-screenshots.R:513 | colony-manager-guide.qmd:690 | 1270x546 | 1270x546 | same size, 99.81% of pixels differ; **capture unreliable** (taken after the session ended) |
| `gva_calculating.png` | Genetic Value Analysis | colony-manager-guide-screenshots.R:364 | colony-manager-guide.qmd:404 | 1270x2843 | 1270x3001 | size differs (+158 px tall) |
| `gva_first_high_value.png` | Genetic Value Analysis | colony-manager-guide-screenshots.R:381 | colony-manager-guide.qmd:411 | 1270x2843 | 1270x3001 | size differs (+158 px tall) |
| `gva_high_and_low_value.png` | Genetic Value Analysis | colony-manager-guide-screenshots.R:390 | colony-manager-guide.qmd:425 | 1270x2843 | 1270x3001 | size differs (+158 px tall) |
| `home_tab_landing.png` | Home | colony-manager-guide-screenshots.R:170 | colony-manager-guide.qmd:168 | 1300x900 | 1300x900 | same size, 23.53% of pixels differ |
| `input_example_pedigree_xlsx.png` | Input | colony-manager-guide-screenshots.R:194 | colony-manager-guide.qmd:208 | 1270x3415 | 1270x3472 | size differs (+57 px tall) |
| `input_format_subtab.png` | Input | colony-manager-guide-screenshots.R:177 | colony-manager-guide.qmd:177 | 1270x3415 | 1270x3472 | size differs (+57 px tall) |
| `input_minParentAgeSequence.png` | Input | colony-manager-guide-screenshots.R:207 | colony-manager-guide.qmd:216 | 1270x3415 | 1270x3472 | size differs (+57 px tall) |
| `marker_genetics_candidate_assignment.png` | Marker Genetics | none | colony-manager-guide.qmd:802 | 1270x344 | not captured | no generator |
| `marker_genetics_comparison.png` | Marker Genetics | none | colony-manager-guide.qmd:715 | 1200x800 | not captured | no generator |
| `marker_genetics_cross_center.png` | Marker Genetics | none | colony-manager-guide.qmd:765 | 1200x800 | not captured | no generator |
| `marker_genetics_genomic_roh.png` | Marker Genetics | none | colony-manager-guide.qmd:885 | 1285x713 | not captured | no generator |
| `marker_genetics_heterozygosity.png` | Marker Genetics | none | colony-manager-guide.qmd:727 | 1200x800 | not captured | no generator |
| `marker_genetics_linkage_coverage.png` | Marker Genetics | none | colony-manager-guide.qmd:822 | 1285x713 | not captured | no generator |
| `marker_genetics_linkage_ldblock.png` | Marker Genetics | none | colony-manager-guide.qmd:850 | 1285x713 | not captured | no generator |
| `marker_genetics_mhc_haplotype.png` | Marker Genetics | none | colony-manager-guide.qmd:922 | 770x990 | not captured | no generator |
| `marker_genetics_parentage_exclusion.png` | Marker Genetics | none | colony-manager-guide.qmd:742 | 1200x800 | not captured | no generator |
| `mate_pair_analysis_eligible_pairs.png` | Mate Pair Analysis | colony-manager-guide-screenshots.R:634 | colony-manager-guide.qmd:600 | 1270x687 | 1270x606 | size differs (-81 px tall); **capture unreliable** (taken after the session ended) |
| `mate_pair_analysis_excluded.png` | Mate Pair Analysis | colony-manager-guide-screenshots.R:640 | colony-manager-guide.qmd:620 | 1270x687 | 1270x606 | size differs (-81 px tall); **capture unreliable** (taken after the session ended) |
| `opening_screen_top_red_oval.png` | Input | colony-manager-guide-screenshots.R:183 | colony-manager-guide.qmd:199 | 1270x3415 | 1270x3472 | size differs (+57 px tall) |
| `pb_10_rows_display_unknown_ids.png` | Pedigree Browser | colony-manager-guide-screenshots.R:233 | colony-manager-guide.qmd:262 | 1270x2341 | 1270x2488 | size differs (+147 px tall) |
| `pb_5_focal_animals_small.png` | Pedigree Browser | colony-manager-guide-screenshots.R:277 | colony-manager-guide.qmd:290 | 1270x2679 | 1270x2826 | size differs (+147 px tall) |
| `pb_diagram_legend.png` | Pedigree Browser | pedigree-diagram-screenshots.R:154 | colony-manager-guide.qmd:347, pedigree-diagram.qmd:40 | 1270x1434 | 1270x1581 | size differs (+147 px tall) |
| `pb_focal_animal_text_box.png` | Pedigree Browser | colony-manager-guide-screenshots.R:256 | colony-manager-guide.qmd:283 | 1270x2341 | 1270x2488 | size differs (+147 px tall) |
| `pb_focal_animals_after_clear.png` | Pedigree Browser | colony-manager-guide-screenshots.R:330 | colony-manager-guide.qmd:308 | 1270x2341 | 1270x2488 | size differs (+147 px tall) |
| `pb_focal_animals_before_clear.png` | Pedigree Browser | colony-manager-guide-screenshots.R:323 | colony-manager-guide.qmd:306 | 1270x2611 | 1270x2758 | size differs (+147 px tall) |
| `pb_no_unknown_displayed.png` | Pedigree Browser | colony-manager-guide-screenshots.R:249 | colony-manager-guide.qmd:277 | 1270x2341 | 1270x2488 | size differs (+147 px tall) |
| `pb_select_trim_for_focal_animals.png` | Pedigree Browser | colony-manager-guide-screenshots.R:309 | colony-manager-guide.qmd:299 | 1270x2679 | 1270x2826 | size differs (+147 px tall) |
| `pb_selection_large_focal_group.png` | Pedigree Browser | colony-manager-guide-screenshots.R:301 | colony-manager-guide.qmd:297 | 1270x2341 | 1270x2488 | size differs (+147 px tall) |
| `pb_trimmed_for_focal_animals.png` | Pedigree Browser | colony-manager-guide-screenshots.R:318 | colony-manager-guide.qmd:301 | 1270x2611 | 1270x2758 | size differs (+147 px tall) |
| `pb_unknown_displayed.png` | Pedigree Browser | colony-manager-guide-screenshots.R:242 | none | 1270x2341 | 1270x2488 | size differs (+147 px tall) |
| `potential_parents_results.png` | Potential Parents | colony-manager-guide-screenshots.R:535 | colony-manager-guide.qmd:1053 | 1300x7121 | 1300x900 | size differs (-6221 px tall); **capture unreliable** (taken after the session ended) |
| `read_and_check_pedigree.png` | Input | colony-manager-guide-screenshots.R:221 | colony-manager-guide.qmd:225 | 1270x691 | 1270x691 | identical |
| `ss_export_mean_kinship_coefficient_histogram.png` | Summary Statistics | colony-manager-guide-screenshots.R:406 | colony-manager-guide.qmd:470 | 1270x6256 | 1270x7598 | size differs (+1342 px tall) |
| `ss_female_founders.png` | Summary Statistics | none | colony-manager-guide.qmd:462 | 2594x878 | not captured | no generator |
| `ss_first_order_relationships.png` | Summary Statistics | none | colony-manager-guide.qmd:456 | 544x493 | not captured | no generator |
| `ss_first_view.png` | Summary Statistics | colony-manager-guide-screenshots.R:399 | colony-manager-guide.qmd:436 | 1270x6256 | 1270x7598 | size differs (+1342 px tall) |
| `ss_kinship_matrix.png` | Summary Statistics | none | colony-manager-guide.qmd:451 | 823x252 | not captured | no generator |
| `ss_trimmed_all_plots.png` | Summary Statistics | colony-manager-guide-screenshots.R:402 | colony-manager-guide.qmd:468 | 1270x6256 | 1270x7598 | size differs (+1342 px tall) |
