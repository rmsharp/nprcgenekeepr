# Changelog

## nprcgenekeepr 2.0.0.9000 (development version)

### Package

- CRAN accepted the 2.0.0 submission (tagged `v2.0.0`); published
  2026-07-26. Development continues here on top of it.

### Pedigree Diagram

- The Pedigree Browser tab gained an interactive **Diagram** view: click
  any animal to re-center the diagram on it. Pedigrees above 750 animals
  show an informative message instead of rendering, to keep diagrams
  readable (issue
  [\#129](https://github.com/rmsharp/nprcgenekeepr/issues/129)).
- The Diagram tab includes an in-app legend explaining what each shape
  means for an animal’s sex (issue
  [\#132](https://github.com/rmsharp/nprcgenekeepr/issues/132)).
- The Diagram tab includes hover tooltips and a search/highlight box for
  finding an animal by id (issue
  [\#135](https://github.com/rmsharp/nprcgenekeepr/issues/135)).
- The Diagram tab’s layout follows the standard kinship2 convention used
  in published pedigree charts: a mated pair is joined by a mate line,
  and an individual with more than one mate is drawn once per mating
  rather than once total.
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
  builds this layout;
  [`makePedigreeDiagramData()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeDiagramData.md)
  is unrelated to it.
- The Diagram tab includes a **Diagram Edge Style** toggle: choose
  between a default “Direct” straight-line connector style and an
  alternative “Rectilinear (kinship2-style)” right-angle style (issue
  [\#142](https://github.com/rmsharp/nprcgenekeepr/issues/142)).
- The Diagram tab can shade individuals as affected by a condition,
  using an optional `affected` column, matching a kinship2 shading
  convention (issue
  [\#133](https://github.com/rmsharp/nprcgenekeepr/issues/133)).
- The Diagram tab can show each animal’s name next to its id, via an
  optional `name` column and a **Show Names on Diagram** toggle;
  de-identified exports automatically remove names (issue
  [\#136](https://github.com/rmsharp/nprcgenekeepr/issues/136)).
- The Diagram tab can show twin connectors (identical, fraternal, or
  unknown zygosity), using the same twin-code convention as kinship2
  (issue [\#137](https://github.com/rmsharp/nprcgenekeepr/issues/137)).
- The Diagram tab places the male parent on the left within a mated pair
  by default, matching the convention most pedigree readers expect
  (issue [\#145](https://github.com/rmsharp/nprcgenekeepr/issues/145)).
- Unaffected and unknown-status individuals are shown unshaded (open)
  rather than filled, matching kinship2’s own shading convention.
- The Diagram tab draws a mate line thicker and in a distinct color for
  a consanguineous mating (parents who are blood relatives), matching
  kinship2’s convention – detected automatically from the pedigree, no
  extra column needed. Applies to the “Direct” edge style; “Rectilinear”
  support follows below.
- The Rectilinear edge style correctly avoids an unnecessary extra bend
  in unrelated mate lines even when a pedigree has one parent recorded
  but missing their own row.
- The consanguineous-mating marker above also survives a “Rectilinear”
  reroute (a mate line that needs to bend around an obstacle).
- When a pedigree has no `affected` column at all, animals default to
  unshaded (open) rather than shaded as affected, matching kinship2’s
  convention – including the package’s own bundled example pedigree.
- Every pair of animals at the same generation keeps at least a
  consistent minimum gap apart, so nearby unrelated animals are never
  drawn closer together than directly-related ones.
- When a mated pair’s two parents are recorded at different generations,
  their shared mating symbol is placed on the correct row by
  construction. A visible consequence: a parent who anchors matings at
  more than one generation appears as a duplicate node more often than a
  naive single-row placement would produce (22 individuals in the
  bundled example pedigree).
- The Diagram tab defaults to the “Rectilinear (kinship2-style)” edge
  style; with no style chosen, the display limit is 400 animals
  (switching to “Direct” raises it to 750).
- In the Rectilinear edge style, a sibling group’s connecting bar avoids
  visually crossing an unrelated animal’s own row in the common case –
  most importantly when a sibling also anchors her own mating at the
  same generation (issue
  [\#160](https://github.com/rmsharp/nprcgenekeepr/issues/160)). Two
  rarer related cases remain open, disclosed follow-ups for a future
  pass.
- In the Rectilinear edge style, the layout detects when a straight
  connector line would visually pass through an unrelated animal – most
  often in large, many-founder colony pedigrees – and reroutes around
  the obstacle. A small number of curved duplicate-animal connectors get
  only a partial correction and remain a disclosed residual.
- The small hidden markers used to bend a connector line around an
  obstacle (see above) no longer occasionally show up as a stray dot
  near an unrelated animal.
- Two parents in a straightforward one-mate pairing (each mated only
  once, sex clearly recorded) are drawn with a clearer gap between them,
  matching kinship2’s convention.
- The small mating symbol for that same kind of pairing sits near one
  parent rather than centered between the two – keeping the connecting
  line down to their children straight instead of bent (issue
  [\#166](https://github.com/rmsharp/nprcgenekeepr/issues/166)).
- Which parent a mating symbol anchors to is consistent across computers
  and regional settings: the anchor tie-break uses a locale-independent
  comparison (issue
  [\#162](https://github.com/rmsharp/nprcgenekeepr/issues/162)).
- Pedigree diagram positioning centers children accurately over their
  parents and produces fewer overlapping lines, especially in large or
  tangled families (issue
  [\#141](https://github.com/rmsharp/nprcgenekeepr/issues/141)).
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
  has no `orderBySex` argument – the male-left/female-right convention
  is always applied.
- Fixed a crash in the Diagram tab: narrowing to a small set of focal
  animals and their family could make the diagram fail to display at all
  under the default connector style. The diagram now always displays
  correctly for this kind of narrowed view.
- The published article comparing pedigree diagrams against kinship2 (a
  well-known reference pedigree tool) is now checked directly by code,
  not just by eye – confirming its example diagrams show the same family
  relationships kinship2 does, in every case checked.
- The Diagram tab no longer shows an individual as a disconnected,
  floating box when they have no recorded parents, mates, or offspring –
  matching how the reference tool kinship2 draws the same family.
  Loading a set of animals with no such relationships among any of them
  no longer crashes the diagram (issue
  [\#164](https://github.com/rmsharp/nprcgenekeepr/issues/164)).
- For most simple mated pairs (one mate each, no other family
  complications), the small mating symbol between them now sits clearly
  between the two animals, with a visible gap, instead of sitting right
  on top of one parent – matching how the reference tool kinship2 draws
  the same pairing. Pairs with more complicated family situations (a
  parent with more than one mate, for example) are unaffected and
  unchanged.
- For mating pairs the layout can safely spread apart, the small mating
  symbol now sits closer to the true midpoint between the two parents,
  instead of drifting toward one parent.
- A small number of mating symbols that could land close enough to an
  unrelated duplicate-animal marker to visually touch, in large colony
  pedigrees with many repeated individuals, are now kept a clear
  distance apart.
- When the Diagram tab leaves an animal out because it has no recorded
  parents, mates, or offspring (see above), it now tells you so, naming
  which animal(s) were left out – and shows a clear message instead of
  an empty diagram when none of the loaded animals have any such
  relationships.
- A small number of duplicate-animal markers that could land close
  enough to an unrelated animal (not part of the same family) to
  visually touch, in large colony pedigrees with many repeated
  individuals, are now kept a clear distance apart. \## Kinship &
  Pedigree Calculations
- Declaring a pair of animals as identical (MZ) twins now corrects their
  computed relatedness to genetic identity, and that correction flows
  through to every other relative reached through either twin – not just
  the pair itself. A twin/zygosity file uploaded on the Diagram tab now
  applies this correction everywhere relatedness is used in the app –
  Summary Statistics, Breeding Groups, and Genetic Value Analysis –
  regardless of which tab is opened first. Script users:
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md),
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md),
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md),
  [`createSimKinships()`](https://github.com/rmsharp/nprcgenekeepr/reference/createSimKinships.md),
  and
  [`cumulateSimKinships()`](https://github.com/rmsharp/nprcgenekeepr/reference/cumulateSimKinships.md)
  all gained a matching `twinRelations` argument.
- New:
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  can now compute X-chromosome relatedness (instead of the usual
  whole-genome average) via a new `chrtype = "x"` option – useful for
  traits carried on the X chromosome. The default behavior
  (`chrtype = "autosome"`) is unchanged; every existing use of
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  keeps working exactly as before. Script-callable only; no Shiny screen
  yet.
- New
  [`shrinkPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/shrinkPedigree.md)
  trims a large pedigree down to just the animals needed to keep it
  genetically informative within a genotyping budget, given which
  animals are already genotyped and, optionally, which are affected by a
  condition of interest. Ties are broken in a fixed, repeatable order
  (kinship2’s own equivalent function breaks ties randomly, so the same
  input there can give a different answer from one run to the next).
  Script-callable only; no Shiny screen yet.

### Marker Genetics

- New **Marker Genetics** tab, starting with a **Kinship Comparison**
  sub-tab: compares DNA-based relatedness (from marker genotypes) side
  by side with pedigree-based relatedness (issue
  [\#130](https://github.com/rmsharp/nprcgenekeepr/issues/130)).
- The Marker Genetics tab includes a **Heterozygosity** sub-tab:
  compares each animal’s own genetic diversity to what’s expected for
  the population (issue
  [\#130](https://github.com/rmsharp/nprcgenekeepr/issues/130)).
- The Marker Genetics tab includes a **Parentage Exclusion** sub-tab:
  flags a pedigree-recorded parent that the DNA evidence contradicts
  (issue [\#130](https://github.com/rmsharp/nprcgenekeepr/issues/130)).
- The Marker Genetics tab includes a **Cross-Center** sub-tab comparing
  genetic diversity between two centers’ populations (issue
  [\#130](https://github.com/rmsharp/nprcgenekeepr/issues/130)) – not to
  be confused with the separate **Cross-Center Identity** tab described
  below, which matches and merges individual animal records rather than
  comparing population-level diversity.
- New **Candidate Parent Assignment** sub-tab: for a flagged animal,
  ranks which other genotyped animals could be the real parent instead,
  based on DNA evidence. Report-only. New
  [`markerParentageLikelihood()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageLikelihood.md)
  (issue [\#147](https://github.com/rmsharp/nprcgenekeepr/issues/147)).
- The Candidate Parent Assignment sub-tab’s automatic suggestion covers
  the common case where a flagged animal’s recorded parent is present in
  the data but simply wrong (issue
  [\#155](https://github.com/rmsharp/nprcgenekeepr/issues/155)).
- New locus-metadata check
  ([`checkLocusMetadata()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md)):
  reports, for each marker locus, whether its chromosome/position data
  is complete, partial, or missing – PLINK-style. New example files
  included. No Shiny screen yet (issue
  [\#153](https://github.com/rmsharp/nprcgenekeepr/issues/153)).
- New
  [`checkLinkageMarkerGenotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLinkageMarkerGenotypeFile.md)
  validates marker panels with more than 2 alleles per locus
  (e.g. STR/microsatellite markers), alongside the existing 2-allele
  check. No Shiny screen yet (issue
  [\#153](https://github.com/rmsharp/nprcgenekeepr/issues/153)).
- New
  [`markerRealizedRelatednessVariance()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerRealizedRelatednessVariance.md)
  estimates how much a pair’s actual DNA-based relatedness can vary
  around what the pedigree alone would predict. No Shiny screen yet
  (issue [\#153](https://github.com/rmsharp/nprcgenekeepr/issues/153)).
- New
  [`markerLdBlock()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerLdBlock.md)
  reports which nearby markers on the same chromosome tend to be
  inherited together, with a matching
  [`obfuscateLdBlocks()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateLdBlocks.md)
  for de-identified export. No Shiny screen yet (issue
  [\#153](https://github.com/rmsharp/nprcgenekeepr/issues/153)).
- The Marker Genetics tab includes a **Linkage and LD Block Metrics**
  sub-tab, combining the locus-coverage, relatedness-variance, and
  linkage-block reports above in one place, with de-identified export
  (issue [\#153](https://github.com/rmsharp/nprcgenekeepr/issues/153)).
- New sequence-scale marker genotype check
  ([`checkSequenceGenotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSequenceGenotypeFile.md)),
  for genotype files with far more markers than a standard panel. No
  Shiny screen yet (issue
  [\#152](https://github.com/rmsharp/nprcgenekeepr/issues/152)).
- The DNA-relatedness and candidate-parent calculations
  ([`markerKinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md)/[`markerParentageLikelihood()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageLikelihood.md))
  are optimized to handle large marker panels efficiently (issue
  [\#152](https://github.com/rmsharp/nprcgenekeepr/issues/152)).
- New: computes each animal’s inbreeding level directly from large-scale
  sequence data (runs of homozygosity), not just from the pedigree. No
  Shiny screen yet. New
  [`computeGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/computeGenomicROH.md)
  (issue [\#152](https://github.com/rmsharp/nprcgenekeepr/issues/152)).
- New
  [`obfuscateGenotypeMatrix()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenotypeMatrix.md)
  de-identifies a sequence-scale genotype file’s animal ids. No Shiny
  screen yet (issue
  [\#152](https://github.com/rmsharp/nprcgenekeepr/issues/152)).
- The Marker Genetics tab includes a **Genomic ROH (F_ROH)** tab: the
  sequence-based inbreeding calculation above, with de-identified export
  (new
  [`obfuscateGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenomicROH.md))
  (issue [\#152](https://github.com/rmsharp/nprcgenekeepr/issues/152)).
  \## Cross-Center Identity Matching
- New
  [`resolveCrossCenterIds()`](https://github.com/rmsharp/nprcgenekeepr/reference/resolveCrossCenterIds.md)
  merges pedigree records for the same animals held by two different
  centers, using a curator-confirmed id-matching table.
- New
  [`checkCrossCenterMapping()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkCrossCenterMapping.md)
  reports every problem with a cross-center id-matching table at once,
  instead of stopping at the first one found. Merging preserves every
  one of an animal’s own data columns (issue
  [\#149](https://github.com/rmsharp/nprcgenekeepr/issues/149)).
- New **Cross-Center Identity** tab: walks a curator through matching
  and merging records from two centers, with a preview and downloadable
  results behind a confirmation step (issue
  [\#149](https://github.com/rmsharp/nprcgenekeepr/issues/149)). \##
  Genetic Value Analysis
- The Genetic Value Analysis tab gained a configurable **Ranking
  Scheme** control: choose a priority-tier ranking alongside the
  existing combined kinship/uniqueness score (issue
  [\#125](https://github.com/rmsharp/nprcgenekeepr/issues/125)). Script
  users:
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  gained matching `guCutoff`/`zScoreCutoff`/`axisPriority` arguments.
- The Genetic Value Analysis Summary Statistics table gained
  **Skewness** and **Kurtosis** columns, describing the shape of the
  genetic-value distribution (issue
  [\#126](https://github.com/rmsharp/nprcgenekeepr/issues/126)). Script
  users: new
  [`calcSkewness()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcSkewness.md)/
  [`calcKurtosis()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcKurtosis.md).
- The Genetic Value Analysis rankings table gained a **flagged** column
  marking animals whose ranking correction couldn’t be applied for lack
  of a comparable peer group (issue
  [\#127](https://github.com/rmsharp/nprcgenekeepr/issues/127)).

### Breeding Group Formation

- The Breeding Group Formation tab now shows up to 5 candidate groupings
  per run, with a selector and comparison table (issue
  [\#125](https://github.com/rmsharp/nprcgenekeepr/issues/125)). Script
  users:
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  gained a matching `candidates` field in its return value.
- The Breeding Group Formation tab gained an **Include animals by**
  control: an alternative genetic-value-floor option alongside the
  existing top-N cutoff (issue
  [\#128](https://github.com/rmsharp/nprcgenekeepr/issues/128)).
- The Breeding Group Formation tab gained a **Candidates to retain**
  control, replacing a fixed cap of 5. Script users:
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  gained a matching `maxCandidates` argument (issue
  [\#146](https://github.com/rmsharp/nprcgenekeepr/issues/146)).
- The Breeding Group Formation tab gained an **Exhaustive enumeration
  mode** checkbox: checks every possible single-group split instead of
  sampling, for the simplest case. Script users:
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  gained a matching `exhaustive` argument (issue
  [\#146](https://github.com/rmsharp/nprcgenekeepr/issues/146)).

### Mate Pair Analysis

- New
  [`reportMatePairs()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportMatePairs.md)
  reports individual mate-pair candidates with their relatedness and
  genetic-value context. Report-only (issue
  [\#151](https://github.com/rmsharp/nprcgenekeepr/issues/151)).
- New **Mate Pair Analysis** tab: a curator view built on the report
  above, kept separate from Breeding Group Formation (issue
  [\#151](https://github.com/rmsharp/nprcgenekeepr/issues/151)).

### De-Identified Export

- [`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)
  gained a **linkedDateShift** argument (default `TRUE`): shifts all of
  one animal’s dates by the same offset when de-identifying, so the gaps
  between its own dates stay realistic instead of possibly ending up out
  of order (issue
  [\#150](https://github.com/rmsharp/nprcgenekeepr/issues/150)).
- New **De-Identified Export** tab: a curator workflow with a live
  preview and 3 downloadable files (the de-identified pedigree, a record
  of what was changed, and a private key to re-identify records later)
  behind a confirmation step (issue
  [\#150](https://github.com/rmsharp/nprcgenekeepr/issues/150)).

### General Fixes

- Fixed: the sort order in a few tables (the Genetic Value Analysis
  tiers, the main pedigree table, and the Breeding Group member table)
  could vary depending on the server’s own regional settings, purely
  from how ids happened to sort – not from any real difference in the
  data. All three now sort in a fixed, consistent order everywhere.

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
