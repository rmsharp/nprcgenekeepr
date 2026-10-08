# Genetic Management Tools Manual

[Introduction](#introduction)  
[Summary of Major Functions](#summary-of-major-functions)  
[Installation](#installation)  
[Running Shiny Application](#running-shiny-application)  
\[Input\]  
[Pedigree Browser](#pedigree-browser)  
[Genetic Value Analysis](#genetic-value-analysis)  
[Summary Statistics](#summary-statistics)  
[Breeding Group Formation](#breeding-group-formation)  
[ORIP Reporting](#orip-reporting)  
[Algorithm: Breeding Group
Formation](#algorithm-breeding-group-formation)  
[Algorithm: Genome Uniqueness](#algorithm-genome-uniqueness)

## Introduction

The goal of **nprcgenekeepr** is to implement Genetic Tools for Colony
Management. It was initially conceived and developed as a Shiny web
application at the Oregon National Primate Research Center (ONPRC) to
facilitate some of the analyses they perform regularly. It has been
enhanced to have more capability as a Shiny application and to expose
the functions so they can be used either interactively or in R scripts.

This work has been supported in part by NIH grants P51 RR13986 to the
Southwest National Primate Research Center and P51 OD011092 to the
Oregon National Primate Research Center.

The application’s main functions include:

1.  Quality control of studbooks contained in text files or Excel
    workbooks and of pedigrees within LabKey Electronic Health Records
    (EHR)
2.  Creation of pedigrees from a lists of animals using the LabKey EHR
    integration
3.  Creation and display of an age by sex pyramid plot of the living
    animals within the designated pedigree
4.  Generation of Genetic Value Analysis Reports
5.  Creation of potential breeding groups with and without proscribed
    sex ratios and defined maximum kinships.

The application has further tabs for mate pair analysis, genetic
diversity, marker genetics, potential parents, cross-center identity
mapping, de-identified export, and genetic-health trends. The Colony
Manager Guide article describes them.

**For more information see:**  
A Practical Approach for Designing Breeding Groups to Maximize Genetic
Diversity in a Large Colony of Captive Rhesus Macaques (*Macaca
mulatta*) Vinson, A ; Raboin, MJ *Journal Of The American Association
For Laboratory Animal Science*, 2015 Nov, Vol.54(6), pp.700-707 \[Peer
Reviewed Journal\]

## Summary of Major Functions

### Quality Control

Studbooks maintained by breeding colonies generally contain information
of varying quality. The quality control functions of the toolkit check
to ensure all animals listed as parents have their own line entries, all
parents have the appropriate sex listed, no animals are listed as both a
sire and a dam, duplicate entries are removed, pedigree generation
numbers are added, and all dates are valid dates. In addition, exit
dates are added if possible and are consistent with other information
such as departure dates and death dates. Ages are added from the birth
and exit dates when the file has valid birth dates and no age column;
the current date is used as the end point for animals with no exit date.
No database connection is needed. (A connection is used only to build a
pedigree from a list of animals with LabKey, described below.)

Parents with ages below a user selected threshold are identified. The
user can set a minimum sire age and a minimum dam age in years, and each
is used to ensure every sire or dam is at least that age on the birth
date of an offspring. Leaving a field blank uses the minimum breeding
age for the animal’s species; 2 years is used only when the species is
missing or unknown. This check is not performed for animals with missing
birth dates.

### Creation of Pedigree From a List of Potential Breeders and LabKey

The user can enter a list of focal animals in a CSV file that will be
used to create a pedigree containing all direct relatives (ancestors and
descendants) via the **labkey.selectRows** function within the
**Rlabkey** package if a database connection is provided via a
configuration file and the user has read permission on a LabKey server
with the demographic data in an **EHR** (Electronic Health Record)
module. Without a database connection, the user can instead upload a
pedigree file together with the list of focal animals, and the pedigree
of the focal animals is built from that file
([`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)).

Two configuration files are needed to use the database features of
nprcgenekeepr with LabKey. The first file is named **\_netrc** on
Microsoft Windows operating systems and **.netrc** otherwise, allows the
user to authenticate with LabKey through the LabKey API and is fully
described by [LabKey
documentation](https://www.labkey.org/Documentation/wiki-page.view?name=netrc)

The second file is named **\_nprcgenekeepr_config** on Microsoft Windows
operating systems and **.nprcgenekeepr_config** otherwise and is the
`nprcgenekeepr` [configuration
file](https://github.com/rmsharp/nprcgenekeepr/blob/master/inst/extdata/examples/example_nprcgenekeepr_config)
An image of this example configuration file is included as a data object
and can be loaded and viewed with the following lines of R code in the R
console.

### Display of an age by sex pyramid plot

Adapted from
<https://www.thoughtco.com/age-sex-pyramids-and-population-pyramids-1435272>
on 20190603. Written by Matt Rosenberg. Updated May 07, 2019.

The most important demographic characteristic of a population is its
age-sex structure. Age-sex pyramids (also known as population pyramids)
graphically display this information to improve understanding and make
comparison easy. The population pyramid sometimes has a distinctive
pyramid-like shape when displaying a growing population.

#### How to Read the Age-Sex Graph

An age-sex pyramid breaks down a population into male and female genders
and age ranges. Usually, you’ll find the left side of the pyramid
graphing the male population and the right side of the pyramid
displaying the female population.

Along the horizontal axis (x-axis) of a population pyramid, the graph
displays the population either as a total population of that age or as a
percentage of the population at that age. The center of the pyramid
starts at zero population and extends out to the left for males and
right for females in increasing size, or proportion of the population.

Along the vertical axis (y-axis), age-sex pyramids display age
increments, from birth at the bottom to old age at the top. The
application uses two-year increments by default; the **Bin Size**
control accepts 1 to 10, and **Age Unit** switches between years and
months.

### Genetic Value Analysis Reports

The Genetic Value Analysis is a ranking scheme developed at ONPRC to
indicate the relative breeding value of animals in the colony. The
scheme uses the mean kinship for each animal to indicate how
inter-related it is with the rest of the current breeding colony
members. Genome uniqueness is used to provide an indication of whether
or not an animal is likely to possess alleles at risk of being lost from
the colony. Under the scheme, animals with low mean kinship or high
genome uniqueness are ranked more highly.

### Breeding Group Formation

One of the goals in breeding group formation is to avoid the potential
for mating of closely related animals. Since behavioral concerns and
housing constraints will also be taken into account in the group
formation process, it is our goal to provide the largest number of
animals possible from a list of candidates that can be housed together
without risk of consanguineous mating. To that end, this function uses
information from the Genetic Value Analysis to search for the largest
combinations of animals that can be produced from a list of candidates.

The default options do not consider the sex of individuals when forming
the groups, though this has likely been a consideration by the user in
selecting the candidate group members. Optionally the user may select to
form harem groups, which considers the sex of individuals when forming
groups and restricts the number of males to one per group.

## Installation

You can install the CRAN version of **nprcgenekeepr** from the R console
prompt with:

``` r

install.packages("devtools")
devtools::install_github(file.path("rmsharp", "nprcgenekeepr"))
```

You can install the development version of **nprcgenekeepr** from GitHub
from the R console prompt with:

``` r

install.packages("devtools")
devtools::install_github(file.path("rmsharp", "nprcgenekeepr"))
```

All missing dependencies should be automatically installed.

## Running Shiny Application

The toolset available within nprcgenekeepr can be used inside standard R
scripts. However, it was originally designed to be used within a Shiny
application that can be started with:

``` r

library(nprcgenekeepr) # nolint: undesirable_function_linter
runGeneKeepR()
```

([`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
also still launches the application but is deprecated in favor of
[`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md).)

## Data Input and Quality Control

The Data Input and Quality Control tab is the starting point for all
analyses. This module (`modInput`) provides a comprehensive interface
for uploading and validating pedigree and genotype data.

### File Type Options

The sidebar panel allows you to select how you are submitting data:

- **File Type**: Choose between Excel (.xlsx, .xls) or Text (.csv, .txt)
  formats
- **File Content**: Select from four options:
  - Pedigree(s) file only; genotypes not provided
  - Pedigree(s) and genotypes in one file
  - Pedigree(s) and genotypes in separate files
  - Focal animals only; pedigree built from database

For text files, you can specify the separator (Comma, Semicolon, or
Tab).

### Required and Optional Columns

The only columns required are those specifying the Ego ID, Sire ID, Dam
ID, Sex, and Birth (the Birth values may be blank for animals when an
Age column is supplied). The remaining columns listed are optional but
will be used if they are present in the uploaded file. The Input Format
tab provides detailed information on allowable columns and how they will
be used in quality control.

### Minimum Parent Age

You can specify a minimum sire age and a minimum dam age (in years) that
parents must have reached at the birthdate of an offspring. Both fields
are optional: leave one blank to use the species-specific default for
that sex (2 years when the species is missing or unknown). This helps
identify potential data entry errors where parents appear too young.

### Quality Control Results

After clicking “Read and Check Pedigree”, the module processes your data
and displays results across multiple tabs:

- **QC Summary**: Shows counts of records processed, errors found, and
  warnings
- **Errors**: Lists critical issues that must be fixed before proceeding
- **Warnings**: Lists potential issues that may need review, such as
  renamed columns and animals with no birth date (the warning says how
  many; their age is unknown, so age-based checks and counts cannot use
  them). A warning never stops the pedigree from being used
- **Cleaned Data**: Preview of the validated studbook data

When the check finds errors, the app opens the Errors tab; when it finds
only warnings, it opens the Warnings tab and shows a yellow notice.

The Errors, Warnings and Cleaned Data tabs each include a download
button to export the data for offline review.

### Module Interface

The `modInput` module returns reactive values that can be used by
downstream modules:

- `cleanedStudbook`: The QC-cleaned studbook data frame
- `genotypeData`: Genotype data if provided
- `qcSummary`: Summary counts of errors, warnings, and records
- `minSireAge`: The minimum sire age value (blank uses the species
  default)
- `minDamAge`: The minimum dam age value (blank uses the species
  default)
- `isReady`: Logical indicating if data passed QC and is ready for
  analysis

## Pedigree Browser

The Pedigree Browser tab (`modPedigree`) allows users to view, filter,
and export pedigree data after quality control validation. It provides a
three-column layout for documentation, focal animal selection, and
display options.

### Layout Overview

The interface is organized into three panels:

1.  **Left Panel**: Displays guidance documentation explaining how to
    use the pedigree browser and interpret the data columns.

2.  **Middle Panel - Focal Animals**: Provides controls for specifying a
    subset of animals to focus the analysis on:

    - **Text Area**: Enter animal IDs manually (one per line or
      comma-separated). IDs can be pasted directly from Excel.
    - **File Upload**: Browse for and select a CSV file containing focal
      animal IDs.
    - **Update Button**: Click “Update Focal Animals” to apply changes.
    - **Clear Checkbox**: Check to clear all focal animals and reset the
      selection.

3.  **Right Panel - Display Options**:

    - **Display Unknown IDs**: Toggle display of unknown IDs (by default
      a capital “U” followed by at least four capital letters or digits,
      such as “U0001”) that are created for animals with only one known
      parent. Which rows are made up is recorded in the `placeholder`
      column (TRUE = made up, FALSE = real animal); a real animal whose
      ID looks like a made-up one, such as “U1234”, stays visible if you
      enter FALSE for it in your file. A real animal whose ID merely
      starts with “U”, such as “U1”, is always shown. Unchecking the box
      changes only this table; the other tabs (for example Genetic Value
      Analysis) still use every animal.
    - **Trim Pedigree**: When checked, trims the pedigree to include
      only the focal animals, their ancestors, and their descendants,
      removing unrelated lineages. Siblings, cousins, and mates that are
      not themselves ancestors or descendants of a focal animal are
      removed too.
    - **Export Button**: Download the current pedigree view as a CSV
      file.

### Data Table and Diagram

Below the control panels, a **Table**/**Diagram** tab set displays the
pedigree.

The **Table** tab is an interactive data table. Features include:

- Adjustable page length (default 15 rows)
- Horizontal scrolling for wide data
- Regex-enabled search across all columns
- Sortable columns

The **Diagram** tab renders the same pedigree as a family-tree diagram
(up to 400 animals with the default Rectilinear edge style below, or up
to 750 if you switch to the Direct style, since Rectilinear renders more
total diagram nodes per animal – narrow the focal-animal selection above
the limit). Each animal is shaped by sex – dot = Female, square = Male,
star = Hermaphrodite, triangle = Unknown, diamond = Other/Unrecorded –
with a legend to the right of the diagram showing the same mapping. If
the pedigree data includes an optional `affected` column, individuals
marked affected are additionally shaded a distinct color on the diagram,
with a matching “Affected” entry in the same legend; pedigrees without
an `affected` column render unshaded, as before. If the pedigree data
includes an optional `name` column, a **Show Names on Diagram** toggle
(off by default) switches each node’s label from id-only to id plus name
on a second line; a name longer than 15 characters is truncated with an
ellipsis on the diagram, with the full name always available in the
hover tooltip. Not every animal needs a name – one with no name (or a
pedigree with no `name` column at all) always renders with just its id,
and the “Select by id” search dropdown below always lists ids, never
names, regardless of the toggle. A mate’s own mating(s) render as a
small connector between the two parents, with a line down to their
shared children, rather than two independent lines running straight from
each parent – the same convention traditional pedigree charts use. A
**Diagram Edge Style** toggle above the diagram switches between
“Rectilinear (kinship2-style)” (the default), which routes the
connectors as strict right angles, matching the more traditional
pedigree-chart look, and “Direct”, the straight-line connector. An
animal that mates more than once, or whose lineage loops back on itself
(e.g. a consanguineous mating), appears once per mating, with each
occurrence joined back to its main occurrence by a curved, dashed line
(the legend’s “Same animal, again” entry shows this line’s style);
hovering, clicking, or searching any occurrence behaves identically to
the animal’s main occurrence. When a mating pairs two blood-related
animals (their kinship coefficient is greater than zero), the two
connector lines joining that pair to their shared mating point render
thicker and in a distinct color (a colorblind-safe vermillion), matching
the doubled/thickened mate-line convention traditional pedigree charts
use to flag a consanguineous mating at a glance – every other mating
renders unchanged. This marker always reflects the pedigree’s own
sire/dam data; it needs no optional column and no toggle. Clicking an
animal re-centers the population on it, the same as entering its ID in
the focal-animals text area. An **Export Diagram (PNG)** button, shown
in the diagram’s own corner, saves the current diagram view as a PNG
image file – useful for husbandry reports, IACUC documents, or
presentations. Hovering any animal shows its ID, sex, generation, sire,
dam, and (when the pedigree data includes it) affected status. Hovering
also highlights that animal together with the animals and mating points
connected to it within a few steps, and dims the rest of the diagram.
Under the default Rectilinear style the highlight reaches a fixed number
of steps along the connector lines, and the invisible bend points that
carry the right-angle lines count as steps, so in some cases (a mating
with nine or more full siblings, or a family whose connectors were
rerouted around crowded lines) an animal’s own parents’ mating point is
not highlighted even though it is connected. A pedigree with many full
siblings of one pair is the most likely to show this. The reach is kept
short on purpose so that the highlight stays easy to read. A **Select by
id** dropdown above the diagram lets you jump straight to a specific
animal by ID, dimming every node except it and its direct connections –
useful for locating one animal in a large, busy diagram without
narrowing the focal-animal selection.

If a colony records twin births, an optional **Twin/Zygosity Relations**
file can be uploaded from the panel to the right of the focal-animal
controls – a CSV or Excel file with `id1`, `id2`, and `code` columns
(`code` one of `"MZ twin"`, `"DZ twin"`, or `"UZ twin"`), following
kinship2’s own twin-code convention. Once uploaded, a **Show Twin
Connectors** toggle above the diagram (off by default) draws a
distinctly-styled connector line directly between each declared pair’s
own diagram nodes, drawn in a colorblind-safe bluish-green: solid for a
monozygotic (MZ) pair, short-dashed for a dizygotic (DZ) pair, and
long-dashed with a “?” label for a pair of unknown twin zygosity (UZ) –
a callback to kinship2’s own “?” glyph – with a matching legend entry so
the styling is discoverable without hovering over a connector. A
malformed or inconsistent twin-relations file (an id not in the
pedigree, or a declared MZ/DZ pair that does not already share both sire
and dam) is rejected with an on-screen notification rather than breaking
the diagram; the pedigree renders exactly as it would with no twin data
at all until a valid file is supplied. A pedigree with no twin data
uploaded is unaffected by this feature entirely.

Uploading this file does more than draw connectors: a declared
monozygotic (MZ) pair’s kinship is corrected to genetic identity
throughout the application, not just on this diagram. Once uploaded, the
correction is reflected in **Summary Statistics**, **Breeding Group
Formation**, and **Genetic Value Analysis** – including for every
relative reached through either twin, not just the pair itself – no
matter which of those tabs is visited first or whether the **Show Twin
Connectors** toggle above is ever switched on (that toggle controls only
this diagram’s own rendering). DZ and UZ pairs are unaffected by this
correction; only a declared MZ pair’s kinship changes.

### Module Interface

The `modPedigree` module accepts input from `modInput` and returns
reactive values for downstream modules:

- `pedigree`: The filtered pedigree data frame (respects the trim and
  unknown-ID settings)
- `analysisPedigree`: The pedigree the other tabs analyze; it applies
  the focal-animal trim but never hides unknown IDs
- `processedPedigree`: The full pedigree with the population, pedigree
  number, and generation columns added
- `focalAnimals`: Character vector of focal animal IDs
- `nAnimals`: Count of animals in the current view
- `populationCount`: Count of animals marked as population
- `isReady`: Logical indicating if pedigree data is available
- `twinRelations`: The validated twin/zygosity relations, or `NULL` when
  none were uploaded or the file was invalid

### Workflow

1.  After data passes QC in the Input tab, navigate to the Pedigree
    Browser.
2.  Optionally specify focal animals to narrow your analysis.
3.  Adjust display options as needed.
4.  A population must be defined before proceeding to Genetic Value
    Analysis.

## Genetic Value Analysis

The Genetic Value Analysis tab (`modGeneticValue`) provides tools for
computing genetic value metrics for your population. This module
calculates Mean Kinship and Genome Uniqueness scores to help identify
genetically valuable animals.

### Analysis Options

The left panel contains controls for configuring the analysis:

- **Gene Drop Iterations**: Number of iterations for the gene-drop
  simulation (default: 1000, range: 100-10,000). More iterations provide
  more accurate genome uniqueness estimates but take longer to compute.

- **Genome Uniqueness Threshold**: An allele counts as rare when it is
  carried by at most this many animals in all, counting the animal
  itself (choices 1-5, default 4).

- **Ranking Scheme**: “Combined (kinship - uniqueness)” (the default)
  ranks animals by mean kinship minus genome uniqueness. “Categorical
  (priority order)” sorts animals into tiers instead and shows three
  more controls: the priority axis (genome uniqueness first or mean
  kinship first), the high-uniqueness cutoff (default 10), and the
  low-kinship z-score cutoff (default 0.25).

- **Calculate Genome Uniqueness** and **Calculate Mean Kinship**: Two
  checkboxes, both checked. They currently have no effect: the analysis
  always calculates both measures.

- **Kinship Overrides (optional)**: Upload a CSV or Excel file with the
  columns `id1`, `id2` and `kinship` to replace the pedigree-derived
  kinship for the listed pairs.

- **Run Analysis**: Click to start the genetic value computation.

### Understanding Genetic Values

The information panel explains the key metrics:

- **Mean Kinship**: The average kinship coefficient between an
  individual and all other members of the population. **Lower values are
  better** as they indicate the animal is less related to the
  population.

- **Genome Uniqueness**: The percentage of an individual’s simulated
  allele copies that are rare in the population, based on gene-drop
  simulation. It is shown on a 0-100 scale, not as a proportion.
  **Higher values are better** as they indicate the animal carries rare
  genetic material.

### Results Tabs

After running the analysis, results are displayed across three tabs:

1.  **Rankings**: Interactive table showing animals ranked by genetic
    value.

    - Adjust “Show top N” to view more or fewer animals (default 20)
    - “Filter by IDs” with “Filter View” shows only the animals you list
    - “Export All” saves the full rankings to CSV and “Export Subset”
      saves the filtered view

2.  **Visualizations**: Scatter plot showing the relationship between
    mean kinship and genome uniqueness values. The ten highest-ranked
    animals are red and all others are blue.

3.  **Summary**: A Metric/Value table with the number of animals
    analyzed, the average mean kinship and genome uniqueness, the
    largest genome-uniqueness standard error, and the founder statistics
    (total, male and female founders, founder equivalents, founder
    genome equivalents, gene diversity, and the sex-ratio and variance
    effective population sizes). It shows no standard deviations or
    distributions.

### Module Interface

The `modGeneticValue` module returns reactive values for downstream use:

- `geneticValues`: Data frame with genetic value metrics for all animals
- `topAnimals`: The ten highest-ranked animals
- `nAnalyzed`: Count of animals included in the analysis

### Performance Notes

Before the analysis begins, the pedigree is always trimmed to the
ancestors of the current population (the living animals, or every animal
when the pedigree has no `exit` column). The application sets no fixed
limit on pedigree size, so a large pedigree simply takes longer to
analyze.

## Summary Statistics

The Summary Statistics tab (`modSummaryStats`) displays comprehensive
visualizations and statistics from the genetic value analysis results.

### Interface Layout

The module provides a structured display with three main sections:

1.  **Guidance Panel**: At the top, an informational panel explains how
    to interpret the statistics and visualizations.

2.  **Export Buttons**: A row of download buttons for exporting:

    - Kinship Matrix (CSV)
    - Male Founders (CSV)
    - Female Founders (CSV)
    - First-Order Relationships (CSV)
    - All Relationships (CSV)
    - Relationship Classes (CSV)

3.  **Population Summary**: Dynamic HTML output showing:

    - Total number of animals analyzed
    - Average mean kinship across the population
    - Average genome uniqueness across the population

### Visualizations

The module displays six plots arranged in two columns:

**Left Column - Histograms**: - Mean Kinship Coefficient Distribution -
Mean Kinship Z-Score Distribution - Genome Uniqueness Distribution

**Right Column - Box Plots**: - Mean Kinship Coefficient - Mean Kinship
Z-Score - Genome Uniqueness

Each plot has an accompanying download button to export as PNG.

### Statistical Summaries

The tab reports founder statistics including: - Number of known
founders, male founders, female founders - Founder equivalents and
founder genome equivalents (the latter is a gene-drop estimate, shown
inline with its sampling standard error as `FG +/- SE`) - **Gene
diversity (GD)** beside FG: the expected heterozygosity still retained
from the founding gene pool, `GD = 1 - 1 / (2 * FG)`, derived from the
founder genome equivalents of Lacy (1989), over the same analysis set as
the founder statistics

A separate **Effective Population Size** block reports two effective
sizes over the **current living breeders** – the living animals that
appear as a sire or dam, a different (usually smaller) population than
the analysis set above:

- **Sex-Ratio Ne**, `4 * Nm * Nf / (Nm + Nf)`, the Crow & Kimura (1970)
  effective size implied by an unequal breeding sex ratio (it equals the
  census when the sexes are balanced and is 0 when either breeding sex
  is absent)
- **Variance Ne**, the general Crow & Kimura (1970) form
  `(N * k - 1) / (k - 1 + V / k)` where `k` is the mean and `V` the
  variance of lifetime offspring counts, the effective size reduced by
  unequal family sizes (N/A when fewer than two living breeders are
  present)

Both effective sizes idealize a Wright-Fisher population (constant size,
discrete generations, random union of gametes), so each is best read as
an index of one source of diversity loss rather than a literal head
count.

For Mean Kinship and Genome Uniqueness, displays the minimum, 1^(st)
quartile, mean, median, 3^(rd) quartile, and maximum, followed by the
skewness and kurtosis of each distribution.

### Module Interface

The `modSummaryStats` module accepts inputs from upstream modules and
returns:

- `summaryData`: Reactive list containing:
  - `nAnimals`: Count of animals in the analysis
  - `meanMK`: Average mean kinship value
  - `meanGU`: Average genome uniqueness value
- `relationships`, `relationClasses`, and `firstOrderCounts`: the data
  behind the three relationship exports
- `mkSummary`, `guSummary`, `mkShape`, and `guShape`: the summary values
  and the skewness and kurtosis for mean kinship and genome uniqueness
- `mkHistogram`, `zscoreHistogram`, `guHistogram`, `meanKinshipBoxPlot`,
  `zscoreBoxPlot`, and `guBoxPlot`: the six plots

### Population Genetics Terms

At the bottom, a reference panel provides definitions of key population
genetics terms used throughout the analysis.

## Breeding Group Formation

The Breeding Group Formation tab (`modBreedingGroups`) helps generate
breeding groups that minimize inter-animal relatedness while maintaining
genetic diversity.

### Configuration Options

The left panel provides controls for group formation:

- **Source**: Select which animals to use as candidates:

  - *Top ranked*: Use the highest-ranked living animals from the Genetic
    Value Analysis
  - *Upload list*: Currently behaves exactly like “All available”; the
    choice does not yet provide a way to upload or type a list of
    candidate IDs
  - *All available*: Use every living animal in the current pedigree

  Whatever the source, only animals that are alive are used. When the
  pedigree has a Status column, an animal counts as alive when its
  Status is ALIVE (so deceased, shipped and placeholder animals are
  skipped). When it has no Status column, an animal with no exit date
  counts as alive. When it has neither column, every animal is used. The
  cut to the top N animals or the genetic-value floor comes after this,
  so “Top ranked” takes the best-ranked living animals. If no animal in
  the source is alive, the tab shows an error notice and forms no
  groups. Animals you type into a seed group are accepted as typed.

- **Include animals by**: Choose how candidates are screened for
  eligibility, independent of Source:

  - *Top N ranked* (default): Include only the top-N ranked animals when
    the source is “Top ranked” (see “Number of top animals” below); no
    genetic- value screening for “Upload list”/“All available”.
  - *Genetic-value floor*: Exclude any animal whose Genetic Value
    Analysis result is “Low Value”, for all three Source choices.
    Animals labeled “Undetermined” (missing parentage/origin data) still
    pass, since a data gap is not evidence of low genetic value. An
    animal with no Genetic Value Analysis result at all (for example,
    one excluded from that report’s population) does not pass the floor.
    This mode ignores “Number of top animals” entirely, so a viable
    animal is never excluded purely for ranking outside a fixed count,
    and a mediocre top-N no longer automatically qualifies. Requires
    having run Genetic Value Analysis first, for any Source choice.

- **Number of top animals**: When using “Top ranked” source with the
  “Top N ranked” inclusion criterion, specify how many of the highest
  genetic value animals to include (default: 20).

- **Number of groups**: How many breeding groups to form (default: 3,
  range: 1-20).

- **Max kinship threshold**: Two animals whose kinship coefficient is at
  or above this value are kept out of the same group (default: 0.25).
  Lower values create more genetically diverse groups but may result in
  fewer animals being placed.

- **Ancestry Guardrails**: An optional, collapsed-by-default section for
  centers that manage geographic ancestry (for example, Indian-origin
  vs. Chinese-origin rhesus). Upload a rules file in which each line
  names two ancestry classifications and a severity: *block* rules keep
  matching pairs out of the same group during formation; *flag* rules
  let groups form and report matching pairs afterward. A status line
  always shows the state of the guardrails: “No ancestry rules loaded.”
  before a file is uploaded; afterward, how many block and flag rules
  are loaded and how many animals in the pedigree no rule names; a
  pedigree without ancestry information leaves the guardrails inactive,
  with the status line saying so. A loaded *block* rule can be
  overridden for the session – select it, choose “Override rule…”, and
  confirm with a required written reason; overridden rules still report
  their pairings, marked “overridden”, never silently dropped. When
  writing rules for animals without usable ancestry information, name
  both UNKNOWN and OTHER (blank entries standardize to UNKNOWN;
  unrecognized text standardizes to OTHER) – the validator warns when
  only one of the two is named.

- **Sex ratio**: Control the male-to-female composition:

  - *None*: No sex ratio constraint
  - *Harem (1M:NF)*: One male per group with multiple females
  - *Custom*: Specify a custom ratio

- **Minimum breeding age (years)**: Kinship involving an animal younger
  than this age is ignored (default: 1). With a harem sex ratio, the
  male in each group must be at least this old.

- **Number of simulations**: How many random groupings the search tries
  (default: 10). More simulations sample more of the possible groupings
  but take longer; raise it for a final run.

- **Candidates to retain**: How many distinct candidate group solutions
  to keep for comparison (default: 5, range: 1-50). Each retained
  solution has its own score and membership, browsable via the
  “Candidate grouping” selector above the results.

- **Exhaustive enumeration mode**: An alternative to the default random-
  sampling search – when checked, every possible way of forming the
  single group is examined (rather than a sample of
  `Number of simulations` attempts), so the retained candidates are
  guaranteed to include the best possible groupings, not merely the best
  the sample happened to find. Only available when forming exactly one
  group with no harem or custom sex ratio – the checkbox itself is
  hidden whenever the current configuration falls outside that scope.
  Checking every combination is only feasible for a small pool: with
  more than 20 candidates the run stops with an error message instead of
  starting, and the search is cut short after 10 seconds. A status
  message beneath the checkbox reports the outcome after each run: how
  many distinct groupings were found, whether the search completed
  exhaustively or was cut short by its internal time limit (shown in
  orange when truncated, since the search may not have found every
  possibility), and which “Candidates to retain” cutoff was applied.

### Results Display

After clicking “Form Groups”, results appear in four tabs:

1.  **Groups**: One panel per formed group, headed “Group N (M
    animals)”, with a table of its members showing ID, sex, birth date,
    sire and dam.

2.  **Statistics**: Summary table with one row per group and four
    columns: Group, Total, Males and Females.

3.  **Group Detail**: One group at a time – annotated membership (ID,
    sex and age in years), the within-group kinship matrix, and
    per-group export buttons. The kinship matrix is shown whether or not
    “Include kinship in display of groups” is checked; that checkbox
    only controls whether each group’s kinship matrix is also included
    in the `groupKinship` value the module returns.

4.  **Ancestry**: When ancestry rules were in effect for the run, every
    within-group pairing a rule matched (with its rule, severity, and
    whether it was overridden), a coverage summary showing how many
    grouped animals carry each ancestry classification and which
    classifications no rule reaches, and a **Download Audit Manifest**
    button exporting the run’s audit record: the rules in effect, any
    overrides with their written reasons, pair counts, and the
    confirmation warning text verbatim.

### Module Interface

The `modBreedingGroups` module returns reactive values:

- `groups`: List of character vectors of animal IDs, one per breeding
  group of the selected candidate grouping; when some candidates fit no
  group, the last element is the “Unused” group
- `nGroups`: Number of elements in `groups` (this counts the “Unused”
  group when there is one)
- `unassigned`: IDs of candidates that appear in no group, including the
  “Unused” group
- `score`: Score of the selected candidate grouping (the size of its
  smallest group)
- `groupKinship`: The kinship matrix for each group, when “Include
  kinship in display of groups” was checked
- `ancestryRules`: The validated ancestry rules table, or `NULL` when no
  rules were uploaded

### Algorithm Notes

The group formation algorithm:

1.  Calculates pairwise kinship for all candidate animals
2.  Iteratively assigns animals to groups while respecting the kinship
    threshold
3.  Optimizes for maximum genetic diversity within groups
4.  Respects sex ratio constraints when specified

By default, the analysis ignores kinship below the Max kinship threshold
(0.25 in the application; the
[`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
function’s own default of 0.015625 is the second-cousin level), pairwise
relatedness involving animals younger than the Minimum breeding age (1
year), and relatedness between females. The guidance panel at the bottom
provides a table of kinship values for common relationship categories.

## Genetic Value Analysis and Breeding Group Formation Description

The Genetic Value Analysis and Breeding Group Description tab
(`modGvAndBgDesc`) provides comprehensive documentation about the
algorithms and methodologies used in genetic value analysis and breeding
group formation.

### Purpose

This informational module serves as a reference for users who want to
understand the scientific basis behind the calculations performed by the
application. It displays detailed HTML documentation loaded from the
package’s guidance files.

### Content Overview

The documentation explains:

1.  **Genetic Value Analysis Algorithms**:
    - How mean kinship coefficients are calculated
    - The gene-drop simulation methodology for genome uniqueness
    - Interpretation of genetic value metrics
2.  **Breeding Group Formation**:
    - The optimization algorithm for minimizing within-group relatedness
    - Which relationships may be ignored (kinship below a threshold,
      young animals, and females) when forming groups
    - The iterative assignment process

### Module Interface

The `modGvAndBgDesc` module is primarily informational:

- `modGvAndBgDescUI`: Renders the documentation panel with styled HTML
  content
- `modGvAndBgDescServer`: Minimal server logic (no reactive outputs)

This module does not return reactive values as it serves only as a
documentation reference for the other analysis modules.

### Related Modules

- See `modGeneticValue` for performing genetic value analysis
- See `modBreedingGroups` for forming breeding groups
- See `modSummaryStats` for viewing analysis results

## ORIP Reporting

The ORIP Reporting tab (`modORIPReporting`) collects information for
reporting to the Office of Research Infrastructure Programs (ORIP). The
tab is shown only when a site configuration file is present and names
ONPRC as the center; other sites do not see it.

The tab has:

- a guidance panel,
- **Export ORIP Report** and **Export Demographics** buttons,
- a **Site Information** section (center, node, user, and system),
- a **Colony Summary** table (animals by sex and the number of founders
  by sex), and
- a **Genetic Diversity Metrics** section (mean kinship, mean genome
  uniqueness, and the number of animals analyzed).

The tab is still under development. A “Coming Soon” list names founder
contribution analysis, inbreeding trends over time, breeding success
rates, age structure analysis, and formatted PDF report generation. The
exact information that needs to be submitted for ORIP recordkeeping is
still under discussion.

## Algorithm: Breeding Group Formation

The group formation process is accomplished by using an algorithm for
determining the maximal independent set (MIS). In graph theory, a
maximal independent set is the largest set of vertices in a graph where
no two share an edge. In breeding group formation, the vertices are
animals, and the edges are the kinships that need to be considered. For
a given group of animals and pairwise kinships, there are potentially
many maximal independent sets, depending on which animals are included
or excluded from the final group. In order to effectively sample the set
of MISs, we use random selection of animals and repeat the MIS
generation numerous times. This allows us to sample a number of MISs and
then choose the one that best fits our selection criteria. For our
purposes, we want the largest group that can be formed from this set of
animals, where none have concerning relatedness to each other.

The algorithm requires several pieces of information:

1.  The candidate animals  
2.  A matrix of pairwise kinships between candidate animals  
3.  The number of groups desired from the list of candidate animals  
4.  The number of simulations to run.  
    \* This is equivalent to the number of random MISs to generate and
    compare.  
5.  Information on which inter-animal relationships (if any) should be
    ignored.

#### Data Pre-processing

Before the group formation algorithm begins generating MISs, the data is
pre-processed to remove any animals and pairwise kinships that should
not be considered.

Specifically:

1.  The candidate animals are chosen. In the application, “Include
    animals by” selects either the top-N ranked animals (the default) or
    a genetic-value floor.  
    \* With the genetic-value floor, any animal that the genetic value
    analysis labeled “Low Value” is removed from further consideration
    (animals labeled “Undetermined” still pass).  
    \* The floor is optional and off by default.  
2.  The pairwise kinship data is filtered down to only the kinship
    between candidate animals.  
3.  If an age threshold has been set, kinships involving animals below
    the threshold will be filtered out.  
    \* This allows the algorithm to ignore young animals, as young
    animals typically go to whatever social group their dam does.  
    \* By default, we ignore animals under 1 year of age  
4.  Pairwise kinships below the specified level will be filtered out.  
    \* The application’s default Max kinship threshold is 0.25, so
    kinship below 0.25 is ignored; the
    [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
    function’s own default, 0.015625, is the 2nd-cousin level  
5.  Pairwise kinships between females will be filtered out  
    \* This allows females of the same matriline to be part of the same
    group like they would be in the wild.  
    \* The application always applies this; script users can change it
    with the `ignore` argument of
    [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md).

#### Random Maximum Independent Set Generation

After any animals and relationships that should be ignored are removed
from the dataset, the algorithm begins using the remaining animals and
kinship information to generate potential groups.

The algorithm proceeds by the following steps:

1.  For **I** iterations:
    1.  Generate **N** empty sets, where **N** is the desired number of
        groups to be created.  
    2.  While there are candidate animals remaining:  
        i. Pick a group **G** randomly from the groups that still have
        an animal available to add  
        ii. Pick an animal **A** randomly from the animals still
        available for **G**, and assign **A** to it  
        iii. Remove animal **A** from consideration for all **N**
        groups  
        iv. Remove all animals related to **A** from consideration for
        group **G**  
    3.  Score the groups that were generated  
        i. For our purposes, the score is the size of the smallest
        group, so a higher score means the groups are larger and more
        even  
    4.  If this set of groups differs from those already saved, save it
        when fewer than the number of candidates to retain (default 5)
        are saved, or when its score beats the lowest saved score.  
2.  Return the saved sets of groups, best score first
    1.  These are the best distinct sets of groups encountered in **I**
        iterations; each set also has an “Unused” group holding any
        candidates that fit in no group.

Vinson, A. and Raboin, M.J. (2015) “A Practical Approach for Designing
Breeding Groups to Maximize Genetic Diversity in a Large Colony of
Captive Rhesus Macaques (*Macaca mulatta*)” *Journal of the American
Association for Laboratory Animal Science*, 2015 Nov, Vol.54(6),
pp.700-707.

## Algorithm: Genome Uniqueness

Genome uniqueness is calculated through the use of a gene-drop
simulation to estimate how frequently an animal will possess founder
alleles not present in other members of the focal population, or present
in a specified number of animals or fewer, counting the animal itself.

The gene-drop simulation used by the web application is a vectorized
version and is shown in the figure below. In an un-vectorized version,
if 1000 gene-drop simulations are desired for the estimation process,
the population had to be iterated over 1000 times. Since each iteration
of the gene-drop is independent, the process can be vectorized so that
each element of a vector represents 1 iteration of the gene-drop
simulation. In the vectorized version, the population is iterated over
once, regardless of the number of simulations desired. This drastically
reduces the amount of time necessary for the program to run.

#### Overview

The basic steps of the gene-drop are:

1.  Each founder is assigned two unique alleles  
2.  For each subsequent generation:
    1.  Assign genotypes to each member of the generation
        - For each animal, find the genotypes of the parents, and
          select  
          one allele from each parent randomly.

Once every animal has been assigned a genotype by mendelian inheritance
tally the number of unique alleles possessed by each member of the focal
population. In the case of this algorithm, we do allow the ‘uniqueness’
threshold to be adjusted so that an allele can be considered unique if
it is possessed by N or fewer members of the focal population in all,
counting the animal itself (the application offers 1-5, default 4).

#### Vectorized Gene-Drop Details

The vectorized gene-drop simulation follows the same basic process
described above. The difference is that instead of dropping one allele
at a time, and repeating the simulation N times, the vectorized version
drops N independent alleles one time.

In the vectorized version, each animal has a vector of paternally
inherited alleles and a vector of maternally inherited alleles. For each
offspring, a random combination of these alleles is produced and dropped
down to the offspring by the process below and shown in the following
figure:

1.  To start the simulation, each founder is assigned two unique
    founding alleles.  
    N-element vectors are created of these alleles, where N is the
    desired number of  
    simulations. In the example below, this founder was assigned the
    unique founder  
    alleles 1 & 2 and 5 simulations were desired.  
2.  Each time alleles need to be dropped from parent to offspring, a
    unique  
    transmission vector is created representing whether or not an
    allele  
    was passed to that offspring. The vector is generated to contain a
    random combination  
    of 0’s and 1’s. The animal’s paternally inherited alleles are then
    multiplied by the  
    transmission vector, while the maternally inherited alleles are
    multiplied by the  
    compliment of the transmission vector.  
3.  To generate the final set of alleles received by the offspring, the
    maternal and  
    paternal allele vectors are added together.  
4.  The result is a vector of alleles that this offspring has received
    from this parent.

Once allele vectors have been generated for every animal in the
pedigree, the focal population can be subset out. Within this population
of allele vectors, unique alleles can be determined:

For each position on the allele vectors (1:N) - Gather each animal’s two
alleles - If the number of animals possessing that allele, counting this
animal, is equal to or below the threshold, score the allele as unique
(1) - Otherwise, score the allele as non-unique (0)

Once every position on each animal’s two allele vector’s has been
scored, sum all of the scores for an animal and divide by the total
number of alleles being considered (2 \* number of simulations). The
application reports this fraction multiplied by 100, so genome
uniqueness is shown as a percentage.

![Generation of a vector of five gametes from one parent. Showing how
the transmission vectors (row 2) determine which alleles are passed from
the parental alleles or haplotypes (row 1) to form complementary vectors
(row 3) that are combined by adding corresponding elements to form the
final vector of transmitted alleles (row
4).](../reference/figures/GeneDrop.png)

Generation of a vector of five gametes from one parent. Showing how the
transmission vectors (row 2) determine which alleles are passed from the
parental alleles or haplotypes (row 1) to form complementary vectors
(row 3) that are combined by adding corresponding elements to form the
final vector of transmitted alleles (row 4).

Genome uniqueness is calculated according to MacCluer JW, et al. (1986)
and Ballou JD, Lacy RC. (1995).

## Software Issues

Our goal is to use current R software development practices in an open
software environment. Users can see all of the code at
[github.com/rmsharp/nprcgenekeepr](https://github.com/rmsharp/nprcgenekeepr)
and can submit suggestions and bug reports on our issue tracker at
[github.com/rmsharp/nprcgenekeepr/issues](https://github.com/rmsharp/nprcgenekeepr/issues).

### CICD Pipeline Use

The application and associated website is being continuously integrated
at each push to the online repository. While often new features being
added are not stable or complete, it is uncommon for the application not
to run and perform functions that were working before. However, make
sure the build was passing by looking for a green *R-CMD-check.yaml
Passing* badge at the top of the README file at
<https://github.com/rmsharp/nprcgenekeepr/>.

### Debug Logging

There is a logging system integrated into the package using the package
**futile.logger**. Note the checkbox at the bottom of the side panel on
the *Input* tab. When the *Debug on* checkbox is checked (it is not
checked by default), the application writes to a file named
*nprcgenekeepr.log* in the users home directory. Currently, events in
the Input tab (`R/modInput.R`), the application server
(`R/appServer.R`), and the functions that read pedigree and genotype
data are logged, as that is where most errors are exposed.

### Code Coverage

Code coverage reports are part of the automated build system running in
GitHub Actions. We are using the **testthat** package for unit tests.
Currently all code returning values that do not access a database or the
file system have coverage with unit tests. Many of these have 100
percent of the lines covered. However, the unit tests are not
exhaustive. The practice is to add further tests as errors are detected
or when working on the code and a new unit test possibility is
discovered. The percentage of lines covered is shown by the Codecov
badge at the top of the README file.
