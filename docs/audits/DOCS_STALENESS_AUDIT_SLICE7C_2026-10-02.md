# Docs staleness audit, slice 7c: the live plans in `docs/planning/` (2026-10-02, S860)

Read-only audit. Nothing in the repo was changed except this report and the session records.

## Audit summary

- **Scope (owner-chosen, S860):** only the planning files that are *live*, meaning an open GitHub issue or an open
  `BACKLOG.md`/`ROADMAP.md` item still points at them, plus a status-header sweep of all 84 files. **Not covered:**
  the finished plans' bodies, `docs/research/` (5) and the older `docs/audits/` reports (dated records; a later slice
  only if the owner wants it).
- **Live set (11 docs):** `issue123-xarch5-column-schema-plan.md` (#123 open), `issue112-genetic-diversity-dashboard-plan.md`
  (#116 open), `issue167-longitudinal-monitoring-plan.md` (BACKLOG Slice 5), `issue144-anchor-row-mismatch-fix-plan.md`
  (BACKLOG Candidate C), `nprc-outreach-announcement-plan.md`, `cran-2.0.0-phase5-runbook.md` (release prep),
  `quarto-documentation-future-proofing-analysis.md` (ROADMAP), `issue122-module-contract-plan.md` (header says not
  implemented), `pedigree-diagram-kinship2-reference-comparison.qmd` (BACKLOG "refresh").
- **Criterion:** does each checkable claim (path, line, count, name, default, status word, issue state, version, commit
  hash) still match today's repo? Is the doc's status header true?
- **Method:** four read-only subagents (123+112; 167+144; outreach+runbook+Quarto; 122+reference qmd). This session then
  re-ran the evidence for 18 of the moderates (column "Check": **S** = re-checked here; **A** = agent only). The status
  sweep was run here with `gh issue view` and `ls`/`grep` against the tree.
- **Findings:** 0 critical, **53 moderate**, and about 40 minor (in the tables). Nothing was found wrong in the *code*.
- **One finding explains most of it.** These plans were written as design records and **were never re-labelled when the
  work shipped**. Of the 38 `issue*` plans, **37 have a CLOSED issue** (only #123 is open), yet at least 14 headers
  still read DRAFT / "pending owner ratification" / "PLAN (not implemented)" / "Pre-RED" / "ready for Slice-1 RED".
  A reader who trusts the header is misled; a reader who trusts the body gets stale line numbers, counts and numbers.

## Status-header sweep (all 84 files)

| Group | Count | State |
|---|---|---|
| `issue*` plans | 38 | 37 issues CLOSED, 1 open (#123, closed only partly by design). 14+ headers still say DRAFT / not implemented / Pre-RED / ready for RED (`issue112`, `118`, `122`, `123`, `13`, `133`, `136`, `143`, `144`, `148`, `150`, `153`, `2`, `73`) |
| 11 files with no status line at all | 11 | `issue119`, `125`-`130`, `152`, `167`, `168`, `30`, `76`, `9` |
| Non-issue plans whose header says unfinished but whose work shipped | 8+ | `shiny-module-conversion-plan` ("Not yet executed"; the modular app, 20 `app*`/`mod*` files, is the app), `document2-colony-manager-guide-plan` (`colony-manager-guide.qmd` exists), `extdata-reorganization-plan` (`inst/extdata` now holds only `examples/ reference/ ui_guidance/`; scratch is in `dev/extdata-scratch/`), `pedigree-diagram-same-row-collision-avoidance-plan` (`.resolveEdgeNodeCollisions()` exists), `pedigree-diagram-sibling-subtree-width-plan` and `-walker-bjl-apportioning-redesign-plan` (`R/positionTreeApportion.R` exists; whether every phase shipped was **not checked**), `-kinship2-fidelity-remediation-plan`, `-kinship2-structural-comparison-plan`, `-duplicate-individual-proximity-plan` (DRAFT/pending ratification headers) |
| Live because the work is open | 4 | `issue123` (residuals), `issue167` (Slice 5), `nprc-outreach`, `cran-2.0.0-phase5-runbook` |

The sweep checks that the artifact exists, not that every phase is done. "Closed issue" is not proof of "shipped" for a
plan whose issue was closed `wontfix`; the deep checks below did verify shipping for the 9 live docs.

## Findings, live docs

Ids XA-XI, one letter per doc. Moderate = would make a reader act on, or believe, something false; minor = line drift,
count drift, wording.

### XA: `issue123-xarch5-column-schema-plan.md` (PARTLY SHIPPED: Phase 1 shipped S386 `8a5465d88`; #123 OPEN on purpose)

| id | sev | where | says | true today | Check |
|---|---|---|---|---|---|
| XA1 | mod | :3,:11-12,:20 | "PLAN (not implemented)" | `R/columnSchema.R`, `R/assertRequiredColsPresent.R` exist; validator wired in `reportGV.R:284`, `qcStudbook.R:373`, `gvaConvergence.R:176` | A |
| XA2 | mod | §2.1 :51-59 | getters hold hardcoded vectors | they return `.nprcColumnSchema$required/$possible/$include` (`getRequiredCols.R:24`, `getPossibleCols.R:83`, `getIncludeColumns.R:20`) | A |
| XA3 | mod | :52,:263-269,:468 | `getPossibleCols()` has 24 elements | **26** (`affected` #133, `name` #136 added) | S |
| XA4 | mod | :164-172,:529-531 | print-method wrinkle at `reportGV.R:303` | still true, now `reportGV.R:353`; no `print.nprcgenekeeprGV.R` | S (file absent) |
| XA5 | mod | §3,§2.2,§4.2,§8.1 | unguarded `intersect` at `reportGV.R:211/218`, `qcStudbook.R:316`, `gvaConvergence.R:161` | now `reportGV.R:251` (guard :284), `qcStudbook.R:374` (guard :373), `gvaConvergence.R:178` (guard :176); a 4th caller `reportMatePairs.R:175` | A |
| XA6 | mod | §10 item 2, Dragon 3 | roxygen calls `birth` "(optional)" | already fixed (`getPossibleCols.R:22-23`) | A |
| XA7 | mod | §10 item 1 | `correctUnknownParentMeanKinship.R:141` inlines the column literal | now `getRequiredCols()` | A |
| XA8 | mod | §8.3 | new tests "required" | exist (`test_assertRequiredColsPresent.R`, `test_reportGV.R:821`) | A |
| XA9-12 | min | various | 9 vs 12 duplicate count; `deparse(` 32 hits/15 files; test line refs; HEAD `b534e08d` | 42 hits/16 files; many line refs drifted; hash valid but historical | A |

BACKLOG gap: #123's closing comment says residuals are tracked in `BACKLOG.md`, but `BACKLOG.md` mentions #123 only at
line 28 (the NEW-24 note). XA4 and §10 item 5 are **untracked**.

### XB: `issue112-genetic-diversity-dashboard-plan.md` (S1-S4 shipped; S5 = open #116, blocked)

| id | sev | where | says | true today | Check |
|---|---|---|---|---|---|
| XB1 | mod | :4-5,:21 | "DRAFT plan, no code written" | S1-S4 shipped (`5667f9c8c`, `2b11f1125`, `cb7eb1a6a`, `7d4104680`); #112 CLOSED | A |
| XB2 | mod | :16,:47-57,:176-183 | dead `R/makeGeneticDiversityDashboard.R`, its test, `.Rbuildignore:21` entry exist | deleted; `.Rbuildignore` has no such line; `getGeneticDiversityStats()` calls all 4 providers | S |
| XB3 | mod | :14-21,:64,:74-78,:96 | "1 column has no provider"; `appServer.R:315` discards the groups return; `shared` has no groups field | `getKinshipWithMaleStatus.R` exists; `shared$breedingGroups` at `appServer.R:53,435` | A |
| XB4 | mod | D3, §7 | `getGeneticDiversityStats(ped, groups, geneticValues, housing, ...)` marked [RATIFY] | shipped `getGeneticDiversityStats(groups, ped, geneticValues, kmat, housing = "shelter_pens", currentDate)` | A |
| XB5 | mod | :39,:57,D7,Q1 | `getProductionStatus(ped, minParentAge = 3L ...)`; roxygen "Defaults to 2 years" | now `minDamAge = 3L`, `minParentAge` deprecated; roxygen fixed | S |
| XB6 | mod | §6 Q2 | "how does the app learn a group's housing type?" open | answered: a housing selector (`modGeneticDiversity.R:31,103`) | A |
| XB7 | mod | :147 | verification filter `!grepl("test-app-\|test-e2e-", file)` | `CLAUDE.md` says this filter was removed S624 and must not return; a copying executor would hide failures | A |
| XB8-13 | min | various | "version 2.0.0"; `DESCRIPTION:45`; `inst/extdata/meeting_notes.qmd:NNN` cites; #109 "recent"; line refs | `2.0.0.9000`; `:48`; file moved to `dev/extdata-scratch/` (so every cited line is unverifiable at that path); #109 closed; drifted | A |

### XC: `issue167-longitudinal-monitoring-plan.md` (Slices 1-4 shipped, #167 CLOSED 2026-09-22; Slice 5 open and unratified)

| id | sev | where | says | true today | Check |
|---|---|---|---|---|---|
| XC1 | mod | :6-12,:517-521 | gated on ratification; "#167 stays intentionally open" | Slices 1-4 shipped; #167 CLOSED | S |
| XC2 | mod | :249,:349-351 | `modSnapshotTrendsServer(id, pedigree, geneticValues, ...)` | `modSnapshotTrendsServer(id, snapshotSource)` (`R/modSnapshotTrends.R:142`) | S |
| XC3 | mod | :245 vs :254-263 | `createColonySnapshot(ped, geneticValue, membershipRule, snapshotDate)` | requires `guIter` and `guThresh` (`createColonySnapshot.R:56-58`); the prose note at :254 is right, the table row is not | A |
| XC4 | mod | `BACKLOG.md:224` (points here) | "§7 Dragon 1 for the full caveat inventory" of Slice 5 | §7 Dragon 1 is the no-seed-in-`reportGV()` point; the retrospective caveats are D5 (:176-186) and Slice 5 (:365-370). **The BACKLOG pointer is wrong, not the plan.** | S |
| XC5-8 | min | :76,:73,:46,... | "15 top-level tabs"; assorted `file:line` | 16 tabs now; lines drifted (`modORIPReporting.R:110`, `reportGV.R:152`, ...) | A |

### XD: `issue144-anchor-row-mismatch-fix-plan.md` (FULLY SHIPPED then SUPERSEDED: Candidate B shipped S474, deleted S573 for Candidate A)

| id | sev | where | says | true today | Check |
|---|---|---|---|---|---|
| XD1 | mod | :15 | "DRAFT, pending owner ratification" | ratified, shipped S474 (`31ce78f4f`); #144 CLOSED | A |
| XD2 | mod | :165-255,:403,:508-515 | adopts Candidate B (`effGenOf`); Candidate A "not adopted" | A was ratified S572 and shipped S573; `grep -rn effGenOf R/` finds nothing | S |
| XD3 | mod | :53-155,:302-332 | mechanism = `used`/elimination branch + `isFounderOf`; line anchors | removed; `.buildMatingUnitForest` :405, `.positionMatingUnitForest` :843 | A |
| XD4 | mod | :43-48,:75,:265,:480 | 51 of 237 anchor mismatches, 740 nodes, 128 duplicates, rectilinear 1228 | 237 units, 170 duplicates, 0 mismatches, 782 nodes (measured by the agent; rectilinear 1202 from a test pin, not re-run) | A |
| XD5 | mod | :344-355,:465-470 | tests hardcode 51/1279/1228; residual shape needs 2 tests | values moved; residual closed by construction under Track 4 | A |
| XD6 | mod | :6-24,:409-436 | the residual multi-unit shape is open | closed structurally (`matingUnits$gen == genOf[[anchor]]`) | A |
| XD7 | mod | :523-543 | dangling-parent crashes to be filed as new BACKLOG items | filed and closed as #154 | S (#154 CLOSED) |
| XD8-10 | min | :544-554,:571,:403-405 | reference-qmd staleness never filed; hash; Candidate C | refreshed S484; hash valid; Candidate C still current in `BACKLOG.md:454-470`, the plan lacks a "superseded" banner | A |

### XE: `nprc-outreach-announcement-plan.md` (LIVE: correspondence unsent, BACKLOG item DECISION NEEDED)

| id | sev | where | says | true today | Check |
|---|---|---|---|---|---|
| XE1 | mod | :1,15,28,408,454, Appendix A/A2 | pitches "2.0.0", "reached a major release" | next release is 3.0.0 (`BACKLOG.md:93`); `DESCRIPTION` 2.0.0.9000; email text and the Appendix B feature table need a refresh before any send | A |
| XE2 | mod | :158-331,:354-370 | contact roster "as of 2026-07-28" | about 66 days old; roles fluid; **NOT CHECKED** (external research); the plan's own §8.2 says re-verify before sending | none |
| XE3-6 | min | :3,:398,:29,:30-38,:36-37 | unchecked close-out box; CRAN date; article URLs; CHANGELOG session cites | box cosmetic; CRAN 2.0.0 published 2026-07-26 and both articles return 200 (confirmed); the session-number cites `342-343, 398, 404-408` matched 0 in `CHANGELOG.md`, **NOT CHECKED** (ledger format differs) | A |

### XF: `cran-2.0.0-phase5-runbook.md` (PARTLY SHIPPED: 2.0.0 accepted 2026-07-26; sections 1-4 reusable for 3.0.0)

| id | sev | where | says | true today | Check |
|---|---|---|---|---|---|
| XF1 | mod | :1,157,201,205 | build and confirm `nprcgenekeepr_2.0.0.tar.gz` | next release is 3.0.0; the tarball name will differ | A |
| XF2 | mod | :164,246-259 | R-hub checks master "(2.0.0, in sync w/ origin)"; "`DESCRIPTION` is `2.0.0`" | `DESCRIPTION` is `2.0.0.9000`; master is **4 commits ahead** of origin; the "verified S242" sync claim is a snapshot to re-run | S (`git status -sb`) |
| XF3 | mod | :137-138,152,178-180 | `devtools`/`rhub`/`gitcreds` "now installed in the renv library" | `requireNamespace("rhub")` is FALSE here (`gitcreds` TRUE); a releaser hits a missing package | S |
| XF4 | mod | :3,270-281 | companion `cran-comments.md` has "-- to be run before submission" markers | `grep` finds none; the file is the finished 2.0.0 resubmission text and needs a 3.0.0 rewrite (no longer a resubmission of an archived package) | S |
| XF5 | mod | :308-312 | Phase 6 (tag, `use_github_release()`, `use_dev_version()`) is a future step | done for 2.0.0 (`v2.0.0` released 2026-07-28); reads as pending, reusable as a 3.0.0 checklist | A |
| XF6-8 | min | :1-131,:244,:65-71 | 130 lines of S135-S391 history, "next action is `submit_cran()`"; `rhub.yaml` exists; Windows CI red / `WriteXLS` flake | history only; `rhub.yaml` confirmed; no `WriteXLS` use remains in `R/`, latest master runs green | A |

### XG: `issue122-module-contract-plan.md` (FULLY SHIPPED S373-S377, #122 CLOSED 2026-07-14)

| id | sev | where | says | true today | Check |
|---|---|---|---|---|---|
| XG1 | mod | :3,:10-11 | "PLAN (not implemented)" | all 5 phases shipped; no superseded banner | S |
| XG2 | mod | :24,§2.1 | `makeGeneticSummaryTable(reportGV()$report)` gives an all-N/A table | fixed: `normalizeGvReport()` called at `makeGeneticSummaryTable.R:38` | S |
| XG3 | mod | :70-80 | rename closure at `modGeneticValue.R:470-482` | deleted; returns `geneticValues = reactive(gvResults())` (:546) | A |
| XG4 | mod | :96-116 | `modBreedingGroups` dead kinship-reuse branch, no `kinshipMatrix` param | `kinshipMatrix` param at `modBreedingGroups.R:260`; `appServer.R:345-364,378,426` | A |
| XG5 | mod | :171-191 | `shared$config` threaded into `modInput`/`modPedigree`, discarded | config params removed; `shared$config <- loadSiteConfig()` survives at `appServer.R:69` | A |
| XG6 | mod | :155-156,:419 | `shared$qcResults` dead write at `appServer.R:146` | gone | A |
| XG7 | mod | :150-153,:425-428 | six blanket `tryCatch(..., NULL)` in `appServer.R` | `tryCatch` at :135, :236, :395 only | A |
| XG8 | mod | :128-147,§2.4 | 47 declared vs 14 consumed reactives; `modSummaryStats` returns 12 unread | unread ones were **kept** (tests read them, `module-contract.md:34-40`); now 15 elements | A |
| XG9 | mod | :287-294,:450-453 | `modInput` not the reference; dead `config` param | made the reference implementation S377; `config` gone | A |
| XG10 | mod | :437-441,:543 | "v2.0.0 mid-resubmission" framing | **NOT CHECKED** here; 3 months old (CRAN accepted 2.0.0 on 2026-07-26 per XE4) | none |
| XG11-13 | min | many | line refs; Dragon 4 wrap `gestationTable` in `reactive()`; ~40 `deparse()` tests | refs drifted; kept as a lazy promise by owner decision (`module-contract.md:63-72`); 39 hits in 13 files | A |

### XH: `pedigree-diagram-kinship2-reference-comparison.qmd` (PARTLY SHIPPED; a point-in-time record whose "current" claims are false)

| id | sev | where | says | true today | Check |
|---|---|---|---|---|---|
| XH1 | mod | :3 | subtitle: #145 "open" | CLOSED 2026-08-10 (also #133, #136, #137, #141-#144, #154) | S |
| XH2 | mod | :253-256,:481-483 | nprc draws zero duplicate nodes for family 1; individual 113 "never silently dropped" | agent run: 99 nodes, 97 edges, 4 duplicates, and 113 is now *suppressed* as an isolate | A |
| XH3 | mod | :209-215,:481 | kinship2 duplicates 103 and 138 in family 1 | with kinship2 1.9.6.2, 110, 115 and 118 are drawn twice | A |
| XH4 | mod | :498-500 | rectilinear is an alternative to the "still-default" direct style | default is `edgeStyle = c("rectilinear","direct")` (rectilinear) | S |
| XH5 | mod | :303-311,:484-486 | no affected-status encoding; twin/zygosity unsupported (#133/#137 "tracked") | both shipped and closed; `twinRelations` is a layout argument | A |
| XH6 | mod | :466-471,:509-520 | neither package has a male-left rule; #145 work should "treat male-left as a default worth choosing" | shipped (S500, S857/S859; `makePedigreeDiagramData.R:1267` `qualifies(u)`) | A |
| XH7 | mod | :106-133 | render helper "matches `modPedigree.R`'s exact current chain" | `modPedigree.R:682` now passes `edgeStyle`, `twinRelations`; the helper is a subset | A |
| XH8 | mod | whole file; `BACKLOG.md:445` | BACKLOG "refresh of `...reference-comparison.qmd`" | that sentence is history (done S484, `dcc53b343`), not an open item; the real staleness is XH1-XH7 | A |
| XH9-11 | min | :35-36,:67-69,:187 | "refreshed once 2026-08-13"; kinship2 absent from DESCRIPTION/renv.lock; cited #143/#144 | the refresh was S484; kinship2 is in both; issues closed consistently | A |

The agent verified the doc's structural numbers that still hold (family 1 = 41 people, family 2 = 14; Example 3 and the
crowding example each give 1 duplicate). The figures were not rendered.

### XI: `quarto-documentation-future-proofing-analysis.md` (PARTLY SHIPPED: Hybrid decision is live policy, referenced from `ROADMAP.md:20`)

| id | sev | where | says | true today | Check |
|---|---|---|---|---|---|
| XI1 | mod | :43-51,153-155,231 | "four CRAN vignettes" incl. `ColonyManagerTutorial.Rmd` | the tutorial is `vignettes/_ColonyManagerTutorial.Rmd`, build-ignored (`.Rbuildignore:30`); `gvaConvergence.Rmd` is a CRAN vignette the table omits; the count of four still holds | S |
| XI2 | mod | :28-29,51,175,228-229 | dev docs live in `inst/extdata/` (`claude_code.qmd`, `software_design_doc.qmd`, `meeting_notes.Rmd`) | they live in `dev/extdata-scratch/` | S |
| XI3 | mod | :229-230 | slice 2 "first article ... a fourth article"; slice 3 "no existing decks" | 10 `.qmd` articles; slice 3 status "not recorded" in `ROADMAP.md:33-34`; no deck found by a cheap grep only | A |
| XI4-8 | min | :153,:75-77,:228-229,:54-55,:3-8 | 13 `child=` chunks/13 files; `rmarkdown` 2.31, `knitr` 1.51; `Config/Needs/website: quarto`; stale renders; "no documents converted" | 14 chunks/15 files; CRAN now 2.32/1.52 (lock pins 2.31/1.51); still true (`DESCRIPTION:87`); partly true; slice 1 done (`meeting_notes.qmd` exists), slice 4 (manual leaves CRAN) not done | A |

NOT CHECKED in XI: the third-party quotes and URLs in §2-§4 and §9 (nothing was sent externally).

## Findings that are not doc fixes

**Code candidates (owner decisions; reword the docs if the code changes):**
1. `getProductionStatus.R:99-111`: `is.na(production) || production > ...` maps "0 dams -> NA" to **green**. The #112 plan (§3.2, §8 risk 2) flagged this as a trap and S2's `getKinshipWithMaleStatus` returns an `NA` colour index (grey) for the same case. Whether the owner ratified green was not checked.
2. `reportGV.R:353` appends the class last and no `print.nprcgenekeeprGV` exists; `getGeneticDiversityStats.R:58` keeps its own `requiredPed` vector. Both were out of the #123 plan's scope, low priority.

**Tracking gaps in `BACKLOG.md`:**
- `BACKLOG.md:224` cites "§7 Dragon 1" for the Slice 5 caveats; the right place is D5 / §5 Slice 5 (XC4).
- `BACKLOG.md:445` lists the reference-qmd refresh in a sentence that reads as pending; it was done S484 (XH8).
- #123's residuals (XA4 print-method wrinkle, §10 item 5) are not in `BACKLOG.md` although the issue comment says they are.

## Recommended fixes (a later session, one cluster at a time)

1. **Banners, not rewrites.** These are dated design records. Add one top banner each to the shipped or superseded plans
   (`issue112` S1-S4 shipped, `issue122` fully shipped, `issue144` superseded by Track 4, `issue167` Slices 1-4 shipped,
   `issue123` Phase 1 shipped, the reference `.qmd` "historical; its 'current' claims predate #133-#145"). That clears
   XA1, XB1, XC1, XD1/XD2/XD6, XG1 and XH1 together without touching the bodies.
2. **Fix the live ones in place:** `cran-2.0.0-phase5-runbook.md` (version strings, the `rhub` install step, the
   `cran-comments.md` description, a "Phase 6 done for 2.0.0" note), the outreach plan (version and feature table; re-verify
   the roster before any send), and `quarto-documentation-future-proofing-analysis.md` (inventory and paths).
3. **Header sweep:** give the 11 status-less plans and the 14+ stale-header plans a one-line status; add a
   `docs/planning/README` stating that a header may lag and `CHANGELOG.md` is the authority.
4. Fix the three `BACKLOG.md` items above.

## Not done (stated, not hidden)

The agents' unchecked items are listed per doc. Not re-run by anyone: the S760 live e2e (9/9) claim, the `reportGV`
repro numbers in XA, the 87.6% x-shift and "11 failures / 6 blocks" counts in XD, rectilinear 1202 in XD4, and all
rendered figures. Of the 53 moderates, 18 were re-checked by this session (marked **S**); the other 36 rest on one
agent's grep or read and were not independently reproduced.
