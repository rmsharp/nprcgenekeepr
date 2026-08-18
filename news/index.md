# Changelog

## nprcgenekeepr 2.0.0.9000 (development version)

- CRAN accepted the 2.0.0 submission (tagged `v2.0.0`); published
  2026-07-26. Development continues here on top of it.
- New
  [`checkLocusMetadata()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md)
  (issue [\#153](https://github.com/rmsharp/nprcgenekeepr/issues/153),
  Slice 1) validates a locus-metadata sidecar table
  (`locus, chrom, pos[, cM]`) and reports each locus’s coverage as
  `"full"`, `"partial"`, or `"none"`, PLINK-style. New example fixtures
  `example_locus_metadata.csv`/`example_str_marker_genotypes.csv`. No
  Shiny UI yet.
- New
  [`checkLinkageMarkerGenotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLinkageMarkerGenotypeFile.md)
  (issue [\#153](https://github.com/rmsharp/nprcgenekeepr/issues/153),
  Slice 2), a sibling to
  [`checkMarkerGenotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md)
  that accepts multiallelic marker panels (e.g. STR/microsatellite). No
  Shiny UI yet.
- New
  [`markerRealizedRelatednessVariance()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerRealizedRelatednessVariance.md)
  (issue [\#153](https://github.com/rmsharp/nprcgenekeepr/issues/153),
  Slice 3) estimates the variance of realized (marker-based) relatedness
  around a pair’s pedigree-expected value. No Shiny UI yet.
- New
  [`markerLdBlock()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerLdBlock.md)
  and
  [`obfuscateLdBlocks()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateLdBlocks.md)
  (issue [\#153](https://github.com/rmsharp/nprcgenekeepr/issues/153),
  Slice 4) add a descriptive same-chromosome pairwise LD/block
  statistic. No Shiny UI yet.
- Genetic Value Analysis tab gained a configurable **Ranking Scheme**
  control (issue
  [\#125](https://github.com/rmsharp/nprcgenekeepr/issues/125)): a new
  priority-tier scheme alongside the existing combined
  kinship/uniqueness score.
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  gained matching `guCutoff`/ `zScoreCutoff`/`axisPriority` arguments.
- Breeding Group Formation tab now surfaces up to 5 candidate groupings
  per run (issue
  [\#125](https://github.com/rmsharp/nprcgenekeepr/issues/125)), with a
  selector and comparison table.
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  gains a `candidates` list field in its return value.
- Breeding Group Formation tab gained an **Include animals by** control
  (issue [\#128](https://github.com/rmsharp/nprcgenekeepr/issues/128)):
  a Genetic-value-floor option alongside the existing top-N cutoff.
- Genetic Value Analysis Summary Statistics table gained **Skewness**
  and **Kurtosis** columns (issue
  [\#126](https://github.com/rmsharp/nprcgenekeepr/issues/126)) via new
  exported
  [`calcSkewness()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcSkewness.md)/
  [`calcKurtosis()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcKurtosis.md);
  [`makeGeneticSummaryTable()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGeneticSummaryTable.md)
  gained matching columns.
- Genetic Value Analysis rankings table gained a **flagged** column
  (issue [\#127](https://github.com/rmsharp/nprcgenekeepr/issues/127))
  marking animals whose mean-kinship correction could not be applied for
  lack of an eligible peer cohort.
- Pedigree Browser tab gained a **Diagram** view (issue
  [\#129](https://github.com/rmsharp/nprcgenekeepr/issues/129)): an
  interactive pedigree diagram via `visNetwork`, with click-to-recenter
  on a focal animal. Diagrams above 750 animals show an informative
  message instead of rendering.
- Diagram tab layout rebuilt for a kinship2-style, mating-aware
  convention (Pedigree Diagram Option 2): mate-line connectors and
  duplicate nodes for multiply-mated individuals; display limit dropped
  from 1,500 to 750. New exported
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md);
  [`makePedigreeDiagramData()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeDiagramData.md)
  unchanged.
- New **Marker Genetics** tab with a **Kinship Comparison** sub-tab
  (issue [\#130](https://github.com/rmsharp/nprcgenekeepr/issues/130),
  Slice 1): a KING-robust marker-based kinship estimate alongside
  pedigree-based kinship. New exported
  [`checkMarkerGenotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md),
  [`buildMarkerGenotypeMatrix()`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md),
  [`markerKinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md).
- Marker Genetics tab gained a **Heterozygosity** sub-tab (issue
  [\#130](https://github.com/rmsharp/nprcgenekeepr/issues/130), Slice
  2): per-animal observed vs. population expected heterozygosity. New
  exported
  [`markerObservedHeterozygosity()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerObservedHeterozygosity.md)/[`markerExpectedHeterozygosity()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerExpectedHeterozygosity.md).
- Marker Genetics tab gained a **Parentage Exclusion** sub-tab (issue
  [\#130](https://github.com/rmsharp/nprcgenekeepr/issues/130), Slice
  3): flags a pedigree-recorded parent contradicted by 3+
  opposite-homozygote loci. New exported
  [`markerParentageExclusion()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageExclusion.md).
- New exported `resolveCrossCenterIds(pedA, pedB, mapping)` (issue
  [\#130](https://github.com/rmsharp/nprcgenekeepr/issues/130), Slice 4)
  merges pedigrees from two centers via a curator-confirmed
  identity-link table. Script-callable only.
- Marker Genetics tab gained a **Cross-Center** sub-tab (issue
  [\#130](https://github.com/rmsharp/nprcgenekeepr/issues/130), Slice
  5): Hudson’s Fst between the populations of two centers. New exported
  [`markerFst()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerFst.md).
- Diagram tab gained an in-app **shape-to-sex legend** (issue
  [\#132](https://github.com/rmsharp/nprcgenekeepr/issues/132)).
- Diagram tab gained **hover tooltips and a search/highlight dropdown**
  (issue [\#135](https://github.com/rmsharp/nprcgenekeepr/issues/135)).
  Node data from
  [`makePedigreeDiagramData()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeDiagramData.md)
  gains a `title` field.
- Diagram tab gained a **Diagram Edge Style** toggle (issue
  [\#142](https://github.com/rmsharp/nprcgenekeepr/issues/142)): a
  “Rectilinear (kinship2-style)” option alongside the default “Direct”
  style.
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
  gained a matching `edgeStyle` argument.
- Diagram tab can now shade **affected-status** individuals (issue
  [\#133](https://github.com/rmsharp/nprcgenekeepr/issues/133)) via an
  optional `affected` column, matching a kinship2 naming convention.
- Diagram tab can now show **animal names** alongside id (issue
  [\#136](https://github.com/rmsharp/nprcgenekeepr/issues/136)) via an
  optional `name` column and a **Show Names on Diagram** toggle.
  [`getPossibleCols()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPossibleCols.md)
  gained `name` alongside the existing `affected`;
  [`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)
  scrubs `name` for de-identified exports.
- Diagram tab can now show **twin/zygosity connectors** (issue
  [\#137](https://github.com/rmsharp/nprcgenekeepr/issues/137)),
  adopting the kinship2 MZ/DZ/UZ twin-code convention. New exported
  [`checkTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md)/[`obfuscateTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateTwinRelations.md).
- New exported
  [`markerParentageLikelihood()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageLikelihood.md)
  (issue [\#147](https://github.com/rmsharp/nprcgenekeepr/issues/147))
  ranks candidate replacement parents for a Mendelian-inconsistent
  recorded parent using a CERVUS-style multilocus likelihood-ratio (LOD)
  score. Report-only. Marker Genetics tab gained a matching **Candidate
  Parent Assignment** sub-tab.
- Fixed (issue
  [\#155](https://github.com/rmsharp/nprcgenekeepr/issues/155)): the
  Candidate Parent Assignment sub-tab’s auto-detect default missed the
  common case of a flagged animal whose recorded parent is present but
  wrong.
- Diagram tab now defaults to placing the male parent on the left in a
  two-parent mating pair (issue
  [\#145](https://github.com/rmsharp/nprcgenekeepr/issues/145)).
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
  gained a matching `orderBySex` argument (default `TRUE`).
- New exported `checkCrossCenterMapping(pedA, pedB, mapping)` (issue
  [\#149](https://github.com/rmsharp/nprcgenekeepr/issues/149), Slice 1)
  reports every cross-center mapping problem at once instead of stopping
  at the first. Also fixes a data-loss defect in
  [`resolveCrossCenterIds()`](https://github.com/rmsharp/nprcgenekeepr/reference/resolveCrossCenterIds.md)
  (non-id/sire/dam columns were silently dropped on merge).
- New **Cross-Center Identity** tab (issue
  [\#149](https://github.com/rmsharp/nprcgenekeepr/issues/149), Slice
  2): a curator workflow around
  [`resolveCrossCenterIds()`](https://github.com/rmsharp/nprcgenekeepr/reference/resolveCrossCenterIds.md)/[`checkCrossCenterMapping()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkCrossCenterMapping.md),
  with a merge preview and 5 downloadable artifacts behind a
  confirmation dialog.
- [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  gained a `maxCandidates` argument (issue
  [\#146](https://github.com/rmsharp/nprcgenekeepr/issues/146), Slice
  1), replacing the hardcoded cap of 5. Breeding Group Formation tab
  gained a matching **Candidates to retain** control.
- [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  gained an `exhaustive` argument (issue
  [\#146](https://github.com/rmsharp/nprcgenekeepr/issues/146), Slice 2,
  closes [\#146](https://github.com/rmsharp/nprcgenekeepr/issues/146)):
  enumerates every possible single-group partition instead of sampling,
  for `numGp = 1`. Breeding Group Formation tab gained a matching
  **Exhaustive enumeration mode** checkbox.
- New exported
  [`reportMatePairs()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportMatePairs.md)
  (issue [\#151](https://github.com/rmsharp/nprcgenekeepr/issues/151),
  Slice 1) reports eligible individual mate-pair candidates with
  pedigree/marker kinship and genetic-value context. Report-only.
- New **Mate Pair Analysis** tab (issue
  [\#151](https://github.com/rmsharp/nprcgenekeepr/issues/151), Slice
  2), a curator view over
  [`reportMatePairs()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportMatePairs.md),
  kept separate from Breeding Group Formation.
- [`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)
  gained a **linkedDateShift** argument (issue
  [\#150](https://github.com/rmsharp/nprcgenekeepr/issues/150), Slice 1,
  default `TRUE`): shifts all of one individual’s Date columns by the
  same offset, preserving inter-date gaps (previously could invert date
  order).
- New **De-Identified Export** tab (issue
  [\#150](https://github.com/rmsharp/nprcgenekeepr/issues/150), Slice 2,
  closes [\#150](https://github.com/rmsharp/nprcgenekeepr/issues/150)):
  a curator workflow around
  [`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)
  with a live preview and 3 downloadable artifacts (de-identified
  pedigree, transformation manifest, re-identification key) behind a
  confirmation dialog.
- Marker Genetics tab gained a **Linkage and LD Block Metrics** sub-tab
  (issue [\#153](https://github.com/rmsharp/nprcgenekeepr/issues/153),
  Slice 5, closes
  [\#153](https://github.com/rmsharp/nprcgenekeepr/issues/153)):
  locus-metadata coverage report, realized-relatedness-variance table,
  and LD-block table, with de-identified export.
- New exported
  [`checkSequenceGenotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSequenceGenotypeFile.md)
  (issue [\#152](https://github.com/rmsharp/nprcgenekeepr/issues/152),
  Slice 1) validates a sequence-scale marker genotype file. New example
  fixtures
  `example_sequence_genotypes.csv`/`example_sequence_locus_metadata.csv`.
  No Shiny UI yet.
- [`markerKinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md)
  and
  [`markerParentageLikelihood()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageLikelihood.md)
  (issue [\#152](https://github.com/rmsharp/nprcgenekeepr/issues/152),
  Slice 2) rewritten internally for large marker panels (vectorized
  matrix algebra, precomputed allele frequencies); output unchanged.
- New exported
  [`computeGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/computeGenomicROH.md)
  (issue [\#152](https://github.com/rmsharp/nprcgenekeepr/issues/152),
  Slice 3) computes per-individual genomic Runs-of-Homozygosity segments
  and the F_ROH inbreeding coefficient from sequence-scale marker data.
  No Shiny UI yet.
- New exported
  [`obfuscateGenotypeMatrix()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenotypeMatrix.md)
  (issue [\#152](https://github.com/rmsharp/nprcgenekeepr/issues/152),
  Slice 4) de-identifies a sequence-scale genotype matrix’s individual
  ids. No Shiny UI yet.
- Marker Genetics gained a **Genomic ROH (F_ROH)** tab (issue
  [\#152](https://github.com/rmsharp/nprcgenekeepr/issues/152), Slice 5,
  closing the issue): computes F_ROH from the already-uploaded genotype/
  locus-metadata files, with de-identified export
  ([`obfuscateGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenomicROH.md)).
- [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  gained a **twinRelations** argument (BL-N, Slice 1) correcting a
  declared MZ-twin pair’s computed kinship to genetic identity and
  propagating that correction to every relative reached through either
  twin (not just the pair itself), porting kinship2’s own
  `mzgrp`/`mzindex` mechanism.
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md),
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md),
  [`createSimKinships()`](https://github.com/rmsharp/nprcgenekeepr/reference/createSimKinships.md),
  and
  [`cumulateSimKinships()`](https://github.com/rmsharp/nprcgenekeepr/reference/cumulateSimKinships.md)
  (BL-N, Slice 2) each gained a matching `twinRelations` argument,
  passed through to their own internal kinship computation. Shiny wiring
  (BL-N, Slice 3): a twin/zygosity sidecar uploaded on the Pedigree
  Browser’s Diagram tab now corrects kinship everywhere in the app –
  Summary Statistics, Breeding Groups, and Genetic Value Analysis –
  regardless of which tab is visited first.
- Fixed: the Pedigree Diagram tab’s affected-status shading rendered
  unaffected/unknown individuals filled instead of open/unfilled,
  counter to standard pedigree drawing convention (kinship2’s own
  “unfilled if 0/NA”).
- The Pedigree Diagram tab now renders a consanguineous mating’s 2
  connector lines thicker and in a distinct color (BL-N), matching
  kinship2’s own doubled/thickened mate-line convention for a
  blood-related couple. Detected directly from the pedigree’s own
  sire/dam data (no optional column or toggle needed);
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
  returned `edges` gains `color`/`width` columns accordingly. Scoped to
  `edgeStyle = "direct"` this release – `"rectilinear"` propagation onto
  a cross-generation dogleg reroute is a deferred follow-up.
- Fixed: a pedigree with a dangling (no-own-row) parent anywhere in it
  could cause the Pedigree Diagram tab’s `edgeStyle = "rectilinear"`
  style to spuriously reroute other, unrelated mate-line edges through
  an unneeded cross-generation “dogleg,” even when those edges’ own
  parents were already at the correct generation. Caused by an internal
  type-coercion defect (a dangling parent’s generation fallback silently
  widened an internal generation vector from integer to double, breaking
  a strict type-sensitive equality check elsewhere).
- The Pedigree Diagram tab’s consanguineous-mating marker (above) now
  also survives an `edgeStyle = "rectilinear"` cross-generation “dogleg”
  reroute – previously the marker’s color/width fell back to the generic
  waypoint-edge style on a doglegged mate edge, even though the
  `edgeStyle = "direct"` style always showed it correctly (BL-N, part of
  the kinship2 supplement full-reproduction plan’s Track C).
- [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  gained `chrtype = c("autosome", "x")` and `sex` arguments (BL-N, the
  kinship2 supplement full-reproduction plan’s Track A): `chrtype = "x"`
  computes X-chromosome kinship instead of the default autosomal
  calculation (a male’s X comes from his mother only; a female’s
  X-linked kinship follows the usual average-of-parents formula). The
  existing `twinRelations` MZ-twin correction applies inside the new
  branch too. `chrtype = "autosome"` (the default) is unaffected – every
  existing call site keeps its current behavior unchanged.
  Script-callable only; no Shiny UI yet.
- New
  [`shrinkPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/shrinkPedigree.md)
  (BL-N, the kinship2 supplement full-reproduction plan’s Track B), a
  `kinship2::pedigree.shrink()` equivalent: trims a pedigree down to the
  individuals needed to keep it genetically informative within a
  genotyping-cost budget (`maxBits`), given which individuals are
  genotyped and, optionally, which are affected by a trait of interest.
  Deterministic tie-break by lowest `id` (string-sorted) – kinship2’s
  own reference implementation breaks ties via
  [`runif()`](https://rdrr.io/r/stats/Uniform.html), so the same input
  can give a different answer run-to-run there. Script-callable only; no
  Shiny UI yet.
- Fixed: the Pedigree Diagram tab’s affected-status shading rendered
  every individual filled with visNetwork’s own default color when a
  pedigree had no `affected` column at all – unlike the already-fixed
  case where the column is present but a value is `FALSE`/`NA` (above).
  Every individual now defaults to an explicit open/unfilled (white)
  fill regardless of whether the `affected` column exists, matching
  kinship2’s own convention for pedigrees with no phenotype data (the
  package’s own bundled `examplePedigree` among them).
- Fixed: the Pedigree Diagram tab could space adjacent mates/siblings
  unevenly – the layout algorithm only guaranteed nodes did not exactly
  overlap, not a fixed minimum gap, so two unrelated same-generation
  nodes positioned deep in different branches of the family tree could
  land visibly closer together than a directly-adjacent pair. Every pair
  of same-generation individuals now keeps at least the algorithm’s own
  minimum-separation unit apart, matching kinship2’s own near-uniform
  mate spacing.
- Fixed: the Pedigree Diagram tab could render a mating unit’s anchor
  parent at a generation row that didn’t match the union’s own
  generation, whenever the two parents’ own generations differed – a
  common pattern (62% of mating units in the bundled example pedigree).
  Previously compensated by relocating the anchor’s own displayed row
  after the fact; now resolved at the source instead: whichever parent
  has the deeper generation always becomes the anchor, so the mismatch
  can no longer occur (a structural guarantee, not a case-by-case
  correction). A measured visual consequence: individuals who anchor
  multiple matings at different generations now more often appear as a
  duplicate node at one of their own mating units, rather than being
  pulled to a single relocated row (22 individuals in the bundled
  example pedigree, up from 2; the corresponding duplicate-node count
  drops from 128 to 102).
- Changed: the Pedigree Diagram tab’s default **Diagram Edge Style** is
  now **Rectilinear (kinship2-style)**, not Direct – the toggle (issue
  [\#142](https://github.com/rmsharp/nprcgenekeepr/issues/142)) and the
  option itself are unchanged, only which one applies with no user
  interaction.
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
  own `edgeStyle` argument default flips to match. The node cap that
  applies with no style chosen is therefore now 400 animals (previously
  750); switching to Direct raises it back to 750.
- Fixed: row order in the Genetic Value Analysis imports/no-parentage
  tiers, the pedigree table produced by
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md),
  and the Breeding Group Formation tab’s group-member table could vary
  depending on the server/session’s own locale (`LC_COLLATE`) – an id
  set sorted one way under one locale and a different way under another,
  purely from character-collation differences, not any change in the
  underlying data. All three now sort ids in a fixed, locale-independent
  byte order.
- Fixed: in the Pedigree Diagram tab’s Rectilinear edge style, a sibship
  bar could visually pass through an unrelated node’s own row – most
  visibly, a sibling who separately anchors her own mating union at the
  same generation (issue
  [\#160](https://github.com/rmsharp/nprcgenekeepr/issues/160)).
  `.addRectilinearWaypoints()`’s D1 sibship-bar/drop waypoints now land
  on a genuine intermediate row (40% of the way from the parent/union
  row to the children’s row) rather than the children’s own row, an
  unconditional geometric guarantee for the common 1-generation-gap
  case. Two disclosed residuals remain, both tracked for a future
  general same-row collision-avoidance pass: a rare bar-vs-node
  coincidence for a union placed an exact multiple of 5 generations from
  its child, and a reduced-but-not-eliminated bar-vs-bar case (2
  unrelated sibships at the same generation gap with overlapping
  horizontal spans; see below for the current count in the bundled
  example pedigree, which the parent-span containment fix below further
  affects).
- Fixed: in the Pedigree Diagram tab’s Rectilinear edge style, a
  straight same-row edge – a kept parent-to-union mate line, or a
  duplicate individual’s own dashed connector – could visually pass
  through an unrelated node, most severely on wide, many-founder colony
  pedigrees where a founder’s own mating union can land far from the
  founder (issue
  [\#160](https://github.com/rmsharp/nprcgenekeepr/issues/160)).
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
  now detects any such collision and inserts a small local reroute clear
  of the obstacle, never moving an existing node; this closes every
  straight-edge collision found on the bundled 375-individual example
  pedigree (105, down from an original 150 – the parent-span containment
  fix below resolves some of these before this detector even runs). The
  curved duplicate-connector arc gets a smaller, disclosed nudge instead
  (increasing its curvature) since rerouting it through right-angle
  waypoints would destroy its own established arc styling – confirmed
  visually, not just by coordinate math; 47 curved-connector cases
  remain disclosed, unconfirmed-by-coordinate-math residuals.
- Fixed: in the Pedigree Diagram tab, a mating union could be positioned
  entirely outside its own two parents’ x-range – most visibly a union
  with a single child, which has no midpoint of its own to center on and
  simply inherited that child’s x, however far the child’s own later
  descendants had pulled it (BACKLOG.md’s S583 item, part of the same
  root cause as issue
  [\#160](https://github.com/rmsharp/nprcgenekeepr/issues/160)). The
  union’s x is now clamped into its own 2 parents’ `[min, max]` range
  whenever the ordinary child-centered formula would place it outside
  that span, matching kinship2’s convention of always centering the
  union between its two parents. This is a disclosed trade-off, not a
  free improvement: clamping a union necessarily moves it further from
  its own children’s true midpoint for the unions it affects (measured
  on the bundled example pedigree: 9 of 251 child edges exceeded a
  200-unit centering threshold before this fix, 53 after), and it also
  increases how often two unrelated sibships’ own bars visually overlap
  in x-range at the same generation gap (a pre-existing,
  already-disclosed residual; 9 cases before this fix, 116 after, on the
  bundled example pedigree). Both are accepted, disclosed costs of
  fixing the more severe parent-span defect.
- Changed: in the Pedigree Diagram tab, the parent-span containment fix
  above’s own disclosed child-centering trade-off is now partially
  recovered, in code, for one specific, narrow shape: a mating union
  whose only duplicated child’s duplicate occurs at another union among
  that same union’s own children (a sibling-consanguineous mating). Such
  a union is now nudged back toward its true child-centered position
  after the parent-span clamp runs, but only when the clamp actually
  altered the union’s value in the first place – a union the clamp
  already left correct is left untouched, closing a
  worse-than-doing-nothing regression an earlier design attempt found on
  nested/chained consanguineous shapes (5 candidate mechanisms, 2
  mechanism families, investigated across Sessions 598-601 before one
  survived adversarial review). This qualifying shape does not occur
  anywhere in the bundled 375-individual example pedigree or the
  package’s own `small` test fixture, so it has no effect on either
  today; it only changes output for real colonies with a
  sibling-consanguineous mating meeting the above description. The
  separate D1 sibship-bar-vs-bar overlap trade-off above is untouched by
  this fix. **Correction (Session 603):** even in the one fixture built
  to exercise this, the nudge moves the union 5 rendered pixels against
  a 25-pixel node radius – verified via `visNetwork`’s own live
  `getPositions()`, before/after screenshots at 3x zoom are
  indistinguishable. The change is real and tested but currently
  produces no visible correction in any case exercised so far; do not
  read this entry as “the child-centering defect is fixed.”
- Fixed: in the Pedigree Diagram tab, the internal `preferAnchor()`
  anchor tie-break’s final clause – used when 2 candidate parents tie on
  both generation and mate count, a condition guaranteed for every
  full-sibling mate pair – fell back to a locale-dependent character
  comparison, so which parent anchored a mating union (and, with it,
  node x-positions across that anchor’s own subtree) could differ
  between machines or locales for the identical pedigree (issue
  [\#162](https://github.com/rmsharp/nprcgenekeepr/issues/162)). Now
  uses a byte/radix order comparison, matching the locale-independent
  fix already applied elsewhere in this file.

## nprcgenekeepr 2.0.0 (20260708)

CRAN release: 2026-07-26

- Major changes
  - **(breaking)**
    [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
    and
    [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
    now reject `id`, `sire`, or `dam` values containing a period
    (offenders returned in `errorLst$invalidIdChars`); auto-generated
    IDs remain period-free.
  - **(breaking)** Removed the unused exports `getLogo()`,
    `shouldShowErrorTab()`, `modMinimalTestUI()`, and
    `modMinimalTestServer()`. The Shiny application was rewritten
    internally as a modular architecture;
    [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
    remains the primary entry point
    ([`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
    works as a deprecated alias).
    ([\#27](https://github.com/rmsharp/nprcgenekeepr/issues/27),
    [\#110](https://github.com/rmsharp/nprcgenekeepr/issues/110))
  - New **Potential Parents** tab listing candidate sires and dams for
    in-colony animals with at least one unknown parent, screened by
    estimated conception date (wiring in the exported
    [`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md));
    dam selection uses a gestation-derived exclusion window rather than
    a fixed +/- 182.5-day window.
    ([\#48](https://github.com/rmsharp/nprcgenekeepr/issues/48),
    [\#31](https://github.com/rmsharp/nprcgenekeepr/issues/31))
  - Gestation length and minimum breeding ages are now species-aware:
    the bundled `speciesGestation` table covers 14 common colony NHP
    species (previously only rhesus macaque), with numeric rather than
    integer breeding ages so fractional minima are represented exactly.
    [`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
    and the Potential Parents tab derive each animal’s gestation window
    from its `species` via the new
    [`getSpeciesGestation()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesGestation.md);
    the Genetic Value Analysis missing-parent correction uses
    per-species minimum breeding ages; and an optional
    configuration-file entry (`speciesOverridesPath`, plus
    `minBreedingAgeDefault` and `gestationDefault`) overrides these
    values via the new
    [`loadSpeciesOverrides()`](https://github.com/rmsharp/nprcgenekeepr/reference/loadSpeciesOverrides.md).
    Species absent from the table keep the previous defaults (a 210-day
    gestation and a 2-year minimum breeding age), so existing results
    are unchanged. Completes issue
    [\#73](https://github.com/rmsharp/nprcgenekeepr/issues/73).
    ([\#73](https://github.com/rmsharp/nprcgenekeepr/issues/73))
  - New sex-specific minimum breeding ages:
    [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md),
    [`checkParentAge()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkParentAge.md),
    [`runQcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/runQcStudbook.md),
    and
    [`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
    now accept `minSireAge` and `minDamAge` in place of a single
    `minParentAge` (kept as a deprecated alias that sets both). The
    Shiny app’s single “Minimum Parent Age” field is replaced by
    separate “Minimum Sire Age” and “Minimum Dam Age” fields.
    ([\#119](https://github.com/rmsharp/nprcgenekeepr/issues/119))
  - New **ORIP Reporting** tab with ONPRC colony summaries for the NIH
    Office of Research Infrastructure Programs (site information, a
    colony table with founder counts, genetic-diversity metrics, and CSV
    exports); shown only at ONPRC.
    ([\#47](https://github.com/rmsharp/nprcgenekeepr/issues/47),
    [\#49](https://github.com/rmsharp/nprcgenekeepr/issues/49))
  - The Pedigree Browser “trim based on focal animals” option now
    includes descendants as well as ancestors, via the new exported
    [`getDescendantPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getDescendantPedigree.md).
    ([\#35](https://github.com/rmsharp/nprcgenekeepr/issues/35))
  - Added the exported founder helpers
    [`isFounder()`](https://github.com/rmsharp/nprcgenekeepr/reference/isFounder.md)
    and
    [`getFounders()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFounders.md).
  - Added the exported
    [`getAutoIdFormat()`](https://github.com/rmsharp/nprcgenekeepr/reference/getAutoIdFormat.md)
    and
    [`setAutoIdFormat()`](https://github.com/rmsharp/nprcgenekeepr/reference/setAutoIdFormat.md),
    making the auto-generated placeholder-ID format configurable
    (default `"U%04d"`).
    ([\#44](https://github.com/rmsharp/nprcgenekeepr/issues/44),
    [\#38](https://github.com/rmsharp/nprcgenekeepr/issues/38))
  - Genetic Value Analysis tab parity: the genome-uniqueness threshold
    is now a user control (default 4), a subset filter and “Export
    Subset” download were added, the default gene-drop iterations
    changed to 1000 (matched at the function level:
    [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
    and
    [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
    now also default to 1000, down from 5000), and an inert “Minimum
    breeding age” slider was removed.
  - Improved visualizations: educational box-plot popovers
    ([`getBoxWhiskerDescription()`](https://github.com/rmsharp/nprcgenekeepr/reference/getBoxWhiskerDescription.md)),
    plot export to PNG, PDF, and SVG
    ([`savePlotToFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/savePlotToFile.md)),
    and an enhanced age-sex pyramid
    ([`getPyramidPlot()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPyramidPlot.md)).
  - The Genetic Value Analysis now reports three additional
    population-genetic summaries: **gene diversity**
    (`GD = 1 - 1 / (2 * FG)`) and – over the current living breeders – a
    **sex-ratio effective population size** (`4 * Nm * Nf / (Nm + Nf)`)
    and a **variance effective population size** (the Crow &
    Kimura (1970) form), via the new exported
    [`calcGeneDiversity()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGeneDiversity.md),
    [`calcNeSexRatio()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeSexRatio.md),
    and
    [`calcNeVariance()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcNeVariance.md);
    each is defined, with its idealizing assumptions, in the in-app
    Population Genetics Terms panel.
    ([\#118](https://github.com/rmsharp/nprcgenekeepr/issues/118))
  - The Genetic Value Analysis now reports the sampling precision of
    each animal’s genome uniqueness: a new `guSE` column (the gene-drop
    Monte Carlo standard error, via the new
    [`calcGUSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md))
    and a “Genome Uniqueness SE (max)” summary row. The new
    [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
    gives evidence-based advice on how many gene-drop iterations a
    pedigree needs for a stable ranking, by comparing rankings from
    split halves of one gene drop; it also accepts a `kinshipOverrides`
    argument.
  - The Genetic Value Analysis now corrects the mean kinship of animals
    missing one parent, which previously understated their relatedness
    and let them rank as more genetically valuable than they should. A
    new `parentage` column labels each animal “known”, “one unknown
    parent”, or “both unknown”; animals with both parents unknown and no
    recorded origin (“Undetermined”) are now ranked last, with genome
    uniqueness reported as 0 rather than the inflated gene-drop-founder
    artifact value. Animals recorded as genuine imports (an `origin`)
    are unaffected. *(Changes reported rankings and genome-uniqueness
    numbers for affected animals.)*
  - [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
    and the Genetic Value Analysis tab now accept an optional
    `kinshipOverrides` argument (or file upload) of outside-information
    kinship coefficients (`id1`, `id2`, `kinship`) that replace the
    pedigree-derived kinship for the named pairs before ranking; applies
    across the Genetic Value Analysis, breeding-group formation, and
    summary-statistics tabs, and the summary-statistics relationship
    table gains an `overridden` flag column. New exported
    [`applyKinshipOverrides()`](https://github.com/rmsharp/nprcgenekeepr/reference/applyKinshipOverrides.md),
    [`checkKinshipOverrides()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkKinshipOverrides.md),
    and
    [`readKinshipOverrides()`](https://github.com/rmsharp/nprcgenekeepr/reference/readKinshipOverrides.md);
    [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
    also accepts overrides. The unknown-parent mean-kinship correction
    is kept even when an override is supplied. Leaving no override
    reproduces previous results exactly.
    ([\#13](https://github.com/rmsharp/nprcgenekeepr/issues/13),
    [\#95](https://github.com/rmsharp/nprcgenekeepr/issues/95))
  - [`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
    now returns the full connected pedigree component (ancestors,
    descendants, and collaterals such as siblings and mates) instead of
    only the strict ancestor/descendant lineage; the new file-sourced
    [`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md)
    provides the same for file pedigrees. The new
    [`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
    and
    [`setLabKeyDefaults()`](https://github.com/rmsharp/nprcgenekeepr/reference/setLabKeyDefaults.md)
    let the focal-animal workflow run fully offline from files, and the
    Shiny input module offers an optional pedigree-file input alongside
    the LabKey/EHR path.
- Minor changes
  - Fixed a startup crash that occurred when a documented-format site
    configuration file was present, via the new tolerant
    [`loadSiteConfig()`](https://github.com/rmsharp/nprcgenekeepr/reference/loadSiteConfig.md).
    ([\#50](https://github.com/rmsharp/nprcgenekeepr/issues/50))
  - The **About** panel now shows the installed package version
    dynamically (it previously displayed a hard-coded “Version 1.0.8”).
  - [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
    now reports duplicate animal IDs with a clear error instead of the
    base-R `duplicate 'row.names' are not allowed` message.
  - Reading a file whose final line lacks a trailing newline no longer
    emits the spurious “incomplete final line” warning.
    ([\#4](https://github.com/rmsharp/nprcgenekeepr/issues/4))
  - [`addGenotype()`](https://github.com/rmsharp/nprcgenekeepr/reference/addGenotype.md)
    now coerces its allele columns to character, so the integer allele
    encoding is consistent whether they are supplied as character or
    factor.
  - Re-exported the bundled `rhesusPedigree` and `rhesusGenotypes` data
    sets with canonical column types (character `id`, `sire`, and `dam`
    and `Date` `birth` and `exit` in `rhesusPedigree`; all-character
    columns in `rhesusGenotypes`), preserving every value.
  - [`summarizeKinshipValues()`](https://github.com/rmsharp/nprcgenekeepr/reference/summarizeKinshipValues.md)
    now reports the `secondQuartile` column as the lower hinge
    (`fivenum()[2]`) instead of duplicating `min`.
  - New dependencies: `bslib`, `DT`, and `ggplot2` (Imports);
    `shinytest2` (Suggests).
  - [`create_wkbk()`](https://github.com/rmsharp/nprcgenekeepr/reference/create_wkbk.md)
    now writes `.xlsx` files with `openxlsx` instead of `WriteXLS`,
    removing the package’s Perl requirement (`WriteXLS` shelled out to a
    bundled Perl script). Output and behavior are otherwise unchanged.
  - Replaced the magrittr pipe (`%>%`) with the base R native pipe
    (`|>`) in vignettes and examples; `magrittr` is no longer used.
  - [`getPedMaxAge()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedMaxAge.md)
    now returns `NA` instead of `-Inf` when a pedigree has no
    non-missing ages, so the age-sex pyramid plot renders cleanly
    instead of deriving a spurious `-Inf` axis bound.
    ([\#121](https://github.com/rmsharp/nprcgenekeepr/issues/121))
  - [`makeSimPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeSimPed.md)
    now preserves a known parent instead of overwriting it with a random
    candidate, correcting
    [`createSimKinships()`](https://github.com/rmsharp/nprcgenekeepr/reference/createSimKinships.md)
    and
    [`cumulateSimKinships()`](https://github.com/rmsharp/nprcgenekeepr/reference/cumulateSimKinships.md)
    for animals with one known and one unknown parent. *(Changes
    simulated-kinship values for affected pedigrees.)*
  - The exported
    [`makeGrpNum()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGrpNum.md)
    has been renamed to
    [`makeGroupNum()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGroupNum.md)
    for naming consistency with the sibling export
    [`makeGroupMembers()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGroupMembers.md);
    the old name is kept as a deprecated alias.
  - The Genetic Value Analysis report and both of its CSV exports (the
    full ranked report and the genetic-value subset) now include `sire`
    and `dam` columns, showing which animals have an unknown parent.
  - File-based pedigree ingestion now treats `species` as a first-class
    column: it is recognized and placed immediately after `sex` in the
    canonical column order, and typed as character, rather than
    surviving as an untyped trailing column.
  - In the Pedigree Browser tab, “Clear Focal Animals” now also clears a
    focal-animals list uploaded via the file browser (and its displayed
    file name) and any focal Ids typed into the text box, so neither is
    silently re-read on the next “Update Focal Animals”.
  - `getPedDirectRelatives(unrelatedParents = TRUE)` now returns a
    placeholder ego record for a referenced parent with no record of its
    own, instead of erroring; previously dormant since no caller
    exercised the `TRUE` branch.
    ([\#114](https://github.com/rmsharp/nprcgenekeepr/issues/114))
  - The offline focal-animal path no longer prints a benign
    `cannot open file ...` console warning when the focal-id list file
    is missing or unreadable; the classed error it already reported is
    unchanged.
  - Documentation: extensive help-page and dataset-documentation
    corrections, including the genetic-value `@return` and parameter
    descriptions, dataset titles and descriptions, and the `@examples`
    for
    [`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md),
    [`cumulateSimKinships()`](https://github.com/rmsharp/nprcgenekeepr/reference/cumulateSimKinships.md),
    and
    [`getIdsWithOneParent()`](https://github.com/rmsharp/nprcgenekeepr/reference/getIdsWithOneParent.md).
  - Documentation: the example configuration file
    (`inst/extdata/example_nprcgenekeepr_config`) now documents that
    `lkPedColumns` is center-specific: SNPRC uses the flat `dam`/`sire`
    columns (direct columns) while ONPRC uses the `Id/parents/dam`
    lookup-traversal form (curated parentage).
  - Fixed a CRAN Policy violation: the Shiny application no longer
    writes a debug log file to the user’s home directory unconditionally
    at startup. The log file is now created only after a user explicitly
    enables the Input tab’s “Debug on” checkbox, matching the documented
    behavior.
  - Fixed a data-corruption bug: uploading a pedigree as an Excel
    workbook via the Input tab silently converted every alphanumeric
    sire/dam ID to a missing value, collapsing the pedigree to
    near-all-founders with no error or warning shown to the user. CSV
    and tab/comma-delimited text uploads were unaffected.
  - Fixed the Breeding Groups tab’s “Custom” sex ratio option: selecting
    it previously had no numeric input to specify the ratio and silently
    behaved identically to “None”. A numeric “Custom ratio (F per M)”
    field now appears when “Custom” is selected, and its value is used
    when forming groups.
  - Fixed the Breeding Groups tab’s “Number of top animals” field: it
    never appeared regardless of the selected animal source, including
    the default “Top ranked” selection where it is supposed to be
    visible on page load.
  - `data(examplePedigree)` now includes a `fromCenter` (colony-origin)
    column, derived from its existing `origin`/`recordStatus` fields, so
    the Potential Parents tab can show a populated result (1,587
    candidates) against the package’s own example data instead of only
    its graceful-degradation message.

## nprcgenekeepr 1.0.8 (20250723)

CRAN release: 2025-07-26

- Minor changes
  - Added returned value descriptions for all functions within R
    directory where formerly missing.
  - Changed unit test for
    [`get_elapsed_time_str()`](https://github.com/rmsharp/nprcgenekeepr/reference/get_elapsed_time_str.md)
    to use a mocked version of
    [`proc.time()`](https://rdrr.io/r/base/proc.time.html)

## nprcgenekeepr 1.0.7 (20250506)

CRAN release: 2025-04-24

- Minor changes
  - Added returned value descriptions for all functions where formerly
    missing.
  - Removed extraneous spaces from DESCRIPTION file.
  - Exposed all examples in roxygen2 comments by removing and and . The
    example with
    [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
    is protected with `if (interactive()) {}`.

## nprcgenekeepr 1.0.6 (20241215)

- Minor changes
  - Update version in preparation for CRAN submission
  - Added article demonstrating Simulated Kinships with Partial
    Parentage
  - Added use of CICD pipeline as GitHub Actions
    - lintr pipeline
    - R CMD check pipeline with multiple R environments and versions
    - pkgdown pipeline
  - Added several unit tests
  - Cleaned up code based on lintr feedback
  - Added example deidentified pedigree data
    2022-05-02_Deidentified_Pedigree.xlsx,
    2022-05-02_Deidentified_Pedigree_focal_animals.csv,
    deidentified_jmac_ped.csv (text, except for dates, are in double
    quotes), deidentified_jmac_ped_edited.csv (edited to remove double
    quotes).
  - Made
    [`getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md)
    more robust.
  - Abstracted out removal of auto generated Ids in preparation of
    allowing the user to define how auto generated Ids will be formed.
  - Added some quality assurance badges to README.
  - Added CRAN status badge to README.
  - Stopped using travis-ci and started using GitHub Actions with
    Rhub.yaml file for checking on Rhub.

## nprcgenekeepr 1.0.5.9004 (20221213)

- Minor changes
  - Changed method used to test class of object to use inherits().
  - Corrected `getPedDirectRelative()` so that all direct relatives are
    found. Supplemented unit tests for more direct relative types.
  - Added unit tests for
    [`trimPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/trimPedigree.md).
  - Changed call `as.character(date_object)` to `format(date_object)` in
    getDatedFileName.R to prepare for newer code in development version
    of
    18. 
  - Technical edits of R code based on `lintr::lint_dir("R")`

## nprcgenekeepr 1.0.5.9003 (20220625)

- Minor changes
  - Removed dependency on gdata.
  - Removed `getMinParentAge()` as it was never used.
  - Starting to replace [`rbind()`](https://rdrr.io/r/base/cbind.html)
    with `rbindlist()` from `data.table` were possible.

## nprcgenekeepr 1.0.5.9002 (20220425)

- Minor changes
  - Added use of data.table in an effort to reduce memory use and CPU
    use for estimation of kinship values.
  - Functions were refactored and the ability to handle larger
    simulations resulted.

## nprcgenekeepr 1.0.5.9001 (20210830)

- Major changes
  - Added ability to use simulation to estimate the kinship values of
    animals with incomplete parental information that are known to have
    been born within the colony. These animals may have 0 or 1 known
    parents but have a value in the pedigree file or database for the
    *fromcenter* or *fromCenter* field of “Y”, “YES”, “T”, or “TRUE”.
- Minor changes
  - Increase unit test coverage primarily to include more rare events
    and events that should not happen and are trapped and result in
    errors.
  - Changed to travis-ci.com

## nprcgenekeepr 1.0.5 (20210328)

CRAN release: 2021-03-31

- Major changes – none
- Minor changes
  - CRAN submission primarily in response to a change in `shiny 1.6`
    that removed an internal `shiny` function (`shiny:::%OR%`) and
    replaced it with `rlang::%||%`
  - Stale URL in historical documentation that were causing notes to be
    generated in automated tests have been removed.
  - A URL referring to Terry Therneau’s page was updated from “http” to
    “https”.
  - I have incremented the version from 1.0.4 (github.com only version)
    to 1.0.5, updated NEWS to reflect the changes, and updated all
    documentation to reflect the version change.

## nprcgenekeepr 1.0.4.9003 (20210318)

- Major changes – none
- Minor changes
  - Testing .travis.yml code change to get textshaping to build on all
    systems..
  - Cleaned up .travis.yml in response to syntax checking on travis.org.
  - Added `markdown` to suggest due to new changes in `knitr`.

## nprcgenekeepr 1.0.4 (20210318)

- Major changes – none
- Minor changes
  - Added suppression of warnings from DT at beginning of server.R since
    it is unlikely for anyone to call affected functions in the
    controlled environment.
  - Changed call to shiny:::`%OR%` to rlang::`%||%` in server.R since
    the update to 1.6 of shiny broke the code. Thanks to Dan Metzger of
    Wisconsin National Primate Research Center.

## nprcgenekeepr 1.0.3 (20200526)

CRAN release: 2020-06-02

- Major changes – none
- Minor changes
  - CRAN re-submission: responded to the two requests provided by
    reviewer
    - I have removed the capitalization from “Genetic Tools for Colony
      Management” and “Genetic Value Analysis Reports” within
      DESCRIPTION.
    - I have removed the conditional installation of DT from the ui.R
      file.
  - I have incremented the version from 1.0.2 to 1.0.3, updated NEWS to
    reflect the changes, and updated all documentation to reflect the
    version change.

## nprcgenekeepr 1.0.2 (20200517)

- Major changes – none
- Minor changes
  - CRAN re-submission: responded to all requests provided by reviewer
    - I have not changed the capitalization of `Shiny` in the
      description section of the DESCRIPTION file as it is the name of
      the type of application and is not being used as the name of the
      package. The use of the capitalization is consistent with the
      capitalization used within the documentation for the `shiny`
      package (?shiny, See the Details section, first sentence where it
      is used as the type of tutorial.) and all documentation and
      tutorials provided by the author and RStudio where it is
      capitalized everywhere except when referring to the package.
    - I have continued to use dontrun for the following examples:
      - `runGeneKeepr()`, which starts the Shiny application
      - [`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md),
        which is dependent on a valid LabKey instance, a proper
        configuration file, and a .netrc or \_netrc authentication file.
    - I have exchanged dontrun for donttest for the following examples:
      - [`create_wkbk()`](https://github.com/rmsharp/nprcgenekeepr/reference/create_wkbk.md)
      - [`createPedTree()`](https://github.com/rmsharp/nprcgenekeepr/reference/createPedTree.md)
      - [`findLoops()`](https://github.com/rmsharp/nprcgenekeepr/reference/findLoops.md)
      - [`countLoops()`](https://github.com/rmsharp/nprcgenekeepr/reference/countLoops.md)
      - All 11 examples in data.R
      - [`makeExamplePedigreeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeExamplePedigreeFile.md)

## nprcgenekeepr 1.0.1 (20200510)

- Major changes – none
- Minor changes
  - CRAN re-submission: responded to all requests provided by reviewer
    - Reduced the time required for unit test from over 12 minutes to
      21.6 seconds by skipping those test dependent on stochastic
      creation of simulated pedigrees and breeding groups when not
      running on my system.
    - Reduced the time to run examples and create vignettes by reducing
      the number of stochastic modeling iterations by orders of
      magnitude without reducing the examples provided for user-facing
      functions.
    - Checking (–as-cran –run-donttest) Duration: 2m 21.8s on my system.
    - The files with the Rd-tag of `\arguments` missing do not take
      arguments.
    - Corrected private referencing (`:::`) for exported functions.
    - Exported all functions used in examples to remove private
      referencing (`:::`).
    - Removed all single quotes on names, abbreviations, initialisms,
      and, acronyms.
    - The phrase Electronic Health Records (EHR) is the name of a module
      within LabKey, which this software can use as a source of pedigree
      information so the capitalization is appropriate.
    - Two exported functions used by server.R to call `tabpanel()` do
      not have examples.

## nprcgenekeepr 1.0 (20200415)

- Major changes – none
- Minor changes
  - CRAN submission

## nprcgenekeepr 0.5.43 (20200414)

- Major changes – none
- Minor changes
  - Final preparation for CRAN submission

## nprcgenekeepr 0.5.42.9012 (20200412)

- Major changes – none
- Minor changes
  - Updated unit test for dataframe2string to account for change in age
    of a sire from 8.67 to 8.66 years.
  - Renamed tutorials.

## nprcgenekeepr 0.5.42.9011 (20200409)

- Major changes – none
- Minor changes
  - Build failed on Travis-ci due to unit test failure but the test has
    never failed and does not fail on other builds. Removed set_seed()
    to see if that helps.
  - Fixed GitHub issue 3
  - Added additional explanatory text from Matt Schultz edits for the
    Colony Manager version of the Shiny tutorial.

## nprcgenekeepr 0.5.42.9010 (20200405)

- Major changes – none
- Minor changes
  - Added code to address issue 1 (GitHub). See comment 1 for details,
    but more should be done.
  - Refreshed Shiny_app_use.Rmd to reflect changes since November 2019.

## nprcgenekeepr 0.5.42.9009 (20200402)

- Major changes – none
- Minor changes
  - Wrapped example for `makeExamplePedigreeFile` with `\dontrun{}`
    because R 4.0.0 alpha was leaving the side effect of the dataframe
    stored in a CSV file named as the text of the next line.

## nprcgenekeepr 0.5.42.9008 (20200321)

- Major changes – none
- Minor changes
  - Changed dependency to R \>= 3.6 since caTools is not available for R
    \< 3.6.

## nprcgenekeepr 0.5.42.9007 (20200319)

- Major changes – none
- Minor changes
  - Changed warnings unit test for getLkDirectAncestors to work with
    Windows.

## nprcgenekeepr 0.5.42.9006 (20200319)

- Major changes – none
- Minor changes
  - Completed examples in function documentation
  - Corrected spelling of several word throughout found with
    `spelling::spell_check_package(".")`.

## nprcgenekeepr 0.5.42.9005 (20200201)

- Major changes – none
- Minor changes
  - Added examples to function documentation
  - Added ColonyManagerTutorial.Rmd initial draft, which is copy of
    shiny_app_use.Rmd. It is to be converted for use by colony managers.

## nprcgenekeepr 0.5.42.9004 (20200201)

- Major changes – none
- Minor changes
  - Added examples to function documentation
  - Added obfuscated rhesus pedigree and rhesus haplotypes to use in
    examples

## nprcgenekeepr 0.5.42.9003

- Major changes – none
- Minor changes
  - Renamed local and remote repositories from nprcmanager to
    nprcgenekeepr.

## nprcgenekeepr 0.5.42.9002

- Major changes
  - Changed name of package to nprcgenekeepr. This required changing of
    many of the supporting files and functions. Having good unit test
    coverage of the functions (739 test with \> 90 percent coverage)
    made this possible.
  - This is the last version under the nprcmanager repository name.
  - Conversion worked
    - Running the build check had OK: 739; Failed: 0; Warnings: 0;
      Skipped: 0
- Minor changes – none
