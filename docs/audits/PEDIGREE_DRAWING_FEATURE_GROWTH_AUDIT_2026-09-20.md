# Pedigree-Drawing Feature Growth Audit

**Date:** 2026-09-20 (Session 737)
**Trigger:** `BACKLOG.md` item "Measure how much this R package has grown due to the
pedigree-drawing feature — a rough estimate (±20%) is sufficient" (owner-requested mid-S721,
2026-09-19, READY, Effort S). Owner explicitly accepts ±20%; shared-infrastructure attribution
does not need to be precise.
**Workstream:** `docs/methodology/workstreams/AUDIT_WORKSTREAM.md`.
**Scope:** Measurement only. No `R/`/`tests/` change (TDD phases N/A). Every number measured
this session at HEAD `0528da0e` (the S737 claim commit; package content is identical to the
CI-verified `2628cd02` — every commit between is `.Rbuildignore`d process documentation).
Reproduction commands in §5.

---

## 1. Audit Summary — the headline answer

**The pedigree-drawing feature accounts for roughly one quarter to (at most) one third of the
package's source growth since it began, and roughly half of the built-tarball growth since the
CRAN 2.0.0 release.** Three consistent views:

| View | Pre-feature baseline | Current | Growth | Feature share of growth | Feature share of current total |
|---|---|---|---|---|---|
| **Shipped source, tracked bytes** (R/, tests/, man/, vignettes/, inst/, data/, root files, `.Rbuildignore` applied) | 4,323,677 B (`fc358df4`, 2026-07-29) | 7,551,980 B | +3,228,303 B (+74.7%) | **821,174–983,984 B = 25.4–30.5%** | 10.9–13.0% |
| **Lines, R/ + tests/testthat** | 55,041 (19,206 R + 35,835 test) | 91,276 (30,742 R + 60,534 test) | +36,235 (+65.8%) | **15,582 lines = 43.0%** (4,330 R + 11,252 test) | 17.1% |
| **Built tarball, compressed** (clean `git archive` export, per S727 recipe) | 2,419,329 B (CRAN 2.0.0, 2026-07-26) | 3,483,939 B | +1,064,610 B (+44.0%) | **≈ 0.55–0.65 MB ≈ 51–61%** | ≈ 16–19% |

Equivalently: the package's shipped source is **~19–23% larger** than it would be without the
feature (821,174–983,984 B over the 4,323,677 B baseline), and the built tarball would be
**≈ 2.84–2.94 MB instead of 3.48 MB**. All figures are inside the owner's ±20% tolerance band —
the widest bracket (byte share 25.4% vs 30.5%) spans 18% relative.

Why the line share (43%) is so much higher than the byte share (25–30%): the other big
post-baseline feature family — marker genetics (issue #130) — ships a single 1,247,940 B example
CSV (`inst/extdata/examples/example_sequence_genotypes.csv`) that alone outweighs the drawing
feature's **entire** tracked source (821,174 B). By code volume the drawing feature is the
largest single growth driver; by bytes it is second to marker-genetics data.

**Repo-level (NOT shipped in the package):** the feature also added ~3.8 MB of tracked
repository material excluded by `.Rbuildignore` — 1,423,301 B of pkgdown articles, images, and
generator scripts (`vignettes/articles/pedigree-diagram*`, `kinship2-fidelity-validation*`,
`shiny_app_use/diagram_*.png`, 4 `data-raw/` generators) and 2,364,048 B across 49
feature-related files under `docs/` (plans, audits, research, spike evidence). This is repo
growth, not package growth, and is excluded from every figure above.

- **Criteria:** attribute B→HEAD growth per file to the drawing feature (wholly-owned /
  partial / ambiguous buckets, §2), on three surfaces: tracked shipped source bytes, R+test
  lines, and the built tarball compressed.
- **Coverage:** every tracked file in shipping paths at both commits (1,004 baseline / 1,336
  HEAD tree entries) enters the bucket arithmetic; every classified file listed in §2.
- **Finding count:** 0 critical · 0 moderate · 4 observations (§4).

---

## 2. Method

### Baseline

`fc358df4` (2026-07-29, "docs: S432 — ratified issue #129 plan") — the last commit before the
feature's first code commit `39eb441e` (2026-07-30) created `R/makePedigreeDiagramData.R`. For
the compressed view the baseline is the published CRAN 2.0.0 tarball (2026-07-26, 3 days
earlier; the intervening commits are release housekeeping) — the same baseline the S727 tarball
audit used.

### Shipping filter

Package-content paths (`R/`, `tests/`, `man/`, `vignettes/`, `inst/`, `data/`, DESCRIPTION,
NAMESPACE, LICENSE, README.md, NEWS.md) minus `.Rbuildignore` exclusions that fall inside them
(`vignettes/articles/`, `data-raw/`, `tests/testthat/_snaps/`, the excluded reference PDFs/HTML,
deprecated R files, non-shipping Rmds). Sizes from `git ls-tree -r -l` at each commit — tracked
blob bytes, not on-disk.

### Buckets

**Wholly-owned (821,174 B at HEAD, all created by the feature):**

| Group | Files | HEAD bytes |
|---|---|---|
| R/ layout core + fidelity apparatus | `makePedigreeDiagramData.R` (3,070 lines), `positionTreeApportion.R` (277), `orderRootSubtrees.R` (213), `comparePedigreeStructure.R` (378), `shrinkPedigree.R` (392 — created 2026-08-14 "Track B" `f68a24ff`) | 202,711 |
| tests (16 files) | `test_positionMatingUnitForest.R`, `test_makePedigreeMatingLayout.R`, `test_addRectilinearWaypoints.R`, `test_resolveEdgeNodeCollisions.R`, `test_makePedigreeDiagramData.R`, `test_buildMatingUnitForest.R`, `test_positionTreeApportion.R`, `test_orderRootSubtrees.R`, `test_findIsolatedIds.R`, `test_comparePedigreeStructure.R`, `test_shrinkPedigree.R`, `test_examplePedigreeFixtures.R` (S693 pins the 5 exemplars, `c5435906`), `helper-comparePedigreeStructure.R`, `helper-live-render-positions.R` + its teardown/timeout tests | 544,829 |
| man/ + example data | `makePedigreeDiagramData.Rd`, `makePedigreeMatingLayout.Rd`, `shrinkPedigree.Rd`; the 5 exemplar pedigree CSVs (`example_pedigree_{backcross,consanguinity,first_cousin,half_sib,linebreeding}.csv`) + `obfuscated_rhesus_mhc_ped_{affected,name,twins}.csv` (consumed by `test_resolveEdgeNodeCollisions.R`, `test_makePedigreeMatingLayout.R`, e2e pedigree tests, and the diagram screenshot generator — verified by grep) | 73,634 |

**Partially-feature (pre-existing files that grew; delta counted as an upper bound —
+119,748 B):** `R/modPedigree.R` (the Diagram tab lives here), `test_modPedigree.R`,
`test_modPedigree_coverage.R`, `test_modPedigree_processing.R`, the 3 `test-e2e-pedigree-*.R`
(all predate the feature, 2026-04-02) — B→HEAD delta +105,113 B; plus the
`vignettes/a2interactive.Rmd` "Pedigree Diagram" tutorial section, measured directly (lines
347–657 at HEAD): +14,635 B. Some of this delta is non-diagram module work, so it
over-attributes — which is why it brackets the high side.

**Twin-relations infrastructure (ambiguous — +43,062 B):** `readTwinRelations.R`,
`checkTwinRelations.R`, `obfuscateTwinRelations.R`, their Rd/tests, the 4 cross-tab
`*_twinRelations.R` module tests, `test-e2e-twin-relations-cross-tab.R`,
`obfuscated_rhesus_mhc_twin_relations.csv` (all created 2026-08-09+). Twin data feeds the
diagram's twin-connector edges (`.buildTwinConnectorEdges()`) *and* kinship handling across
four other tabs — a cross-cutting capability the diagram campaign prompted. Counted only in the
high bracket.

**Everything else** is non-feature: the marker-genetics family (issue #130: `marker*`, `mhc*`,
`obfuscate*` [non-twin], cross-center #149, mate-pair #151, de-identified export #150,
genomic ROH), breeding groups #146 (`enumerateMaximalIndependentSets.R`), the shinyBS #140 fix
(`zzz.R`, `inst/www/js/`), CI/process test files, NEWS.md, guidance HTML, etc. Largest
non-feature growth items are listed in §3 for context.

### Compressed attribution (two methods, cross-checking)

The tarball built this session from a clean `git archive HEAD` export is **3,483,939 B**
(matches the S728 quality gate's 3,483,944 B at `2628cd02` to within gzip-header noise, and
S727's 3,485,185 B at `f8ffa40b` before two small interim content changes). Uncompressed
content: 12,009,207 B across 997 entries.

Inside it, the feature's members are the wholly-owned tracked files above **plus** the
feature's share of the built vignette `inst/doc/a2interactive.html` (2,765,257 B — the largest
single member): the vis-network JavaScript bundle (3 script blocks, 1,069,799 B), html2canvas
(a visNetwork export dependency, 124,573 B), and the two live diagram widget payloads
(33,421 B) — attributable because the document's only htmlwidgets are the Pedigree Diagram
section's two (S667 scoping doc; the remaining large script block is d3-based, belongs to
another section's widget, and is excluded — conservative). Plus the diagram section of
`a2interactive.Rmd`, which ships twice (`vignettes/` + `inst/doc/` copies, 2 × 14,635 B).

- **Method A — independent `gzip -9` of the feature members** (the S727 audit's method, ±4%
  for stream-splitting): wholly-owned files 245,095 B + HTML components 291,271 B + Rmd section
  copies ≈ 9,000 B = **≈ 545,000 B strict**; + partial-delta estimate ≈ 26,000 B + twin
  17,179 B = **≈ 589,000 B high**.
- **Method B — proportional share of the actual tarball** (feature uncompressed bytes ÷ total
  uncompressed × 3,483,939): strict 2,080,333 B/12,009,207 B → **≈ 603,000 B**; high
  2,228,508 B → **≈ 646,000 B**.

The methods agree within 10%; the reported range **0.55–0.65 MB** spans both. Against the CRAN
2.0.0 baseline (+1,064,610 B total): **51–61% of the compressed growth**.

---

## 3. Measurements

### Shipped source bytes (tracked, shipping filter applied)

| Bucket | Baseline | HEAD | Delta |
|---|---:|---:|---:|
| TOTAL shipped source | 4,323,677 | 7,551,980 | +3,228,303 |
| Drawing feature, wholly-owned | 0 | 821,174 | +821,174 |
| — of which R/ core | 0 | 202,711 | +202,711 |
| — of which tests | 0 | 544,829 | +544,829 |
| — of which man/ + example data | 0 | 73,634 | +73,634 |
| Partial files (delta = upper bound) + a2interactive diagram section | 77,832 | 197,580 | +119,748 |
| Twin-relations infrastructure (ambiguous) | 0 | 43,062 | +43,062 |

Feature share of growth: **strict 25.4%** (821,174) · **+partials 29.1%** (940,922) ·
**+twin 30.5%** (983,984).

### Lines (R/ + tests/testthat, HEAD vs baseline)

| Scope | Baseline | HEAD | Growth | Feature lines | Feature share of growth |
|---|---:|---:|---:|---:|---:|
| `R/*.R` | 19,206 | 30,742 | +11,536 | 4,330 | 37.5% |
| `tests/testthat/*.R` | 35,835 | 60,534 | +24,699 | 11,252 | 45.6% |
| Combined | 55,041 | 91,276 | +36,235 | 15,582 | **43.0%** |

At HEAD the feature owns 14.1% of all R/ lines and 18.6% of all test lines. Test-to-source
ratio inside the feature: **2.6 : 1** by lines (11,252 : 4,330), 2.7 : 1 by bytes.

### Largest non-feature growth items (context)

| Delta (B) | File | Family |
|---:|---|---|
| +1,247,940 | `inst/extdata/examples/example_sequence_genotypes.csv` | marker genetics |
| +76,153 | `tests/testthat/test_modMarkerGenetics.R` | marker genetics |
| +56,510 | `R/modMarkerGenetics.R` | marker genetics |
| +38,118 | `vignettes/a2interactive.Rmd` (of which +14,635 is the diagram section, counted above) | mixed |
| +32,797 | `tests/testthat/test_markerParentageLikelihood.R` | marker genetics |

Non-feature growth total: 2,258,954 B — of which the marker-genetics family (code + tests +
example data) is by far the largest component.

---

## 4. Observations

1. **Line-heavy, byte-light.** The feature is the largest single *code* growth driver (43% of
   R+test line growth) but only ~25–30% of byte growth, because marker genetics ships a
   1.25 MB example CSV that alone outweighs the feature's entire tracked source. Any future
   "why is the package big" question should look at example data before code.
2. **The feature's largest shipped weight is a dependency payload, not its own code.** Inside
   the tarball, ~0.29 MB compressed (~1.23 MB uncompressed) is the vis-network + html2canvas
   JavaScript embedded in `inst/doc/a2interactive.html` by the section's two live widgets —
   more than the compressed weight of all the feature's R code, tests, and data combined
   (~0.25 MB). This connects directly to the open `inst/doc/` slimming item (`BACKLOG.md`,
   DECISION NEEDED): its optional step "replace `a2interactive`'s two live `visNetwork` widgets
   with static images" would remove most of the feature's tarball footprint on its own.
3. **The campaign's test discipline shows in the ratio.** 2.6 lines of test per line of layout
   source (vs ~2.0 package-wide at HEAD: 60,534 : 30,742) — consistent with the strict-TDD
   campaign the feature was built under.
4. **Attribution honesty.** The strict/high bracket (25.4–30.5% of source growth) is driven by
   two judgment calls documented in §2: the partial-file deltas (over-attribute: not every
   `modPedigree.R` change since 2026-07-29 is diagram work) and the twin infrastructure
   (under-attribute if considered diagram-motivated, over- if considered its own capability).
   The bracket width (~18% relative) sits inside the owner's ±20% tolerance.

## 5. Coverage and reproduction

**Coverage:** 100% of tracked files in shipping paths at both commits entered the arithmetic;
all 55 classified feature/twin/partial entries (32 wholly-owned + 15 twin + 7 partial files +
the measured `a2interactive.Rmd` section) are enumerated in §2; unclassified files are
non-feature by construction and their total is reconciled in §3 (821,174 + 119,748 + 43,062 +
2,258,954 − 14,635 double-count adjustment = 3,228,303 ✓). Not measured: the feature's share of
the 17 embedded static images in `a2interactive.html` (unknown section ownership, ≤ 538 KB
uncompressed total across all sections — bounded, noted, excluded from the feature estimate),
and per-file `git log` churn (the S667 scoping doc §2.6 already covers churn).

```sh
# Trees at both commits (bytes per tracked file)
git ls-tree -r -l fc358df4   # baseline: last commit before 39eb441e (2026-07-30)
git ls-tree -r -l HEAD
# Clean tarball (S727 §7 recipe)
X=$(mktemp -d); mkdir "$X/src" "$X/out"; git archive HEAD | tar -x -C "$X/src"
Rscript -e "pkgbuild::build('$X/src', dest_path = '$X/out')"; ls -l "$X"/out/*.tar.gz
# Feature share of the built vignette: script-block sizes in inst/doc/a2interactive.html
tar xzf "$X"/out/*.tar.gz -C "$X" nprcgenekeepr/inst/doc/a2interactive.html
# then measure <script> block spans (vis-network x3, html2canvas, 2 widget payloads)
# Lines
wc -l R/makePedigreeDiagramData.R R/positionTreeApportion.R R/orderRootSubtrees.R \
      R/comparePedigreeStructure.R R/shrinkPedigree.R; cat R/*.R | wc -l
```

**Limits:** ±4% on independent-gzip shares (S727's caveat applies unchanged); the partial-file
bucket is an upper bound by construction; CRAN 2.0.0 predates the code baseline by 3 days; the
`a2interactive.Rmd` diagram-section boundary (lines 347–657) was taken from the section heading
map at HEAD.
