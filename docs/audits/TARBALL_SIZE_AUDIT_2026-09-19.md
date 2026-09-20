# Source-Tarball Size Audit

**Date:** 2026-09-19 (Session 727)
**Trigger:** `BACKLOG.md` Up Next item "Reduce the built package (source tarball) size toward
CRAN's ≤10 MB policy — owner reports the current tarball at ~19 MB" (owner-requested mid-S726,
READY, Effort L — "extensive code research first: a tarball-contents inventory session, then
remedy slices").
**Workstream:** `docs/methodology/workstreams/AUDIT_WORKSTREAM.md`.
**Scope:** Measurement and recommendations only. No remedy applied; no `R/`, `tests/`,
`.Rbuildignore`, or `.gitignore` change (TDD gates do not apply). Every number below was
measured this session against `f8ffa40b` (the S727 claim; identical to S726's `fd9c8911` for
every file that ships). Reproduction commands are in §7.

---

## 1. Audit Summary

**The package is not oversized. The ~19 MB tarball was a build-hygiene leak, not package
content.** A tarball built from a clean export of `HEAD` is **3,485,185 B (3.49 MB) — 35% of
CRAN's 10 MB guideline.** The owner's 19.7 MB artifact contains the untracked, 20 MB
`scratchpad/` working directory, which the *committed* `.Rbuildignore` does not exclude.

| Build | Size | What it is |
|---|---|---|
| Owner's artifact, `../nprcgenekeepr_2.0.0.9000.tar.gz` (built 20:14, 2026-09-19) | **19,732,245 B** | 1,260 entries, of which **252 are `scratchpad/`** (19.99 MB uncompressed) + the since-deleted `~$e Compounding Loop.html` lock file |
| Reproduction: clean `HEAD` export **+ `scratchpad/` + untracked test debris copied in**, committed `.Rbuildignore` | **19,714,510 B** | Reproduces the owner's figure to within 0.1% (the residual is the lock file S725 deleted) |
| Current working tree (includes the owner's **uncommitted** `^scratchpad$` line) | **3,564,041 B** | Leak closed; +78,856 B over clean is untracked testthat debris (Finding 2) |
| **Clean export of `HEAD` (`git archive`) — what a fresh clone / CRAN submission gets** | **3,485,185 B** | 997 entries, 12.01 MB uncompressed |
| CRAN release `nprcgenekeepr_2.0.0.tar.gz` (published 2026-07-26) | 2,419,329 B | Baseline: dev is **+1,065,856 B (+44%)** since release |

- **Criteria:** CRAN Repository Policy, revision 6875, fetched this session
  (<https://cran.r-project.org/web/packages/policies.html>): "Source package tarballs should if
  possible not exceed 10MB"; "As a general rule, neither data nor documentation should exceed
  5MB"; "Packages should be of the minimum necessary size." Plus `R CMD check`'s installed-size
  check (reports above 5 MB) and a hygiene criterion: nothing that is not package content ships.
- **Coverage:** all 997 entries of the clean tarball attributed by directory; every file >30 KB
  individually weighed compressed; all 3 untracked non-ignored paths in the working tree examined.
- **Finding count:** 0 critical · 2 moderate · 3 minor.

### Criteria grid

| # | Criterion | Measured | Verdict |
|---|---|---|---|
| C1 | Source tarball ≤ 10 MB | 3.49 MB | **Pass** (6.5 MB headroom) |
| C2 | Data ≤ 5 MB | `data/` 0.16 MB + `inst/extdata/` 2.50 MB = 2.66 MB | **Pass** |
| C3 | Documentation ≤ 5 MB | `inst/doc/` 4.38 MB + `man/` 0.66 MB uncompressed (installed: `doc` 4.3 + `help` 0.9 MB) | **Borderline** — Finding 3 |
| C4 | Only package content ships | Committed `.Rbuildignore` lets `scratchpad/` (16.3 MB compressed) and testthat debris through | **Fail at `HEAD`** — Findings 1, 2 |
| C5 | Installed size (check reports > 5 MB) | 8.9 MB local; CI 9.5–10.2 MB across 5 platforms (`INFO`, not a NOTE, on current R) | **Informational** — Finding 4 |

---

## 2. Where the 3.49 MB goes

Compressed attribution (each directory re-compressed alone with `gzip -9`; the parts sum to
3.59 MB against the real 3.49 MB, so read these as ±4%):

| Directory | Uncompressed | Compressed | Share | Entries |
|---|---|---|---|---|
| `inst/doc/` (built vignettes) | 4.38 MB | **1.37 MB** | 38% | — |
| `tests/` | 2.69 MB | 0.66 MB | 18% | 341 |
| `inst/extdata/examples/` (23 files) | 2.33 MB | 0.46 MB | 13% | — |
| `R/` | 1.23 MB | 0.39 MB | 11% | 276 |
| `man/` | 0.66 MB | 0.31 MB | 9% | 265 |
| `inst/extdata/reference/` (1 PDF) | 0.16 MB | 0.15 MB | 4% | — |
| `data/` | 0.16 MB | 0.14 MB | 4% | 26 |
| `vignettes/` (sources) | 0.14 MB | 0.05 MB | 1% | 22 |
| everything else (`ui_guidance`, `testdata`, `www`, root files) | ~0.2 MB | ~0.06 MB | 2% | — |

Largest individual files, ranked by what they cost **compressed** (the number that counts
toward the 10 MB):

| Compressed | Uncompressed | File |
|---|---|---|
| 855 KB | 2,766 KB | `inst/doc/a2interactive.html` |
| 233 KB | 863 KB | `inst/doc/simulatedKValues.html` |
| 225 KB | 676 KB | `inst/doc/gvaConvergence.html` |
| 154 KB | 162 KB | `inst/extdata/reference/Master_Genetic_metrics_2_14_15.pdf` |
| 143 KB | 148 KB | `inst/extdata/examples/2022-05-02_Deidentified_Pedigree.xlsx` |
| 126 KB | 1,248 KB | `inst/extdata/examples/example_sequence_genotypes.csv` |
| 83 KB | 88 KB | `man/figures/card.png` |
| 55 KB | 317 KB | `tests/testthat/exampleFile.txt` |
| 54 KB | 261 KB | `inst/extdata/examples/ExamplePedigree.csv` |
| 52 KB | 265 KB | `inst/extdata/examples/ExamplePedigree.txt` |
| 47 KB | 149 KB | `R/makePedigreeDiagramData.R` |
| 44 KB | 46 KB | `man/figures/logo.png` |
| 44 KB | 156 KB | `tests/testthat/test_positionMatingUnitForest.R` |
| 42 KB | 271 KB | `inst/extdata/examples/deidentified_jmac_ped.csv` |

Two things this table corrects in the BACKLOG item's on-disk anchors: (a) the biggest
*uncompressed* example file, `example_sequence_genotypes.csv` (1.25 MB), costs only 126 KB in
the tarball — text compresses ~10:1, so slimming CSV examples buys little; (b) the three
`html_document` vignettes are **1.31 MB compressed — 38% of the whole tarball** — and are the
only place a meaningful size remedy exists. `tests/` is 99% `.R` source (2.37 MB of `.R`, one
317 KB data file); there are no heavyweight fixtures to slim.

---

## 3. Findings

### Finding 1 — `scratchpad/` ships in any working-tree build from the committed `.Rbuildignore` (Moderate)
- **Location:** `.Rbuildignore` at `HEAD` (no `scratchpad` entry — and never has had one:
  `git log -S'scratchpad' -- .Rbuildignore` is empty); `scratchpad/` (untracked, 250 files,
  oldest dated 2026-08-17, 20 MB on disk, 16,271,360 B compressed — two ~5.6 MB `.rds` regression captures,
  `s696_green_fullreg.rds` / `s696_spike_fullreg.rds`, plus 65 PNGs, neither compressible).
- **Evidence:** the owner's 19.7 MB tarball lists 252 `nprcgenekeepr/scratchpad/` entries; the
  controlled reproduction (clean export + `scratchpad/`) builds to 19,714,510 B; removing it
  yields 3.49 MB. This is also the long-standing `checking top-level files ... NOTE —
  Non-standard file/directory found at top level: 'scratchpad'` (S721 onward;
  `../nprcgenekeepr.Rcheck/00check.log:37-39`).
- **Impact:** every RStudio Build / `devtools::build()` / `devtools::check()` from this working
  tree produces a 19.7 MB artifact and a check NOTE. CI and any fresh clone are unaffected
  (`scratchpad/` is untracked), which is why CI never flagged it.
- **Status:** the owner's **uncommitted** `.Rbuildignore` edit (`+^scratchpad$`) is exactly the
  fix — measured: working tree builds to 3,564,041 B with it. It is not yet committed, so the
  fix does not exist at `HEAD`.
- **Recommendation:** commit the `^scratchpad$` line. `scratchpad/` is also not git-ignored
  (it shows in every `git status`); adding `/scratchpad/` to `.gitignore` is the owner's call —
  it would silence the noise but also hide the directory from the Phase 0 untracked-file
  ghost-session check.

### Finding 2 — untracked testthat debris ships too (Minor)
- **Location:** `tests/testthat/_problems/` (28 KB) and `tests/testthat/testthat-problems.rds`
  (72 KB), both dated 2026-09-10, both untracked; `git check-ignore` matches neither, and no
  `.Rbuildignore` pattern matches either.
- **Evidence:** working-tree build − clean build = 78,856 B; the two paths compress to ~80 KB.
- **Impact:** small, but it is non-package content in a release artifact, and `_problems/` holds
  failure dumps from a past local test run.
- **Recommendation:** add both to `.Rbuildignore` **and** `.gitignore`
  (`^tests/testthat/_problems$`, `^tests/testthat/testthat-problems\.rds$`); delete the stale
  copies once confirmed uninteresting.

### Finding 3 — documentation is the one CRAN sub-limit with little headroom (Moderate)
- **Location:** `inst/doc/` = 4.38 MB uncompressed (86% of the 5 MB documentation guideline on
  its own; over it if `man/`'s 0.66 MB is counted). `a2interactive.html` alone is 2.77 MB.
- **Evidence / cause:** `vignettes/a2interactive.Rmd`, `gvaConvergence.Rmd`, and
  `simulatedKValues.Rmd` declare `output: html_document` (`df_print: paged`), which embeds the
  full Bootstrap + jQuery + pagedtable framework in every file. `gvaConvergence.html` is 676 KB
  with **zero** embedded images — almost all framework. `a3manual.Rmd` uses
  `rmarkdown::html_vignette` and its HTML is 62 KB. `a2interactive.html` additionally embeds the
  `visNetwork` htmlwidget library (2 widgets) and 17 base64 images (0.54 MB). The individual
  weight of visNetwork vs. framework inside `a2interactive.html` was **not** separately measured
  — that belongs to the remedy slice.
- **Impact:** not a current violation of the 10 MB rule and CRAN accepted 2.0.0 in this shape,
  but this is where growth will first hit a CRAN guideline, and where a reviewer looks.
- **Recommendation (largest available saving, est. 0.4–0.9 MB compressed):** switch the three
  vignettes to `rmarkdown::html_vignette` (estimated ~0.2 MB compressed saved per file from
  framework removal — *an estimate from the `a3manual` comparison, not a measurement*); for
  `a2interactive`, consider static images in place of the two live `visNetwork` widgets, or move
  it to a web-only pkgdown article (the existing `vignettes/articles/` pattern). `df_print:
  paged` is not available under `html_vignette`; tables would need `knitr::kable()`.

### Finding 4 — installed size is 8.9–10.2 MB (Minor, informational)
- **Evidence:** local `../nprcgenekeepr.Rcheck/00check.log:28-32` ("installed size is 8.9Mb;
  doc 4.3Mb, extdata 2.5Mb"); CI run 35481710058: 9.5 MB (Windows) – 10.2 MB (macOS), with `R`
  1.5 MB also listed. Reported as `INFO` on current R, so it does not count toward check status.
- **Recommendation:** none required. Finding 3's remedy would cut `doc` roughly in half.

### Finding 5 — no mechanical guard on artifact size or contents (Minor, structural)
- **Evidence:** `.Rbuildignore` is a denylist, so any new untracked top-level directory ships by
  default; local builds have been leaking `scratchpad/` since it appeared (~2026-08-17, about
  a month), the resulting check NOTE was carried as "known clutter" from S721 on, and the size
  was caught only when the owner happened to look at the file. `.quality-gates.json`
  declares 0 gates.
- **Recommendation:** per `AUDIT_WORKSTREAM.md` anti-pattern 10 (a mechanical invariant is a
  gate, not prose), declare one gate: clean-export tarball size ≤ a ceiling (suggest 5 MB — 43%
  above today, half of CRAN's line). Cheap form: a CI step after `R CMD build` that fails on
  size; the local form is a `.quality-gates.json` entry. Owner decision — not applied here.

---

## 4. Structural Observations

1. **On-disk size was the wrong instrument twice over.** The S726 item already warned that
   `.Rbuildignore` excludes the biggest *tracked* trees (`docs/`, `vignettes/articles/`); the
   mirror-image error is that it does *not* exclude *untracked* ones. Only building the artifact
   and listing it (`tar tzvf`) answers "what ships."
2. **Working-tree builds and clean builds are different artifacts in this repo.** CI builds from
   a clone, so CI green says nothing about what a local RStudio Build produces. A CRAN
   submission tarball should be built from a clean export (§7) or downloaded from CI — never from
   the working tree.
3. **Compressed, not uncompressed, is the currency.** CSV/text examples and `.R` tests compress
   ~4–10:1; HTML with base64 assets ~3:1; PDFs, XLSX, PNG, and `.rds` not at all. Remedies aimed
   at text data (the BACKLOG item's "shrink examples/test data" steer) would recover little:
   *all* of `inst/extdata/examples/` is 0.46 MB and *all* of `tests/` is 0.66 MB compressed.
4. **Well-designed and worth keeping:** the existing `.Rbuildignore` correctly excludes ~43.5 MB
   of tracked material (51.10 MB tracked, 7.56 MB of it passes the ignore patterns — `docs/`,
   `vignettes/articles/`, reference PDFs/HTMLs are the bulk of what is held back); `data/` is already
   tight (0.16 MB, 26 files).

## 5. Bearing on the two cross-referenced BACKLOG items

- **Package-split investigation** (S667 recommendation "do not split now", owner disposition
  pending): **size is no longer an argument for splitting.** The pedigree-drawing R sources
  named in that scoping doc (`R/makePedigreeDiagramData.R`, `R/comparePedigreeStructure.R`,
  `R/modPedigree*.R`) total 205 KB uncompressed; the entire `R/` directory is 0.39 MB
  compressed. A split would move well under 0.3 MB.
- **Pedigree-growth measurement** (READY, S): this audit bounds it — total growth since CRAN
  2.0.0 is **+1.07 MB compressed (+44%)** across *all* features, so the drawing feature's share
  is some fraction of that. The per-feature attribution remains that item's job; not done here.

## 6. Comparison with Prior Audits

No prior tarball-size audit exists. Baseline established this session:

| Metric | CRAN 2.0.0 (2026-07-26) | `f8ffa40b` clean (2026-09-19) |
|---|---|---|
| Source tarball | 2,419,329 B | 3,485,185 B |
| Entries | not measured | 997 |
| Uncompressed payload | not measured | 12.01 MB |
| Installed size | not measured | 8.9 MB (local), 9.5–10.2 MB (CI) |

## 7. Recommendations (ranked) and reproduction

1. **Commit the pending `^scratchpad$` `.Rbuildignore` line** (Finding 1) — closes the entire
   19.7 → 3.5 MB gap and clears the top-level-files check NOTE. Effort: trivial.
2. **Ignore the testthat debris in `.Rbuildignore` + `.gitignore`** (Finding 2). Effort: trivial.
3. **Build release tarballs from a clean export, never the working tree** (Observation 2).
4. **Optional — declare a tarball-size gate** (Finding 5). Effort S; owner decision.
5. **Optional — slim `inst/doc/` by moving three vignettes to `html_vignette`** (Finding 3).
   Effort M; the only remedy with material size effect; buys documentation-guideline headroom
   rather than tarball-limit compliance, which is already met.
6. **Not recommended on size grounds:** shrinking example/test data, recompressing `data/`
   (0.14 MB total), or the package split (§5).

```sh
# Clean build — the authoritative number (run from the repo root so renv activates)
X=$(mktemp -d); mkdir "$X/src" "$X/out"; git archive HEAD | tar -x -C "$X/src"
Rscript -e "pkgbuild::build('$X/src', dest_path = '$X/out')"
ls -l "$X"/out/*.tar.gz
# Inventory: bytes by top-level directory, then largest files
tar tzvf "$X"/out/*.tar.gz | awk '{n=$NF; sub(/^nprcgenekeepr\//,"",n); split(n,a,"/");
  s[index(n,"/")?a[1]:"(root)"]+=$5} END{for(k in s) printf "%-10s %8.3f MB\n",k,s[k]/1e6}' | sort -k2 -rn
tar tzvf "$X"/out/*.tar.gz | awk '{print $5, $NF}' | sort -rn | head -30
# Leak check: anything shipping from the working tree that a clean build would not?
git ls-files --others --exclude-standard   # then test each path against .Rbuildignore
```

**Limits of this audit:** compressed per-directory shares are ±4% (independent `gzip -9`
streams vs. one tar stream). The `html_vignette` saving in Finding 3 is an estimate. The
composition of `a2interactive.html` was identified (framework, visNetwork, pagedtable, 17
images) but not weighed per component. Win-builder / CRAN incoming checks were not run.
