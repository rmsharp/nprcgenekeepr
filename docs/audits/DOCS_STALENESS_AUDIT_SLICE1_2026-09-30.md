# Documentation Staleness Audit, Slice 1 (Session 820)

**Question answered:** the owner saw stale figures in `vignettes/articles/pedigree-diagram.pdf` and
`vignettes/articles/kinship2-fidelity-validation.pdf`. Is the staleness only in those local PDFs,
or also in the committed article sources and static images?

**Answer:** both. The two PDFs are stale local renders (and carry claims the sources have since
retracted). One of the 8 committed `kinship2-fidelity-validation-img/` images is also stale; the
other 7 are current.

- **Date:** 2026-09-30 · **HEAD when read:** `2522ee676` (R code unchanged since the S817 commits).
- **Type:** read-only audit. **No tracked file was modified except this report.** The figure
  regeneration below overwrote the committed images in place (the script writes there) and
  `git checkout` restored them; `git status` showed no tracked change afterward.
- **Method:** counted and measured, not recalled. Figures were regenerated from today's code with
  `data-raw/kinship2FidelityValidation.R` and compared pixel by pixel (Pillow) with the committed
  PNGs. The script was run twice; the two runs were pixel-identical (0 differing pixels over a
  threshold of 64/255 in all 8 images), so a difference from a committed image is real, not noise.

## Audit Summary

- **Scope:** the two named PDFs, their two `.qmd` sources, the 8 `kinship2-fidelity-validation-img/`
  figures, and the Diagram-limit wording the S789 note flagged.
- **Criteria:** (1) does each artifact match today's code or output; (2) is it tracked, ignored or
  referenced; (3) does each claim checked still hold.
- **Coverage:** see "Items audited" and "Not audited" below. This is slice 1 of several.
- **Findings:** 0 critical, 2 moderate, 3 minor.

## Findings

### Finding 1: both article PDFs are stale local renders, untracked, unignored, unreferenced
- **Severity:** Moderate
- **Location:** `vignettes/articles/pedigree-diagram.pdf`, `vignettes/articles/kinship2-fidelity-validation.pdf`
- **Evidence:** `pdfinfo` creation dates are 2026-08-25 09:39. The sources were edited later:
  `kinship2-fidelity-validation.qmd` last 2026-09-18 (`318c32da6`, with earlier corrections on
  08-27 and 08-30), `pedigree-diagram.qmd` last 2026-09-28 (`893d485c2`; the "Reading classic
  breeding structures" section arrived 09-17). Text extraction (`pdftotext`) shows the
  `pedigree-diagram.pdf` has 0 matches for "classic breeding structures" (the source has 2), and the
  `kinship2-fidelity-validation.pdf` still says the 9-subject fixture forces a rectilinear "dogleg"
  (its text lines 146-192), a claim the source retracted ("That dogleg no longer occurs", S573,
  corrected S645/S657). `git status` lists both as untracked (`??`); `git check-ignore` matches
  neither (`.gitignore:21` covers only `vignettes/*.pdf`); no file in the repo, outside the
  archived worktree copies and the ledgers, references either PDF.
- **Impact:** a reader opening the local PDF sees figures and claims the project has corrected.
  Because they are not ignored, they also show in every `git status` and could be committed by
  accident.
- **Recommendation:** owner decision on the files (they are the owner's local renders, so this
  session did not delete them): delete them, or re-render and ignore them. If kept, add
  `vignettes/articles/*.pdf` to `.gitignore` so they stop appearing as untracked.

### Finding 2: `trackC-nprc-rectilinear.png` is stale against the current engine
- **Severity:** Moderate
- **Location:** `vignettes/articles/kinship2-fidelity-validation-img/trackC-nprc-rectilinear.png`
  (committed 2026-09-10, `29c46f561`), used at `kinship2-fidelity-validation.qmd:222`
- **Evidence:** a fresh render differs in a 170 x 46 px region (bounding box x 508-678, y 171-217),
  213 pixels over threshold. The committed image draws the dashed duplicate-person connector as a
  high arc that clears the `W` square; the fresh render draws a flatter arc that reaches the top
  edge of the `W` square. The image predates S714 (2026-09-18, `318c32da6`, "curved-connector arc
  model"), which is the likely cause; the commit message of S714 is about the census measure, so
  this attribution is a likely cause, not a confirmed one. The article text for this figure
  (`:222`) describes the marker edges, not the arc shape, so the prose is not contradicted.
- **Impact:** the published figure does not show what `makePedigreeMatingLayout(edgeStyle =
  "rectilinear")` draws today.
- **Recommendation:** regenerate by running `data-raw/kinship2FidelityValidation.R` and commit the
  changed image in its own session. Before committing, look at the fresh arc touching the `W`
  square: S714's census counts "arc-inside-symbol" events, so it may be known, but this audit did
  not confirm that it is.

### Finding 3: the Diagram-limit wording in the user manual reads misleadingly
- **Severity:** Minor (already noted S789)
- **Location:** `vignettes/manual_components/_pedigree_browser.Rmd:62-65`
- **Evidence:** the text says "up to 750 animals ... the limit drops to 400 animals when the
  Rectilinear edge style below is selected". In `R/modPedigree.R:426` and `:438` the caps are 750
  (direct) and 400 (rectilinear), and `.currentEdgeStyle()` returns `"rectilinear"` until the
  radio button has rendered (`R/modPedigree.R:445-446`), so Rectilinear is the default. A reader
  of the default view is told 750 when the cap they meet is 400.
- **Recommendation:** reword to lead with the default: "up to 400 animals with the default
  Rectilinear edge style (750 with Direct)".

### Finding 4: an in-code comment says the edge style defaults to "direct"
- **Severity:** Minor (internal)
- **Location:** `R/modPedigree.R:440-443`
- **Evidence:** the comment says the style is "defaulting to "direct" before the style toggle ...
  has ever rendered (so the very first render is byte-identical to pre-issue-142 behavior)", but
  the function body returns `"rectilinear"` at `:445-446`. The comment most likely describes the
  behavior before the default changed (the article was updated "for the new default" in S574,
  `6a619ad11`); this audit did not trace the commit that changed the code default.
- **Recommendation:** correct the comment (a comment-only change; run `lintr` on the file).

### Finding 5: the other 7 kinship2 images are current
- **Severity:** Minor (a pass, recorded so the next slice does not re-check it)
- **Evidence:** per image, pixels that differ at all / over threshold 64: `trackA-kinship-heatmaps`
  595/0, `trackB-kinship2-full` 383/0, `trackB-kinship2-shrunk` 442/0, `trackB-nprc-full` 65/0,
  `trackB-nprc-shrunk` 36/0, `trackC-kinship2` 475/0, `trackC-nprc-direct` 16/0. All differences
  are anti-aliasing (none over threshold); every file differs byte for byte, so a byte comparison
  is useless for these. The script's structural checks (Track D) all reported identical to
  kinship2: Track B full TRUE, Track B shrunk TRUE, Track C TRUE.

## Items Audited

| Item | Status | Findings |
|---|---|---|
| `vignettes/articles/pedigree-diagram.pdf` | Fail (stale) | 1 |
| `vignettes/articles/kinship2-fidelity-validation.pdf` | Fail (stale) | 1 |
| `kinship2-fidelity-validation-img/trackC-nprc-rectilinear.png` | Fail (stale) | 2 |
| other 7 `kinship2-fidelity-validation-img/*.png` | Pass | 5 |
| `vignettes/manual_components/_pedigree_browser.Rmd` Diagram-limit sentence | Fail (misleading) | 3 |
| `R/modPedigree.R:440-443` comment | Fail (stale) | 4 |
| `vignettes/articles/pedigree-diagram-img/` (5) | Pass, not re-run (measured S805, see `BACKLOG.md`) | none |

## Not audited (later slices)

- `vignettes/articles/shiny_app_use/` (50 images): the next slice. Each needs the Shiny app
  driven to its screen, so it is its own session.
- The prose claims of both `.qmd` files beyond the three spot-checks above (the "6 of 237 unions"
  count at `kinship2-fidelity-validation.qmd:166`, the census numbers, the node-shape legend).
- User-facing: `README`, the other `vignettes/` and `vignettes/articles/*.qmd`, the pkgdown site,
  `NEWS.Rmd`, `inst/extdata/ui_guidance/`, the `man/` pages.
- Internal: `docs/` (planning, audits, research), `ROADMAP.md`, `CLAUDE.md`, `BACKLOG.md`.

## Structural Observations

- Every stale artifact here is a **rendered or generated output** that outlived its source
  (two PDFs, one PNG, one code comment). None of the checked prose sources was found wrong
  beyond the known manual sentence. A render-date-versus-source-date check finds this class
  mechanically; slice 2 can use `git log` dates on each image against its generator's last change.
- The figure generator is deterministic and writes straight into the committed directory, so
  "regenerate and diff" is cheap and safe to repeat (two identical runs here).

## Recommendations

1. Owner: delete the two PDFs, or ignore them (`vignettes/articles/*.pdf` in `.gitignore`).
2. Own session, strict TDD where it applies: regenerate `trackC-nprc-rectilinear.png`; look at the
   arc/`W` contact before committing it.
3. Fix the manual sentence (Finding 3) and the code comment (Finding 4); both are small. The
   comment-only code change needs no new test but does need `lintr` on the file.
4. Slice 2: the 50 `shiny_app_use/` images.
