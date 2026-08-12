NEWS
================
R. Mark Sharp, Ph.D.
2026-01-26

# nprcgenekeepr 2.0.0.9000 (development version)

- CRAN's 2.0.0 submission (2026-07-17, tagged `v2.0.0`) was accepted and
  published 2026-07-26. Development continues here on top of it; any
  future CRAN resubmission ships as 2.0.1, not a second 2.0.0 attempt.
- New script-callable `checkLocusMetadata()` (issue \#153, Slice 1)
  validates a `locus, chrom, pos[, cM]` locus-metadata sidecar table --
  the schema shared with sibling issue \#152's own sequence-genetics
  work -- and reports each locus's coverage as one of three explicit
  tiers: `"full"` (chrom and pos both known; cM is optional even within
  `"full"`), `"partial"` (exactly one of chrom/pos known), or `"none"`
  (neither known), following a PLINK-style three-state coverage model
  rather than requiring complete metadata before any downstream use. A
  new bundled example fixture pair (`example_locus_metadata.csv` /
  `example_str_marker_genotypes.csv`) adds the package's first
  multiallelic, panel-scale marker-genotype example, proving the
  existing `buildMarkerGenotypeMatrix()` already handles multiallelic
  data unchanged -- the biallelic restriction lives entirely in
  `checkMarkerGenotypeFile()`, deliberately not used for this fixture.
  No Shiny UI yet -- linkage-aware/haplotype-block metrics and a
  matching tab are separate, future slices.
- New script-callable `checkLinkageMarkerGenotypeFile()` (issue \#153,
  Slice 2) is a sibling to `checkMarkerGenotypeFile()`: it validates the
  same long-format `id`/`locus`/`allele1`/`allele2` genotype table and
  retains the same column-count, `id`-first-column, and duplicate-row
  checks, but deliberately omits the more-than-two-distinct-alleles-per-
  locus rejection -- so real, multiallelic colony marker panels (e.g.
  microsatellite/STR panels) can be ingested.
  `checkMarkerGenotypeFile()`/`markerKinship()`'s existing biallelic
  contract is completely untouched. No Shiny UI yet.
- New script-callable `markerRealizedRelatednessVariance()` (issue
  \#153, Slice 3) estimates the variance of *actual* (realized)
  relatedness around a pair's pedigree-expected value for
  Parent-Offspring, Full-Siblings, and Half-Siblings pairs -- pedigree
  kinship gives only an average, but the true fraction of genome shared
  identical-by-descent varies around it because of Mendelian sampling
  and linkage. Implements the closed-form solution of Hill & Weir
  (2011), extending this package's existing
  `kinship()`/`convertRelationships()` rather than a new framework;
  other relationship categories return `NA`, not an error. No Shiny UI
  yet.
- New script-callable `markerLdBlock()` and `obfuscateLdBlocks()` (issue
  \#153, Slice 4) add a descriptive, same-chromosome pairwise LD/block
  statistic for exploratory use -- a documented, non-rigorous
  compromise, since no method exists that is both pedigree-aware and
  multiallelic- capable; `markerRealizedRelatednessVariance()` remains
  the primary, pedigree-valid metric. `obfuscateLdBlocks()`
  de-identifies the optional founder-id column before export. No Shiny
  UI yet.
- The Genetic Value Analysis tab gained a configurable **Ranking
  Scheme** control (issue \#125): the existing combined
  kinship/uniqueness score stays the default, unchanged; a new
  categorical priority-tier scheme is now selectable alongside it, with
  adjustable high-uniqueness and low-kinship cutoffs and a choice of
  which axis takes priority when an animal qualifies for both.
  `reportGV()` gained matching `guCutoff`, `zScoreCutoff`, and
  `axisPriority` arguments for scripted use, each defaulting to today's
  behavior when omitted.
- The Breeding Group Formation tab now surfaces up to 5 distinct
  candidate groupings per run (issue \#125), instead of only the single
  best-scoring one, with a new selector to switch among them (and a
  comparison table of each candidate's score) without re-running the
  group-formation algorithm. Leaving the selector at its default (the
  best-scoring candidate) is unchanged from today's behavior.
  `groupAddAssign()`'s return value gains a `candidates` list field for
  scripted use; the existing top-level `group`/`score`/`groupKin` fields
  are unchanged (they alias the best candidate).
- The Breeding Group Formation tab gained an **Include animals by**
  control (issue \#128): the existing top-N cutoff stays the default,
  unchanged; a new **Genetic-value floor** option excludes any candidate
  whose Genetic Value Analysis result is "Low Value" instead of applying
  a fixed count, for all three animal-source choices. Animals labeled
  "Undetermined" still pass (a data gap, not evidence of low value); an
  animal with no Genetic Value Analysis result at all does not pass.
  Leaving the control at its default ("Top N ranked") reproduces today's
  exact behavior.
- The Genetic Value Analysis Summary Statistics tab's Mean Kinship /
  Genome Uniqueness distribution table gained **Skewness** and
  **Kurtosis** columns (issue \#126), alongside the existing Min/1st
  Quartile/Mean/Median/3rd Quartile/Max columns;
  `makeGeneticSummaryTable()` gained the same two columns for script
  use. Both are the bias-adjusted Fisher-Pearson estimators (Joanes &
  Gill 1998), exposed as new exported functions
  `calcSkewness()`/`calcKurtosis()`; either reads "N/A" when the
  underlying values are too few or have zero variance to compute.
  `modSummaryStatsServer()` gained matching `mkShape`/`guShape`
  return-list reactives for scripted use.
- The Genetic Value Analysis rankings table (and both CSV downloads)
  gained a **flagged** column (issue \#127): `TRUE` for a
  one-unknown-parent animal that `reportGV()`'s mean-kinship correction
  left uncorrected for lack of an eligible contemporaneous breeding-age
  peer cohort, `FALSE` for every other animal. Previously this
  information was silently discarded; there was no way to tell such an
  animal apart from one whose correction succeeded.
- The Pedigree Browser tab gained a **Diagram** view (issue \#129, Slice
  1): alongside the existing sortable table, a new tab renders the same
  focal-animal-trimmed population as an interactive pedigree diagram --
  sex-shaped nodes (square/dot/star/triangle), directed sire/dam edges,
  and a generation-ordered top-down layout -- via a new `visNetwork`
  dependency. Diagrams above 750 animals show an informative message
  instead of an unbounded render; narrow the focal-animal selection to
  view one. Clicking a node (issue \#129, Slice 2) now re-centers the
  population on that animal, re-driving the same focal-animal selection
  the Table tab and focal-animal text box already share -- switch back
  to the Table tab (or enable "Trim pedigree based on focal animals") to
  see the new selection reflected there.
- The Diagram tab's layout was rebuilt for a kinship2-style,
  mating-aware convention (Pedigree Diagram Option 2): a mate's own
  mating(s) now render as small connector nodes with a mate-line to each
  parent and a line down to their shared children, instead of two
  independent sire/dam edges into each child. An individual who mates
  more than once (or whose lineage loops back on itself, e.g. a
  consanguineous mating) appears once per mating as a duplicate node,
  connected back to their main occurrence by a dashed line -- hovering,
  clicking, or searching any occurrence behaves identically to the
  individual's main occurrence. The animal-count display limit above
  dropped from 1,500 to 750 individuals as a result (a colony pedigree
  typically renders roughly twice as many total diagram nodes as animals
  under this convention). A new exported function,
  `makePedigreeMatingLayout()`, computes this layout for scripted use;
  the existing `makePedigreeDiagramData()` is unchanged and still
  available for a simpler one-node-per-animal diagram.
- A new **Marker Genetics** tab, starting with a **Kinship Comparison**
  sub-tab, was added (issue \#130, Slice 1) alongside the existing
  pedigree-based analyses: given an uploaded multi-locus marker genotype
  file, it computes a KING-robust marker-based kinship estimate
  (Manichaikul et al. 2010) for each pair of genotyped animals and
  displays it side by side with the existing pedigree-based kinship, so
  a curator can spot pedigree/marker mean-kinship disagreements. New
  exported functions `checkMarkerGenotypeFile()`,
  `buildMarkerGenotypeMatrix()`, and `markerKinship()` support the same
  computation for scripted use.
- The Marker Genetics tab gained a **Heterozygosity** sub-tab (issue
  \#130, Slice 2): per-animal observed heterozygosity alongside the
  population's expected heterozygosity (Nei 1973 gene diversity),
  computed from the same uploaded genotype file. New exported functions
  `markerObservedHeterozygosity()` and `markerExpectedHeterozygosity()`.
- The Marker Genetics tab gained a **Parentage Exclusion** sub-tab
  (issue \#130, Slice 3): cross-references each animal's
  pedigree-recorded dam/sire against the uploaded genotypes and flags
  any recorded parent contradicted by 3 or more opposite-homozygote
  loci, a genotyping-error-tolerant Mendelian-exclusion threshold
  (Cifuentes et al. 2006). New exported function
  `markerParentageExclusion()`.
- New exported function `resolveCrossCenterIds(pedA, pedB, mapping)`
  (issue \#130, Slice 4) merges two centers' pedigrees using a
  curator-confirmed cross-center identity-link table, so a transferred
  animal becomes one node with its real recorded parents intact instead
  of an artificial founder at the receiving center. Script-callable
  only; no Shiny UI change this slice.
- The Marker Genetics tab gained a **Cross-Center** sub-tab (issue
  \#130, Slice 5): given a second, independently uploaded Center B
  genotype file, computes Hudson's Fst (Bhatia et al. 2013) between the
  two centers' populations at each shared locus, plus a pooled estimate
  across loci. New exported function `markerFst()`.
- The Pedigree Browser's Diagram tab gained an in-app **shape-to-sex
  legend** (issue \#132): a panel next to the diagram now shows what
  each node shape means (dot = Female, square = Male, star =
  Hermaphrodite, triangle = Unknown, diamond = Other/Unrecorded), so
  this no longer has to be looked up outside the app.
- The Pedigree Browser's Diagram tab gained **hover tooltips and a
  search/highlight dropdown** (issue \#135): hovering any animal now
  shows its ID, sex, generation, sire, and dam; a new "Select by id"
  dropdown lets you jump straight to an animal by ID, dimming everything
  except it and its direct connections. `makePedigreeDiagramData()`'s
  returned node data gains a `title` field for scripted use.
- The Pedigree Browser's Diagram tab gained a **Diagram Edge Style**
  toggle (issue \#142): the default "Direct" style is unchanged; a new
  "Rectilinear (kinship2-style)" option routes mate-line and sibship-bar
  connections as strict right angles instead of straight diagonal
  segments, matching the classic pedigree-chart convention. Diagrams
  above 400 animals under the rectilinear style show the same
  informative message the existing 750-animal direct-style limit already
  shows (the rectilinear style renders more total diagram nodes per
  animal, so its display limit is lower). `makePedigreeMatingLayout()`
  gained a matching `edgeStyle = c("direct", "rectilinear")` argument
  for scripted use, defaulting to "direct" (unchanged existing behavior
  for every current caller).
- The Pedigree Browser's Diagram tab can now shade **affected-status**
  individuals (issue \#133): an optional new `affected` logical column
  (matching kinship2's own `affected` argument naming) marks an animal
  as affected by a condition of interest; when present, affected
  individuals are shaded on the diagram and every node's hover tooltip
  gains an "Affected: Yes/No/Unknown" line. Pedigrees without an
  `affected` column render exactly as before. Both
  `makePedigreeDiagramData()` and `makePedigreeMatingLayout()` gained
  this optional-column support. The Diagram tab's shape-to-sex legend
  gained a matching "Affected" swatch so the new shading is discoverable
  without hovering over a node.
- The Pedigree Browser's Diagram tab can now show **animal names**
  alongside id (issue \#136): an optional new `name` character column
  marks an animal's human-readable name/nickname; a new, off-by-default
  **Show Names on Diagram** toggle switches each real (and
  duplicate-occurrence) node's label from id-only to a two-line "id" +
  name form, with a name longer than 15 characters truncated with an
  ellipsis on the canvas label (the full name is always shown in the
  hover tooltip). Not every center records a name, and not every animal
  has one -- an animal with no name, or a pedigree with no `name` column
  at all, renders exactly as before. The diagram's "Select by id" search
  dropdown always lists ids, never names, regardless of the toggle.
  `getPossibleCols()` gained `name` alongside the existing `affected`;
  `obfuscatePed()` scrubs `name` to `NA`, so a de-identified pedigree
  never leaks an animal's real name. Both `makePedigreeDiagramData()`
  and `makePedigreeMatingLayout()` gained this optional-column support.
- The Pedigree Browser's Diagram tab can now show **twin/zygosity
  connectors** (issue \#137), adopting kinship2's own MZ/DZ/UZ twin-code
  convention: an optional twin-relations sidecar file (`id1`, `id2`,
  `code` columns, `code` one of `"MZ twin"`/`"DZ twin"`/`"UZ twin"`) can
  be uploaded alongside the pedigree, and a new, off-by-default **Show
  Twin Connectors** toggle draws a distinctly-styled connector line
  between each declared twin pair's own diagram nodes -- solid for MZ,
  short-dashed for DZ, long-dashed with a "?" label for UZ (a callback
  to kinship2's own UZ glyph), all three drawn in a colorblind-safe
  Okabe-Ito bluish-green (`#009E73`) -- with a matching legend entry.
  Twin declarations are validated against the pedigree (both ids must
  exist and differ; an MZ/DZ pair must already share both `sire` and
  `dam`; MZ additionally requires matching `sex`; UZ has no such
  precondition) via the new exported `checkTwinRelations()`; a companion
  `obfuscateTwinRelations()` scrubs a twin-relations table's ids through
  the same alias map `obfuscatePed(..., map = TRUE)` produces, so a
  de-identified export never leaks real ids through this sidecar. A
  pedigree loaded without any twin data renders exactly as before. Both
  `makePedigreeDiagramData()` and `makePedigreeMatingLayout()` gained an
  optional `twinRelations` argument for scripted use.
- New script-callable `markerParentageLikelihood()` (issue \#147) ranks
  candidate replacement parents for a recorded parent
  `markerParentageExclusion()` has flagged as Mendelian-inconsistent,
  using a CERVUS-style multilocus likelihood-ratio (LOD) score (Meagher
  & Thompson 1986; Marshall, Slate, Kruuk & Pemberton 1998).
  Report-only: it never writes to a pedigree's `sire`/`dam` columns, and
  `markerParentageExclusion()` itself is unchanged and remains the
  independent Mendelian-exclusion check. Reports raw `LOD`, `delta` (the
  gap to the next-ranked candidate), `nLociUsed`, `excluded`, and
  `lowPower` per candidate, deliberately without a simulation-calibrated
  percentage confidence (see the function's own documentation for why).
  The Marker Genetics tab gained a matching **Candidate Parent
  Assignment** sub-tab surfacing this ranking for every flagged pair in
  the uploaded genotype file and current pedigree, with no new file
  input needed.
- Fixed (issue \#155): the Candidate Parent Assignment sub-tab's
  auto-detect default previously showed no candidates at all for the
  common real-world case of a flagged animal whose recorded parent is
  present but wrong (only a genuinely *missing* recorded parent worked
  before). Both the auto-detect default and
  `markerParentageLikelihood()`'s explicit
  `id`/`role`/`candidates = NULL` script-callable form are fixed; no
  change to either function's exported signature or return shape.
- The Pedigree Browser's Diagram tab now defaults to placing the male
  parent to the left in a simple two-parent mating pair, matching common
  pedigree-drawing convention (issue \#145) -- a new, additive default,
  not a bug fix: the diagram never had sex-based left-right positioning
  before. Applies only to a mating pair whose two real parents each have
  an unambiguous male/female sex code and no other mate or partial
  -parentage relationship; multi-mate/"crowded" families keep today's
  layout, unaffected. `makePedigreeMatingLayout()` gained a matching
  `orderBySex` argument (default `TRUE`) for scripted use; setting it to
  `FALSE` reproduces the prior, sex-agnostic default exactly.
- New exported function `checkCrossCenterMapping(pedA, pedB, mapping)`
  (issue \#149, Slice 1): the "show every problem at once" companion to
  `resolveCrossCenterIds()`, sharing its id-existence,
  mapping-uniqueness, id-collision, and parent-conflict checks but never
  stopping on a domain problem -- every one found is returned as a row
  instead, so all of them can be reviewed together rather than one at a
  time. Script-callable only; no Shiny UI change this slice. Also fixes
  a data-loss defect in `resolveCrossCenterIds()` itself: a merged
  individual's shared, agreeing columns beyond `id`/`sire`/`dam` (e.g.
  `sex`) were previously silently dropped; they are now carried through
  under the same prefer-non-`NA`/error-on-conflict rule already used for
  `sire`/`dam`. This is an additive behavior change -- a merged pair
  whose two centers disagree on such a column, which previously merged
  silently, now raises the same kind of conflict error `sire`/`dam`
  disagreement always has.
- New **Cross-Center Identity** tab (issue \#149, Slice 2): a Shiny
  workflow around `resolveCrossCenterIds()`/`checkCrossCenterMapping()`.
  Upload two centers' pedigrees plus a curator-reviewed identity
  mapping; every validation issue is shown at once (no fixing one
  problem at a time); once clean, a Preview tab shows the proposed
  merge's lineage changes (which side each resolved `sire`/`dam` value
  came from); an explicit confirmation dialog gates access to 5
  downloadable artifacts (Merged Pedigree, Mapping, Validation Results,
  Merge Summary, Provenance). Retains the
  no-automatic-identity-inference policy -- identity is established only
  by the uploaded mapping file, never guessed from matching id strings.
  A standalone review/export tool this slice: the merged pedigree is a
  downloadable CSV, not fed into any other tab's analysis; re-upload it
  through the Input tab's existing pedigree-file path to use it
  downstream.
- `groupAddAssign()` gained a `maxCandidates` argument (issue \#146,
  Slice 1) replacing the previously-hardcoded cap of 5 distinct retained
  candidate solutions; the default remains 5, unchanged. The Breeding
  Group Formation tab gained a matching **Candidates to retain** control
  (default 5, 1-50) next to the existing simulation-count input.
- `groupAddAssign()` gained an `exhaustive` argument (issue \#146, Slice
  2, closes \#146): when `TRUE`, every possible single-group partition
  is enumerated instead of randomly sampled, guaranteeing the retained
  candidates include the true best groupings rather than the best a
  sample happened to find. Supported only for `numGp = 1` with no harem
  or custom `sexRatio`; an out-of-scope request, or one whose candidate
  pool exceeds the new `maxExhaustiveCandidates` argument (default 20),
  stops with a message naming the reason rather than silently falling
  back to sampling. A new `exhaustiveTimeLimit` argument (default 10
  seconds) bounds search time, degrading gracefully to a truncated
  (non-exhaustive) result rather than blocking indefinitely. The return
  value gains `exhaustive`, `examined`, and `retentionRule` fields when
  this mode is used; ordinary (sampling) calls are unaffected. The
  Breeding Group Formation tab gained a matching **Exhaustive
  enumeration mode** checkbox (visible only when the current
  configuration is eligible) and a status message reporting the search
  outcome after each run.
- New script-callable `reportMatePairs()` (issue \#151, Slice 1) reports
  eligible individual mate-pair candidates -- opposite-sex, minimum-age
  pairs surviving the same eligibility screens Breeding Group Formation
  already uses (`filterPairs()`/`filterAge()`), each row carrying
  pedigree kinship and, when available, marker-based kinship
  (`markerKinship()`'s KING-robust estimator) and per-parent
  genetic-value context (`reportGV()`'s `indivMeanKin`/`gu`). No
  blended/composite ranking score is computed; callers sort or filter
  the raw columns themselves. A `populationIds` argument scopes the
  candidate pool before computation (age alone does not bound table size
  when many individuals have no recorded age); an `exclude` argument
  drops specific ids entirely. Dropped pairs are reported separately
  with a reason ("under minimum age" or "user-excluded"), never silently
  discarded. Report-only, no Shiny UI yet -- a Mate Pair Analysis tab is
  a separate, future slice.
- A new **Mate Pair Analysis** tab was added (issue \#151, Slice 2), a
  curator-facing view over `reportMatePairs()` (Slice 1), kept
  structurally and file-wise separate from Breeding Group Formation. A
  candidate population must be chosen explicitly -- "All alive" (no
  recorded exit date), "Top ranked by genetic value", or a pasted custom
  id list -- since the age floor alone does not bound the candidate
  table on real, imperfectly-curated colony data. A separate "Excluded"
  table shows every dropped pair with its reason (never silently
  discarded), alongside an optional exclude-list textarea. The "Eligible
  Pairs" table is sortable/filterable and its CSV export downloads
  exactly the currently filtered/sorted rows, not the full unfiltered
  table. Marker-based kinship, where available, now reaches this tab and
  the existing Marker Genetics tab unchanged:
  `modMarkerGeneticsServer()`'s own `markerKinshipMatrix` value was
  computed but never read by any caller until now (a one-line, additive
  capture at its existing call site).
- `obfuscatePed()` gained a **linkedDateShift** argument (issue \#150,
  Slice 1), defaulting to `TRUE`: every Date column of one individual
  (e.g. `birth`/`exit`/`death`) is now shifted by the same, single
  random offset, preserving that individual's inter-date gaps exactly.
  The previous behavior -- each Date column shifted independently --
  could invert an individual's recorded date order (e.g. an obfuscated
  `exit` preceding an obfuscated `birth`), producing a negative
  recomputed `age`; the old behavior is still available via
  `linkedDateShift = FALSE` for any caller that needs it. Ships ahead of
  a future de-identified pedigree export workflow (Slice 2) that depends
  on this fix.
- New **De-Identified Export** tab (issue \#150, Slice 2, closes \#150):
  a curator-facing workflow around the existing `obfuscatePed()`
  (Slice 1) and a new transformation-manifest helper. Exports the
  pedigree already loaded in the current session -- no separate upload
  -- with configurable alias-id length, maximum date shift, and the
  `linkedDateShift` toggle (Slice 1's fix, on by default). A live
  preview shows the de-identified output before anything is exported; an
  explicit confirmation dialog, carrying an institutional-responsibility
  disclaimer (this app's first), gates 3 downloadable artifacts: the
  de-identified pedigree, a transformation manifest (parameters used,
  row count, timestamp -- never the id map or any raw pre-obfuscation
  value), and a distinctly labeled re-identification key ("DO NOT
  SHARE"). Fields other than id, dam, sire, dates, and name (e.g.
  `origin`, `status`) pass through unchanged -- disclosed in the warning
  text and manifest, not silently scrubbed. Matches this app's
  established curator-controlled pattern (a confirmation dialog and
  warning text, not real access control) rather than building new auth
  infrastructure.
- The Marker Genetics tab gained a **Linkage and LD Block Metrics**
  sub-tab (issue \#153, Slice 5, closes \#153): a locus-metadata upload
  with a three-tier coverage report (full/partial/none); the
  pedigree-valid realized-relatedness-variance table
  (`markerRealizedRelatednessVariance()`, Slice 3); and the descriptive
  LD-block table (`markerLdBlock()`, Slice 4) behind a persistent,
  non-dismissable caveat banner. The LD-block table's export is
  de-identified (`obfuscateLdBlocks()`) behind the same curator
  confirm-gate pattern established by the De-Identified Export tab.
- New script-callable `checkSequenceGenotypeFile()` (issue \#152,
  Slice 1) validates a long-format biallelic marker genotype file sized
  for sequence-scale panels, rejecting a literal `.` placeholder and
  warning (not stopping) above a 50,000-locus ceiling. A new bundled
  example fixture pair (`example_sequence_genotypes.csv` /
  `example_sequence_locus_metadata.csv`) provides a 1,000-locus,
  50-individual panel for future slices. No Shiny UI yet.
- `markerKinship()` and `markerParentageLikelihood()` (issue \#152,
  Slice 2) are internally rewritten for large marker panels --
  vectorized matrix algebra and precomputed allele frequencies,
  respectively -- with output and signatures unchanged.
- New script-callable `computeGenomicROH()` (issue \#152, Slice 3)
  computes per-individual genomic Runs-of-Homozygosity segments and the
  F_ROH inbreeding coefficient from a sequence-scale marker genotype
  matrix and locus-metadata sidecar -- a marker-based inbreeding
  estimate independent of the recorded pedigree. No Shiny UI yet.
- New script-callable `obfuscateGenotypeMatrix()` (issue \#152, Slice 4)
  de-identifies a sequence-scale genotype matrix by remapping its row
  names (individual ids) through the same alias map
  `obfuscatePed(...,   map = TRUE)` already returns; genotype values are
  unchanged. No Shiny UI yet.

# nprcgenekeepr 2.0.0 (20260708)

- Major changes
  - **(breaking)** `qcStudbook()` and `geneDrop()` now reject `id`,
    `sire`, or `dam` values containing a period (offenders returned in
    `errorLst$invalidIdChars`); auto-generated IDs remain period-free.
  - **(breaking)** Removed the unused exports `getLogo()`,
    `shouldShowErrorTab()`, `modMinimalTestUI()`, and
    `modMinimalTestServer()`. The Shiny application was rewritten
    internally as a modular architecture; `runGeneKeepR()` remains the
    primary entry point (`runModularApp()` works as a deprecated alias).
    (#27, \#110)
  - New **Potential Parents** tab listing candidate sires and dams for
    in-colony animals with at least one unknown parent, screened by
    estimated conception date (wiring in the exported
    `getPotentialParents()`); dam selection uses a gestation-derived
    exclusion window rather than a fixed +/- 182.5-day window. (#48,
    \#31)
  - Gestation length and minimum breeding ages are now species-aware:
    the bundled `speciesGestation` table covers 14 common colony NHP
    species (previously only rhesus macaque), with numeric rather than
    integer breeding ages so fractional minima are represented exactly.
    `getPotentialParents()` and the Potential Parents tab derive each
    animal's gestation window from its `species` via the new
    `getSpeciesGestation()`; the Genetic Value Analysis missing-parent
    correction uses per-species minimum breeding ages; and an optional
    configuration-file entry (`speciesOverridesPath`, plus
    `minBreedingAgeDefault` and `gestationDefault`) overrides these
    values via the new `loadSpeciesOverrides()`. Species absent from the
    table keep the previous defaults (a 210-day gestation and a 2-year
    minimum breeding age), so existing results are unchanged. Completes
    issue \#73. (#73)
  - New sex-specific minimum breeding ages: `qcStudbook()`,
    `checkParentAge()`, `runQcStudbook()`, and `getPotentialParents()`
    now accept `minSireAge` and `minDamAge` in place of a single
    `minParentAge` (kept as a deprecated alias that sets both). The
    Shiny app's single "Minimum Parent Age" field is replaced by
    separate "Minimum Sire Age" and "Minimum Dam Age" fields. (#119)
  - New **ORIP Reporting** tab with ONPRC colony summaries for the NIH
    Office of Research Infrastructure Programs (site information, a
    colony table with founder counts, genetic-diversity metrics, and CSV
    exports); shown only at ONPRC. (#47, \#49)
  - The Pedigree Browser "trim based on focal animals" option now
    includes descendants as well as ancestors, via the new exported
    `getDescendantPedigree()`. (#35)
  - Added the exported founder helpers `isFounder()` and
    `getFounders()`.
  - Added the exported `getAutoIdFormat()` and `setAutoIdFormat()`,
    making the auto-generated placeholder-ID format configurable
    (default `"U%04d"`). (#44, \#38)
  - Genetic Value Analysis tab parity: the genome-uniqueness threshold
    is now a user control (default 4), a subset filter and "Export
    Subset" download were added, the default gene-drop iterations
    changed to 1000 (matched at the function level: `reportGV()` and
    `geneDrop()` now also default to 1000, down from 5000), and an inert
    "Minimum breeding age" slider was removed.
  - Improved visualizations: educational box-plot popovers
    (`getBoxWhiskerDescription()`), plot export to PNG, PDF, and SVG
    (`savePlotToFile()`), and an enhanced age-sex pyramid
    (`getPyramidPlot()`).
  - The Genetic Value Analysis now reports three additional
    population-genetic summaries: **gene diversity**
    (`GD = 1 - 1 / (2 * FG)`) and -- over the current living breeders --
    a **sex-ratio effective population size**
    (`4 * Nm * Nf / (Nm + Nf)`) and a **variance effective population
    size** (the Crow & Kimura (1970) form), via the new exported
    `calcGeneDiversity()`, `calcNeSexRatio()`, and `calcNeVariance()`;
    each is defined, with its idealizing assumptions, in the in-app
    Population Genetics Terms panel. (#118)
  - The Genetic Value Analysis now reports the sampling precision of
    each animal's genome uniqueness: a new `guSE` column (the gene-drop
    Monte Carlo standard error, via the new `calcGUSE()`) and a "Genome
    Uniqueness SE (max)" summary row. The new `gvaConvergence()` gives
    evidence-based advice on how many gene-drop iterations a pedigree
    needs for a stable ranking, by comparing rankings from split halves
    of one gene drop; it also accepts a `kinshipOverrides` argument.
  - The Genetic Value Analysis now corrects the mean kinship of animals
    missing one parent, which previously understated their relatedness
    and let them rank as more genetically valuable than they should. A
    new `parentage` column labels each animal "known", "one unknown
    parent", or "both unknown"; animals with both parents unknown and no
    recorded origin ("Undetermined") are now ranked last, with genome
    uniqueness reported as 0 rather than the inflated gene-drop-founder
    artifact value. Animals recorded as genuine imports (an `origin`)
    are unaffected. *(Changes reported rankings and genome-uniqueness
    numbers for affected animals.)*
  - `reportGV()` and the Genetic Value Analysis tab now accept an
    optional `kinshipOverrides` argument (or file upload) of
    outside-information kinship coefficients (`id1`, `id2`, `kinship`)
    that replace the pedigree-derived kinship for the named pairs before
    ranking; applies across the Genetic Value Analysis, breeding-group
    formation, and summary-statistics tabs, and the summary-statistics
    relationship table gains an `overridden` flag column. New exported
    `applyKinshipOverrides()`, `checkKinshipOverrides()`, and
    `readKinshipOverrides()`; `gvaConvergence()` also accepts overrides.
    The unknown-parent mean-kinship correction is kept even when an
    override is supplied. Leaving no override reproduces previous
    results exactly. (#13, \#95)
  - `getLkDirectRelatives()` now returns the full connected pedigree
    component (ancestors, descendants, and collaterals such as siblings
    and mates) instead of only the strict ancestor/descendant lineage;
    the new file-sourced `getFileDirectRelatives()` provides the same
    for file pedigrees. The new `getFocalAnimalPedFromFile()` and
    `setLabKeyDefaults()` let the focal-animal workflow run fully
    offline from files, and the Shiny input module offers an optional
    pedigree-file input alongside the LabKey/EHR path.
- Minor changes
  - Fixed a startup crash that occurred when a documented-format site
    configuration file was present, via the new tolerant
    `loadSiteConfig()`. (#50)
  - The **About** panel now shows the installed package version
    dynamically (it previously displayed a hard-coded "Version 1.0.8").
  - `geneDrop()` now reports duplicate animal IDs with a clear error
    instead of the base-R `duplicate 'row.names' are not allowed`
    message.
  - Reading a file whose final line lacks a trailing newline no longer
    emits the spurious "incomplete final line" warning. (#4)
  - `addGenotype()` now coerces its allele columns to character, so the
    integer allele encoding is consistent whether they are supplied as
    character or factor.
  - Re-exported the bundled `rhesusPedigree` and `rhesusGenotypes` data
    sets with canonical column types (character `id`, `sire`, and `dam`
    and `Date` `birth` and `exit` in `rhesusPedigree`; all-character
    columns in `rhesusGenotypes`), preserving every value.
  - `summarizeKinshipValues()` now reports the `secondQuartile` column
    as the lower hinge (`fivenum()[2]`) instead of duplicating `min`.
  - New dependencies: `bslib`, `DT`, and `ggplot2` (Imports);
    `shinytest2` (Suggests).
  - `create_wkbk()` now writes `.xlsx` files with `openxlsx` instead of
    `WriteXLS`, removing the package's Perl requirement (`WriteXLS`
    shelled out to a bundled Perl script). Output and behavior are
    otherwise unchanged.
  - Replaced the magrittr pipe (`%>%`) with the base R native pipe
    (`|>`) in vignettes and examples; `magrittr` is no longer used.
  - `getPedMaxAge()` now returns `NA` instead of `-Inf` when a pedigree
    has no non-missing ages, so the age-sex pyramid plot renders cleanly
    instead of deriving a spurious `-Inf` axis bound. (#121)
  - `makeSimPed()` now preserves a known parent instead of overwriting
    it with a random candidate, correcting `createSimKinships()` and
    `cumulateSimKinships()` for animals with one known and one unknown
    parent. *(Changes simulated-kinship values for affected pedigrees.)*
  - The exported `makeGrpNum()` has been renamed to `makeGroupNum()` for
    naming consistency with the sibling export `makeGroupMembers()`; the
    old name is kept as a deprecated alias.
  - The Genetic Value Analysis report and both of its CSV exports (the
    full ranked report and the genetic-value subset) now include `sire`
    and `dam` columns, showing which animals have an unknown parent.
  - File-based pedigree ingestion now treats `species` as a first-class
    column: it is recognized and placed immediately after `sex` in the
    canonical column order, and typed as character, rather than
    surviving as an untyped trailing column.
  - In the Pedigree Browser tab, "Clear Focal Animals" now also clears a
    focal-animals list uploaded via the file browser (and its displayed
    file name) and any focal Ids typed into the text box, so neither is
    silently re-read on the next "Update Focal Animals".
  - `getPedDirectRelatives(unrelatedParents = TRUE)` now returns a
    placeholder ego record for a referenced parent with no record of its
    own, instead of erroring; previously dormant since no caller
    exercised the `TRUE` branch. (#114)
  - The offline focal-animal path no longer prints a benign
    `cannot open file ...` console warning when the focal-id list file
    is missing or unreadable; the classed error it already reported is
    unchanged.
  - Documentation: extensive help-page and dataset-documentation
    corrections, including the genetic-value `@return` and parameter
    descriptions, dataset titles and descriptions, and the `@examples`
    for `getPedDirectRelatives()`, `cumulateSimKinships()`, and
    `getIdsWithOneParent()`.
  - Documentation: the example configuration file
    (`inst/extdata/example_nprcgenekeepr_config`) now documents that
    `lkPedColumns` is center-specific: SNPRC uses the flat `dam`/`sire`
    columns (direct columns) while ONPRC uses the `Id/parents/dam`
    lookup-traversal form (curated parentage).
  - Fixed a CRAN Policy violation: the Shiny application no longer
    writes a debug log file to the user's home directory unconditionally
    at startup. The log file is now created only after a user explicitly
    enables the Input tab's "Debug on" checkbox, matching the documented
    behavior.
  - Fixed a data-corruption bug: uploading a pedigree as an Excel
    workbook via the Input tab silently converted every alphanumeric
    sire/dam ID to a missing value, collapsing the pedigree to
    near-all-founders with no error or warning shown to the user. CSV
    and tab/comma-delimited text uploads were unaffected.
  - Fixed the Breeding Groups tab's "Custom" sex ratio option: selecting
    it previously had no numeric input to specify the ratio and silently
    behaved identically to "None". A numeric "Custom ratio (F per M)"
    field now appears when "Custom" is selected, and its value is used
    when forming groups.
  - Fixed the Breeding Groups tab's "Number of top animals" field: it
    never appeared regardless of the selected animal source, including
    the default "Top ranked" selection where it is supposed to be
    visible on page load.
  - `data(examplePedigree)` now includes a `fromCenter` (colony-origin)
    column, derived from its existing `origin`/`recordStatus` fields, so
    the Potential Parents tab can show a populated result (1,587
    candidates) against the package's own example data instead of only
    its graceful-degradation message.

# nprcgenekeepr 1.0.8 (20250723)

- Minor changes
  - Added returned value descriptions for all functions within R
    directory where formerly missing.
  - Changed unit test for `get_elapsed_time_str()` to use a mocked
    version of `proc.time()`

# nprcgenekeepr 1.0.7 (20250506)

- Minor changes
  - Added returned value descriptions for all functions where formerly
    missing.
  - Removed extraneous spaces from DESCRIPTION file.
  - Exposed all examples in roxygen2 comments by removing and and . The
    example with `runGeneKeepR()` is protected with
    `if (interactive()) {}`.

# nprcgenekeepr 1.0.6 (20241215)

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
  - Made `getVersion()` more robust.
  - Abstracted out removal of auto generated Ids in preparation of
    allowing the user to define how auto generated Ids will be formed.
  - Added some quality assurance badges to README.
  - Added CRAN status badge to README.
  - Stopped using travis-ci and started using GitHub Actions with
    Rhub.yaml file for checking on Rhub.

# nprcgenekeepr 1.0.5.9004 (20221213)

- Minor changes
  - Changed method used to test class of object to use inherits().
  - Corrected `getPedDirectRelative()` so that all direct relatives are
    found. Supplemented unit tests for more direct relative types.
  - Added unit tests for `trimPedigree()`.
  - Changed call `as.character(date_object)` to `format(date_object)` in
    getDatedFileName.R to prepare for newer code in development version
    of
    18. 
  - Technical edits of R code based on `lintr::lint_dir("R")`

# nprcgenekeepr 1.0.5.9003 (20220625)

- Minor changes
  - Removed dependency on gdata.
  - Removed `getMinParentAge()` as it was never used.
  - Starting to replace `rbind()` with `rbindlist()` from `data.table`
    were possible.

# nprcgenekeepr 1.0.5.9002 (20220425)

- Minor changes
  - Added use of data.table in an effort to reduce memory use and CPU
    use for estimation of kinship values.
  - Functions were refactored and the ability to handle larger
    simulations resulted.

# nprcgenekeepr 1.0.5.9001 (20210830)

- Major changes
  - Added ability to use simulation to estimate the kinship values of
    animals with incomplete parental information that are known to have
    been born within the colony. These animals may have 0 or 1 known
    parents but have a value in the pedigree file or database for the
    *fromcenter* or *fromCenter* field of "Y", "YES", "T", or "TRUE".
- Minor changes
  - Increase unit test coverage primarily to include more rare events
    and events that should not happen and are trapped and result in
    errors.
  - Changed to travis-ci.com

# nprcgenekeepr 1.0.5 (20210328)

- Major changes -- none
- Minor changes
  - CRAN submission primarily in response to a change in `shiny 1.6`
    that removed an internal `shiny` function (`shiny:::%OR%`) and
    replaced it with `rlang::%||%`
  - Stale URL in historical documentation that were causing notes to be
    generated in automated tests have been removed.
  - A URL referring to Terry Therneau's page was updated from "http" to
    "https".
  - I have incremented the version from 1.0.4 (github.com only version)
    to 1.0.5, updated NEWS to reflect the changes, and updated all
    documentation to reflect the version change.

# nprcgenekeepr 1.0.4.9003 (20210318)

- Major changes -- none
- Minor changes
  - Testing .travis.yml code change to get textshaping to build on all
    systems..
  - Cleaned up .travis.yml in response to syntax checking on travis.org.
  - Added `markdown` to suggest due to new changes in `knitr`.

# nprcgenekeepr 1.0.4 (20210318)

- Major changes -- none
- Minor changes
  - Added suppression of warnings from DT at beginning of server.R since
    it is unlikely for anyone to call affected functions in the
    controlled environment.
  - Changed call to shiny:::`%OR%` to rlang::`%||%` in server.R since
    the update to 1.6 of shiny broke the code. Thanks to Dan Metzger of
    Wisconsin National Primate Research Center.

# nprcgenekeepr 1.0.3 (20200526)

- Major changes -- none
- Minor changes
  - CRAN re-submission: responded to the two requests provided by
    reviewer
    - I have removed the capitalization from "Genetic Tools for Colony
      Management" and "Genetic Value Analysis Reports" within
      DESCRIPTION.
    - I have removed the conditional installation of DT from the ui.R
      file.
  - I have incremented the version from 1.0.2 to 1.0.3, updated NEWS to
    reflect the changes, and updated all documentation to reflect the
    version change.

# nprcgenekeepr 1.0.2 (20200517)

- Major changes -- none
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
      - `getFocalAnimalPed()`, which is dependent on a valid LabKey
        instance, a proper configuration file, and a .netrc or \_netrc
        authentication file.
    - I have exchanged dontrun for donttest for the following examples:
      - `create_wkbk()`
      - `createPedTree()`
      - `findLoops()`
      - `countLoops()`
      - All 11 examples in data.R
      - `makeExamplePedigreeFile()`

# nprcgenekeepr 1.0.1 (20200510)

- Major changes -- none
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
    - Checking (--as-cran --run-donttest) Duration: 2m 21.8s on my
      system.
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

# nprcgenekeepr 1.0 (20200415)

- Major changes -- none
- Minor changes
  - CRAN submission

# nprcgenekeepr 0.5.43 (20200414)

- Major changes -- none
- Minor changes
  - Final preparation for CRAN submission

# nprcgenekeepr 0.5.42.9012 (20200412)

- Major changes -- none
- Minor changes
  - Updated unit test for dataframe2string to account for change in age
    of a sire from 8.67 to 8.66 years.
  - Renamed tutorials.

# nprcgenekeepr 0.5.42.9011 (20200409)

- Major changes -- none
- Minor changes
  - Build failed on Travis-ci due to unit test failure but the test has
    never failed and does not fail on other builds. Removed set_seed()
    to see if that helps.
  - Fixed GitHub issue 3
  - Added additional explanatory text from Matt Schultz edits for the
    Colony Manager version of the Shiny tutorial.

# nprcgenekeepr 0.5.42.9010 (20200405)

- Major changes -- none
- Minor changes
  - Added code to address issue 1 (GitHub). See comment 1 for details,
    but more should be done.
  - Refreshed Shiny_app_use.Rmd to reflect changes since November 2019.

# nprcgenekeepr 0.5.42.9009 (20200402)

- Major changes -- none
- Minor changes
  - Wrapped example for `makeExamplePedigreeFile` with `\dontrun{}`
    because R 4.0.0 alpha was leaving the side effect of the dataframe
    stored in a CSV file named as the text of the next line.

# nprcgenekeepr 0.5.42.9008 (20200321)

- Major changes -- none
- Minor changes
  - Changed dependency to R \>= 3.6 since caTools is not available for R
    \< 3.6.

# nprcgenekeepr 0.5.42.9007 (20200319)

- Major changes -- none
- Minor changes
  - Changed warnings unit test for getLkDirectAncestors to work with
    Windows.

# nprcgenekeepr 0.5.42.9006 (20200319)

- Major changes -- none
- Minor changes
  - Completed examples in function documentation
  - Corrected spelling of several word throughout found with
    `spelling::spell_check_package(".")`.

# nprcgenekeepr 0.5.42.9005 (20200201)

- Major changes -- none
- Minor changes
  - Added examples to function documentation
  - Added ColonyManagerTutorial.Rmd initial draft, which is copy of
    shiny_app_use.Rmd. It is to be converted for use by colony managers.

# nprcgenekeepr 0.5.42.9004 (20200201)

- Major changes -- none
- Minor changes
  - Added examples to function documentation
  - Added obfuscated rhesus pedigree and rhesus haplotypes to use in
    examples

# nprcgenekeepr 0.5.42.9003

- Major changes -- none
- Minor changes
  - Renamed local and remote repositories from nprcmanager to
    nprcgenekeepr.

# nprcgenekeepr 0.5.42.9002

- Major changes
  - Changed name of package to nprcgenekeepr. This required changing of
    many of the supporting files and functions. Having good unit test
    coverage of the functions (739 test with \> 90 percent coverage)
    made this possible.
  - This is the last version under the nprcmanager repository name.
  - Conversion worked
    - Running the build check had OK: 739; Failed: 0; Warnings: 0;
      Skipped: 0
- Minor changes -- none

# nprcmanager 0.5.42.9001

- Major changes -- none
- Minor changes
  - Adding small executable examples in `roxygen2` comments that will go
    into the Rd-files. Since I have tests, I am wrapping the examples in
    .
  - Added code prior to changing `par()` in *getPyramidPlot.R* to reset
    `par()` with  
    `opar <- par(no.readonly =TRUE)`  
    `on.exit(par(opar))`  
  - Removed the word "Implements" from the title.
  - Reworded the first sentence of the Description element and therein
    removing "implements" and "nprcmanager" as unnecessary words.
  - Added single quotes around all package, software, and API names
    within the Description element of the DESCRIPTION file.

# nprcmanager 0.5.42.9000

- Major changes
  - Added ability to export genetic summary statistic plots
- Minor changes -- none

# nprcmanager 0.5.42 (20191208)

- CRAN submission
- Move output of suspicious parent list from the user's home directory
  to the result of `tempdir()`.

# nprcmanager 0.5.41 (20191130)

- CRAN submission.

# nprcmanager 0.5.40.9002 (20191119)

- Tried to get vignette for shiny application to find images on all
  building platforms by adding "./" to relative path.

# nprcmanager 0.5.40.9001 (20191115)

- Added unit test for **create_wkbk** from
  github.com/rmsharp/rmsutilityr
- Fixed bug in Genetic Value Analysis tab were failure to remove all
  white space in Filter View Id window did not clear filter.
- Changed minimum parent age default from 4 to 2 years.
- Added ability to download founders in a *maleFounders.csv* file and a
  *femaleFounders.csv* file.
- Added **createExampleFiles** and **saveDataframesAsFiles** to allow
  the user to generate all of the example pedigrees and other files used
  in testing and in tutorials.
- Removed **Development_Plans.Rmd** from build because it has has been
  replaced by adding issues on our GitHub issue tracker.

# nprcmanager 0.5.40.9000 (20191115)

- Corrected bug in **addIdRecords** to handle *NA* characters; amended
  its unit tests to check for correct behavior
- Changed name of **sexRatioWithAddions** to
  **getSexRatioWithAdditions**

# nprcmanager 0.5.39 (20191115)

- Moved vignettes to expose them in GitHub Pages.
- Removed more unneeded files from package.

# nprcmanager 0.5.38 (20191113)

- Changed **getBreederPed** function to **getFocalAnimalPed** and
  animals read in by that function from **breeders** to **focalAnimals**

# nprcmanager 0.5.37 (20191108)

- Working on updating documentation

# nprcmanager 0.5.36 (20191106)

- Added colorIndex to list returned by getIndianOriginStatus(),
  getProductionStatus(), and getProportionLow(). Updated related unit
  tests
- Changed getSiteInfo() to reflect ONPRC's query structure
- Changed .Rbuildignore to leave out .png image files needed for Shiny
  tutorial.

# nprcmanager 0.5.35 (20191013)

- Corrected calculateSexRatio and updated unit test
- Modified getProductionStatus to match new definition and added unit
  tests

# nprcmanager 0.5.34 (20191006)

- Added code to filter out animals no longer at institution and without
  birth date.

# nprcmanager 0.5.33 (20191006)

- Broke up LICENSE contents into LICENSE and LICENSE.md for CRAN
  compliance

# nprcmanager 0.5.32 (20191004)

- Corrected ancestry to sexCodes in test_convertSexCodes()

# nprcmanager 0.5.31 (20191003)

- Added more tutorial notes
- Removed undefined elements in DESCRIPTION file including Displaymode:
  Showcase, which is recommended in a Shiny example by RStudio. This was
  removed based on RHUB feedback.
- Added more code for genetic diversity dashboard.

# nprcmanager 0.5.30 (20190829)

- Began adding code for the genetic diversity dashboard. This includes
  the functions **getIndianOriginStatus** and **getProportionLow**, and
  a rudimentary **makeGeneticDiversityDashboard** function.
- Added another obfuscation function **mapIdsToObfuscated** to further
  facilitate creation of obfuscated data. This was specifically used to
  obfuscate haplotype data Ids.

# nprcmanager 0.5.29 (20190810)

- Copied rmsutilityr functions into nprcmanager to make Publication on
  the RStudio Shiny application hosting site possible

# nprcmanager 0.5.28 (20190714)

- Added to interactive tutorial
- Enhance algorithm for creating the desired sex ratio in groups.

# nprcmanager 0.5.27 (20190713)

- Added to interactive tutorial
- Minor corrections of function documentation
- Moved *updateProgress* parameter to end of list for
  **groupAddAssign()**.

# nprcmanager 0.5.26 (20190707)

- Updated and corrected *\_software_development.Rmd*
- Corrected summary statistics descriptions
- Added expectConfigFile argument to **getSiteInfo()** and associated
  unit test to allow user to avoid a warning when configuration file is
  not expected to be present.

# nprcmanager 0.5.25 (20190701)

- Removed animals with exit dates from pyramid plots
- Added ability to retain novel column names
- Increased the number of column names understood for display in
  pedigree browser.

# nprcmanager 0.5.24 (20190630)

- Renamed resetPopulation to setPopulation
- Added sections to interactive_use_tutorial

# nprcmanager 0.5.23 (20190624)

- Added weak unit test for getGenotypes function

# nprcmanager 0.5.22 (20190624)

- Corrected and augmented unit tests for print_summary_nprcmanagGV and
  summary.nprcmanagGV

# nprcmanager 0.5.21 (20190624)

- Added unit tests for print_summary_nprcmanagGV and summary.nprcmanagGV

# nprcmanager 0.5.20 (20190622)

- Added unit test for getPedigree.

# nprcmanager 0.5.19 (20190622)

- Replaced examplePedigree which I an failed to obfuscate with an
  obfuscated version
- Added the ability to retrieve the map of original IDs to the new
  aliases to obfuscatePed.

# nprcmanager 0.5.18 (20190622)

- Replaced actual unpublished pedigree objects with obfuscated pedigree
  objects so they can be shared
- Updated unit tests that were dependent on replaced pedigree objects

# nprcmanager 0.5.17 (20190619)

- Removed old pedigree files in preparation for new custom built
  demonstration pedigrees
- Removed old, no longer used logos

# nprcmanager 0.5.16 (20190615)

- Added functions used to obfuscate pedigrees. This changes the IDs, all
  dates and age calculations while maintaining internal relational
  consistency (parent IDs correspond) and date, though different are
  similar.

# nprcmanager 0.5.15 (20190602)

- Added ability to create an example pedigree file using the
  **examplePedigree** data structure.
- Added **summary.nprcmanagGV** and **print.summary.nprcmanagGV**
  functions
- Added description of age-sex pyramid plot to the *summary of major
  functions*.

# nprcmanager 0.5.14 (20190518)

- Added ability to use Excel files as input
  - Added getGenotypes, getPedigree, getBreederPed,
    readExcelPOSIXToCharacter,
  - Added selection of Excel or Text file to uitpInput.R and modified
    other aspects to separate out the delimiter selection logic.
  - Default file type is Excel.
  - If a user selects and Excel file and an Excel file is detected, all
    file type and delimiter selections are ignored and the Excel file is
    used and no error or warning is given.
- Improved checkRequiredCols, toCharacter and getDatedFileName functions
- Exported set_seed. This will be moved into rmsutilityr
- Removed erroneous toCharacter documentation
- Added set_seed
  - Tried unsuccessfully to use the RNGkind function and the sample.kind
    argument to set.seed, but found neither existed prior to R 3.6.
  - Created a R version sensitive version of set_seed that duplicates
    the pre-R version 3.6 set.seed function. This is only useful for
    creating data structures for testing purposes and should not be used
    to set seeds for large simulations

# nprcmanager 0.5.13 (20190508)

- Updated unit tests that were using set.seed to use a R version
  sensitive set.seed wrapper.

# nprcmanager 0.5.12 (20190507)

- Updated nprcmanager.R to add **Pedigree Testing** and **Plotting**
  function lists.

# nprcmanager 0.5.11 (20190430)

- Changed wording and format above Suspicious Parent table in ErrorTab
- Removed row label from Suspicious Parent table
- Updated meeting notes

# nprcmanager 0.5.10 (20190428)

- Corrected roxygen2 comment "@export" in getAnimalsWithHighKinship().
- Added unit test for fillGroupMembersWithSexRatio()

# nprcmanager 0.5.09 (20190428)

- Corrected bug where parents with suspicious dates were not being
  reported.
- Improved display of parents with suspicious dates by outputing HTML
  table to the ErrorTab.

# nprcmanager 0.5.08 (20190418)

- Minor rewording of option label on breeding group formation tab

# nprcmanager 0.5.07 (20190408)

- Rearranged and reformatted breeding group formation tab

# nprcmanager 0.5.06 (20190407)

- Changed spelling of gu.iter and gu.thresh to guIter and guThresh

# nprcmanager 0.5.05 (20190406)

- Fixed all but one bug associated with having multiple dynamically
  generated seed animal groups.
- Added global definition of MAXGROUPS, which is current set as 10 and
  allows up to six seed animal groups.
- Corrected test_fillBins, which was erroneously using a current date
  instead of a fixed date for calculating age.

# nprcmanager 0.5.04 (20190225)

- Adding ability to have up to six seed animal groups.
- Added conditional appearance of Make Groups action button that is
  dependent on the user having select on of the optional group formation
  workflows.

# nprcmanager 0.5.03 (20190215)

- Adding new version of breeding group formation UI and related server
  code.

# nprcmanager 0.5.02 (20190103)

- Added ability to specify sex ratio in increments of 0.5 (Female/Male)
  from 0.5 to 10 in increments of 0.5.

# nprcmanager 0.5.01 (20181230)

- Correction of some bugs in harem creation and provided additional unit
  tests for harem creation to prevent regression.

# nprcmanager 0.5.00 (20181228)

- First draft with harem group creation working.
  - Fails if more than one potential sire (male and at least of minimum
    age) is in the current group.
  - Fails if there are insufficient males to have one per breeding group
    being formed.
  - Requires the user to provide males in the candidate set that are
    appropriate for breeding as the current code does not check to
    ensure the animals are still alive. This could easily be added.
  - Males are selected for each group randomly at each iteration just as
    are all other members. The only difference between animal selection
    for harems is that sex is part of the selection process.
  - This required the creation of a few functions and modification of
    others. Unit tests were updated to reflect changes, but not
    additions. New unit tests are needed.
  - The format of the breeding group creation page must be improved.
  - The changes made and the new unit tests will serve to simplify
    adding the sex ratio criterion to breeding group formation.

# nprcmanager 0.4.23 (20181226)

- Added code to detect LabKey connection failure and report it on an
  Error tab

# nprcmanager 0.4.22 (20181224)

- Minor text changes to Input tab. Refactored groupAddAssign function to
  have a function create the return list.

# nprcmanager 0.4.20 (20181222)

- Refactor of **groupAddAssign** function by extracting much of the
  function into separate functions. One such function,
  **fillGroupMembers** isolates the group formation code to allow adding
  the ability to satisfy sex ratio requirements and harem creation.

# nprcmanager 0.4.19 (20181217)

- All minor interface changes
  - Substituted hovertext for description of minimum parental age
  - Added meeting notes for 20181210 meeting
  - Changed label on button controlling reading of pedigree information
  - Updated logo
- Added code of conduct file.
- Corrected license text

# nprcmanager 0.4.18 (20181210)

- Added unit test for removing animals added to pedigree because they
  are unknown parents

# nprcmanager 0.4.17 (20181208)

- Changed error reporting so as not to report as an error the wrong sex
  when animals are added into the pedigree and appear as both a sire and
  dam without an ego record. The error report now indicates these are
  both a sire and a dam. Done 20181208
- Made a combined logo for Oregon and SNPRC. Have ONPRC on top using
  blue and green. Done 20181208
- Additional unit tests to cover all of the new functions created to
  handle the PEDSYS and military formatted dates (YYYYMMDD) have been
  made. Done 20181112
- Corrected breeding groups formation, which was including unknown
  animals that had been added as placeholders for unknown parents. Done
  20181119
- Hardened LabKey code by trapping a bad base URL in the configuration
  file with a tryCatch function and send a message to the log file. This
  needs to be tested with a working LabKey system.
