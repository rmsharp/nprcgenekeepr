# Docs staleness audit, slice 8: `docs/research/` and the older `docs/audits/` reports (2026-10-02, S868)

Read-only audit. Nothing in the repo was changed except this report and the session records.

## Audit summary

- **Scope (owner-chosen, S868):** the 5 files in `docs/research/` and 41 older files in `docs/audits/` (the 12 BACKLOG-,
  roxygen-, issue- and XARCH-era reports; the 10 genetic-metrics, kinship2, review, CRAN and tarball reports; the 7
  pedigree-drawing and PED_GV reports; the 4 findings CSVs). **Not covered:** the slice 1-7c reports of this series
  (recent, and they are this audit's own records).
- **Criterion:** a statement true "as of its date" is not stale because code moved on. A finding is a claim that is
  presented as current, a status line or banner that is now false, an open-items / ratified-order / defect list whose items
  were since done without a marker, or a path, function, line, count, default or issue state that today misleads a reader.
- **Method:** four read-only subagents (A: `docs/research/`; B: June-July audits; C: genetic-metrics, kinship2, review,
  CRAN and tarball reports; D: pedigree-drawing and PED_GV reports). This session then re-ran the evidence for the
  headline claims: issue states with `gh` (#1-#168 as cited), `git cat-file -t` on the cited commits, `DESCRIPTION`
  (`quadprog` Imports:55, `Rlabkey (>= 3.2.0)` :57, `kinship2` Suggests:70), file existence (`R/sexCodes.R`,
  `R/columnSchema.R`, `R/getConfigApiKey.R`, `R/hasNetrc.R`, `R/defaultSiteParams.R`; `R/agePyramidPlot.R` and the two
  suggested-NEWS files are gone), `.Rbuildignore:156`, the `tarball_size_clean_export` gate, `makePedigreeDiagramData.R`
  (3,095 lines; `.positionMatingUnitForest` at :843), counts (233 exports, 286 `R/` files, 267 `man/` pages) and the CSV
  row counts. Anything an agent could not check (CRAN state, Rlabkey release, measured times and sizes, the census scripts
  that overwrite tracked CSVs) is said so in its section. The agents' ids are kept (A, B, C, D).
- **Findings:** 0 critical, **42 moderate** (A 9, B 10, C 11, D 12) and **62 minor** (A 12, B 19, C 19, D 12).
  Nothing was found wrong in the *code*.
- **One cause explains nearly all of it, the same as slice 7c:** these are dated records, and **none of them carries a
  "status as of" or superseded banner**. Every one that ended in "fixes are a separate follow-on", "OPEN, untriaged",
  "a fix item is warranted" or a ratified pickup order was acted on afterwards (issues #109, #118, #119, #120, #143-#153,
  #156, #158, #167, #168 and the QP solver, all closed), so a reader who trusts the body re-opens finished work.

## Recommendation (nothing applied this session)

> **Update S870 (2026-10-02):** recommendations 1 and 2 were applied: a status banner on the 26 files with a moderate finding (4 in `docs/research/`, 22 in `docs/audits/`) and the two numbers corrected inline. Recommendations 3-4 are still open.

1. Add a one-line "Status as of 2026-10-02" banner, naming what superseded the report, to the files with a moderate
   finding. Leave the bodies as dated records. Candidates by group:
   - **A:** `kinship2-alignped4-joint-positioning-mechanism` (A4, A5), `labkey-integration-options` (A13),
     `pedigree-diagram-package-split-scoping` (A18, A19), `kinship2-feature-gap-analysis` (A9, A10).
   - **B:** `BACKLOG_STALENESS_AUDIT_2026-06-12`, `IMPLEMENTED_BUT_OPEN_AUDIT_2026-06-16`, `ROXYGEN_HARMONIZATION`,
     `ISSUE_109`, `ISSUE_118`, `ISSUE_119`, `ISSUE_120`, `XARCH_TRACKER_RECONCILIATION`.
   - **C:** the sequencing audit, the 08-06 capability audit, `ISSUE_129`, `KINSHIP2_SUPPLEMENT`, `DOCUMENT1_TWO_LENS`,
     `SUGGESTED_NEWS_ENTRY_REVIEW`, `CRAN_CHECK_TIME`, `TARBALL_SIZE`.
   - **D:** all six reports with findings; `PED_GV_AUDIT_TRIAGE` needs it most (commit `926cc907b`, S795, fixed
     NEW-14, PED-11, NEW-56, NEW-63 and PED-10/NEW-43, and `BACKLOG.md` does not list it, so "32 open ids" is overstated).
2. Correct the two checkable numbers that cannot be left as history: the 09-02 census report says its CSV holds 2,734 rows
   (it holds 1,678 data rows, regenerated under later engines), and `tarball_size` says "0 gates" (there is one).
3. Owner decisions: whether to do the banner pass at all, and whether the stale file:line cites in the plans and the
   gap analysis should be replaced by function names or left.
4. D's open question for a later session: 6 of 474 parent-to-union edges in the founder-positioning rerun still differ in
   row; not investigated.

The agents' full tables follow, unedited except for heading levels.

## Group A tables (subagent report)

### Slice 8 / A staleness audit (docs/research, 5 files). Read-only. Run 2026-10-02.

### issue-145-kinship2-sire-dam-placement-spike-2026-08-08.md
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| A1 | minor | :19-21 | kinship2 1.9.6.2 "not added to DESCRIPTION/renv.lock" | DESCRIPTION:70 lists kinship2 in Suggests (S637 commit 526c7fecf, after this doc). Installed version still 1.9.6.2 (Rscript packageVersion). | leave as dated record, or add one-line "since S637 Suggests" |
| A2 | minor | :146-147 | "already nprcgenekeepr's own existing tie-break convention in .positionMatingUnitForest()" | function still exists (R/makePedigreeDiagramData.R:843), but tie-break behaviour not re-verified | leave |
| A3 | minor | :139-158 | "Recommendation for a future #145 design session"; qmd refresh "not this session's scope" | issue #145 is CLOSED (gh issue view 145). Doc has no banner saying recommendations were acted on. | add "status as of 2026-10: #145 CLOSED" banner |
Other checks OK: cited audit and .qmd exist; kinship2 1.9.6.2 installed.

### kinship2-alignped4-joint-positioning-mechanism-2026-09-03.md
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| A4 | moderate | :4-12, :208 (header "§5 still-open A-vs-C decision"), TL;DR :45-54 | doc exists to inform an undecided (A) vs (C) choice; (C) is a "costed estimate" | Option (C) was adopted and built: plan docs/planning/pedigree-diagram-joint-qp-solver-plan.md exists; commit 2cd89eeee "S673 .solveJointQP() standalone"; R/makePedigreeDiagramData.R:1329,1578 call quadprog::solve.QP. | add status banner "decision made, (C) implemented S673+; see joint-qp-solver-plan" |
| A5 | moderate | :49-50 and :151-153 | quadprog "currently absent, even transitively, from DESCRIPTION"; grep of R/ NAMESPACE DESCRIPTION "returns nothing" | DESCRIPTION:55 lists quadprog under Imports (lines 42-62); renv.lock has it; R/makePedigreeDiagramData.R:1578 uses it. Re-ran grep: hits. | reword with "(as of S670; added S673)" |
| A6 | moderate | :34, :114, :202, :275 (also :143-:186 area) | "R/makePedigreeDiagramData.R:713-733", ":759-1529, ~770 lines", ":705-1529", ":801-810", ":781", ":1280", ":1492" | file is now 3095 lines; .positionMatingUnitForest is at :843; .forestComponents :640, .packComponents :727. All cited line numbers/ranges point at different code. | add "line numbers as of S670" note; do not use as navigation |
| A7 | minor | :54, :186 | BACKLOG.md Up Next item 1 / "BACKLOG.md's two untested alternatives" | grep joint/alignped4/option (C) in BACKLOG.md: no hits; item gone. | leave as dated or note item completed |
| A8 | minor | :194-197 | "pinned test suite test_positionMatingUnitForest.R, test_resolveEdgeNodeCollisions.R" | not individually re-checked (ran out of budget for this) | unchecked |
Verified OK: data-raw/kinship2AlignPedigreeJointSolverProbe.R exists; kinship2 1.9.6.2; local 1.6.4 checkout dir /Users/rmsharp/Documents/Development/R/r_workspace/kinship2 exists.

### kinship2-feature-gap-analysis-2026-09-20.md
Counts re-run: kinship2 exports = 25, S3 registrations = 11, datasets = 3 (minnbreast, sample.ped, testped1). Issues #131-#137, #143, #144, #145 all CLOSED. Referenced docs (ISSUE_129 audit, supplement plan, issue-145 spike) exist. shrinkPedigree helpers, findGeneration, findPedigreeNumber, etc. exist. familycheck/ibdMatrix: no hits in R/ NAMESPACE (still absent). Substantive claims hold.
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| A9 | moderate | table rows 1,4-6,8-17,20-22 evidence column (:73-107) and :127,:152 | ~25 file:line cites, e.g. `R/qcStudbook.R:186`, `R/kinship.R:104`, `R/shrinkPedigree.R:227/363/337/250/281/326/122`, `R/addParents.R:30`, `R/findGeneration.R:40`, `R/trimPedigree.R:51`, `R/findPedigreeNumber.R:36`, `R/makePedigreeDiagramData.R:1665` | Checked with sed -n Np: nearly all now land on roxygen/example lines or other code. Definitions now at: qcStudbook :223, kinship :107, addParents :34, correctParentSex :79, addBackSecondParents :36, findPedigreeNumber :39, trimPedigree :58, removeUnknownAnimals :25, removeUninformativeFounders :33, readTwinRelations :36, getIdsWithOneParent :28, shrinkPedigree :98, .bitSizeOf :203, .findUnavailable :226, .excludeUnavailFounders :257, .strayMarryinIds :302, .findAvailNonInform :313, .findAvailAffected :339, makePedigreeMatingLayout :1673. findGeneration :40 and getDescendantPedigree :26 still correct. (Some of the drift predates the doc, e.g. 3 shrink cites were already off.) | replace with function-name-only evidence or add "line numbers as of S741"; moderate because the evidence column is the doc's verifiability mechanism |
| A10 | moderate | :4, :158, :37-38 | `BACKLOG.md:95`, `BACKLOG.md:71-94`, `NEWS.Rmd:230-235` | BACKLOG item now at ~:239 (BLOCKED, D-1/D-2/D-3 DONE S744-746); prep steps no longer "queued/remain step 0"; NEWS.Rmd chrtype entry now at :103, shrinkPedigree :96. | reword :158 and :197-199 ("Sequencing is already queued: prep D-1/D-2/D-3 precede any extraction") to say prep is complete; drop line refs |
| A11 | minor | :160 | D-1 boundary at `R/makePedigreeDiagramData.R:1755` | line 1755 is a comment about mating-unit logic; kinship( refs at :1752 (comment). Whether D-1 inverted it (BACKLOG says D-1 landed S744): consistent with doc being superseded. | note D-1 done |
| A12 | minor | :99-?, row 16/19/23 | `R/modPedigree.R:686`, `:649-660`, `:675-790` | modPedigree.R is now 925 lines; :686 is renderVisNetwork, :649-660 is a twin-connector checkbox (not legend). Roughly right area but not exact. | with A9 |
Not checked: that the two "substantive partials" (no hint mechanism; no block-sparse kinship) remain true; no signature change seen in makePedigreeMatingLayout (:1673 signature starts edgeStyle=...), I did not read the full arg list.

### labkey-integration-options-2026-06-19.md
Doc carries "(as of 2026-06-19)" stamps and a Status line, which protects most time-relative claims. But the recommendations are presented as pending and have been implemented.
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| A13 | moderate | :17, :154-:170 (Recommendation 1-4), :118 table, :132 risk 1 | "Rlabkey declared with no version floor"; Rec 1 "add a version floor, DESCRIPTION:52" | DESCRIPTION:57 `Rlabkey (>= 3.2.0)` (merged PR #57, c12cfafd). BACKLOG.md:213-216: "Recs #1-#5 all DONE" (floor, defaultSiteParams(), optional API-key auth, getPedigreeSource() adapter, getLkDirectRelatives delegating). R/getConfigApiKey.R, R/hasNetrc.R, R/defaultSiteParams.R, R/getPedDirectRelatives.R exist. | add banner at top: "Recs 1-5 implemented; see BACKLOG 'Act on the LabKey integration research' item" |
| A14 | moderate | :5, :23, :1 exec summary | "v2.0.0 (CRAN-archived 2025-07-29, working toward re-submission)" | sibling doc (pedigree-diagram-package-split-scoping-2026-09-02.md:56) says 2.0.0 is on CRAN, published 2026-07-26; DESCRIPTION is 2.0.0.9000. I could not confirm CRAN status first-hand (no network check); the claim is only internally inconsistent across docs. | banner "re-submitted; accepted 2026-07-26 per scoping doc" if owner confirms |
| A15 | minor | :25, :27, :154, :200, :217-221 | `R/getSiteInfo.R:71-74` (lkPedColumns), `:67` (baseUrl), `:56-87`, `:37-44`; `DESCRIPTION:52`; "ONPRC fallback hardcoded" in getSiteInfo | defaults moved to R/defaultSiteParams.R (:24); getSiteInfo.R mentions primeuat.ohsu.edu only in roxygen (:17); DESCRIPTION line is :57; example config is at inst/extdata/examples/example_nprcgenekeepr_config (not inst/extdata/). | fold into A13 banner |
| A16 | minor | :41, :47 | Rlabkey current release 3.4.6 (2026-02-21) | stamped "as of 2026-06-19"; not re-checked (no network) | leave |
| A17 | minor | :176 open questions | live ONPRC/SNPRC server version unknown | BACKLOG.md:229-231 still lists it unobserved: still true | leave |

### pedigree-diagram-package-split-scoping-2026-09-02.md
Mostly measurements explicitly tied to commit 94ae26c8 (exists: git cat-file -t = commit) and dated; counts (2,537 lines, 277, 882, 29,140 R/ lines, 272/86 commits) are as-of measurements and now differ (3095, 437, 925, 34753) but are labeled; not flagged.
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| A18 | moderate | :66-69 and :400-413 (section 6 revisit condition 1) | "STANDING TOP PRIORITY (S643) ... stands"; condition 1 "owner has lifted the standing priority" | MEMORY.md: standing priority RETIRED by owner sign-off 2026-09-17 (S699); grep STANDING in BACKLOG.md finds no such note. Condition 1's first half is met; the churn half unverified. | add status note; note BACKLOG item (:239, disposition S738/S742) holds the live revisit conditions |
| A19 | moderate | :422-436 (Option D, D-1/D-2/D-3 "candidates, not commitments"; "This session adds none") | prep steps are optional/unqueued | BACKLOG.md:239-243: D-1 S744, D-2 S745, D-3 S746 ALL DONE; positionTreeApportion.R now has 13 @noRd hits. Standalone-package item is BLOCKED on S738 revisit conditions only. | add "D-1..D-3 completed S744-S746" |
| A20 | minor | many (:108-111, :119-120 etc.) | file:line anchors (`:32`, `:1461`, `:389`, `:627`, `:1927`, `:2253`, `:1551`, `:642`, `test_modPedigree.R:1669/:1706`) | makePedigreeDiagramData now :38, makePedigreeMatingLayout :1673, .positionMatingUnitForest :843; others not re-checked | acceptable given 94ae26c8 anchor; add "line numbers as of 94ae26c8" if desired |
| A21 | minor | :56-58 | CRAN Imports lacks visNetwork; Diagram tab "unreleased dev work" | DESCRIPTION line 62 now has visNetwork; if 2.0.0 shipped 2026-07-26 (per :56) the "unreleased" framing is contradictory within the doc's own premise; I could not verify CRAN content | clarify date |

### Counts
moderate: 10 (A4, A5, A6, A9, A10, A13, A14, A18, A19 = 9; plus none other) -> exact: A4 A5 A6 A9 A10 A13 A14 A18 A19 = 9 moderate.
minor: A1 A2 A3 A7 A8 A11 A12 A15 A16 A17 A20 A21 = 12 minor.
(issue-145 doc: 0 moderate, 3 minor; alignped4: 3 moderate, 2 minor; gap analysis: 2 moderate, 2 minor; labkey: 2 moderate, 3 minor; scoping: 2 moderate, 2 minor.)

### Verified by running (first-hand)
A1 (grep DESCRIPTION, packageVersion), A3 (gh issue view 145), A4/A5 (grep DESCRIPTION/R/NAMESPACE for quadprog; git log --grep quadprog; ls docs/planning), A6 (grep -n function definitions, wc -l), A9 (sed -n Np on ~22 cites; grep -n function defs), A10 (grep BACKLOG/NEWS), A11, A12, A13 (grep DESCRIPTION Rlabkey; ls R/; BACKLOG:213-216), A15, A18 (MEMORY note read; grep BACKLOG), A19 (grep @noRd count, BACKLOG:239-243); gap-analysis counts (25/11/3 via load_all + getNamespaceExports), issues #131-137,143-145 all CLOSED via gh; git cat-file 94ae26c8.
Read-only / not checked: A2, A7, A8, A14, A16, A17, A20, A21 (no network, so CRAN state and Rlabkey 3.4.6 not verifiable; test file names in A8 not checked; README-style claims inside the 5 docs about kinship2 internals (alignped4 behaviour, probe numbers 520/529 etc.) were not re-run).

## Group B tables (subagent report)

### Slice 8 B -- staleness audit of 12 docs/audits files (read-only; run 2026-10-02)

Common finding: none of the 12 files carries a "status as of" / superseded banner (grep for "supersed|status as of" hits only XARCH_TRACKER, where it is unrelated). Several carry a Status line or recommendations list that is now false.

### BACKLOG_STALENESS_AUDIT_2026-06-12.md
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| B1 | moderate | lines 24-27, 130-167 (Headline, Recommendations) | "STALE -> close candidate: #14,#8"; "PARTIAL: #1,#5,#9,#35,#37"; "OPEN: #2,#4,#10,#11,#12,#13,#26,#28,#29,#31,#32,#33,#36,#38"; "Leave the 14 OPEN issues open"; "Consolidate ID cluster #38/#32/#26/#31" | `gh issue list --state all`: CLOSED = 1,2,4,8,9,13,14,26,29,31,32,33,35,38. Only 5,10,11,12,28,36,37 still OPEN. Recs (close #14/#8, re-scope #35, keep #1/#9 open, leave #2/#4/#13/#26/#29/#31/#32/#33/#38 open) are all done or reversed. | add banner "historical, 21 issues as of 2026-06-12; see gh for current state" |
| B2 | moderate | "Findings - OPEN" table rows 38,29,33,32,31,26,13,2,4 | "setAutoIdFormat()/getAutoIdFormat() do not exist"; "makeGroupNum exists nowhere"; "R/fillBins.R:6 still TODO"; "R/getPotentialParents.R:92-94 hack TODO" | NAMESPACE now exports getAutoIdFormat (l.85), setAutoIdFormat (228), makeGroupNum (147), makeGrpNum (148, deprecated alias, R/makeGroupNum.R:35 `.Deprecated`). `grep TODO R/fillBins.R R/removeAutoGenIds.R R/getPotentialParents.R` -> none. Reader of the table would think these gaps persist. | covered by B1 banner |
| B3 | minor | l.129, l.130-131 | cites `R/agePyramidPlot.R:60-63`, `inst/extdata/meeting_notes.Rmd:51` | R/agePyramidPlot.R deleted (commit f78162106 "delete dead agePyramidPlot.R", S285); `inst/extdata/meeting_notes.Rmd` absent, only `dev/extdata-scratch/meeting_notes.qmd`. #36 still OPEN but its cited TODO location no longer exists (R/getPyramidPlot.R has no TODO/species). | covered by banner; note path moves |
| B4 | minor | all file:line cites (modInput.R:67-112 etc.) | | Line numbers not re-checked individually; R/ has grown 202->286 files; treat as dated. | leave |

### IMPLEMENTED_BUT_OPEN_AUDIT_2026-06-16.md
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| B5 | moderate | Headline table l.36-41; Recommendations l.135-150 | open-issue set "#45, #37, #1, #5, #9, #2, #10, #11, #12, #13, #28, #29, #36, #46"; "Next actionable work: #36 or #29 (rename...grep inventory first)"; "#46 keystone"; "owner decision: close #45?" | CLOSED today: 1,2,9,13,29,45,46. #29 rename done (makeGroupNum exported, makeGrpNum deprecated). Still OPEN: 5,10,11,12,28,36,37. "Owner decision on #45" and "#29 grep inventory first" are moot. | add banner |
| B6 | minor | "Not-implemented" table, #29 row, #36 row, #11/#12 rows | `makeGroupNum appears nowhere`; `R/agePyramidPlot.R:60-63`; `meeting_notes.Rmd:51-52` | makeGroupNum now exists; agePyramidPlot.R deleted; meeting_notes moved to dev/extdata-scratch/*.qmd | banner |
| B7 | minor | no pointer | audit is superseded for #37 by ISSUE_37 2026-06-27 and for the tracker by later state | no cross-link | optional banner |

### ISSUE_37_UNUSED_EXPORTS_AUDIT_2026-06-16.md
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| B8 | minor | Summary/Findings #3, #4, Items table 26-27 | "166 exports / 127 used / 39 unused"; "makeGrpNum" not mentioned; `setAutoIdFormat` row "keep-as-public-API"; "202 R/*.R files" | NAMESPACE now 233 `export(` lines, R/ has 286 files; superseded by the 06-27 audit (176/137/39), which itself is old. Inventory is dated, not presented as live. | leave as dated record; optional "superseded by 2026-06-27" banner |
| B9 | minor | Finding #3 | safeExecute/logModuleEvent/savePlotToFile "zero callers" | Still true for safeExecute (only a @seealso in logModuleEvent.R); logModuleEvent is called from savePlotToFile.R (island-internal, audit says "outside their own files" so consistent). Verified still accurate. | no action |
Issue #37 is still OPEN (verified), so the "owner: close or keep+refresh body" recommendation is still live; no staleness.

### ISSUE_37_UNUSED_EXPORTS_AUDIT_2026-06-27.md
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| B10 | minor | Finding #4 | `makeGrpNum` at `R/makeGroupNum.R:32`, `NAMESPACE:125`; makeGroupNum `NAMESPACE:124` | .Deprecated is at R/makeGroupNum.R:35; NAMESPACE lines are now 147/148. `export(gvaConvergence)` still present (l.128). Content correct, line numbers drifted. | leave |
| B11 | minor | headline "176 exported / 137 used / 39 unused" | | 233 export() lines now; counts are dated "HEAD 600e166d". Not presented as current. | leave as dated record |
Open recommendation (close #37 or refresh body) still live (#37 OPEN).

### ROXYGEN_HARMONIZATION_AUDIT_2026-06-29.md
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| B12 | moderate | l.5 Status; l.100-140 roadmap Sec 6; Sec 4 defects D1-D8 | "Implementation is a separate follow-on session"; defect table D1-D8 and 8-stage roadmap read as open | #102 and #103 CLOSED; commits S267-S319 incl. 8d28e779c "close issue ... Stage 8 complete"; 923b66e4f fixed set_seed @returns. Verified fixed: single `_PACKAGE` (R/nprcgenekeepr-package.R:5; R/nprcgenekeeper.R gone); no "obfucate/portential" in R/; `@returns` gone; getSpeciesGestation-style copyright-above-block now in addAnimalsWithNoRelative.R; `@keywords internal` absent from modPotentialParents.R/readFocalAnimalIds.R. | add banner "implemented via #103, closed" |
| B13 | minor | l.98 / Sec 7 | "226 R/*.R files", "145/167 exported with examples" | 286 files, 233 exports now. Dated counts. | banner covers |
| B14 | minor | Finding 7 table | `@import` held by 10 files; "kinship.R: @import Matrix", "nprcgenekeepr-package.R @import shiny" | still true for those two (R/kinship.R:98, R/nprcgenekeepr-package.R:8), the other 8 converted (grep `@import ` only these 2). Table is partially stale. | banner |

### ISSUE_109_DOC_ERROR_AUDIT_2026-07-04.md
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| B15 | moderate | l.7 Status; Sec 3 (38 findings); Sec 6 Recommendations "follow-on, owner-gated session" | "fixes are a separate, owner-gated follow-on"; 38 confirmed errors listed as to-fix | #109 CLOSED. Commits 3b5b1a996 "fix 37/38 audited doc-vs-code errors" (S274), 600a1a0bb finding #9 + close #109 (S275), 1be687ae9 geneDrop col-order reconcile (S278). Checked: man/checkChangedColsLst.Rd now says TRUE/FALSE; saveDataframesAsFiles.Rd/makeExamplePedigreeFile.Rd now say `.excel` not xlsx; `candidates` gone from getPotentialSires/removePotentialSires/calculateSexRatio Rd; "monolithic" gone from runModularApp.Rd. | add banner "all 38 fixed (S274-S278), #109 closed" |
| B16 | minor | finding #9 / Sec 4 | "runGeneKeepR() is a lifecycle::deprecate_soft alias ... of runModularApp()" ; "decide alongside #110" | Direction reversed: R/runModularApp.R now deprecate_soft -> runGeneKeepR(); runGeneKeepR is canonical (R/runGenekeepr.R @seealso). #110 CLOSED. A reader of finding #9 would get the alias direction backwards. | banner/note |
| B17 | minor | Sec 1 "203 man pages" | | 268 man files now. dated. | leave |

### ISSUE_118_EFFECTIVE_POPULATION_SIZE_TRIAGE_2026-07-07.md
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| B18 | moderate | l.5-6 "Status of issue: OPEN, untriaged"; Sec 8 "Recommended next step: Not implementation ... planning session" | issue open/untriaged; no Ne code | #118 CLOSED. docs/planning/issue118-effective-population-size-plan.md exists; R/calcGeneDiversity.R, calcNeSexRatio.R, calcNeVariance.R, getLivingBreeders exist; commits 4d164a994/326ebf3a4/e3983a121/547908200 (S310-S313, "close #118"). Sec 4 "No prior Ne work exists" and Sec 6 option list (owner to pick) are decided/done. | add banner "resolved: E1+E2+E3 shipped; see plan doc" |

### ISSUE_119_MINPARENTAGE_TRIAGE_2026-07-07.md
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| B19 | moderate | l.5 "Status of issue: OPEN, untriaged"; Sec 1-4 describing scalar minParentAge default 2/3 as live; Sec 8 "owner decision deferred to planning session" | | #119 CLOSED. docs/planning/issue119-sex-specific-min-breeding-age-plan.md exists; commits S302-S307 (8fd217536, 8e1dc9de1, 8b2d6c4da, 31c6cdddc, c3c2ef67e). minParentAge is now `lifecycle::deprecated()` in R/checkParentAge.R:62, getPotentialParents.R:76, getProductionStatus.R:63, replaced by minSireAge/minDamAge. Decision-site line numbers (checkParentAge.R:94-95, getPotentialParents.R:97, getProductionStatus.R:64) and default table (2 vs 3) no longer describe the code. Option 1-ish (unify) was taken, not "deferred". | add banner |

### ISSUE_120_CITATION_COVERAGE_AUDIT_2026-07-08.md
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| B20 | moderate | l.9-11 Status; F1-F12; Sec 6 | "fixes are a separate, owner-gated follow-on"; F1-F5 "no @references anywhere", F8 Lacy only in @examples, F12 orphan files, F11 Lange 1997 vs 2002 | #120 CLOSED. `grep -c @references`: calcNeSexRatio, calcGeneDiversity, meanKinship, groupAddAssign, rankSubjects, calcFE/FG/FEFG/Retention, modBreedingGroups all now =1 (calcGU/calcA=2 incl. MacCluer, calcA l.27). population_genetics_terms.html now matches Mean Kinship/Genome Uniqueness (3 hits). vignettes/manual_components/_bg_algorithm.Rmd and _bg_formation.Rmd deleted (ls). gvAndBgDesc.html:11 now says Lange (1997) (matches kinship.R). _breeding_group_algorithm.Rmd now cites Vinson (l.77). | add banner "all findings addressed; #120 closed" |
| B21 | minor | Sec 3 file count "50/50", "230 R files" | | dated | leave |
(Not checked: F4 rankSubjects "ONPRC-original vs cited" owner decision outcome; only that an @references tag now exists.)

### READCSV_COLCLASSES_AUDIT_2026-07-11.md
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| B22 | minor | Sec 1, Sec 3 | "27 call sites across 12 files"; per-site lines (modSummaryStats_coverage 128,134,155,179,185 -- still correct; modGeneticValue.R:1423; modORIPReporting_server.R 177,208,226,242; modPedigree_coverage.R:56 ok) | `grep -rn "read\.csv(" tests/` now 139 hits in 62 files; modGeneticValue read.csv now at :1478; modORIPReporting_server now 6 sites (209,240,272,290,306 + comment). Audit text says "recommend no new BACKLOG item" and "close BACKLOG item" - BACKLOG entry is gone (grep), fine. Scope statement is dated; new tests since are unaudited. Not misleading if read as dated. | optional note "27 sites as of S356" |

### XARCH_TRACKER_RECONCILIATION_AUDIT_2026-07-11.md
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| B23 | moderate | Sec 1 table, XARCH-4 and XARCH-5, Sec 3 | XARCH-4 "sex-code half unchanged ... no exported sexCodes constant"; "BACKLOG narrow items for XARCH-4/6/8" | R/sexCodes.R exists (commit 3a02990a4 "S367 GREEN XARCH-4 part 1 (sexCodes constant + 3 sites)"), 2 days after this audit. R/columnSchema.R exists and getRequiredCols() now returns `.nprcColumnSchema$required` (R/getRequiredCols.R) -- the "three separate hand-maintained column vectors" claim for XARCH-5/8 is no longer true. BACKLOG.md has zero XARCH mentions, so the "tracked in BACKLOG" disposition is gone (done or dropped). (Literal sex comparisons in getPotentialSires/fillBins/filterPairs not individually re-checked.) | add banner |
| B24 | moderate | XARCH-2 "STILL OPEN (filed as issue)"; XARCH-5 "STILL OPEN (filed as an issue)"; Rec 2 | issues "see CHANGELOG for the number" | Issue numbers are #122 (module contract) CLOSED (S377, Phases 1-5 DONE) and #123 (string-keyed pipeline) still OPEN with a partial-closure comment (S387). So XARCH-2 is RESOLVED; XARCH-5 PARTIAL. Also the report never names the issue numbers (reader must dig). | add banner naming #122/#123 and states |
| B25 | minor | XARCH-6 | modInput.R:485-525 calls qcStudbook() "three times" | R/modInput.R:516-518 comment: reuses result "instead of via a second qcStudbook() invocation" -- dual-call removed. Only cited line numbers reviewed, not full re-trace. | banner |
| B26 | minor | XARCH-1 | runGeneKeepR canonical, runModularApp alias | still true (verified); noted because it contradicts ISSUE_109 audit finding #9 (B16). | none |
| B27 | minor | cites `TECH_DEBT_AUDIT_2026-05-30.md` bare | | file is at repo root (./TECH_DEBT_AUDIT_2026-05-30.md), not docs/; path acceptable. | none |

### XARCH3_SHINY_PROGRESS_HOOK_AUDIT_2026-07-11.md
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| B28 | minor | Sec 3 table line cites | reportGV `updateProgress` param L123, calls L179-221; groupAddAssign L129/L183-184; geneDrop L93/L121-145; modBreedingGroups L307-310; modGeneticValue L216-227 | now reportGV.R:153, calls 222-261; groupAddAssign.R:188, 308; geneDrop.R:96, 124-148; modBreedingGroups.R:515-627. Pattern claim (function-or-NULL, guarded, no shiny:: in code outside roxygen) re-verified TRUE for all five compute files. | leave (dated) |
| B29 | minor | Sec 1 "230 R/*.R files", "10 files surfaced" | | 286 files; `grep -rl shiny::` now also modMarkerGenetics.R, modMatePair.R (mod files, fine), zzz.R:6 (shiny::addResourcePath at load; not compute). Conclusion unaffected. R/modInput.R also references Progress fns. | leave |
Recommendation "remove the BACKLOG item" -- no XARCH/NEW-12 in BACKLOG now; done.

### Counts
moderate: 10 (B1, B2, B5, B12, B15, B18, B19, B20, B23, B24); minor: 19. (B1/B2 share a banner fix, B12-B20 each = "Status line says fixes pending; they are done".)
Root recommendation: one-line "Status as of 2026-10-02: ..." banner on B-files for 06-12, 06-16(a), 06-29, 07-04, 07-07 x2, 07-08, XARCH_TRACKER; others leave as dated records.

### Verified by running (first-hand)
`gh issue list --state all` states for #1-#130 (saved scratchpad/issues.json); `grep NAMESPACE` (makeGroupNum, makeGrpNum, set/getAutoIdFormat, gvaConvergence, 233 export lines); `ls R | wc` (286); `git cat-file -t` for 10 hashes cited (all exist: 6fd16715 2a64770f a5507a35 600e166d d06552ec 7da01afe 78009fd3 4cb5a63e bb7f2be6 b980f998); `git log --grep` for #103/#109/#118/#119/#120/#122/#123; grep `_PACKAGE`, obfucate/portential, `@returns`, `@references` counts; man/*.Rd spot checks (checkChangedColsLst, saveDataframesAsFiles, makeExamplePedigreeFile, getPotentialSires, runModularApp); R/checkParentAge|getProductionStatus|getPotentialParents minParentAge deprecated; ls vignettes/manual_components; grep read.csv in tests; grep updateProgress/shiny:: in compute files; R/sexCodes.R, R/columnSchema.R, getRequiredCols.R; safeExecute callers.
Read-only / not re-checked: ~26 of the 38 individual #109 man-page claims (only 5 spot-checked, plus issue closed with commit messages saying 37/38 fixed + 1 declined: the one declined item not identified); every individual file:line cite in the 06-12/06-16 audits' evidence sections (B4); the semantic claims about code behaviour in 06-12 STALE/PARTIAL analysis; #120 F4 owner decision text; XARCH-6/8 internals (getSiteInfo binary switch) beyond what is cited above; ROXYGEN audit counts (examples 145/167, \code vs backtick counts).

## Group C tables (subagent report)

### Slice 8 C staleness audit (docs/audits, 10 files) -- read-only, 2026-10-02

### GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| C1 | moderate | whole doc; "Recommended implementation order", Recommendations 1-5 | ratified tiered order for "8 open GitHub issues (#146-153)"; "file 2 new tracking issues"; "surface #150 to owner"; "hold scope-narrowing on #148" | `gh issue view`: #146,147,148,149,150,151,152,153 all CLOSED (08-10..09-18). Longitudinal monitoring = #167 CLOSED 09-22; ancestry guardrails = #168 CLOSED 09-23 (+#169). Order is fully done; no banner | add "status as of 2026-10-02: all #146-153 closed; Finding 1 gaps filed as #167/#168 and closed" banner |
| C2 | minor | Rec 1 | "A BACKLOG.md Sequencing note pointer is added" | `grep SEQUENCING_AUDIT BACKLOG.md` hits only the pedigree-diagram audit (l.425); pointer for this cluster gone (cluster done) | covered by banner |
| C3 | minor | Finding 3 / Tier 2 | "app's first showModal()/modalDialog()" gate | `grep showModal R/mod*.R` = 11 hits now; intent was a prediction | leave as dated record |
Verified first-hand: obfuscatePed/Id/Date/mapIdsToObfuscated, resolveCrossCenterIds, fillGroupMembers, markerParentageExclusion, modMarkerGenetics, modBreedingGroups, checkMarkerGenotypeFile exist (ls R/). PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md exists.

### GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md
| C4 | minor | header / Findings tables / "Summary: notable missing features" | "16 implemented, 9 partial, 12 missing"; ranking hardcoded; no skew/kurtosis; no marker kinship; Pedigree/Draw Missing; "Recommendations" 1-5 | Superseded by 08-05/08-06 audits (26 impl.) and by shipped work (reportGV guCutoff/axisPriority, calcSkewness, markerKinship, diagram, #167/#168). Doc has no superseded banner; 08-05 names it as "Baseline" but the reverse pointer is absent. File:line cites (e.g. modBreedingGroups.R:40-53, groupAddAssign.R:164-186) are 2+ months old | add one-line "Baseline snapshot of 2026-07-29; superseded by ..._2026-08-06.md" banner; otherwise leave |

### GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md
| C5 | minor | "Remaining priority gaps" 1-5; "26 implemented, 9 partial, 2 missing" | five gaps "remaining" | Superseded one day later by 08-06; gaps since closed: #147,#146,#149,#152,#153 CLOSED | add "superseded by 08-06 (and gaps now closed per #146-153)" banner |
Note: its Method says focused tests "completed successfully" -- not re-run (dated).

### GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-06.md
| C6 | moderate | "Executive assessment" 1-5, "Capability comparison" Missing/Partial rows, "Priority gap analysis" (High/Medium/Deferred) | "No mechanism prevents ... ancestry mixing"; "No longitudinal snapshot/trend workflow" (Missing); parentage assignment cannot rank; cross-center "script-only"; mate-pair "no ... table"; MHC/NGS/LD "Missing/Partial" | Priority table is the authoritative source cited by the sequencing audit and is read as "current gaps". Today: #167 longitudinal CLOSED, #168/#169 ancestry guardrails CLOSED, #147 CLOSED, #149 CLOSED, #151 CLOSED, #148/#152/#153 CLOSED. All 7 table rows are done; no banner | add "status as of 2026-10-02: every row of Priority gap analysis has a closed issue" banner (table of row -> issue) |
| C7 | minor | row "Support population projection" | "issue #10 tracks future GVA prediction" | `gh issue view 10` = OPEN, "Add ability to predict future GVA through breeding simulation" | still accurate; no action |
| C8 | minor | row "Analyze individual candidate mating pairs" | "no ... curator-facing table" | Mate Pair Analysis module/reportMatePairs() exists (#151 closed; #169 refs modMatePair) | covered by C6 banner |

### ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md
| C9 | moderate | Findings 1,3,5,6,8; Recs 1-3,8; table rows 6,7,9,10,14 | no loop verification (Dragon P2 open); no image export; no legend; no twins; no names; "file a GitHub issue" x4 | Issues filed and CLOSED: #134 loop verify, #131 image export, #132 legend, #133 affected status, #135 hover/search, #136 names, #137 twins. R/modPedigree.R now has visLegend (~l.726) and "Export Diagram (PNG)" (l.720). Doc carries no status banner | add status banner: findings 1,2,3,5,6,8 and rec 8 now shipped (#131-#137) |
| C10 | minor | table row 1/13, Finding 7 | "1,500 nodes", `pedigreeDiagramMaxNodes <- 1500L` (R/modPedigree.R:366) | now 750L at R/modPedigree.R:445 (+ 400 rectilinear, l.457) | reword or banner |
| C11 | minor | table row 1,2,5 etc. | engine is "visNetwork hierarchical layout (visHierarchicalLayout UD)"; makePedigreeDiagramData is the layout | layout now `makePedigreeMatingLayout()` (R/makePedigreeDiagramData.R:1673); visNetwork still in DESCRIPTION:62. All R/modPedigree.R:NNN citations (360-413, 383-402, 129-133...) are shifted | banner: line numbers are as of S435 |
| C12 | minor | Method / D2 | plan doc `docs/planning/issue129-...plan.md:364-381` | file exists (633 lines); line range not re-checked | not verified |

### KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md
| C13 | moderate | Finding #1 (`kinship()` "takes only id/father.id/mother.id/pdepth", no twin support); Rec 1 | gap: MZ twins not in kinship() | R/kinship.R:107-108 now `kinship(id,father.id,mother.id,pdepth,sparse=FALSE,twinRelations=NULL,chrtype="autosome",sex=NULL)`; roxygen l.34-49 documents MZ correction. Resolved | banner/strike: "resolved (twinRelations threaded into kinship())" |
| C14 | moderate | Finding #4 "No X-chromosome kinship; grepped chrtype ... zero matches"; Table "No -- capability doesn't exist" | stale | `grep chrtype R/kinship.R` -> l.51,108,114,120; issue #156 CLOSED "Add X-chromosome kinship computation"; kinship.R roxygen cites supplement Table S2 | banner/reword |
| C15 | moderate | Finding #2 "`grep -in consang R/*.R`: zero matches"; no visual marker; Rec 2 | stale | `grep -il consang R/*.R` -> R/makePedigreeDiagramData.R; issue #158 CLOSED "Propagate consanguineous-marker color/width onto ... rectilinear" | banner/reword |
| C16 | minor | Finding 2 Location `R/makePedigreeDiagramData.R:1032` | makePedigreeMatingLayout there | now l.1673 | minor |
| C17 | minor | Finding #1 "15 call sites", "Rec: file follow-up issue" | n/a | not re-counted | not verified |
Finding #3 (trimPedigree vs pedigree.shrink) still correct (R/trimPedigree.R exists; "shrinkPedigree" mentioned in a later review as having twinRelations -- not re-checked).

### DOCUMENT1_TWO_LENS_REVIEW_2026-07-09.md
| C18 | moderate | Status line (l.4-11), "Final Findings Summary" (all 15 "Confirmed, unfixed"), "What this session did NOT do", "Next steps for the session that picks up the fixes" | "All 15 are confirmed real and still unfixed"; fix session still to come | Commit 98db4ff7e "docs: S343 -- fix all 15 confirmed Document 1 audit findings". Today vignettes/articles/engineering-the-2.0.0-release.qmd: l.180 now says `runModularApp()` became the alias (A1 fixed); l.683 "three sessions"; l.760 "illustrates)" (B2 fixed); 44 hyperlinks (was 1); data/commit-activity-timeline.csv has 2026-01..03 rows with 0 (A2 fixed); feature-highlights.csv row 4 date 2026-06-13 (A3 fixed). `grep -c "S343" this doc` = 0 -- no pointer | add banner "all 15 fixed in S343 (98db4ff7e)"; line refs (L105-131, L709 etc.; file now 796 lines) are stale |
| C19 | minor | Lens B B4/B5 | XARCH-2 / Phase A still unglossed? | `grep` shows "Phase A" still used (l.595,705,738,752) -- gloss status not checked | not verified |

### SUGGESTED_NEWS_ENTRY_REVIEW_2026-09-27.md
| C20 | moderate | Scope/Audit Summary: reviews "the owner's untracked draft" `suggested_NEWS_entry.md` + `vignettes/suggested_NEWS_entry.Rmd` | files exist | Neither exists in working tree; commit 3a8c026bb (S831) untracked/removed the draft NEWS vignette. Reader cannot open the objects of the review | add note "drafts removed S831; review kept as record" |
| C21 | moderate | all `NEWS.Rmd:NNN` citations (dev-block `15-495`, `21-192`, `193-216`, `218-270`, `330-380`, `455-495` etc.); "33 detailed bullets" in Pedigree section; G4 `## Package` entry at `NEWS.Rmd:17-19` "CRAN accepted ... published 2026-07-26" | dev-block 15-495 | `grep ^## NEWS.Rmd`: dev-block is 14-384 (2.0.0 begins l.385); sections: Pedigree Diagram 22, Kinship 83, Marker 106, MHC 150, ... General Fixes 317. `## Package` section no longer exists (G4 moot); section titles changed ("Pedigree diagrams"->"Pedigree Diagram", "General improvements"). Sweep + any S7/S11 follow-up since 09-27 means "Moderate S7 / S11" recs may already be applied or moot -- not checked | banner "line numbers as of 2026-09-27; NEWS.Rmd dev-block since restructured" |
| C22 | minor | S7 `R/groupAddAssign.R:171` | `candidates` first param there | function def at l.175 | minor |
| C23 | minor | G2/G3/Rec 3 "BACKLOG open consolidate item" | BACKLOG l.76: "Move version to 3.0.0 just before release (READY at release time)" -- owner decided (S855) next release is 3.0.0; `Version: 2.0.0.9000` unchanged (DESCRIPTION:4) | version-heading remarks still true; add note that 3.0.0 now decided | optional |
Verified: harem-sire BACKLOG item exists (BACKLOG l.171); Learning 778 exists (1 match); display cap 400/750 still in NEWS.Rmd l.50-51.

### CRAN_CHECK_TIME_AUDIT_2026-09-19.md
| C24 | moderate | Lead paragraph, Finding 1 (Critical), Recs 1-2, "Research only: no remedy applied" | 17.3 min check, submission-blocking example, `R/makePedigreeDiagramData.R:1659-1662` still `examplePedigree` | Fixed: ba088d0dc "S732 -- shrink makePedigreeMatingLayout example input (examplePedigree 3,694 rows/734 s -> smallPed 17 rows/0.03 s)"; R/makePedigreeDiagramData.R:1667-1670 now uses `nprcgenekeepr::smallPed`; commit msg: check CPU 1,032->291.6 s, >5s table empty. Doc has no resolution marker | add "RESOLVED S732 (ba088d0dc)" banner at top |
| C25 | minor | Finding 1 / Context | `pedigreeDiagramMaxNodes <- 750L` at `R/modPedigree.R:406` | value correct, line now 445 | minor |
| C26 | minor | Coverage/§1 counts | "202 Rd examples of 256 Rd files", "330 test files" | `ls man/*.Rd` = 267; `ls tests/testthat/test*.R` = 365 | dated record; leave |
| C27 | minor | Finding 3 | "0 Rd files use \donttest, 9 use \dontrun" | re-grepped man/: 0 / 9 -- still true | none |
Verified exist: test_positionMatingUnitForest.R, test_resolveEdgeNodeCollisions.R; commits c8397845 (cat-file commit), `f8ffa40b` (commit). Finding 4 (optional skip_on_cran) -- not checked if applied.

### TARBALL_SIZE_AUDIT_2026-09-19.md
| C28 | moderate | Findings 1,2,5; Recs 1,2,4 ("fix does not exist at HEAD"; ".Rbuildignore at HEAD has no scratchpad entry"; ".quality-gates.json declares 0 gates") | open | `.Rbuildignore:156 ^scratchpad$`, `:160-161` testthat debris; `.gitignore:97,101-102`; `.quality-gates.json` has gate `tarball_size_clean_export` max 5,000,000 (S728). Findings 1/2/5 resolved; Finding 3 (html_document vignettes) still open per BACKLOG l.278-292 | add status banner: F1,F2,F5 resolved (S728+); F3 open |
| C29 | minor | "scratchpad/ (untracked, 250 files, 20 MB)" | `ls -d scratchpad` exists; size not re-measured | not verified |
| C30 | minor | Findings 3 table: `inst/doc/` 4.38 MB | `inst/doc` absent in working tree (build artifact); not re-measured | not verified |
Vignette claim still true: a2interactive/gvaConvergence/simulatedKValues use `html_document` + paged (grep). Clean tarball size not re-measured (did not run pkgbuild); `git archive HEAD | wc -c` = 56 MB is repo, not tarball.

### Counts
moderate: C1, C6, C9, C13, C14, C15, C18, C20, C21, C24, C28 = 11
minor: C2, C3, C4, C5, C7, C8, C10, C11, C12, C16, C17, C19, C22, C23, C25, C26, C27, C29, C30 = 19 (C7, C27 are "still true" notes, C12/C17/C19/C29/C30 unverified)

### Verified by running (first-hand)
gh issue state: 129,130,146-153,125,156,158,167,168,169,10,134,131-137; ls R/ for named files; grep kinship.R signature/chrtype/twinRelations; grep consang; grep pedigreeDiagramMaxNodes; grep visLegend/PNG export in R/modPedigree.R; sed R/makePedigreeDiagramData.R examples; git cat-file on c8397845/f8ffa40b; git log for S343/S732/S831; grep .Rbuildignore/.gitignore/.quality-gates.json; grep vignette output types; grep NEWS.Rmd headings and `wc -l`; grep article .qmd lines + hyperlink count + CSV; ls man/test counts; BACKLOG greps.
Read-only (not re-run): all test-run claims, timings (734 s, 1,037 s), tarball byte sizes, per-directory compressed shares, kinship2 external-source claims, WebFetch/CRAN claims, plan-doc line numbers, Learning/line numbers beyond those named, Lens B editorial items (B4-B12) beyond spot checks.
Could not check: R CMD check / pkgbuild (told not to); win-builder; kinship2 upstream facts; `inst/doc` size; whether SUGGESTED_NEWS S7/S11 recommendations were later applied to NEWS.Rmd.

## Group D tables (subagent report)

### Slice 8 D audit: pedigree/GV audit records in docs/audits (read-only, 2026-10-02)

Severity: M = moderate, m = minor. None of the 7 reports carries a status banner (checked first 20 lines of each).

### FOUNDER_POSITIONING_DEFECT_AUDIT_2026-08-03.md
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| D1 | M | whole report; L58-61, L87-91, L182-185 | "critical, confirmed 62% defect... fix not designed" | Issue #143 CLOSED 2026-08-04; fix commit 904d74b75 (S472); #144 CLOSED. Re-ran makePedigreeMatingLayout on obfuscated_rhesus_mhc_ped.csv (375 rows, 237 units): FD3BB6 y=150 and AU22BC y=150 (audit: 0 vs 150); parent-to-union edges with parent y != union y: 6 of 474 (audit: 147 of 237 units). | add 'status as of' banner: fixed S472 (#143/#144), residual 6/474 measured 2026-10-02 |
| D2 | m | L24-25 (`R/makePedigreeDiagramData.R:134-614`), L67 (`:585-591`), L98 | line ranges | file is 3,095 lines; `.buildMatingUnitForest` now at :405, `.positionMatingUnitForest` at :843 | leave as dated record (covered by banner) |
| D3 | m | L205-209 Rec 2 "File as its own GitHub issue" | recommendation | done: #143 filed and closed | covered by banner |
| D4 | none | Finding #4 (L136-152, `data-raw/rhesusPedigree.R:7-15`) | docstring claims independent raw source | STILL OPEN: BACKLOG.md:478-492 tracks it. Docstring now at data-raw/rhesusPedigree.R:7-15 reads "obfuscated from rhesusPedigree_fromCenter.csv via obfuscatePed()"; fixture first columns identical (cmp on cut -f1-3 matched) | no change; banner should say Finding #4 remains open |
Also checked: inventory table fixture row counts not re-counted (375 confirmed via read.csv).

### PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| D5 | M | L196-241 "Recommended implementation order" Tiers 1-3; L39-40 "all 6 open GitHub issues" | ratified next-pickup order for open items | gh: #133,#136,#137,#145 CLOSED 2026-08-08..10; #141 CLOSED 2026-08-21; #134,#135,#131,#142,#143,#144 CLOSED; only #138 OPEN. B3/B4 dangling-parent crashes fixed (issue #154 CLOSED; BACKLOG.md:426); #145 spike done. BACKLOG.md:418-436 records Tier 1 (S481-S484) and Tier 2 (S485-S500) as executed | add banner: order executed S481-S500; only #138 open |
| D6 | M | L122-143 Finding #1 "no sex-based ordering rule ... today" | #145 is new feature, not a fix | #145 shipped S500 (simple-pair scope). Finding is false as a statement about current code | banner |
| D7 | M | L61-71 table "BACKLOG.md lines 561-1286" B1-B9 | pointers into BACKLOG | BACKLOG.md is now 553 lines; all those line numbers point nowhere. B8 still open (BACKLOG.md:478); B2 (:439) and B9 (:494) still open | banner or reword to item names |
| D8 | m | L130-132 (`makePedigreeDiagramData.R` lines 51-57, 754-759, 154-181, 465-476, 373-680) | line refs | file now 3,095 lines | leave |
| D9 | m | L93 `inst/extdata/reference/pedigree_nomenclature.html` | path | exists (ls); OK. | none |
Not rechecked: B1/B5/B6/B7 individual status.

### PED_GV_AUDIT_TRIAGE_2026-09-26.md
Closure record (L145-165) is a marker for the 11 ids; nothing marks F1-F4 or other later fixes. BACKLOG.md:8-34 says every F slice is done. Verified first-hand with a Rscript (pkgload::load_all):
- P1 smallPed -> removeUnknownAnimals now 17 rows (was 0). F1 fixed (S782).
- P2 2-cycle getAncestors now stops "the pedigree contains a cycle ... A -> B -> A"; diamond still returns S G D G. F4 fixed (S783).
- P3 removeAutoGenIds now keeps Uma and U123 (returns Uma U123 real1 kid1). F2 other half fixed (S807-S811, `placeholder` column; R/removeAutoGenIds.R:14). addUIds reuse fixed S806/S808.
- P5/F3 fixed S798 (commit 174be7f5e); R/getPotentialParents.R:175-199 now reuses the gestation-filtered set. My P5 repro returned NULL (my input shape was probably wrong), so F3 is confirmed by commit and code read only.
- P7 kinshipMatricesToKValues(list()) now stops "kinshipMatrices must contain at least one kinship matrix" (was "object 'kValues' not found"); code R/kinshipMatricesToKValues.R:95-97. NEW-14 fixed S795 (commit a2fe3443a/926cc907b).
- P9 PED-8 still warns naming A, B (matches). P6 NEW-59 matches.
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| D10 | M | L19-26 Audit Summary "35 PRESENT"; L99-127 "Findings worth acting on" F1-F4; L129-143 Recommendations 1-2 | F1-F4 present and to be fixed first | all four fixed (S782, S783, S797/S808-S811, S798); reader following Rec 1 would redo finished work | add status banner pointing at BACKLOG.md:8 |
| D11 | M | table L55-97 rows NEW-31/32/35/38/41, PED-11, NEW-14, NEW-56, NEW-63, PED-10/NEW-43 | verdict PRESENT | fixed since: NEW-31/32 (F1), NEW-35 (F3), NEW-38 (F2), NEW-41 (F4); NEW-14 (S795); PED-11 `any()` gone from R/getRecordStatusIndex.R:14 (now `which(...)`); NEW-56 `[1L]` gone from getPotentialParents.R; NEW-63 getMaxAx roxygen now "non-negative" (R/getMaxAx.R:8-9); PED-10 roxygen now says "subdirectory of tempdir()" (R/createPedOne.R:6). BACKLOG.md:8-34 does not list the S795 bundle (NEW-14, PED-11, NEW-56, NEW-63, PED-10/43). NEW-62 still PRESENT (3 blocks, reportGV.R:222,241,260) | banner; optionally add a 'later-fixed' column |
| D12 | m | L201 Structural Obs 5 "getAncestors has no cycle test" | test gap | tests/testthat/test_getAncestors.R:45-49 now has a cycle test | covered by banner |
| D13 | m | many path:line cites (e.g. getPotentialParents.R:64-213, :190-199, :130; getRecordStatusIndex.R:14; getAncestors.R:44-67) | line numbers | R/getPotentialParents.R is now 228 lines (function at :75-228); other cites shifted after F1-F4 | leave; report says 'frozen S781 reading' only in the closure note (L148) |
| D14 | m | L8 "HEAD when read 40b9be61", L164 "Open after closure 32 ids" | counts | hash exists; 32-open count is now off by the ids in D11 (NEW-14, PED-11, NEW-56, NEW-63, PED-10, NEW-43 fixed, NEW-31/32/35/38/41 fixed) | banner |
| D15 | m | PED-2 row L55 "28 comparison lines in 10 files" | count | BACKLOG.md:21-22 says a broader grep in S852 found 32 in 13; I did not recount | leave; BACKLOG has the later number |
Verified true today: NEW-24 -> issue #123 OPEN; #46 CLOSED; commits 40b9be61, 2066f73a, ea5d28fa, 14c8e84d all exist; PED-8/PED-9 closed per closure record.

### PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-02.md (+ _findings.csv)
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| D16 | M | L20-23 "writes every finding row -- 2,734 of them -- to ..._2026-09-02_findings.csv" | CSV count/parent link | CSV has 1,678 data rows (wc -l 1679 minus header; python csv agrees). Contents by class: Real 375 chord 1,667, b off-centre 8, d 1; Track C chord 1, d 1; no a, c2, c1 or e rows. Report's scoreboard (a 288, b 168, c2 414, e 56) cannot come from this CSV. CSV was regenerated under later engines (git log: S674, S678, S679, S683, S685, S696) | banner: CSV is not the report's rows |
| D17 | M | L330-ff "Finding #1/#2 critical formulas", Recommendations L360-386 (A-vs-C decision, `BACKLOG.md Up Next` DECISION NEEDED) | defects and open decision | decision made: QP joint solver (.solveJointQP, R/makePedigreeDiagramData.R:1411; S674 Phase 2, S697 Phase 4 closed plan). Curved-arc census (L108-111 of report 09-18) shows class a=0, c2=0, e=0 on all 7 fixtures, b=6. Only one `minSep * 0.4` remains (line 1156) | banner: superseded by S674 QP engine and 2026-09-18 census |
| D18 | M | L24-25 "How to reproduce: Rscript data-raw/pedigreeDrawingErrorCensus.R" | reproduces report | script since changed (S713 b-predicate 1e-3 floor, S714 arc model replaces chord heuristic, `c-curved-chord` retired) and now writes `..._2026-09-18_postfix_findings.csv` (script lines 74-80); will not reproduce 2026-09-02 numbers. Not run (would overwrite CSV) | banner/reword |
| D19 | m | Findings #1 L20 etc. `test_resolveEdgeNodeCollisions.R:20-29` cited as stale | incidental | not rechecked | leave |
| D20 | m | `R/makePedigreeDiagramData.R` identifiers `qualifies()`, Tier 1/2/3 | tiered formulas | tier logic replaced by QP | covered by D17 |

### PEDIGREE_DRAWING_SPIKE_TWO_CONSTANT_FIX_2026-09-02.md (+ _findings.csv)
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| D21 | M | L3-4 "Feeds BACKLOG.md Up Next item 1 (owner's A-vs-C decision) ... no decision made"; L116-118 | open decision | decided (QP engine). That BACKLOG item no longer exists (grep of BACKLOG.md finds no A-vs-C item) | banner |
| D22 | M | L116-118 "census findings CSV remains the BEFORE reference" | BEFORE reference | census CSV was regenerated after S669 (see D16); it is no longer the BEFORE state | reword/banner |
| D23 | m | L17-19 `R/makePedigreeDiagramData.R:759-1529` as of b8ae2114 | line range | commit exists; function now at :843; the spike script copy is of an engine replaced in S674 (script data-raw/pedigreeDrawingSpikeTwoConstantFix.R last touched before; `Reproduce` command not run) | leave as dated record |
| CSV | ok | L116 "3,602 rows" | | matches (3602 data rows) | |

### PEDIGREE_DRAWING_CURVED_ARC_CENSUS_2026-09-18.md (+ both 09-18 CSVs)
| id | sev | location | claim | true today | rec |
|---|---|---|---|---|---|
| D24 | M | L134-150 "Recommendation: A fix item is warranted ... replace the blind +0.3 bump" and L93-104 Finding 3 "bump ... net negative" | open recommendation | implemented S715 (commit 691529998; R/makePedigreeDiagramData.R:2603-2620 roundness ladder 0.05-0.60); post-fix re-run 587 -> 149 events (postfix CSV 149 c-arc-inside rows; commit msg says 117 -> 72 arcs). Report is silent on this | add banner: fixed S715, post-fix CSV |
| D25 | m | L33-34 "The 2026-09-02 census doc and CSV are frozen audit records, untouched" | | the 09-02 CSV was rewritten S674-S696 (D16); the claim is false for the CSV | reword |
| D26 | m | `_postfix_findings.csv` (157 rows = 149 arc + 6 b + 2 d) | parent report | no report references it; only data-raw script (L74-80) and archived HANDOFFS/SESSION_NOTES do. Orphan CSV | reference from the report banner |
CSV counts verified: 09-18_findings 595 rows (587 arc + 6 b + 2 d) matches report L7/L158-160; Real 375 cArc 587 matches. 173 curved edges, 170+3: not recounted.

### PEDIGREE_DRAWING_FEATURE_GROWTH_AUDIT_2026-09-20.md
No findings. Measurement record anchored to HEAD 0528da0e; all cited hashes exist (0528da0e, 2628cd02, fc358df4, 39eb441e, f8ffa40b). Open `inst/doc/` slimming item still exists (BACKLOG.md:276-289) so Observation 2 still points at a live item. Line counts (e.g. makePedigreeDiagramData.R 3,070) are dated, now 3,095; fine as a dated record. Did not recompute the byte/line totals.

### Counts
Moderate: D1, D5, D6, D7, D10, D11, D16, D17, D18, D21, D22, D24 = 12. Minor: D2, D3, D8, D12, D13, D14, D15, D19, D20, D23, D25, D26 = 12 (D4, D9 and the CSV ok-rows are no-action notes).

### Verified by running (first-hand)
D1 (layout run on the rhesus fixture), D10 (P1, P2, P3, P9), D11 (P7, P6, plus file reads), CSV row counts and class tallies (D16, D26, wc and python csv), all gh issue states (#123, #46, #129, #131-#145, #154), all git hashes (git cat-file).
Read-only / not run: D3, D13 (F3 was only confirmed by commit and code read), D15, D17 (class a/c2/e = 0 comes from the 09-18 report's own table, not a fresh census), D18/D23 (scripts not run because they overwrite committed CSVs), D19, the B1/B5/B6/B7 statuses, the feature-growth totals.

### Could not check
Running the census script or spike script (would overwrite tracked CSVs). My P5 repro of NEW-35 returned NULL, likely due to my hand-built input, so F3 rests on commit 174be7f5e plus code. Did not locate the 6 residual rhesus mismatches in D1 (may be a separate class, such as anchor-side or duplicate-edge geometry).

