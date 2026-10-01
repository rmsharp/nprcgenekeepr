# Docs staleness audit, slice 7: `NEWS.Rmd` (2026-10-01, S845)

Read-only audit. Nothing in the repo was changed except this report and the session records.

## Audit summary

- **Scope:** `NEWS.Rmd` (1,305 lines) and its rendered copy `NEWS.md`. Lines 1-14 (header), 15-551 (the
  development-version release notes), 552-736 (the 2.0.0 section). Lines 737-1305 (releases 1.0.8 back to
  nprcmanager 0.5.07) are history and were only grepped for text presented as current. The internal docs
  (`docs/`, `ROADMAP.md`, `CLAUDE.md`, `BACKLOG.md`) are **not covered**; they are the rest of slice 7's item.
- **Criterion:** does each checkable claim (UI label, default, count, function or argument name, described behavior,
  file, date, version) still match today's code? Is the dev section written as finished release state against 2.0.0
  (the project's NEWS rule), not as a milestone log? A 2.0.0 sentence is stale only if it is wrong about 2.0.0 or is
  present-tense about behavior that has since changed.
- **Method:** four read-only subagents (lines 15-194, 195-387, 388-551, and the 2.0.0 section plus file-level checks).
  This session then re-ran or re-read the code for the three moderates and four of the minors (column "Check").
  **R** = code re-read, **A** = run, **S** = this session re-checked. Agent-only checks are marked with the agent's own
  letter.
- **Coverage:** 3 of 3 audited regions. About 210 claims checked by the agents (about 30 + 75 + 58 + 45); the great
  majority are current. Every function name in the dev section is exported; every UI label checked matches.
- **Findings:** 0 critical, **3 moderate, 16 minor** (19). No wrong default, count of functions, argument name or UI
  label was found in the dev section. The staleness is (a) two "Fixed" bullets that announce fixes to files and a tab
  that never shipped, (b) the rendered `NEWS.md`, 37 commits behind, and (c) milestone-style wording and a few
  small inaccuracies.

## Findings: Moderate

| ID | Location | Claim | Evidence | Fix | Check |
|---|---|---|---|---|---|
| NC1 | `NEWS.Rmd:462-468` | "Fixed: on the Marker Genetics tab, generating a de-identified export preview could abruptly end the session" | `git cat-file -e v2.0.0:R/modMarkerGenetics.R` fails: the tab is new since 2.0.0, so the bug existed only in unreleased code. A reader of the release notes has no baseline for it. | Delete the bullet; the finished tab is described in the Marker Genetics section | S |
| NC2 | `NEWS.Rmd:545-550` | "Fixed: the example `ExamplePedigree.txt` had been saved through Excel ... `getPedigree()` could not read it" | `inst/extdata/examples/ExamplePedigree.txt` is not in `v2.0.0` (checked): a never-released file. | Delete the bullet (at most say the example ships as `.csv` and `.txt`) | S |
| NE1 | `NEWS.md` (whole dev section) | `NEWS.md` is the rendered copy of `NEWS.Rmd` | Last regenerated 2026-09-18 (`37d17a55a`); 37 `NEWS.Rmd` commits since (S788-S817). The agent compared the 2.0.0 section: identical. Only the dev section (Pedigree Diagram, Marker Genetics, MHC, Genetic Value and Breeding Groups, General Fixes) is stale. Not regenerated here. | Re-render `NEWS.Rmd` after the NEWS fixes below, in one commit | A |

## Findings: Minor

| ID | Location | Claim / problem | Evidence / fix | Check |
|---|---|---|---|---|
| NA1 | `NEWS.Rmd:17-19` | "## Package": CRAN accepted 2.0.0, published 2026-07-26 | A release event, not a dev-version change, and the section's only bullet. CRAN date not verifiable offline. Delete the bullet and heading, or move it under 2.0.0 | R |
| NA2 | `NEWS.Rmd:82-86, 153-157` | Two bullets on Rectilinear obstacle rerouting; the second says "see the rerouting entry above" | The second only refines the first. "Partial correction ... disclosed residual" is milestone wording; agent run on the 375-animal pedigree still warns of 72 unresolved collisions while the text says "small number". Merge; state the residual in finished terms | A |
| NA3 | `NEWS.Rmd:132-141, 146-152` | Three bullets on a mate shown as a duplicate marker beside the partner, each repeating "straighter lines to children" | Same topic. Merge into one end-state bullet | R |
| NA4 | `NEWS.Rmd:69-77, 90-97, 118-126, 173-193` | Incremental phrasing: "no longer occasionally show a stray dot", "crossings cut by roughly three quarters", "about a quarter shorter" | Relative to earlier dev states; 2.0.0 had no Diagram, so there is no baseline. The percentages were not reproduced. Condense to end-state descriptions; drop before/after figures | R |
| NB1 | `NEWS.Rmd:337-340, 344-346` | "shows up to 5 candidate groupings" and, a bullet later, "**Candidates to retain** ..., replacing a fixed cap of 5" | `maxCandidates = 5L` (`R/groupAddAssign.R:183`); UI default 5, range 1-50 (`R/modBreedingGroups.R:116-118`). "Replacing a fixed cap" is a state that never shipped. Merge into one bullet | R |
| NB2 | `NEWS.Rmd:347-350` | Exhaustive mode "checks every possible single-group split" | Agent read: it enumerates maximal groups, bounded by `maxExhaustiveCandidates = 20L` and `exhaustiveTimeLimit = 10` s (`R/groupAddAssign.R:57-70,184-186`); offered only for one group, no harem, no custom ratio (`R/modBreedingGroups.R:129-131`). Reword, name both limits | R (agent) |
| NB3 | `NEWS.Rmd:205-210` | `kinship(chrtype = "x")` described as a plain option | `R/kinship.R:68` says `sex` is "Required when `chrtype = "x"`" (re-read). Add that | S |
| NB4 | `NEWS.Rmd:311-314` | The `checkCrossCenterMapping()` bullet ends "Merging preserves every one of an animal's own data columns (issue #149)" | Re-read: that sentence is about `resolveCrossCenterIds()` (line 308, which has no issue ref). Move it there | S |
| NB6 | `NEWS.Rmd:351-386` | Ancestry Guardrails: one ~35-line bullet; quoted status "2 block, 2 flag rule(s)" | Real text is "%d block, %d flag rule(s); %d animal(s) uncovered." (`R/reportAncestryViolations.R:200`). Quote the full line or drop the quote; split into bullets | R (agent) |
| NC3 | `NEWS.Rmd:512-513` | "the shipped ancestry example now counts its founder `U1` (4 female founders, not 3)" | `example_ancestry_pedigree.csv` is not in `v2.0.0` (checked); the "not 3" refers to a never-released state. "4" is right today (agent ran `read.csv`). Drop the parenthetical | S |
| NC4 | `NEWS.Rmd:418` | De-Identified Export tab: "a curator workflow with a live preview" | `R/modDeidentifiedExport.R:117,204`: the preview is a **Generate Preview** button, parameters snapshotted at the click; nothing is live (re-read). Say "a preview generated on request" | S |
| NC5 | `NEWS.Rmd:507-524` | The `U1`/`placeholder` bullet: an 18-line bullet mixing a fix, the new `placeholder` column, de-identified-export and center-linking behavior | Split into a fix bullet and a "New `placeholder` column" bullet; re-wrap line 521 | R (agent) |
| NC6 | `NEWS.Rmd:530-534` | "Changed:" Potential Parents bullet | Behavior fine; "Changed:" breaks the "Fixed:" style used elsewhere. Optional | R (agent) |
| ND1 | `NEWS.Rmd:3` | YAML `date: "2026-01-26"` | File last changed 2026-09-30, and the date is a fixed string. Update or drop | R |
| ND2 | `NEWS.Rmd:552` | Heading "nprcgenekeepr 2.0.0 (20260708)" | Tag `v2.0.0` is dated 2026-07-21 (tagged commit 2026-07-17, checked); the dev section says CRAN published 2026-07-26. No source gives 07-08. Owner to confirm the intended date | S |
| ND3 | `NEWS.Rmd:732-734` | "Potential Parents tab can show a populated result (1,587 candidates)" for `examplePedigree` | `getPotentialParents(examplePedigree)` returns 1,587 list elements, one per animal with an unknown parent; candidates total 140,757 (run: `1587 140757`). Say "1,587 animals with an unknown parent" | S |

## Not verified

- The CRAN publication date (no network); issue numbers #125-#168; the before/after figures in NA4; rendered Diagram
  behavior (legend, hover, search, twin connectors, tie-break, mating-symbol centering) which lives in the
  visNetwork output; the Candidate Parent Assignment suggestion (#155); the "optimized for large marker panels" claim
  (#152); the sex-whitespace, `convertDate()`, `addUIds()` and `removeDuplicates()` fix bullets (functions exist, no
  before/after run); the Genetic-Health Trends "start a new one" path; per-species age and config keys in the 2.0.0
  section end to end; the conception-window rule.
- NB5 and NB7 were dropped, not findings: NB5 was cosmetic and correct; NB7 asked whether Mate Pair uses
  `twinRelations`; `grep` in `R/modMatePair.R` finds none, so the list in the text is complete.

## Leads outside this slice

- The agent for the 2.0.0 section saw `R/appServer.R:114` say "CRAN archived nprcgenekeepr 2.0.0" while
  `cran-comments.md` says 1.0.8 was archived. Not checked by this session; a candidate for a code-comment fix.

## Structural observations

- All three moderates and most minors share one cause: the dev section was grown one session at a time, so bullets
  describe the steps (a fix to a feature added a week earlier, a restatement "see above") instead of the end state
  against 2.0.0. The NEWS release-state rule applies. The Pedigree Diagram section (NA2-NA4) is the largest remaining
  case, consistent with the standing note that it is still to be condensed in stages.
- Every name, default, count and UI label that could be run or grepped held. The file is accurate about the code; it
  is not yet written as a release note.

## Items audited

| Item | Status | Findings |
|---|---|---|
| Header, version, dates (1-14, 15, 552) | Fail (minor) | ND1, ND2 |
| Package (17-19) | Fail (minor) | NA1 |
| Pedigree Diagram (21-194) | Fail (minor) | NA2-NA4 |
| Kinship, Marker Genetics, MHC, Cross-Center, Genetic Value, Breeding Groups (195-387) | Fail (minor) | NB1-NB4, NB6 |
| Mate Pair, De-Identified Export, Longitudinal Monitoring, General Fixes (388-551) | Fail | NC1, NC2 (moderate); NC3-NC6 |
| 2.0.0 section (552-736) | Pass except ND3 | ND3 |
| History (737-1305) | Pass (grep only) | none |
| `NEWS.md` (rendered) | Fail | NE1 |

## Recommendations

1. Fix NC1 and NC2 (delete two bullets), then the minors that are wording only (NB1-NB4, NC3-NC5, ND1-ND3, NA1).
   This is a docs-only pass (NEWS.Rmd), one session.
2. Condense the Pedigree Diagram section (NA2-NA4) as its own staged pass, per the existing NEWS release-state work.
3. Re-render `NEWS.md` last (NE1), after the text changes, and run the NEWS guard test.
4. Owner decision: the 2.0.0 heading date (ND2).
