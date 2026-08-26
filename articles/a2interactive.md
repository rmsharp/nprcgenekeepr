# Interactive Use of nprcgenekeepr

## Introduction

This tutorial demonstrates the major functions used within the Shiny
application provided by the **nprcgenekeepr** package and provides
sufficient insight into those functions that they may be used
independently.

This tutorial is primarily directed toward someone with experience using
R who wants to better understand how the Shiny application works or to
perform some actions not directly supported by the Shiny application.

Please provide any comments, questions, or bug reports through the
GitHub issue tracker at
<https://github.com/rmsharp/nprcgenekeepr/issues>.

## Installation and Help

You can install **nprcgenekeepr** from GitHub with the following code.

``` r

install.packages(nprcgenekeepr)
## Use the following code to get the development version
# install.packages("devtools")
# devtools::install_github("rmsharp/nprcgenekeepr")
```

All missing dependencies should be automatically installed.

You can get help from the **R** console with

``` r

?nprcgenekeepr
```

**The help provided by this (*nprcgenekeepr.R*) needs to be more
complete and include links to the tutorials.**

## Reading in a Pedigree

A pedigrees can be imported using either Excel worksheets or text files
that contain all of the pedigree information or using either Excel
worksheets or text files that contain a list of focal animals with the
remainder of the pedigree information is pulled in through the LabKey
API.

This tutorial will use a pedigree file that can be created using the
**makeExamplePedigreeFile** function as shown below. The function
**makeExamplePedigreeFile** both saves a file and returns the full path
name to the saved file, which we are saving into the variable
*pedigreeFile*. Note: the user will select where to store the file.

``` r

library(nprcgenekeepr)
pedigreeFile <- makeExamplePedigreeFile()
```

This writes *ExamplePedigree.csv* to a place you select within your file
system.

You use the file name provided by the **makeExamplePedigreeFile**
function to tell **read.table** what file to read.

``` r

breederPedCsv <- read.table(pedigreeFile,
  sep = ",", header = TRUE,
  stringsAsFactors = FALSE
)

breederPedCsv$fromCenter <- "TRUE"
breederPedCsv$fromCenter[
  suppressWarnings(sample(
    which(is.na(breederPedCsv$sire) &
      is.na(breederPedCsv$dam)),
    round(0.8 * length(which(
      is.na(breederPedCsv$sire) &
        is.na(breederPedCsv$dam)
    )))
  ))
] <- "FALSE"
```

Note the number of rows read. Each row represents an individual within
the pedigree.

``` r

nrow(breederPedCsv)
```

    ## [1] 3694

The next step is to put the information read from the file into a
pedigree object. This is done with the **qcStudbook** function, which
examines the file contents and tests for common pedigree errors.

You can see the errors that can be detected by **qcStudbook** by
returning the empty error list with **getEmptyErrorLst()**. We are not
showing the output of the function call now because later in this
tutorial we will explore errors in more depth.

**qcStudbook** can take five arguments *sb*, *minSireAge* and
*minDamAge* (in years), *reportChanges*, and *reportErrors*. However,
all but *sb* have default values and only the *sb* argument is required.

It is prudent to ensure that parents are at least of breeding age, which
is species and sex specific. Leaving *minSireAge* and *minDamAge* blank
(their default, `NULL`) looks up the species-specific breeding age for
each sex; a number overrides that sex’s floor. I have set both to 2
years here.[^1]

``` r

breederPed <- qcStudbook(breederPedCsv, minSireAge = 2L, minDamAge = 2L)
```

If **qcStudbook** reports an error, change the call by adding the
**reportErrors** argument set to **TRUE** and examine the returned
object. More on this is presented in the **Pedigree Errors** section.

## Identifying Focal Animals

You may want to focus your work on a *focal* group of animals. This can
be done by reading in a list of animal IDs that make up the *focal*
group and use that list to update the pedigree. Alternatively you can
created a list of animal IDs based on criteria you have selected.

For example, to select living animals at the facility with at least one
parent, the following can be used.

``` r

focalAnimals <- breederPed$id[!(is.na(breederPed$sire) &
  is.na(breederPed$dam)) &
  is.na(breederPed$exit)]
print(stri_c(
  "There are ", length(focalAnimals),
  " animals in the vector _focalAnimals_."
))
```

\[1\] “There are 327 animals in the vector *focalAnimals*.”

As can be seen, these animals have at least one parent and have not left
the facility.

``` r

breederPed[breederPed$id %in%
  focalAnimals, c("id", "sire", "dam", "exit")][1L:10L, ]
```

    ##          id   sire    dam exit
    ## 1669 01QRQ4 VDBGDP TH7HTY <NA>
    ## 1743 CLSVU6 ULV9M7 SUFWJI <NA>
    ## 1887 1SPLS8 U9APLW 142GKP <NA>
    ## 1934 5IAFMK U4YSS5 WVE6Y4 <NA>
    ## 2072 HLQ9SY UI3RFL VEWC1E <NA>
    ## 2234 XFWVVX U3MFSZ L4LM1F <NA>
    ## 2337 6X6BG9 ENI6HX IUF0HC <NA>
    ## 2377 B228Q6 UEUIRJ CBSIAA <NA>
    ## 2378 B2CKHA ENI6HX WBFBR5 <NA>
    ## 2383 BCJJKN UA379T JPVAT3 <NA>

We indicate that these are the animals of interest by using the
**setPopulation** function. This function simply sets a column named
*population*[^2] to the logical value of **TRUE** if the row represents
an animal in the list and **FALSE** otherwise.

The first line of code below sets the *population* column and the second
counts the number of rows where the value was set to **TRUE**.

``` r

breederPed <- setPopulation(ped = breederPed, ids = focalAnimals)
nrow(breederPed[breederPed$population, ])
```

    ## [1] 327

The IDs used to populate the *population* flag can be used to trim the
pedigree so that it contains only those individuals who are in the ID
list or are ancestors of those individuals.

``` r

trimmedPed <- trimPedigree(focalAnimals, breederPed)
nrow(breederPed)
```

    ## [1] 3694

``` r

nrow(trimmedPed)
```

    ## [1] 704

The **trimPedigree** function has the ability to remove those ancestors
that do not contribute genetic information. Uninformative founders are
those individuals who are parents of only one individual and who have no
parental information. (*Currently genotypic information is ignored by
**trimPedigree***).

``` r

trimmedPedInformative <- trimPedigree(focalAnimals, breederPed,
  removeUninformative = TRUE
)
nrow(trimmedPedInformative)
```

    ## [1] 509

We can find all of the animals that are in the trimmed pedigree but are
not focal animals.

``` r

nonfocalInTrimmedPed <- trimmedPed$id[!trimmedPed$id %in% focalAnimals]
length(nonfocalInTrimmedPed)
```

    ## [1] 377

We can see which of these 377 are and are not parents. We will first
make sure we have all of the parents by getting our list of parents from
the entire pedigree. We then demonstrate that they are all in the
trimmed pedigree.

``` r

allFocalParents <- c(
  breederPed$sire[breederPed$id %in% focalAnimals],
  breederPed$dam[breederPed$id %in% focalAnimals]
)
trimmedFocalParents <- c(
  trimmedPed$sire[trimmedPed$id %in% focalAnimals],
  trimmedPed$dam[trimmedPed$id %in% focalAnimals]
)
all.equal(allFocalParents, trimmedFocalParents) # Are the IDs the same?
```

    ## [1] TRUE

However, not all of the animals in the trimmed pedigree are either the
focal animals or their parents. They are more distant ancestors as we
will show.

``` r

notFocalNotParent <-
  trimmedPed$id[!trimmedPed$id %in% c(focalAnimals, allFocalParents)]
length(notFocalNotParent)
```

    ## [1] 187

Since the trimming process is supposed to retain the focal animals and
their ancestors, we will leave it as an exercise for you to demonstrate
that at least some of the remaining animals are grandparents of the
focal animals. *Hint: there are 490 grandparents in both the trimmed and
the complete pedigree*.

As you can see from the number of rows in the full pedigree (3694)
versus the trimmed pedigree (704), trimmed pedigrees can be much
smaller. Of the additional 377 animals, 182 provide genetic information
while the others (195) are genetically uninformative.

As is shown below only 4 (0ZX29Q, 1QBKW9, 5PWJ0G, and Y3CJ5A) living
animals are still in the colony but are not in the trimmed pedigree.[^3]

``` r

unknownBirth <- breederPed$id[is.na(breederPed$birth)]
knownExit <- breederPed$id[!is.na(breederPed$exit)]
unknownBirthKnownExit <-
  breederPed$id[is.na(breederPed$birth) | !is.na(breederPed$exit)]
knownPed <- breederPed[!breederPed$id %in% unknownBirthKnownExit, ]
otherIds <- knownPed$id[!knownPed$id %in% trimmedPed$id[is.na(trimmedPed$exit)]]
print(stri_c(
  "The living animals in the pedigree that are not in the trimmed ",
  "pedigree are ", get_and_or_list(otherIds), "."
))
```

\[1\] “The living animals in the pedigree that are not in the trimmed
pedigree are 0ZX29Q, 1QBKW9, 5PWJ0G, and Y3CJ5A.”

## Age Sex Pyramid Plot

You can examine the population structure using an age-sex pyramid plot
with a single function. We will limit our view to just the focal animals
and their living relatives. This is appropriate for colony management
because in addition to the genetic diversity we seek, we have to remain
cognizant of the age and sex distributions within the colonies we
manage.

``` r

getPyramidPlot(ped = trimmedPed[is.na(trimmedPed$exit), ])
```

![Age Sex Pyramid
Plot.](a2interactive_files/figure-html/plot-focal-age-sex-pyramid-1.png)

    ## 45 45

    ## [1] 5.1 4.1 4.1 2.1

## Pedigree Diagram

The Pedigree Browser’s Diagram tab in the Shiny application renders a
pedigree as a family-tree diagram. A mate’s own mating(s) render as a
small connector between the two parents, with a line down to their
shared children, rather than two independent lines running straight from
each parent – the same convention traditional pedigree charts use. An
animal that mates more than once, or whose lineage loops back on itself
(e.g. a consanguineous mating), appears once per mating, with each
occurrence after the first joined back to its main occurrence by a
dashed line. Both are built on two script-callable functions that work
identically outside the Shiny application: **makePedigreeMatingLayout**
prepares a pedigree’s node/edge data in this convention, and
**visNetwork::visNetwork** (from the **visNetwork** package, a
dependency of **nprcgenekeepr**) renders it. (A simpler function,
**makePedigreeDiagramData**, remains available for a plain
one-node-per-animal diagram without this convention – it is no longer
what the Shiny app itself uses.) See the *pedigree-diagram* article for
the equivalent point-and-click workflow and screenshots of every feature
– including affected-status shading, name labels, and twin/zygosity
connectors, none of which this scripted walkthrough demonstrates.

That parent-to-mating-to-child connector has two available routings,
selected by **makePedigreeMatingLayout**’s *edgeStyle* argument:
`"rectilinear"` (the default, Track 2, docs/planning/pedigree-diagram-
kinship2-fidelity-remediation-plan.md – strict horizontal/vertical right
angles throughout: a horizontal segment between the two parents, a
vertical drop to the mating dot, a horizontal sibship bar across the
children, and a vertical drop into each one, matching the convention the
**kinship2** R package uses) and `"direct"` (a single straight or
lightly sloped line all the way from parent to mating dot to child). The
Shiny app’s Diagram tab exposes the same choice live as a “Diagram Edge
Style” toggle above the diagram; in a script it is just this one
argument. Both are demonstrated below – *direct* first, *rectilinear*
(matching the tab’s own default) afterward.

The *trimmedPed* pedigree built earlier in this tutorial has 704 animals
– realistic for the live Shiny application’s pan-and-zoom canvas, but
too dense for a single static demonstration to usefully show every
feature at once. It is also limited to the *Female*, *Male*, and
*Unknown* sex codes that happen to occur in the bundled example data –
the *Hermaphrodite* and unrecorded-sex shapes never appear in it. So
instead we build a small, synthesized pedigree spanning a few
generations, deliberately including all five sex codes
**makePedigreeMatingLayout** recognizes – and, since two of its founders
(*M1* and *F2*) each mate more than once, the diagram’s duplicate-node
convention as well.[^4]

``` r

founders <- data.frame(
  id = c(paste0("F", 1L:4L), paste0("M", 1L:4L)),
  sire = NA_character_, dam = NA_character_,
  sex = c(rep("F", 4L), rep("M", 4L)),
  stringsAsFactors = FALSE
)
gen1 <- data.frame(
  id = paste0("C", 1L:12L),
  sire = c(
    "M1", "M1", "M1", "M2", "M2", "M3", "M3", "M3", "M4", "M4", "M1", "M1"
  ),
  dam = c(
    "F1", "F1", "F1", "F2", "F2", "F3", "F3", "F3", "F4", "F4", "F2", "F2"
  ),
  sex = c("F", "M", "H", "F", "M", "M", "F", "U", "F", "M", "F", "M"),
  stringsAsFactors = FALSE
)
gen2 <- data.frame(
  id = paste0("D", 1L:9L),
  sire = c("C2", "C2", "C5", "C5", "C5", "C6", "C10", "C10", "C12"),
  dam = c("C4", "C4", "C7", "C7", "C7", "C1", "C9", "C9", "C11"),
  sex = c("F", "M", "M", "F", "M", "F", "M", "F", "F"),
  stringsAsFactors = FALSE
)
gen3 <- data.frame(
  id = paste0("E", 1L:4L),
  sire = c("D2", "D2", "D5", "D7"),
  dam = c("D4", "D4", "D8", "D6"),
  sex = c("F", "M", "U", NA_character_),
  stringsAsFactors = FALSE
)
demoPed <- rbind(founders, gen1, gen2, gen3)
demoPed$gen <- findGeneration(demoPed$id, demoPed$sire, demoPed$dam)
nrow(demoPed)
```

    ## [1] 33

``` r

table(demoPed$sex, useNA = "ifany")
```

    ## 
    ##    F    H    M    U <NA> 
    ##   15    1   14    2    1

Sex code **H** (*C3*) and the unrecorded sex code (*E4*, `NA`) each
appear exactly once, alongside code **U** (*C8* and *E3*) and the
ordinary **F**/ **M** codes that make up the rest – enough for every one
of the five node shapes to appear in the diagram below at least once,
across 4 generations and 33 animals.

### Direct Edge Style

``` r

## edgeStyle is now explicit -- Track 2 flipped the package's own default
## to "rectilinear", so this section's own "Direct Edge Style" labeling
## needs edgeStyle = "direct" spelled out rather than relying on the
## (now different) implicit default.
diagramData <- makePedigreeMatingLayout(demoPed, edgeStyle = "direct")
names(diagramData)
```

    ## [1] "nodes"           "edges"           "duplicateToReal"

``` r

nrow(diagramData$nodes)
```

    ## [1] 48

``` r

nrow(diagramData$edges)
```

    ## [1] 53

**makePedigreeMatingLayout** returns a list of three elements: *nodes*
(one row per real animal – shaped by sex, dot = Female, square = Male,
star = Hermaphrodite, triangle = Unknown, diamond = Other/Unrecorded,
with an HTML hover-tooltip giving ID, sex, generation, sire, and dam –
plus one small, unlabeled dot per mating and one extra row per duplicate
occurrence, each carrying its animal’s own shape, label, and tooltip
with a note that it is a duplicate occurrence), *edges*
(parent-to-mating and mating-to-child edges, plus a dashed edge from
each duplicate occurrence back to the real animal), and
*duplicateToReal* (a named lookup from each duplicate occurrence’s id
back to the real animal it represents).

Each node already carries its own fixed **x**/**y** position (computed
by **makePedigreeMatingLayout** itself), so rendering it turns vis.js’s
usual physics/hierarchical layout off rather than turning one on. Piping
*diagramData* into **visNetwork::visNetwork** and the same layout,
export, legend, and search options `R/modPedigree.R` uses reproduces the
Diagram tab’s rendering exactly, including a genuinely working **Export
Diagram (PNG)** button – try it below.[^5]

``` r

visNetwork::visNetwork(diagramData$nodes, diagramData$edges) |>
  visNetwork::visPhysics(enabled = FALSE) |>
  visNetwork::visNodes(physics = FALSE) |>
  visNetwork::visEdges(smooth = FALSE) |>
  visNetwork::visExport(
    type = "png", name = "pedigree_diagram",
    label = "Export Diagram (PNG)"
  ) |>
  visNetwork::visLegend(
    addNodes = data.frame(
      label = c(
        "Female", "Male", "Hermaphrodite", "Unknown", "Other / Unrecorded"
      ),
      shape = c("dot", "square", "star", "triangle", "diamond"),
      stringsAsFactors = FALSE
    ),
    useGroups = FALSE, position = "right", main = "Sex",
    width = 0.28, stepY = 65L
  ) |>
  visNetwork::visOptions(
    nodesIdSelection = list(
      enabled = TRUE,
      # Excludes all 5 of makePedigreeMatingLayout()'s reserved node-id
      # prefixes -- __union_/__dup_ can appear under either edge style;
      # __drop_/__bar_/__proj_ only appear under "rectilinear" (see below).
      # Harmless no-op here since diagramData was built with edgeStyle =
      # "direct" explicit above, but keeps this pattern identical to the
      # rectilinear chunk below and to R/modPedigree.R's own.
      values = diagramData$nodes$id[
        !grepl("^__union_|^__dup_|^__drop_|^__bar_|^__proj_",
               diagramData$nodes$id)
      ]
    ),
    highlightNearest = list(enabled = TRUE, hover = TRUE, degree = 1L,
                             algorithm = "all")
  )
```

The **Select by id** dropdown above the diagram – filtered to real
animals, excluding mating and duplicate-occurrence nodes – lets you jump
straight to a specific animal and dims every node except it and its
direct connections – useful for locating one animal in a diagram this
size, and just as useful in a real diagram of 704 animals like the one
built earlier in this tutorial, where finding one animal by eye is much
harder.

### Rectilinear Edge Style

The diagram above uses the *direct* edge style, requested explicitly.
Omitting `edgeStyle` entirely (or passing `edgeStyle = "rectilinear"`
explicitly, as below) draws the same relationships – same *demoPed*,
same animals, same parent/child/mating structure – with strict right
angles: a horizontal line directly between mates, a vertical drop to
their shared mating dot, a horizontal bar across their children, and a
vertical drop into each child, matching the convention the **kinship2**
R package uses, and matching **makePedigreeMatingLayout**’s own default
(Track 2).

``` r

diagramDataRectilinear <- makePedigreeMatingLayout(demoPed,
                                                     edgeStyle = "rectilinear")
```

    ## Warning: makePedigreeMatingLayout(): 2 same-row edge-node collision(s) could
    ## not be fully resolved (residual after the repair-pass cap, or an unconfirmed
    ## curved-connector heuristic) -- rendered output may still show a straight or
    ## curved edge passing near an unrelated node.

``` r

names(diagramDataRectilinear)
```

    ## [1] "nodes"           "edges"           "duplicateToReal"

``` r

nrow(diagramDataRectilinear$nodes)
```

    ## [1] 98

``` r

nrow(diagramDataRectilinear$edges)
```

    ## [1] 103

98 nodes and 103 edges here, versus 48 and 53 for the same 33-animal
*demoPed* under the *direct* style above – the difference is entirely
extra invisible “waypoint” nodes/edges that carry out the right-angle
routing (zero size, transparent color, excluded from the **Select by
id** dropdown below just like the mating dots above), not any change to
which animals or relationships are shown.[^6] *nodes* and *edges* also
gain extra `color.background`/`color.border` (nodes) and `color` (edges)
columns under *rectilinear* – **visNetwork::visNetwork()** reads these
directly, so no extra rendering code is needed; they exist because
vis.js otherwise defaults every waypoint-touching edge to inheriting its
parent node’s border color, which would route the new right angles in
the wrong color.

Rendering it uses the identical chain as the *direct* style above, with
one difference: **highlightNearest**’s hover-highlight *degree* is
raised from `1` to `6`. Under *rectilinear*, a plain individual’s
nearest graph neighbor is often one of the invisible waypoint nodes
above rather than a visible mating dot, so `degree = 1` (correct for
*direct*) can highlight nothing visible at all on hover; `6` restores
visible feedback for the common case. The live Shiny app’s Diagram tab
applies this same style-aware degree automatically when you switch the
“Diagram Edge Style” toggle.

``` r

visNetwork::visNetwork(diagramDataRectilinear$nodes,
                        diagramDataRectilinear$edges) |>
  visNetwork::visPhysics(enabled = FALSE) |>
  visNetwork::visNodes(physics = FALSE) |>
  visNetwork::visEdges(smooth = FALSE) |>
  visNetwork::visExport(
    type = "png", name = "pedigree_diagram_rectilinear",
    label = "Export Diagram (PNG)"
  ) |>
  visNetwork::visLegend(
    addNodes = data.frame(
      label = c(
        "Female", "Male", "Hermaphrodite", "Unknown", "Other / Unrecorded"
      ),
      shape = c("dot", "square", "star", "triangle", "diamond"),
      stringsAsFactors = FALSE
    ),
    useGroups = FALSE, position = "right", main = "Sex",
    width = 0.28, stepY = 65L
  ) |>
  visNetwork::visOptions(
    nodesIdSelection = list(
      enabled = TRUE,
      values = diagramDataRectilinear$nodes$id[
        !grepl("^__union_|^__dup_|^__drop_|^__bar_|^__proj_",
               diagramDataRectilinear$nodes$id)
      ]
    ),
    highlightNearest = list(enabled = TRUE, hover = TRUE, degree = 6L,
                             algorithm = "all")
  )
```

The live Shiny app also caps how large a pedigree it will render as a
diagram, and the cap itself is style-aware: 750 animals under *direct*,
400 under *rectilinear* – because the rectilinear style’s extra waypoint
nodes make an equivalent-size diagram roughly 1.9x heavier to render.
Both caps are internal to the Shiny app (`R/modPedigree.R`); the
script-callable functions demonstrated here have no such limit of their
own.

### Twin/Zygosity Connectors

A recorded pedigree has no way to represent that two siblings are twins,
or how confident that twin call is – that information has to come from
outside the pedigree, typically a curator-maintained sidecar file.
**readTwinRelations** reads such a file (Excel or delimited text,
columns *id1*, *id2*, *code*) with no validation of its own;
**checkTwinRelations** then checks the result against the pedigree –
both ids must exist, an *MZ twin* (monozygotic) or *DZ twin* (dizygotic)
pair must already share both recorded parents, and an *MZ twin* pair
must additionally match in recorded sex, while a *UZ twin* (zygosity
undetermined) pair has no such precondition. Only the validated result
is accepted by **makePedigreeMatingLayout**’s optional *twinRelations*
argument, which adds a dashed twin-connector edge between the pair,
styled by zygosity code – the same connectors shown in the live app’s
Diagram tab.

``` r

twinPed <- data.frame(
  id = c("F1", "F2", "S1", "S2"),
  sire = c(NA, NA, "F1", "F1"),
  dam = c(NA, NA, "F2", "F2"),
  sex = c("M", "F", "F", "M"),
  stringsAsFactors = FALSE
)
twinPed$gen <- findGeneration(twinPed$id, twinPed$sire, twinPed$dam)
twinRelationsCsv <- tempfile(fileext = ".csv")
writeLines(c("id1,id2,code", "S1,S2,UZ twin"), twinRelationsCsv)
```

*S1* and *S2* are full siblings (both recorded parents are *F1*/*F2*),
so a *UZ twin* call between them passes validation:

``` r

twinRelations <- checkTwinRelations(twinPed, readTwinRelations(twinRelationsCsv))
twinRelations
```

    ##   id1 id2    code
    ## 1  S1  S2 UZ twin

``` r

twinDiagramData <- makePedigreeMatingLayout(twinPed, twinRelations = twinRelations)
twinDiagramData$edges
```

    ##                from               to dashes smooth.enabled smooth.type
    ## 3                F1        __union_1  FALSE             NA        <NA>
    ## 4                F2        __union_1  FALSE             NA        <NA>
    ## 5                S1               S2  14, 8             NA        <NA>
    ## 1         __union_1 __drop___union_1  FALSE             NA        <NA>
    ## 2          __bar_S1               S1  FALSE             NA        <NA>
    ## 31         __bar_S2               S2  FALSE             NA        <NA>
    ## 41         __bar_S1 __drop___union_1  FALSE             NA        <NA>
    ## 51 __drop___union_1         __bar_S2  FALSE             NA        <NA>
    ##    smooth.roundness   color width label
    ## 3                NA    <NA>    NA  <NA>
    ## 4                NA    <NA>    NA  <NA>
    ## 5                NA #009E73    NA     ?
    ## 1                NA #2B7CE9    NA  <NA>
    ## 2                NA #2B7CE9    NA  <NA>
    ## 31               NA #2B7CE9    NA  <NA>
    ## 41               NA #2B7CE9    NA  <NA>
    ## 51               NA #2B7CE9    NA  <NA>

Compare the *edges* table above to what **makePedigreeMatingLayout**
returns for the same pedigree without *twinRelations*: the union/parent
-child edges are identical, but only the version above has the extra row
connecting *S1* directly to *S2* (dashed, labeled `"?"` for the
undetermined zygosity code) – that row exists only because a validated
*twinRelations* table was supplied.

## Genetic Value Analysis

Your genetic value analysis must be carefully performed. The next three
commands set up the entire pedigree for analysis. The first of these
three commands set all of the pedigree members to be part of the
population of interest by setting the *population* column to **TRUE**
for all individuals.

``` r

ped <- setPopulation(breederPed, NULL)
```

Note that a new pedigree object (**ped**) is being created.

``` r

probands <- ped$id[ped$population]
ped <- trimPedigree(probands, ped,
  removeUninformative = FALSE,
  addBackParents = FALSE
)
```

The arguments to **reportGV** are all optional except for *ped*, but you
may often want to use non-default values.

- **ped** Pedigree information in data.frame format

- **guIter** Integer indicating the number of iterations for the
  gene-drop analysis. Default is 1000 iterations

- **guThresh** Integer indicating the threshold number of animals for
  defining a unique allele. Default considers an allele “unique” if it
  is found in only 1 animal.

- **pop** Character vector with animal IDs to consider as the population
  of interest. The default is NULL.

- **byID** Logical variable of length 1 that is passed through to
  eventually be used by alleleFreq(), which calculates the count of each
  allele in the provided vector. If byID is TRUE and ids are provided,
  the function will only count the unique alleles for an individual
  (homozygous alleles will be counted as 1).

``` r

geneticValue <- reportGV(ped,
  guIter = 50L,
  guThresh = 3L,
  byID = TRUE,
  updateProgress = NULL
)
summary(geneticValue)
```

    ## The genetic value report 
    ## Individuals in Pedigree: 3694 
    ## Male Founders: 141
    ## Female Founders: 122
    ## Total Founders: 263 
    ## Founder Equivalents: 241.84 
    ## Founder Genome Equivalents: 164.01 +/- 0.04 
    ## Live Offspring: 4052 
    ## High Value Individuals: 1593 
    ## Low Value Individuals: 729

What happens if we limit our analysis to the trimmed pedigree? Remember
that the trimmed pedigree still contains all of the genetic information
that the full pedigree has for the focal animals.

``` r

trimmedGeneticValue <- reportGV(trimmedPed,
  guIter = 50L,
  guThresh = 3L,
  byID = TRUE,
  updateProgress = NULL
)
summary(trimmedGeneticValue)
```

    ## The genetic value report 
    ## Individuals in Pedigree: 327 
    ## Male Founders: 3
    ## Female Founders: 17
    ## Total Founders: 20 
    ## Founder Equivalents: 109.67 
    ## Founder Genome Equivalents: 47.49 +/- 0.32 
    ## Live Offspring: 321 
    ## High Value Individuals: 233 
    ## Low Value Individuals: 94

It is clear that limiting your analysis to the animals of interest
reduces the effort required to examine the animals of interest.

### Detailed look at the Genetic Value Report object

The names of the object within the genetic value report object
(*trimmedGeneticValue*) can be listed as shown in the next line of code.

``` r

names(trimmedGeneticValue)
```

    ##  [1] "report"          "kinship"         "gu"              "fe"             
    ##  [5] "fg"              "fgSE"            "neGD"            "neSexRatio"     
    ##  [9] "neVariance"      "maleFounders"    "femaleFounders"  "nMaleFounders"  
    ## [13] "nFemaleFounders" "total"

The *report* object (an R dataframe) can in-turn be examined.

``` r

names(trimmedGeneticValue$report) ## column names
```

    ##  [1] "id"              "sex"             "age"             "birth"          
    ##  [5] "exit"            "population"      "origin"          "sire"           
    ##  [9] "dam"             "indivMeanKin"    "zScores"         "gu"             
    ## [13] "guSE"            "totalOffspring"  "livingOffspring" "parentage"      
    ## [17] "flagged"         "value"           "rank"

``` r

nrow(trimmedGeneticValue$report) ## Number of rows
```

    ## [1] 327

The report is more conveniently used as a separate object. The next
section of code rounds some of the numerical values and converts all
columns to characters for display as a table where only the first 10
lines are included.

``` r

rpt <- trimmedGeneticValue[["report"]]
rpt$indivMeanKin <- round(rpt$indivMeanKin, 5L)
rpt$zScores <- round(rpt$zScores, 2L)
rpt$gu <- round(rpt$gu, 5L)
rpt <- toCharacter(rpt)
names(rpt) <- headerDisplayNames(names(rpt))
knitr::kable(rpt[1L:10L, ]) # needs more work for display purposes.
```

| Ego ID | Sex | Age (in years) | Birth Date | Exit Date | Breeding Colony Member | Origin | Sire ID | Dam ID | Individual Mean Kinship | Z-score (Mean Kinship) | Genome Uniqueness (%) | NA | Total Offspring | Living Offspring | NA | NA | Value Designation | Rank |
|:---|:---|---:|:---|:---|:---|:---|:---|:---|---:|---:|---:|---:|---:|---:|:---|:---|:---|---:|
| KZM9RB | M | 30.1 | 1989-05-03 | NA | TRUE |  | UWTJQ0 | BLLUWW | 0.00329 | -2.30 | 92 | 2.618615 | 0 | 0 | one unknown parent | TRUE | High Value | 1 |
| CLSVU6 | F | 23.9 | 1995-08-02 | NA | TRUE |  | ULV9M7 | SUFWJI | 0.00951 | -1.18 | 90 | 2.857143 | 1 | 1 | one unknown parent | FALSE | High Value | 2 |
| 1SPLS8 | F | 7.9 | 2011-07-26 | NA | TRUE |  | U9APLW | 142GKP | 0.01066 | -0.97 | 84 | 3.331973 | 0 | 0 | one unknown parent | FALSE | High Value | 3 |
| WK89I9 | F | 21.1 | 1998-05-26 | NA | TRUE |  | U5QF9U | KZX47Z | 0.01212 | -0.71 | 80 | 3.499271 | 0 | 0 | one unknown parent | FALSE | High Value | 4 |
| 8YP6PA | M | 5.0 | 2014-07-04 | NA | TRUE |  | UD26S6 | PU7RSG | 0.01208 | -0.72 | 77 | 3.559982 | 0 | 0 | one unknown parent | FALSE | High Value | 5 |
| 01QRQ4 | F | 18.2 | 2001-04-04 | NA | TRUE |  | VDBGDP | TH7HTY | 0.00373 | -2.23 | 74 | 3.568570 | 0 | 0 | known | FALSE | High Value | 6 |
| IZDV8K | M | 7.7 | 2011-09-29 | NA | TRUE |  | U5B4PI | PI4VHT | 0.01173 | -0.78 | 74 | 3.568570 | 0 | 0 | one unknown parent | FALSE | High Value | 7 |
| R6HV9A | M | 22.1 | 1997-05-13 | NA | TRUE |  | HPSHXC | BCJJKN | 0.00625 | -1.77 | 73 | 4.783048 | 0 | 0 | known | FALSE | High Value | 8 |
| CFD12A | M | 20.8 | 1998-08-25 | NA | TRUE |  | U79BJ1 | WFQENR | 0.01139 | -0.84 | 71 | 3.525418 | 0 | 0 | one unknown parent | FALSE | High Value | 9 |
| 3MMZD4 | M | 12.2 | 2007-03-24 | NA | TRUE |  | K7900I | 5W3NTM | 0.00536 | -1.93 | 70 | 4.040610 | 0 | 0 | known | FALSE | High Value | 10 |

We start the next lines of code by getting a fresh copy of the genetic
value report since we changed all of the numeric values to characters in
the last section to print the table. These lines demonstrate one way of
extracting the component objects from the *genetic value* object.

``` r

rpt <- trimmedGeneticValue[["report"]]
kmat <- trimmedGeneticValue[["kinship"]]
f <- trimmedGeneticValue[["total"]]
mf <- trimmedGeneticValue[["maleFounders"]]
ff <- trimmedGeneticValue[["femaleFounders"]]
nmf <- trimmedGeneticValue[["nMaleFounders"]]
nff <- trimmedGeneticValue[["nFemaleFounders"]]
fe <- trimmedGeneticValue[["fe"]]
fg <- trimmedGeneticValue[["fg"]]
```

It is informative to examine the distribution of *genetic uniqueness*,
*mean kinship*, and *z-scores* (normalized *mean kinship* values).

Creation of the boxplot for the *genetic uniqueness* values is shown
below.

``` r

gu <- rpt[, "gu"]
guBox <- ggplot(data.frame(gu = gu), aes(x = "", y = gu)) +
  geom_boxplot(
    color = "darkblue",
    fill = "lightblue",
    notch = TRUE, #| fig.alt: >
    #|   Histogram of time between eruptions for Old Faithful.
    #|   It is a bimodal distribution with peaks at 50-55 and
    #|   80-90 minutes.

    outlier.color = "red",
    outlier.shape = 1L
  ) +
  theme_classic() +
  geom_jitter(width = 0.2) +
  coord_flip() +
  ylab("Score") +
  ggtitle("Genetic Uniqueness")
print(guBox)
```

![Genetic Uniqueness Box
Plot.](a2interactive_files/figure-html/genetic-uniqueness-boxplot-1.png)

Extraction of the individual *mean kinship* values and their
corresponding z-scores is shown in the next code chunk.

``` r

mk <- rpt[, "indivMeanKin"]
zs <- rpt[, "zScores"]
```

Creation of boxplots for the *mean kinship* and *z-scores* is left as an
exercise.

## Breeding Group Formation

The primary purpose of **nprcgenekeepr** is to form breeding groups
according to our best information regarding maintaining the genetic
characteristics we desire and the realities associated with other animal
husbandry needs.

There are several options you must consider when forming groups using
**nprcgenekeepr**, which we will examine using code below.

- Animals used to form groups
  - *high-value*: Randomly select from only high-value animals in
    genetic value analysis
  - *all*: Randomly select from all animals in genetic value analysis
  - *candidates*: Use candidate animals entered below to form groups
- Sex ratio
  - Randomly assign animals without regard to sex
  - Use a harem structure with one breeding male per group
  - Specify the sex ratio between 0.5 and 10 (F/M)
- Whether or not to pre-populate (seed) groups with animals of your
  choice
- Number of groups to be formed
- Whether or not to ignore females at or above the minimum parent age
- Number of simulations used to search for the optimal group makeup
- Whether or not kinship coefficients are to be included in results

You decisions regarding each of the above options are expressed in a
call to the function **groupAddAssign**. A complete description of the
function and its arguments is available using the code shown below.

``` r

?groupAddAssign
```

Below is the descriptions of the function parameters extracted from the
documentation near the time this tutorial was prepared.

- **candidates** Character vector of IDs of the animals available for
  use in forming the groups. The animals that may be present in
  currentGroups are not included within candidates.

- **currentGroups** List of character vectors of IDs of animals
  currently assigned to groups. Defaults to a list with character(0) in
  each sub-list element (one for each group being formed) assuming no
  groups are pre-populated.

- **kmat** Numeric matrix of pairwise kinship values. Rows and columns
  are named with animal IDs.

- **ped** Dataframe that is the ‘Pedigree’. It contains pedigree
  information including the IDs listed in candidates.

- **threshold** Numeric value indicating the minimum kinship level to be
  considered in group formation. Pairwise kinship below this level will
  be ignored. The default values is 0.015625.

- **ignore** List of character vectors representing the sex combinations
  to be ignored. If provided, the vectors in the list specify if
  pairwise kinship should be ignored between certain sexes. Default is
  to ignore all pairwise kinship between females.

- **minAge** Integer value indicating the minimum age to consider in
  group formation. Pairwise kinships involving an animal of this age or
  younger will be ignored. Default is 1 year.

- **iter** Integer indicating the number of times to perform the random
  group formation process. Default value is 1000 iterations.

- **numGp** Integer value indicating the number of groups that should be
  formed from the list of IDs. Default is 1.

- **updateProgress** Function or NULL. If this function is defined, it
  will be called during each iteration to update a shiny::Progress
  object.

- **harem** Logical variable when set to TRUE, the formed groups have a
  single male at least minAge old.

- **sexRatio** Numeric value indicating the ratio of females to males x
  from 0.5 to 20 by increments of 0.5.

- **withKin** Logical variable when set to TRUE, the kinship matrix for
  the group is returned along with the group and score. Defaults to not
  return the kinship matrix. This maintains compatibility with earlier
  versions.

We will use the *trimmedPed* pedigree in our code.

For illustration purposes we are going to keep the numbers of
candidates, groups, and iterations fairly small.

We will get first some animal IDs to use for our candidates by selecting
animals at least 2 years old at the time this pedigree was sampled
(01-01-2015).

``` r

candidates <- trimmedPed$id[trimmedPed$birth < as.Date("2013-01-01") &
  !is.na(trimmedPed$birth) &
  is.na(trimmedPed$exit)]
table(trimmedPed$sex[trimmedPed$id %in% candidates])
```

    ## 
    ##   F   M   H   U 
    ## 184  96   0   0

Our candidates are made up of 184 females and 96 males. The parameters
**currentGroups**, **threshold**, **ignore**, **minAge**, **sexRatio**,
**withKin**, and **updateProgress** are allowed to take their default
values. The setting of the **sexRatio** parameter to 0 is ignored in the
following call of the **groupAddAssign** function. This is consistent
with the a value of 0 making little since in a breeding colony.

The empty seventh group at the bottom is evidence that all of the
candidate animals could be placed in a group without exceeding the
default value of 0.015625.

### Harems

The following group assignments will be forming harem groups. This is
done by setting **harem** to . Setting `iter` to 100 or more will
increase optimal composition of breeding groups

``` r

haremGrp <- groupAddAssign(
  kmat = trimmedGeneticValue[["kinship"]],
  ped = trimmedPed,
  candidates = candidates,
  iter = 10L,
  numGp = 6L,
  harem = TRUE
)
haremGrp$group
```

    ## [[1]]
    ##  [1] "S63QDN" "TQEMY6" "XYRDKV" "ZATMEE" "AW400C" "AR5U44" "CHK1ZX" "414N7M"
    ##  [9] "EZ2F8A" "WLMGS1" "MYUMMX" "DHNQ1W" "1KJ2MG" "KZY6PD" "0SGJ12" "CS23RV"
    ## [17] "AP1YLW" "38K2SR" "VWC5ZH" "GTLA8R" "1CIRC9" "YLRNIK" "5KWNMZ" "83HQBN"
    ## [25] "465ERA" "Y6DB6L" "7NE2UT" "EX5K0S" "MTCAIG"
    ## 
    ## [[2]]
    ##  [1] "CHJ9D2" "T3QPW5" "XEC0M5" "YFCIHJ" "S222R3" "BKWE4D" "S3EBGZ" "8JUUJ9"
    ##  [9] "72LYDE" "6X6BG9" "CRPXY7" "FB5L3N" "87AQLF" "QCENKM" "MX4J7G" "BCJJKN"
    ## [17] "WKY2SZ" "QRZK48" "01QRQ4" "SCFSBF" "AFZKBS" "WI38KZ" "DH9WJQ" "BS3RLE"
    ## [25] "Y0TCYX" "30J3CQ" "MFKT9C"
    ## 
    ## [[3]]
    ##  [1] "FX9E4X" "B228Q6" "CMMUKU" "7B9CA6" "N4NV8B" "MH88T6" "I5CI33" "M9PVG5"
    ##  [9] "1SSCJC" "WNEAS6" "46ZHKN" "967Y3D" "2F6J3U" "E5Q33K" "C18V6I" "3YJIMV"
    ## [17] "N5QBWD" "AIHJ8Z" "1CZM30" "DI4AHD" "YTJ2UL" "SHG3RB" "AZ3L0D" "X694YR"
    ## [25] "1FAZ0K" "DRXMW4" "D4B0RM" "Z904TJ" "0XTZQ1" "GCBYDW" "FL170P" "50D77I"
    ## 
    ## [[4]]
    ##  [1] "Z25D52" "NK802Y" "IH1KPA" "PJ72W1" "Q8U9LB" "B134XZ" "RJ4JPC" "MKY9TK"
    ##  [9] "S7IWWA" "QW2Z3R" "D9P18Y" "5W621W" "3GECJJ" "S056D5" "SH3FB7" "HE0SCR"
    ## [17] "H2J6UA" "TYEWF1" "WTE53B" "GIIEUD" "D33J06" "PU7RSG" "3SKITJ" "6F9FB8"
    ## [25] "W6MDVK" "J3F6PD" "R5AYJK" "Q7U139" "7RA57Q" "5EDLL7" "RVHVTZ" "WJXIH9"
    ## [33] "PVY432"
    ## 
    ## [[5]]
    ##  [1] "YDRD81" "G58RGY" "5ERY5Z" "1SPLS8" "6KWVRI" "321LLB" "K3TNHP" "TEACA3"
    ##  [9] "2Z4YLY" "FJS7RQ" "9MG040" "JLFKV8" "N79QXB" "5EDIEE" "13B1QL" "QWKFBH"
    ## [17] "QCA36T" "WK89I9" "I8ABC7" "LYSLPP" "MB6NYQ" "1GF3GM" "DKIM6U" "99BMJW"
    ## [25] "KX0RJ3" "0HYZ23" "QQMBT1" "92UG4N" "GAS52W" "DPXEQE" "G25E3F" "PYPM1W"
    ## [33] "EMV4P6" "TXZUKC" "S5H1GC" "1QVS67" "CLSVU6" "LVYYNY" "5BPBUI"
    ## 
    ## [[6]]
    ##  [1] "XY2CK7" "F45799" "NN3GDQ" "KEA4QG" "LS184H" "9P0DES" "MPIQ4N" "B1WVCN"
    ##  [9] "W5WIRP" "3DTD2N" "5IAFMK" "DCJJYS" "PI4VHT" "0X4W26" "FG0SFA" "7ZNY75"
    ## [17] "G8MCV7" "ZQXZYB" "PBAFJF" "ZPS15A" "ILVQVB" "ZH3YG1" "Q17CG3" "W0GUKI"
    ## [25] "F7I2ED" "AR17R5" "XFWVVX" "1VP3UC" "0IIAEN" "ESUIAF"
    ## 
    ## [[7]]
    ## [1] NA

We can identify and list the males in each group with the following
code.

``` r

sapply(haremGrp$group, function(ids) {
  ids[ids %in% trimmedPed$id[trimmedPed$sex == "M"]]
})
```

    ## [[1]]
    ## [1] "S63QDN"
    ## 
    ## [[2]]
    ## [1] "CHJ9D2"
    ## 
    ## [[3]]
    ## [1] "FX9E4X"
    ## 
    ## [[4]]
    ## [1] "Z25D52"
    ## 
    ## [[5]]
    ## [1] "YDRD81"
    ## 
    ## [[6]]
    ## [1] "XY2CK7"
    ## 
    ## [[7]]
    ## logical(0)

It is easy to notice that the male is listed first within each breeding
group.

We can also see the number of animals and the sex ratios created in each
group. Since these are harem groups the sex ratios are determined by the
number of animals in the individual groups.

``` r

lines <- sapply(haremGrp$group, function(ids) {
  paste0(
    "Count: ", length(ids), " Sex Ratio: ",
    round(calculateSexRatio(ids, trimmedPed), 2)
  )
})
for (line in lines) print(line)
```

    ## [1] "Count: 29 Sex Ratio: 28"
    ## [1] "Count: 27 Sex Ratio: 26"
    ## [1] "Count: 32 Sex Ratio: 31"
    ## [1] "Count: 33 Sex Ratio: 32"
    ## [1] "Count: 39 Sex Ratio: 38"
    ## [1] "Count: 30 Sex Ratio: 29"
    ## [1] "Count: 1 Sex Ratio: Inf"

Examination of this table shows that of the 184 females 156 are
included.

### Controlling Sex Ratios

The following group assignments will be forming harem groups. This is
done by setting **harem** to .

``` r

sexRatioGrp <- groupAddAssign(
  kmat = trimmedGeneticValue[["kinship"]],
  ped = trimmedPed,
  candidates = candidates,
  iter = 10L,
  numGp = 6L,
  sexRatio = 9.0
)
sexRatioGrp$group
```

    ## [[1]]
    ##  [1] "SHG3RB" "8TV4MT" "QRZK48" "D9P18Y" "414N7M" "SH3FB7" "0XTZQ1" "3YJIMV"
    ##  [9] "BKWE4D" "83HQBN" "Z904TJ" "6KWVRI" "NN3GDQ" "KZM9RB" "BS3RLE" "5EDIEE"
    ## [17] "KEA4QG" "DRXMW4" "87AQLF" "2Z4YLY" "0X4W26" "ESUIAF" "1CIRC9" "WNEAS6"
    ## [25] "HLQ9SY" "1SPLS8" "PU7RSG" "S7IWWA" "S222R3" "5BPBUI" "WLMGS1" "J3F6PD"
    ## [33] "MPIQ4N" "WJXIH9" "G2GYST"
    ## 
    ## [[2]]
    ##  [1] "Y6DB6L" "XY2CK7" "1KJ2MG" "XEC0M5" "DHNQ1W" "KZY6PD" "5KWNMZ" "B228Q6"
    ##  [9] "5EDLL7" "Y0TCYX" "CRPXY7" "G8MCV7" "GIIEUD" "R6HV9A" "W6MDVK" "CS23RV"
    ## [17] "1SSCJC" "01QRQ4" "MB6NYQ" "1CZM30" "WKY2SZ" "VWC5ZH" "PBAFJF" "Q7U139"
    ## [25] "CFD12A" "MYUMMX"
    ## 
    ## [[3]]
    ##  [1] "XYRDKV" "5XVTVH" "QCA36T" "RVHVTZ" "3SKITJ" "WK89I9" "FG0SFA" "DI4AHD"
    ##  [9] "WTE53B" "XFWVVX" "C18V6I" "MH88T6" "321LLB" "YHHVC7" "TQEMY6" "Q17CG3"
    ## [17] "50D77I" "AFZKBS" "3DTD2N" "ZATMEE" "30J3CQ" "EMV4P6" "DPXEQE" "8JUUJ9"
    ## [25] "K7900I"
    ## 
    ## [[4]]
    ##  [1] "MKY9TK" "2F1IV1" "1QVS67" "MTCAIG" "1GF3GM" "YFCIHJ" "W0GUKI" "465ERA"
    ##  [9] "EX5K0S" "6F9FB8" "YTJ2UL" "PVY432" "D33J06" "IZDV8K" "99BMJW" "AZ3L0D"
    ## [17] "R5AYJK" "N5QBWD" "NK802Y" "N79QXB" "46ZHKN" "WI38KZ" "72LYDE" "0HYZ23"
    ## [25] "3MMZD4"
    ## 
    ## [[5]]
    ##  [1] "DH9WJQ" "XL658N" "QQMBT1" "X694YR" "AIHJ8Z" "7RA57Q" "LVYYNY" "0IIAEN"
    ##  [9] "1VP3UC" "Q8U9LB" "GCBYDW" "MX4J7G" "FL170P" "T38W6H" "PI4VHT" "S5H1GC"
    ## [17] "5ERY5Z" "JLFKV8" "ZQXZYB" "13B1QL" "7NE2UT" "GTLA8R" "PJ72W1" "DKIM6U"
    ## [25] "LN1DLY" "EZ2F8A" "G25E3F" "KX0RJ3" "7ZNY75" "LS184H" "9MG040" "ZH3YG1"
    ## [33] "N4NV8B" "B134XZ" "Z7NBA2"
    ## 
    ## [[6]]
    ##  [1] "38K2SR" "B2CKHA" "QCENKM" "AP1YLW" "CHK1ZX" "YLRNIK" "QWKFBH" "D4B0RM"
    ##  [9] "GAS52W" "TXZUKC" "G58RGY" "967Y3D" "CLSVU6" "7D09WH" "1FAZ0K" "ILVQVB"
    ## [17] "B1WVCN" "RJ4JPC" "T3QPW5" "S3EBGZ" "AR17R5" "LYSLPP" "F7I2ED" "FJS7RQ"
    ## [25] "5PW7WT" "FB5L3N" "HE0SCR" "H2J6UA" "BCJJKN" "K3TNHP" "S056D5"
    ## 
    ## [[7]]
    ##   [1] "5IAFMK" "6X6BG9" "DCJJYS" "GDXWJ1" "JSAP3H" "TR5L57" "XC304E" "1E8KD1"
    ##   [9] "5KFB90" "A6A1M1" "AEP5EG" "AW400C" "BW10CL" "CHJ9D2" "FTVE03" "IH1KPA"
    ##  [17] "IRFJ09" "KXHGRH" "LMJWTN" "M9PVG5" "Q9LWGX" "RNQU14" "SCFSBF" "TEACA3"
    ##  [25] "TYEWF1" "W5WIRP" "ZPS15A" "09LFE4" "2F6J3U" "3GECJJ" "3QHAFI" "55BPSE"
    ##  [33] "7B9CA6" "8IG767" "9FRCIE" "ER464J" "FFGPS4" "FG6L7S" "NHWTJ9" "P7RBPI"
    ##  [41] "TBCE78" "YI16QD" "4LHK19" "59NYZE" "5IYDXN" "6KLWVC" "80F2MI" "A98D7P"
    ##  [49] "AZ4D19" "BTTHAJ" "CHSCFG" "EEGLWY" "FX9E4X" "G91ZM6" "I5CI33" "I8ABC7"
    ##  [57] "J1R2EW" "LDND6J" "MFKT9C" "MQT080" "NSIC4I" "PHB6TE" "PYPM1W" "QRWYQZ"
    ##  [65] "QW2Z3R" "RY1AZM" "WHQLH5" "WQUN84" "XX0GYV" "YP910X" "0SGJ12" "0V4SAC"
    ##  [73] "0X1RZ9" "3YHBC1" "55VDSQ" "5W621W" "653J82" "6MEP2C" "76DIT4" "80KACX"
    ##  [81] "92UG4N" "9P0DES" "B2YJJP" "CMMUKU" "E3JP0C" "E5Q33K" "F45799" "FLIZQI"
    ##  [89] "GM371F" "MEUZ85" "PA9F3J" "SXSVEH" "TJN1AD" "WNKKW3" "XZH41H" "YDRD81"
    ##  [97] "Z25D52" "ZDRSG0" "3P9BX6" "AR5U44" "DGZLV3" "S63QDN" "ZW2X4N"

Again we can identify and list the males in each group with the
following code.

``` r

sapply(sexRatioGrp$group, function(ids) {
  ids[ids %in% trimmedPed$id[trimmedPed$sex == "M"]]
})
```

    ## [[1]]
    ## [1] "8TV4MT" "KZM9RB" "HLQ9SY" "G2GYST"
    ## 
    ## [[2]]
    ## [1] "XY2CK7" "R6HV9A" "CFD12A"
    ## 
    ## [[3]]
    ## [1] "5XVTVH" "YHHVC7" "K7900I"
    ## 
    ## [[4]]
    ## [1] "2F1IV1" "IZDV8K" "3MMZD4"
    ## 
    ## [[5]]
    ## [1] "XL658N" "T38W6H" "LN1DLY" "Z7NBA2"
    ## 
    ## [[6]]
    ## [1] "B2CKHA" "7D09WH" "5PW7WT"
    ## 
    ## [[7]]
    ##  [1] "GDXWJ1" "JSAP3H" "TR5L57" "XC304E" "1E8KD1" "5KFB90" "A6A1M1" "AEP5EG"
    ##  [9] "BW10CL" "CHJ9D2" "FTVE03" "IRFJ09" "KXHGRH" "LMJWTN" "Q9LWGX" "RNQU14"
    ## [17] "09LFE4" "3QHAFI" "55BPSE" "8IG767" "9FRCIE" "ER464J" "FFGPS4" "FG6L7S"
    ## [25] "NHWTJ9" "P7RBPI" "TBCE78" "YI16QD" "4LHK19" "59NYZE" "5IYDXN" "6KLWVC"
    ## [33] "80F2MI" "A98D7P" "AZ4D19" "BTTHAJ" "CHSCFG" "EEGLWY" "FX9E4X" "G91ZM6"
    ## [41] "J1R2EW" "LDND6J" "MQT080" "NSIC4I" "PHB6TE" "QRWYQZ" "RY1AZM" "WHQLH5"
    ## [49] "WQUN84" "XX0GYV" "YP910X" "0V4SAC" "0X1RZ9" "3YHBC1" "55VDSQ" "653J82"
    ## [57] "6MEP2C" "76DIT4" "80KACX" "B2YJJP" "E3JP0C" "FLIZQI" "GM371F" "MEUZ85"
    ## [65] "PA9F3J" "SXSVEH" "TJN1AD" "WNKKW3" "XZH41H" "YDRD81" "Z25D52" "ZDRSG0"
    ## [73] "3P9BX6" "DGZLV3" "S63QDN" "ZW2X4N"

We can also see the number of animals and the sex ratios created in each
group.

``` r

lines <- sapply(sexRatioGrp$group, function(ids) {
  paste0(
    "Count: ", length(ids), " Sex Ratio: ",
    round(calculateSexRatio(ids, trimmedPed), 2L)
  )
})
for (line in lines) print(line)
```

    ## [1] "Count: 35 Sex Ratio: 7.75"
    ## [1] "Count: 26 Sex Ratio: 7.67"
    ## [1] "Count: 25 Sex Ratio: 7.33"
    ## [1] "Count: 25 Sex Ratio: 7.33"
    ## [1] "Count: 35 Sex Ratio: 7.75"
    ## [1] "Count: 31 Sex Ratio: 9.33"
    ## [1] "Count: 103 Sex Ratio: 0.36"

Examination of this table shows that of the 184 females 239 are
included.

## Individual Mate-Pair Analysis

**groupAddAssign**, used throughout the previous section, forms whole
breeding groups. **reportMatePairs** instead answers a narrower question
– for a candidate population, which individual sire/dam pairs are even
eligible to be considered (opposite sex, both above **minAge**), and
what does every available kinship/genetic-value signal say about each
pair? It composes the package’s existing pair-eligibility machinery into
a single report, returning two tables: *pairs*, one row per eligible
sire/dam combination, and *excluded*, one row per pair dropped and why.
It computes no composite ranking score of its own – sort or filter the
returned columns as your own workflow requires. Marker-based kinship
(**markerKinship**’s output) and each parent’s genetic-value context
(*indivMeanKin*/*gu*, from **reportGV**’s report) can both be supplied
as optional enrichment and default to `NA` when not.

We reuse the *candidates* vector already built above, restricted further
to a small illustrative slice – one male and seven females – so the
output stays readable; a full call against all 280 candidates would
return one row per opposite-sex, age-eligible pair, which quickly runs
into the thousands.

``` r

smallCandidates <- head(candidates, 8L)
trimmedPed[trimmedPed$id %in% smallCandidates, c("id", "sex", "age")]
```

    ##          id sex  age
    ## 1637 WTE53B   F 26.1
    ## 1669 01QRQ4   F 18.2
    ## 1743 CLSVU6   F 23.9
    ## 1887 1SPLS8   F  7.9
    ## 1934 5IAFMK   F 32.0
    ## 2072 HLQ9SY   M 26.1
    ## 2234 XFWVVX   F 28.0
    ## 2337 6X6BG9   F 22.1

``` r

matePairs <- reportMatePairs(trimmedPed, trimmedGeneticValue[["kinship"]],
                              geneticValues = trimmedGeneticValue,
                              populationIds = smallCandidates)
matePairs$pairs
```

    ##   sireId  damId  kinship markerKinship sireIndivMeanKin sireGu damIndivMeanKin
    ## 1 HLQ9SY 01QRQ4 0.000000            NA       0.01162094     34     0.003727064
    ## 2 HLQ9SY CLSVU6 0.000000            NA       0.01162094     34     0.009512525
    ## 3 HLQ9SY 1SPLS8 0.000000            NA       0.01162094     34     0.010663266
    ## 4 HLQ9SY 5IAFMK 0.000000            NA       0.01162094     34     0.021478402
    ## 5 HLQ9SY XFWVVX 0.000000            NA       0.01162094     34     0.011650809
    ## 6 HLQ9SY 6X6BG9 0.015625            NA       0.01162094     34     0.023037318
    ##   damGu
    ## 1    74
    ## 2    90
    ## 3    84
    ## 4    28
    ## 5    24
    ## 6    13

With only one male in this slice, every eligible pair shares the same
sire, so *sireIndivMeanKin*/*sireGu* are identical across rows (both
come from *trimmedGeneticValue*’s report for that one animal);
*damIndivMeanKin*/ *damGu* vary by dam. *markerKinship* is `NA`
throughout, since no marker genotype matrix was supplied to this call.

**exclude** removes a specific id from consideration and records why in
the *excluded* table – useful when a curator already knows a particular
animal is unavailable this cycle, independent of age or sex eligibility.

``` r

matePairsExcluded <- reportMatePairs(trimmedPed, trimmedGeneticValue[["kinship"]],
                                      geneticValues = trimmedGeneticValue,
                                      populationIds = smallCandidates,
                                      exclude = matePairs$pairs$damId[1L])
matePairsExcluded$excluded
```

    ##   sireId  damId        reason
    ## 1 HLQ9SY 01QRQ4 user-excluded

One caveat worth knowing before relying on **minAge** alone to bound a
real-world call: a missing (`NA`) recorded age *passes* the age screen
rather than failing it, on the premise that an unknown age should not
silently disqualify an otherwise-eligible animal. **populationIds**, not
**minAge**, is the reliable way to bound which candidates a call
considers.

## Pedigree Errors

As stated earlier you can see which types of errors are detected by
*qcStudbook* by looking at names returned by *getEmptyErrorLst()* as
shown below.

``` r

names(getEmptyErrorLst())
```

    ##  [1] "failedDatabaseConnection" "missingColumns"          
    ##  [3] "invalidDateRows"          "suspiciousParents"       
    ##  [5] "femaleSires"              "maleDams"                
    ##  [7] "sireAndDam"               "duplicateIds"            
    ##  [9] "invalidIdChars"           "changedCols"

Each is defined below.

| Error | Definition |
|:---|:---|
| failedDatabaseConnection | Database connection failed: configuration or permissions are invalid |
| missingColumns | Columns that must be within the pedigree file are missing. |
| invalidDateRows | Values, which are supposed to be dates, cannot be interpreted as a date. |
| suspiciousParents | Parents were too young on the date of birth of to have been the parent. |
| femaleSires | Individuals listed as female or hermaphroditic and as a sire. |
| maleDams | Individuals are listed as male and as a dam. |
| sireAndDam | Individuals who are listed as both a sire and a dam. |
| duplicateIds | IDs listed more than once. |
| invalidIdChars | IDs (id, sire, or dam) that contain a period (‘.’), which is not allowed. |
| changedCols | Columns that have been changed to conform to internal naming conventions and what they were changed to. |

We are going to use the small imaginary pedigree listed below that has
multiple errors to discuss pedigree error detection and reporting. First
note the birth dates of ego_id *o4* (2006-04-13) and the purported sire
*s2* (2006-06-19). Note also the purported birth date of the *d2* and
the birth dates of her offspring. Obviously dates or IDs may be
incorrect.

This is the pedigree. *(We will discuss the column names shortly.)*

``` r

knitr::kable(nprcgenekeepr::pedOne)
```

| ego_id | sire.id | dam_id | sex | birth_date |
|:-------|:--------|:-------|:----|:-----------|
| s1     | NA      | NA     | F   | 2000-07-18 |
| d1     | NA      | NA     | M   | 2003-04-13 |
| s2     | NA      | NA     | M   | 2006-06-19 |
| d2     | NA      | NA     | F   | 2015-09-16 |
| o1     | s1      | d1     | F   | 2015-02-04 |
| o2     | s1      | d2     | F   | 2009-03-17 |
| o3     | s2      | d2     | F   | 2012-04-11 |
| o4     | s2      | d2     | M   | 2006-04-13 |

If we try to convert this pedigree file into the standardized studbook
format, we are going to get an error message and the creation of a file
in the R sessions temporary directory that lists the records that have
generated the errors.

``` r

pedOne <- nprcgenekeepr::pedOne # put it in the local environment
ped <- qcStudbook(pedOne, minSireAge = 0.0, minDamAge = 0.0)
```

    ## Error in `qcStudbook()`:
    ## ! Parents with low age at birth of offspring are listed in /tmp/RtmptISgPK/lowParentAge.csv.

The contents of *lowParentAge.csv* is shown below.

| dam | sire | id  | sex | birth      | recordStatus | exit | sireBirth  | damBirth   | sireAge | damAge |
|:----|:-----|:----|:----|:-----------|:-------------|:-----|:-----------|:-----------|--------:|-------:|
| d2  | s1   | o2  | F   | 2009-03-17 | original     | NA   | 2000-07-18 | 2015-09-16 |    8.66 |  -6.50 |
| d2  | s2   | o3  | F   | 2012-04-11 | original     | NA   | 2006-06-19 | 2015-09-16 |    5.81 |  -3.43 |
| d2  | s2   | o4  | M   | 2006-04-13 | original     | NA   | 2006-06-19 | 2015-09-16 |   -0.18 |  -9.43 |

Examination of the ages of the parents reveals the issues being
reported.

We can remove the errors by changing the birth dates of *o4* from
2006-04-13 to 2015-09-16 and of *d2* from 2015-09-16 to 2006-04-13.

``` r

pedOne$birth_date[pedOne$ego_id == "o4"] <- as.Date("2015-09-16")
pedOne$birth_date[pedOne$ego_id == "d2"] <- as.Date("2006-04-13")
```

Note the changes made to the column names between the original
**pedOne** pedigree and the pedigree (**ped**) we get from
**qcStudbook**. We have chosen to limit the displayed pedigree by
selecting the *ego_id*’s and *id*’s in **pedOne** and **ped**
respectively.

``` r

ped <- qcStudbook(pedOne, minSireAge = 0.0, minDamAge = 0.0)
ped[ped$id %in% c("s2", "d2", "o3", "o4"), ]
```

    ##   id sire  dam sex gen      birth exit  age recordStatus
    ## 2 d2 <NA> <NA>   F   0 2006-04-13 <NA> 20.4     original
    ## 4 s2 <NA> <NA>   M   0 2006-06-19 <NA> 20.2     original
    ## 7 o3   s2   d2   F   1 2012-04-11 <NA> 14.4     original
    ## 8 o4   s2   d2   M   1 2015-09-16 <NA> 10.9     original

However, the preferred method of creating the standardized studbook
format with **qcStudbook** is to examine all errors found and correcting
them before proceeding. This is done by explicitly requesting that all
aspects inconsistent with the studbook format be identified by setting
*reportChanges* and *reportErrors* to .

``` r

errorList <- qcStudbook(pedOne,
  minSireAge = 0.0, minDamAge = 0.0, reportChanges = TRUE,
  reportErrors = TRUE
)
summary(errorList)
```

    ## Error: The animal listed as a sire and also listed as a female is: s1.
    ## Error: The animal listed as a dam and also listed as a male is: d1.
    ## Change: The column where period was removed is: sire.id to sireid.
    ## Change: The columns where underscore was removed are: ego_id, dam_id, and birth_date to egoid, damid, and birthdate.
    ## Change: The column changed from: egoid to id.
    ## Change: The column changed from: sireid to sire.
    ## Change: The column changed from: damid to dam.
    ## Change: The column changed from: birthdate to birth.
    ## 
    ## Please check and correct the pedigree file.
    ## 

We will discuss each of these newly identified errors in a moment,
however, let’s look at shortening this report, because often you will
not be interested in the more trivial changes to the column names made
by **qcStudbook** and in those cases you simply choose not to report
changes to the column names as is shown here by setting *reportChanges*
to . For this illustration, we are going to bring back the original copy
of **pedOne** to see how the suspicious parents are reported by the
**summary** function.

``` r

pedOne <- nprcgenekeepr::pedOne
errorList <- qcStudbook(pedOne,
  minSireAge = 0L, minDamAge = 0L, reportChanges = FALSE,
  reportErrors = TRUE
)
options(width = 90L)
summary(errorList)
```

    ## Error: The animal listed as a sire and also listed as a female is: s1.
    ## Error: The animal listed as a dam and also listed as a male is: d1.
    ## 
    ## Please check and correct the pedigree file.
    ##  
    ## Animal records where parent records are suspicous because of dates.
    ## One or more parents appear too young at time of birth.
    ##   dam sire id sex      birth recordStatus exit  sireBirth   damBirth sireAge damAge
    ## 2  d2   s1 o2   F 2009-03-17     original <NA> 2000-07-18 2015-09-16    8.66   -6.5
    ## 3  d2   s2 o3   F 2012-04-11     original <NA> 2006-06-19 2015-09-16    5.81   -3.4
    ## 4  d2   s2 o4   M 2006-04-13     original <NA> 2006-06-19 2015-09-16   -0.18   -9.4

The first two errors mentioned are of particular interest. Currently
**qcStudbook** automatically changes the sex of dams to *F* (female) and
sires to *M* (male) when **reportErrors** is set to .

## Genetic Loops

This feature is not supported within the Shiny application and is not
fully implemented.

To use the **findLoops** function run the following code and select a
pedigree as your input file that has a loop in it. We are continuing to
use the example pedigree that comes with the software
*Example_Pedigree.csv*.

``` r

exampleTree <- createPedTree(breederPed)
exampleLoops <- findLoops(exampleTree)
```

You can count how many loops you have with the following code.

``` r

length(exampleLoops)
```

    ## [1] 3694

``` r

nLoops <- countLoops(exampleLoops, exampleTree)
sum(unlist(nLoops[nLoops > 0L]))
```

    ## [1] 258

You can list the first 10 sets of ids, sires and dams in loops with the
following line of code:

``` r

examplePedigree[unlist(exampleLoops), c("id", "sire", "dam")][1L:10L, ]
```

    ##          id   sire    dam
    ## 2519 V49H3Y UFI88T 9T7Y2Z
    ## 2572 61FUGE UDQ5WC GL88CF
    ## 2695 LWJ3A5 KZM9RB GCBYDW
    ## 2722 RNQU14 H2RDE2 DKIM6U
    ## 2752 L9M1DC 3PU50K WFQENR
    ## 2755 Q8U9LB 3PU50K CLSVU6
    ## 2905 FVJ14K UXC40T L5VC2M
    ## 2922 531HAC UMV4BE 5DIPZN
    ## 2924 85ESBB UQFY9C Q2RK1E
    ## 2941 0VLW56 6KPKH7 MMEHXV

## Marker Genetics

Everything up to this point has estimated kinship and diversity from a
*recorded* pedigree – **kinship**, **reportGV**, and the rest all assume
the sire/dam relationships in your pedigree data are correct. The
functions in this section instead estimate relatedness, heterozygosity,
parentage consistency, and between-center differentiation directly from
a marker genotype panel (e.g. a SNP or STR panel), independent of any
known pedigree. This is the same functionality behind the Shiny
application’s **Marker Genetics** tab – see the “Marker Genetics”
section of the *colony-manager-guide* article for the equivalent
point-and-click workflow and screenshots. The small example genotypes
below match the ones used there, so the numbers you see printed here are
the same numbers shown in that article’s tables.

### Preparing a Marker Genotype File

A marker genotype file is long-format: one row per *id* x *locus*, with
columns *id*, *locus*, *allele1*, and *allele2*. (This is a different
shape from the single-locus *first_name*/*second_name* genotype format
used earlier by **addGenotype**/**geneDrop** – the two are unrelated.)
You would normally read this from a CSV file with **read.csv**, the same
way the pedigree file was read in at the start of this tutorial; here we
build a small example directly, for a parent (*P*), her offspring (*C*),
and an unrelated founder (*U*), genotyped at 10 biallelic loci.

``` r

markerGenotype <- data.frame(
  id = c(rep("P", 10L), rep("C", 10L), rep("U", 10L)),
  locus = rep(paste0("L", 1L:10L), 3L),
  allele1 = c(
    "A", "A", "A", "B", "A", "A", "B", "A", "A", "A",
    "A", "A", "B", "A", "A", "A", "B", "A", "A", "A",
    "A", "B", "A", "A", "A", "A", "A", "B", "A", "B"
  ),
  allele2 = c(
    "A", "B", "B", "B", "A", "B", "B", "B", "A", "B",
    "B", "A", "B", "B", "A", "B", "B", "B", "B", "A",
    "B", "B", "A", "B", "B", "A", "B", "B", "B", "B"
  ),
  stringsAsFactors = FALSE
)
```

**checkMarkerGenotypeFile** validates the column shape and rejects any
locus with more than two distinct alleles (the estimators below all
require biallelic markers). **buildMarkerGenotypeMatrix** then pivots
the checked long-format table into the wide *id* x *locus* matrix the
rest of this section’s functions consume, one cell per individual/locus
combination (e.g. `"A/B"`), or `NA` where that individual has no
genotype call at that locus.

``` r

markerGenotype <- checkMarkerGenotypeFile(markerGenotype)
genotypeMatrix <- buildMarkerGenotypeMatrix(markerGenotype)
genotypeMatrix
```

    ##   L1    L2    L3    L4    L5    L6    L7    L8    L9    L10  
    ## P "A/A" "A/B" "A/B" "B/B" "A/A" "A/B" "B/B" "A/B" "A/A" "A/B"
    ## C "A/B" "A/A" "B/B" "A/B" "A/A" "A/B" "B/B" "A/B" "A/B" "A/A"
    ## U "A/B" "B/B" "A/A" "A/B" "A/B" "A/A" "A/B" "B/B" "A/B" "B/B"

### Marker-Based Kinship

**markerKinship** estimates pairwise kinship directly from
*genotypeMatrix*, using the “KING-robust” estimator (Manichaikul et al.
2010) – the same estimator implemented by KING, PLINK2, and
`SNPRelate::snpgdsIBDKING`. It never looks at recorded parentage, so it
is useful as an independent cross-check on the pedigree-based kinship
computed by **kinship**/**reportGV** above.

``` r

markerKmat <- markerKinship(genotypeMatrix)
markerKmat
```

    ##     P    C    U
    ## P 0.5  0.2  0.0
    ## C 0.2  0.5 -0.3
    ## U 0.0 -0.3  0.5

*P* and *C* are the true parent/offspring pair in this example, and
their marker-based kinship (0.2) is clearly higher than either pair
involving the unrelated founder *U*. The KING-robust estimator is not
bounded below by zero – *C* and *U*’s negative estimate here is
informative (more divergent ancestry than the reference panel), not an
error.

### Heterozygosity Diagnostic

**markerObservedHeterozygosity** computes, per animal, the fraction of
its genotyped loci at which it is heterozygous (*Ho*).
**markerExpectedHeterozygosity** computes Nei’s (1973) gene diversity
(*He*) at each locus from the population’s allele frequencies, plus the
unweighted mean across loci as a population-wide summary – the standard
observed-vs-expected heterozygosity diagnostic. Both take the same
*genotypeMatrix* shape as **markerKinship**. This example uses three
animals (*X*, *Y*, *Z*) genotyped at 4 loci, with *Y* missing a call at
*L4*.

``` r

hetGenotype <- data.frame(
  id = c(rep("X", 4L), rep("Y", 3L), rep("Z", 4L)),
  locus = c(paste0("L", 1L:4L), paste0("L", c(1L, 2L, 3L)), paste0("L", 1L:4L)),
  allele1 = c("A", "A", "A", "A", "A", "A", "B", "B", "A", "A", "A"),
  allele2 = c("A", "B", "B", "B", "B", "A", "B", "B", "A", "B", "A"),
  stringsAsFactors = FALSE
)
hetGenotype <- checkMarkerGenotypeFile(hetGenotype)
hetMatrix <- buildMarkerGenotypeMatrix(hetGenotype)
```

``` r

markerObservedHeterozygosity(hetMatrix)
```

    ##         X         Y         Z 
    ## 0.7500000 0.3333333 0.2500000

``` r

markerExpectedHeterozygosity(hetMatrix)
```

    ## $perLocus
    ##        L1        L2        L3        L4 
    ## 0.5000000 0.2777778 0.4444444 0.3750000 
    ## 
    ## $meanHe
    ## [1] 0.3993056

Note *Y*’s observed heterozygosity is computed over its own 3 genotyped
loci (1/3), not over all 4 – a missing call at one locus does not lower
an animal’s own *Ho*, since the denominator is always that animal’s own
non-missing loci, not the full panel.

### Parentage Verification (Mendelian Exclusion)

**markerParentageExclusion** cross-references a pedigree’s recorded
dam/sire against each animal’s marker genotype and flags a recorded
parent whose genotype evidence contradicts simple Mendelian inheritance
– directly useful for catching the kind of dam/sire misidentification a
paper pedigree alone cannot reveal. A locus counts as a conflict only
when the animal and the candidate parent are each homozygous for a
*different* allele (“opposite homozygotes”); by default
(`maxExclusions = 2`) a recorded parent is only flagged once 3 or more
such conflicts accumulate, since a single mismatching locus can arise
from ordinary genotyping error even for a true parent.

We reuse the P/C/U *genotypeMatrix* from above, with a pedigree in which
*C*’s recorded dam (*P*) is correct, but *C*’s recorded sire has been
(deliberately, for this example) misrecorded as the unrelated *U*.

``` r

pedigree <- data.frame(id = c("P", "C", "U"), sire = c(NA, "U", NA),
                        dam = c(NA, "P", NA), stringsAsFactors = FALSE)
```

``` r

markerParentageExclusion(genotypeMatrix, pedigree)
```

    ##   id parentId role exclusionCount nLoci flagged
    ## 1  C        P  dam              0    10   FALSE
    ## 2  C        U sire              3    10    TRUE

*C*’s true dam (*P*) has zero exclusions and is not flagged; *C*’s
falsely recorded sire (*U*) has 3 exclusions, exceeding the default
`maxExclusions = 2`, and is correctly flagged.

### Candidate-Parent Likelihood Ranking

Once **markerParentageExclusion** has flagged a recorded parent as
Mendelian-inconsistent with its offspring’s genotype,
**markerParentageLikelihood** picks up the investigation: it ranks
candidate replacement parents using a CERVUS-style multilocus
likelihood-ratio (LOD) score (Meagher & Thompson 1986; Marshall, Slate,
Kruuk & Pemberton 1998), the same approach independently validated in a
real captive macaque colony by de Groot et al. (2025). It is
deliberately report-only – it never rewrites
*pedigree$`sire_/_pedigree`$dam*; a flagged parent is a curator
decision, not something to silently overwrite. Candidates default to
**getPotentialParents**’s own demographically -eligible list (breeding
age, gestation window, proven-breeder preference) for the flagged
offspring/role, or can be supplied explicitly, as below.

``` r

likelihoodGenotype <- data.frame(
  id = c("O", "O", "D", "D", "C1", "C1", "C2", "C2"),
  locus = c("L1", "L2", "L1", "L2", "L1", "L2", "L1", "L2"),
  allele1 = c("A", "A", "A", "A", "A", "A", "B", "B"),
  allele2 = c("A", "B", "B", "A", "A", "B", "B", "B"),
  stringsAsFactors = FALSE
)
likelihoodMatrix <- buildMarkerGenotypeMatrix(likelihoodGenotype)
likelihoodPed <- data.frame(id = "O", sire = "C2", dam = "D",
                             stringsAsFactors = FALSE)
```

*O* is the offspring, recorded dam *D*, recorded sire *C2*; *C1* is an
unrecorded candidate. **markerParentageExclusion** first shows why *C2*
is worth a second look:

``` r

markerParentageExclusion(likelihoodMatrix, likelihoodPed)
```

    ##   id parentId role exclusionCount nLoci flagged
    ## 1  O        D  dam              0     2   FALSE
    ## 2  O       C2 sire              1     2   FALSE

*C2*’s single exclusion (of 2 loci) falls within the default
`maxExclusions = 2` tolerance, so it is not `flagged` here – but 1
conflicting locus is still worth ranking against alternatives:

``` r

markerParentageLikelihood(likelihoodMatrix, likelihoodPed, id = "O",
                           role = "sire", candidates = c("C1", "C2"),
                           minLoci = 1L)
```

    ##   id role candidateId       LOD delta nLociUsed excluded lowPower
    ## 1  O sire          C1 0.4700036   Inf         2    FALSE    FALSE
    ## 2  O sire          C2      -Inf    NA         2    FALSE    FALSE

*C1* – genetically identical to *O* at both loci – decisively outranks
the recorded sire *C2* (`LOD` 0.47 vs `-Inf`). Notice *C2*’s `excluded`
column is `FALSE` (the same tolerant test as above) even though its
`LOD` is `-Inf`: a single opposite-homozygote locus (*C2* is B/B at
*L1*, where *O* is A/A) is a zero-tolerance Mendelian impossibility
under the likelihood model, with no allowance for ordinary genotyping
error the way the exclusion count is. `delta` for *C1* is `Inf`, not a
large finite number – the gap down to a `-Inf`-ranked neighbor is
reported as infinite, by design.

### Validating a Cross-Center Mapping

When an animal transfers between centers that use independent id
namespaces, the receiving center often has no way to know the animal’s
real parents and records it as an artificial founder – losing its actual
lineage even though the originating center’s records still have it.
**resolveCrossCenterIds** (next) fixes this by merging two centers’
pedigrees given a curator-confirmed id mapping, but it
[`stop()`](https://rdrr.io/r/base/stop.html)s on the *first* problem it
finds in that mapping. **checkCrossCenterMapping** shares the same
validation logic but never stops early – it returns every problem found
as a row in a data.frame, so a curator sees everything wrong with a
mapping in one call rather than a stop-fix-rerun cycle, one problem at a
time.

In this example, *T1* (in Center A’s pedigree, *pedA*) and *X9* (in
Center B’s pedigree, *pedB*) are the same physical animal – Center B
recorded it as a founder (both parents `NA`) because it never knew
*T1*’s real parents, which Center A does have.

``` r

pedA <- data.frame(
  id = c("P1", "P2", "T1"), sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
  stringsAsFactors = FALSE
)
pedB <- data.frame(
  id = c("X9", "O1"), sire = c(NA, "X9"), dam = c(NA, NA),
  stringsAsFactors = FALSE
)
mapping <- data.frame(idA = "T1", idB = "X9", stringsAsFactors = FALSE)
```

``` r

checkCrossCenterMapping(pedA, pedB, mapping)
```

    ## [1] type    ids     message
    ## <0 rows> (or 0-length row.names)

Zero rows means the mapping is clean – **resolveCrossCenterIds** can be
called on the same three inputs without error, as it is below. A mapping
with real problems (here, *idB* `"X9"` mapped twice, and an *idA* value
`"NOPE"` that doesn’t exist in *pedA*) instead reports both problems at
once, rather than only the first:

``` r

badMapping <- data.frame(idA = c("T1", "NOPE"), idB = c("X9", "X9"),
                          stringsAsFactors = FALSE)
checkCrossCenterMapping(pedA, pedB, badMapping)
```

    ##         type  ids                                                       message
    ## 1 uniqueness   X9                        Duplicate idB value(s) in mapping: X9.
    ## 2  existence NOPE mapping references idA value(s) not present in pedA$id: NOPE.

One subtlety: a genuine undeclared id collision between the two centers
(an id present in both *pedA* and *pedB* but never named in *mapping*)
is only ever reported once every problem above is already clean – a
collision check on a mapping that doesn’t resolve to real pedigree rows
would be meaningless. A clean result from this function is what licenses
trusting the absence of a collision, not merely the absence of a
`"collision"` row in a dirty one.

### Cross-Center Identity Linking

With the mapping validated above, **resolveCrossCenterIds** merges the
two centers’ pedigrees into one, preferring whichever side actually
recorded a parent.

``` r

resolveCrossCenterIds(pedA, pedB, mapping)
```

    ##   id sire  dam
    ## 1 P1 <NA> <NA>
    ## 2 P2 <NA> <NA>
    ## 3 T1   P1   P2
    ## 4 O1   T1 <NA>

The merged pedigree has a single row for *T1* with its real parents
(*P1*, *P2*) intact, and *O1* – recorded at Center B as *X9*’s offspring
– now correctly points to *T1* as its sire.

### Cross-Center Differentiation (Fst)

**markerFst** takes a different, population-level view: rather than
linking individual animals across centers, it estimates Hudson’s Fst
(Hudson, Slatkin & Maddison 1992, as given in closed form by Bhatia et
al. 2013) – how differentiated two centers’ colonies are in allele
frequency, at each locus genotyped by both, plus a single pooled summary
across loci. The pooled value is a ratio of summed numerators and
denominators, not a mean of the per-locus ratios, which Bhatia et
al. show is materially biased.

``` r

centerAGenotype <- data.frame(
  id = c(rep("CA1", 2L), rep("CA2", 2L), rep("CA3", 2L), rep("CA4", 2L)),
  locus = rep(c("L1", "L2"), 4L),
  allele1 = c("A", "A", "A", "A", "A", "A", "B", "A"),
  allele2 = c("A", "A", "A", "B", "B", "B", "B", "A"),
  stringsAsFactors = FALSE
)
centerBGenotype <- data.frame(
  id = c(rep("CB1", 2L), rep("CB2", 2L), rep("CB3", 2L),
         rep("CB4", 2L), rep("CB5", 2L), rep("CB6", 2L)),
  locus = rep(c("L1", "L2"), 6L),
  allele1 = c("A", "B", "B", "A", "A", "B", "B", "B", "A", "B", "B", "A"),
  allele2 = c("B", "B", "B", "B", "B", "B", "B", "B", "A", "B", "B", "B"),
  stringsAsFactors = FALSE
)
matrixA <- buildMarkerGenotypeMatrix(checkMarkerGenotypeFile(centerAGenotype))
matrixB <- buildMarkerGenotypeMatrix(checkMarkerGenotypeFile(centerBGenotype))
```

``` r

markerFst(matrixA, matrixB)
```

    ## $perLocus
    ##         L1         L2 
    ## 0.05794206 0.45129870 
    ## 
    ## $pooledFst
    ## [1] 0.2749664

*L2* shows substantially more differentiation between the two centers
than *L1* does in this example; the pooled value summarizes both loci
into one number for a quick between-center comparison.

### Multiallelic Marker Panels and Locus Metadata

Everything above assumed a biallelic panel – **checkMarkerGenotypeFile**
rejects any locus with more than two distinct alleles, since the
KING-robust kinship estimator requires it. Real microsatellite/STR
panels are routinely multiallelic, though, so the package provides a
second, more permissive validator for the linkage-aware metrics below:
**checkLinkageMarkerGenotypeFile** keeps the same structural checks
(column shape, no duplicate *id* x *locus* rows) but drops the biallelic
restriction.

``` r

strGenotype <- data.frame(
  id = c("W", "X", "Y", "Z"),
  locus = c("L1", "L1", "L1", "L1"),
  allele1 = c("A", "A", "A", "A"),
  allele2 = c("B", "C", "A", "D"),
  stringsAsFactors = FALSE
)
```

This locus has 4 distinct alleles (A, B, C, D) across the four animals –
**checkLinkageMarkerGenotypeFile** accepts it:

``` r

checkLinkageMarkerGenotypeFile(strGenotype)
```

    ##   id locus allele1 allele2
    ## 1  W    L1       A       B
    ## 2  X    L1       A       C
    ## 3  Y    L1       A       A
    ## 4  Z    L1       A       D

The same data fed to **checkMarkerGenotypeFile** instead fails, exactly
as that function is designed to:

``` r

checkMarkerGenotypeFile(strGenotype)
```

    ## Error in `checkMarkerGenotypeFile()`:
    ## ! Marker genotype file has one or more loci with more than two distinct alleles (the KING-robust estimator requires biallelic markers): L1.

The metrics below also need per-locus genomic position information,
which real curated panels rarely have complete records for.
**checkLocusMetadata** validates a *locus*/*chrom*/*pos* (optionally
*cM*) sidecar table and classifies each locus’s own coverage as `"full"`
(chromosome and position both known), `"partial"` (one of the two), or
`"none"` (neither) – downstream functions then decide for themselves
which loci they can use, rather than requiring complete metadata up
front.

``` r

locusMetadata <- data.frame(
  locus = c("L1", "L2", "L3"),
  chrom = c("1", "1", NA),
  pos   = c(1000000, NA, NA),
  stringsAsFactors = FALSE
)
checkLocusMetadata(locusMetadata)
```

    ##   locus chrom   pos coverage
    ## 1    L1     1 1e+06     full
    ## 2    L2     1    NA  partial
    ## 3    L3  <NA>    NA     none

*L1* has both chromosome and position and is `"full"`; *L2* has only a
chromosome (`"partial"`); *L3* has neither (`"none"`).
**computeGenomicROH** (the F_ROH tab’s estimator) uses only
`"full"`-coverage loci and drops the rest with a named warning;
**markerLdBlock** below needs only *chrom* and tolerates a missing
*pos*/*cM* entirely.

### Realized Relatedness Variance

Pedigree-expected relatedness (kinship doubled) is only an average –
actual IBD sharing between two relatives varies around that expectation
because of Mendelian sampling and linkage.
**markerRealizedRelatednessVariance** computes a closed-form estimate of
that variance (Hill & Weir 2011) for Parent-Offspring, Full-Sibling, and
Half-Sibling pairs – every other relationship category (grandparent,
cousin, unrelated, self, and so on) legitimately returns `NA`, not an
error, since a pedigree-wide call includes many such pairs as a matter
of course. Despite the “marker” name shared with the rest of this
section, it needs no genotype data at all – only a kinship matrix, the
pedigree, and the species’ chromosome count and total autosomal genetic
map length (in Morgans).

``` r

smallPedKmat <- kinship(smallPed$id, smallPed$sire, smallPed$dam, smallPed$gen,
                         sparse = FALSE)
## Rhesus macaque autosome count/map length are used here only as an
## example scale -- supply values appropriate to your own species.
rrv <- markerRealizedRelatednessVariance(smallPedKmat, smallPed, nChr = 20L,
                                          mapLength = 28)
rrv[rrv$relation %in% c("Parent-Offspring", "Full-Siblings", "Half-Siblings"), ]
```

    ##     id1 id2 kinship         relation    R         varR        sdR
    ## 3     A   C   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
    ## 4     A   D   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
    ## 8     A   H   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
    ## 9     A   I   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
    ## 13    A   M   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
    ## 17    A   Q   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
    ## 20    B   C   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
    ## 21    B   D   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
    ## 25    B   H   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
    ## 38    C   D   0.250    Full-Siblings 0.50 0.0018350199 0.04283713
    ## 42    C   H   0.250    Full-Siblings 0.50 0.0018350199 0.04283713
    ## 43    C   I   0.125    Half-Siblings 0.25 0.0009175099 0.03029043
    ## 46    C   L   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
    ## 47    C   M   0.125    Half-Siblings 0.25 0.0009175099 0.03029043
    ## 57    D   F   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
    ## 58    D   G   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
    ## 59    D   H   0.250    Full-Siblings 0.50 0.0018350199 0.04283713
    ## 60    D   I   0.125    Half-Siblings 0.25 0.0009175099 0.03029043
    ## 64    D   M   0.125    Half-Siblings 0.25 0.0009175099 0.03029043
    ## 74    E   F   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
    ## 75    E   G   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
    ## 92    F   G   0.250    Full-Siblings 0.50 0.0018350199 0.04283713
    ## 128   H   I   0.125    Half-Siblings 0.25 0.0009175099 0.03029043
    ## 132   H   M   0.125    Half-Siblings 0.25 0.0009175099 0.03029043
    ## 146   I   J   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
    ## 149   I   M   0.125    Half-Siblings 0.25 0.0009175099 0.03029043
    ## 182   K   L   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
    ## 218   M   N   0.000 Parent-Offspring 0.00 0.0000000000 0.00000000
    ## 220   M   P   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
    ## 254   O   P   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000

Parent-offspring pairs have `varR` of exactly zero, not merely small –
biologically, exactly one allele at every locus is always IBD between a
parent and its offspring, so there is no variance to estimate around the
`R = 0.5` expectation. Full-sibling variance is roughly double half
-sibling variance in this example (two independently segregating parents
vs. one), a useful sanity check when interpreting the estimate for your
own pedigree.

### Linkage-Disequilibrium Blocks

**markerLdBlock** takes a different, more classical view of marker
relationships: pairwise linkage disequilibrium (LD) between loci sharing
a chromosome, using Hedrick’s (1987) frequency-weighted D’ and a
multiallelic r² generalization, from phase frequencies estimated by an
EM algorithm (generalizing Excoffier & Slatkin 1995) since this
package’s genotype matrix is unphased. It is explicitly the secondary,
exploratory statistic in a pair with
**markerRealizedRelatednessVariance** above – classical LD theory
assumes random mating, which a pedigreed colony violates, so every row
of its output carries a fixed caveat saying so.

``` r

ldGenotype <- checkLinkageMarkerGenotypeFile(data.frame(
  id = rep(c("W", "X", "Y", "Z"), 2),
  locus = rep(c("L1", "L2"), each = 4),
  allele1 = c("A", "A", "A", "A", "M", "M", "N", "N"),
  allele2 = c("A", "B", "A", "B", "M", "N", "M", "N"),
  stringsAsFactors = FALSE
))
ldGenotypeMatrix <- buildMarkerGenotypeMatrix(ldGenotype)
ldLocusMetadata <- checkLocusMetadata(data.frame(
  locus = c("L1", "L2"), chrom = c("1", "1"), pos = c(NA, NA),
  stringsAsFactors = FALSE
))
```

``` r

markerLdBlock(ldGenotypeMatrix, ldLocusMetadata)
```

    ##   locus1 locus2 chrom Dprime        r2 nUsed idsUsed
    ## 1     L1     L2     1      1 0.3333333     4    <NA>
    ##                                                                                                                                                                                                                                                      caveat
    ## 1 Descriptive statistic only -- not a rigorous, pedigree-aware LD-block measure. Classical linkage-disequilibrium theory assumes random mating, which a pedigreed colony violates; prefer markerRealizedRelatednessVariance() for pedigree-valid estimates.

*D’ = 1* (the maximum possible) in this toy example – only *X* is a
double heterozygote at both loci (the only source of phase ambiguity
here), and the EM estimator resolves it to a fully-consistent phase
assignment. Note *r²* (1/3) does not move in lockstep with *D’* here –
the two statistics capture different aspects of the same association,
and needn’t agree.

### De-identifying LD-Block Results

**markerLdBlock**’s own output is a locus-pair-level population
statistic with no per-individual ids in it – except *idsUsed*, populated
only when *founderIds* restricts the computation to a named subset. That
is the one place a real id can leak, and **obfuscateLdBlocks** closes
it: it remaps *idsUsed* through the same alias vector **obfuscatePed**’s
*map* output produces, mirroring **obfuscateTwinRelations**’s existing
pattern from elsewhere in the package’s de-identification family. A row
whose *idsUsed* contains an id absent from the map
[`stop()`](https://rdrr.io/r/base/stop.html)s loudly rather than
silently leaking it.

``` r

ldBlockResult <- data.frame(
  locus1 = "L1", locus2 = "L2", chrom = "1", Dprime = 0.5, r2 = 0.3,
  nUsed = 2L, idsUsed = "F1,F2", caveat = "Descriptive statistic only.",
  stringsAsFactors = FALSE
)
obfuscatedTwinPed <- obfuscatePed(twinPed[, c("id", "sire", "dam", "sex", "gen")],
                                   map = TRUE)
```

``` r

obfuscateLdBlocks(ldBlockResult, obfuscatedTwinPed$map)
```

    ##   locus1 locus2 chrom Dprime  r2 nUsed       idsUsed                      caveat
    ## 1     L1     L2     1    0.5 0.3     2 LYWT67,PYF94A Descriptive statistic only.

The real ids *F1*/*F2* (reusing the twin-pedigree ids from the
**Pedigree Diagram** section above) no longer appear in *idsUsed* –
every other column (the statistics themselves) is untouched. The exact
alias strings are randomly generated on every call and are not
reproduced here; what matters is that no real id from the input survives
into the de-identified table.

``` r

elapsed_time <- get_elapsed_time_str(start_time)
```

The current date and time is 2026-08-26 04:43:09.814114. The processing
time for this document was 13 seconds..

``` r

sessionInfo()
```

    ## R version 4.6.1 (2026-06-24)
    ## Platform: x86_64-pc-linux-gnu
    ## Running under: Ubuntu 24.04.4 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
    ## LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
    ## 
    ## Random number generation:
    ##  RNG:     Mersenne-Twister 
    ##  Normal:  Inversion 
    ##  Sample:  Rounding 
    ##  
    ## locale:
    ##  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
    ##  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
    ##  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
    ## [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
    ## 
    ## time zone: UTC
    ## tzcode source: system (glibc)
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices datasets  utils     methods   base     
    ## 
    ## other attached packages:
    ## [1] nprcgenekeepr_2.0.0.9000 knitr_1.51               ggplot2_4.0.3           
    ## [4] stringi_1.8.9           
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] gtable_0.3.6         anytime_0.3.13       xfun_0.60            bslib_0.12.0        
    ##  [5] visNetwork_2.1.4     htmlwidgets_1.6.4    lattice_0.22-9       vctrs_0.7.3         
    ##  [9] tools_4.6.1          generics_0.1.4       tibble_3.3.1         pkgconfig_2.0.3     
    ## [13] Matrix_1.7-5         data.table_1.18.6.1  checkmate_2.3.4      RColorBrewer_1.1-3  
    ## [17] S7_0.2.2             desc_1.4.3           readxl_1.5.0         lifecycle_1.0.5     
    ## [21] compiler_4.6.1       farver_2.1.2         stringr_1.6.0        textshaping_1.0.5   
    ## [25] Rlabkey_3.5.0        httpuv_1.6.17        htmltools_0.5.9      sass_0.4.10         
    ## [29] yaml_2.3.12          htmlTable_2.5.0      later_1.4.8          pillar_1.11.1       
    ## [33] pkgdown_2.2.1        jquerylib_0.1.4      DT_0.34.0            cachem_1.1.0        
    ## [37] sessioninfo_1.2.4    mime_0.13            tidyselect_1.2.1     zip_3.0.2           
    ## [41] digest_0.6.39        dplyr_1.2.1          labeling_0.4.3       fastmap_1.2.0       
    ## [45] grid_4.6.1           cli_3.6.6            magrittr_2.0.5       withr_3.0.3         
    ## [49] shinyBS_0.65.0       scales_1.4.0         promises_1.5.0       backports_1.5.1     
    ## [53] plotrix_3.8-14       lubridate_1.9.5      timechange_0.4.0     rmarkdown_2.31      
    ## [57] lambda.r_1.2.4       httr_1.4.8           otel_0.2.0           futile.logger_1.4.9 
    ## [61] cellranger_1.1.0     ragg_1.5.2           openxlsx_4.2.8.1     shiny_1.14.0        
    ## [65] evaluate_1.0.5       rlang_1.3.0          futile.options_1.0.1 Rcpp_1.1.2          
    ## [69] xtable_1.8-8         glue_1.8.1           formatR_1.14         renv_1.2.3          
    ## [73] rstudioapi_0.19.0    jsonlite_2.0.0       R6_2.6.1             systemfonts_1.3.2   
    ## [77] fs_2.1.0

[^1]: Setting *minDamAge* to 3.5 and above will cause an error along
    with the creation of a file *~/lowParentAge.csv* that will list the
    parents with low age at the birth of an offspring: two dams in this
    pedigree were about 3.3 years old at a birth. The sires are all
    older, so raising *minSireAge* alone to 3.5 does not trigger the
    error – exactly the sex-specific control the two floors provide.

[^2]: The *population* column is created and added to the pedigree
    object if it does not already exist.

[^3]: All animals within the colony have a known birth date.

[^4]: This pedigree is entirely synthetic – constructed for this
    tutorial, not drawn from any real colony’s records.

[^5]: The Diagram tab’s click-to-navigate behavior (clicking a node
    narrows the focal-animal selection to it, resolving a
    duplicate-occurrence click to the real animal and ignoring
    mating-node clicks) is Shiny-specific – it relies on a live Shiny
    session to receive the click event – and is therefore not reproduced
    here.

[^6]: These waypoint nodes are internal plumbing needed for the
    right-angle routing itself, not new diagram content.
