# Changelog

## nprcgenekeepr 3.0.0 (20261030)

This release expands `nprcgenekeepr` beyond pedigree management and
genetic value analysis. It adds interactive pedigree diagrams,
marker-based genetic analysis, MHC haplotype reporting, cross-center
identity matching, ancestry-aware breeding safeguards, de-identified
export workflows, and longitudinal monitoring of colony genetic health.

Each app tab in these notes is explained in the [Colony Manager’s
Guide](https://rmsharp.github.io/nprcgenekeepr/articles/colony-manager-guide.html).
To reach it from the app, open the **Help** tab, follow **Online
Documentation**, and under **Articles** choose “Purpose, Approach, and a
Colony Manager’s Guide to Practice”. The guide is on the website only;
for working from a script, the installed tutorial is
[`vignette("a2interactive", package = "nprcgenekeepr")`](https://github.com/rmsharp/nprcgenekeepr/articles/a2interactive.md).

### Input

- New: the Input tab now warns when animals in the uploaded pedigree
  have no birth date. The Warnings tab counts them and says that
  age-based checks and counts cannot use them. The pedigree can still be
  used.
- New: the Input tab now warns when an animal’s death or departure date
  is earlier than its birth date, and names the first five such animals.
  The pedigree can still be used. `runQcStudbook(reportChanges = TRUE)`
  returns this warning and the one above.
- New `placeholder` column: the pedigree check records which animals are
  stand-ins. Enter `FALSE` for a real animal whose id looks like one
  (such as `U1234`) and it is kept as real throughout.
- New: with “Pedigree(s) and genotypes in one file”, the Input tab now
  reads genotypes from columns named `allele_1` and `allele_2` or
  `first_name` and `second_name` as well as `first` and `second`,
  accepts text labels as well as whole numbers, and says under the QC
  Summary which columns it read or why it read none. A file with text in
  `first` and `second` now has its genotypes used, so its Genetic Value
  results can change.
- Fixed: The Input tab lists every invalid date by row.
- Fixed: A `fromCenter` value that is not a whole yes or no stops the
  load and names its rows, in
  [`convertFromCenter()`](https://github.com/rmsharp/nprcgenekeepr/reference/convertFromCenter.md)
  and
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  too.
- Fixed: The Changed Columns tab reports only real renames, including a
  lowercase `geographicorigin`, `recordstatus` or `fromcenter` header,
  and a column named `NA` no longer stops
  [`checkRequiredCols()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkRequiredCols.md)
  or
  [`fixColumnNames()`](https://github.com/rmsharp/nprcgenekeepr/reference/fixColumnNames.md).
- Fixed: The count boxes of the QC Summary (Records Processed, Errors
  and Warnings) are colored by what the check found.
- Fixed: An id that merely starts with a capital U is no longer taken
  for a stand-in, so “Display Unknown IDs” hides only ids shaped like
  `U0001`, and a generated stand-in id never repeats a real one
  ([`addUIds()`](https://github.com/rmsharp/nprcgenekeepr/reference/addUIds.md)).
- Fixed: A sire or dam with an unreadable sex is no longer reported as a
  “female sire” or “male dam”.
- Fixed: An empty cell in a CSV or text file is read as missing, so a
  blank ancestry no longer counts as OTHER instead of UNKNOWN.
- Fixed: On Linux computers with ARM processors, a small file whose last
  value is in quotes and that has no final line break now loads.
- Fixed: With “Pedigree(s) and genotypes in separate files”, a genotype
  file the app cannot use is reported on the QC Summary (“The genotype
  file was not used, so no genotypes are used.”, with the reason) and
  the app keeps running.

### Pedigree Diagram

- The Pedigree Browser has a new interactive **Diagram** view that
  follows most kinship2 drawing conventions. The comparison article
  checks by code that the same individuals and relationships appear as
  in kinship2; the layouts are not identical.
- Click an animal to re-center the diagram. You can also pan and zoom,
  hover for details, search for an id, and save an image. Connectors can
  be right-angle, as in kinship2, or straight.
- Optional pedigree columns shade affected animals and show names.
  Deceased animals, twins and consanguineous matings are marked in the
  drawing, and a legend explains the symbols.
- A pedigree too large to draw shows a message instead, saying what to
  do.
- Script users:
  [`makePedigreeDiagramData()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeDiagramData.md),
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
  and
  [`drawPedigreeDiagram()`](https://github.com/rmsharp/nprcgenekeepr/reference/drawPedigreeDiagram.md)
  draw the Diagram from a script. Save it as a web page or put it in an
  R Markdown report.
- Five small example pedigrees show classic mating structures; the
  Pedigree Diagram article walks through them.

### Kinship & Pedigree Calculations

**Major**

- Animals declared as identical (MZ) twins now have their relatedness
  corrected to genetic identity, and the correction passes to relatives
  of either twin.
- A twin/zygosity file uploaded on the Diagram tab applies this
  throughout the app.
- Script users:
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md),
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md),
  [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md),
  [`createSimKinships()`](https://github.com/rmsharp/nprcgenekeepr/reference/createSimKinships.md)
  and
  [`cumulateSimKinships()`](https://github.com/rmsharp/nprcgenekeepr/reference/cumulateSimKinships.md)
  take `twinRelations`.
  [`readTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/readTwinRelations.md),
  [`checkTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md)
  and
  [`obfuscateTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateTwinRelations.md)
  read, validate and de-identify the file.
- New
  [`shrinkPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/shrinkPedigree.md)
  trims a large pedigree to the animals needed to stay informative
  within a genotyping budget. Script only.

**Minor**

- [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  computes X-chromosome relatedness with `chrtype = "x"` (needs `sex`);
  the default is unchanged. Script only.

### Age-Sex Pyramid

- Fixed: Download Plot saves nothing until a pedigree is loaded.

### Genetic Value Analysis

**Major**

- With no focal animals entered, the Pedigree Browser now takes the
  living animals as the population instead of every animal ever
  recorded, so the default Genetic Value rankings and founder measures
  describe the living colony. A pedigree with no living animal still
  uses every animal. Script users:
  [`setPopulation()`](https://github.com/rmsharp/nprcgenekeepr/reference/setPopulation.md)
  still flags every animal when given no IDs.
- Fixed: unchecking “Display Unknown IDs” in the Pedigree Browser no
  longer stops the Genetic Value Analysis with a “logic error”. The box
  hides rows only in the Pedigree Browser table; every other tab uses
  the full pedigree (“Trim pedigree based on focal animals” still
  narrows it).
- Configurable **Ranking Scheme**: a priority-tier ranking alongside the
  combined kinship/uniqueness score (issue
  [\#125](https://github.com/rmsharp/nprcgenekeepr/issues/125)).
- Script users:
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  takes `guCutoff`, `zScoreCutoff` and `axisPriority`.

**Minor**

- The rankings table gained a **flagged** column for animals whose
  ranking correction could not be applied for lack of a comparable peer
  group (issue
  [\#127](https://github.com/rmsharp/nprcgenekeepr/issues/127)).
- The rankings table starts with the animal ID. It used to start with an
  unlabeled column of leftover row numbers (such as 4, 5, 6, 9, 10) that
  were not the rank; the **rank** column, last in the table, still gives
  each animal’s rank.
- The Genetic Value Analysis tab no longer shows the “Calculate Genome
  Uniqueness” and “Calculate Mean Kinship” check boxes. They did
  nothing: the analysis works out both numbers whether or not they were
  ticked.
- Fixed: Founder genome equivalents, their standard error and gene
  diversity are worked out from the pedigree alone, so genotypes no
  longer make them NA.
- Fixed: An Excel file of kinship overrides works as a CSV of the same
  table does, in the app and in
  [`readKinshipOverrides()`](https://github.com/rmsharp/nprcgenekeepr/reference/readKinshipOverrides.md).
- Fixed: Genetic Value tiers and the pedigree and group tables sort the
  same way whatever the server’s regional settings.

### Summary Statistics

- New: **Skewness** and **Kurtosis** (issue
  [\#126](https://github.com/rmsharp/nprcgenekeepr/issues/126); script:
  [`calcSkewness()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcSkewness.md),
  [`calcKurtosis()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcKurtosis.md)).
- Fixed: The twelve Export pop-ups show only their sentence, with no
  `character(0)` title bar.

### Breeding Group Formation

**Major**

- Groups are formed from living animals only, whatever the **Source**,
  so the default **Top ranked** 20 are animals that can breed. An animal
  counts as alive when its Status is ALIVE (or, in a pedigree with no
  Status column, when it has no exit date). If none is alive, the tab
  says so and forms no groups.
- Several candidate groupings are shown per run, with a selector and
  comparison table (issue
  [\#125](https://github.com/rmsharp/nprcgenekeepr/issues/125)). Script
  users:
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  returns a `candidates` field and takes `maxCandidates` (issue
  [\#146](https://github.com/rmsharp/nprcgenekeepr/issues/146)).
- Formation can follow your center’s ancestry rules (issue
  [\#168](https://github.com/rmsharp/nprcgenekeepr/issues/168)). Upload
  a rules file in the new **Ancestry Guardrails** section to block or
  flag mixing of ancestry groups. A block rule can be overridden with a
  written reason, and an audit record can be downloaded. Without a rules
  file, formation is unchanged. Script users:
  [`readAncestryRules()`](https://github.com/rmsharp/nprcgenekeepr/reference/readAncestryRules.md),
  [`checkAncestryRules()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkAncestryRules.md),
  the `ancestryRules` argument of
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md),
  and
  [`reportAncestryViolations()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportAncestryViolations.md).
- A harem’s automatically chosen sire is now kept apart from his
  relatives like every other animal. An animal at or above the Max
  kinship threshold to him, or one an ancestry block rule bars from him,
  stays out of his harem; if that leaves no one, the harem is the sire
  alone. Results for a given random seed differ from earlier versions.
- With a **Custom** sex ratio, a male under the **Minimum breeding
  age**, or with no birth date, is left out of the groups and listed
  under **Unused animals**. A group stops filling when no breeding-age
  male is left for it, so it can end with fewer females than the ratio
  asks for.
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  and
  [`fillGroupMembersWithSexRatio()`](https://github.com/rmsharp/nprcgenekeepr/reference/fillGroupMembersWithSexRatio.md)
  follow the same rule. On a pedigree with such males, results for a
  given random seed differ from earlier versions.

**Minor**

- New **Include animals by** control: a genetic-value floor as an
  alternative to the top-N cutoff (issue
  [\#128](https://github.com/rmsharp/nprcgenekeepr/issues/128)).
- New **Exhaustive enumeration mode**: lists every maximal group that
  can be housed together, for the simplest case only. Script users: the
  `exhaustive` argument of
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  (issue [\#146](https://github.com/rmsharp/nprcgenekeepr/issues/146)).
- The **Source** choice “Upload list”, which had no place to give it a
  list, is now “My own list”. Paste the animal IDs into the box that
  appears. Groups are formed from those that are alive; an ID that is
  not in the pedigree stops the run and is named, and an animal that is
  not alive is left out and named.
- The last box on the **Groups** tab, which holds the animals that fit
  no group, is headed **Unused animals** instead of the next group
  number. The **Statistics** table, the **Group Detail** list and the
  **Genetic Diversity** heat map use the same name.
- Fixed: With **Harem** selected, seeding a male in some groups but not
  all no longer stops the run with “subscript out of bounds”. A group
  with a seeded male keeps him as its sire; a group with no seeded male
  is given a sire chosen at random.
- Fixed: A script that passes `harem = TRUE` and a non-zero `sexRatio`
  to
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  now stops with a message naming both settings, instead of returning
  groups of one or two animals; use one or the other.
- Fixed: A box that holds exactly one animal is headed “(1 animal)” on
  the **Groups** tab, not “(1 animals)”.
- Fixed: After you read a different pedigree or trim it on the Pedigree
  Browser, a group holding an animal that is not loaded no longer shows
  old group sizes over empty tables and a red error. The **Groups**,
  **Statistics** and **Group Detail** pages say so in one sentence and
  ask you to form the groups again or bring back the earlier pedigree.
  **Group Detail** shows no tables or **Export** buttons until then. The
  groups are kept, so bringing that pedigree back shows them again.
- Fixed: Forming groups that include animals with no birth date no
  longer ends the session after a genetic value analysis.

### Mate Pair Analysis

- New **Mate Pair Analysis** tab: a curator view of possible mate pairs
  with relatedness and genetic-value context, separate from Breeding
  Group Formation. Report only (issue
  [\#151](https://github.com/rmsharp/nprcgenekeepr/issues/151)).
- Mate pair reports can follow your ancestry rules (issue
  [\#169](https://github.com/rmsharp/nprcgenekeepr/issues/169)). Rules
  loaded on the Breeding Groups tab apply here, and a rule can be
  overridden with a written reason.
- Eligible and excluded pairs can be exported.
- Script users:
  [`reportMatePairs()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportMatePairs.md).

### Genetic Diversity

- Fixed: A breeding group with no breeding-age females has a gray
  Production cell, because Production cannot be calculated for it.
- Fixed: An undefined Inbreeding cell is red.
- Fixed: A female with no birth date and no offspring is left out of the
  Production and Inbreeding cells, and a note under the heat map gives
  the counts.
- Fixed: The heat map’s column and group names are written level, bold
  and whole, at 2.5 times the old size.
- Fixed: After focal animals are chosen, the tab scores every group with
  the whole pedigree’s kinship instead of stopping with “kmat is missing
  kinship for group member(s)”.

### Marker Genetics

- New **Marker Genetics** tab (issue
  [\#130](https://github.com/rmsharp/nprcgenekeepr/issues/130)):
  - **Kinship Comparison** compares DNA-based with pedigree-based
    relatedness.
  - **Heterozygosity** compares each animal’s diversity with the
    population expectation.
  - **Parentage Exclusion** flags a recorded parent that the DNA
    contradicts.
  - **Candidate Parent Assignment** ranks genotyped animals that could
    be a flagged animal’s real parent. Report only (issue
    [\#147](https://github.com/rmsharp/nprcgenekeepr/issues/147)).
  - **Cross-Center** compares diversity between two centers. It is not
    the **Cross-Center Identity** tab below, which merges individual
    records.
  - **Linkage and LD Block Metrics** reports locus coverage, relatedness
    variance and linked marker blocks (issue
    [\#153](https://github.com/rmsharp/nprcgenekeepr/issues/153)).
  - **Genomic ROH (F_ROH)** shows the sequence-based inbreeding
    calculation, from runs of homozygosity, with de-identified export
    (issue
    [\#152](https://github.com/rmsharp/nprcgenekeepr/issues/152)).
- Script users:
  [`checkMarkerGenotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md),
  [`buildMarkerGenotypeMatrix()`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md),
  [`markerKinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md),
  [`markerObservedHeterozygosity()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerObservedHeterozygosity.md),
  [`markerExpectedHeterozygosity()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerExpectedHeterozygosity.md),
  [`markerParentageExclusion()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageExclusion.md),
  [`markerParentageLikelihood()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageLikelihood.md),
  [`markerFst()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerFst.md),
  [`checkLocusMetadata()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md),
  [`checkLinkageMarkerGenotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLinkageMarkerGenotypeFile.md),
  [`markerRealizedRelatednessVariance()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerRealizedRelatednessVariance.md),
  [`markerLdBlock()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerLdBlock.md),
  [`obfuscateLdBlocks()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateLdBlocks.md),
  [`checkSequenceGenotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSequenceGenotypeFile.md),
  [`computeGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/computeGenomicROH.md),
  [`obfuscateGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenomicROH.md)
  and
  [`obfuscateGenotypeMatrix()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenotypeMatrix.md).

### MHC Haplotype Reporting

- New **MHC Haplotype Reporting** tab: upload haplotype designations to
  see how common each haplotype is, which are rare, and which animals
  carry them, with de-identified downloads (issue
  [\#148](https://github.com/rmsharp/nprcgenekeepr/issues/148)).
- Script users:
  [`checkMhcHaplotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMhcHaplotypeFile.md),
  [`mhcHaplotypeFrequency()`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeFrequency.md),
  [`mhcHaplotypeCarriers()`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeCarriers.md)
  and
  [`obfuscateMhcHaplotypes()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateMhcHaplotypes.md).

### Cross-Center Identity Matching

- New **Cross-Center Identity** tab: walks a curator through matching
  and merging records from two centers, with a preview and downloadable
  results behind a confirmation step (issue
  [\#149](https://github.com/rmsharp/nprcgenekeepr/issues/149)).
- Script users:
  [`checkCrossCenterMapping()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkCrossCenterMapping.md)
  checks an id-matching table and
  [`resolveCrossCenterIds()`](https://github.com/rmsharp/nprcgenekeepr/reference/resolveCrossCenterIds.md)
  merges the records.

### De-Identified Export

**Major**

- New **De-Identified Export** tab: a preview on request and three
  downloads (the de-identified pedigree, a record of changes, and a
  private re-identification key) behind a confirmation step (issue
  [\#150](https://github.com/rmsharp/nprcgenekeepr/issues/150)).

**Minor**

- [`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)
  gained **linkedDateShift** (default `TRUE`): all of one animal’s dates
  move by the same offset, so the gaps between them stay realistic
  (issue [\#150](https://github.com/rmsharp/nprcgenekeepr/issues/150)).

### Potential Parents

- Changed: Potential Parents
  ([`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md))
  lists candidates only for the missing parent: an animal with a
  recorded dam and no sire gets candidate sires, and the reverse.
- New: each Potential Parents result
  ([`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md))
  now says where its dam list came from, in `damBasis`.
- Fixed: A female who gave birth too close in time to have carried the
  animal is left out as dam.

### Longitudinal Monitoring

- Colony managers can keep a history file of dated colony snapshots, one
  row of colony-level genetic-health values per date, to see whether
  genetic health is improving or eroding (issue
  [\#167](https://github.com/rmsharp/nprcgenekeepr/issues/167)).
- New **Genetic-Health Trends** tab: upload or start a history, record a
  snapshot from the genetic value analysis you just ran, view trend
  plots, and compare two dates. Snapshots recorded under different
  settings or software versions are flagged, so a jump is not mistaken
  for a real change in the colony.
- **Build Earlier Snapshots** on the Genetic-Health Trends tab rebuilds
  a yearly history from the birth and exit dates in the studbook, so a
  trend shows without waiting for new snapshots; rebuilt points are
  drawn dashed and kept apart from recorded ones (issue
  [\#170](https://github.com/rmsharp/nprcgenekeepr/issues/170)).
- Script users:
  [`readSnapshotHistory()`](https://github.com/rmsharp/nprcgenekeepr/reference/readSnapshotHistory.md),
  [`checkSnapshotHistory()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSnapshotHistory.md),
  [`createColonySnapshot()`](https://github.com/rmsharp/nprcgenekeepr/reference/createColonySnapshot.md),
  [`appendColonySnapshot()`](https://github.com/rmsharp/nprcgenekeepr/reference/appendColonySnapshot.md),
  [`plotSnapshotTrends()`](https://github.com/rmsharp/nprcgenekeepr/reference/plotSnapshotTrends.md),
  [`calcSnapshotDeltas()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcSnapshotDeltas.md),
  [`backfillColonySnapshots()`](https://github.com/rmsharp/nprcgenekeepr/reference/backfillColonySnapshots.md)
  and
  [`previewBackfillSupport()`](https://github.com/rmsharp/nprcgenekeepr/reference/previewBackfillSupport.md).

### Speed and Memory

- The Genetic Value analysis of the shipped example (708 animals, 1,000
  iterations) takes about 0.2 seconds instead of about 3, the Summary
  Statistics relationship downloads of the whole example finish in under
  10 seconds instead of not finishing, and 1,000 Breeding Groups trials
  take about 6 seconds instead of about 23 (about 5 instead of about 27
  when forming harems). The app no longer keeps a kinship matrix of the
  whole pedigree, so it holds about 180 MB less once the example is
  loaded, and Summary Statistics no longer keeps the table of every pair
  after a relationship download (about 235 MB for the example). Results
  are the same as before for the same random seed.

- `kinship(sparse = TRUE)` takes about half a second for the whole
  shipped example (3,694 animals) instead of about 43 seconds.

- Loading the package takes about 0.4 seconds instead of about 0.9: it
  no longer loads Matrix and ggplot2, which a sparse kinship matrix or a
  plot loads when first needed.

### General Fixes

- Configuration file
  - Fixed: A line starting with `#` is a comment wherever the file is
    read, so a site that copies the example file unedited no longer gets
    the API key `paste-your-labkey-api-key-here` in place of its
    `.netrc` file.
  - Fixed: A setting written with different capitals, such as `Center`,
    is read instead of stopping with “subscript out of bounds”.
  - Fixed: A value in double quotes is one value, so a path such as
    `"/My Folder/EHR"` is not split.
  - Fixed: A setting with nothing after its `=` is empty, so an empty
    `apiKey` is no key.
  - Fixed: `data("exampleNprcgenekeeprConfig")` is the shipped example
    file.
- Installation and example files
  - Fixed: The app starts after a default install, because `shinyBS` now
    installs with the package; 2.0.0 stopped with “there is no package
    called ‘shinyBS’” until it was installed by hand.
  - Fixed: The Japanese macaque example file `deidentified_jmac_ped.csv`
    is rebuilt from a 2018 studbook (2,590 animals, 819 with a recorded
    sire) and loads once Minimum Dam Age is 3.3 or lower and Minimum
    Sire Age is 4.3 or lower.
- Script functions
  - [`removeUnknownAnimals()`](https://github.com/rmsharp/nprcgenekeepr/reference/removeUnknownAnimals.md),
    [`convertDate()`](https://github.com/rmsharp/nprcgenekeepr/reference/convertDate.md),
    [`removeDuplicates()`](https://github.com/rmsharp/nprcgenekeepr/reference/removeDuplicates.md)
    and
    [`correctParentSex()`](https://github.com/rmsharp/nprcgenekeepr/reference/correctParentSex.md)
    treat only animals recorded as added as stand-ins.
  - [`getAncestors()`](https://github.com/rmsharp/nprcgenekeepr/reference/getAncestors.md),
    [`findLoops()`](https://github.com/rmsharp/nprcgenekeepr/reference/findLoops.md)
    and
    [`countLoops()`](https://github.com/rmsharp/nprcgenekeepr/reference/countLoops.md)
    stop with a message naming the animals instead of an “infinite
    recursion” error when an animal is its own ancestor, and no longer
    stop with “argument is of length zero” when a parent has no row of
    its own.
  - [`getLkDirectAncestors()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectAncestors.md)
    and
    [`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)
    no longer run without end on a pedigree with an animal as its own
    ancestor or a row with no id.
  - [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
    stops before any calculation, naming every missing column, when the
    pedigree lacks `id`, `sire`, `dam`, `gen` or `sex`, and
    [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
    and
    [`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
    stop with the number of animals when the population has fewer than
    2.
  - [`convertRelationships()`](https://github.com/rmsharp/nprcgenekeepr/reference/convertRelationships.md),
    [`makeRelationClassesTable()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeRelationClassesTable.md),
    [`filterKinMatrix()`](https://github.com/rmsharp/nprcgenekeepr/reference/filterKinMatrix.md),
    [`calcGU()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md),
    [`calcGUSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md),
    [`calcA()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcA.md),
    [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md),
    [`calcFE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md),
    [`calcFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md),
    [`calcFEFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md)
    and
    [`calcFGSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFGSE.md)
    work for a single animal.
  - [`calcGU()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md),
    [`calcGUSE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcGUSE.md)
    and
    [`alleleFreq()`](https://github.com/rmsharp/nprcgenekeepr/reference/alleleFreq.md)
    return an empty table for no animals or no alleles.
  - [`create_wkbk()`](https://github.com/rmsharp/nprcgenekeepr/reference/create_wkbk.md),
    [`saveDataframesAsFiles()`](https://github.com/rmsharp/nprcgenekeepr/reference/saveDataframesAsFiles.md),
    [`makeExamplePedigreeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeExamplePedigreeFile.md),
    [`obfuscateDate()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateDate.md),
    [`obfuscateId()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateId.md),
    [`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md),
    [`withinIntegerRange()`](https://github.com/rmsharp/nprcgenekeepr/reference/withinIntegerRange.md)
    and
    [`makeGeneticDiversityHeatmap()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGeneticDiversityHeatmap.md)
    say what is wrong in their messages.
  - [`setExit()`](https://github.com/rmsharp/nprcgenekeepr/reference/setExit.md)
    finds a death or departure column in any letter case.
  - [`makeGroupNum()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGroupNum.md)
    and
    [`makeGrpNum()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGrpNum.md)
    make one group when called with no number, as their help said they
    would.
  - [`convertRelationships()`](https://github.com/rmsharp/nprcgenekeepr/reference/convertRelationships.md),
    [`makeCEPH()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeCEPH.md),
    [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md),
    [`fillGroupMembersWithSexRatio()`](https://github.com/rmsharp/nprcgenekeepr/reference/fillGroupMembersWithSexRatio.md)
    and
    [`findOffspring()`](https://github.com/rmsharp/nprcgenekeepr/reference/findOffspring.md)
    take ids given as numbers or as a factor as their text; such a
    studbook got wrong relationship names, `NA` offspring counts or a
    stopped run.
  - [`get_elapsed_time_str()`](https://github.com/rmsharp/nprcgenekeepr/reference/get_elapsed_time_str.md)
    rounds before it writes minutes and seconds.

## nprcgenekeepr 2.0.0 (20260721)

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
    the Potential Parents tab can show a populated result (1,587 animals
    with an unknown parent) against the package’s own example data
    instead of only its graceful-degradation message.

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
    of 18.
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
