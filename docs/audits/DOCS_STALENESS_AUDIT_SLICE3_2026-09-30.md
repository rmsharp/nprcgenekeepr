# Docs staleness audit, slice 3: prose claims in the 11 articles (2026-09-30, S822)

Read-only audit. Nothing in the repo was changed except this report and the session records.

## Audit summary

- **Scope:** the 11 `vignettes/articles/*.qmd` articles (about 3,900 lines): prose, code chunks, tables, cross-references.
  Images were slices 1 and 2. The 16 `vignettes/manual_components/*.Rmd`, `a2interactive.Rmd`, the other vignettes, the
  README, `man/`, `NEWS.Rmd`, the in-app guidance pages and the internal docs are **not covered** (slice 4 onward).
- **Criterion:** does each checkable claim (UI label, default, limit, count, function or argument name, described behavior,
  quoted number, link, line citation) still match today's code or output? Read from the implementation, not its docs.
- **Method:** four read-only subagents, one per article group, each reading the article and the code and running cheap
  `Rscript` checks. The session then re-read the cited code for every Moderate finding and for most Minor ones (column
  "Check"). Two agent line numbers were wrong (BG1/BG2) and were corrected here.
- **Coverage:** 11 of 11 articles. About 370 claims checked by the agents (colony guide ~95, diagram + kinship2 ~85,
  QC + GVA + breeding groups ~95, the other four ~95); the great majority were found current. Each agent also listed
  what it could not verify (section "Not verified").
- **Findings:** 0 critical, **7 moderate, 22 minor** (29). No broken code chunk, no renamed or removed function, no
  broken link or anchor, no wrong quoted statistic was found. The staleness is in counts, one-line descriptions of
  behavior, and a few citations.

Check column: **R** = re-read by this session against the code; **A** = agent-run result (executed or counted by the
agent), not reproduced here.

## Findings: Moderate

| ID | Location | Claim | Evidence | Fix | Check |
|---|---|---|---|---|---|
| CG1 | `colony-manager-guide.qmd:134` | "`NAMESPACE` exports 182 functions as of 2026-07-17" | `grep -c '^export(' NAMESPACE` = 233 (agent: `getNamespaceExports()` also 233, all functions) | Change to 233 and re-date, or drop the number (compute it, do not hand-maintain it) | R |
| CG2 | `colony-manager-guide.qmd:411-414` | "Undetermined" animals are "typically imports or very young animals"; the ranking change is at `R/modGeneticValue.R:289-301` | Two errors. (a) `R/orderReport.R:60-91` sends genuine imports (recorded origin) to the `imports` tier, which ranks normally; only both-parents-unknown animals with **no** recorded origin become "Undetermined". (b) Lines 289-301 are no longer the demotion; it is at `R/modGeneticValue.R:375-385` | Define Undetermined as "both parents unknown and no recorded origin"; cite the function, not line numbers | R |
| CG3 | `colony-manager-guide.qmd:676` | Production = "whether age-appropriate breeding females are present for the selected Housing type" | `R/getProductionStatus.R:6-30`: Production is a ratio (births in the two calendar years ending last year that lived 30+ days, per female aged 3+), scored red/yellow/green against cut-offs that depend on Housing type | Describe it as births per breeding-age female over two years, thresholds by Housing type | R (header) / A (thresholds) |
| CG4 | `colony-manager-guide.qmd:27, 52, 143, 1091` | "six feature-depth articles" / "Six shorter feature articles" / "the six feature articles in @tbl-function-groups" | The guide links 7 feature articles (age-sex-pyramid, breeding-group-formation, fg-se-validation, genetic-value-analysis, offline-focal-animal-workflow, pedigree-diagram, studbook-quality-control) plus the engineering article; `kinship2-fidelity-validation` is not linked from the guide at all | Say "seven" (or "eight" and add the kinship2 article to the table); compute, don't hand-count | R (links counted) |
| GV1 | `genetic-value-analysis.qmd:138` | Ranking tier 1 is "imported founders with no offspring" | `R/orderReport.R:76`: `i <- !is.na(origin) & bothUnknown`, no offspring condition; tier is ordered by age. The `orderReport` roxygen (`R/orderReport.R:34`, "imported animals with no offspring") has the same wrong wording | "imported animals (both parents unknown, recorded origin), youngest first"; fix the roxygen too | R |
| BG1 | `breeding-group-formation.qmd:176` | `minAge` = "minimum age (years) to be placed" | `R/groupAddAssign.R` roxygen and `R/filterAge.R:26`: a kinship conflict is dropped when either animal is younger than `minAge`; younger animals are still placed. Also the minimum harem-sire age (`R/getPotentialSires.R:23`, agent) | "animals younger than this are exempt from kinship conflicts; also the minimum age of a harem sire" | R |
| BG2 | `breeding-group-formation.qmd:112, 175` | Groups never contain two animals whose kinship "exceeds `threshold`"; `threshold` = "maximum within-group kinship" | `R/groupAddAssign.R:175` defaults `ignore = list(c("F","F"))`, so female-female pairs are not checked at all; `R/filterThreshold.R:29` keeps `kinship >= threshold`, so a pair exactly at the threshold conflicts; `ignore` is not in the arguments table | Say female-female kinship is ignored by default, "reaches or exceeds", and add `ignore` to the table | R |

## Findings: Minor

| ID | Location | Claim | Evidence / fix | Check |
|---|---|---|---|---|
| CG5 | `colony-manager-guide.qmd:454-457` | Founders CSV has 14 listed columns | Actual 16: also `fromCenter` and `placeholder` (between `recordStatus` and `population`). Add them | A |
| CG6 | `colony-manager-guide.qmd:873-875` | ROH thresholds "pre-filled with PLINK's own defaults" | `R/modMarkerGenetics.R:279,285` pre-fill 50 SNPs and 1,000,000 bp; `R/computeGenomicROH.R:53` says 50 is scaled down from PLINK's 100. Only the bp value is PLINK's | R (values) |
| CG7 | `colony-manager-guide.qmd:254` | table pages "10, 25, 50, or 100 rows" | `R/modPedigree.R:410` `pageLength = 15L`; no `lengthMenu` set, so the menu is DataTables' default and 15 is the default page. State the default or drop the list | R (code) / menu not seen in a browser |
| CG8 | `colony-manager-guide.qmd:1058-1059` | "the tab ships a worked example" | `R/modSnapshotTrends.R` has no example loader; the file is `inst/extdata/examples/example_snapshot_history.csv` (exists). Say the package ships it | R (file) |
| CG9 | `colony-manager-guide.qmd:37, 62, 148` | "current as of 2026-07-17"; "walks every tab" | Stamp is 75 days old; the ONPRC-only ORIP Reporting tab (`R/appUI.R:213-221`) is neither walked nor excluded. Re-stamp after CG1-CG3; add one sentence on ORIP | A |
| PD1 | `pedigree-diagram.qmd:41-42` | Focal Animals panel is "to the left of the diagram" | `R/modPedigree.R:53` puts it in the top `fluidRow`; the tabset is a later row (`:179-183`), so the panel is above | R |
| PD2 | `pedigree-diagram.qmd:211` | Select-by-id dropdown "below" | The article says "above the diagram" at line 259; self-contradiction | R |
| PD3 | `pedigree-diagram.qmd:82-84` | Consanguinity marker uses the twin file "for correctness parity" under both edge styles | `twinRelations` reaches `makePedigreeMatingLayout()` only while "Show Twin Connectors" is on, so the marker's twin correction follows that toggle (`R/modPedigree.R` ~655-664, agent) | A |
| PD4 | `pedigree-diagram.qmd:34` | "Every animal is one node" | The app suppresses fully isolated animals and shows a banner (`R/modPedigree.R` ~575-596, agent); add one sentence | A |
| PD5 | `pedigree-diagram.qmd:259-261` | Select-by-id dims everything but "its direct connections" | `R/modPedigree.R:821` uses `degree = 6L` for rectilinear (the default), 1 only for direct, because waypoint nodes sit between visible ones | R |
| KF1 | `kinship2-fidelity-validation.qmd:16-19` | Supplement example is "10-subject" | The article's own line 314 and `docs/audits/KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md` say 17-subject `fam1`, with a 10-subject reproducible subset | A |
| KF2 | `kinship2-fidelity-validation.qmd:25` | "`chrtype = c("autosome", "x")`" | `R/kinship.R:105` signature is `chrtype = "autosome"`; `"x"` is the other accepted value. Write `chrtype = "autosome"` (or `"x"`) | R |
| KF3 | `kinship2-fidelity-validation.qmd:249-252` | The packages duplicate "`Y` in kinship2's rendering, `A` in nprcgenekeepr's" for the same union | Agent ran the Track C fixture: nprcgenekeepr duplicates `A` (A-X union) and `Y` twice (A-Y, Y-W). So it is not "A instead of Y" for the A-Y union. Reword to "do not duplicate the same set of nodes" | A |
| KF4 | `kinship2-fidelity-validation.qmd:202-203` | Track 4 comment and test at `test_makePedigreeMatingLayout.R:1297-1368` | Those lines are the consanguineous-direct-marker tests; the "Track 4" comment is at 1420-1433 and its test at 1434-1482. Cite those or drop line numbers | R |
| SQ1 | `studbook-quality-control.qmd:26-27` | "animal IDs must be alphanumeric" | `R/hasInvalidIdChar.R` rejects only a period; agent ran `a-1`, `b_2`, `c 3`, all accepted. Say "must not contain a period" (line 166 already does). The `qcStudbook` roxygen has the same overstatement | R (code) / A (run) |
| SQ2 | `studbook-quality-control.qmd:235-236` | the app's "Quality Control tab" | `R/appUI.R:170-173`: the tab is "Input" (heading "Data Input and Quality Control"; sub-tab "QC Summary") | A |
| GV2 | `genetic-value-analysis.qmd:139-141` | ties in uniqueness broken by mean kinship | `R/orderReport.R` orders on `trunc(gu)`, so ties are on whole percent. Cosmetic | A |
| GV3 | `genetic-value-analysis.qmd:130-150` | Four-tier list | Omits the last tier: both parents unknown, no recorded origin, placed last as "Undetermined" with `rank = NA` (`R/rankSubjects.R`); conflicts with "1 = most valuable". Add a sentence | A |
| GV4 | `genetic-value-analysis.qmd:106` | "The rest summarize founder diversity" | The list also holds `neGD`, `neSexRatio`, `neVariance`, which are effective sizes of current breeders. Omission, not false | A |
| EN1 | `engineering-the-2.0.0-release.qmd:637, 756-757` | protocol "maintains" 27 failure modes (present tense) | `SESSION_RUNNER.md:339` has row 28. Anchor to the freeze ("27 at the 2.0.0 freeze; 28 today") or say 28 | R |
| EN2 | `engineering-the-2.0.0-release.qmd:164-166` | diagram: "composes 10 modXXXUI() calls", "10 R/mod*.R modules" | Today 15 `R/mod*.R` files and 15 `mod*UI(` references in `R/appUI.R` (counted). The caption dates only the port; add "(at 2.0.0)" to the labels | R |
| AS1 | `age-sex-pyramid.qmd:105-106` | with `ageUnit = "months"` "the title switch[es] to months" | `R/getPyramidPlot.R:95-110`: `main` is always "Total on date: N"; the unit appears in the "Age (mo)" side label. Say "age-axis label" | R |

## Structural observations

1. **Hand-maintained counts are the dominant failure (CG1, CG4, CG5, CG9, EN1, EN2).** Every count in the Moderate and
   Minor lists that went stale was typed by hand (exports, feature articles, CSV columns, modules, failure modes).
   Counts that were *computed or dated* held. Same lesson as `CLAUDE.md`'s "replace any hand-maintained count with the
   command that produces it". A repo-level guard is feasible for the cheapest ones: a test that compares the exported
   count quoted in the guide with `NAMESPACE` (CG1) and the module count in the engineering diagram (EN2). Judgment
   findings (everything else) stay findings.
2. **One-sentence descriptions of a rule drift from the rule (CG2, CG3, GV1, BG1, BG2, SQ1).** Each article sentence
   compresses a rule that has details (origin tier, thresholds, `ignore`, "alphanumeric"). Three of the six (GV1, SQ1,
   and the "Undetermined" wording) copy a wrong roxygen sentence, so the roxygen is the root and the article the
   copy: fix `R/orderReport.R:34` and the `qcStudbook` roxygen with the articles.
3. **Line-number citations rot (CG2, KF4, and the agent's own BG1/BG2 mis-citations).** Both stale citations point into
   files that have since gained lines. Cite the function or test name instead.
4. **What held up well:** control labels and defaults across the whole colony guide (about 60 labels), all
   quoted statistics in `fg-se-validation` (every number matches `data-raw/fgSEValidation-results.rds`), the QC
   diagnostic outputs (reproduced exactly), the kinship2 Track A/B/C numbers (re-run live), and all links and anchors.
   The articles last edited in July are no worse than the ones edited in late September.

## Comparison with prior slices

| Metric | Slice 1 | Slice 2 | Slice 3 |
|---|---|---|---|
| Surface | 2 PDFs + 8 kinship2 images + prose spot-check | 50 screenshots | prose of 11 articles |
| Moderate | (not tallied this way) | 2 | 7 |
| Minor | | 3 | 22 |
| Pattern | local renders old; 1 image stale | UI help text change moved 15 images | hand-written counts and rule summaries |

## Not verified (listed by the agents; none checked by this session)

- All commit shas, issue numbers, S-numbers and the Actions run URL in the engineering article; Codecov figures.
- Prose that describes image content ("6-animal pedigree", which node kinship2 duplicates), and whether the Export
  Diagram button sits "in the diagram's own corner" (needs a rendered app).
- That the layout engine still gives "6 of 237" off-centre unions on the 375-animal fixture (census CSV is dated 2026-09-18).
- Colony guide: literature statements (Manichaikul 2010, Hill & Weir 2011), "first disclaimer this app has had",
  Cross-Center validation issue types, Ancestry Guardrails manifest columns, whether a node click narrows the table.
- `fg-se-validation.qmd:60-61` "FG = 2.18" for Lacy's paper (recorded reference at K=20000 is 2.1866); the
  `geneDrop()` independence claim at `:148-149`.
- Side notes from the agents, outside the articles: `data-raw/fgSEValidation.R:11` says "~11 min" against the article's
  "~7 min" (recorded elapsed time supports 7); the roxygen for `makePedigreeMatingLayout` at
  `R/makePedigreeDiagramData.R:1661-1665` says a marked mate edge replaced by a dogleg "falls back to the generic color
  (a deferred follow-up)". The agent says it was implemented, but the comment at `:2334-2339` is ambiguous
  ("narrowed to direct style only"), so this is **not** reported as a finding; it needs its own look.
- Agents were told to ignore images; their reports were not given the rendered `.html`.

## Recommendations

1. Fix the 7 Moderate items in one docs-only session (CG1-CG4, GV1, BG1, BG2); roxygen for GV1 and SQ1 in the same pass
   (roxygen edit means `devtools::document()` and the Rd diff). Strict-TDD does not apply to prose, but
   `test_pkgdown_reference_config.R`, the news guard and the article render are the verification.
2. Replace the cheap hand-typed counts with computed ones (inline R in the `.qmd`) or add a count-guard test
   (CG1, EN2). Judge per count whether a guard is worth it.
3. Fix the 22 Minor items alongside, grouped by article so each article is touched once.
4. Slice 4: the 16 manual components, `a2interactive.Rmd`, README, `man/`, `NEWS.Rmd`, `inst/extdata/ui_guidance/`; then
   the internal docs. Slice 1's open items (PDFs, `trackC` image, `_pedigree_browser.Rmd:62-65`, `R/modPedigree.R:440-443`)
   and slice 2's capture-script failure remain open and are unchanged by this slice.
