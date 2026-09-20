# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature
inventory & future plans → `ROADMAP.md`. (Methodology file model — see
`SESSION_RUNNER.md` Phase 0.)*

## Up Next

## Active

## Architecture follow-ups (from TECH_DEBT_AUDIT_2026-05-30.md, re-verified 2026-07-11)

*Resolves the former “Tracker reconciliation” decision item (S365) –
`docs/audits/XARCH_TRACKER_RECONCILIATION_AUDIT_2026-07-11.md`
re-verified all 8 XARCH-1..8 findings against current source rather than
trusting the six-week-old audit text. XARCH-1/3/7 are fully RESOLVED (no
further tracking). XARCH-2 (implicit/ inconsistent module contract) and
XARCH-5 (string-column-keyed pipeline, no validated seam) are STILL OPEN
and owner-directed to GitHub issues \#122 and \#123 respectively – track
them there, not here. XARCH-4 (sex-code literal centralization) is now
also fully RESOLVED – S367 (2026-07-12): see `CHANGELOG.md`. XARCH-6
([`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)/`modInput.R`
multi-call redundancy) is now also fully RESOLVED – S368 (2026-07-12):
see `CHANGELOG.md`. XARCH-8’s narrower remaining gap is now also fully
RESOLVED – S369 (2026-07-12): see `CHANGELOG.md`. The
`man/filterPairs.Rd` staleness this recurring collateral regen left
behind (S367 origin, flagged S368/S369) is now also RESOLVED – S370
(2026-07-12): see `CHANGELOG.md`. No items remain in this section.*

## Up Next

**Act on the LabKey integration research recommendations** (BLOCKED –
remainder needs a live LabKey server to test/observe, Effort M) —
research pass DONE
(`docs/research/labkey-integration-options-2026-06-19.md`, S143).
\*\*Rec \#3 (explicit optional API-key auth with `.netrc` fallback +
clear error) DONE — S144,
[`setLabKeyDefaults()`](https://github.com/rmsharp/nprcgenekeepr/reference/setLabKeyDefaults.md).
Rec \#1 (`Rlabkey` version floor) DONE — S146, `Rlabkey (>= 3.2.0)` in
`DESCRIPTION` (all four EHR-module repos target LabKey 26.6; the live
ONPRC/SNPRC server version, doc §8.1, is still unobserved). See
`CHANGELOG.md`. Rec \#2 (config-ize the ONPRC defaults) DONE — S147:
centralized into the internal `defaultSiteParams()` (single source of
truth for
[`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)‘s
no-config fallback; no behavior change) + documented the center-specific
`lkPedColumns` form in the example config (flat `dam`/`sire` = SNPRC
direct columns; `Id/parents/dam` = ONPRC curated lookup). All three
quick wins (Rec \#1/#2/#3) DONE. **Rec \#4/#5 (formalize a data-source
adapter on the `getPedDirectRelatives` seam + a deterministic mocked
integration test) DONE (fetch-boundary slice) — S148: internal
`getPedigreeSource()` (`labkey` \| `dataframe`) now backs
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)’s
fetch with the walk byte-identical, plus the first deterministic walk
test.** Walk-unification DONE — S149:\*\*
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
now delegates its pedigree walk to
[`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md),
so the LabKey/EHR path returns the full connected pedigree component
(collaterals included), consistent with the in-memory function — a
deliberate, owner-accepted behavior change; the deterministic test now
asserts the full component incl. the previously-excluded collateral
sibling. **`file` provider DONE — S150:** `getPedigreeSource()` gained a
`"file"` source (params `fileName`/`sep`) that reads a pedigree file
(CSV or Excel) via the exported
[`getPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedigree.md),
alongside `"labkey"` and `"dataframe"`; offline-deterministic, validates
id/sire/dam, errors loudly like the `dataframe` branch. **`"file"`
provider WIRED to a first-class caller DONE — S151:** new exported
`getFileDirectRelatives(ids, fileName, sep, unrelatedParents)`, a
file-sourced sibling of
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
(reads via the `"file"` provider, then the source-agnostic
[`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)
walk). The clean symmetric family is now `getPedDirectRelatives`
(in-memory) / `getLkDirectRelatives` (LabKey) / `getFileDirectRelatives`
(file). **Option C — file pedigree source through the focal-animal app
pipeline DONE — S152:** new exported
`getFocalAnimalPedFromFile(fileName, pedigreeFileName, sep)`, a
file-sourced sibling of
[`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md)
(reads focal Ids from one file, builds the connected component from a
separate pedigree file via
[`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md);
fail-soft to a classed `nprcgenekeeprFileErr` whose `message` names WHY
the read failed — bad focal-id list file, a
missing/not-found/unreadable/ wrong-column pedigree file, or no focal
IDs matched — surfaced as the app’s “File Read Error” detail (richer
error messages added S155). `modInput` gained an optional pedigree-file
input on the focal-animals path and dispatches to the offline function
when supplied, else the unchanged LabKey path — so the Shiny
focal-animal workflow can now run offline with no LabKey/EHR connection.
(The focal-id read was factored into a shared internal
`readFocalAnimalIds()`.) **Still deferred:** a non-LabKey other-EHR
provider on the same seam; server-side filtering / `executeSql` /
consuming the centers’ `study.Pedigree`/`ehr.kinship` (research doc
explicitly defers until pull size is measured + per-center query
availability/permissions are confirmed; needs a live LabKey server to
test/observe, and a naive focal-id server filter is incompatible with
the client-side connected-component walk).

**Investigate factoring out the pedigree-diagram drawing functionality
into a separate R package that `nprcgenekeepr` depends on** (found
2026-08-19, owner-directed, READY, Effort M – a research/scoping
session, not an implementation session) – look into the possibility,
advantages, and disadvantages of splitting the pedigree-diagram
layout/rendering code
(`.buildMatingUnitForest()`/`.positionMatingUnitForest()`/`.addRectilinearWaypoints()`/
`.resolveEdgeNodeCollisions()`/[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
in `R/makePedigreeDiagramData.R`, plus the Shiny Diagram-tab module) out
of `nprcgenekeepr` into its own standalone package, with `nprcgenekeepr`
then depending on it. A future session should weigh this independent of,
and probably after, the Walker/BJL apportioning redesign
(`docs/planning/ pedigree-diagram-walker-bjl-apportioning-redesign-plan.md`,
issue \#141) currently in progress – splitting mid-redesign would add
package-boundary churn on top of an already-large in-flight algorithm
change. Not scoped further this session (out of Phase 1a’s own
boundary); a future session should produce the actual
advantages/disadvantages analysis (reuse potential outside this project,
cleaner dependency graph, and versioning/release overhead, cross-package
test/CI complexity, `@noRd`/internal-function visibility loss across a
package boundary, etc.) before any decision to split. **Scoping analysis
DONE S667 (2026-09-02) as a side artifact** – the session was first
(mis-)pointed at this item before the owner redirected it to pedigree
drawing:
[`docs/research/pedigree-diagram-package-split-scoping-2026-09-02.md`](https://github.com/rmsharp/nprcgenekeepr/docs/research/pedigree-diagram-package-split-scoping-2026-09-02.md)
(`findGlobals()`-measured coupling: the layout core reaches back into
the package at exactly one point,
[`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md);
only
[`modPedigreeServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeServer.md)
consumes it; the Shiny module cannot move; recommendation **do not split
now**, with 3 revisit conditions and 3 optional in-place prep steps).
**Owner disposition pending** – the item stays open until the owner
accepts or rejects the recommendation; nothing else to do here until
then. \## Housekeeping

**Measure how much this R package has grown due to the pedigree-drawing
feature — a rough estimate (±20%) is sufficient** (owner-requested
mid-S721, 2026-09-19, READY, Effort S) – quantify the package-size
growth attributable to the pedigree-diagram/ drawing capability (issue
\#129’s Diagram tab, S433/S434, through the S643-S699 pedigree-drawing
campaign): e.g. lines/bytes of the feature’s own source and test files
(the layout core in `R/makePedigreeDiagramData.R`, the Diagram-tab Shiny
module, `R/comparePedigreeStructure.R`, their `tests/testthat/` files,
and the pedigree-diagram vignettes/articles) vs. package totals, and/or
a before/after comparison against a pre-feature commit (~2026-07-29,
before S433). The file-level coupling inventory in
`docs/research/pedigree-diagram-package-split-scoping-2026-09-02.md`
already names the feature’s file set and is a good starting point. Owner
explicitly accepts a rough ±20% estimate – shared-infrastructure
attribution does not need to be precise.

**(Optional, low priority) Root-cause why the pinned Chrome-for-Testing
binary hangs on `macos-latest`’s `ChromoteSession$new()` bootstrap**
(found S619, 2026-08-20, incidental to the chromote CDP-timeout fallback
fix below, READY, Effort M – research only, not required) – the
practical problem is FULLY resolved: `macos-latest` reverts to ambient/
unpinned Chrome (`R-CMD-check.yaml`,
`if: matrix.config.os != 'macos-latest'` on the 3 Chrome-provisioning
steps), verified green on real CI. What remains unexplained: raising
chromote’s `default_timeout` to 60s did NOT resolve the pinned binary’s
hang (same exact failure, wall time roughly doubled, confirming the
session is genuinely wedged, not merely slow) – direct source inspection
confirmed the timeout-governed call is `ChromoteSession$new()`’s own
internal `Runtime.evaluate("window.devicePixelRatio", ...)` bootstrap
probe (`private$get_pixel_ratio()`, chromote 0.5.1), but WHY that
specific probe never gets a response on the pinned macOS ARM64 binary
specifically (vs. the SAME pinned binary working fine on
ubuntu-latest/windows-latest, and vs. ambient Chrome working fine on
macos-latest) is unconfirmed. A research workflow found a plausible but
NOT Chromium- confirmed analog (Mozilla Bugzilla \#1893921 – Firefox’s
own content-process spawn hitting a 5s AppKit/IOKit sandbox-denial stall
specific to GitHub’s *virtualized* macOS ARM64 hosts, fixed by widening
Firefox’s own sandbox allowlist) but found no matching Chromium tracker
entry. Only worth pursuing if pinned-Chrome reproducibility on macOS
specifically becomes valuable later (e.g. `xattr -l` on the extracted
`.app` on a live failing runner to rule out/in Gatekeeper quarantine,
which the same research found NOT evidenced for
`browser-actions/setup-chrome`’s actual download/unzip pipeline; or
filing a new `rstudio/chromote` upstream issue, since no existing issue
there matches this exact macOS+GHA+live-CDP-timeout signature).

**Register `rmsharp/nprcgenekeepr` with api.reuse.software so the REUSE
badge renders its real compliance status** (found S607, 2026-08-18,
DECISION NEEDED / owner action, Effort S) – the badge added above
currently renders gray **“unregistered,”** not green: hitting
`https://api.reuse.software/badge/github.com/rmsharp/nprcgenekeepr`
directly returns an “unregistered” SVG, and
`https://api.reuse.software/info/...` returns “Project not registered.”
This REUSE API service requires a one-time manual registration at
<https://api.reuse.software/register> (repo URL + an email address,
confirmed via a confirmation email) before it will crawl and report a
project’s actual compliance state – this is not something a session can
or should do on the owner’s behalf (it ties an email address to the
public registration and is a one-way “join the registry” action). The
repo itself IS `reuse lint`-compliant now (1234/1234, verified locally);
only the badge’s live display is blocked on this registration step. A
future session can verify the badge went green after the owner
registers, but cannot perform the registration itself.

**`CHANGELOG.md`’s own ~4-entries-per-session ledger convention (claim,
Phase 0 reconcile, deliverable, close-out) may be a `CHANGELOG.md`-side
analogue of the already-diagnosed `HANDOFFS.md` “Receipt Inflation” (H4)
rate problem** (found S543, 2026-08-12, Effort unknown, not
investigated) – incidental to the `SRF_RED` investigation: the tagged
region regrew ~105,000 B in roughly a day during an active multi-session
stretch (S536-S542), and a `grep -c '^### 2026-08-12'` on the pre-trim
file showed a large share of that region was same-day,
multiple-entries-per-session housekeeping (claim/reconcile/close-out
entries) rather than deliverable-content entries. Not confirmed as
causal, and not investigated further this session (out of the `SRF_RED`
decision’s own scope, per `PROJECT_LEARNINGS.md` Learning 382’s “report,
don’t fix mid-session” precedent). A future session could measure the
actual housekeeping-vs-deliverable entry-byte split and decide whether a
norm analogous to the canonical design’s own deferred H4 remedy
(`docs/planning/ledger-trimmer-design.md` §10.2, “the lever is receipt
size, and the mechanism would be a norm plus a check, not an archiver”)
is worth adopting for `CHANGELOG.md` specifically.

**iCloud “conflicted copy” duplicate `.R` files corrupt
`devtools::document()`/`R CMD check` output** (found S461, Effort S, not
a code defect) – `R/appServer 2.R` and `R/modMarkerGenetics 2.R`
(carried forward many sessions as passive noise) are SOURCED by
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)/`devtools::document()`
like any other `.R` file, silently merging their own stale roxygen
comments into the SAME generated `.Rd` page as the current source –
confirmed twice this session (`man/appServer.Rd`,
`man/modMarkerGeneticsServer.Rd`, `man/modMarkerGeneticsUI.Rd`, each
reverted via `git checkout --` immediately). See `PROJECT_LEARNINGS.md`
Learning 454. The owner is relocating this repository outside iCloud’s
purview specifically because of this and other iCloud-latency issues
(same session, out-of-band) – once moved, this item should self-resolve;
a future session should confirm the 2 duplicate files no longer reappear
and, if so, close this item without further action. **Recurred again
S462 (2026-08-03):** the owner rebuilt the package locally (outside this
session’s own tool calls) while reviewing a screenshot, which
re-corrupted the same 3 `.Rd` files the same way; reverted again via
`git checkout --`. As of this session’s Orient, the planned repository
relocation had NOT yet happened (`pwd` still resolves to the original
iCloud-synced path) – this item cannot be closed until the move actually
completes.

**`devtools::check()`’s spelling NOTE has drifted again – 6 new words,
not caught by any session since S461** (found S465, Effort S, incidental
– confirmed pre-existing, not caused by this session’s own diff via a
stash test) – `man/makePedigreeMatingLayout.Rd:40` (“sibship”,
“waypoint”) and `vignettes/a2interactive.Rmd:355,371,429, 437,440,441`
(“duplicateToReal”, “js’s”, “makePedigreeMatingLayout”, “vis”) are
flagged in `devtools::check()`’s `spelling.R` test diff (comparing fresh
`spelling.Rout` against the committed `spelling.Rout.save`) but are not
yet in `inst/WORDLIST`. Mirrors the S443/S448/S452 spelling-gap pattern
(Learning 426, `CLAUDE.md`’s own “Additional close-out checks”
precedent) – a future session should hand-add these 6 words to
`inst/WORDLIST` in `LC_ALL=C` byte-order position (not via
[`spelling::update_wordlist()`](https://docs.ropensci.org/spelling//reference/wordlist.html),
per S230 convention) and re-verify `devtools::check()` drops to the
pre-existing iCloud duplicate-file warning + vignette-engine note only.
**Count grown to 9 words as of S490 (2026-08-09), still not fixed** –
incidental to issue \#136 Slice 2’s own `devtools::check()` verification
pass. The original 6 (`sibship`/`waypoint`/`duplicateToReal`/`js's`/
`makePedigreeMatingLayout`/`vis`) are joined by 3 more: `discoverable`
(`NEWS.md:140`), a bare `js` (`a2interactive.Rmd:533`, distinct token
from `js's`), and `unshaded` (`_pedigree_browser.Rmd:55`) – all 3
confirmed via `git blame`/`git log -S` to trace to commit `100741ae`
(S487, 2026-08-08, issue \#133 Slice 2’s own NEWS/tutorial/article
commit), not this session’s diff. A future session fixing this item
should hand-add all 9 words, not just the original 6. **Count grown to
10 words as of S642 (2026-08-26)** – incidental to this session’s
`test_wordlist_coverage.R` full-regression run: `comparator`
(`R/comparePedigreeStructure.R:230`, a roxygen `@details`-block word,
likely introduced by S633-S636’s original `.comparePedigreeStructures()`
implementation). Confirmed pre-existing via a `git stash` test (fails
identically with this session’s own diff stashed out) – not caused by
this session’s `. formatStructuralDiscrepancy()` work. Not visible on
real CI (all recent `R-CMD-check.yaml` runs green), likely a local
hunspell/ dictionary-state difference from CI’s runner, matching this
item’s own established “local devtools::check() catches words CI’s own
spelling gate doesn’t” pattern.

**`BACKLOG.md`’s own ledger-size housekeeping – editorial compression,
not a `methodology_trim.py` config** (found S518, 2026-08-11, READY,
Effort L) – `BACKLOG.md` itself is one of the dashboard’s 3-file
HIGH-risk ledger-size items but does not fit `methodology_trim.py`’s
chronological-record model: it has 10 `##` sections, each a large
*standing topical category* that accumulates resolved-item narrative
indefinitely, not dated newest-on-top records. The file’s own header
already states the right remedy: “Open, actionable work only… for
history see `CHANGELOG.md`.” **Housekeeping section DONE – S529
(2026-08-12):** an inventory pass (background agent, full read of all
2,501 then-current lines) found 62 top-level items file-wide, 48 fully
resolved, ~1,500 compressible lines total, concentrated in 3 oversized
sections (Housekeeping, “Pedigree diagram vs kinship2,” “Genetic-metrics
PDF audit”). Scoped to Housekeeping only for this session (owner-picked
via `AskUserQuestion`, over top-15-file-wide / single-biggest-item /
prep-only alternatives) – self-contained, bounded by clean section
headers. All 17 of its 19 fully-resolved items compressed to the file’s
own established short-pointer convention; the 8 genuinely-open items
(incl. this one) left untouched. **2 items had NO existing
`CHANGELOG.md` entry at all** (a real ledger gap, FM \#27 – not just
verbose narrative): the `inst/extdata/` reorg (Sessions 415-418) and the
non-portable-filename fix (Session 497). Backfilled proper
`CHANGELOG.md` entries for both before compressing, rather than compress
to a dangling pointer that would have destroyed the only detailed
record. Net: Housekeeping 147→389 lines (263 removed); file total
2,501→2,238 (263 removed). Zero information loss verified by re-reading
the full compressed section end-to-end before close-out. **“Pedigree
diagram vs kinship2 audit follow-ups” section DONE – S530
(2026-08-12):** the 2nd of the item’s 2 remaining sections. Compressed
all 12 fully-resolved bulleted items (issues \#131/#134/#135/#139,
Option 2 layout feasibility/design/3 implementation slices, the
duplicate-node-arc fix, issues \#143/#144) to the file’s own
short-pointer convention, and condensed the ~375-line unbulleted
S480-S500 Progress-narrative chain (Tier 1 crash-bug fixes + \#145
spike + doc refresh; Tier 2 issues \#133/#136/#137/#145, all closed)
into one ~50-line consolidated summary retaining every session number,
design-doc path, and Learning cross-reference. Verified `CHANGELOG.md`
(+ its `docs/archive/CHANGELOG-through-*.md` shards) actually carries an
entry for all 31 session numbers cited before compressing to a pointer –
0 gaps found this time (unlike the Housekeeping section’s 2). All
Learning cross-references and all 11 cited
`docs/planning|audits|research/*` file paths confirmed to resolve. The 4
genuinely -open items (Candidate C’s connector idea; the 3
dangling-parent-crash-bugs and free-pass-filter pointers, both already
short; the node-count-off-by-one gap; the docstring-mismatch gap; the
`highlightNearest` degree=6 bound) left untouched. Net: section
896-\>286 lines (610 removed); file total 2,254-\>1,658 (596 removed,
after this session’s own S518-item progress notes added lines back
elsewhere in the file). Zero information loss verified by re-reading the
full compressed section end-to-end before close-out. **“Genetic-metrics
PDF audit follow-ups” section DONE – S531 (2026-08-12):** the 3rd and
last of the item’s 3 oversized sections. Compressed 8 fully-resolved
issue chains (#126/#127/#129/#130’s shared sequencing-decision bullet,
plus the individually-tracked \#147/#149/#146/#151/#150/#153
design-\>slice narrative chains) to the file’s own short-pointer
convention; also condensed the S479-S483 re-audit/sequencing context
note (still relevant – it names the still-open items) without losing any
issue number, tier assignment, or audit-doc pointer. Left the still-open
issue \#152 chain (design S517, Slice 1 S525, Slice 2 S526, Slice 3
next) fully untouched, matching the S529/S530 “leave open items
untouched” precedent. An early compression pass left a real duplication
defect – the \#153 chain’s design paragraph was replaced but its 3
slice-by-slice progress paragraphs (S520/S521-523/S524) were missed and
briefly duplicated the new compressed bullet – caught by this session’s
own end-to-end re-read before close-out and fixed by removing the
now-redundant paragraphs. Verified `CHANGELOG.md` (+ both
`docs/archive/CHANGELOG-through-*.md` shards) carries an entry for all
39 session numbers cited before compressing to a pointer – 0 gaps found.
All Learning cross-references and all 13 cited `docs/planning|audits/*`
file paths confirmed to resolve. Net: section 753-\>267 lines (486
removed); file total 1,658-\>1,173 (485 removed, some absorbed by this
item’s own progress-note growth). Zero information loss verified by
re-reading the full compressed section end-to-end before close-out.
**The S518 item is now fully RESOLVED – all 3 oversized sections
compressed across 3 sessions:** Housekeeping (S529, 147-\>389 lines),
“Pedigree diagram vs kinship2” (S530, 896-\>286 lines), “Genetic-metrics
PDF audit follow-ups” (S531, 753-\>267 lines). File total: 2,501 lines
(S529 start) -\> 1,173 lines (S531 end), a 1,328-line/53% reduction
across 3 sessions, with zero information loss at any step (each
session’s own end-to-end re-read plus CHANGELOG.md/Learning/file-path
cross-reference verification). See `CHANGELOG.md`. **Correction (S606,
2026-08-18): “fully RESOLVED” held only as a snapshot – a standing
topical section regrows as later sessions append their own progress
narrative to it, exactly the accumulation pattern this item’s own
opening paragraph names as the root problem.** Between S531 and this
session, 3 further issue \#152 slice-completion sessions (S532/S533/
S535) each appended their own multi-paragraph progress update to
“Genetic-metrics PDF audit follow-ups,” regrowing it from S531’s 267
lines back to 304 – with issue \#152 now fully closed (S535), unlike at
S531’s compression time (then still open, Slice 3 pending). Owner picked
this section for re-compression this session via `AskUserQuestion` (over
“Pedigree diagram vs kinship2” and “both sections”). Re-compressed: the
6 progress paragraphs (S517 design + Slices 1-5) condensed into 1
consolidated summary retaining every session number, design-doc path,
and Learning cross-reference. Also corrected 2 stale claims found in the
same pass, not just compressed around them: the section’s own intro
paragraph still said “#152 (Deferred) is in progress (Slice 3 next)”
(superseded by S535’s close); and the S535 paragraph’s own
“shinytest2/chromote headless-modal-rendering harness limitation”
finding was never corrected in place after `PROJECT_LEARNINGS.md`
Learning 542 (S536) retracted it as a test-pedigree-fixture defect
(missing `birth` column), not a harness limitation. Verified
`CHANGELOG.md` (+ its `docs/archive/CHANGELOG-through-*.md` shards)
carries an entry for all 6 session numbers cited
(S517/S525/S526/S532/S533/S535) before compressing to a pointer – 0 gaps
found (1 apparent gap, S492, was a search-pattern false negative: the
archive heading reads “Session 492,” not “S492”). All 6 cited
`PROJECT_LEARNINGS.md` Learning cross-references
(532/538/539/540/541/542) and the 1 cited `docs/planning/*.md` path
confirmed to resolve; issues \#152/#153’s CLOSED state independently
confirmed via `gh issue view`, not assumed from prose. Net: section
304-\>80 lines (224 removed); file total 1,881-\>1,657 (224 removed).
Zero information loss verified by re-reading the full compressed section
end-to-end before close-out. **“Pedigree diagram vs kinship2” (S530’s
own prior compression target) was NOT re-checked this session for the
same regrowth pattern** – out of this session’s own scope; a future
session should check whether it, too, has regrown since S530, and should
treat this item’s own “fully RESOLVED” framing as describing a recurring
maintenance need, not a one-time fix. See `CHANGELOG.md`.

(found S568, 2026-08-14, incidental to this session’s own
[`pkgbuild::build()`](https://pkgbuild.r-lib.org/reference/build.html)
verification, Effort S, not fixed this session) **An empty, untracked
`inst/extdata/reference/untitled folder` directory** (dated 2026-08-13,
the same day as the now-resolved “Compounding Loop” files) sits in the
package source tree – `R CMD build` silently drops it during staging
(“Removed empty directory…”), so it has no build-correctness impact, but
it’s a stray Finder artifact with no content. A future session should
confirm with the owner it’s safe to delete and remove it (no
`.gitignore`/`.Rbuildignore` entry needed for an already-build-dropped
empty directory – just a filesystem cleanup).

## Pedigree diagram vs kinship2 audit follow-ups (from ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md)

*S435’s capability-comparison audit
(`docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md`)
compared the just-shipped issue \#129 pedigree-diagram feature against
kinship2’s pedigree-drawing feature set (17-point checklist, 8 findings,
8 recommendations). Triaged S436 (2026-07-30) via explicit owner
direction (free-text, not per-item `AskUserQuestion` picks): **all 8
recommendations** filed as GitHub issues, tracked there, not here –
including Recommendations 4-7, which the audit itself scored “no action”
(data-model-gated, or an already-ratified Dragon-P3 scope tradeoff);
filing tracks the idea for future consideration and does not reverse the
audit’s own assessment (each issue body preserves the audit’s original
disposition text verbatim). Owner set an explicit priority order that
**inverts** the audit’s own suggested ordering (which rated Finding \#1
highest): **\#131** (diagram image/print export, Finding \#3/Rec \#2,
priority 1) – **\#132** (in-app shape-to-sex legend, Finding \#6/Rec
\#3, priority 2, also resolves plan Dragon P5) – **\#133**
(affected/phenotype/genotype status encoding, Finding \#2/Rec \#4,
priority 3, data-model gated) – **\#134** (verify
inbreeding-loop/consanguinity rendering, Finding \#1/Rec \#1, priority
4, resolves plan Dragon P2 / `PROJECT_LEARNINGS.md` Learning 410) –
**\#135** (hover tooltips + search/highlight, Rec \#8, priority 5) –
**\#136** (name labels instead of ID-only, Finding \#8/Rec \#7, priority
6, data-model gated) – **\#137** (twin/zygosity encoding, Finding
\#5/Rec \#5, priority unranked by the owner, placed 7th as an inference
not a stated decision) – **\#138** (full-colony rendering beyond the
1,500-node cap, Finding \#7/Rec \#6, priority 8 – explicitly
deprioritized/delayed by the owner, `low priority` GitHub label
applied). Owner also directed (mid-session, 2026-07-30) a broader goal:
overlay kinship2’s genetics-domain naming conventions onto the pedigree
data model where applicable when these are implemented, and build test
pedigree fixtures with the corresponding added columns – folded into
\#133 (kinship2’s `affected` argument convention) and \#137 (kinship2’s
`relation` argument convention), the two data-model-adding items. Owner
also directed that any plan implementing one of \#131-#138 must include
a documentation phase (`vignettes/articles/ colony-manager-guide.qmd`
and/or `vignettes/manual_components/_pedigree_browser.Rmd`), now
recorded as `CLAUDE.md`’s “Tutorial/article documentation checklist” –
checking whether this was already true for the base feature found it was
not: **issue \#139** tracks that issue \#129’s already-shipped Diagram
tab has zero tutorial/article coverage today. See `PROJECT_LEARNINGS.md`
Learning 411 and `CHANGELOG.md` for the full S436 triage record. None
imply reopening issue \#129 or revisiting the visNetwork-vs-kinship2
technology decision (D2), which stands as ratified.*

**Sequencing note (S480, 2026-08-08):** the items below through the
`highlightNearest` degree=6 item, plus GitHub issues
\#133/#136/#137/#138/#141/#145, were jointly examined for implementation
order in
`docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`
(kinship2-capability- and nomenclature-reference-informed). Recommended
order: (1) the two dangling-parent crash bugs below + the
free-pass-filter reachability check, (2) issue \#145’s verification
spike, (3) refresh the stale `.qmd` comparison doc below, (4) the
owner’s existing \#133 \> \#136 \> \#137 \> \#138 order, (5) \#141 and
Candidate C stay deferred pending new evidence/owner sign-off.

**Tier 1 – DONE (S481, S482, S484):** the 2 dangling-parent crash bugs +
the free-pass-filter reachability check were filed and fixed as issue
\#154 (S481). Issue \#145’s verification spike (S482,
`docs/research/issue-145-kinship2-sire-dam-placement-spike-2026-08-08.md`)
empirically confirmed (kinship2 v1.9.6.2 source read + 5
synthetic-pedigree tests, not inferred from docs) that kinship2
implements **neither** a hard male-left invariant **nor** a sex-aware
crossing-minimizing default – once an individual has multiple mates,
left/right is decided purely by pedigree-data discovery order; the
issue’s own cited sources were found unreliable on this point.
`docs/planning/pedigree-diagram- kinship2-reference-comparison.qmd` was
refreshed (S484) to reflect issues \#143/#144’s fixes and to add a new
Example 4 reproducing S482’s own kinship2 counter-example directly
(`quarto render` clean, 37 chunks).

**Tier 2 – DONE (S485-S494, S499-S500): issues \#133, \#136, \#137, and
\#145 are all now fully implemented and closed.** Each followed
design-document ratification (`AskUserQuestion`-gated judgment calls)
then 1-3 implementation slices, each slice a full strict-TDD
PRE-RED-\>RED-\>GREEN (-\>REFACTOR) cycle with clean regression +
`devtools::check()` + live `shinytest2`/`chromote` verification, plus
the citation/tutorial/`NEWS.Rmd`/`a2interactive.Rmd` documentation
checklists applied per-slice: - **Issue \#133** (affected/phenotype
status): design S485
(`docs/planning/issue133-affected-status- pedigree-diagram-plan.md` –
new `affected` logical column, `color.background` + tooltip, no new
dependency). Slice 1 (data model + rendering) S486 – found and fixed a
gap where the rectilinear edge style would have silently erased the new
coloring. Slice 2 (legend + docs) S487. **Closed S487.** - **Issue
\#136** (name labels): design S488
(`docs/planning/issue136-name-labels-pedigree-diagram- plan.md` –
corrected 3 premises in the issue itself; found and closed a disclosure
defect,
[`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)
would have left `name` unscrubbed). Slice 1 (data model +
de-identification) S489. Slice 2 (label rendering + off-by-default
toggle + docs) S490 – found and fixed a real
toggle-discarded-on-rerender defect via live verification
(`PROJECT_LEARNINGS.md` Learning 490). **Closed S490.** - **Issue
\#137** (twin/zygosity encoding): design S491
(`docs/planning/issue137-twin-zygosity- pedigree-diagram-plan.md` – new
sidecar `twinRelations` table, zero schema.R changes; a
workflow-truncation tooling defect found and worked around,
`PROJECT_LEARNINGS.md` Learning 491). Slice 1 (data model +
de-identification,
[`checkTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md)/[`obfuscateTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateTwinRelations.md))
S492. Slice 2 (core rendering, MZ/DZ/UZ connector styles) S493. Slice 3
(UI wiring, legend, docs) S494 – found and filed (not fixed) a Slice 2
color-wiring gap as its own Housekeeping item. **Closed S494.** -
**Issue \#145** (sire/dam left-right placement, deferred from Tier 1’s
spike): design S499
(`docs/planning/issue145-sire-dam-left-right-placement-plan.md` – a
3-agent adversarial review refuted the first proposed mechanism,
`orderBySex = TRUE` parameter ratified instead). Slice 1 (core
positioning) S500. **Closed S500** for the ratified simple-pair scope.

**Issue \#138** (full-colony rendering beyond the 1,500-node cap) is the
one item in the owner’s Tier 2 order this cluster did not reach – still
open, tracked as its own GitHub issue (`low priority` label), needing
its own scoping session first, matching \#133/#136/#137/#145’s own
precedent. See `CHANGELOG.md` for the full session-by-session record and
`PROJECT_LEARNINGS.md` Learnings 485, 488-499 for the individual
technical findings. - \[ \] **Candidate C’s connector/dogleg
visual-signposting idea** (found S473, designing the issue \#144 plan;
not adopted for \#144 itself, Effort unknown, low priority) – extends
the existing D2 mate-line “dogleg” (issue \#142) to `edgeStyle="direct"`
(which currently gets zero compensating treatment for any
cross-generation connector) and adds dashed/colored/titled styling to
both edge styles so a multi-generation-spanning mate-line reads as
intentional rather than a positioning bug. Fully validated (including a
real ~37% `edgeStyle="rectilinear"` performance regression found and
fixed during design) but requires its own fresh, explicit owner
product-level sign-off to pursue – independently valuable as a
diagram-readability enhancement, decoupled from \#144’s own resolution
(which does not need it). See
`docs/planning/issue144-anchor-row-mismatch-fix-plan.md` §5/§8. **Also
considered and again not adopted for the kinship2-fidelity remediation
plan’s Track 4 (design S572, implemented S573, 2026-08-14)** – Track 4
ratified and shipped Candidate A (gen-aware D2 anchor selection)
instead, see
`docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md` §3/§8.
Live-rendered (S573, both `edgeStyle` values, zero console errors) with
the redistribution this decision predicted (duplicate nodes 128-\>102,
multi-anchor individuals 2-\>22, max 5). Still not precluded – remains
open as a future, separately-scoped enhancement if the owner judges,
from that live render, that remaining cross-generation mate-lines still
benefit from signposting for legibility. - \[ \] **The live app’s
uploaded/QC’d copy of `obfuscated_rhesus_mhc_ped.csv` produces one fewer
node than reading the same bundled CSV directly** (found S472,
incidental to issue \#143’s live verification, Effort unknown, low
priority) – `direct`-style Diagram node count is 739 live vs. 740 via
[`read.csv()`](https://rdrr.io/r/utils/read.table.html) +
`.buildMatingUnitForest()`/ `.positionMatingUnitForest()` directly (a
stable, already-tested figure, unaffected by this session’s fix); the
live rectilinear -style projection-node count is correspondingly 50
vs. an offline -computed 51. Not investigated further this session (out
of the issue \#143 fix’s own scope, per `PROJECT_LEARNINGS.md` Learning
382’s “report, don’t fix mid-session” precedent) – most likely explained
by the upload/QC pipeline (`modInput.R`’s
[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
or similar) dropping or merging exactly one row relative to a raw
[`read.csv()`](https://rdrr.io/r/utils/read.table.html), but this was
not confirmed. A future session should identify which individual differs
and why, and decide whether the app’s own bundled -fixture test coverage
(`test-e2e-pedigree-module.R`, etc.) should assert this QC’d count
explicitly rather than relying on the raw-CSV-read count as a proxy for
what the live app actually renders. - \[ \]
**`data-raw/rhesusPedigree.R`’s docstring claims
`rhesusPedigree_fromCenter.csv` is an independent raw/pre-obfuscation
source for `obfuscated_rhesus_mhc_ped.csv`, but the two shipped fixtures
are byte-identical on every shared column** (found S470, incidental to
the founder-positioning audit above, Effort S, low priority) – confirmed
via [`identical()`](https://rdrr.io/r/base/identical.html) on
`id`/`sire`/`dam`/`sex`/`gen`/`birth`/`exit`/`age` between the two
files; `rhesusPedigree_fromCenter.csv` differs only by one added
`fromCenter` column (all `TRUE`). The documented
[`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)
id/date-obfuscation transform was evidently never applied to produce
this particular fixture, or produced a no-op. Not fixed this session
(reported per `PROJECT_LEARNINGS.md` Learning 382’s “report, don’t fix
mid-session” precedent – out of the founder-positioning audit’s own
scope). A future session should reconcile the docstring against the
shipped fixture (or regenerate `rhesusPedigree_fromCenter.csv` to match
the documented provenance). See
`docs/audits/FOUNDER_POSITIONING_DEFECT_AUDIT_2026-08-03.md` Finding
\#4, `PROJECT_LEARNINGS.md` Learning 468. - \[ \] **`highlightNearest`
degree=6 mitigation for the rectilinear style is bounded, not a full
fix** (found S468, Effort M, low priority) – a very wide sibship’s D1
sibship-bar chain can exceed 6 hops (chain length scales with the number
of children in one mating unit), so a hover on an individual in a very
large family could still light up nothing visible. A full fix would need
either a custom JS `highlightNearest` reimplementation that specifically
skips through invisible waypoint nodes regardless of hop count, or a
data-layer change that keeps degree-1 semantics correct (e.g. tagging
waypoint edges so a custom traversal treats them as zero-cost hops). Not
designed this session – the degree=6 mitigation was explicitly scoped as
a quick, bounded fix, owner-directed via `AskUserQuestion`. A future
session should measure the real fixture’s own maximum sibship size to
gauge how often 6 hops is actually insufficient in practice before
deciding whether a full fix is warranted.

## Outreach

**NPRC outreach & announcement plan** (DECISION NEEDED – owner
review/edit of drafts + send timing; Effort N/A, not a coding task) –
plan complete: `docs/planning/nprc-outreach-announcement-plan.md` (S413,
owner-directed, not from this backlog). Covers audiences (the NPRC
Genetics and Genomics Working Group, plus each of the 7 centers’
colony-manager/veterinarian contacts), tailored messaging, channels, a
sourced 7-center contact roster (director + colony-manager/
head-veterinarian-equivalent + genetics contact per center, each with a
source), a generic timeline, 5 named risks, and ready-to-edit draft
materials (WG email, colony-manager/vet email, one-page feature summary,
presentation outline). Two items remain genuinely unresolved after
dedicated research, not just undone: the Working Group’s current (2026)
chair could not be confirmed (recommended action: ask
`support@nhprc.org` directly, see the plan’s §3/§8); and a
colony-manager contact could not be named at 3 of 7 centers (Southwest,
Tulane, Washington – the role is undocumented by name on each center’s
own site). **Next steps are owner-executed, real-world actions**
(review/edit the drafts, confirm exact recipients, send) per the plan’s
own §7 – pick this up in a future session only if the owner wants help
drafting a specific follow-up, not as a general “send the emails” coding
task. See `CHANGELOG.md`.

## Architecture (issue \#122 / XARCH-2 – module contract)

*Resolved – S372 planning session through S377 execution (Phases 1-5,
all DONE); see `CHANGELOG.md` for the per-phase detail (S373
vocabulary-composition fix, S374 kinship dedup, S375 vocabulary
collapse, S376 dead-surface pruning, S377 contract doc + guard test).
The living contract is `docs/architecture/module-contract.md`; it is
enforced by `tests/testthat/test_moduleContract.R`. `modInput` is the
reference implementation.*

## Documents (v1.0.8 -\> v2.0.0 write-up)

## Audit follow-ups

*(From `PED_GV_AUDIT_2026-05-30.md`; all audit follow-up items are now
resolved — see `CHANGELOG.md`. Per-item reachability notes and traps
live in `CLAUDE.md` “Project-specific Learnings”.)*

## Genetic-metrics PDF audit follow-ups (from GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md)

*S419’s capability-comparison audit
(`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md`)
compared the package against the 2015 NHP Genetics and Genomics Working
Group PDF and found 12 missing / 9 partial findings (of 37 total).
Triaged S422 (2026-07-29) via owner `AskUserQuestion` picks – all 6
findings/clusters owner-directed to file as GitHub issues, tracked
there, not here: **\#125** (configurable ranking-priority scheme +
surface multiple breeding-group candidates, Dimensions 1 & 2), **\#126**
(kinship/genome-uniqueness distribution shape statistics – skewness,
kurtosis, Dimension 3), **\#127** (surface
`correctUnknownParentMeanKinship()`’s silently-dropped `flagged` list,
Dimension 4), **\#128** (breeding-group exclusion is top-N rank-based,
not a genetic-value floor, Dimension 2), **\#129**
(pedigree-diagram/tree visualization, currently table-only, Dimension
7), **\#130** (marker-based
kinship/heterozygosity/parentage-verification + cross-center identity
resolution, Dimensions 5 & 6). 1 finding (NGS/whole-genome/MHC-specific/
linkage-disequilibrium methods, Dimension 5) declined, no action – the
source PDF itself frames these as speculative future work even in 2015,
matching the audit’s own Recommendation \#5. The remaining findings
(PMX/MateRx/Pedscope/PedSys tool-comparison notes, the “make pedigree
available to researchers” governance recommendation) are descriptive or
already-adequately-served, not gaps requiring tracking. See
`CHANGELOG.md`.*

**Second-generation re-audit and issue-sequencing (S479-S483, 2026-08-05
to 2026-08-08):** a ghost session (reconciled S479,
`PROJECT_LEARNINGS.md` Learning 479) produced 2 further capability
audits
(`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`,
`..._2026-08-06.md`) and filed 8 new GitHub issues: **\#146**
(configurable/exhaustive breeding-group candidate retention), **\#147**
(likelihood-based candidate-parent assignment), **\#148** (MHC
haplotype-specific frequency reporting), **\#149** (cross-center
identity-mapping workflow with provenance export), **\#150**
(de-identified pedigree export workflow), **\#151** (individual
mate-pair analysis), **\#152** (whole-genome/whole-exome sequence
input + sequence-based metrics), **\#153** (linkage-aware/
haplotype-block metrics). Sequencing ratified S483
(`docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md`,
owner-directed, 8-agent codebase-grounded workflow): Tier 1 \#147; Tier
2 \#149 \> \#146 \> \#151; Tier 3 (policy-gated) \#150; Deferred
(design-only) \#152 \> \#153 \> \#148, with \#148 flagged as needing its
own scope-narrowing conversation first (filed broader than the audit
recommends). **Also found, still not filed as of this compression:** 2
audit-table High-priority rows – “Longitudinal genetic-health
monitoring” and “Ancestry guardrails in breeding decisions” – have no
corresponding GitHub issue, despite ranking above every Medium/Deferred
item in this batch (Finding \#1/Recommendation 2); a future triage
session should file both. **Every Tier 1/2/3 item (#147, \#149, \#146,
\#151, \#150) plus Deferred-tier \#152 and \#153 are now fully shipped
and closed** – see the compressed entry below. \#148’s scope-narrowing
conversation is DONE (S703, 2026-09-17, owner via `AskUserQuestion`:
design-first, same issue — decision record
`docs/planning/issue148-mhc-haplotype-scoping-2026-09-17.md`, issue
comment posted) and its design plan is RATIFIED (S704, 2026-09-17 —
`docs/planning/issue148-mhc-haplotype-reporting-plan.md`, D1-D10, owner
picked all 4 recommended judgment calls); Slice 1 (validator + parse
rule) shipped S705 (2026-09-17, strict TDD,
[`checkMhcHaplotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMhcHaplotypeFile.md) +
[`.parseMhcHaplotypeCalls()`](https://github.com/rmsharp/nprcgenekeepr/reference/dot-parseMhcHaplotypeCalls.md));
Slice 2 (statistics) shipped S706 (2026-09-17, strict TDD,
[`mhcHaplotypeFrequency()`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeFrequency.md) +
[`mhcHaplotypeCarriers()`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeCarriers.md));
Slice 3 (de-identification primitive) shipped S707 (2026-09-17, strict
TDD,
[`obfuscateMhcHaplotypes()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateMhcHaplotypes.md));
Slice 4 (the 8th Marker Genetics tab “MHC Haplotype Reporting” +
confirm-gate export + `.buildMhcExportManifest()` + tutorial/terms/NEWS
docs) shipped S708 (2026-09-18, strict TDD, live E2E) – **issue \#148 is
DONE and closed**, so every issue in this batch (#146-#153) is now
shipped and closed. See `CHANGELOG.md`.

**Progress, issue \#152 (whole-genome/whole-exome sequence input +
sequence-based genetic metrics) – DONE, closed (design S517 through
close-out S535, Sessions 517-535).** Design ratified S517
(`docs/planning/issue152-sequence-input-genetic-metrics-plan.md` – two
parallel background research agents plus direct verification of the
load-bearing prior Bioconductor -Imports decline): sparse/GBS-scale
scope tier (~50,000-locus ceiling); a shared `locusMetadata`
(`locus, chrom, pos[, cM]`) sidecar reused by sibling issue \#153;
genome-wide F_ROH (new, Ceballos et al. 2018) plus genome-scale reruns
of the existing kinship/heterozygosity/Fst functions; a new tab inside
the existing `modMarkerGenetics.R` rather than a dedicated module.
Scoped as 5 vertical slices, each its own session, each a full
strict-TDD PRE-RED-\>RED-\>GREEN(-\>REFACTOR) cycle gated by
`AskUserQuestion`: - **Slice 1** (S525): new
[`checkSequenceGenotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSequenceGenotypeFile.md)
structural validator (reuses issue \#153’s
[`checkLocusMetadata()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md));
`data-raw/generate_sequence_fixtures.R` (seeded 50-individual x
1,000-locus synthetic biallelic SNP panel + `locusMetadata` sidecar,
committed as `inst/extdata/examples/example_sequence_*.csv`). - **Slice
2** (S526):
[`markerKinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md)/[`markerParentageLikelihood()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageLikelihood.md)
performance rewrite – vectorized matrix algebra / precomputed per-locus
allele-frequency tables – _(2x/)2.4x speedups, output unchanged
(golden-master +
[`system.time()`](https://rdrr.io/r/base/system.time.html) benchmark
regression tests; the median-of-3 -reps timing-stability fix is
`PROJECT_LEARNINGS.md` Learning 532). - **Slice 3** (S532): new
[`computeGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/computeGenomicROH.md)
F_ROH metric (Ceballos et al. 2018 convention), reuses
[`checkLocusMetadata()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md)’s
coverage classification. `PROJECT_LEARNINGS.md` Learning 538 (a
lower-than-baseline `devtools::check()` NOTE count needs the same direct
verification as a higher one) originates here. - **Slice 4** (S533): new
[`obfuscateGenotypeMatrix()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenotypeMatrix.md)
de-identification primitive, mirrors the established `obfuscate*` family
pattern. `PROJECT_LEARNINGS.md` Learning 539 (verification tools must be
invoked with the project’s own default config/args, not an override)
originates here; found (not fixed) the `.Rbuildignore`
`methodolog_trim.py` typo, fixed next session (Learning 540). - **Slice
5** (S535, closes \#152): new “Genomic ROH (F_ROH)” tab in
`R/modMarkerGenetics.R` (curator confirm-gate export: de-identified
genotype matrix + F_ROH table + manifest), new
[`obfuscateGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenomicROH.md).
Live Phase 3E verification found and fixed a real bug –
`sequenceRohTable` fed `locusMetadata()`’s
already-[`checkLocusMetadata()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md)-processed
output back into
[`computeGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/computeGenomicROH.md),
which re-runs that same check internally, silently mislabeling a column
(`PROJECT_LEARNINGS.md` Learning 541). S535 also suspected a
`shinytest2`/`chromote` headless-modal-rendering harness limitation
blocking the export-confirm modal – **`PROJECT_LEARNINGS.md` Learning
542 (S536) corrects this: there was no harness limitation, the real
cause was a test pedigree fixture missing the required `birth` column,
which silently blocked `req()` upstream of `showModal()`; fixed by
completing the fixture.**

Each slice: full clean regression 0 failed/0 error, `devtools::check()`
clean modulo pre-existing NOTEs, citation/`NEWS.Rmd`/`_pkgdown.yml`
checklists applied per-slice (tutorial/article checklist satisfied at
Slice 5; `a2interactive.Rmd` deferred per its own standing rule). See
`CHANGELOG.md` for the full session-by-session record.
