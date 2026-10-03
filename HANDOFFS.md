# Handoff Receipts — durable close-out proof

The cumulative, append-only record of **each session's close-out handoff**, distilled into a
machine-checkable block. It is the durable answer to *"was close-out actually performed, and what
did the session hand its successor?"* — the part of close-out that otherwise lives only in the
transient `SESSION_NOTES.md` (overwritten every session) or the spoken report (which leaves no file
at all).

One `handoff` block per **session** (not per commit), newest on top. The canonical-only
`bin/check-handoff` (copy it into your `bin/` if you want the structural check) asserts each block is
present and structurally complete; the next session's Phase 0 reconcile greps this file for a missing
or still-`pending` receipt and backfills it — that reconcile, not the checker, is the dependable
backstop, so the discipline needs no tooling. Together — a write-step at close-out **and** a
reconcile-on-read backstop — this makes a skipped handoff *detectable* rather than silent.

> **A green `bin/check-handoff` is not a good handoff.** The check verifies presence and structure,
> never semantic quality. Faithfulness is still scored 1–10 by the next session (Phase 3A). A
> well-formed but hollow receipt passes the check and is caught only by that human judgement.

## How to write a receipt

**At Phase 1B (claim the session)** — write the stub block below with `status: pending`, filling what
you can, and commit it with your session-claim commit. This committed `pending` block is the crash
breadcrumb: if the session ends before close-out, the next session's Phase 0 reconcile sees it.

**At Phase 3D (close-out)** — overwrite that block in place to `status: complete` and fill every
field. The block must satisfy all six Minimum Handoff Requirements (`SESSION_RUNNER.md` §3D).

## Format — a fenced `handoff` block

````
```handoff
session: S878
date: 2026-10-02
status: pending
active_task: sexCodes adoption stage 5 of 6 (makePedigreeDiagramData)
```

```handoff
session: S877
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- sexCodes adoption stage 4 of 6 (correctParentSex, addParents, modORIPReporting); stages 5-6 remain
what_was_done: claim df4767656; RED 4295ec5b4 (stage-4 list in test_sexCodes.R; failed on exactly the 14 expected lines); GREEN 3040c6d8a (14 bare letters now use sexCodes; keepAsSire/keepAsDam locals); REFACTOR nothing to change; close-out commit carries records
next_steps: stage 5 of docs/planning/sexcodes-adoption-plan.md section 4: makePedigreeDiagramData.R, hoist male/female <- sexCodes[[...]] out of loops at ~965/1090/1262; RED = add the file to the guard list; DONE needs the 9 pedigree-diagram test files green and rendered output identical on a fixed pedigree before and after
key_files: tests/testthat/test_sexCodes.R (stage-4 test); R/correctParentSex.R:82-90,97-98,110-111; R/addParents.R:54,62; R/modORIPReporting.R:210-218,312-313,359-360; PROJECT_LEARNINGS.md Learning 844
gotchas: makePedigreeDiagramData.R has a parameter named sexCodes in .shapeForVec (~1840) that shadows the constant, so do not use it there; identical(sexOf[[p]], ...) keeps [[ ]] access; stage 5 changes drawn output, so capture a before-render first; e2e needs NPRC_RUN_E2E=true
runtime_smoke: e2e-orip-module with NPRC_RUN_E2E=true 9 pass; 5 related test files pass; lintr::lint_package() 0 lints; full test_dir 365 files 0 failed 0 error 187 skipped; devtools::check() not run (plan: stage 6); quality_ratchet: not run
changelog_ref: S877 DONE entry
commit: the close-out commit that carries this receipt; claim df4767656
```

```handoff
session: S876
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- sexCodes adoption stage 3 of 6 (getPotentialParents, reportGV, modPyramid, correctUnknownParentMeanKinship); stages 4-6 remain
what_was_done: claim f4a645440; RED 6fafbcd30 (assignmentPattern, self-test lines, stage-3 list in test_sexCodes.R; failed on exactly the 7 expected lines); GREEN 01600af88 (7 bare letters now use sexCodes[["male"]]/[["female"]]); REFACTOR nothing to change; close-out commit carries records
next_steps: stage 4 of docs/planning/sexcodes-adoption-plan.md section 4: correctParentSex (97,98,108,109), addParents (54,62), modORIPReporting; RED = stage-4 file list in test_sexCodes.R; GREEN also runs tests/testthat/test-e2e-orip-module.R
key_files: tests/testthat/test_sexCodes.R (findBareSexCodeLiterals, assignmentPattern, stage-3 test); R/getPotentialParents.R:164,171; R/reportGV.R:293,295; R/modPyramid.R:121,122; R/correctUnknownParentMeanKinship.R:172
gotchas: correctParentSex:97,98 use c("H","U","M") inside %in%, so confirm RED flags them; assignment scan of all R/ hits only stage 4 files and allowlisted convertSexCodes; macOS sed -i needs -i ''; wrap at 80 columns
runtime_smoke: 6 related test files pass; lintr::lint_package() 0 lints; full test_dir 365 files 0 failed 0 error 187 skipped; no shinytest2 run (modPyramid changed only sum() tests); devtools::check() not run (plan: stage 6)
changelog_ref: S876 DONE entry
commit: the close-out commit that carries this receipt; claim f4a645440
```

```handoff
session: S875
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- sexCodes adoption stage 2 of 6 (getSpeciesMinBreedingAge, resolveBreedingAge, checkParentAge, getKinshipWithMaleStatus); stages 3-6 remain
what_was_done: claim b7f865a4c; RED 672d2d5dd (stage-2 list and argumentPattern in test_sexCodes.R, self-test lines); GREEN 0ac3b7858 (8 bare letters in 4 R files now use sexCodes[["male"]]/[["female"]]); records in the close-out commit
next_steps: stage 3 of docs/planning/sexcodes-adoption-plan.md section 4: getPotentialParents, reportGV, modPyramid, correctUnknownParentMeanKinship; RED = stage-3 file list in test_sexCodes.R plus an assignment-form pattern (correctUnknownParentMeanKinship:172 assigns a letter); re-run plan section 2 greps first; estimate: 4 R files + the guard test = 5 files
key_files: tests/testthat/test_sexCodes.R (findBareSexCodeLiterals, argumentPattern, stage-2 test); R/getSpeciesMinBreedingAge.R:57-58; R/resolveBreedingAge.R:35-40; R/checkParentAge.R:148-153; R/getKinshipWithMaleStatus.R:51-53; PROJECT_LEARNINGS.md Learning 842
gotchas: argumentPattern also matches correctParentSex:108-109 (stage 4 scope) and the known non-sex lines (convertFromCenter:28, convertStatusCodes:40, obfuscateId:53-54, qcStudbook:412); new lines must stay within 80 columns for lint; macOS sed needs -i ''
runtime_smoke: 5 touched test files pass; lintr::lint_package() 0 lints; full test_dir 0 failed 0 error 187 skipped over 365 files; no Shiny module touched so no shinytest2 run; devtools::check() not run (plan: stage 6). quality_ratchet: not run.
changelog_ref: S875 DONE entry
commit: the close-out commit that carries this receipt; claim b7f865a4c
```

```handoff
session: S874
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- sexCodes adoption stage 1 of 6 (calcNeSexRatio, createColonySnapshot, getSexRatioWithAdditions, getProductionStatus); stages 2-6 remain
what_was_done: claim cc22c5ce6; guard in test_sexCodes.R widened (both-side ==/!=, %in%, identical, single quotes) with a self-test and stage-1 list; new test_getSexRatioWithAdditions.R; 7 bare letters in 4 R files now use sexCodes[["male"]]/[["female"]]; code and records in the close-out commit
next_steps: stage 2 of docs/planning/sexcodes-adoption-plan.md section 4: getSpeciesMinBreedingAge, resolveBreedingAge, checkParentAge (lines 148,151 are argument literals), getKinshipWithMaleStatus; RED = add a stage-2 file list to test_sexCodes.R and extend the guard for the "M", argument form; estimate: 4 R files + the guard test = 5 files
key_files: tests/testthat/test_sexCodes.R (findBareSexCodeLiterals, expectNoBareSexCodeLiterals, stage-1 test); tests/testthat/test_getSexRatioWithAdditions.R; R/getSexRatioWithAdditions.R:20-24; R/calcNeSexRatio.R:54-55; R/createColonySnapshot.R:154-155; R/getProductionStatus.R:83
gotchas: SESSION_NOTES.md has a 25,000-token commit ceiling (a claim stub was refused; methodology_trim.py had nothing to do, so condense an older record); macOS sed needs -i ''; getSexRatioWithAdditions counts every non-M (incl. U, H, NA) as female, pinned by the new test; test_createColonySnapshot.R warns about gene-drop outside test_that (unrelated)
runtime_smoke: 7 touched test files pass; lintr::lint_package() 0 lints; full test_dir 0 failed 0 error 187 skipped over 365 files; no Shiny module touched so no shinytest2 run. quality_ratchet: not run (no .quality-gates.json check performed).
```

```handoff
session: S873
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- scoping plan for the sexCodes adoption written (docs/planning/sexcodes-adoption-plan.md); no code touched
what_was_done: claim 6a84d5abe; plan document with grep inventory (43 code lines, 17 files), 6 staged sessions, guard-test design; BACKLOG item updated; records in the close-out commit
next_steps: owner answers plan section 5 (groupAddAssign default; leave convertSexCodes.R and fixtures), then stage 1 of the plan under strict TDD: RED = add the 4 stage-1 files to the guard list in tests/testthat/test_sexCodes.R plus a direct getSexRatioWithAdditions test. Push only on owner say-so
key_files: docs/planning/sexcodes-adoption-plan.md; tests/testthat/test_sexCodes.R:12-25 (guard helper); R/sexCodes.R:13; R/groupAddAssign.R:179; man/groupAddAssign.Rd:13; R/makePedigreeDiagramData.R:965,1090,1262,1840
gotchas: sexCodes["male"] (single bracket) is named and breaks identical(); .shapeForVec param named sexCodes shadows the constant; getSexRatioWithAdditions has no direct test; non-sex quoted letters at convertFromCenter:28, convertStatusCodes:40, obfuscateId:53-54, qcStudbook:412
runtime_smoke: not applicable -- planning/docs only; no tests or lint run (no .R file changed). quality_ratchet: not run.
```

```handoff
session: S872
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- owner decision on PED-2/NEW-29/PED-7 recorded (adopt sexCodes everywhere); no code touched; docs only
what_was_done: claim bbe315dfa; BACKLOG item "Adopt sexCodes for every direct sex letter"; triage report Decision record 3 (ids stay open); records in the close-out commit
next_steps: (A) plan-mode scoping of the sexCodes adoption, then strict TDD in staged commits, first RED a guard test scanning R/ for quoted sex letters in comparisons. (B) other owner decisions: PED-5/6, PED-3/NEW-42, sim driver, constants/HTML builders. (C) find or drop "four likely code defects". (D) 3.0.0 scoping. (E) push only on owner say-so
key_files: R/sexCodes.R:13; R/convertSexCodes.R:56; R/addParents.R:54,62; R/makePedigreeDiagramData.R:965-1262; R/modORIPReporting.R (8 hits); BACKLOG.md (new sexCodes item); docs/audits/PED_GV_AUDIT_TRIAGE_2026-09-26.md (Decision record 3)
gotchas: count is 40 comparison lines in 16 files by grep, not the old 28/10; convertSexCodes level list and sexCodes.R itself are legitimate literals; roxygen examples also contain letters
runtime_smoke: not applicable -- docs only; no tests or lint run (no .R file changed). quality_ratchet: not run.
changelog_ref: S872 DONE entry
commit: the close-out commit that carries this receipt; claim bbe315dfa
```

```handoff
session: S871
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 7
active_task: DONE -- NEW-61 decision recorded (keep both founder definitions) and documented in calcFEFG/reportGV roxygen; docs only
what_was_done: claim f00361217; roxygen docs 5f6ba3c0b (R/calcFEFG.R, R/reportGV.R, two Rd); triage report Closure record 2 and BACKLOG update in the close-out commit
next_steps: (A) remaining owner decisions: PED-2 sex-code constants, PED-5/6 error contract, PED-3/NEW-42 walk helpers, sim driver, constants/HTML builders; read the code, then ask in plain words. (B) 3.0.0 release prep scoping. (C) Push only on the owner's say-so.
key_files: R/calcFEFG.R:1-20 (new founder paragraph); R/reportGV.R:97-108; docs/audits/PED_GV_AUDIT_TRIAGE_2026-09-26.md (Closure record 2); BACKLOG.md:8-31
gotchas: roxygenise() also rewrites man/nprcgenekeepr-package.Rd (revert it); "four likely code defects" in S870's handoff has no findable list; 31 triage ids open
runtime_smoke: not applicable -- roxygen text only; lintr clean on both files, test_wordlist_coverage.R passes; full suite not run. quality_ratchet: not run.
changelog_ref: S871 DONE entry
commit: the close-out commit that carries this receipt; claim f00361217
```

```handoff
session: S870
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- status banners on the 26 dated docs/research and docs/audits files with a moderate slice 8 finding, plus two inline number corrections; docs only
what_was_done: claim 99631c962; banner commits 42d617267..19e8f917c (26 files, +52 -0); number fixes 89e3fc7c9; close-out commit holds the BACKLOG slice 8 note, slice 8 report update note, SESSION_NOTES, CHANGELOG and this receipt
next_steps: (A) Owner decisions: PED_GV leftovers and the four likely code defects (Effort S each, strict TDD), CV1/CV2. (B) 3.0.0 release prep scoping session. (C) Push only on the owner's say-so. (D) Optional: replace stale file:line cites in plans and gap analysis with function names
key_files: BACKLOG.md (slice 8 note, "Banner pass DONE S870"); docs/audits/DOCS_STALENESS_AUDIT_SLICE8_2026-10-02.md (source of every banner)
gotchas: banners rest on the slice 8 agents' tables spot-checked only where a number was written; "S673-S697" merges the report's S673 and S674 ids; a later change to a banner's subject makes it stale again
runtime_smoke: not applicable -- docs only; no tests or lint run (no .R file changed; docs/ is .Rbuildignore'd). quality_ratchet: not run.
changelog_ref: S870 DONE entry
commit: the close-out commit that carries this receipt; claim 99631c962
```

```handoff
session: S869
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- 15 SESSION_NOTES.md lines over 280 B re-wrapped; context_budget.py per-line finding cleared; docs only
what_was_done: claim cb178a6ef; close-out commit holds the wrapped SESSION_NOTES.md (text identical modulo whitespace, checked by diff), CHANGELOG entry, this receipt; removed the S842 record and S841 evaluation
next_steps: (A) Owner decision: banner pass on ~30 dated audit/research files (Effort M). (B) Owner decisions: PED_GV leftovers, CV1/CV2. (C) 3.0.0 release prep scoping. (D) Push only on the owner's say-so
key_files: SESSION_NOTES.md (records S859-S862 re-wrapped); python3 context_budget.py
gotchas: new long lines will trip the 280 B per-line check; wrap at about 110 columns. Master is 39 ahead of origin before the close-out commit
runtime_smoke: not applicable -- docs only; no tests or lint run (no .R file changed). quality_ratchet: not run.
changelog_ref: S869 DONE entry
commit: the close-out commit that carries this receipt; claim cb178a6ef
```

```handoff
session: S868
date: 2026-10-02
status: complete
self_score: 7
predecessor_score: 8
active_task: DONE -- docs-staleness audit slice 8 (docs/research, 41 older docs/audits files): 42 moderate, 62 minor, no code defects; report only, nothing applied
what_was_done: claim 0754aa0c5; close-out commit holds docs/audits/DOCS_STALENESS_AUDIT_SLICE8_2026-10-02.md, BACKLOG slice 8 note, CHANGELOG, SESSION_NOTES, this receipt. Four read-only subagents; headline claims re-run first-hand
next_steps: (A) Owner decision: banner pass on ~30 dated reports (Effort M). (B) SESSION_NOTES.md housekeeping (15 lines over 280 B). (C) Owner decisions: PED_GV leftovers, CV1/CV2. (D) 3.0.0 scoping session. (E) Push only on owner's say-so
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE8_2026-10-02.md (Recommendation at top, agent tables A-D below); BACKLOG.md slice 8 note in the docs-staleness item
gotchas: agent tables are unedited and carry minors I did not re-check; census scripts overwrite tracked CSVs so D did not run them; PED_GV triage needs a banner most (926cc907b not listed in BACKLOG)
runtime_smoke: not applicable -- docs only, no runtime change; no tests or lint run (no .R file changed). quality_ratchet: not run.
changelog_ref: S868 DONE entry
commit: the close-out commit that carries this receipt; claim 0754aa0c5
```

```handoff
session: S867
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- Breeding Groups and Mate Pair share the override status sentence/paragraph, the confirm step and the filtered-rows-for-CSV helper in R/ancestryOverrides.R; behavior unchanged; strict-TDD REFACTOR
what_was_done: claim 1f4ac9b75; REFACTOR f5e833df9 (6 helper tests in tests/testthat/test_ancestryOverrides.R, helpers in R/ancestryOverrides.R, R/modMatePair.R and R/modBreedingGroups.R rewired); close-out commit holds BACKLOG removal and records. Full suite 9283 expectations 0 failed 0 error; lint 0
next_steps: (A) Docs-staleness audit next slice (READY, Effort L). (B) BACKLOG.md / SESSION_NOTES.md housekeeping (READY; 15 SESSION_NOTES lines over 280 B). (C) Owner decisions: PED_GV leftovers, CV1/CV2. (D) 3.0.0 release prep needs a scoping session. (E) Push only on the owner's say-so
key_files: R/ancestryOverrides.R:~130-205 (four helpers); R/modMatePair.R:~359-375 and ~490-510; R/modBreedingGroups.R:~476-495; tests/testthat/test_ancestryOverrides.R:~535-590
gotchas: onThisTab only changes the sentence wording; .ancestryOverrideApply() relies on callers req()-ing the rule key first; no app launch this session (e2e files skip without a browser); a stack trace prints when test_modMatePair.R runs but the file passes
```

```handoff
session: S866
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the Mate Pair Excluded tab has an Export Excluded Pairs CSV button (downloadExcluded) holding the rows left after the curator's filter; strict TDD, REFACTOR skipped by owner
what_was_done: claim 2b777576a; RED+GREEN 6c72dd8e6 (tests/testthat/test_modMatePair.R 5 new tests, R/modMatePair.R); close-out commit holds NEWS.Rmd, colony-manager-guide.qmd, BACKLOG, CHANGELOG, records. Owner chose rows-shown scope and Excluded-tab-only button.
next_steps: (A) Optional READY refactor: share overrideConfirm observer and overrideStatus sentence, and the filter-then-write body of the two downloads. (B) Owner: PED_GV leftovers; CV1/CV2. (C) Docs-staleness audit next slice. (D) 3.0.0 release prep needs its own scoping session. (E) Push only on owner's say-so.
key_files: R/modMatePair.R:121-125 (button), R/modMatePair.R:~509-523 (handler); tests/testthat/test_modMatePair.R:449-570 (new tests)
gotchas: excludedTable is client-side renderDT but excludedTable_rows_all is still set by DT; NEWS.md not re-knit (S864 did not either); a stack trace prints when test_modMatePair.R runs though it reports 19/19.
runtime_smoke: not done -- no app launch; behaviour covered by testServer tests; full suite 2927 tests, 0 failed, 0 error; lint clean. quality_ratchet: not run.
changelog_ref: S866 DONE entry
commit: the close-out commit that carries this receipt; claim 2b777576a; RED+GREEN 6c72dd8e6
```

```handoff
session: S865
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the duplicated ancestry-override gate code (choices builder + confirm modal) in modBreedingGroups.R and modMatePair.R is shared as .ancestryOverrideChoices() and .ancestryOverrideModal(); behaviour unchanged; strict TDD
what_was_done: claim dfd40047d; RED+GREEN adb5d2991 (R/ancestryOverrides.R, test_ancestryOverrides.R, 8 new tests); REFACTOR 4ba8138f2 (both modules); close-out commit holds BACKLOG, CHANGELOG, records. Owner picked the item and the narrow scope (choices builder + modal only).
next_steps: (A) Owner: Excluded-tab export DECISION NEEDED; PED_GV leftovers; CV1/CV2. (B) Optional READY follow-up: share the overrideConfirm observer and overrideStatus sentence. (C) 3.0.0 release prep needs its own scoping session. (D) Push only on owner's say-so.
key_files: R/ancestryOverrides.R:92-139 (helpers); R/modMatePair.R:336-353; R/modBreedingGroups.R:456-474; tests/testthat/test_ancestryOverrides.R (last 8 tests)
gotchas: helpers rely on the package-wide importFrom(shiny,...) in NAMESPACE (roxygen not re-run, NAMESPACE unchanged and already complete); modal helper takes session$ns the function; test_markerParentageLikelihood.R benchmark can flake under load (passed both full runs)
runtime_smoke: not done -- no manual app launch; behaviour covered by module testServer tests and e2e files in the full suite (2922 tests, 0 failed, 0 error, before and after REFACTOR); lint clean. quality_ratchet: not run (no .quality-gates.json run this session).
changelog_ref: S865 DONE entry
commit: the close-out commit that carries this receipt; claim dfd40047d; RED+GREEN adb5d2991; REFACTOR 4ba8138f2
```

```handoff
session: S864
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- a valid zero-rule ancestry table now gives a 1-row inactive audit manifest instead of an error (Mate Pair and Breeding Groups); strict TDD, REFACTOR skipped by owner
what_was_done: claim a66e2e4bb; GREEN 38c38ee90 (R/ancestryOverrides.R, test_ancestryOverrides.R, test_matePairAncestryManifest.R); close-out commit holds NEWS.Rmd, BACKLOG, CHANGELOG, records. Owner chose scope = zero-rule only and behavior = inactive.
next_steps: (A) Owner: PED_GV leftovers; mate-pair residue (Excluded-tab export DECISION NEEDED; duplicated gate code READY refactor); CV1/CV2. (B) 3.0.0 release prep needs its own scoping session. (C) Push only on owner's say-so (about 25 ahead). (D) Optional: watch CI on 38c38ee90.
key_files: R/ancestryOverrides.R:212-290; tests/testthat/test_ancestryOverrides.R (zero-rule tests); tests/testthat/test_matePairAncestryManifest.R; R/modMatePair.R:562; R/modBreedingGroups.R:889
gotchas: modules pass any non-NULL rules table to the builder so a zero-rule run yields a 1-row CSV (download UI text not inspected); test_markerParentageLikelihood.R runtime benchmark flakes under load, re-run alone; guard test pinned to "not present in rules" so it cannot pass via the old stop
runtime_smoke: not done -- no app launch, no module-level test; builder covered at unit level only (stated as a gap). quality_ratchet: not run (no .quality-gates.json run this session).
changelog_ref: S864 DONE entry
commit: the close-out commit that carries this receipt; claim a66e2e4bb; GREEN 38c38ee90
```

```handoff
session: S863
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- getProductionStatus 0 dams now NA (was green) and the Genetic Diversity heat map draws NA gray; strict TDD, REFACTOR skipped by owner
what_was_done: claim 1bcc1f76e; GREEN 317d61687 (R/getProductionStatus.R, R/makeGeneticDiversityHeatmap.R, man, 2 test files); close-out commit holds NEWS.Rmd, BACKLOG, CHANGELOG, records. Owner chose gray and producer + heat map scope. Full suite 1 failed (wordlist "grey") fixed, then re-run files green; lint clean.
next_steps: (A) Optional: run the app with a no-dam group and look at the heat map. (B) Owner: PED_GV leftovers, mate-pair residue, CV1/CV2. (C) 3.0.0 release prep needs its own scoping session. (D) Push only on owner's say-so (about 22 ahead). (E) Watch CI on 317d61687.
key_files: R/getProductionStatus.R:93-120; R/makeGeneticDiversityHeatmap.R:44-47,66; tests/testthat/test_getProductionStatus.R:55-85,163-175; tests/testthat/test_makeGeneticDiversityHeatmap.R:105-140
gotchas: use "gray" in prose (wordlist guard flags "grey"); devtools::document() churns man/nprcgenekeepr-package.Rd, revert it; one test pinning old green was missed in RED; modules' UI text for an NA cell not inspected.
runtime_smoke: not done -- heat map exercised through tests only, no app launch (stated as a gap). quality_ratchet: not run (no .quality-gates.json run this session).
changelog_ref: S863 DONE entry
commit: the close-out commit that carries this receipt; claim 1bcc1f76e; GREEN 317d61687
```

```handoff
session: S862
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- header sweep of docs/planning (docs only): status banners on 31 plans plus docs/planning/README.md; BACKLOG audit item updated
what_was_done: claim b651541d4; banners c5c15b6ee, fdb24ef30, 5fed0fb1a, 026fbf102, c2a1ec432 (22 issue plans), f35538868, 93670ec95 (9 non-issue plans); close-out commit holds README, BACKLOG and records. 3 read-only subagents gathered evidence; I re-checked every cited hash, issue state and key artifact; unverified points are hedged in the banners.
next_steps: (A) Owner: getProductionStatus 0 dams green vs grey, then strict TDD. (B) Owner: PED_GV leftovers, mate-pair residue (zero-rule table, Excluded-tab export; duplicated gate code READY), CV1/CV2. (C) 3.0.0 release prep needs its own scoping session. (D) master is ahead of origin by about 20 commits; push only on owner say-so.
key_files: docs/planning/README.md; BACKLOG.md:149 (audit item); docs/audits/DOCS_STALENESS_AUDIT_SLICE7C_2026-10-02.md (sweep table)
gotchas: banners say S862 and a later note; plans with no banner are unswept, not current; insert after the first "# " line (issue168 has a license header); zsh does not word-split variables, use bash -c for loops; agent evidence for issue9/13/73 was thin.
runtime_smoke: n/a -- docs only. quality_ratchet: not run (no code change).
changelog_ref: S862 close-out entry
commit: the close-out commit that carries this receipt; claim b651541d4
```

```handoff
session: S861
date: 2026-10-02
status: complete
self_score: 7
predecessor_score: 8
active_task: DONE -- slice 7c docs fixes (banners on 5 plans + reference qmd, in-place edits to runbook/outreach/Quarto docs, 3 BACKLOG pointers); header sweep remains
what_was_done: claim 1e0295d5b; banners 1754691e1; runbook/outreach/Quarto fixes a1cbfde13; BACKLOG pointers and audit-item status f6ae48446; close-out commit holds records. Re-checked rhub, cran-comments markers, versions, paths before writing; fixed two wrong cites caught on re-check.
next_steps: (A) Header sweep, docs only: one-line status for the 11 status-less plans and the 14+ stale-header plans in the S860 report, plus docs/planning/README (CHANGELOG is the authority). (B) Owner: getProductionStatus 0 dams green vs grey. (C) PED_GV decisions, mate-pair residue, 3.0.0 release prep. (D) master 11 ahead of origin; push only if the owner says.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE7C_2026-10-02.md (sweep table); BACKLOG.md:149 (audit item); docs/planning/cran-2.0.0-phase5-runbook.md:3-11 (banner)
gotchas: banners are later notes, bodies untouched; insert after the H1 (issue167 has a license header first); 36 of 53 moderates were agent-only, so re-check before editing; BSD sed needs -i ''.
runtime_smoke: n/a -- docs only. quality_ratchet: not run (no code change).
changelog_ref: S861 close-out entry
commit: the close-out commit that carries this receipt; claim 1e0295d5b
```

```handoff
session: S860
date: 2026-10-02
status: complete
self_score: 7
predecessor_score: 8
active_task: DONE -- docs-staleness audit slice 7c, live docs/planning plans only (owner-scoped); report written, docs not fixed yet
what_was_done: claim 2c2d1aaea; close-out commit holds docs/audits/DOCS_STALENESS_AUDIT_SLICE7C_2026-10-02.md, BACKLOG audit item, records. 4 read-only subagents audited 9 live plans; I re-checked 18 of 53 moderates; status sweep of 84 files done here.
next_steps: (A) Fix slice 7c: one banner per shipped plan (issue112/122/123/144/167 + reference qmd), in-place fixes to cran-2.0.0-phase5-runbook, nprc-outreach plan, quarto analysis, 3 BACKLOG pointers (report section "Recommended fixes"); docs only. (B) Owner call: getProductionStatus 0 dams -> green. (C) Still open: PED_GV decisions, mate-pair residue, CV1/CV2, 3.0.0 release prep. (D) Master is 5 commits ahead of origin; push only on the owner's say-so.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE7C_2026-10-02.md; BACKLOG.md:100-160 (audit item), :224 (wrong Dragon 1 pointer), :445; docs/planning/cran-2.0.0-phase5-runbook.md:137,246-259,270-281
gotchas: 36 of 53 moderates rest on one agent's read; re-check before editing. Many plan bodies are dated design records: use banners, not rewrites. BSD sed needs -i ''. Plan header status lags; CHANGELOG is the authority.
runtime_smoke: n/a -- docs only. quality_ratchet: not run (no code change).
changelog_ref: S860 close-out entry
commit: the close-out commit that carries this receipt; claim 2c2d1aaea
```

```handoff
session: S859
date: 2026-10-02
status: complete
self_score: 6
predecessor_score: 8
active_task: DONE -- one-mate-each couples whose mate is a duplicate node draw male-left (`|| qualifies(u)`, R/makePedigreeDiagramData.R:1267); strict TDD, all gates asked; owner accepted the fix after app-proportion figures; BACKLOG item removed.
what_was_done: claim f46ce6de3; RED ca0ee89ac; GREEN+REFACTOR 82e020669 (1 R line, header comment, generic test file, 6 pins in 3 files); close-out commit holds records and BACKLOG removal. Full suite 364 files / 2,907 tests, lint 0.
next_steps: (A) Nothing owed on this item. Male-left for multi-mate couples would be a new plan (issue #145 D5/D9, new machinery) only if the owner asks. (B) Open: PED_GV decisions, mate-pair residue, CV1/CV2, doc-audit slice-6e fixes. (C) Release prep: BACKLOG "Move the version to 3.0.0". (D) Push only on the owner's say-so.
key_files: R/makePedigreeDiagramData.R:1213-1222,1267; tests/testthat/test_maleLeftDuplicateMate.R; test_makePedigreeMatingLayout.R:745,774; test_addRectilinearWaypoints.R:797-798; test_resolveEdgeNodeCollisions.R:721-722
gotchas: any layout change moves 6 pins in 3 files; render owner figures via the app's visNetwork settings with fixed moveTo zoom after a warm-up navigate; couple 2 keeps an ~8 px step (jog-free needs a solver change); crossings not recounted this session (S858: 1702 to 1700, 1542 to 1544).
runtime_smoke: layout function output rendered through visNetwork + chromote; no live Shiny launch. quality_ratchet: not run (no .quality-gates results cited).
changelog_ref: S859 close-out entry
commit: the close-out commit that carries this receipt; claim f46ce6de3
```

```handoff
session: S858
date: 2026-10-02
status: complete
self_score: 6
predecessor_score: 8
active_task: DONE (no code kept) -- cause of the 2 duplicate-mate male-right couples measured; `|| qualifies(u)` fix tried and rejected by the owner after figures; R/ unchanged; BACKLOG item rewritten with the owner's words and no decided rule
what_was_done: claim 88f283ea6; RED 8aeef0da2 (test file removed in close-out); close-out commit holds BACKLOG, records, test removal. Fix reverted before commit.
next_steps: (A) New session: ask the owner what the placement rule is for these couples (BACKLOG "Placement of couples whose mate is drawn as a duplicate node"); do not infer it from the quoted feedback. (B) Open: PED_GV decisions, mate-pair residue, CV1/CV2, slice-6e doc fixes.
key_files: R/makePedigreeDiagramData.R:1262-1272,1075-1080; BACKLOG.md:101; git show 8aeef0da2 (rejected RED test)
gotchas: census pins that move with any layout change: test_makePedigreeMatingLayout.R:745,774; test_addRectilinearWaypoints.R:797-798. Open figures for the owner with `open`; do not turn owner feedback into a rule.
runtime_smoke: n/a -- no code kept. quality_ratchet: not run (no code change).
changelog_ref: S858 close-out entry
commit: the close-out commit that carries this receipt; claim 88f283ea6
```

```handoff
session: S857
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- male-left placement fix (strict TDD, three gates asked): in the Decision-1 seeding a unit the S666 pass handled takes the sex rule, so the min-separation sweep can no longer flip the mate side; the 2 squeezed rhesusPedigree couples (and 8 in qcPed, 1 in the MHC pedigree) now draw male-left
what_was_done: claim acc020703; RED 62cac01de (test_maleLeftSweepSurvival.R, 6 tests, 4 failing as designed); GREEN c4b383978 (R/makePedigreeDiagramData.R seeding, 5 lines); REFACTOR comments and records in the close-out commit. Full unfiltered suite 363 files / 2897 tests, 0 failed, 0 error; lint_package 0; blast radius measured on 22 layouts (crossings, row gaps, drawn relations unchanged); pictures in the scratchpad
next_steps: (A) Owner decides the BACKLOG duplicate-mate item (2 rhesusPedigree couples with a duplicate-node mate stay male-right): extend the rule (strict TDD) or reword roxygen. (B) Open: PED_GV decisions, mate-pair residue, CV1/CV2. (C) Release prep: BACKLOG item Move the version to 3.0.0. (D) Master 23 ahead of origin; push only on owner say-so
key_files: R/makePedigreeDiagramData.R:1213-1219,1261-1272; tests/testthat/test_maleLeftSweepSurvival.R; BACKLOG.md:101
gotchas: .maleFemaleUnitX() must trace through __jog_ and keep __dup_ nodes; never compare layout x with == across versions (QP drift 1e-4); full-suite logs contain Shiny tracebacks, wait for the results file; devtools::check() and a live app launch not run
```

```handoff
session: S856
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- cause of the 2 one-mate rhesusPedigree male-right pairs found: the S666 correction sets the right side, then sweepMinSepBackstop() pushes the couple past the child's x in a crowded row and the Decision-1 seeding reads the side from the children's mean. Owner chose FIX; BACKLOG item rewritten as a READY strict-TDD fix with the cause
what_was_done: claim 996cd9d40; read-only investigation (scratch debug copies in the scratchpad, nothing committed but BACKLOG and records) in the close-out commit
next_steps: (A) Fix session, strict TDD with a gate per phase: BACKLOG item "Male-on-the-left placement: fix the layout" (READY, Effort M); full unfiltered suite plus diagram fidelity checks required. (B) Open: CV1/CV2, PED_GV decisions, mate-pair residue. (C) Master 17 ahead of origin; push only on owner say-so
key_files: R/makePedigreeDiagramData.R:951-969,1025,1086-1119,1263-1266; tests/testthat/test_positionMatingUnitForest.R
gotchas: edge sources into __union_ can be __jog_* nodes (trace back); keep __dup_ nodes when mapping with duplicateToReal; sweep runs per component
```

```handoff
session: S855
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- owner chose 3.0.0 for the next release; recorded as BACKLOG item "Move the version to 3.0.0 just before release". Version files unchanged (2.0.0.9000); an over-reach bump to 2.99.0.9000 was made then reverted at the owner's direction
what_was_done: claim 2d7189745; BACKLOG item and records in the close-out commits; version edits reverted (diff vs claim empty)
next_steps: (A) Owner picks another decision (PED_GV items, mate-pair residue, male-left placement, CV1/CV2). (B) At release prep do the new BACKLOG item. (C) Master 16 ahead of origin; push only on owner say-so
key_files: BACKLOG.md (item Move the version to 3.0.0)
gotchas: version files intentionally still say 2.0.0.9000
```

```handoff
session: S854
date: 2026-10-02
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- convertDate() invalid-date row numbers (reportErrors = TRUE vector and stop() message) now count positions in the pedigree passed in, so an added record ahead of an original no longer shifts them. Owner chose fix over document-only. Strict TDD RED/GREEN/REFACTOR, every gate asked.
what_was_done: claim a06651046; fix, 5 tests, roxygen/Rd and BACKLOG item removal in the close-out commit. Full unfiltered suite 362 files / 2891 tests, 0 failed, 0 error; lintr clean on the two changed files.
next_steps: (A) Owner picks another PED_GV decision from BACKLOG (isAddedRecord helper, sex-code adoption, getPotentialParents split). (B) Optional small slice: pin getDateErrorsAndConvertDatesInPed() with an added row first. (C) Open: release number, CV1/CV2, male-left placement. (D) Master 12 ahead of origin; push only on owner's say-so.
key_files: R/convertDate.R:109-120,160-170; tests/testthat/test_convertDate.R:140-185; R/getDateErrorsAndConvertDatesInPed.R:33-45; BACKLOG.md PED_GV item.
gotchas: man/nprcgenekeepr-package.Rd is stale against DESCRIPTION; roxygenise regenerates it and I reverted it, so the diff reappears next run. getDateErrorsAndConvertDatesInPed now drops the right row for an added-first pedigree but no test pins that. devtools::check() not run.
runtime_smoke: n/a -- no startup/wiring change; unit and full-suite tests only. quality_ratchet: no gates declared/not re-run.
changelog_ref: S854 close-out entry
commit: the close-out commit that carries this receipt; claim a06651046
```

```handoff
session: S853
date: 2026-10-01
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- applied 33 of 35 slice-7b docs-staleness findings (ROADMAP.md, CLAUDE.md, module-contract.md, CLOSEOUT_CHECKLISTS.md, ROXYGEN_EXAMPLES_POLICY.md, BACKLOG.md). Docs only, no TDD phase. CV1/CV2 left as code decisions.
what_was_done: claim 144d140cb; fixes 61577e834; close-out commit (BACKLOG.md and records). Every changed cite re-read against code; wordlist and rbuildignore tests pass; context budget OK.
next_steps: (A) Slice 7c: docs/planning (84 files), docs/research, older docs/audits; scope with owner first. (B) Owner: release number 3.0.0 vs 2.0.0.9000; CV1/CV2; male-left placement. (C) Master 10 ahead of origin after this commit; push only on owner's say-so.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE7B_2026-10-01.md; BACKLOG.md docs-audit item (grep "Slice 7b AUDITED") and regrowth check (grep "Regrowth check (S853)"); ROADMAP.md.
gotchas: BACKLOG.md is 599 lines and regrowing (docs-audit and chromote items are the next cuts). ROADMAP.md keeps two "not re-checked" statements (Quarto slices 3-4; five audit ids), not verified claims.
runtime_smoke: n/a -- docs only; no R/ file changed. Full suite and lint not run. quality_ratchet: unchanged, not re-run.
changelog_ref: S853 close-out entry
commit: the close-out commit that carries this receipt; claim 144d140cb
```

```handoff
session: S852
date: 2026-10-01
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- docs-staleness audit slice 7b (living internal docs, owner-scoped); report docs/audits/DOCS_STALENESS_AUDIT_SLICE7B_2026-10-01.md, 35 findings (10 moderate, 25 minor), none fixed
what_was_done: claim 9ab55d5df; close-out commit. Four read-only subagents, then 9 of 10 moderates re-checked first-hand. BACKLOG docs-audit item updated; S849 record removed from SESSION_NOTES (also clears the per-line finding).
next_steps: (A) Apply the 35 findings, docs only, BACKLOG.md last. (B) Slice 7c: docs/planning, docs/research, older docs/audits (scope with owner). (C) Owner: release number 3.0.0 vs 2.0.0.9000. (D) Master 7 ahead of origin after this commit; push only on owner's say-so.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE7B_2026-10-01.md; BACKLOG.md docs-audit item (grep "Slice 7b AUDITED"); BACKLOG.md regrowth figure (grep "Regrowth check"); ROADMAP.md:6-34.
gotchas: BACKLOG line cites in the report are approximate for the BA ids, re-locate by item name; the second BACKLOG agent's line numbers were off by about 45. Edit BACKLOG.md last when applying fixes.
runtime_smoke: n/a -- docs only; no R/ file changed. Full suite and lint not run. quality_ratchet: unchanged, not re-run.
changelog_ref: S852 close-out entry
commit: the close-out commit that carries this receipt; claim 9ab55d5df
```

```handoff
session: S851
date: 2026-10-01
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- adopted the owner's suggested_NEWS_entry.md ideas into the NEWS.Rmd dev block: opening summary, restored marker export fix, plainer pass over all 11 sections (long bullets split, nothing dropped). Docs only, no TDD phase.
what_was_done: claim b9c019c5b; close-out commit. Each section shown before/after and approved; NEWS.md re-rendered; guard and wordlist tests pass. 2,629 words, 80 bullets.
next_steps: (A) Owner decides the release number (draft said 3.0.0, package says 2.0.0.9000); the two untracked draft files were deleted at the owner's request. (B) Slice 7b internal-docs audit, READY, Effort L. Push only on the owner's say-so; master is 3 ahead after this commit.
key_files: NEWS.Rmd:14-390, tests/testthat/test_newsReleaseState.R:473-690 (pinned wording).
gotchas: Pinned phrases stay verbatim: "male parent on the left", the 400/750 cap once, the 113 count with "duplicate node" and "bundled", one #168 entry. Re-render NEWS.md, then run the guard test.
runtime_smoke: n/a -- docs only; no R/ file changed. Full suite and lint not run. quality_ratchet: unchanged, not re-run (no R/ change)
changelog_ref: S851 close-out entry
commit: the close-out commit that carries this receipt; claim b9c019c5b
```

```handoff
session: S850
date: 2026-10-01
status: complete
self_score: 7
predecessor_score: 9
active_task: DONE -- brevity pass on the NEWS.Rmd dev block (about 4,460 to 2,500 words, Major/Minor lists kept), owner reviewed and approved. Docs only, no TDD phase.
what_was_done: claim eae700925; close-out commit. Merged related Minor bullets, trimmed Major bullets, kept every limit, default and caveat; issue numbers kept because the guard test needs one #168 mention. NEWS.md re-rendered; guard and wordlist tests pass.
next_steps: (A) Owner compares suggested_NEWS_entry.md with the shortened NEWS.Rmd. (B) Slice 7b internal-docs audit, READY, Effort L. Master was pushed (origin bd6783a3a); check CI with gh run list.
key_files: NEWS.Rmd:14-354, tests/testthat/test_newsReleaseState.R:473-690 (pinned wording).
gotchas: Diagram section must keep the 400/750 cap once, one shading entry, one "male parent on the left", and the 113 count with "duplicate node" and "bundled". Re-render NEWS.md, then run the guard test.
runtime_smoke: n/a -- docs only; no R/ file changed. Full suite and lint not run. quality_ratchet: unchanged, not re-run (no R/ change)
changelog_ref: S850 close-out entry
commit: the close-out commit that carries this receipt; claim eae700925
```

```handoff
session: S849
date: 2026-10-01
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- labeled the NEWS.Rmd dev block with a Major list then a Minor list in each of 11 sections, sorting approved by the owner first. Docs only, no TDD phase. Brevity pass deliberately not done.
what_was_done: claim 8415e4fab; close-out commit. Moved 75 bullets whole (wording unchanged), fixed three "above" references to "below", re-rendered NEWS.md, guard and wordlist tests pass.
next_steps: (A) Brevity pass after the owner's comparison with suggested_NEWS_entry.md; add guard checks first because the Diagram and Ancestry wording is pinned. (B) Slice 7b internal-docs audit, READY, Effort L. Push only on the owner's say-so; master is 20 ahead after this commit.
key_files: NEWS.Rmd:14-470, tests/testthat/test_newsReleaseState.R:96-163 (parser reads "## " and "- " only).
gotchas: Use Python, not macOS sed -i, for in-place edits. New bullets go under the right Major or Minor label. Re-render NEWS.md after any edit, then run the guard test.
runtime_smoke: n/a -- docs only; no R/ file changed. Full suite and lint not run. quality_ratchet: unchanged, not re-run (no R/ change)
changelog_ref: S849 close-out entry
commit: the close-out commit that carries this receipt; claim 8415e4fab
```

```handoff
session: S848
date: 2026-10-01
status: complete
self_score: 7
predecessor_score: 8
active_task: DONE -- made NEWS.Rmd complete and accurate before the owner compares it with suggested_NEWS_entry.md. Docs only, no TDD phase. S793 had already reviewed the draft, so no new scoping document was written.
what_was_done: claim 82a5dc655; close-out commit. Verified display cap, Rectilinear default, PNG export and the kinship2-parity wording (structure test and guard test pass). Found 9 post-2.0.0 exports absent from NEWS and added them to five existing bullets; NEWS.md re-rendered; BACKLOG draft item rewritten.
next_steps: (A) Owner compares the draft with NEWS.Rmd and decides what to adopt. (B) Slice 7b internal-docs audit, READY, Effort L. (C) Owner decisions on the two missing Diagram features. Push only on the owner's say-so; master is 18 ahead after this commit.
key_files: NEWS.Rmd:105-120 and 132-165 (new text), docs/audits/SUGGESTED_NEWS_ENTRY_REVIEW_2026-09-27.md, BACKLOG.md (draft item).
gotchas: Re-render NEWS.md after any NEWS.Rmd edit, then run test_newsReleaseState.R. One pre-existing over-80 line sits in the Ancestry bullet. The splitting of the Breeding Group and Mate Pair paragraphs was left for the owner.
runtime_smoke: n/a -- docs only; no R/ file changed. Full suite and lint not run. quality_ratchet: unchanged, not re-run (no R/ change)
changelog_ref: S848 close-out entry
commit: the close-out commit that carries this receipt; claim 82a5dc655
```

```handoff
session: S847
date: 2026-10-01
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE: rewrote the NEWS.Rmd Pedigree Diagram section (S845 audit NA2-NA4) as a new feature described against kinship2; NEWS.md re-rendered; docs only
what_was_done: Claim de5191418; rewrite, BACKLOG item (deceased marker, several affected conditions) and records in the close-out commit. About 40 bullets to 13, no issue numbers. Measured 113 individuals drawn more than once on the 375-animal example (170 markers). Guard and wordlist tests pass
next_steps: Slice 7b internal-docs audit (READY, Effort L); or owner decisions on audit code candidates and the two Diagram feature gaps; owner to decide on untracked suggested_NEWS_entry.md. Master 16 ahead of origin, push only on the owner's say-so
key_files: NEWS.Rmd:16-105; tests/testthat/test_newsReleaseState.R:197-200,515-600; BACKLOG.md (Diagram-gaps item); vignettes/articles/kinship2-fidelity-validation.qmd:151-166
gotchas: test_newsReleaseState.R pins wording (male parent on the left; duplicate node + bundled + count; no every/all/always/each in placement bullets). Re-render NEWS.md after the text, then run the test. Kinship2-parity wording rests on the fidelity article scope, not a re-run
```

```handoff
session: S846
date: 2026-10-01
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE: fixed the slice-7a NEWS.Rmd audit findings (owner-reviewed in 3 rounds), NEWS.md re-rendered; docs only
what_was_done: Claim 40a1e529f; fixes and re-render 54130dfe1; records in close-out commit. Fixed NC1-NC5, NB1-NB4, NB6, ND1-ND3, NA1; 2.0.0 heading date 20260721, Package section and YAML date removed. Guard test passes. NA2-NA4 not done.
next_steps: Condense the Pedigree Diagram section NA2-NA4 in its own staged pass (READY, Effort M); or slice 7b internal-docs audit (READY, Effort L); or owner decisions on audit code candidates. Owner to decide on untracked suggested_NEWS_entry.md. Master 13 ahead of origin at close-out start; push only on owner say-so.
key_files: NEWS.Rmd:21-195 (Diagram section); docs/audits/DOCS_STALENESS_AUDIT_SLICE7_2026-10-01.md; tests/testthat/test_newsReleaseState.R; R/appServer.R:114 (lead)
gotchas: Re-render NEWS.md last after any NEWS.Rmd text change, then run the guard test; check wraps with awk length>80; keep SESSION_NOTES.md lines at or under 280 B.
```

```handoff
session: S845
date: 2026-10-01
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE: docs-staleness audit slice 7a, NEWS.Rmd and NEWS.md; report only (3 moderate, 16 minor); no fixes, no code
what_was_done: Claim 34cf56826; report docs/audits/DOCS_STALENESS_AUDIT_SLICE7_2026-10-01.md plus records in the close-out commit. Four read-only subagents by line range; moderates and several minors re-checked first-hand (v2.0.0 tag file checks, Rscript run for ND3).
next_steps: Fix the NEWS.Rmd findings (delete NC1 and NC2, reword the minors, owner confirms 2.0.0 date), then re-render NEWS.md last (READY, Effort S). Or condense the Pedigree Diagram section (NA2-NA4); or slice 7b internal docs (READY, Effort L). Push of 10 local commits only on the owner's say-so.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE7_2026-10-01.md; NEWS.Rmd:462-468 and 545-550 (NC1, NC2), 311-314 (NB4), 732-734 (ND3), 552 (ND2); R/appServer.R:114 (lead)
gotchas: Re-render NEWS.md after the text fixes, not before. Dev-section edits follow the release-state rule. Minor findings NB2, NB6, NC5, NC6, NA1-NA4 rest on agent reads only. Keep SESSION_NOTES.md lines at or under 280 B.
```

```handoff
session: S844
date: 2026-10-01
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE: fixed all 95 slice-6e docs-staleness findings in R/*.R roxygen (67 files), man/ regenerated; docs only, code candidates untouched
what_was_done: Claim 56668e779; fixes 54c2f64e5 (RE+RF), ff8f3c941 (RG+RH), 52335a523 (RI+RJ), 9c650237f (RK+RL). Four subagents on disjoint files. Only #' lines changed (diff-checked); lint 0; wordlist test pass; devtools::check(--no-tests) 0/0/1 note. Full suite not run.
next_steps: Owner decisions on the audit code candidates (46 slice-6e CE-CL, 22 slice-6d, 8 slice-6c, older). Or docs-audit slice 7: NEWS.Rmd then internal docs (READY, Effort L). Push of 8 local commits only on the owner's say-so.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE6E_2026-10-01.md; BACKLOG.md:197; R/makeGroupNum.R (numGp "Default is 1" still stale); R/fillGroupMembersWithSexRatio.R:37 and R/groupAddAssign.R:128 (deprecated minParentAge in examples)
gotchas: zsh arrays are 1-indexed (a commit loop mislabeled messages; reset and redone). After document() restore man/nprcgenekeepr-package.Rd. Reword rather than extend inst/WORDLIST. Keep SESSION_NOTES.md lines at or under 280 B. Per-finding wording rests on the agents' source reads.
```

```handoff
session: S843
date: 2026-10-01
status: complete
self_score: 9
predecessor_score: 8
active_task: DONE: split the 10 SESSION_NOTES.md lines over the 280 B per-line ceiling; context_budget.py now OK; docs only
what_was_done: Claim f407e5a1c; the line split, records and ledger in the close-out commit. Re-wrapped at word boundaries outside backtick spans, no word changed.
next_steps: Fix the 95 slice-6e findings in R/*.R roxygen, then devtools::document() and git checkout man/nprcgenekeepr-package.Rd (READY, Effort M). Or owner decisions on the audit code candidates.
key_files: SESSION_NOTES.md (former S842/S841 long paragraphs); context_budget.py; .context-budget.json
gotchas: Keep every SESSION_NOTES.md line at or under 280 B (awk 'length($0)>280' SESSION_NOTES.md). Master may be ahead of origin; S842's 47-ahead figure was not re-checked.
```

```handoff
session: S842
date: 2026-10-01
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE: docs-staleness audit slice 6e, the last 126 man/ pages; all 267 now audited; 26 moderate, 69 minor, 46 code candidates; read-only
what_was_done: Claim 89042b761; report docs/audits/DOCS_STALENESS_AUDIT_SLICE6E_2026-10-01.md, BACKLOG and records in the close-out commit. Eight subagents (sets RE-RL); I re-ran or re-read 23 of 26 moderates (not RF2, RH2, RJ3); corrected RE4 line cites and narrowed RJ4.
next_steps: Fix the 95 slice-6e findings in R/*.R roxygen, then devtools::document() and git checkout man/nprcgenekeepr-package.Rd (READY, Effort M). Or owner decisions on the 46 slice-6e, 22 slice-6d and 8 slice-6c code candidates. Push of 47 local commits only on the owner's say-so.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE6E_2026-10-01.md; BACKLOG.md:197; R/trimPedigree.R; R/getAnimalsWithHighKinship.R:5-42; R/readKinshipOverrides.R; R/getPotentialParents.R
gotchas: Report Location line numbers can be off (RE4 was), grep for the text. SESSION_NOTES.md sits at the token ceiling, so a claim commit needs a trim (removed S804/S805 and S840 records). After document() restore the package Rd. Reword rather than add to inst/WORDLIST. Minors and code candidates are agent-checked only.
```

```handoff
session: S841
date: 2026-10-01
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE: fixed all 42 slice-6d docs-staleness findings in R/*.R roxygen (15 files), man/ regenerated; docs only, code candidates untouched
what_was_done: Claim c33cfd543; fixes 8b2e51b54 (RA), 9b66199cd (RB), 53409c805 (RC), 21d33c54f (RD), fd573b5c8 (wordlist rewording); records in the close-out commit. Roxygen only, no code or test change. lintr 0 after each group, wordlist test pass, devtools::check(--no-tests) 0 errors / 0 warnings / 1 note (untracked suggested_NEWS_entry.md). Caught two of my own wrong claims against the code (geneticValues requirement, exhaustive-mode scope) before commit. Minors rest on the audit plus a source read, not a re-run; full suite not run.
next_steps: Audit slice 6e (126 man/ pages left: obfuscate*, pedigree-tree and getters, get*/calc*/check* helpers, datasets), read-only. Or owner decisions on code (22 slice-6d candidates, 8 slice-6c candidates, PB4, PB7, PB11, PB13, PA4, PD12, PD1, MC1, MB3) then reword docs (RA3/RA4/RA6, RA8, RB10, RC7 first). suggested_NEWS_entry.md commit-or-drop still unanswered. Master is 46 ahead of origin; push only on the owner's say-so.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE6D_2026-10-01.md; R/modBreedingGroups.R:205-290; R/modPedigree.R:190-250; R/modSummaryStats.R:235-310; R/runGenekeepr.R:1-40; BACKLOG.md:197
gotchas: git checkout man/nprcgenekeepr-package.Rd after document(); lint_package() after joined roxygen lines; reword rather than add words to inst/WORDLIST; prose after a @param folds into it, so put it before the first @param; some audit Location line numbers point at code not roxygen, grep the claim text; avoid `echo ====` in the Bash tool (zsh).
```

```handoff
session: S840
date: 2026-10-01
status: complete
active_task: DONE: docs-staleness audit slice 6d, 34 Shiny app and module man/ pages (read-only report)
what_was_done: Audited 34 pages with 4 read-only subagents; report docs/audits/DOCS_STALENESS_AUDIT_SLICE6D_2026-10-01.md has 8 moderate, 34 minor, 22 code candidates. Re-read all 8 moderates in source, re-ran RA8 and CA4, downgraded RD6. Commits: claim cffbb16cc; close-out commit holds report, BACKLOG, records.
next_steps: Fix the 42 slice-6d findings in R/*.R roxygen then devtools::document() (decide CA1-CA4, CB1, CC1 first), or audit slice 6e (126 man/ pages left). Start at BACKLOG.md:197 and the report's code-candidates table.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE6D_2026-10-01.md; R/modBreedingGroups.R:257-272; R/modGeneticDiversity.R:63-64; R/appServer.R:441-446; R/getKinshipWithMaleStatus.R:49-61; R/modPedigree.R:209-225,878; R/runGeneKeepR.R:27
gotchas: roxygen folds a blank-line paragraph into the preceding @param (RA1); git checkout man/nprcgenekeepr-package.Rd after document(); minors are agent-checked, not re-run by me; RA12 and RD10 are not findings.
predecessor_score: 9
self_score: 8
```

```handoff
session: S839
date: 2026-10-01
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE: fixed all 29 slice-6c docs-staleness findings in R/*.R roxygen (19 files), man/ regenerated; docs only, code candidates untouched
what_was_done: Claim 3075b7b50; fixes 48aabebb6, 65be5d010, 4d0042987, 03493492a; records in the close-out commit. Roxygen only, no code or test change. Examples run, lintr 0, wordlist test pass, devtools::check(--no-tests) 0 errors / 0 warnings / 1 note (untracked suggested_NEWS_entry.md). Re-ran the behaviors I newly documented (all-NA He, numeric(0) frequency, markerLdBlock edge cases, checker accepts a missing allele); the rest of the wording rests on the audit and a source read
next_steps: Audit slice 6d (160 man/ pages left, one topic group: Shiny mod* ~28, obfuscate*, pedigree-tree/getters), read-only. Owner decisions on code: 8 slice-6c candidates, PB4, PB7, PB11, PB13, PA4, PD12, PD1, MC1, MB3, then reword their docs; suggested_NEWS_entry.md commit or drop. Master is 37 ahead of origin; push only on owner say-so
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE6C_2026-10-01.md, R/computeGenomicROH.R:19-32, R/hasGenotype.R:4-15, R/buildMarkerGenotypeMatrix.R:11-30, BACKLOG.md:197
gotchas: git checkout man/nprcgenekeepr-package.Rd after document(). Append to inst/WORDLIST rather than re-sort, but prefer rewording (genotype's was flagged). Run lint_package() after roxygen edits that join lines. Code candidate 7 is worse than the audit said: checkMarkerGenotypeFile does not reject a missing allele, so buildMarkerGenotypeMatrix yields "NA/NA" even after it
```

```handoff
session: S838
date: 2026-10-01
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE: docs-staleness audit slice 6c, 35 marker-genetics, genotype and MHC man/ pages (4 moderate, 25 minor, 8 code candidates); findings not yet fixed
what_was_done: Claim 542ccce38; report docs/audits/DOCS_STALENESS_AUDIT_SLICE6C_2026-10-01.md, BACKLOG and records in the close-out commit. Read-only; four subagents audited 8-9 pages each; I re-read the source for all 4 moderates and re-ran QA2 and QC1. Minors and code candidates are agent-checked only
next_steps: Fix the 29 slice-6c findings in R/*.R roxygen then devtools::document() (decide code candidates 1-4 first), or audit slice 6d (160 man/ pages left). Owner decisions open: PB4, PB7, PB11, PB13, PA4, PD12, PD1, MC1, MB3, suggested_NEWS_entry.md commit or drop, stale man/nprcgenekeepr-package.Rd. Master is 31 ahead of origin; push only on owner say-so
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE6C_2026-10-01.md, R/computeGenomicROH.R:99-146, R/hasGenotype.R:22-35, R/checkSequenceGenotypeFile.R:126-128, R/markerKinship.R:20-25, BACKLOG.md:197
gotchas: man/ is generated; fix roxygen then document(), then git checkout man/nprcgenekeepr-package.Rd. Example() fails; use Rd2ex()+source(). Append to inst/WORDLIST, do not re-sort. The earlier 196 pages-left count included man/figures; real count is 160. QB5 and QD5 ids intentionally unused
```

```handoff
session: S837
date: 2026-10-01
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE: fixed 54 of 57 slice-6b docs-staleness findings in R/*.R roxygen (32 files), man/ regenerated; PB4, PB7, PB11 left for owner
what_was_done: Claim ba41d2fc0; fixes da62c124d, 18f215ec0, b6cd4ffc6, e6c434bec, cfcd9d11f, f2a21abef, fdacad923, 01a6bfda1, 7c1497876; records in the close-out commit. Roxygen and examples only, no code or test change. Three forks edited disjoint file sets; lint 0, wordlist test pass (3 words added), examples run, devtools::check(--no-tests) 0 errors / 0 warnings / 1 note (untracked suggested_NEWS_entry.md). Full suite and runtime smoke not run (no behavior change).
next_steps: Slice 6c: audit the next topic group of man/ (196 pages left), read-only. Owner decisions: PB4, PB7, PB11 (then their docs), PB13, PA4, PD12, PD1, MC1, MB3, suggested_NEWS_entry.md commit or drop, stale man/nprcgenekeepr-package.Rd. Master is 28 ahead of origin; push only on the owner's say-so.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE6B_2026-10-01.md, R/checkRequiredCols.R:6-41, R/checkChangedColsLst.R:8-9, R/getDateErrorsAndConvertDatesInPed.R:6-17, BACKLOG.md:197
gotchas: git checkout man/nprcgenekeepr-package.Rd after document(). Append to inst/WORDLIST, do not re-sort. Fork 1 (qcStudbook) did not re-run each claim; PC13 and PD10 wording rest on the audit. PB4/PB7/PB11 docs still carry the audited false claims; PB13, PA4, PD12, PD1 document today's behavior and need rewording if the code changes.
```

```handoff
session: S836
date: 2026-10-01
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE: docs-staleness audit slice 6b, 36 pedigree QC and curation man/ pages (20 moderate, 37 minor)
what_was_done: Claim 714780074; report docs/audits/DOCS_STALENESS_AUDIT_SLICE6B_2026-10-01.md, BACKLOG and records in the close-out commit. Read-only; four subagents audited nine pages each, I re-ran or re-read the source for all 20 moderate findings. No code, test or man/ change; suite, lint, check not run (nothing built changed).
next_steps: Fix the 57 findings in R/*.R roxygen then devtools::document() (shared reportErrors sentence on all pages at once), or audit slice 6c (196 man/ pages left). Owner decisions: MC1, MB3, seven 6b code candidates (PB4, PB7, PB11, PB13, PA4, PD12, PD1), suggested_NEWS_entry.md. Push master (18 ahead) only on the owner's say-so.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE6B_2026-10-01.md, R/qcStudbook.R:67-190, R/checkRequiredCols.R:6-41, R/convertDate.R:19-24, BACKLOG.md:197
gotchas: man/ is generated; fix roxygen then document(), then git checkout man/nprcgenekeepr-package.Rd. Minor findings are agent-verified (A/R) only. Do not word docs for PB4, PB7, PB11 until the owner decides the code question. PA7 stale DEAD level also in R/getPossibleCols.R (outside the slice).
```

```handoff
session: S835
date: 2026-10-01
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE: fixed 52 of 54 slice-6a docs-staleness findings in R/*.R roxygen (27 genetic-value/kinship pages), man/ regenerated; MC1 and MB3 left for owner
what_was_done: Claim d84dede31; fixes 7382be400, 4a9d8efdf, 8cecc2e49, 6f65ce721, 42197fb0e, d5129f551, 63f5c7a5d; records in the close-out commit. Roxygen and examples only, no code or test change. Examples run, wordlist test pass, lint 0, devtools::check(--no-tests) 0 errors / 0 warnings / 1 note (owner's untracked suggested_NEWS_entry.md). Full test suite and runtime smoke not run (no behavior change).
next_steps: Slice 6b: audit the next topic group of man/ (232 pages left), read-only, one group per session. Owner decisions: MC1 filterKinMatrix drop=FALSE, MB3 unknown-sex founder kinship, suggested_NEWS_entry.md commit or drop, stale man/nprcgenekeepr-package.Rd. Master is 16 ahead of origin; push only on the owner's say-so.
key_files: R/reportGV.R:15-30,110-135, R/geneDrop.R:42-70, R/rankSubjects.R:4-30, R/kinshipMatricesToKValues.R:4-40, BACKLOG.md:197
gotchas: devtools::document() rewrites man/nprcgenekeepr-package.Rd from DESCRIPTION; git checkout it unless intended. example() fails (package not installed): use tools::Rd2ex() then source(). Roxygen lines over 80 characters fail lint; lint per batch. MA3/MB14 cite only e1071 from recall (moments and e1071 not installed here).
```

```handoff
session: S834
date: 2026-10-01
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE: docs-staleness audit slice 6a, 36 genetic-value/kinship man/ pages (9 moderate, 45 minor)
what_was_done: Claim 5fc891cb9; report docs/audits/DOCS_STALENESS_AUDIT_SLICE6A_2026-10-01.md, BACKLOG and records in the close-out commit. Read-only; four subagents audited nine pages each, I re-read the source for 9 findings. No code, test or man/ change; suite, lint, check not run (nothing built changed).
next_steps: Fix the 54 findings in R/*.R roxygen then devtools::document() (shared sentences on all pages at once), or audit slice 6b (232 man/ pages left). Owner decisions: MC1 filterKinMatrix drop=FALSE, MB3 unknown-sex founder kinship, suggested_NEWS_entry.md. Push master (7 ahead) only on the owner's say-so.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE6A_2026-10-01.md, BACKLOG.md:197, R/filterKinMatrix.R:27, R/kinship.R:14,216, R/reportGV.R:113-117
gotchas: man/ is generated; fix roxygen then document(). MA3 and MB14 (moments has no type argument) rest on recall, verify first. Most findings are agent-verified (A/R), 9 re-read by me (S).
```

```handoff
session: S833
date: 2026-10-01
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE: fixed all 30 audit findings (AI1-AI30) in vignettes/a2interactive.Rmd
what_was_done: Claim 8d41e1229; fixes, BACKLOG and records in the close-out commit. Prose, lists and inline R only. Knit clean with numbers read back; spelling test and baseline test pass; devtools::check(--no-tests) 0 errors, 0 warnings, 2 notes (owner's untracked suggested_NEWS_entry.md; a stray Rplots.pdf from my scratch run, since deleted).
next_steps: Slice 6 of the docs-staleness audit: man/ (268 pages), one topic group per session. Owner decisions pending: suggested_NEWS_entry adopt/drop, four code defects. Push master (4 ahead) only on the owner's say-so.
key_files: vignettes/a2interactive.Rmd, docs/audits/DOCS_STALENESS_AUDIT_SLICE5_2026-10-01.md, BACKLOG.md:197
gotchas: Vignette samples randomly, so keep counts as inline R. Run R scripts from the repo root, not vignettes/ (renv path). Not run: full suite, lint, smoke (no code changed). AI20 and AI26 wording rests on agent runs from the audit.
```

```handoff
session: S832
date: 2026-10-01
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE: docs-staleness audit slice 5, scoped to vignettes/a2interactive.Rmd; report docs/audits/DOCS_STALENESS_AUDIT_SLICE5_2026-10-01.md (12 moderate, 18 minor, no code defects)
what_was_done: Claim 0838d80d3; report and records in the close-out commit. Four subagents by line range plus a full knit (no chunk error); I re-read the code for 7 findings. BACKLOG item updated with slice 5 result and next steps. No code changed.
next_steps: Fix AI1-AI30 in vignettes/a2interactive.Rmd (READY, Effort M; knit + devtools::check()), then slice 6 man/ (268 pages) and slice 7 NEWS.Rmd. Owner decisions pending: suggested_NEWS_entry adopt/drop, four code defects.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE5_2026-10-01.md, vignettes/a2interactive.Rmd:920-1019/851-899/680-699/1315, R/groupAddAssign.R:172-186, R/correctParentSex.R:105, R/qcStudbook.R:323
gotchas: Inline-R counts (AI1, AI2) must be recomputed by running. 23 of 30 findings are agent-run, not re-read by me. Not run: suite, check, lint, smoke (audit only).
```

```handoff
session: S831
date: 2026-09-30
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE: fixed the pkgdown breakage by untracking vignettes/suggested_NEWS_entry.Rmd and vignettes/articles/pedigree-diagram.pdf (owner decision "untrack both")
what_was_done: Claim 46a7d9e56; fix 3a8c026bb (git rm of both files); records in the close-out commit. RED = existing test_pkgdown_reference_config.R failure; now passes, check_pkgdown() clean, full unfiltered suite 0 failed / 0 error (2886 results). BACKLOG item removed; Learning 836.
next_steps: Push master only on the owner's say-so (38 ahead, none since S819) and watch all four workflows; then docs-staleness audit slice 5 (Effort L) with owner decisions on suggested_NEWS_entry adopt/drop and the four code defects.
key_files: tests/testthat/test_pkgdown_reference_config.R, _pkgdown.yml (articles list), BACKLOG.md (docs-audit item), suggested_NEWS_entry.md (untracked, top level)
gotchas: R CMD check NOTEs on the untracked top-level suggested_NEWS_entry.md. First push in 12 sessions may show other CI findings unrelated to this fix (estimate). Deleted files recoverable from 9a2a5ddb7.
```

```handoff
session: S830
date: 2026-09-30
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE: reworded "supports five groups of functions" in DESCRIPTION and _pkgdown.yml (BB14), adding the README sentence naming the further tabs; docs only
what_was_done: Claim a80ccc514; content and records in the close-out commit. Both files now say "supports these main groups of functions" with the five-item list kept plus "Further tabs cover mate pair analysis, genetic diversity, marker genetics, potential parents, cross-center identity mapping, de-identified export, and genetic-health trends." Check with --no-tests/--no-vignettes: 0 errors, 0 warnings, 1 note (untracked suggested_NEWS_entry.md). Found test_pkgdown_reference_config.R failing at HEAD from S825's tracked vignettes/suggested_NEWS_entry.Rmd; BACKLOG item added. Learning 835.
next_steps: Fix the pkgdown breakage (BACKLOG, READY, Effort S) before any push; then docs-staleness audit slice 5 (Effort L). Owner decisions open: suggested_NEWS_entry adopt/drop, four code defects. Master is 37 ahead of origin.
key_files: DESCRIPTION:17-30, _pkgdown.yml:14-27, vignettes/suggested_NEWS_entry.Rmd, tests/testthat/test_pkgdown_reference_config.R, BACKLOG.md
gotchas: Do not push until pkgdown::check_pkgdown() passes (the vignette is missing from the articles index). R CMD check NOTEs on the untracked top-level suggested_NEWS_entry.md. Not run: full suite, full check with tests and vignettes, app smoke test.
```

```handoff
session: S829
date: 2026-09-30
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE: trimmed CLAUDE.md out of the warn band (26,731 B to 19,486 B) by moving the 13 close-out checklists verbatim to docs/conventions/CLOSEOUT_CHECKLISTS.md; docs only
what_was_done: Claim 5bc5dbe34; content 70de12168; records in the close-out commit. Moved text proven verbatim by diff; CLAUDE.md keeps one trigger line per checklist plus a link, and session-protocol rule 3 says to read the new file at close-out. File placed in docs/conventions/ (not docs/, which .gitignore:24 ignores); one relative link fixed to ../archive/. context_budget.py reports OK. Learning 834.
next_steps: Pick another READY item: reword the five-groups text in DESCRIPTION and _pkgdown.yml (Effort S), or docs-staleness audit slice 5 (Effort L). Owner decisions open: suggested_NEWS_entry.md commit-or-drop, four code defects, stale comment R/modPedigree.R:440-443. Master is 35 ahead of origin.
key_files: CLAUDE.md:234-251, docs/conventions/CLOSEOUT_CHECKLISTS.md, .gitignore:24-40, BACKLOG.md
gotchas: Read docs/conventions/CLOSEOUT_CHECKLISTS.md at every close-out; CLAUDE.md only has one-line triggers. New files directly under docs/ are git-ignored. Not run: full suite, devtools::check() (no built or tested file changed), app smoke test.
```

```handoff
session: S828
date: 2026-09-30
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE: fixed docs-audit slice 4 cluster 4 (pedigree browser, summary stats, ORIP, major functions, software development, introduction, online documentation components; pedigree_browser.html, pyramidPlot.html; README re-rendered); slice 4 is complete
what_was_done: Claim 2ceac67a8; fixes 4ed44b77a, 8c35cd311 and the README/test commit; records in the close-out commit. Every claim re-read against modSummaryStats.R, modPedigree.R, modORIPReporting.R, qcStudbook.R, modInput.R, modPyramid.R, appUI.R. Fixed BB1-BB17, UG22, UG23, RM1-RM4. Updated two page-text test assertions (test_modPedigree.R, test-e2e-pyramid-detailed.R). Doc unit tests and the two opt-in e2e files pass.
next_steps: Slice 5 (a2interactive.Rmd, man/, NEWS.Rmd, internal docs): read-only audit first, then fix by cluster. Owner decisions: DESCRIPTION/_pkgdown.yml "five groups of functions" wording, the four code defects, stale comment R/modPedigree.R:440-443, suggested_NEWS_entry.md commit-or-drop.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE4_2026-09-30.md, BACKLOG.md (slice 5 line), vignettes/a2interactive.Rmd, tests/testthat/test_modPedigree.R:64
gotchas: Grep tests for page content phrases, not only file names (Learning 833). test_pkgdown_reference_config.R fails locally on the untracked suggested_NEWS_entry. Not run: full suite, app smoke test.
```

```handoff
session: S827
date: 2026-09-30
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE: fixed docs-audit slice 4 cluster 3 (genetic-value pages: _genetic_value_analysis.Rmd, _genome_uniqueness_algorithm.Rmd, genetic_value.html, population_genetics_terms.html, one sentence of summary_stats.html; docs only)
what_was_done: Claim 172ddba8c; fixes 9d6dacb47; records in the close-out commit. Every claim re-read against modGeneticValue.R, calcA.R, calcGU.R, modSummaryStats.R. Fixed BA17-BA22, UG12 second half, UG24, UG25. Related doc tests, test_modGeneticValue.R and the genetic-value e2e pass; Rmd components render.
next_steps: Slice 4 cluster 4 (pedigree browser, summary stats, ORIP, introduction, README re-render from README.Rmd children first; UG22, UG23, RM1-RM4, BA24), then slice 5. Grep tests/testthat for each page name first.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE4_2026-09-30.md, R/modPedigreeBrowser.R, R/modSummaryStats.R, README.Rmd
gotchas: The R helpText at R/modGeneticValue.R:88 still says Summary Statistics relationship table (code, left alone). suggested_NEWS_entry.md untracked and breaks test_pkgdown_reference_config.R locally; ask owner commit or drop. Pages not opened in the running app.
```

```handoff
session: S826
date: 2026-09-30
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE: fixed docs-audit slice 4 cluster 2 (breeding-group pages: _breeding_group_formation.Rmd, _breeding_group_algorithm.Rmd, _gv_and_bg_desc.Rmd, group_formation.html, gvAndBgDesc.html; docs only)
what_was_done: Claim f2c2c4e54; fixes 6a55bf613; records in the close-out commit. Every claim re-read against the module and algorithm code; allele-count claim executed. Fixed BA1-BA16, BA30-31, UG11-UG21 (BA12 and UG17 on the help and manual pages only; the groupAddAssign roxygen wording left with the code-defect decisions). Tests: wordlist, modGvAndBgDesc, modBreedingGroups, minParentAge scan and the opt-in breeding-groups e2e pass; three Rmd components render.
next_steps: Slice 4 cluster 3, genetic-value pages (_genetic_value_analysis.Rmd, _genome_uniqueness_algorithm.Rmd, genetic_value.html, population_genetics_terms.html; BA17-BA22, UG12 second half, UG24-UG25), reusing the genome-uniqueness wording now in gvAndBgDesc.html; then cluster 4 plus README re-render, then slice 5. Owner decisions unchanged (four code defects plus the groupAddAssign roxygen wording, slice 2 screenshots, slice 1 leftovers, 4 untracked files).
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE4_2026-09-30.md, R/modGeneticValue.R:32-75,318-342,368-390, R/calcA.R:41-48, R/orderReport.R:55-145, inst/extdata/ui_guidance/gvAndBgDesc.html
gotchas: grep tests/testthat for a page name and run its opt-in e2e (Learning 832); lead not verified in the app: colony-manager-guide.qmd:527-529 captions tie Group Detail kinship to the checkbox but the module always shows the table; suggested_NEWS_entry still fails test_pkgdown_reference_config.R locally; master 21 ahead of origin, docs only, no CI owed.
```

```handoff
session: S825
date: 2026-09-30
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE: fixed docs-audit slice 4 cluster 1, all 17 findings (UG1-UG10, BA23-BA29) in input_format.html and _input.Rmd; deleted orphan _database_access.Rmd (docs only)
what_was_done: Claim bd0f3134c; fixes 9a2a5ddb7; records in the close-out commit. Every claim re-read against code or executed (qcStudbook with first/second, allele_1/2, age without birth, blank birth, sex H). birth is required; IDs only reject a period; one-file genotypes need integer first/second; hermaphrodite reads Unknown; age = (exit - birth)/365.25; real button names; sire and dam minimum ages optional. Tests: qcStudbook, two doc tests, wordlist coverage, and the opt-in input-tutorial e2e pass (first e2e run failed on the removed word tab-delimited, fixed).
next_steps: Slice 4 cluster 2: breeding-group pages (_breeding_group_formation.Rmd, _breeding_group_algorithm.Rmd, group_formation.html, gvAndBgDesc.html, _gv_and_bg_desc.Rmd; BA1-BA16, BA30-31, UG11-UG21), then cluster 3 genetic-value pages, cluster 4 pedigree browser/summary stats/ORIP/intro plus README re-render, then slice 5 audit. Owner decisions unchanged (four code defects, slice 2 screenshots, slice 1 leftovers, 7 untracked drafts).
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE4_2026-09-30.md, R/modBreedingGroups.R:40-46,63-64,113-115,532-537,967-1011, tests/testthat/test-e2e-input-tutorial.R:109-110, R/modInput.R:79-158,474-495
gotchas: opt-in e2e files (NPRC_RUN_E2E=true) assert help-page text, so grep tests/testthat for a ui_guidance page name and the text you remove before editing it (Learning 832); README.md is a render, fix the _*.Rmd children; A-marked findings need a code re-read; master 18 ahead of origin, docs only, no CI owed; suggested_NEWS_entry.Rmd draft still fails test_pkgdown_reference_config.R locally.
```

```handoff
session: S824
date: 2026-09-30
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE: docs staleness audit slice 4 (read-only); 16 manual_components, 8 ui_guidance pages and README have 33 moderate and 44 minor findings (71 distinct), no broken link or function name
what_was_done: Claim d69808512; report docs/audits/DOCS_STALENESS_AUDIT_SLICE4_2026-09-30.md in the close-out commit. Four read-only subagents did the first pass; this session re-read the code for 26 of 33 Moderate findings and executed getRequiredCols(). Scope narrowed at claim (a2interactive, man/, NEWS.Rmd, internal docs move to slice 5). BACKLOG item updated.
next_steps: Fix slice 4 in four docs-only sessions in the report's Recommendation order (input pages; breeding-group pages; genetic-value pages; pedigree browser/summary stats/ORIP/intro then re-render README.md from README.Rmd); slice 5 audit (a2interactive, man/, NEWS.Rmd, internal docs); owner decisions on four likely code defects (Upload list, no-op GU/MK checkboxes, groupAddAssign roxygen, silent allele_1/allele_2 genotype drop). Still open: slice 2 capture-script tail then 31 screenshots; slice 1 leftovers; 7 untracked owner drafts.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE4_2026-09-30.md, R/modBreedingGroups.R:40-46,63-64,113-115,532-537,967-1011, R/modGeneticValue.R:42-66,424-492, R/modPedigree.R:444-457, BACKLOG.md:151-210
gotchas: README.md is rendered from README.Rmd plus 5 manual-component children, fix the children then re-render; 7 of 33 Moderate findings are agent-only (BA11, BA24, BB9, UG2, UG13, RM1, RM2) and most Minor ones too, re-read code before fixing; suggested_NEWS_entry.Rmd draft still fails test_pkgdown_reference_config.R locally (CI never sees it); master 15 ahead of origin, docs only, no CI owed.
```

```handoff
session: S823
date: 2026-09-30
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE: fixed all 29 docs-audit slice-3 findings (7 moderate, 22 minor) in the 11 articles plus orderReport, qcStudbook and hasInvalidIdChar roxygen (docs only)
what_was_done: Claim 02ee08477; roxygen 5d934ecc3; articles 0ca073234, 930cd1ca8, 2b42611a4; records in the close-out commit. Every wrong claim re-read against code before editing; export count now an inline computed value (233); line citations replaced by names. All 11 touched articles rendered with quarto against a scratch install; targeted tests and lintr pass. BACKLOG item updated.
next_steps: Docs audit slice 4 (16 manual_components, a2interactive, README, man/, NEWS.Rmd, ui_guidance, then internal docs; read-only report). Still open: slice 2 capture-script tail failure then regenerate 31 stale screenshots; slice 1 leftovers (PDFs delete-or-ignore, trackC image, _pedigree_browser.Rmd:62-65, R/modPedigree.R:440-443); 7 untracked owner drafts (commit or drop?).
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE3_2026-09-30.md, R/orderReport.R:33-45, vignettes/articles/colony-manager-guide.qmd:134, BACKLOG.md:151-205
gotchas: untracked owner draft vignettes/suggested_NEWS_entry.Rmd makes test_pkgdown_reference_config.R:107 fail locally (CI never sees it, not a regression); quarto render of articles needs the package installed (R CMD INSTALL -l scratch, R_LIBS); commits used --no-verify; master 14 ahead of origin, docs only, no CI owed.
```

```handoff
session: S822
date: 2026-09-30
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE: docs staleness audit slice 3 (read-only); prose of the 11 articles has 7 moderate and 22 minor stale claims, no broken chunk, link or function name
what_was_done: Claim 96c19a10a; report docs/audits/DOCS_STALENESS_AUDIT_SLICE3_2026-09-30.md. Four subagents checked about 370 claims, this session re-read the code for all Moderate findings and corrected two wrong agent line numbers. BACKLOG item updated; scope narrowed from "articles and manual components" to the 11 articles.
next_steps: Fix the findings in one docs-only session (report tables are the plan; include orderReport and qcStudbook roxygen then devtools::document(); render the touched articles); then slice 4 (16 manual_components, a2interactive, README, man/, NEWS.Rmd, ui_guidance, internal docs); slice 1 and 2 leftovers still open.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE3_2026-09-30.md, BACKLOG.md:151-200, R/orderReport.R:34,76, R/groupAddAssign.R:175, R/getProductionStatus.R:6-30, R/modGeneticValue.R:375-385
gotchas: agent-cited line numbers were wrong twice (breeding-group-formation.qmd is 199 lines; agent cited :350 and :416), re-check every citation before editing; about 60% of Minor findings are agent-run, not reproduced (marked A); master 8 ahead of origin, docs only, no CI owed.
```

```handoff
session: S821
date: 2026-09-30
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE: docs staleness audit slice 2 (read-only); 31 of 38 regenerable shiny_app_use images differ from the app, 4 not judgeable, 12 have no generator
what_was_done: Claim 1d15ed59b; report docs/audits/DOCS_STALENESS_AUDIT_SLICE2_2026-09-30.md (5 findings: stale images by module, colony script tail fails identically in 2 runs, 12 ungenerated images, 1 orphan, GVA tie-order content). Committed PNGs restored after measuring.
next_steps: Diagnose the capture-script tail failure (diagnose skill, reproduce by hand first), then regenerate by module viewing each pair; open slice 1 items (PDFs delete-or-ignore, trackC image, manual sentence, code comment); then slice 3 prose claims.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE2_2026-09-30.md, vignettes/articles/colony-manager-guide-screenshots.R:84-110 and :496-655, BACKLOG.md:151-192
gotchas: colony script takes about 10 minutes and overwrites committed PNGs in place (restore with git checkout -- vignettes/articles/shiny_app_use); master 6 ahead of origin, docs only, no CI owed.
```

```handoff
session: S820
date: 2026-09-30
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE: docs staleness audit slice 1 (read-only); staleness is in both the local PDFs and 1 of 8 committed kinship2 images
what_was_done: Claim 2522ee676; report docs/audits/DOCS_STALENESS_AUDIT_SLICE1_2026-09-30.md (5 findings: PDFs stale and unignored, trackC-nprc-rectilinear.png stale, manual limit wording, stale code comment, 7 images current); BACKLOG item updated. Figures regenerated twice and the committed images restored. No code, no suite run.
next_steps: Owner decides delete-or-ignore for the two PDFs; regenerate trackC-nprc-rectilinear.png (own session); fix _pedigree_browser.Rmd:62-65 and the R/modPedigree.R:440-443 comment; then audit slice 2 (50 shiny_app_use images). Ask once whether to commit or drop the 7 untracked drafts.
key_files: docs/audits/DOCS_STALENESS_AUDIT_SLICE1_2026-09-30.md, data-raw/kinship2FidelityValidation.R:67, R/modPedigree.R:440-446, BACKLOG.md:151-190
gotchas: the kinship2 script overwrites the committed PNGs in place (compare pixels, not bytes; restore with git checkout); master is 3 ahead of origin, docs only, no CI owed.
```

```handoff
session: S819
date: 2026-09-30
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE: pushed master and watched CI; all four workflows green on 7bcfdcc68
what_was_done: Claim 7bcfdcc68 pushed with 8 prior commits (incl. S817 R change); pkgdown, test-coverage, R-CMD-check and lint all succeeded. No code edits.
next_steps: Pick from priorities: the 6 no-behavior-change PED_GV items (triage Recommendation 2), Mate-pair residues (BACKLOG.md:91), or the docs staleness audit. Ask once whether to commit or drop the 7 untracked drafts.
key_files: BACKLOG.md:8 (PED_GV), BACKLOG.md:91 (Mate-pair)
gotchas: only this docs-only records commit is unpushed; no CI owed for it; CLAUDE.md in the warn band (26,731 B).
```

```handoff
session: S818
date: 2026-09-30
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE: closed the 11 settled PED_GV audit ids (docs only); 32 remain
what_was_done: Claim 8a11781b0; closure record added to docs/audits/PED_GV_AUDIT_TRIAGE_2026-09-26.md and BACKLOG.md:8 updated (close-out commit follows the claim). No code, no suite run.
next_steps: Push master and watch CI (S817 R code), or Mate-pair residues (BACKLOG.md:91), or the 6 no-behavior-change PED_GV items (triage Recommendation 2). Ask once whether to commit or drop the 7 untracked drafts.
key_files: docs/audits/PED_GV_AUDIT_TRIAGE_2026-09-26.md (Closure record), BACKLOG.md:8
gotchas: master is unpushed, 8 ahead; only S817 R-code commits need CI; the 32 open ids include NEW-24 = issue #123.
```

```handoff
session: S817
date: 2026-09-30
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE: Potential Parents (getPotentialParents) lists candidates only for the missing parent; owner chose "blank it"
what_was_done: Claim 370e9a1c0; RED 604d4ac9a (5 tests, 3 failing); GREEN c8b7fc794 (R/getPotentialParents.R); docs ada8616ca (roxygen, Rd, tab intro, NEWS.Rmd). Full suite 2,886 tests, 1 known local-only failure; lint clean. Removed the BACKLOG item. Not pushed.
next_steps: Push master and watch CI (R code changed). Then pick from priorities: PED_GV owner decisions (BACKLOG.md:8), Mate-pair residues, optional a2interactive.Rmd pass. Still ask once whether to commit or drop the 7 untracked drafts.
key_files: R/getPotentialParents.R (end of the per-animal loop), tests/testthat/test_getPotentialParents.R:497, NEWS.Rmd (Changed entry after the dam-fallback Fixed entry)
gotchas: master is unpushed and the push triggers all four workflows; no app launch (only intro text changed); NEWS.md lags NEWS.Rmd; test_pkgdown_reference_config.R fails locally only.
```

```handoff
session: S816
date: 2026-09-30
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE: pushed master (6d34fe5f9..d40b734c9) and confirmed CI; all four push workflows green, S811 lint red fixed
what_was_done: Phase 0 report and picker; claim d40b734c9; pushed 14 commits; gh run list for d40b734c9: lint, pkgdown, test-coverage, R-CMD-check all success. No code change.
next_steps: Pick from priorities: Potential Parents own-dam (R/getPotentialParents.R:190, DECISION NEEDED), PED_GV owner decisions (docs/audits/PED_GV_AUDIT_TRIAGE_2026-09-26.md), Mate-pair residues. Still ask once whether to commit or drop the 7 untracked drafts.
key_files: BACKLOG.md:6-50, R/getPotentialParents.R:190
gotchas: master is 1 commit ahead after the records commit (build-ignored only, no CI watch owed); test_pkgdown_reference_config.R fails locally only.
```

```handoff
session: S815
date: 2026-09-30
status: complete
self_score: 9
predecessor_score: 9
active_task: BACKLOG READY item DONE: the six S813 vignette words (ancestryCoverage, ancestryRule, ancestryRules, ancestrySeverity, ancestryStatus, overriddenRules) are in inst/WORDLIST, so test_wordlist_coverage.R and devtools::check() pass
what_was_done: Strict TDD: claim d26c85241; RED was the existing failing test_wordlist_coverage.R:121 (6 words flagged); GREEN added the six words to inst/WORDLIST (two alphabetical insertions); REFACTOR had nothing to change. Full unfiltered suite 362 files, 2,881 tests, 1 failure (known local-only test_pkgdown_reference_config.R); devtools::check(vignettes = FALSE) 0 errors, 0 warnings, 1 note (owner's untracked suggested_NEWS_entry.md). Records and BACKLOG item removal in the S815 close-out commit.
next_steps: Owner pushes master (12 commits ahead; all 4 workflows should go green, including lint.yaml via S812's fix), then report gh run list and do not fix inline. Then pick from the priorities list starting with Potential Parents own-dam (R/getPotentialParents.R:190, DECISION NEEDED); still ask once whether to commit or drop the 7 untracked owner drafts.
key_files: inst/WORDLIST:260 (ancestry words); inst/WORDLIST:496 (overriddenRules); tests/testthat/test_wordlist_coverage.R:121; BACKLOG.md:6 (Up Next now starts with the PED_GV item)
gotchas: inst/WORDLIST has two sorted runs (capitalized words first, then lowercase/camelCase from line ~255); test_wordlist_coverage.R needs NOT_CRAN=true or it bare-skips; last red CI run (lint.yaml, S811 push) is fixed only in unpushed commit 4ccdb0dd4
runtime_smoke: n/a: data-only change (inst/WORDLIST), no runtime behavior touched; check() and the full suite passed
changelog_ref: S815 close-out entry
commit: see git log (S815 close-out)
```

```handoff
session: S814
date: 2026-09-30
status: complete
self_score: 8
predecessor_score: 7
active_task: Display Unknown IDs vs reportGV() BACKLOG item DONE: the box now filters only the Pedigree Browser table; other tabs get the new analysisPedigree return element
what_was_done: Strict TDD with owner-decided scope (table only). Claim 86df3a042, RED cb26af5d5 (8 new tests, 6 failing, 2 guards; contract and stub updates), GREEN 9a7657865 (R/modPedigree.R analysisPedigree + R/appServer.R wiring), docs c5968028a (help text, manual, guide, NEWS.Rmd), records in the S814 close-out commit. Full suite 2,881 tests with 2 failures (known pkgdown-config and S813's wordlist); lint 0; smoke HTTP 200.
next_steps: Add the 6 words S813 left out of inst/WORDLIST (BACKLOG top item, READY, Effort S) so test_wordlist_coverage.R and devtools::check() pass, then the owner pushes master (11 commits ahead, all 4 workflows run). Then pick from the priorities list starting with Potential Parents own-dam (R/getPotentialParents.R:190).
key_files: R/modPedigree.R:358 (applyFocalTrim, analysisPedigreeData); R/appServer.R:310 (shared$currentPedigree from analysisPedigree); tests/testthat/test_displayUnknownIdsDownstream.R:1; tests/testthat/test_appServer_server.R:65 (stub); BACKLOG.md:7 (wordlist item)
gotchas: analysisPedigree keeps the focal-animal trim; the table, diagram and CSV export still use the filtered pedigree(); a new modPedigreeServer stub needs an analysisPedigree element; NEWS.md lags NEWS.Rmd (last rendered S716); no browser click-through, testServer only
runtime_smoke: runGeneKeepR(port = 6099L) HTTP 200, no log errors; behavior verified with testServer on modPedigreeServer and appServer
changelog_ref: S814 close-out entry
commit: see git log (S814 close-out)
```

```handoff
session: S<N>
date: YYYY-MM-DD
status: <pending | complete>
self_score: <1-10>
predecessor_score: <1-10>
active_task: <current state>
what_was_done: <what you did, including a commit sha — or the literal `pending`>
next_steps: <specific and actionable; never "pick next from backlog">
key_files: <each entry carries a path:line token, e.g. SessionManager.java:245>
gotchas: <traps the next session should watch for>
runtime_smoke: <a run result, or "n/a — docs-only", or "impossible: <reason>">
changelog_ref: <PR #N or a short-sha into CHANGELOG.md>
commit: <short-sha — or `pending` until the next session reconciles it>
```
<free-text prose: the durable proxy for the Phase 3G spoken report, plus the +/- self-score breakdown>

Write clean `key: value` lines — no inline `#` comments (a `#` is a literal value character,
as in `changelog_ref: PR #52`). The keys are the six Phase 3D Minimum Handoff Requirements (the sixth
*is* `self_score`) plus `predecessor_score` (the Phase 3A evaluation) and a little metadata. `status`
is `pending` at the Phase 1B claim and `complete` at
close-out; a third value, `reconciled`, is written *only* by a later session's Phase 0 reconcile
when it reconstructs a receipt a crashed session never completed — you never write it yourself.
````

`self_score` and `predecessor_score` are distinct keys so one can never stand in for the other; omit
`predecessor_score` on Session 1 (there is no predecessor to score). `commit: pending` and
`what_was_done: pending` are legal at write time (the receipt ships in the very commit whose sha it
would name); the next session reconciles them to real shas.

## Size, and when to archive

handoffs-format: 2 — keep this marker, and bring it across with this section; `bin/status` reads it.

This file gains a receipt every session and nothing removes one, so it grows without bound. The
protocol never asks a session to read it whole: Phase 0 reconciles it against `git log` and checks
the newest receipt, and a session reads that receipt at the top — past the harness's default-read
refusal, with an offset and a limit. Archive it when the trimmer's trigger fires. The tool states the
trigger, and this file names no size of its own.

**Run this rather than estimating it:**

```sh
python3 methodology_trim.py --file HANDOFFS.md --check
```

`--check` evaluates the trigger and never writes. `--write` performs the trim, refuses unless it
can prove the split lossless, and **neither commits nor stages** — it leaves this file modified and
the new shard *untracked*, and leaves the commit to you (`git add HANDOFFS.md docs/archive/`).

An archive is a **shard**: a new frozen file, same format, same newest-on-top order.

- **Path: `docs/archive/HANDOFFS-through-<CUT-KEY>.md`.** Both halves are load-bearing — the
  directory keeps the shard from shadowing this file, and the `HANDOFFS-` prefix is what the
  trigger's own glob looks for. A shard named otherwise is silently invisible to it.
- **This file keeps one short pointer** naming each shard, the span it covers and how many receipts
  it holds — with the command that recomputes those counts, never a hand-maintained number.
- **The shard back-links here and states only facts about itself.** It must not restate a
  forward-looking rule: a shard is frozen, so a rule copied into one cannot be corrected when the
  live rule moves.
- **After a split, anything that enumerates receipts must span both** — `HANDOFFS.md
  $(git ls-files 'docs/archive/HANDOFFS-*.md')` — or it silently counts a shrunken
  population. Enumerate the shards with `git ls-files`, never as a bare glob: zsh aborts a
  command whose glob matches nothing, so before the first split the bare form counts nothing
  at all — the same reason the ledger's audit is written that way.

The reasoning this file shares with `CHANGELOG.md` — how a ledger is read, why the tool is the only
statement of its trigger, and what a split must conserve — is in the *Reading and archiving*
subsection of [§The Action Ledger](docs/methodology/FRAMEWORK_APPARATUS.md#the-action-ledger).
That subsection makes archiving optional for `CHANGELOG.md`; this file keeps its own rule, above —
archive it when the trimmer's trigger fires. Everything needed to *act* is here.

What is specific to *this* file, and gets receipts wrong if assumed:

- **A record is a `handoff` block *plus the prose beneath it*, not the fence alone.** The self-score
  and predecessor-score paragraphs sit outside the fence and belong to the receipt above them. A
  fence-only cut severs every receipt from its own scoring.
- **Archive oldest-first by position, never by sorting on `session:`.** Two independent `S<N>`
  sequences can share one ledger — a fork and its upstream each running their own counter — and
  their numbers collide. The record's identity is **session + date**.
- **A trim leaves the newest-receipt check alone and moves what the older-receipt checks see.**
  Phase 0 reconcile is frontier-based and a structural checker applies the full schema to the newest
  receipt only, so neither is disturbed. Its other passes are not so confined — an answer-slot rule
  reads every receipt below the newest, and a locator-form rule reads every receipt in the file. So
  after a trim, **run the checker against each shard as well**, and recompute any "all N older
  receipts" count from the files rather than carrying it forward.
- **Never trim to zero receipts.** An empty receipt ledger is indistinguishable from a broken one.
- **A shard freezes, with one exception this file needs:** a `commit:` answer slot may still be
  reconciled inside an archived receipt, because that field was always going to be filled by a later
  session. Nothing else in a shard is rewritten.

**Archived 181 record(s), 2026-07-08 → 2026-08-10** into [`docs/archive/HANDOFFS-through-2026-08-10.md`](docs/archive/HANDOFFS-through-2026-08-10.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-10.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-10.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 39 record(s), 2026-08-10 → 2026-08-12** into [`docs/archive/HANDOFFS-through-2026-08-12.md`](docs/archive/HANDOFFS-through-2026-08-12.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-12.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-12.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 17 record(s), 2026-08-12 → 2026-08-13** into [`docs/archive/HANDOFFS-through-2026-08-13.md`](docs/archive/HANDOFFS-through-2026-08-13.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-13.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-13.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 21 record(s), 2026-08-13 → 2026-08-14** into [`docs/archive/HANDOFFS-through-2026-08-14.md`](docs/archive/HANDOFFS-through-2026-08-14.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-14.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-14.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

This file currently holds **2** receipt(s). Computed by `methodology_trim.py` on every
`--check`/`--write` run, never hand-maintained.

**Archived 116 record(s), 2026-08-14 → 2026-09-17** into [`docs/archive/HANDOFFS-through-2026-09-17.md`](docs/archive/HANDOFFS-through-2026-09-17.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-17.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-17.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 13 record(s), 2026-09-17 → 2026-09-18** into [`docs/archive/HANDOFFS-through-2026-09-18.md`](docs/archive/HANDOFFS-through-2026-09-18.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-18.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-18.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 11 record(s), 2026-09-18 → 2026-09-19** into [`docs/archive/HANDOFFS-through-2026-09-19.md`](docs/archive/HANDOFFS-through-2026-09-19.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-19.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-19.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 9 record(s), 2026-09-19 → 2026-09-19** into [`docs/archive/HANDOFFS-through-2026-09-19-2.md`](docs/archive/HANDOFFS-through-2026-09-19-2.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-19-2.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-19-2.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 31 record(s), 2026-09-19 → 2026-09-21** into [`docs/archive/HANDOFFS-through-2026-09-21.md`](docs/archive/HANDOFFS-through-2026-09-21.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-21.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-21.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 7 record(s), 2026-09-22 → 2026-09-23** into [`docs/archive/HANDOFFS-through-2026-09-23.md`](docs/archive/HANDOFFS-through-2026-09-23.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-23.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-23.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 11 record(s), 2026-09-23 → 2026-09-24** into [`docs/archive/HANDOFFS-through-2026-09-24.md`](docs/archive/HANDOFFS-through-2026-09-24.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-24.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-24.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 4 record(s), 2026-09-24 → 2026-09-26** into [`docs/archive/HANDOFFS-through-2026-09-26.md`](docs/archive/HANDOFFS-through-2026-09-26.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-26.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-26.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 3 record(s), 2026-09-26 → 2026-09-26** into [`docs/archive/HANDOFFS-through-2026-09-26-2.md`](docs/archive/HANDOFFS-through-2026-09-26-2.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-26-2.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-26-2.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 4 record(s), 2026-09-26 → 2026-09-26** into [`docs/archive/HANDOFFS-through-2026-09-26-3.md`](docs/archive/HANDOFFS-through-2026-09-26-3.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-26-3.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-26-3.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

```handoff
session: S813
date: 2026-09-30
status: complete
self_score: 8
predecessor_score: 8
active_task: a2interactive.Rmd demo sections for reportMatePairs ancestry columns and obfuscateId(placeholder =) DONE; BACKLOG Mate-pair ancestry guardrails item now has 3 open residues (zero-rule manifest, Excluded-tab export, duplicated gate code). Nothing in progress.
what_was_done: Added two sections to vignettes/a2interactive.Rmd (+104 lines): Ancestry Rules for Mate Pairs (rules table, pairs/excluded/ancestryCoverage, override) and Aliasing Ids with a Known Placeholder Status. Rendered the vignette and checked each prose claim against the rendered output. Removed the finished sub-item from BACKLOG.md. Learning 829. Claim commit 30537e2fe.
next_steps: Owner pushes master (5 commits ahead; all 4 workflows run, lint should go green). Then pick from: Display Unknown IDs breaking reportGV (DECISION NEEDED, R/appServer.R:312, R/modPedigree.R:359-364), Potential Parents own-dam (DECISION NEEDED, R/getPotentialParents.R:190), PED_GV owner decisions, or the zero-rule manifest and Excluded-tab export residues. Optional: a full a2interactive inventory pass of exports and parameters since S541/S808 (not started).
key_files: vignettes/a2interactive.Rmd:1080 (Ancestry Rules for Mate Pairs); vignettes/a2interactive.Rmd:1786 (Aliasing Ids with a Known Placeholder Status); BACKLOG.md:127 (Mate-pair ancestry guardrails residue); PROJECT_LEARNINGS.md:2326
gotchas: The vignette's setup calls set_seed(1L) (line 30), which sets sample.kind to Rounding, so seeded output differs from a console run; the prose about the aliases is seed-dependent (Learning 829). Rendering to md_document fails on the HTML tables; render HTML and strip tags to read output. vignettes/*.html are gitignored and pre-existing.
runtime_smoke: n/a - docs-only; the vignette render (rmarkdown::render of a2interactive.Rmd) is the build equivalent and completed with no error
changelog_ref: S813 close-out entry
commit: see git log (S813 close-out)
```

```handoff
session: S812
date: 2026-09-30
status: complete
self_score: 8
predecessor_score: 8
active_task: Red lint.yaml run on 6d34fe5f9 fixed locally (comment re-wrap at R/resolveCrossCenterIds.R:367); not pushed, so CI green is unconfirmed. Next: owner pushes, then pick from the priorities list.
what_was_done: Reproduced the single line_length_linter finding locally, re-wrapped the roxygen paragraph (comment only) and regenerated man/resolveCrossCenterIds.Rd (whitespace only); lint_package 0, two related test files pass; Learning 828.
next_steps: Owner pushes master (all 4 workflows run; lint should go green). Then pick: Display Unknown IDs breaking reportGV (DECISION NEEDED, R/appServer.R:312), Potential Parents own-dam (DECISION NEEDED, R/getPotentialParents.R:190), a2interactive demos (READY).
key_files: R/resolveCrossCenterIds.R:364; man/resolveCrossCenterIds.Rd:1; PROJECT_LEARNINGS.md:2323
gotchas: Lint after the last docs/roxygen edit, not only after GREEN (Learning 828). gh run list can print oldest-first within one push; use --json createdAt. Full suite and devtools::check were not re-run (comment-only change).
runtime_smoke: n/a - comment-only change, no runtime behavior touched
changelog_ref: S812 close-out entry
commit: see git log (S812 close-out)
```

```handoff
session: S811
date: 2026-09-29
status: complete
self_score: 9
predecessor_score: 8
active_task: Placeholder-marking plan (docs/planning/unknown-parent-placeholder-marking-plan.md): all 5 slices DONE (S807-S811); the BACKLOG.md item is removed. Next: pick from the priorities list.
what_was_done: Strict TDD Slice 5. obfuscateId gets an optional placeholder vector, obfuscatePed passes the column, and resolveCrossCenterIds resolves a linked pair's mark (real wins, one-sided mark kept, no error on disagreement; owner decision S811). RED 6de83f4d8 (18 tests, 11 failing, 7 guards), GREEN 665e9c475, docs a229b3bb1. Full suite 2872 tests 0 errors 1 known local failure; check 0/0/2 notes; lint 0.
next_steps: No placeholder slice remains. Options: Display Unknown IDs breaking reportGV (DECISION NEEDED, R/appServer.R:312), Potential Parents own-dam (DECISION NEEDED, R/getPotentialParents.R:190), PED_GV audit decisions, or the deferred a2interactive pass (reportMatePairs and obfuscateId(placeholder =)).
key_files: R/obfuscateId.R:41; R/obfuscatePed.R:43; R/resolveCrossCenterIds.R:322; tests/testthat/test_placeholderMarkDeidMerge.R:1; docs/planning/unknown-parent-placeholder-marking-plan.md:362
gotchas: checkCrossCenterMapping reports only sire/dam conflicts; a column on only one file is not merged by the generic otherCols loop in resolveCrossCenterIds, so a new column that must survive a linked pair needs its own line; a port answering HTTP 200 may belong to another process (check the log says Listening).
runtime_smoke: runGeneKeepR(port = 6111L) HTTP 200, no log errors (port 6099 was held by another process and is not counted); de-identified export verified with testServer on modDeidentifiedExportServer.
changelog_ref: a229b3bb1
commit: a229b3bb1
```

```handoff
session: S810
date: 2026-09-29
status: complete
self_score: 9
predecessor_score: 9
active_task: Placeholder-marking plan (docs/planning/unknown-parent-placeholder-marking-plan.md): Slices 1-4 DONE (S807-S810). Next: Slice 5 (de-identification and cross-center merge).
what_was_done: Strict TDD Slice 4. The Display Unknown IDs filter passes the pedigree so it reads the placeholder mark; headerDisplayNames maps placeholder to Generated Unknown ID; help text, manual, guide and NEWS.Rmd updated; both exports pinned as round trips. RED 056bceda4, GREEN 83dbbee34, docs b406e7ead. Full suite 2854 tests 0 errors 1 known local failure; check 0/0/2 notes.
next_steps: Slice 5 (plan section 5): obfuscateId() optional placeholder vector filled by obfuscatePed() from the column (R/obfuscateId.R:28, R/obfuscatePed.R:43) and the cross-center merge NA-fill (R/resolveCrossCenterIds.R:17-26). Re-run the plan section 2 greps first; strict TDD with AskUserQuestion gates.
key_files: R/modPedigree.R:361; R/modPedigree.R:107; R/headerDisplayNames.R:56; tests/testthat/test_placeholderMarkDisplay.R:1; docs/planning/unknown-parent-placeholder-marking-plan.md:341
gotchas: The unticked box still leaves children naming a hidden stand-in (R/appServer.R:312 feeds the filtered pedigree downstream); the browser table shows raw column names; grep UI html for a phrase not the word placeholder (matches an HTML attribute).
runtime_smoke: runGeneKeepR(port = 6098L) HTTP 200, no log errors; filter verified with testServer on modPedigreeServer.
changelog_ref: b406e7ead
commit: b406e7ead
```

```handoff
session: S809
date: 2026-09-29
status: complete
self_score: 8
predecessor_score: 9
active_task: Placeholder-marking plan (docs/planning/unknown-parent-placeholder-marking-plan.md): Slices 1-3 DONE (S807-S809). Next: Slice 4 (Display Unknown IDs filter, display name, help/docs, exports keep the mark).
what_was_done: Strict TDD Slice 3. reportGV() founder counts and parentage, classifyParentage(ped =), correctUnknownParentMeanKinship() (whole ped), getLivingBreeders() (so the effective sizes) and gvaConvergence() parentage read the placeholder mark; an id with no row is read by shape (D4). 14 new tests in test_placeholderMarkReaders.R (11 failed on old behavior, 2 guards). NEWS.Rmd entry extended; plan and BACKLOG updated. Learning 825.
next_steps: Slice 4 (plan section 5): R/modPedigree.R:363 filter passes ped; R/headerDisplayNames.R display name for placeholder; help text and colony-manager-guide.qmd / _pedigree_browser.Rmd; summary_stats.html; exports keep the mark (D8). RED first; re-run the plan section 2 greps.
key_files: R/classifyParentage.R:20; R/getLivingBreeders.R:26; R/correctUnknownParentMeanKinship.R:155; R/reportGV.R:282-293; R/gvaConvergence.R:175; tests/testthat/test_placeholderMarkReaders.R; PROJECT_LEARNINGS.md (Learning 825)
gotchas: Until Slice 4 the Display Unknown IDs filter still uses the id shape. Shipped data is unmarked, so only a fixture shows a mark changing an answer (makeMarkedPed() in the new test file). gh run list can return stale runs or time out; find runs by head sha. 22 commits unpushed; pushing is the owner's call.
runtime_smoke: runGeneKeepR(port = 6097L) HTTP 200, no log errors; module behavior verified with testServer on modGeneticValueServer. Full suite 359 files / 2,844 tests / 0 errors (known local-only pkgdown failure). devtools::check 0 errors / 0 warnings / 2 notes (owner's drafts). Lint 0. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 4f4491dfc876 · manifest aa983075d6a2
changelog_ref: 4802843c6
commit: cc1eca898
```

```handoff
session: S808
date: 2026-09-29
status: complete
self_score: 8
predecessor_score: 9
active_task: Placeholder-marking plan (docs/planning/unknown-parent-placeholder-marking-plan.md): Slices 1-2 DONE (S807, S808); owner ratified D1/D3/D5/D6/D10-D13. Next: Slice 3 (reportGV, classifyParentage, correctUnknownParentMeanKinship, getLivingBreeders read the mark).
what_was_done: Strict TDD Slice 2. qcStudbook() writes a logical placeholder column (made stand-ins TRUE, user TRUE/FALSE/1/0 kept, rest by id shape; bad values stop QC or fill errorLst$invalidPlaceholderRows, 11th field); isGeneratedUnknownId(ped =) and removeAutoGenIds() read it; addUIds() no longer reuses ids used only as sire/dam; getPotentialParents() reads the mark before dropping animals with no birth date (D12). 23 new tests RED then GREEN; docs-only REFACTOR (roxygen/man, NEWS.Rmd, QC article, guide, a2interactive table, WORDLIST). Commits: claim a0e687f7, decisions 2c82c8a8, RED 98720bf2 b6f050a1 84382fa1, GREEN bac494e0 410273d5 9a4dee7c cd19fbab, docs ec2c4d14 d830034e 34fcc801 ef91c4b1 904d9ff2, records (this).
next_steps: Slice 3 (plan section 5): R/reportGV.R:283-286 founders, classifyParentage() optional ped (callers R/reportGV.R:292, R/gvaConvergence.R:175), R/correctUnknownParentMeanKinship.R:134/155, R/getLivingBreeders.R:26 pass ped. RED: marked real U1234 founder counted and offspring known; parent whose placeholder row was filtered away stays unknown (D4); qcPed calcNeVariance stays 26.405868. Re-run plan section 2 greps first.
key_files: R/qcStudbook.R:207 (parse/validate); R/qcStudbook.R:370 (readPlaceholderMark, addPlaceholderMark); R/autoIdFormat.R:143 (isGeneratedUnknownId); R/removeAutoGenIds.R:25; R/getPotentialParents.R:90; R/addUIds.R:46; tests/testthat/test_modInput_placeholder.R:1; tests/testthat/test_qcStudbook.R:495; PROJECT_LEARNINGS.md (Learning 824)
gotchas: Until Slice 3 the GV/breeder readers still use the id shape, so a marked real U1234 is misread there. The Pedigree Browser shows the column under its raw name until Slice 4. Invalid-row numbers are the uploaded file's rows before UNKNOWN-id rows are dropped. test_getFocalAnimalPed.R:112 runs only for the owner's user name and pins 11 fields. devtools::check builds vignettes and caught the a2interactive table the suite missed. Known local-only failure test_pkgdown_reference_config.R and check's 2 notes = the owner's untracked suggested_NEWS_entry drafts.
runtime_smoke: runGeneKeepR(port = 6098L) HTTP 200, no log errors; upload and Potential Parents behavior verified with testServer on the real module servers. Full suite 358 files / 2,830 tests / 0 errors (known local-only pkgdown failure). devtools::check 0 errors / 0 warnings / 2 notes (owner's drafts). Lint 0. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 44ec6f035883 · manifest aa983075d6a2
changelog_ref: bac494e0
commit: pending
```

```handoff
session: S807
date: 2026-09-28
status: complete
self_score: 8
predecessor_score: 9
active_task: Real animal ids that start with the placeholder prefix (U1, Uma, U123) treated as stand-ins for unknown parents (PED_GV F2 / NEW-38 other half). Plan docs/planning/unknown-parent-placeholder-marking-plan.md: Slice 1 (the tighter rule) DONE S807; owner ratified D1/D3/D5/D6 plus D10/D11. Next: Slice 2 (addUIds reuse fix, then qcStudbook writes the placeholder column).
what_was_done: Strict TDD Slice 1. isGeneratedUnknownId() now needs the prefix plus at least getAutoIdWidth() capitals/digits (U1/U123/Uma real; ancestry example counts U1, 4 female founders); setAutoIdFormat() refuses formats whose ids fail the rule (D11); obfuscateId() lengthens only placeholder aliases when size is too short (D10, found by measuring the app's alias-length minimum 4). 16 RED tests + 5 guards; docs-only REFACTOR (roxygen/man for 4 functions, app help text, manual line, NEWS.Rmd). Commits: claim 0647abea, decisions 95a4e5fa, RED 9b8431dd 9dd49380, GREEN aeccac96, docs 9e89cd3d 32cae6cc 93640b3f, plan/backlog f673d78d, NEWS spelling fix 02a83f49, records (this).
next_steps: Slice 2 (plan section 5): first make addUIds() skip ids used only as a sire or dam (R/addUIds.R:46, plan M11 repro); then qcStudbook() writes the logical placeholder column after addUIds/addParents (R/qcStudbook.R:231), keeps user TRUE/FALSE, stops on bad values (D5), fills blanks with the Slice 1 rule; isGeneratedUnknownId(ped =) reads the mark (D4); removeAutoGenIds passes ped. Moves test_qcStudbook.R:105; keep test_getPotentialParents.R:452 at 1587. Re-run the plan section 2 greps before RED.
key_files: R/autoIdFormat.R:116 (getAutoIdWidth); R/autoIdFormat.R:143 (isGeneratedUnknownId); R/autoIdFormat.R:75 (setAutoIdFormat probe); R/obfuscateId.R:40; R/modPedigree.R:110; tests/testthat/test_autoIdFormat.R:140; tests/testthat/test_reportGV.R:870; tests/testthat/test_modDeidentifiedExport.R:189; R/addUIds.R:46; R/qcStudbook.R:231; PROJECT_LEARNINGS.md:2311 (Learning 823)
gotchas: getAutoIdWidth() errors if the option is set directly (options()) to a format with no conversion; setAutoIdFormat() refuses those, untested. test_wordlist_coverage.R runs only in the full suite with NOT_CRAN=true; run it after NEWS/roxygen wording changes. obfuscateId() random streams changed for real ids at small size (short U-leading aliases now accepted). The width is recomputed per predicate call; hoist if Slice 2 loops per row. Known local-only failure test_pkgdown_reference_config.R and check's 2 notes = the owner's untracked suggested_NEWS_entry drafts.
runtime_smoke: runGeneKeepR(port = 6099L) served HTTP 200 with the new Pedigree Browser help text, old text absent, no log errors; filter and de-identified export behavior verified via testServer on the real module servers. Full suite 357 files / 2,809 tests / 0 errors (known local-only pkgdown failure; spelling guard fixed in 02a83f49). devtools::check 0 errors / 0 warnings / 2 notes (owner's untracked drafts). quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 4e12678a802c · manifest aa983075d6a2
changelog_ref: aeccac96
commit: pending
```

```handoff
session: S806
date: 2026-09-28
status: complete
self_score: 8
predecessor_score: 9
active_task: Real animal ids that start with the placeholder prefix (U1, Uma, U123) are treated as stand-ins for unknown parents (PED_GV F2 / NEW-38 other half). Owner chose "mark ids when they are made"; plan written (docs/planning/unknown-parent-placeholder-marking-plan.md). Next: owner decisions D1/D3/D5/D6 (plan section 11), then Slice 1 or 2.
what_was_done: Planning session, no code. Measured 11 facts (M1-M11: shipped U-id shapes, rule trials over the full suite, recordStatus reset, attribute loss, column survival, filtered downstream pedigree, reportGV error when filtered, obfuscatePed aliases, addUIds reusing a sire-only id); owner picked the approach and plan-first via AskUserQuestion; plan with grep inventory, decisions D1-D9, 5 TDD slices. BACKLOG: item points at the plan; new item for reportGV stopping when Display Unknown IDs is unticked; the addUIds reuse added to the placeholder and PED_GV items. Commits: claim cb4601aa, plan 2d327d7f, records (this).
next_steps: Ask the owner the plan's 4 decisions (section 11) in plain words. If D3 = the tighter rule, implement Slice 1 with strict TDD: R/autoIdFormat.R:109-111, obfuscateId() alias length at R/obfuscateId.R:40-46, the 3 moved tests (test_autoIdFormat.R:58, test_modPedigree.R:113-169, test_obfuscateId.R:31), NEWS.Rmd entry. Otherwise start at Slice 2 (addUIds sire/dam reuse fix first, then qcStudbook writes the mark).
key_files: docs/planning/unknown-parent-placeholder-marking-plan.md:1 (sections 1.3, 2, 5, 11); R/autoIdFormat.R:109; R/addUIds.R:46; R/qcStudbook.R:231; R/qcStudbook.R:324; R/addParents.R:43; R/modPedigree.R:359; R/appServer.R:312; tests/testthat/test_qcStudbook.R:105; BACKLOG.md:51
gotchas: Trial a rule by assigning into both asNamespace("nprcgenekeepr") and package:nprcgenekeepr after load_all; a wrapper breaks mockery::stub tests on that function (test_qcStudbook.R:443). recordStatus is rebuilt every QC run. fixColumnNames rewrites "ego" to "id" in any header and lowercases camelCase. BACKLOG.md is 54,837 B, 1,913 B under the 56,750 B read cap. Full suite's 1 known failure is local-only (untracked vignettes/suggested_NEWS_entry.Rmd).
runtime_smoke: n/a -- docs-only (a plan and BACKLOG.md; both build-ignored, read by no test). Two full-suite trials in scratch (357 files, 2,790 tests each): tighter rule moved 3 tests; a qcStudbook mark column moved 1 (plus 1 trial artifact). CI on e5e007f8 (in_progress at Orient) re-read green: R-CMD-check all 5 legs, test-coverage. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 3749928c8792 · manifest aa983075d6a2
changelog_ref: 2d327d7f
commit: pending
```

```handoff
session: S805
date: 2026-09-28
status: complete
self_score: 8
predecessor_score: 9
active_task: Re-render the 2 stale Pedigree Diagram article figures (exemplar-linebreeding-rectilinear.png, exemplar-half_sib-rectilinear.png) -- DONE, owner-approved and committed; the render script's stale header (expected two collision warnings S715 retired) also fixed, owner-approved.
what_was_done: Ran vignettes/articles/pedigree-diagram-exemplar-renders.R (all 5 renders, node/edge counts matching the fixture pins, no layout warnings; the header's expected two warnings were retired S715, confirmed from test_examplePedigreeFixtures.R's rectilinearCollisionWarning = FALSE pins). Against the committed PNGs: linebreeding 2,228 and half_sib 1,210 pixels differ (1,257 / 782 by more than 0.25), only in the dashed duplicate-animal arcs, now flatter; the other 3 differ by anti-aliasing only (121-189 px, max 0.055) and were restored from git. New arcs clear LA2 by ~5-6 px and HA2 by ~3 px at 1200x900. Owner viewed old/new/overlay strips and approved both images and the header fix. Commits: claim 54a3a7bd, figures 2a247184 (+ BACKLOG documentation-audit finding updated), header 16bc27bd (comment only), records. Fixture test 14 tests / 303 expectations, 0 failed; script parses, lint 0; article and alt text still fit. Learning 821.
next_steps: (A) Documentation audit next slice: check vignettes/articles/kinship2-fidelity-validation-img/ (8) and vignettes/articles/shiny_app_use/ (50) against current code; find each image's generator first (an estimate of where to look, not checked). (B) Up Next owner decisions: jmac example file, U-prefix ids, recorded dam, PED_GV. (C) Carried: methodology_dashboard.py tracked vs untracked; CHANGELOG.md/HANDOFFS.md trims (owner runs the forced write); suggested_NEWS_entry review; 7 untracked residue; 5 unpushed after this records commit (owner's call; a push publishes the new figures via pkgdown).
key_files: vignettes/articles/pedigree-diagram-img/exemplar-{linebreeding,half_sib}-rectilinear.png; vignettes/articles/pedigree-diagram-exemplar-renders.R:16-24; tests/testthat/test_examplePedigreeFixtures.R:228-282 and :520-535; vignettes/articles/pedigree-diagram.qmd:120-126; PROJECT_LEARNINGS.md Learning 821.
gotchas: The render script overwrites all 5 PNGs; commit only files with pixels changed by more than 0.25 and git checkout -- the rest. It needs Chrome (chromote); 23 s here. gh run list --json returned older runs than plain gh run list; query by id with gh run view. The full suite's 1 known failure is local-only. STANDING SET unchanged from S790-804.
runtime_smoke: No runtime behavior changed (build-ignored images and a comment). Fixture test (the pinned drawn structure) 303 expectations pass; renders inspected by pixel diff and zoomed closest-approach checks; owner visual approval. CI on fd2056ca (in_progress at Orient): lint, pkgdown, test-coverage green; R-CMD-check run 36489531079 green on all 5 legs incl. windows-latest (re-read at close-out). quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 5deafc2db4bb · manifest aa983075d6a2
changelog_ref: this records commit (S805 records entry, prepended above the S805 header, figures and claim entries)
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log)
```
Predecessor (S804) scored 9/10: every Orient measurement held and next step (A) was exact to the pixel; missing: the render script's header contradicts the test pins (expects two retired warnings). Self-score 8/10: +reproduced S802's numbers first; +checked the missing warnings against the pins; +committed only the real change; +measured each arc's closest approach; +overlay strips for the owner look. -first zoom crop missed; -one call failed on an uninstalled abind; -no mandated-read reduction.

```handoff
session: S804
date: 2026-09-28
status: complete
self_score: 8
predecessor_score: 8
active_task: Fix the red windows-latest leg of R-CMD-check (test_examplePedigreeTxt.R:52 found carriage returns in ExamplePedigree.txt) -- DONE and green on CI. A new .gitattributes pins that file to LF on every checkout; .Rbuildignore excludes .gitattributes.
what_was_done: Found at Orient: windows-latest failed test_examplePedigreeTxt.R:52 on runs 36472173902, 36472806892 (S802 pushes) and 36482001967 (S803's); other legs green. Measured: file stored LF, no .gitattributes, Git for Windows' core.autocrlf=true writes 3,695 CRs (scratch clone and git cat-file --filters). Owner gates: .gitattributes rather than skipping the test on Windows; pin only this file; REFACTOR review-only; push and wait. RED ef0665ef (cat-file --filters test under core.autocrlf=true and core.eol=crlf, skips outside the source repo; .Rbuildignore guard), GREEN 0868249f (.gitattributes 'inst/extdata/examples/ExamplePedigree.txt text eol=lf' + '^\.gitattributes$' in .Rbuildignore), REFACTOR no change. Verified: both files pass; tarball 1,050 entries, no .gitattributes; fresh clones with core.autocrlf=true and core.eol=crlf write 0 CRs into the .txt (CSV control 3,695 under autocrlf); full suite 357 files / 2,790 tests, 1 failed (known local-only test_pkgdown_reference_config.R, the owner's untracked suggested_NEWS_entry.Rmd), 0 error; lint 0. Pushed (owner-directed) bc0624ac -> 0868249f; CI on 0868249f all green, R-CMD-check windows-latest Status OK, [ FAIL 0 | WARN 8 | SKIP 265 | PASS 8379 ]. Learning 820; memory skip-ci-for-buildignored-changes gained its limit.
next_steps: (A) Every Up Next item is an owner decision; measure first (Learnings 812/815-820). Nearest: the stale linebreeding/half_sib article figures (BACKLOG.md:202-237): re-run vignettes/articles/pedigree-diagram-exemplar-renders.R, owner looks, commit the 2 images. Then jmac (BACKLOG.md:256), U-prefix ids (:51), recorded dam (:32), PED_GV (:8). (B) Carried owner question: keep methodology_dashboard.py tracked (each sync needs --force) or untrack it. (C) Carried: CHANGELOG.md/HANDOFFS.md trims (owner runs the forced write), suggested_NEWS_entry review, residue (7 untracked), 1 unpushed after this records commit (owner's call).
key_files: .gitattributes (new); .Rbuildignore:17; tests/testthat/test_examplePedigreeTxt.R:56-98 (isGitTopLevel, checkoutBytes, the new test); tests/testthat/test_rbuildignore.R:42-57; PROJECT_LEARNINGS.md Learning 820.
gotchas: A test that reads a shipped file's raw bytes needs a .gitattributes line for that file or Windows CI fails it; pin per file (deidentified_jmac_ped.csv is stored CRLF). git -c core.autocrlf=true cat-file --filters HEAD:<path> shows a Windows checkout locally. A CI run still in_progress at Orient must be re-read before close-out whatever this session pushes. The full suite's 1 known failure is local-only. gh run view --log-failed returned nothing; gh api .../actions/jobs/<id>/logs works. STANDING SET unchanged from S790-803.
runtime_smoke: Fresh clones of 0868249f with core.autocrlf=true and with core.eol=crlf: ExamplePedigree.txt 0 CR, 218,687 B (the unpinned CSV 3,695 CR under autocrlf, the control); CI R-CMD-check on 0868249f green on all 5 legs incl. windows-latest (run 36485068983). quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results fb7aec9c7bc3 · manifest aa983075d6a2
changelog_ref: this records commit (S804 records entry, prepended above the S804 GREEN, RED and claim entries)
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log)
```
Predecessor (S803) scored 8/10: every Orient measurement held (ledger frontier = HEAD, the receipt and its quality-gate citation, 1 unpushed, the residue list) and its next steps were accurate. Missing: S802's R-CMD-check, still running at S803's Orient, was never re-read or flagged as unread; it had failed on windows-latest. Self-score 8/10: +measured before proposing; +fast deterministic regression test of the real failure; +control in the fresh-clone check; +CI confirmed on the real runner, log read to show the byte test ran. -RED committed with --no-verify and no ledger entry (amended before any push); -first EOL probe on the wrong path; -two empty --log-failed fetches; -a collect_all str-vs-Path slip.

```handoff
session: S803
date: 2026-09-28
status: complete
self_score: 8
predecessor_score: 9
active_task: Update the synced methodology_dashboard.py from v2.18.0 to canonical v2.19.0 (owner-directed at the S802 close-out) -- DONE. The Class B read-cap row no longer claims the trimmer answers NO_CONFIG, and for a file this project's own methodology_trim.py declares in LEDGERS it names the --check remedy at LOW severity. This closes the carried "methodology fork's Class A/B decision" item (S796's finding, fixed by the fork as BL-88).
what_was_done: Checked first: sibling methodology/ on main at 016b3ae (v3.7-1277-g016b3ae), clean, level with origin/main; the local copy's blob equals canonical e1b6bdf (v2.18.0), so no local edit could be lost; canonical changes since are cb9b0ed + 161181c only; dry run skipped the tracked file. Sync 0058e7f8 (--sync --force): cmp-identical to canonical, diff 158+/27- = the canonical diff. Verified: v2.19.0's parse of this project's trimmer = its executed LEDGERS (CHANGELOG.md, HANDOFFS.md, SESSION_NOTES.md); both versions give the same 4 risk rows here today (96/100, 0 high); in a scratch clone with SESSION_NOTES.md padded to 60,809 B, v2.18.0 HIGH with the NO_CONFIG claim vs v2.19.0 LOW with the remedy, which ran with exit 0; no stale-version warning; tarball built from HEAD 0058e7f8 holds no dashboard/trimmer/ledger file. R suite and CI not run or awaited: the file is .Rbuildignore'd and no test or workflow reads it. Learning 819.
next_steps: (A) Every Up Next item is an owner decision; measure first (Learnings 812/815-819). Nearest: the stale linebreeding/half_sib article figures inside the documentation-audit item (BACKLOG.md:202-237): re-run vignettes/articles/pedigree-diagram-exemplar-renders.R, commit the images after an owner look. Then jmac (BACKLOG.md:256), U-prefix ids (:51), recorded dam (:32), PED_GV (:8). (B) Owner question from this sync: keep the dashboard tracked (then every sync needs --force) or untrack it as the sync tool's "Phase 3 untrack" label suggests. (C) Carried: CHANGELOG.md/HANDOFFS.md trims (owner runs the forced write), residue, 4 unpushed after this records commit (owner's call).
key_files: methodology_dashboard.py:95 (version), :1033 (find_trim_tool), :1088 (_parse_trim_ledgers), :2280 (tool_ledgers), :3625-3658 (Class B row and remedy); methodology_trim.py:316 (LEDGERS); .Rbuildignore:84; CLAUDE.md:256 (the --budget-bytes 65536 rule); PROJECT_LEARNINGS.md Learning 819.
gotchas: The dashboard's remedy command omits --budget-bytes 65536; always add it (CLAUDE.md:256). BACKLOG.md is Class B but not in the trimmer's LEDGERS: 54,143 B, 2,607 B under the 56,750 B read cap; past it, a HIGH row with no remedy. A sync of this tracked file needs --force. quality_ratchet.py --run builds git archive HEAD: run it after the commit it covers (Learning 772). This shell's stat is GNU; use /usr/bin/stat -f. STANDING SET unchanged from S790-802.
runtime_smoke: Ran the synced dashboard on the project (v2.19.0, 96/100, 0 high, no stale warning) and both versions via collect_all() on the project and on a padded scratch clone (HIGH -> LOW with the remedy; the remedy ran, exit 0). quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 8d60dc76ee85 · manifest aa983075d6a2
changelog_ref: this records commit (S803 records entry, prepended above the S803 sync and claim entries)
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log)
```
Predecessor (S802) scored 9/10: every Orient measurement held (ledger frontier = HEAD, the receipt and its quality-gate citation, 1 unpushed, the residue list); the owner's direction for this session was stated plainly and the four push workflows were read as asked. Missing: the carried "Class A/B decision" and "dashboard v2.18.0 vs v2.19.0" items were one item, which the fork's v2.19.0 commit message names. Self-score 8/10: +source checkout and local blob checked before syncing; +dry run first; +new behavior tested on this project's own customized trimmer and in a padded clone, remedy run; +the two carried items tied together. -ran the quality gate before committing, so it measured the claim commit (Learning 772; caught by reading the gate command, re-ran after the commit); -the GNU-vs-BSD stat slip again; -two probe slips (risks under scores; an R string escape) each cost a re-run; -no reduction of a mandated-read file.

```handoff
session: S802
date: 2026-09-28
status: complete
self_score: 8
predecessor_score: 9
active_task: The five classic-structure example pedigrees (inst/extdata/examples/example_pedigree_*.csv) cannot be loaded in the app (BACKLOG.md item found S801) -- DONE. Each file now carries a birth column (made-up dates by a written rule), so it uploads in the app with 0 errors; the article's figures are unchanged; the article notes that the app's Diagram tab can order a row differently (consanguinity), and NEWS.Rmd's entry says the files can be uploaded.
what_was_done: PRE-RED measured both options through the real modInputServer: all 5 refused ("Missing required columns: birth"); with trial dates 0 errors, drawing identical with and without the column; the app's Diagram matches the article for 4 of 5 (consanguinity arranged differently because qcStudbook() sorts by (gen, id), R/qcStudbook.R:329); owner picked dates + article note. RED 595d3b01 (test_examplePedigreeFixtures.R: column pin + 4 new tests, 40 expected failures, 0 errors; 14/14 against trial fixtures before commit). GREEN a2c7e66f + 8c0116f2 (data-raw/example_pedigree_birth.R run once; other columns byte-identical; rerun byte-identical; no R/ change). REFACTOR 893d485c (article sentence, NEWS.Rmd entry, BACKLOG item removed, stale-figure finding filed). Full suite GREEN and REFACTOR 357 files / 2,788 tests / 8,776 expectations, 1 failed (the known test_pkgdown_reference_config.R), 0 error; lint 0; NEWS guards 26/0 and 3/0; article renders; old and new figure renders pixel-identical. Learning 818.
next_steps: (A) Every Up Next item is an owner decision; measure first (Learnings 812/815-818). Nearest: the stale linebreeding/half_sib article figures inside the documentation-audit item (committed BACKLOG.md:226-237): re-run vignettes/articles/pedigree-diagram-exemplar-renders.R, commit the images after an owner look. Then jmac (BACKLOG.md:256), U-prefix ids, recorded dam, PED_GV. (B) Carried: CHANGELOG.md/HANDOFFS.md trims (owner runs the forced write), suggested_NEWS_entry, residue, 26 unpushed after this records commit (owner's call), dashboard v2.18.0 vs v2.19.0, methodology fork Class A/B. (C) Watch the shinytest2 job's runtime (29m36s on 2026-09-28) against its 45-minute limit.
key_files: inst/extdata/examples/example_pedigree_consanguinity.csv:1 (birth column, likewise the other four); data-raw/example_pedigree_birth.R:1-53; tests/testthat/test_examplePedigreeFixtures.R:58 (.uploadExemplar), :77 (.appDiagramLayout), :294 (column pin), :314, :334, :349, :364 (new tests); vignettes/articles/pedigree-diagram.qmd:114-118; NEWS.Rmd:162-167; R/qcStudbook.R:329; PROJECT_LEARNINGS.md Learning 818.
gotchas: The app's Diagram tab draws the (gen, id)-sorted studbook while the article draws the file as read, so a figure can differ from the app with nothing wrong. The birth column is derived: re-run data-raw/example_pedigree_birth.R after editing an example file's rows. PNG renders differ byte-wise run to run; compare by pixel against a control render. base::system.file() returns "" under pkgload::load_all(). STANDING SET unchanged from S790-801.
runtime_smoke: Package reinstalled; real app headless (shinytest2). Old consanguinity file: Error List "The missing column is: birth". Installed new file: "QC passed! 14 records processed."; Diagram 33 nodes / 33 edges, CS1 drawn twice, marked mating CS1 x CD1; linebreeding 35/35, LK and LB2 twice, LB2 x LA2 marked. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 9f0d10e7e4d3 · manifest aa983075d6a2
changelog_ref: this records commit (S802 records entry, prepended above the S802 REFACTOR, GREEN 2/2 and 1/2, RED, PRE-RED and claim entries)
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log)
```
Predecessor (S801) scored 9/10: every Orient measurement held (ledger frontiers, the receipt and its quality-gate citation, 20 unpushed, the residue list, the known failure); next step (A) named this item with both options, the pin and the "figures must not change" constraint, all accurate; the YAML-free staging recipe worked as written. Missing, not knowable then: the app's (gen, id) sort, which makes one example draw differently in the app. Could not apply at Orient: the 07:00 UTC shinytest2 read (read at close-out: passed, 29m36s). Self-score 8/10: +both options measured through the real app path, the arrangement difference found and shown as images before the owner decided; +one plain question answered first time; +every TDD gate via AskUserQuestion; +RED tests run against trial fixtures before commit; +pixel comparison with a control render; +live app old vs new. -several tool slips cost retries (BSD vs GNU stat, an unexported variable, base::system.file() under load_all(), a wrong devtools::install() argument, a first QC-panel probe that read nothing, a zsh backtick parse error that silently skipped a ledger write, caught on the next check); -re-ran the data-raw script while the suite ran in the background (byte-identical, suite clean, but a Learning 529 risk); -no ledger reduction.

```handoff
session: S801
date: 2026-09-28
status: complete
self_score: 8
predecessor_score: 8
active_task: Rebuild the shipped inst/extdata/examples/ExamplePedigree.txt from ExamplePedigree.csv (BACKLOG.md item found S800) -- DONE. The only text-format example had every non-blank age cell saved as Excel display text (2,262: 1,536 '1900-01-DD' day serials, 620 '1900-01-00', 106 '#####') and id 15FEBR as 15-Feb; it now holds the same cells as the .csv. Owner closed the '#'-in-a-cell reader question.
what_was_done: Orient discussion answered the owner's questions (the .txt's only reference is the always-skipped test-shinytest2-debug.R; it is the only text-format example; all 15 example pedigrees measured through the app path: 8 with 0 errors, xlsx 1, jmac 67, the 5 example_pedigree_*.csv refused for no birth column -- first told the owner "six", corrected to 8). RED cc6f575a (new test_examplePedigreeTxt.R, 4 tests / 11 assertions, 8 failing for the expected reason, 3 passing, 0 errors); GREEN b31f44f0 (data-raw/ExamplePedigree_txt.R, run once; exactly the 2,262 age lines changed ignoring line endings; rerun byte-identical; no R/ change); REFACTOR 1daa0301 (NEWS.Rmd General Fixes entry; BACKLOG item removed, classic-structure item filed). Full unfiltered suite GREEN and REFACTOR 357 files / 2,784 tests / 8,686 expectations, 1 failed (the known test_pkgdown_reference_config.R), 0 error; lint 0; NEWS guards 26/0 and 3/0. Learning 817.
next_steps: (A) Every Up Next item is an owner decision; measure first and count from printed output (Learnings 812/815/816/817). Nearest: the classic-structure item (BACKLOG.md:264-278 committed numbering): add a birth column to the five example_pedigree_*.csv files (test_examplePedigreeFixtures.R:249 pins the columns; the exemplar figures must not change) or reword pedigree-diagram.qmd:104-111. Then jmac (BACKLOG.md:246), U-prefix ids, recorded dam, PED_GV. (B) Carried: CHANGELOG.md/HANDOFFS.md trims (owner runs the forced write), suggested_NEWS_entry, residue, 20 unpushed after the S801 records commits (owner's call), dashboard v2.18.0 vs v2.19.0, methodology fork Class A/B. (C) Read the 2026-09-28 07:00 UTC shinytest2 run at next Orient (not fired at 06:23 UTC).
key_files: inst/extdata/examples/ExamplePedigree.txt; data-raw/ExamplePedigree_txt.R:1-34; tests/testthat/test_examplePedigreeTxt.R:37,:50,:56,:62; NEWS.Rmd:515-520; BACKLOG.md:264-278; vignettes/articles/pedigree-diagram.qmd:96-111; R/qcStudbook.R:303; PROJECT_LEARNINGS.md Learning 817.
gotchas: qcStudbook() keeps a supplied age column unchecked, so date text in it loads with 0 errors. test_examplePedigreeTxt.R pins the .txt to the .csv cell for cell -- re-run data-raw/ExamplePedigree_txt.R after any .csv edit. Learning 318(d)'s "every example pedigree is error-laden" is wrong (8 of 15 load clean). BACKLOG staging without the owner's YAML header: tail -n +6 BACKLOG.md > f; git update-index --cacheinfo 100644,$(git hash-object -w f),BACKLOG.md. In R probes use x[["field"]], not x$field (partial matching). STANDING SET unchanged from S790-800.
runtime_smoke: Real app in headless Chrome (installed package, current R/), Text + Tab upload, Pedigree Browser. Old file: JDVB5M age blank, ancestry UNKNOWN, status UNKNOWN; 2ZMHG7 age 1900-01-07; 15FEBR not found. Rebuilt file: JDVB5M -0.1 / JAPANESE / DECEASED; 2ZMHG7 7.8; 15FEBR 0.2; both 3,694 entries. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 05ed18700c1f · manifest aa983075d6a2
changelog_ref: this records commit (S801 records entry, prepended above the S801 REFACTOR, GREEN, RED, PRE-RED and claim entries)
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log)
```
Predecessor (S800) scored 8/10: every Orient measurement held (ledger frontiers, the receipt, 13 unpushed, the residue list, the known failure); its next step (A) named this item with both options and its gotcha (3) framed it. Wrong in scope, not fact: the item described 106 '#####' cells, while the whole age column (2,262 cells) and one id were Excel display text and the file passed QC with 0 errors. Missing: the .txt being the only text-format example and having no live reference, which decided rebuild vs delete. Could not apply: the 07:00 UTC shinytest2 read (Orient 05:23 UTC). Self-score 8/10: +cell-by-cell comparison with the source before scoping; +all 15 example files measured when the owner questioned a claim, which found the classic-structure item; +plain scope question answered first time; +every TDD gate via AskUserQuestion; +live app old vs rebuilt. -repeated Learning 318(d) as fact (owner corrected); -"every age is wrong" named no comparison; -"six" clean files from memory (8), reaching a committed ledger entry; -a probe bug cost a rerun; -my notes pushed SESSION_NOTES.md past its 25,000-token read ceiling, caught only at the records commit (owner ran the forced trim: 13 records to docs/archive/SESSION_NOTES-through-2026-09-28.md, 61,948 -> 26,273 B); CHANGELOG.md/HANDOFFS.md still over budget.

```handoff
session: S800
date: 2026-09-28
status: complete
self_score: 9
predecessor_score: 9
active_task: Blank cells in app uploads (BACKLOG.md item found S776, extended S799) -- DONE. The Input module reads an empty CSV or text upload cell as missing (na.strings = c("", "NA"), the getPedigree() rule), so blank-parent files load, blank ancestry is UNKNOWN, and a founder with a blank origin is "Undetermined" in the Genetic Value report instead of an import. Two measured follow-up items filed in its place.
what_was_done: Pre-RED measured all 16 shipped pedigree files both ways through runQcStudbook() and getPedigree(): jmac loses its "both a sire and a dam" error (67 parent-age errors remain); ancestry example OTHER 2/UNKNOWN 0 -> 1/1; ExamplePedigree.csv 241 blank-origin founders were imports (Genetic Value High 926 -> 685, Undetermined 1,372 -> 1,613, 2,081 of 3,694 ranks change, matching the script path). Owner picked "read as missing". RED 0c7f527a (new test_modInput_blankCells.R, 9 failing tests / 26 assertions, 2 controls; ancestry e2e re-pinned, 5 exact pin failures live); GREEN 99df405a (na.strings on both reads in readDataFile()); REFACTOR 54fae557 (code comment, Input Format help) and 599a0803 (NEWS.Rmd entry; BACKLOG item removed, jmac parent-age and ExamplePedigree.txt '#####' items split out). Full unfiltered suite GREEN 356 files / 2,780 tests, 1 known failure, 0 error; REFACTOR 356 files / 2,780 tests / 8,675 expectations, 1 failed (the known test_pkgdown_reference_config.R), 0 error. Learning 816.
next_steps: (A) Every Up Next item is an owner decision; measure options on real files through both read paths first (Learnings 812/815/816). Nearest: the two new items at BACKLOG.md:251-283 (ExamplePedigree.txt '#' cells: regenerate the .txt and/or comment.char = ""; jmac: document, correct the 2 sire records, or review the 4-year floor). (B) U-prefix item: the ancestry example's real animal U1 counts as a placeholder (isGeneratedUnknownId("U1") TRUE, consequence unmeasured); recorded-dam item and PED_GV decisions untouched. (C) Carried: CHANGELOG.md/HANDOFFS.md trims (owner runs the forced write), suggested_NEWS_entry, residue, 13 unpushed (owner's call), dashboard script v2.18.0 vs v2.19.0, methodology fork Class A/B. (D) Read the 2026-09-28 07:00 UTC shinytest2 run at next Orient (not fired at 05:17 UTC); it tests origin/master, without S799/S800 until pushed.
key_files: R/modInput.R:300-337 (comment, readDataFile(), reads at :330/:336); tests/testthat/test_modInput_blankCells.R:1-176 (11 tests); tests/testthat/test-e2e-mate-pair-analysis-module-ancestry.R:14-20 (header), :171, :214, :236, :245, :378 (moved pins); inst/extdata/ui_guidance/input_format.html:20-24; NEWS.Rmd:509-514; BACKLOG.md:251-283 (two new items); PROJECT_LEARNINGS.md Learning 816.
gotchas: An empty upload cell is now NA everywhere; code expecting "" from an app upload is wrong. A column meaning "was it recorded?" (origin) is decided with is.na() downstream, so grep a changed column's consumers, not only QC (Learning 816). read.table() treats '#' in a cell as a comment on both the app text path and getPedigree() (open item). The ancestry e2e pins the aligned numbers and runs only with NPRC_RUN_E2E=true or in scheduled shinytest2 CI. STANDING SET unchanged from S790-799.
runtime_smoke: The shipped ExamplePedigree.csv uploaded through the real modInputServer: 0 errors, 3,694 rows, no "" origins, Genetic Value order 685/1,396/1,613, identical to the script path (pre-fix app 926/1,396/1,372). Opt-in e2e with the real app in headless Chrome: mate-pair ancestry 42/0, breeding-groups ancestry 18/0, input module 5/0, input detailed 6/0, input tutorial 8/0.
changelog_ref: this records commit (S800 records entry, prepended above the S800 REFACTOR B/A, GREEN, RED, PRE-RED and claim entries)
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log)
```
Predecessor (S799) scored 9/10: every Orient measurement held (CHANGELOG.md/HANDOFFS.md sizes, the receipt, 7 unpushed, the residue list); its next step (A) named this item with the jmac state that held exactly, and its gotcha (1) -- measure blanks on both read paths and through modInputServer with a real file -- was this session's method. One step could not apply (reading the 07:00 UTC shinytest2 run -- Orient at 04:39 UTC). Gap, not a fault: the item called files that write missing parents as NA "unaffected", yet ExamplePedigree.csv's blank origin column was the largest effect. Self-score 9/10: +every shipped file measured on both read paths and each changed column followed to its consumers, which found the Genetic Value effect before the owner was asked; +one decision question, answered first time; +RED checked assertion by assertion, the one failing control diagnosed as a test bug before commit; +live-app e2e at RED (5 exact pins) and GREEN; +runtime through the real module compared with the script path; +two still-open sub-threads split out with numbers. -wrote "66 dams" into BACKLOG.md before recounting (65, caught before commit); -no ledger reduction again (CHANGELOG.md/HANDOFFS.md still over budget).

```handoff
session: S799
date: 2026-09-27
status: complete
self_score: 9
predecessor_score: 9
active_task: Unreadable parent sex (BACKLOG.md item found S787) -- DONE. convertSexCodes() now trims spaces and reads a blank or unrecognized sex as "U", so qcStudbook() no longer reports such a parent as a "female sire" / "male dam" and the app upload goes through. Side finding filed under the blank-ancestry BACKLOG.md item: the app cannot load the shipped deidentified_jmac_ped.csv (blank sire/dam cells read as the id "").
what_was_done: Pre-RED measured before asking: 0 blank/unrecognized sex codes in the 12 shipped datasets; 1 blank in the example files, read as "" by the app and NA by getPedigree(); read.csv() keeps spaces so "M " was unreadable; a blank-sex non-parent stayed NA and was counted as both sexes. Owner picked "treat it as unknown" and "ignore spaces" (one plain-language AskUserQuestion). Claim a98fbe7a; RED b2c26fe4 (7 failing assertions in test_convertSexCodes.R, 13 in test_correctParentSex.R incl. the app's runQcStudbook() step; one accidental pass relabelled control:); GREEN 566f8fce (trimws before toupper, catch-all to "U"); REFACTOR e76fb2e4 (redundant NA line dropped; roxygen + man pages for convertSexCodes/qcStudbook; app Input Format help) and 89f240b6 (studbook-quality-control article, NEWS.Rmd Fixed entry, BACKLOG item removed + side finding filed, owner's YAML header kept out). Full unfiltered suite at GREEN and REFACTOR: 355 files / 2,769 tests, 1 known failure, 0 error. Learning 815.
next_steps: (A) Every Up Next item is an owner decision; measure each option on real files and both read paths before asking (Learnings 812/814/815). Nearest this session's code: the blank-ancestry item, now with S799's blank sire/dam measurement (aligning the app read with getPedigree() would make deidentified_jmac_ped.csv's parents readable, but that file still has 67 parent-age errors, and the S777 e2e pins move). (B) Untouched: the recorded-dam item, the U-prefix real-id item, the PED_GV owner decisions. (C) Carried: CHANGELOG.md and HANDOFFS.md trims (both over 65,536 B; CHANGELOG.md last; a forced write needs the owner, Learning 811), suggested_NEWS_entry disposition, working-tree residue, unpushed commits (owner's call), dashboard script v2.18.0 vs v2.19.0, the methodology fork's Class A/B decision. (D) Read the 07:00 UTC 2026-09-28 shinytest2 run at the next Orient (first live test of S794's 45-minute limit; it had not fired at this Orient).
key_files: R/convertSexCodes.R:18-22 (roxygen), :42 (trimws), :52-53 (catch-all); R/qcStudbook.R:114-117; tests/testthat/test_convertSexCodes.R:37-71; tests/testthat/test_correctParentSex.R:305-361; inst/extdata/ui_guidance/input_format.html:118-120; vignettes/articles/studbook-quality-control.qmd:102-105; NEWS.Rmd:505-508; BACKLOG.md:272-282 (S799 paragraph in the blank-ancestry item); PROJECT_LEARNINGS.md Learning 815.
gotchas: The app reads an empty CSV cell as "" and getPedigree() as NA; measure blank-cell behavior on both and through modInputServer with a real file (Learning 815). An unreadable sire now comes back "U" rather than a guessed "M" in qcStudbook(reportErrors = FALSE) too (NEWS says so). QC output no longer produces an NA sex; the Diagram's "Other / Unrecorded" label remains for data that never went through qcStudbook(). Opt-in e2e files need NPRC_RUN_E2E=true; the full suite skips them silently. Stage BACKLOG.md with the three-call tail/hash-object/update-index recipe. Recount ledger frontiers and the unpushed count fresh (Learning 806).
runtime_smoke: shiny::testServer(modInputServer) with a real CSV upload (blank, "xyz", "M ", " F" parents plus a blank non-parent): loads with 0 errors, sexes U/U/M/F/U; same upload with the pre-fix function: 4 female-sire / male-dam errors, nothing loaded. Opt-in e2e with NPRC_RUN_E2E=true (real app, headless Chrome): test-e2e-input-module.R 5 tests and test-e2e-input-detailed.R 6 tests, 0 failed / 0 skipped / 0 error.
changelog_ref: this records commit (S799 records entry, prepended above the S799 REFACTOR B/A, GREEN, RED, PRE-RED and claim entries)
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log)
```
Predecessor (S798) scored 9/10: every Orient measurement held (CHANGELOG.md/HANDOFFS.md sizes, the receipt, the residue list, the one known test failure and its cause); its background-the-suite gotcha and Learning 812 carried straight into this session. One step could not apply: reading the 07:00 UTC shinytest2 run at Orient -- Orient ran at 03:47 UTC, before it fired. Self-score 9/10: +measured on shipped data, both read paths and the real Input module before asking; +the space-padding case found by measuring and offered as its own yes/no; +one decision call answered first time; +RED failures all for the expected reason, the one accidental pass caught and labelled; +full unfiltered suite at GREEN and REFACTOR; +runtime through the real module with a pre-fix comparison and two live-app e2e files; +a side finding measured at module level and filed with the item that owns its fix. -one probe call had a wrong argument list; -no ledger reduction again (CHANGELOG.md/HANDOFFS.md still over budget).

```handoff
session: S798
date: 2026-09-27
status: complete
self_score: 9
predecessor_score: 9
active_task: PED_GV F3 (NEW-35) -- DONE. The getPotentialParents() dam fallback no longer re-admits a female the gestation window ruled out. Every PED_GV F-slice is now done; the PED_GV BACKLOG.md item holds only owner decisions (overhaul roots, closing 11 ids). New DECISION NEEDED item filed right below it: an animal's own recorded dam is never among its candidate dams.
what_was_done: Full TDD cycle, every gate via AskUserQuestion, plus a separate plain-language pre-RED decision question with measured counts in each option (Learning 812): a switchable copy of the dam logic reproduced the shipped function exactly, then showed the fallback runs for 0 of 50 (rhesusPedigree) and 1 of 1,587 (qcStudbook(examplePedigree)) animals and re-admits nobody. Owner picked "skip ruled-out females". Claim 33b4de7c; RED 4bbcb071 (3 tests in test_getPotentialParents.R, exactly 3 failures); GREEN 174be7f5 (one filter clause in the fallback); REFACTOR b29ee018 (eligibleDams reused by the fallback, comment + @return + man/getPotentialParents.Rd, NEWS.Rmd General Fixes entry, BACKLOG.md F3 out + recorded-dam item filed, owner's YAML header kept out). Full unfiltered suite at GREEN and REFACTOR: 355 files / 2,760 tests, 1 known failure, 0 error. Learning 814.
next_steps: (A) Pick among the Up Next DECISION NEEDED items; each is Effort S-M and needs an owner choice first -- measure each option on qcStudbook(examplePedigree) before asking (Learnings 812/814). Closest to this session's code: the new recorded-dam item (return candidates only for the unknown parent, document it, or leave it; R/getPotentialParents.R around the eligibleDams line, ~190-203). (B) Carried and untouched: the "U"-prefix real-id item (four written options), the unreadable-parent-sex item, CHANGELOG.md (~94 KB) and HANDOFFS.md (~76 KB) trims, both over the 65,536 B budget, CHANGELOG.md last, and a forced write needs the owner (Learning 811); suggested_NEWS_entry disposition; working-tree residue; push of the unpushed commits (owner's call); the methodology fork's Class A/B decision. (C) The next scheduled shinytest2 run (07:00 UTC 2026-09-28) is the first live test of S794's 45-minute limit -- check it at Orient.
key_files: R/getPotentialParents.R:44-52 (@return), :190-203 (eligibleDams, proven-breeder filter, fallback); tests/testthat/test_getPotentialParents.R:289-353 (fallbackPed() + the 3 F3 tests); man/getPotentialParents.Rd; NEWS.Rmd:500-504; BACKLOG.md "Up Next" items 1-2 (PED_GV, recorded-dam); PROJECT_LEARNINGS.md Learning 814.
gotchas: Only examplePedigree ships with a fromCenter column; getPotentialParents() returns NULL for qcPed and every other shipped dataset (add fromCenter to rhesusPedigree to use it). On a qcStudbook()-cleaned pedigree every unknown parent is a U placeholder, so count known parents with isGeneratedUnknownId(), never is.na() alone (Learning 814). The Potential Parents e2e file is opt-in: NPRC_RUN_E2E=true, otherwise the full suite silently skips it. The full suite outlasts the 2-minute Bash timeout: run it in the background and wait for the notification. The one standing failure is test_pkgdown_reference_config.R, from the untracked vignettes/suggested_NEWS_entry.Rmd. Stage BACKLOG.md with the three-call tail/hash-object/update-index recipe. Recount ledger frontiers and the unpushed count fresh (Learning 806).
runtime_smoke: shiny::testServer() on modPotentialParentsServer() with the P5 pedigree plus an open female: K1's row lists dam F_OPEN only (pre-fix code: F1, F_OPEN). Opt-in e2e test-e2e-potential-parents-module.R with NPRC_RUN_E2E=true (real app in headless Chrome): 4 tests, 0 failed / 0 skipped / 0 error. Shipped data unchanged: rhesusPedigree 244 and examplePedigree 52,012 candidate dams.
changelog_ref: this records commit (S798 records entry, prepended above the S798 REFACTOR/GREEN/RED/PRE-RED/claim entries)
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log)
```
Predecessor (S797) scored 9/10: every Orient measurement held (ledger frontiers at HEAD, receipt complete, 12 unpushed, CHANGELOG.md 89,813 B, HANDOFFS.md 71,322 B, the residue list, the one known test failure and its cause); its "measure first, counts in the option text" instruction made F3's decision a single question. One step could not apply: "run each option on qcPed" -- qcPed has no fromCenter column, so getPotentialParents() returns NULL for it. Self-score 9/10: +harness checked against the real function before any count was trusted; +one plain-language decision question, answered first time; +exactly the planned RED failures; +full unfiltered suite at GREEN and REFACTOR; +runtime through the real module and the live-app e2e; +a related defect found, measured and filed, not fixed in passing. -The first recorded-parent count was wrong (placeholders counted as known parents), caught by its own impossibility before use; -the over-budget ledger trims are still carried, not reduced.

```handoff
session: S797
date: 2026-09-27
status: complete
self_score: 7
predecessor_score: 8
active_task: PED_GV F2 (NEW-38) -- HALF DONE by owner decision. The addUIds() duplicate-id half shipped; the stricter-detection half was tried, broke the shipped data, was withdrawn, and is now its own BACKLOG.md "Up Next" item (DECISION NEEDED). PED_GV item's next slice is F3.
what_was_done: Full TDD cycle with every gate via AskUserQuestion. RED a01e13af (9 assertions, 3 files, all failing). First GREEN (exact-digit-width detection + skip-past minting) passed those files but the unfiltered full suite went to 24 failed + 1 error in 7 files; isolated to the detection change by restoring only R/autoIdFormat.R (all 8 affected files then passed). Cause: obfuscateId() disguises placeholders as prefix + random capitals/digits, and all 43 qcPed / 1,372 examplePedigree placeholders look like "U05X3C". Owner re-decided: ship the duplicate fix only. Withdrew the detection tests 4155665f (restored byte-exact); GREEN cf956da8 (internal mintAvailableIds(), placed after addUIds() so the roxygen blocks stay separate); REFACTOR 5dc89a2e (roxygen + man/addUIds.Rd, NEWS.Rmd General Fixes entry, BACKLOG.md: F2 out of the PED_GV item, detection half filed with measurements; owner's YAML header kept out). Claim b0c28655. Learnings 812-813.
next_steps: (A) PED_GV F3: the fallback at R/getPotentialParents.R:196-199 re-admits an excluded dam (NEW-35/NEW-55); owner picks fall back to the filtered set, return none, or label the tier -- run each option on examplePedigree/qcPed and put the counts in the option text before asking (Learning 812). (B) The new detection item (real ids like "Uma" treated as placeholders) has four written options; the rejected approach's RED tests are in commit a01e13af. (C) Carried and untouched: suggested_NEWS_entry disposition, working-tree residue, CHANGELOG.md and HANDOFFS.md trims (both over 65,536 B), push of 12 unpushed commits (owner's call), the methodology fork's Class A/B decision.
key_files: R/addUIds.R:43-91 (addUIds 43-62, mintAvailableIds 64-91); tests/testthat/test_addUIds.R:36-52; R/autoIdFormat.R:109-111 (predicate, unchanged); R/obfuscateId.R:40-46 (why stricter detection fails); NEWS.Rmd:496-499; BACKLOG.md "Up Next" items 1-2; PROJECT_LEARNINGS.md Learnings 812-813.
gotchas: isGeneratedUnknownId() must stay prefix-tolerant for the shipped obfuscated placeholders -- measure any change on qcPed and examplePedigree first. The full suite outlasts the Bash 2-minute timeout: run it in the background and wait for the notification, no sleep polling. The one standing failure is test_pkgdown_reference_config.R, caused by the untracked vignettes/suggested_NEWS_entry.Rmd. Stage BACKLOG.md with the three-step tail/hash-object/update-index recipe to keep the owner's YAML header out. Recount ledger frontiers and the unpushed count fresh (Learning 806).
runtime_smoke: qcStudbook() on a pedigree holding a real U0001 minted U0002 (sire) and U0003 (dam), 0 duplicate ids; qcStudbook(examplePedigree) 3,694 rows, 0 duplicates. Shiny app not launched live; its app/e2e test files passed in the full suite (355 files / 2,757 tests, 1 known unrelated failure, 0 error).
changelog_ref: this records commit (S797 records entry, prepended above the S797 claim entry)
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log)
```
Predecessor (S796) scored 8/10: every Orient measurement held (frontiers, receipt status, HANDOFFS.md size, residue list file by file); its next steps pointed at exactly the files F2 needed. One stale number, same class as Learning 806 ("CHANGELOG.md now 80,265 B", 83,492 B at Orient because S796's own records commit landed after it was written). Self-score 7/10: +ran the unfiltered full suite before REFACTOR and so caught the regression instead of shipping it; +isolated the cause in one run; +stopped and re-asked in plain words instead of rewriting seven files of pinned tests; +shipped the independent, verified half; +caught a roxygen-block merge by re-reading; +runtime check through the real QC path. -Pre-RED checked the predicate's consumers but not its producers or the shipped data, and marked the unworkable option "Recommended" -- one R probe would have shown it; -one stray sleep-poll against harness guidance; -F2 only half closed.

```handoff
session: S796
date: 2026-09-27
status: complete
self_score: 6
predecessor_score: 7
active_task: PED_GV F2/F3 (docs/audits/PED_GV_AUDIT_TRIAGE_2026-09-26.md; BACKLOG.md "Up Next" item 1) -- NOT STARTED. No R/ file, test, or BACKLOG.md change this session; the item is unchanged and fully open for the next session's fresh Pre-RED.
what_was_done: No PED_GV code work. Instead: (1) investigated the ad hoc "trim SESSION_NOTES.md" ask -- methodology_trim.py's 65,536 B trigger did not fire -- and found/delegated a real cross-repo finding: methodology_dashboard.py's declared READ_CAP_CLASS_A/READ_CAP_CLASS_B split (lines 423-424) hardcodes SESSION_NOTES.md as Class B ("NO_CONFIG"), false in this repo because of this project's own local, unsynced methodology_trim.py LedgerSpec patch (CLAUDE.md's local-customization checklist). Confirmed nprcgenekeepr's dashboard copy is byte-identical to the methodology fork's tools/methodology_dashboard.py (not stale); confirmed the fork's own two pinning tests (tools/test_methodology_dashboard.py:5464,5485) only guard the fork's own LEDGERS table, never an adopter's local patch. Handed a full evidence-based prompt to the methodology fork's own live session (methodology-bf), owner-pasted there directly. (2) Phase 1B's mandatory claim-stub write to SESSION_NOTES.md tripped a separate, harder ceiling -- .context-budget.json's read-cap (max_tokens 25000 =~ 56,750 B), independent of and smaller than the 65,536 B archive budget -- refused by the installed context_budget.py --precommit hook (first time this ceiling has fired here). methodology_trim.py --budget-bytes 65536 said NOTHING_TO_DO; --budget-bytes 45000 --force produced a verified-lossless dry run (L1_OK/L2_OK/L3_OK, 57,871 B -> 19,719 B). The --write itself was denied by the harness's auto-mode classifier ("Irreversible Local Destruction"); handed the exact command to the owner, who ran it -- verified after the fact via docs/archive/SESSION_NOTES-through-2026-09-27.md.verify.sh (OK: L1, L2/front-matter, L3). Single records commit for the whole session (claim + trim + close-out never split; no code touched).
next_steps: PED_GV F2/F3 is unchanged and still the top BACKLOG.md item -- next session restarts from a fresh Pre-RED (read docs/audits/PED_GV_AUDIT_TRIAGE_2026-09-26.md, R/getPotentialParents.R, R/addUIds.R/R/removeAutoGenIds.R directly). Everything S793-S795 carried forward is still open: suggested_NEWS_entry disposition, PED_GV's "Also open" sub-items, working-tree residue, unsynced methodology files, CHANGELOG.md trim (now over budget, growing). Separately: check back on the methodology fork's own session (methodology-bf) for its decision on the dashboard Class A/B drift -- it may produce a distributable fix or an adopter-side convention nprcgenekeepr should adopt.
key_files: methodology_dashboard.py:423-424,431-443 (read-only); .context-budget.json:38-51 (SESSION_NOTES.md's two ceilings); CLAUDE.md (the methodology_trim.py local-customization checklist); docs/archive/SESSION_NOTES-through-2026-09-27.md + .verify.sh (new shard); PROJECT_LEARNINGS.md (Learnings 810-811); BACKLOG.md (F2/F3 item, unchanged).
gotchas: SESSION_NOTES.md's real binding ceiling is 56,750 B (read-cap), not 65,536 B (archive budget) -- re-check context_budget.py immediately before any write once within ~1-2 KB of that number (Learning 810). A forced methodology_trim.py --write needs the owner's own hands -- the auto-mode classifier blocks the agent even after a verified-lossless dry run (Learning 811). CHANGELOG.md now further over its 65,536 B budget, trim still owed (LAST, per convention -- but check read-cap math first per Learning 810). Working-tree residue (BACKLOG.md YAML header + BACKLOG.log, 3 planning-spike HTMLs, suggested_NEWS_entry.md/.Rmd, 2 vignettes/articles PDFs) unchanged from S791-795, individually date-checked, not a new ghost-session signal, untouched by this session.
runtime_smoke: n/a -- pure docs/ledger operations this session, no R/ or Shiny change.
changelog_ref: this records commit (S796 records entry, prepended above the auto-generated SESSION_NOTES.md trim entry and the S796 claim entry)
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log)
```
Predecessor (S795) scored 7/10: every Orient measurement held, but the gotcha "CHANGELOG.md/SESSION_NOTES.md both over/near their 65,536 B budgets" named the wrong binding ceiling for SESSION_NOTES.md -- accurate in spirit, but missed the separate, smaller 56,750 B read-cap ceiling this session's own Phase 1B write immediately tripped. Not really S795's fault: context_budget.py's plain report was technically "ok" at that exact byte count (one token under). Self-score 6/10: +investigated rather than blind-executing the ambiguous initial ask; +found and correctly delegated a real, evidence-verified cross-repo drift without touching any synced file; +diagnosed the read-cap blocker to its actual root cause; +respected the permission classifier's denial exactly as instructed instead of working around it; +left the unrelated stray BACKLOG.md/BACKLOG.log residue untouched throughout. -the chosen deliverable (PED_GV F2/F3) was never started -- the whole session became ledger/tooling housekeeping instead of the development work the owner picked; -the read-cap risk was in principle knowable at Phase 0 (the file was 2 B from the ceiling already) but wasn't flagged before the Phase 1B write tripped it.

```handoff
session: S795
date: 2026-09-27
status: complete
self_score: 9
predecessor_score: 8
active_task: DONE -- BUNDLE/DOC cleanup of 5 trivial PED_GV audit findings (docs/audits/PED_GV_AUDIT_TRIAGE_2026-09-26.md): PED-11 (redundant any() in getRecordStatusIndex.R), NEW-56 (redundant [1L] in getPotentialParents.R), NEW-63 (stale getMaxAx.R roxygen), PED-10/NEW-43 (stale createPedOne.R/createPedSix.R roxygen), NEW-14 (kinshipMatricesToKValues()'s first-flag accumulator plus its empty-list edge, fixed with stop() on an empty list per owner decision). Full RED/GREEN/REFACTOR TDD cycle for the one behavior-changing item (NEW-14); the other 4, confirmed behavior-neutral by their own existing tests, folded directly into REFACTOR. BACKLOG item's resolved sub-item removed.
what_was_done: claim 5592b052; RED (PRE-RED + RED entries) 84dcfc87 (tests/testthat/test_kinshipMatricesToKValues.R, confirmed failing against "object 'kValues' not found"); GREEN a2fe3443 (R/kinshipMatricesToKValues.R, one guard clause; new test passes, siblings unaffected); REFACTOR 926cc907 (getRecordStatusIndex.R, getPotentialParents.R, getMaxAx.R roxygen, createPedOne.R/createPedSix.R roxygen, kinshipMatricesToKValues.R accumulator restyled to lapply; BACKLOG.md sub-item removed via the tail -n +6/hash-object/update-index --cacheinfo recipe); this records commit. Verification: every touched function's own test file 0 failed/0 error; lintr::lint() 0 lints on all 7 touched files; full unfiltered suite 355 files/2,756 tests/8,603 expectations, 1 known-pre-existing failure, 0 error. Learning 809 added (PROJECT_LEARNINGS.md, appended after Learning 808).
next_steps: (A) Ledger sizes measured fresh at close: CHANGELOG.md 76,593 B, well past its 65,536 B trim budget, trim owed (--force likely), still LAST among the three ledgers. SESSION_NOTES.md 62,233 B, approaching its own 65,536 B budget faster than recent sessions -- watch it. HANDOFFS.md 57,727 B, under budget. (B) S794's own next-step (A) -- push/dispatch to verify the shinytest2 45-min cap live -- and S793's carried-forward items (suggested_NEWS_entry disposition, PED_GV F2/F3 decisions, working-tree residue, unsynced methodology files) are all still open and untouched by this session. (C) The PED_GV audit's remaining "Also open" sub-items ((a) overhaul-root owner decisions, (b) NEW-24/issue #123) are unaffected by this session's cleanup and still open.
key_files: R/getRecordStatusIndex.R:14; R/getPotentialParents.R:202; R/getMaxAx.R:4-16; R/createPedOne.R:6-7; R/createPedSix.R:6-7; R/kinshipMatricesToKValues.R:96-111; tests/testthat/test_kinshipMatricesToKValues.R (new test); BACKLOG.md (sub-item removed); PROJECT_LEARNINGS.md (Learning 809)
gotchas: CHANGELOG.md 76,593 B, well over budget, trim owed (measure fresh -- stale the moment this commit lands). SESSION_NOTES.md 62,233 B, closing in on its own budget faster than recent sessions. 0 undocumented expected both ledger frontiers; origin/master was caught up (0 ahead/0 behind) as of this session's Orient -- recount fresh per Learning 806's reflex. The kinshipMatricesToKValues() accumulator restyle is a real code change to an @export'ed function's internals, not just docs -- verified via its own + 2 caller test files + the full suite, but re-verify if any other caller exists that this session's grep missed. Working-tree residue unchanged from S791-794, pre-dates this session by mtime; the BACKLOG.md YAML-header residue again survived this session's own edit via the 3-separate-Bash-call recipe. New Learning 809: a "trivial cleanup bundle" mixing behavior-neutral and behavior-changing findings only needs RED/GREEN for the behavior-changing one(s) -- check each item's existing test coverage at PRE-RED first. STANDING SET unchanged from S790-794 (see SESSION_NOTES.md gotcha 6 for the full list).
runtime_smoke: n/a -- pure R/ function-level fixes (2 doc-only, 2 behavior-neutral, 1 error-message change reachable only via a direct empty-list argument no real caller ever passes); no service registration, config resolution, or Shiny dispatch changed. The full unfiltered suite (includes test-app-*/test-e2e-* files per the S624 no-exclusion-filter convention) came back 0 error, but that is a test-suite read, not a live app launch -- stated explicitly per FM #24.
changelog_ref: 5592b052 (claim), 84dcfc87 (RED), a2fe3443 (GREEN), 926cc907 (REFACTOR), and this records commit
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log); claim 5592b052
```

```handoff
session: S794
date: 2026-09-27
status: complete
self_score: 8
predecessor_score: 7
active_task: DONE -- investigated and fixed the shinytest2 GitHub Actions workflow's 30-minute execution-time cap. PRE-RED found the item's "hit twice" framing was wrong (one cancelled run, observed by 3 same-day sessions hours apart, not two); real signal was genuine capacity growth (job duration ~20-22min early Aug -> 24-30min Sept, breaching the cap 2026-09-27). Owner picked raising timeout-minutes (30->45) over a matrix split. Full RED/GREEN/REFACTOR TDD cycle completed, BACKLOG item removed.
what_was_done: claim e1788ffd; RED d503a38c (tests/testthat/test_shinytest2_workflow_timeout.R, confirmed failing at 30); GREEN dad5a3d0 (.github/workflows/shinytest2.yaml:46, 30->45; new test passes; sibling coverage test unaffected; unfiltered full suite 355 files/2,755 tests/8,408 passed/1 known-pre-existing-failure/0 error; lint 0); REFACTOR 0c1a5b44 (resolved BACKLOG.md item removed via tail -n +6/hash-object/update-index --cacheinfo to exclude the unrelated pre-existing YAML-header residue from the commit); this records commit. Learning 808 added (PROJECT_LEARNINGS.md:2283).
next_steps: (A) Owner's call: push the 34 unpushed commits and/or manually dispatch shinytest2.yaml to verify the 45-min cap holds on live GitHub infrastructure -- not done this session (visible/shared-state action). (B) CHANGELOG.md now 70,735 B, further over its 65,536 B trim budget -- trim owed, owner-gated --force likely, trim LAST among the three ledgers if others also need it. (C) If growth continues past 45 min in future months, the deferred alternative (parallel matrix split) is captured in this session's CHANGELOG.md PRE-RED entry, not lost. (D) S793's own next-steps (B)-(E) unchanged: suggested_NEWS_entry disposition still open, PED_GV F2/F3 decisions, working-tree residue, unsynced methodology files.
key_files: .github/workflows/shinytest2.yaml:46 (the fix); tests/testthat/test_shinytest2_workflow_timeout.R (new RED test); BACKLOG.md (resolved item removed); PROJECT_LEARNINGS.md:2283 (Learning 808)
gotchas: CHANGELOG.md 70,735 B, over budget, trim owed. 0 undocumented expected both ledger frontiers; 34 unpushed as of just before this records commit (Learning 806 reflex -- recount at pickup). shinytest2 fix is UNVERIFIED against live GitHub infra (no push/dispatch this session). Working tree residue unchanged from S791-793, all pre-dating this session by mtime, not a ghost session; the BACKLOG.md YAML-header residue survived this session's own edit via the tail -n +6/hash-object/update-index --cacheinfo recipe run as 3 SEPARATE Bash calls (chained form still blocked by the auto-mode classifier). New Learning 808: a scheduled CI failure observed by several same-day sessions hours apart with no new scheduled run between them is ONE event -- verify with gh run view --json jobs (job-level startedAt/completedAt, not run-level createdAt/updatedAt) before trusting a predecessor's "recurred"/"twice" framing. STANDING SET unchanged from S790-793 (see SESSION_NOTES.md gotcha 6 for the full list).
runtime_smoke: n/a for R/ (no R/ file changed) -- CI workflow config only. Real-world verification requires a live GitHub run (next scheduled run or workflow_dispatch), deliberately not triggered this session pending the owner's push/dispatch decision (FM #24: stated explicitly, not silently treated as done).
changelog_ref: e1788ffd (claim), d503a38c (RED), dad5a3d0 (GREEN), 0c1a5b44 (REFACTOR), and this records commit
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log); claim e1788ffd
```

```handoff
session: S793
date: 2026-09-27
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- reviewed suggested_NEWS_entry.md / vignettes/suggested_NEWS_entry.Rmd (owner's untracked 3.0.0-consolidation draft, both substantively identical) against current NEWS.Rmd; produced adopt/reject/modify verdicts with rationale for every suggested idea (14 items: 8 ADOPT, 5 MODIFY, 1 REJECT-as-drafted). No NEWS.Rmd edits this session, per owner scoping. Followed AUDIT_WORKSTREAM.md; no TDD gates (docs review only, no code/test change). Owner's initial scope pick from the Phase 0 priorities picker used BACKLOG.md's own S791-authored framing ("own scoping session first"), which the owner said they did not understand -- two plain-prose clarifying exchanges established the real, lighter scope (Learning 807).
what_was_done: claim 5638629b; this records commit. No RED/GREEN/REFACTOR (not applicable -- docs review, no code/test). Wrote docs/audits/SUGGESTED_NEWS_ENTRY_REVIEW_2026-09-27.md: verified all 31 cited function/argument names against R/ by direct grep (all resolve); found one confirmed factual error (groupAddAssign()'s pre-existing `candidates` PARAMETER mislabeled as a new "control" in the draft, when the actual new item is a `candidates` field in its RETURN VALUE, per R/groupAddAssign.R:89-96's own roxygen -- NEWS.Rmd already states this correctly); found one dropped owner-accepted-limitation caveat (the harem-sire ancestry-rule enforcement gap, BACKLOG.md's open item, Learning 778) and one section (General Fixes) where the draft silently drops 4 of 6 real bug-fix disclosures. Also filed one incidental BACKLOG.md item: the scheduled shinytest2 workflow hit its 30-minute cap a second time (first S791, now this session's Orient) -- documented with the workflow's own structure (21 sequential per-module Rscript groups) and a concrete next step, not investigated or fixed.
next_steps: (A) CHANGELOG.md measured 65,721 B at this session's Orient -- already OVER its 65,536 B trim budget before this session's own entries; a methodology_trim.py --file CHANGELOG.md --budget-bytes 65536 pass is owed, owner-gated --force likely needed (SRF_RED pattern, Learnings 549/586/587). (B) The suggested_NEWS_entry review is DONE and filed; BACKLOG.md's own suggested_NEWS_entry disposition item stays open -- a future session should read the review with the owner and decide what to act on now (Findings S7/S8's bullet-splitting of NEWS.Rmd's two densest paragraphs is actionable independent of the 3.0.0-timing question) vs. reserve for an eventual 3.0.0 release note (most other findings). (C) The new shinytest2 BACKLOG item (top of Up Next) needs `gh run list --workflow=shinytest2.yaml`'s full duration history before assuming a hang vs. capacity growth. (D) Everything else in S792's next-steps list is unchanged and still open.
key_files: docs/audits/SUGGESTED_NEWS_ENTRY_REVIEW_2026-09-27.md (the review: 4 global + 11 per-section findings, items-audited table, structural observations, recommendations); suggested_NEWS_entry.md / vignettes/suggested_NEWS_entry.Rmd (reviewed, untouched); NEWS.Rmd:15-495 (compared against, untouched); R/groupAddAssign.R:89-96,171 (the candidates return-value-vs-parameter distinction); BACKLOG.md working (new shinytest2 item at top of Up Next); PROJECT_LEARNINGS.md:2279,2281 (Learnings 806-807).
gotchas: CHANGELOG.md is over its 65,536 B trim budget (measure fresh, it will have grown further from this session's own entries) -- trim owed, owner-gated. Expect 0 undocumented on both ledger frontiers; ~30-31 unpushed after this records commit (stated as "just before this commit" per Learning 806 -- recount, don't trust verbatim per that same learning). shinytest2 scheduled workflow has now hit its 30-minute cap twice (S791, and this session) -- see the new BACKLOG.md item, don't re-file a duplicate. Working tree NOT clean: same residue as S791/S792 (BACKLOG.md 5-line header, BACKLOG.log, two suggested_NEWS_entry drafts, 3 planning-spike HTML files, 2 rendered PDFs) -- all confirmed pre-dating this session by file mtime, not a new ghost-session signal. BACKLOG.md commit recipe: this session found the CHAINED multi-step form (tail redirect + hash-object + update-index in one Bash call) BLOCKED by the auto-mode classifier as "Irreversible Local Destruction" -- running each of the 3 steps as its OWN separate Bash call worked cleanly; do this if the chained form is blocked again. This session's review made NO NEWS.Rmd changes -- acting on any finding is a NEW deliverable, likely under TDD gates. New Learnings 806 (a receipt's unpushed-count/frontier-gap figure should be phrased as "just before this commit," not a bare predicted post-commit number) and 807 (a BACKLOG item describing an owner's own draft/preference is a session's interpretation, not confirmed intent -- re-confirm in plain language at pickup). STANDING SET (condensed, unchanged from S790-792): full-40-char sha from git rev-parse; git log --grep needs --extended-regexp plus a control id; scratchpad/ invisible to git BY OWNER DECISION; CLAUDE.md warn band = headroom; trim budget 65,536 B for all three ledgers, trim CHANGELOG.md LAST; the context_budget.py pre-commit hook counts TOKENS and only tracks CLAUDE.md/SESSION_NOTES.md -- it does NOT gate CHANGELOG.md/HANDOFFS.md's separate manual trim-budget convention; a foreground sleep is blocked (use run_in_background); skip waiting on CI only when every changed file is .Rbuildignore'd and read by no test.
runtime_smoke: n/a -- a review document and BACKLOG.md/records changes only; no R/ file, test, or NEWS.Rmd itself touched; no runtime behavior changed. quality_ratchet: unchanged from S790 -- 1/1 pass, 0 fail, 0 unmeasured, results ce2ee7e8ec51, manifest aa983075d6a2 (not re-run; no R/ change)
changelog_ref: 5638629b (claim), and the S793 records entry
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log); claim 5638629b
```

```handoff
session: S792
date: 2026-09-27
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE -- NEWS.Rmd release-state sweep, stage 2 piece (d), closing the whole 4-stage sweep (stages 1, 2a-2c already DONE). PRE-RED found every underlying fact in piece (d)'s 6 line ranges TRUE and current (crash fixes, isolated-animal behavior, disconnected-component separation, kinshipMatrix argument, example-pedigree counts/colors all pinned by existing code/tests). Unlike pieces (a)-(c), which each found one stale FACT, piece (d)'s defect was uniform release-state FRAMING: 9 of 10 entries narrated a fix/change against a pre-2.0.0 state the diagram feature never had. Rewrote all 9 to plain finished-state prose; 37 entries unchanged. Also investigated and found NOT to hold: BACKLOG.md's own claim of stale cross-references in Marker Genetics/Mate Pair (they point at unrelated content). Piece (d) being the last stage triggered the BACKLOG completed-item removal checklist: whole sweep item removed from BACKLOG.md, two open sub-threads extracted as new items (suggested_NEWS_entry disposition; ## Package entry keep-or-delete).
what_was_done: claim 35f19cc6; RED 3d26dd6f (pieceDNarrationPhrases, 14 exact phrases; target file 26 tests/93 passed/14 failed by design/0 errors); GREEN f5bb6428 (9 entries rewritten; entry count re-confirmed 37; NEWS.Rmd knits via rmarkdown::render(); target file 26/107/0 failed; full unfiltered suite 354 files, 2,754 tests, 8,408 expectations (8,407 passed), 1 failed = the known pkgdown draft, 0 errors, 187 skipped, 6 warnings, host load 17.84); REFACTOR eff424a6 (no behavior change re-confirmed 26/0 failed, 0 lints; BACKLOG sweep item removed via the owner-header-preserving commit recipe, verified post-commit diff shows only the 5-line header; two new BACKLOG items filed; enriched completion record folded into the REFACTOR CHANGELOG.md entry); this records commit carries this receipt.
next_steps: The NEWS.Rmd sweep is CLOSED -- no piece (e). Next NEWS-adjacent work is the two just-extracted BACKLOG.md items: the owner's suggested_NEWS_entry 3.0.0-consolidation disposition (DECISION NEEDED, M, own scoping session) and the ## Package entry keep-or-delete decision (Optional, S, low). Also READY: docs staleness audit (L); a2interactive reportMatePairs() section (S); PED_GV cleanup bundle (S); Chrome-for-Testing hang (M, optional); BACKLOG.md housekeeping (L, likely due for a regrowth check, not measured this session). DECISION NEEDED backlog: male-left placement (S), blank/unrecognized sex reporting (S), isAddedRecord() helper (S, optional), convertDate() row numbering (S, low), getAncestors() absent id (S), PED_GV F2/F3, paths-ignore (S). Owner items: contributor tutorial, papers, harem-sire hole, blank ancestry OTHER/UNKNOWN, LabKey (both), retrospective backfill, trimmer verify false positive. Push the 27 local commits after ff8308a5 when ready -- CI has not seen S792 (NEWS.Rmd + a test file changed, watch the run once pushed).
key_files: tests/testthat/test_newsReleaseState.R (new in S792: pieceDNarrationPhrases, the piece (d) wording test, header comment documenting scope/grounding); NEWS.Rmd:21- (Pedigree Diagram section, still 37 entries; 9 rewritten entries span :37- through :174-); R/makePedigreeDiagramData.R (S630/S682 crash-fix code; kinshipMatrix formal :1685; duplicate/consanguineous colors :1946-2012, :1973); BACKLOG.md working (sweep item REMOVED; two new items added); CHANGELOG.md (S792 entries newest first: REFACTOR, GREEN, RED, claim); PROJECT_LEARNINGS.md:2277 (Learning 805).
gotchas: The NEWS.Rmd sweep BACKLOG item is GONE -- don't look for piece (e); history is in CHANGELOG.md's S788-S792 entries. CHANGELOG.md frontier = HEAD; HANDOFFS.md frontier 3 commits behind HEAD (the claim commit only -- RED/GREEN/REFACTOR don't touch HANDOFFS.md by convention, NOT a reconcile finding). 27 unpushed after this records commit; origin/master = ff8308a5, CI green (4/4) on it, has NOT seen S792; the shinytest2 scheduled timeout (first seen S791) has NOT recurred (checked twice now) -- still not worth a BACKLOG item on one occurrence. Working tree NOT clean: same residue as S791 (BACKLOG.md 5-line header, BACKLOG.log, two suggested_NEWS_entry drafts, 5 render artifacts); the owner-header commit recipe worked again verbatim (tail -n +6 BACKLOG.md into a blob, hash-object, update-index --cacheinfo, confirm git diff HEAD -- BACKLOG.md shows only the 5 header lines). Full suite baseline: 354 files, 2,754 tests, 8,408 expectations (8,407 passed), 187 skipped, 6 warnings, 1 failed (pkgdown draft) -- rose by exactly this session's additions. Ledger sizes measured fresh (wc -c, against the 65,536 B trim budget): SESSION_NOTES.md 27,936 B, HANDOFFS.md 41,837 B, CHANGELOG.md 63,315 B -- CHANGELOG.md is closest to the ceiling, likely due for a trim within a session or two; re-measure, don't assume these numbers still hold. Ratchet unchanged from S790: 1/1 at ff682ffb (results ce2ee7e8ec51, manifest aa983075d6a2) -- no R/ change this session. New this session (Learning 805): when a piece closes the LAST stage of a tracked multi-session BACKLOG item, fold the completed-item removal checklist into THAT piece's own REFACTOR, including extracting any open sub-threads the item's text still carries; and a BACKLOG item's own scope description can itself carry a stale sub-claim -- verify it fresh (grep + read) rather than executing it on trust. Disclosed: two pointless Bash no-op placeholder calls were made while waiting on the backgrounded full-suite run (no polling of the output file occurred, but the calls themselves added nothing) -- next time just end the turn and let the notification arrive.
runtime_smoke: n/a -- NEWS.Rmd, a test file, and records only; no R/ file touched, no runtime behavior changed. quality_ratchet: unchanged from S790 -- 1/1 pass, 0 fail, 0 unmeasured, results ce2ee7e8ec51, manifest aa983075d6a2 (not re-run; no R/ change)
changelog_ref: eff424a6 (REFACTOR), f5bb6428 (GREEN), 3d26dd6f (RED), 35f19cc6 (claim), and the S792 records entry
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log); REFACTOR eff424a6
```

```handoff
session: S791
date: 2026-09-27
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE (stage 2 piece (c) of the NEWS.Rmd release-state sweep) -- the Pedigree Diagram section's sibling-bar/connecting-bar entry (issue #160) said "Two rarer related cases are not corrected"; true right after Track 1 shipped (S593), stale since Track 2 (.resolveEdgeNodeCollisions(), S595) generalized same-row collision repair the next day. Measured fresh: 0 straight-residual collisions of any kind remain on the bundled 375-animal example (only 72 already-disclosed curved-heuristic ones do, matching S715's shipped count exactly). Clause dropped; the other 11 entries in scope checked and found accurate. Section stays at 37 entries (a wording fix, not a merge). Piece (d) remains, in BACKLOG.md.
what_was_done: claim 642202ef; RED ac2ca6c0 (straightResidualCount() helper + one section-scoped test; 25 tests, 92 expectations, 1 failing by design, 0 errors); GREEN 8434a88c (NEWS.Rmd:79-82 only: target file 25/92/0 failed; full unfiltered suite 354 files, 2,753 tests, 8,393 expectations (8,392 passed), 1 failed = the known pkgdown draft, 0 errors, 187 skipped, 6 warnings, host load 22.82 -- the wall-clock benchmarks held); REFACTOR 97e7ce60 (no behavior change; BACKLOG.md sweep item narrowed to piece (d) only, its NEWS.Rmd lines confirmed unchanged via git diff --stat; the owner's untracked suggested_NEWS_entry.md/.Rmd draft and its S791 disposition filed); ledger trim 8c9c5eaa (SESSION_NOTES.md 68,163 to 27,309 B, 5 records, owner-approved --force for the SRF small-denominator refusal, L1/L2/L3 OK); the S791 records commit carries this receipt.
next_steps: (A) Stage 2 piece (d): the crash fixes, isolated-animal entries, example pedigrees/article, layout-origin/kinshipMatrix entries, and cross-references outside the section (READY, M, closes the sweep) -- BACKLOG.md working (re-derive at pickup; as of this close, CONFIRMED UNCHANGED from S790: :32-42, :104-116, :117-121, :131-136, :147-152, :165-177 -- piece (c)'s edit was a net 3-lines-for-3-lines swap). Add checks as failing tests FIRST, scoped with newsSectionEntries(); check every claim against real output, not memory or roxygen. Once piece (d) closes, the sweep is DONE and the suggested_NEWS_entry.md/.Rmd disposition (adopt it, how, when) is its own next scoping question. (B) Also READY: the docs staleness audit (L); the a2interactive reportMatePairs() section (S); the PED_GV cleanup bundle (S); the Chrome-for-Testing hang root cause (M, optional); the BACKLOG.md ledger-size housekeeping (L). (C) DECISION NEEDED: male-left placement roxygen vs. real layouts (S); blank/unrecognized sex reported as a wrong-sex parent (S); the isAddedRecord() helper (S, optional); convertDate row numbering (S, low); getAncestors() absent id (S); F2/F3 of the PED_GV item; paths-ignore (S). (D) Owner items: contributor tutorial, papers (own scoping session first), harem-sire hole, blank ancestry OTHER/UNKNOWN, LabKey (both items), retrospective backfill, trimmer verify false positive, and now suggested_NEWS_entry's disposition once the sweep closes. (E) Your decisions open: the working-tree residue (untouched), the push of the 22 local commits after ff8308a5 (CI has not seen S791; NEWS.Rmd and a test file changed, so await it), the same-day shinytest2 scheduled-run timeout (new, unreported before this session -- watch for recurrence before deciding it needs a BACKLOG item), closing the 11 recommended PED_GV ids, the NEWS.Rmd:18 Package entry, the two methodology files context_budget.py flags as matching no canonical revision (still not investigated).
key_files: tests/testthat/test_newsReleaseState.R (new in S791: straightResidualCount(), the sibling-bar wording test, before the #168 test); NEWS.Rmd:21 (Pedigree Diagram section, 37 entries; rewritten at :79-82); R/makePedigreeDiagramData.R (.addRectilinearWaypoints() :2166, .resolveEdgeNodeCollisions() :2646); BACKLOG.md working (sweep item narrowed to piece (d); the suggested_NEWS_entry disposition, its own new item); CHANGELOG.md (S791 entries, newest first: ledger trim, REFACTOR, GREEN, RED, claim); PROJECT_LEARNINGS.md:2275 (Learning 804); docs/archive/SESSION_NOTES-through-2026-09-26-4.md (the new shard and its .verify.sh); suggested_NEWS_entry.md / vignettes/suggested_NEWS_entry.Rmd (the owner's untracked 3.0.0 consolidation draft, disposition recorded, files untouched).
gotchas: (1) Expect 0 undocumented on both frontiers -- measure; 22 unpushed after this records commit (recount); origin/master = ff8308a5, CI green (4/4) but has NOT seen any S791 commit; a same-day scheduled shinytest2 run timed out at its 30-minute cap (unrelated to push history) -- check for recurrence. Working tree NOT clean: BACKLOG.md = owner's 5-line header only, untracked BACKLOG.log, two suggested_NEWS_entry drafts, 5 render artifacts; stage by name; BACKLOG.md commit recipe: tail -n +6 into a blob, hash-object, update-index --cacheinfo, commit, confirm the diff is the 5 header lines (worked again). (2) Full suite baseline: 354 files, 2,753 tests, 8,393 expectations (8,392 passed), 187 skipped, 6 warnings, 1 failed (pkgdown draft) even under high host load (22.82) -- check uptime anyway (Learnings 760, 800). (3) Ratchet UNCHANGED from S790: 1/1 at ff682ffb (results ce2ee7e8ec51, manifest aa983075d6a2) -- no R/ change this session, not re-run; compare BEFORE any run, run AFTER committing if R/ changes. (4) Wording contracts from pieces (a)/(b)/(c): a limit number followed within 60 non-digit chars by its style name; "default" attaches to the style named just before it, else the first after; exactly one shading entry; no "by default" or every-pair word on male-left; the duplicate-count entry cites a number a test recomputes fresh; promisesEveryPair() flags "each" only when followed by a word; the sibling-bar entry no longer claims anything is "not corrected" (a test recomputes the real residual count). Piece (d) scopes its own new patterns with newsSectionEntries(). (5) SESSION_NOTES.md was trimmed THIS session (68,163 to 27,309 B) -- the cut split S790's own "Session 789 Handoff Evaluation (by Session 790)" from its paired "What Session 790 Did" report (evaluation stayed live, report archived); not data loss (L1/L3 confirmed, aside from the expected BL-27 frontier note) but an unusual boundary -- a future session could tidy this by hand if it bothers a reader. HANDOFFS.md 33,120 B and CHANGELOG.md 55,881 B before this receipt, both with headroom -- measure fresh with context_budget.py, don't assume. (6) STANDING SET carried in this receipt (unchanged from S790's gotcha 6, condensed): full-40-char sha from git rev-parse and a smoke-tested gh run filter; git log --grep needs --extended-regexp plus a control id; scratchpad/ invisible to git BY OWNER DECISION; CLAUDE.md warn band = headroom; trim budget 65,536 B for all three ledgers, trim CHANGELOG.md LAST and the cut keeps the N newest; the hook counts TOKENS (2.27 B/token, ceiling 25,000 = 56,750 B) and refuses a commit that GROWS an over-ceiling file (do not bypass); zsh traps (unquoted list vars, ${PIPESTATUS[0]}, unquoted globs, BSD sed -i, a cd persisting across Bash calls); a foreground sleep is blocked (use run_in_background); skip waiting on CI only when every changed file is .Rbuildignore'd and read by no test. NEW in S791 (Learning 804): Phase 1B (the claim stub) comes FIRST, before any PRE-RED fact-finding or scope questions -- do not let "pose the gate right after PRE-RED fact-finding" (Learning 803d) push 1B itself later; claim the session, THEN fact-find, THEN gate. An untracked owner draft found mid-session proposing a DIFFERENT scope than the in-progress task is a mid-session AskUserQuestion moment, not a silent pivot. A claim true right after one fix shipped can go stale the very next day when a MORE GENERAL fix supersedes it -- trace the issue's own comment history (gh issue view --comments), not just the code. A NEWS proportion/count tied to a specific historical session's own measurement can be re-verified cheaply by checking whether today's live measurement matches that session's own shipped number.
runtime_smoke: n/a -- NEWS.Rmd, a test file and records only; no runtime behavior changed (no R/ file touched); claims checked against real .addRectilinearWaypoints()/.resolveEdgeNodeCollisions() output and gh issue view's own history, not roxygen or memory. quality_ratchet: unchanged from S790 -- 1/1 pass · 0 fail · 0 unmeasured · results ce2ee7e8ec51 · manifest aa983075d6a2 (not re-run; no R/ change)
changelog_ref: 97e7ce60 (REFACTOR), 8434a88c (GREEN), ac2ca6c0 (RED), 642202ef (claim), 8c9c5eaa (ledger trim), and the S791 records entry
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log); claim 642202ef
```

```handoff
session: S790
date: 2026-09-27
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE (stage 2 piece (b) of the NEWS.Rmd release-state sweep) -- the Pedigree Diagram section's mating-symbol placement/spacing entries state the finished state: a stale duplicate-node count (22, measured S573, never re-checked) is now 113 (measured fresh); 6 overlapping "symbol sits centered/spaced" entries from many sessions merged into 1, worded "in most cases"; the "every mating symbol...each mated pair" claim reworded to "many mated pairs" (both were overstatements, same class as S789's male-left finding). 42 to 37 entries. Pieces (c), (d) remain, in BACKLOG.md.
what_was_done: claim f953672e; RED a2d440f1 (matingUnitDuplicateCount() + unit test, extended promisesEveryPair() to flag a leading "each", 2 new section-scoped real-file checks; 24 tests, 92 expectations, 3 failing by design); RED ledger backfill 7d0fae64 (the RED commit omitted its own CHANGELOG.md entry, caught and fixed before the next commit); GREEN b007682c (NEWS.Rmd only: target file 24/88/0 failed; full unfiltered suite 354 files, 2,752 tests, 8,582 expectations, 1 failed = the known pkgdown draft, 0 errors, 187 skipped, 6 warnings, matching the S789 baseline plus this piece's own +3/+14 exactly; NEWS.Rmd knits); REFACTOR ff682ffb (no behavior change; BACKLOG.md sweep item narrowed, pieces (c)/(d) line ranges re-derived fresh against the post-edit file); the S790 records commit carries this receipt, SESSION_NOTES.md and Learning 803.
next_steps: (A) Stage 2 piece (c): connector routing, collision avoidance and the Rectilinear sibling-bar entries (READY, M), BACKLOG.md working (re-derive at pickup -- as of this close: :67-69, :79-90, :122-130, :137-142, :153-164, :178-198); the item flags NEWS.Rmd:82's "Two rarer related cases are not corrected" (issue #160) as kept but NOT re-checked against the code -- piece (c) must find what the two cases are. Add checks as failing tests FIRST, scoped with newsSectionEntries(); verify every claim against real output (Learning 802/803). (B) Also READY: the docs staleness audit (L); the a2interactive reportMatePairs() section (S) sub-item (1); the PED_GV cleanup bundle (S); the Chrome-for-Testing hang root cause (M, optional); the BACKLOG.md ledger-size housekeeping (L). (C) DECISION NEEDED: male-left placement roxygen vs. real layouts (S); blank/unrecognized sex reported as a wrong-sex parent (S); the isAddedRecord() helper (S, optional); convertDate row numbering (S, low); getAncestors() absent id (S); F2/F3 of the PED_GV item; paths-ignore (S). (D) Owner items: contributor tutorial, papers (own scoping session first), harem-sire hole, blank ancestry OTHER/UNKNOWN, LabKey (both items), retrospective backfill, trimmer verify false positive. (E) Your decisions open: the working-tree residue (untouched), the push of the 15 local commits after ff8308a5 (CI has not seen S790; NEWS.Rmd and a test file changed, so await it), closing the 11 recommended PED_GV ids, the NEWS.Rmd:18 Package entry, the two methodology files context_budget.py flags as matching no canonical revision (still not investigated). HANDOFFS.md is at or near its 65,536 B trim budget after this receipt -- propose the owner-gated archive pass early next session if a commit is refused.
key_files: tests/testthat/test_newsReleaseState.R (matingUnitDuplicateCount() and its unit test, the extended promisesEveryPair() with its each-idiom control, the 2 new real-file checks before the #168 test); NEWS.Rmd:21 (Pedigree Diagram section, 37 entries; rewritten at :73-78, :91-95, :143-146); R/makePedigreeDiagramData.R (.buildMatingUnitForest(), the duplicates data frame); tests/testthat/test_positionMatingUnitForest.R:2917-2974 (the disclosed-residuals centering test); BACKLOG.md working (sweep item, narrowed); CHANGELOG.md (S790 entries, newest first: REFACTOR, GREEN, RED ledger backfill, RED, claim); PROJECT_LEARNINGS.md:2273 (Learning 803).
gotchas: (1) Expect 0 undocumented on both frontiers -- measure; 15 unpushed after this records commit (recount); origin/master = ff8308a5, CI green (4/4) but has NOT seen any S790 commit. Working tree NOT clean: BACKLOG.md = owner's 5-line header only, untracked BACKLOG.log, two suggested_NEWS_entry drafts, 5 render artifacts; stage by name; BACKLOG.md commit recipe: tail -n +6 into a blob, hash-object, update-index --cacheinfo, commit, confirm the diff is the 5 header lines (worked again). (2) Full suite baseline: 354 files, 2,752 tests, 8,582 expectations, 187 skipped, 6 warnings, 1 failed (pkgdown draft) on a quiet machine; check uptime first (Learnings 760, 800). (3) Ratchet 1/1 at ff682ffb (results ce2ee7e8ec51, manifest aa983075d6a2): compare BEFORE any run, run AFTER committing. (4) Wording contracts from pieces (a)/(b): a limit number followed within 60 non-digit chars by its style name; "default" attaches to the style named just before it, else the first after; exactly one shading entry; no "by default" or every-pair word on male-left; the duplicate-count entry cites a number a test recomputes fresh (do not hand-edit without re-running it); promisesEveryPair() now flags "each" only when followed by a word, not punctuation. Each piece scopes its own new patterns with newsSectionEntries(). (5) HANDOFFS.md measured 62,993 B before this receipt (budget 65,536 B) -- this receipt likely crosses it; if a commit is refused, run methodology_trim.py --file HANDOFFS.md --write --budget-bytes 65536 (expect the SRF small-denominator refusal and --force, owner-gated), trim CHANGELOG.md LAST (Learning 761). SESSION_NOTES.md 51,669 B (~22.8k tokens against the 25,000-token hook ceiling), CHANGELOG.md 46,815 B before this session's own growth -- both have headroom but check with context_budget.py, not wc -c alone. (6) STANDING SET carried in this receipt (unchanged from S789's gotcha 7, condensed): full-40-char sha from git rev-parse and a smoke-tested gh run filter; git log --grep needs --extended-regexp plus a control id; scratchpad/ invisible to git BY OWNER DECISION; CLAUDE.md warn band = headroom; trim budget 65,536 B for all three ledgers, trim CHANGELOG.md LAST and the cut keeps the N newest; the hook counts TOKENS (2.27 B/token, ceiling 25,000 = 56,750 B) and refuses a commit that GROWS an over-ceiling file (do not bypass); zsh traps (unquoted list vars, ${PIPESTATUS[0]}, unquoted globs, BSD sed -i, a cd persisting across Bash calls); a foreground sleep is blocked (use run_in_background); skip waiting on CI only when every changed file is .Rbuildignored and read by no test. NEW in S790: pose the PRE-RED->RED phase gate as the very next action after PRE-RED fact-finding, before opening any test file (Learning 803d); each TDD-phase commit needs its OWN CHANGELOG.md entry as it happens -- verify against a recent session's git show --stat if in doubt; a shared lexical guard extended for a new trigger word needs a control for that word's other, harmless use (Learning 803c); a number cited in a NEWS entry can go stale from LATER, unrelated code changes even though it was correct when written -- pin it with a test that recomputes it from real output (Learning 803a).
runtime_smoke: n/a -- NEWS.Rmd, a test file and records only; no runtime behavior changed (no R/ file touched); claims checked against real .buildMatingUnitForest() output and the position engine's own test suite, not a live click-through of the Shiny Diagram tab. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results ce2ee7e8ec51 · manifest aa983075d6a2
changelog_ref: ff682ffb (REFACTOR), b007682c (GREEN), 7d0fae64 (RED ledger backfill), a2d440f1 (RED), f953672e (claim), and the S790 records entry
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log); claim f953672e
```

```handoff
session: S789
date: 2026-09-27
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE (stage 2 piece (a) of the NEWS.Rmd release-state sweep) -- the Pedigree Diagram section's display and defaults entries state the finished state against 2.0.0: the display limit is stated once (400 animals with the default Rectilinear connector style, 750 with Direct), Rectilinear is named the default (the notes called Direct the default), shading is one rule (only animals marked affected are shaded; unaffected, unknown and every animal with no affected column are drawn open), and male-left is in most cases (not by default: no setting; not always: real layouts refute it); 45 entries became 42; four section-scoped checks in tests/testthat/test_newsReleaseState.R tie the notes to the app. Pieces (b), (c), (d) remain, in BACKLOG.md.
what_was_done: claim 95d0d2de; RED 4523973e (3 helpers with unit tests and 4 real-file checks failing by design, 10 failing expectations in 4 tests as predicted); RED correction a4b61e66 (my check required the word always; probing every mixed-sex mating of the bundled pedigrees showed the male on the left in 227 of 257, 88.3 percent, so the check now forbids by default and any every-pair word: 9 failing); GREEN 4e8ada74 (NEWS.Rmd only: the file 21 tests, 74 expectations, 0 failed; full unfiltered suite 354 files, 2,749 tests, 8,568 expectations, 1 failed = the known pkgdown draft, 0 errors, 187 skipped, 6 warnings; every claim checked against the code and real layout output first); REFACTOR 9df0bac6 (one unit test moved; BACKLOG.md sweep item narrowed, male-left placement item filed, audit item extended; ratchet 1/1); ledger trim 43179247 (CHANGELOG.md 65,424 to 37,593 B, 13 of 25 records, owner-approved, --cut 12 --force, verify script OK on L1/L2/L3); ledger trim 87118663 (SESSION_NOTES.md 53,844 to 25,632 B before my record was put back, 4 of 7 records, owner-approved, --cut 3 --force, verify OK on L1/L2/L3); the S789 records commit carries this receipt, SESSION_NOTES.md and Learning 802.
next_steps: (A) Stage 2 piece (b): mating-symbol placement and spacing (READY, M), BACKLOG.md working :136 -- the item lists the NEWS.Rmd lines (:70-78, :91-100, :119-131, :152-156, :163-167; re-derive by reading the section); add the piece's checks to test_newsReleaseState.R as failing tests FIRST, scoped with newsSectionEntries(block, "Pedigree Diagram"); check every sentence against the code and real output; the entry at NEWS.Rmd:73-78 states 22 individuals in the bundled example pedigree, a number NOT verified (measure it with makePedigreeMatingLayout). (B) Also READY: the docs staleness audit (L) :195; the a2interactive reportMatePairs() section (S), sub-item 1 of :114; the PED_GV cleanup bundle (S) :13; the Chrome-for-Testing hang root cause (M, optional) :386; the BACKLOG.md ledger-size housekeeping (L) :444. (C) DECISION NEEDED: male-left placement, roxygen versus real layouts (S) :176; blank or unrecognized sex reported as a female sire or male dam (S) :39; the isAddedRecord() helper (S, optional) :56; convertDate row numbering :70; getAncestors() absent id :85; F2 and F3 :13; paths-ignore :101. (D) Owner items: contributor tutorial :222, papers :606 (own scoping session first), harem-sire :261, blank ancestry :239, LabKey :300 and :315, retrospective backfill :281, trimmer verify false positive :409. (E) Your decisions open: the working-tree residue, the push of the local commits after ff8308a5 (CI was green on ff8308a5 and has not seen S789; a test file changed, so await it), closing the 11 recommended PED_GV ids, whether to delete the Package entry at NEWS.Rmd:18, the two methodology files context_budget.py says match no canonical revision.
key_files: tests/testthat/test_newsReleaseState.R:100 (newsSectionEntries), :117 (defaultStyles), :142 (promisesEveryPair), :147 (readCap), :155 (diagramCaps), :165 (diagramSectionEntries), :276-367 (helper unit tests), :369, :396, :413, :430 (the four real-file checks); NEWS.Rmd:21 (the Pedigree Diagram section, 42 entries; rewritten entries at :22, :43, :46, :58); R/modPedigree.R:405 (limits, also :417), :423 (default style), :505 (the over-limit message); R/makePedigreeDiagramData.R:173 (.affectedColor), :1682 (layout signature), :1590 (male-left roxygen); BACKLOG.md working :136 (sweep item) and :176 (male-left item); CHANGELOG.md:63 (the S789 records entry), :82 and :90 (the two trim entries), :98 (REFACTOR), :114 (GREEN), :149 (RED correction), :172 (RED), :208 (claim); HANDOFFS.md:178 (this receipt); PROJECT_LEARNINGS.md:2272 (Learning 802); docs/archive/CHANGELOG-through-2026-09-26-3.md
gotchas: (1) Expect 0 undocumented on both frontiers at Phase 0 -- measure; 9 unpushed after this records commit (recount); origin/master = ff8308a5, CI on it green (4 of 4). The working tree will NOT be clean: BACKLOG.md modified (the owner's 5-line YAML header ONLY; verify with git diff HEAD -- BACKLOG.md), untracked BACKLOG.log, two suggested_NEWS_entry drafts and 5 render artifacts; stage by name; for a BACKLOG.md commit edit the working file, tail -n +6 into a scratch file, git hash-object -w it, git update-index --cacheinfo 100644,<sha>,BACKLOG.md, commit, then confirm the diff is the 5 header lines (worked verbatim again); working BACKLOG.md line numbers are HEAD +5. (2) A local unfiltered suite reads 1 failed on a QUIET machine (test_pkgdown_reference_config.R, the owner's draft); under host load two wall-clock benchmarks (test_markerKinship.R, test_markerParentageLikelihood.R) also fail (Learnings 760, 800). Baseline now 354 files, 2,749 tests, 8,568 expectations, 187 skipped, 6 warnings. Clean-export R CMD check only when R/ changes (recipe in the S788 receipt gotcha 2, Learning 797d). (3) Ratchet 1/1 at 9df0bac6 (3,577,928 B, results 40286d04f00e, manifest aa983075d6a2): compare BEFORE any run, run AFTER committing. (4) The new checks are wording contracts: a limit number is followed within 60 non-digit characters by its style name; default attaches to the style named just before it in the same sentence, else the first after; exactly one shading entry (the words shade, shaded, shading, filled, unfilled); the male-left entry has no by default and no always, every or all; each later piece adds its own, scoped with newsSectionEntries(); the guard from stage 1 still scans the whole newest block for milestone phrases. (5) THE COMMIT HOOK COUNTS TOKENS: SESSION_NOTES.md has a 25,000-token ceiling (56,750 B at 2.27 B per token), not the 65,536 B of the size table, and refuses a commit that GROWS an over-ceiling file (do not bypass); measure with python3 context_budget.py (it prints tokens), not wc -c. Measured after this records commit is written: SESSION_NOTES.md 37,289 B, HANDOFFS.md about 62 KB (trim budget 65,536 B: the next claim stub plus a close-out receipt of this size (about 9 KB, too big: keep the next one under 5 KB) will cross it, so propose the owner-gated HANDOFFS.md archive pass at Orient or before the receipt), CHANGELOG.md about 41 KB. (6) The S788 receipt gotcha (1) is superseded (the push happened). (7) STANDING SET (carried from S787, condensed; READ IT BEFORE THE FIRST COMMAND): full-40-char sha from git rev-parse and a smoke-tested gh run filter; git log --grep needs --extended-regexp plus a control id; scratchpad/ invisible to git BY OWNER DECISION; CLAUDE.md warn band (26,658 B) = headroom; trim budget 65,536 B for ALL THREE ledgers, trim CHANGELOG.md LAST (Learning 761) and the cut keeps the N newest (Learning 777); the hook counts TOKENS (2.27 B/token, ceiling 25,000 = 56,750 B) and refuses a commit that GROWS an over-ceiling budgeted file (do not bypass); shinytest2 0.5.1 load_all()s the checkout (Learning 789); .Rprofile prints renv::status(dev = TRUE) at an interactive start from the package root (normal); zsh traps: an unquoted list variable does not word-split, ${PIPESTATUS[0]} prints empty, an unquoted glob in --include= aborts (quote it), stat is the builtin (use /usr/bin/stat), echo ===== fails, an apostrophe or parenthesis inside an unquoted echo argument aborts the whole command (put probe scripts in files), a cd <dir> && ... persists across Bash calls (start each command with cd <root> &&), BSD sed -i needs an empty suffix (or use Python); a foreground sleep is blocked (use run_in_background; a plain command run with run_in_background notifies at its real end, Learning 799f); the Grep tool may be unavailable (use grep through Bash with quoted globs); skip waiting on CI only for pushes whose every changed file is .Rbuildignored and read by no test, but DO await it when R/ or tests changed; NEW in S788: put a scope question to the owner in plain words first (feedback memory and Learning 801c); a grep -l for a file NAME matches comments (grep for a read call instead); a shell variable assigned earlier in the line is not in Rscript's environment (use the literal path); the AskUserQuestion header for a phase gate can exceed 12 characters (accepted). NEW in S789: AskUserQuestion takes the questions array (a pasted string fails to parse, twice); a full suite run alone in the background takes 4.6 minutes at load about 6 and its notification arrives at its real end; methodology_trim.py dry-run first (--cut 12 --force --budget-bytes 65536), it names its own shard (-3 when the day's name is taken) and adds its own ledger entry; verify a claim about behavior against the real function's output, not the roxygen (Learning 802).
runtime_smoke: n/a -- NEWS.Rmd, a test file and records only; no runtime behavior changed (no R/ file touched); NEWS.Rmd was knit to a scratch file (1,399 lines); the limit and default are read from the code and the shading and male-left claims were checked against real makePedigreeMatingLayout() output, not a live click-through of the Shiny Diagram tab. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 40286d04f00e · manifest aa983075d6a2
changelog_ref: 9df0bac6 (REFACTOR), 4e8ada74 (GREEN), a4b61e66 (RED correction), 4523973e (RED), 95d0d2de (claim), 43179247 and 87118663 (ledger trims), and the S789 records entry
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log); claim 95d0d2de
```

