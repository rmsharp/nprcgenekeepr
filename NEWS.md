NEWS
================
R. Mark Sharp, Ph.D.

# nprcgenekeepr 2.0.0.9000 (development version)

This release expands `nprcgenekeepr` beyond pedigree management and
genetic value analysis. It adds interactive pedigree diagrams,
marker-based genetic analysis, MHC haplotype reporting, cross-center
identity matching, ancestry-aware breeding safeguards, de-identified
export workflows, and longitudinal monitoring of colony genetic health.

## Pedigree Diagram

**Major**

- The Pedigree Browser has a new interactive **Diagram** view. It
  follows most kinship2 drawing conventions: sex symbols, mate lines
  with children descending from the midpoint, dashed links between
  repeated individuals, separate blocks for unrelated families, shaded
  affected individuals, twin connectors, and a thicker colored mate line
  for consanguineous matings. The comparison article checks by code that
  the same individuals and the same parent-child and mate relationships
  appear as in kinship2; the layouts themselves are not identical. A
  deceased marker and more than one affected condition are not drawn.
- Click an animal to re-center the diagram. You can also pan and zoom,
  hover for details, and search for an id to highlight it. A legend
  explains the sex symbols, and **Export Diagram (PNG)** saves an image.
- **Diagram Edge Style** switches between "Rectilinear (kinship2-style)"
  right-angle connectors (the default) and "Direct" straight lines.
  Rectilinear connectors are routed around unrelated animals. On crowded
  pedigrees some still cross a symbol, and the layout warning says how
  many.
- An optional `affected` column shades affected individuals. Unaffected
  and unknown-status individuals, and everyone when the column is
  absent, are drawn open.
- An optional `name` column shows names beside ids, with a **Show Names
  on Diagram** toggle. De-identified exports remove names. Twin
  connectors (identical, fraternal or unknown zygosity) follow
  kinship2's twin codes.
- Consanguineous matings are detected automatically, with no extra
  column, and drawn with a thicker, distinct-colored mate line in both
  styles.
- A pedigree above the display limit shows a message instead of a
  diagram: 400 animals with the default "Rectilinear" style, 750 with
  "Direct". Trim to fewer focal animals to bring it back under the
  limit.

**Minor**

- Animals with no recorded parents, mates or offspring are left out, as
  in kinship2. The diagram names them, and shows a message when none of
  the loaded animals have relationships.
- The diagram puts the male parent on the left of a mated pair in most
  cases. A parent with several mates is placed to fit the family layout,
  so those pairs can appear either way round. A mating symbol sits
  centered between its parents with clear gaps, so symbols do not
  overlap even in large pedigrees (diagrams are correspondingly wide;
  pan and zoom). Placement does not depend on regional settings.
- A parent who anchors matings at more than one generation appears as a
  duplicate node (113 individuals in the bundled 375-animal example
  pedigree). A mate who also belongs to another family appears as a
  duplicate marker beside their partner, as in kinship2, so the pair and
  their children stay directly above and below one another.
- Branches from different founders are ordered so that branches sharing
  animals sit near each other, which shortens the curved connectors
  between an animal's repeated appearances. A parent with recorded
  children but no row of their own is drawn normally, including in
  trimmed pedigrees.
- `makePedigreeMatingLayout()` has no `orderBySex` argument and accepts
  an optional `kinshipMatrix`, an already-computed kinship table to
  reuse when flagging consanguineous matings.
- Five small example pedigrees (`example_pedigree_*.csv` in
  `extdata/examples`) show classic mating structures: brother-sister,
  linebreeding, a daughter bred to her sire, first cousins, and
  half-siblings sharing a sire. Each has 11-14 animals and one
  consanguineous mating; the Pedigree Diagram article walks through
  them.

## Kinship & Pedigree Calculations

**Major**

- Animals declared as identical (MZ) twins now have their relatedness
  corrected to genetic identity, and the correction passes to relatives
  of either twin.
- A twin/zygosity file uploaded on the Diagram tab applies this
  throughout the app, whichever tab is opened first. Fraternal and
  identical pairs must share both recorded parents, and identical pairs
  must be the same sex.
- Script users: `kinship()`, `reportGV()`, `gvaConvergence()`,
  `createSimKinships()` and `cumulateSimKinships()` take
  `twinRelations`. `readTwinRelations()`, `checkTwinRelations()` and
  `obfuscateTwinRelations()` read, validate and de-identify the file
  (columns `id1`, `id2`, `code`).
- New `shrinkPedigree()` trims a large pedigree to the animals needed to
  stay informative within a genotyping budget, optionally keeping
  affected animals. Results repeat from run to run, unlike kinship2's
  equivalent, which breaks ties randomly. Script only.

**Minor**

- `kinship()` computes X-chromosome relatedness with `chrtype = "x"`
  (needs `sex`); the default is unchanged. Script only.

## Marker Genetics

**Major**

- New **Marker Genetics** tab (issue \#130). **Kinship Comparison**
  compares DNA-based with pedigree-based relatedness.
- **Heterozygosity** compares each animal's diversity with the
  population expectation.
- **Parentage Exclusion** flags a recorded parent that the DNA
  contradicts.
- **Candidate Parent Assignment** ranks genotyped animals that could be
  a flagged animal's real parent. Report only (issue \#147).
- **Cross-Center** compares diversity between two centers. It is not the
  **Cross-Center Identity** tab below, which merges individual records.
- **Linkage and LD Block Metrics** combines the locus-coverage,
  relatedness-variance and linkage-block reports below, with
  de-identified export (issue \#153).
- **Genomic ROH (F_ROH)** shows the sequence-based inbreeding
  calculation below, with de-identified export via
  `obfuscateGenomicROH()` (issue \#152).
- Script users: `markerObservedHeterozygosity()` and
  `markerExpectedHeterozygosity()`; `markerParentageExclusion()`, which
  flags a parent when more than `maxExclusions` loci (default 2)
  conflict; `markerFst()`, Hudson's Fst per locus and pooled; and
  `markerParentageLikelihood()`.

**Minor**

- `checkMarkerGenotypeFile()` checks a genotype file with one row per
  animal and locus (`id`, `locus`, `allele1`, `allele2`) and rejects a
  locus with more than two alleles; `buildMarkerGenotypeMatrix()` turns
  it into the animal-by-locus table the marker functions use.
- The Candidate Parent Assignment suggestion covers the common case
  where a flagged animal's recorded parent is present but wrong (issue
  \#155).
- `checkLocusMetadata()` reports each locus's chromosome and position
  data as complete, partial or missing.
  `checkLinkageMarkerGenotypeFile()` accepts panels with more than two
  alleles per locus, such as microsatellites.
- `markerRealizedRelatednessVariance()` estimates how far DNA-based
  relatedness can vary around the pedigree prediction. `markerLdBlock()`
  and `obfuscateLdBlocks()` report and de-identify linked marker blocks
  (issue \#153).
- `checkSequenceGenotypeFile()`, `computeGenomicROH()` (inbreeding from
  runs of homozygosity) and `obfuscateGenotypeMatrix()` support
  sequence-scale genotype files, and `markerKinship()` and
  `markerParentageLikelihood()` are optimized for large panels (issue
  \#152).

## MHC Haplotype Reporting

**Major**

- New **MHC Haplotype Reporting** tab: upload haplotype designations to
  see how common each haplotype is, which are rare, and which animals
  carry them. Every animal in the file must be in the loaded pedigree
  (issue \#148).
- Rarity thresholds are adjustable next to the tables. After you
  confirm, you can download a de-identified summary, carrier list and
  settings record.
- `mhcHaplotypeFrequency()` gives copies, carriers and frequency per
  haplotype, and discloses missing and provisional calls. A haplotype is
  rare at frequency 0.01 or lower, or with 2 or fewer carriers; both
  thresholds are adjustable.
- `mhcHaplotypeCarriers()` lists the animals carrying each rare (or
  every) haplotype, including provisional carriers.

**Minor**

- `checkMhcHaplotypeFile()` validates a file with two named haplotypes
  per animal (a trailing `?` marks a provisional call);
  `obfuscateMhcHaplotypes()` replaces carrier-list ids with the
  pedigree's de-identification aliases and stops on an id it never
  covered.
- The frequency column shows four decimal places on screen; downloads
  keep the exact values.

## Cross-Center Identity Matching

**Major**

- New **Cross-Center Identity** tab: walks a curator through matching
  and merging records from two centers, with a preview and downloadable
  results behind a confirmation step (issue \#149).
- `resolveCrossCenterIds()` merges records for the same animals using a
  curator-confirmed id-matching table, preserving each animal's own data
  columns.

**Minor**

- `checkCrossCenterMapping()` reports every problem in an id-matching
  table at once.

## Genetic Value Analysis

**Major**

- Fixed: unchecking "Display Unknown IDs" in the Pedigree Browser no
  longer stops the Genetic Value Analysis with a "logic error". The box
  hides rows only in the Pedigree Browser table; every other tab uses
  the full pedigree ("Trim pedigree based on focal animals" still
  narrows it).
- Configurable **Ranking Scheme**: a priority-tier ranking alongside the
  combined kinship/uniqueness score (issue \#125).
- Script users: `reportGV()` takes `guCutoff`, `zScoreCutoff` and
  `axisPriority`.

**Minor**

- Summary Statistics gained **Skewness** and **Kurtosis** (issue \#126;
  script: `calcSkewness()`, `calcKurtosis()`).
- The rankings table gained a **flagged** column for animals whose
  ranking correction could not be applied for lack of a comparable peer
  group (issue \#127).

## Breeding Group Formation

**Major**

- Several candidate groupings are shown per run, with a selector and
  comparison table (issue \#125). **Candidates to retain** sets how many
  are kept (default 5, 1 to 50). Script users: `groupAddAssign()`
  returns a `candidates` field and takes `maxCandidates` (issue \#146).
- Formation can follow your center's ancestry rules (issue \#168).
  Upload a rules file in the new **Ancestry Guardrails** section; each
  line names two ancestry groups (for example Indian-origin and
  Chinese-origin rhesus) and says whether mixing them is blocked or only
  flagged. Blocked pairs never share a group, in every formation mode;
  flagged pairs form freely and are pointed out afterward. Without a
  rules file, formation is unchanged.
- A block rule can be overridden for your session through a confirmation
  step that requires a written reason. Overridden pairings stay in the
  violations list, marked "overridden". A downloadable audit record
  lists the rules in effect, overrides with reasons, and the warning
  shown.
- Caveat: in harem formation the automatically chosen sire is not
  checked against the rules (his groupmates are checked against each
  other).

**Minor**

- New **Include animals by** control: a genetic-value floor as an
  alternative to the top-N cutoff (issue \#128).
- New **Exhaustive enumeration mode**: lists every maximal group that
  can be housed together, for the simplest case only (one group, no
  harem, no custom sex ratio). It stops with a message above 20 eligible
  animals and returns what it has found after 10 seconds. Script users:
  `exhaustive`, `maxExhaustiveCandidates` and `exhaustiveTimeLimit`
  (issue \#146).
- A status line shows the loaded rules (for example "2 block, 2 flag
  rule(s)") and how many animals no rule reaches; a file problem is
  reported and ignored, and a pedigree without ancestry information
  leaves the guardrails inactive. A new **Ancestry** results tab lists
  matched pairings with a coverage summary.
- Script users: `readAncestryRules()`, `checkAncestryRules()`, the
  `ancestryRules` argument of `groupAddAssign()`, and
  `reportAncestryViolations()` for existing groups. An example rules
  file and pedigree ship with the package.

## Mate Pair Analysis

**Major**

- New **Mate Pair Analysis** tab: a curator view built on the report
  below, separate from Breeding Group Formation (issue \#151).
- Mate pair reports can follow your ancestry rules (issue \#169). Rules
  loaded on the Breeding Groups tab apply here: a "block" pair moves to
  Excluded with the reason "ancestry rule", and a "flag" pair stays in
  Eligible Pairs with its rule shown, in the export too.
- **Override rule...** with a written reason keeps a rule's pairs in
  Eligible Pairs, marked "overridden".
- The **Ancestry** tab shows coverage, and **Download Audit Manifest**
  saves the rules, overrides with reasons, pair counts and the
  confirmation warning.
- The **Excluded** tab has an **Export Excluded Pairs** button that
  saves the blocked pairs, with their reasons, as a CSV file. Like the
  Eligible Pairs export, it holds exactly the rows left after any search
  or filter.
- Script users: `reportMatePairs()` takes `ancestryRules` and
  `overriddenRules`. Without rules or an ancestry column, nothing
  changes.

**Minor**

- `reportMatePairs()` reports mate-pair candidates with relatedness and
  genetic-value context. Report only (issue \#151).

## De-Identified Export

**Major**

- New **De-Identified Export** tab: a preview on request and three
  downloads (the de-identified pedigree, a record of changes, and a
  private re-identification key) behind a confirmation step (issue
  \#150).

**Minor**

- `obfuscatePed()` gained **linkedDateShift** (default `TRUE`): all of
  one animal's dates move by the same offset, so the gaps between them
  stay realistic (issue \#150).

## Longitudinal Monitoring

**Major**

- Colony managers can keep a history file of dated colony snapshots, one
  row of colony-level genetic-health values per date, to see whether
  genetic health is improving or eroding (issue \#167).
- Script users: `readSnapshotHistory()`, `checkSnapshotHistory()` and
  `appendColonySnapshot()`; an example history ships.
- New **Genetic-Health Trends** tab: upload or start a history, record a
  snapshot from the genetic value analysis you just ran, view trend
  plots, and compare two dates. Histories and comparisons can be
  downloaded.
- Snapshots recorded under different settings or software versions are
  flagged, so a jump is not mistaken for a real change in the colony.

**Minor**

- `createColonySnapshot()` records a finished analysis's results,
  population make-up and settings in one dated row, and refuses a
  snapshot whose stated animal-membership rule (whole pedigree or focal
  population) does not match the animals analyzed.
- `plotSnapshotTrends()` draws each value over time, with uncertainty
  for values from repeated random sampling, and `calcSnapshotDeltas()`
  lists changes between two dates; both flag differing settings or
  software versions.

## General Fixes

**Major**

- Fixed: loading an ancestry rules table that is valid but has no rules
  made Download Audit Manifest fail with an error on both the Mate Pair
  and Breeding Groups tabs. A table with no rules now counts as no rules
  in effect: the download works, and its single row says that no
  ancestry rules were in effect for the run.

- Fixed: a breeding group with no breeding-age females was shown as a
  green Production cell in the Genetic Diversity dashboard, as healthy
  as a group that meets its birth target. Production cannot be
  calculated for such a group, so its cell is now gray, as the
  Inbreeding cell already was.

- Fixed: forming breeding groups that include animals with no birth
  date, after running the genetic value analysis, could turn the page
  gray and end the session (the shipped example pedigree does this with
  the default settings). A male with no birth date is now left out of
  the Inbreeding count of potential mates, a female with no birth date
  is counted as described in the next entry, and a problem while the
  Genetic Diversity heat map is being worked out no longer ends the
  session.

- Fixed: in the Genetic Diversity dashboard, a female with no birth date
  was always counted as a breeding-age female in the Production cell,
  whether or not she had any offspring, which lowered Production. In
  both the Production and the Inbreeding cells she now counts only when
  the pedigree lists an offspring for her, wherever that offspring is; a
  female with no birth date and no offspring is left out of both. A
  group whose only female is left out has no Production value, so its
  cell is gray. A note under the heat map now says how many animals in
  the groups have no birth date, and how many of those females were
  counted or left out.

- Fixed: the column names above the Genetic Diversity heat map were
  slanted and cut off by the top edge of the picture (they read "Va",
  "Or", "Pro" and "Inb"), and both the column names and the group names
  were too small to read comfortably. The names are now written level,
  in bold and whole, at 2.5 times the old size.

- New: the Input tab now warns when animals in the uploaded pedigree
  have no birth date. The app shows its yellow warning notice and opens
  the Warnings tab, which says how many animals have none (1,432 of
  3,694 in the shipped example pedigree) and that their age is unknown,
  so age-based checks and counts, such as the parent-age check, the
  Age-Sex Pyramid and the breeding-age counts, cannot use them. It is
  only a warning: the pedigree can still be used.
  `runQcStudbook(reportChanges = TRUE)` returns the same warning.

- Fixed: a real animal whose id starts with a capital U (such as `U1`,
  `U123` or `Uma`) was mistaken for a stand-in for an unknown parent, so
  it was left out of founder and breeder counts, hidden when "Display
  Unknown IDs" was off, and its offspring were shown with an unknown
  parent. Only ids shaped like a stand-in -- a U followed by at least
  four capital letters or digits, such as `U0001` -- are treated that
  way.

- New `placeholder` column: the pedigree check records which animals are
  stand-ins. Enter `FALSE` for a real animal whose id looks like one
  (such as `U1234`) and it is kept as real throughout, including
  Potential Parents, founder counts and the breeder counts behind
  effective population size.

- A `placeholder` value other than TRUE, FALSE, 1, 0 or blank stops the
  check and names the rows. The column survives download and re-upload,
  de-identified export and cross-center linking.

- Changed: Potential Parents (`getPotentialParents()`) lists candidates
  only for the missing parent: an animal with a recorded dam and no sire
  gets candidate sires, and the reverse. Before, a recorded dam was
  ruled out of her own animal's list, so those dam lists were never
  useful.

- New: each Potential Parents result (`getPotentialParents()`) now says
  where its dam list came from: `damBasis` is `"provenBreeder"` for
  females who gave birth near the animal's birth, `"eligibleFemale"`
  when there were none and every female old enough and present is listed
  instead, and blank when no dam is listed. The sire and dam lists
  themselves are unchanged.

- Fixed: a sire or dam whose sex was blank, misspelled or space-padded
  (such as `"M "`) was reported as a "female sire" or "male dam" and
  stopped the upload. Spaces are ignored, and a blank or unreadable sex
  is read as unknown.

- Fixed: the Shiny app read an empty cell in an uploaded CSV or text
  file as a value rather than missing, unlike Excel uploads and
  `getPedigree()`. Empty cells are now read as missing.

- The old behavior meant files with blank founder sire and dam cells
  would not load, a blank ancestry counted as OTHER instead of UNKNOWN,
  and a founder with a blank origin ranked as an import instead of
  "Undetermined".

**Minor**

- Fixed: on the Marker Genetics tab, building the de-identified export
  preview could end the session when the genotype file had an animal
  missing from the loaded pedigree or had failed its format check. The
  app now stays connected, skips the preview, and explains why next to
  the export controls.
- Fixed: the sort order of the Genetic Value Analysis tiers, the main
  pedigree table and the Breeding Group member table could vary with the
  server's regional settings; all three now sort the same way
  everywhere.
- Fixed: `removeUnknownAnimals()`, `convertDate()`, `removeDuplicates()`
  and `correctParentSex()` mishandled an animal whose record of being
  added was blank, missing or unrecognized: they could drop, skip or
  mislabel it, return an empty pedigree, or stop with an unexplained
  error. They now treat only animals recorded as added as stand-ins. The
  "Duplicate IDs found" list no longer names stand-ins that were not
  duplicated.
- Fixed: when a pedigree lists an animal as its own ancestor,
  `getAncestors()`, `findLoops()` and `countLoops()` stop with a message
  naming the animals instead of an "infinite recursion" error.
- Fixed: `getLkDirectAncestors()` no longer runs without end when a
  pedigree lists an animal as its own ancestor; it stops and returns the
  animals found. `getPedDirectRelatives()` no longer runs without end
  when a pedigree has a row with no animal id; it stops and returns the
  family, that row included.
- Fixed: `convertRelationships()` given the id of a single animal now
  returns that animal's own "Self" row instead of a meaningless row, and
  given ids that match no animal returns an empty table instead of an
  error. `makeRelationClassesTable()` returns an empty table when there
  are no pairs of different animals to count instead of stopping.
  `filterKinMatrix()` always returns a matrix, so `reportMatePairs()`
  given one animal's id returns its usual empty result instead of an
  error.
- Fixed: a stand-in id (`U0001`, `U0002`, ...) could duplicate an id a
  real animal already had. The check and `addUIds()` skip any id already
  in the pedigree, including one that appears only as a sire or dam.
- Fixed: Potential Parents rules out as dam a female who gave birth too
  close in time to have also carried this animal; when no nearby female
  was a proven breeder, the fallback let her back in. It now leaves her
  out too.
- Fixed: `reportGV()` now stops before doing any calculation, with a
  message naming every missing column, when the pedigree lacks `id`,
  `sire`, `dam`, `gen` or `sex`. A missing `id`, `sire`, `dam` or `gen`
  used to give an unexplained R error.
- Fixed: `reportGV()` and `gvaConvergence()` now stop before doing any
  calculation, with a message giving the number of animals, when the
  population of interest has fewer than 2 animals (none, or one). They
  used to stop with an unexplained R error. Ranking needs at least two
  animals to compare.
- Fixed: `calcGU()`, `calcGUSE()`, `calcA()` and `kinship()` now work
  for a single animal, and `calcFE()`, `calcFG()`, `calcFEFG()` and
  `calcFGSE()` for a population with one living descendant, instead of
  stopping with an unexplained R error. `calcGU()`, `calcGUSE()` and
  `alleleFreq()` return an empty table when given no animals or no
  alleles.

# nprcgenekeepr 2.0.0 (20260721)

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
    the Potential Parents tab can show a populated result (1,587 animals
    with an unknown parent) against the package's own example data
    instead of only its graceful-degradation message.

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
    18\.
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
    `par()` with\
    `opar <- par(no.readonly =TRUE)`\
    `on.exit(par(opar))`\
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
