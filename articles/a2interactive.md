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

You can install **nprcgenekeepr** from CRAN with the following code.

``` r

install.packages("nprcgenekeepr")
## Use the following code to get the development version from GitHub
# install.packages("devtools")
# devtools::install_github("rmsharp/nprcgenekeepr")
```

All missing dependencies should be automatically installed.

You can get help from the **R** console with

``` r

?nprcgenekeepr
```

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
*pedigreeFile*. Note: by default the file is written to the session’s
temporary directory
([`tempdir()`](https://rdrr.io/r/base/tempfile.html)); pass the *file*
argument to choose a different location.

``` r

library(nprcgenekeepr)
pedigreeFile <- makeExamplePedigreeFile()
```

This writes *examplePedigree.csv* to the session’s temporary directory
unless you supply a *file* argument.

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
focal animals. *Hint: there are 490 grandparents of the focal animals in
the trimmed pedigree*.

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
**drawPedigreeDiagram** draws it with the **visNetwork** package (a
dependency of **nprcgenekeepr**); the Diagram tab itself calls
**drawPedigreeDiagram**. (A simpler function,
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

    ## [1] "nodes"              "edges"              "duplicateToReal"   
    ## [4] "isolatedIds"        "conditions"         "conditionsNotDrawn"

``` r

nrow(diagramData$nodes)
```

    ## [1] 56

``` r

nrow(diagramData$edges)
```

    ## [1] 61

**makePedigreeMatingLayout** returns a list of four elements: *nodes*
(one row per real animal that has recorded parents, mates, or offspring
– shaped by sex, dot = Female, square = Male, star = Hermaphrodite,
triangle = Unknown, diamond = Other/Unrecorded, with an HTML
hover-tooltip giving ID, sex, generation, sire, and dam – plus one
small, unlabeled dot per mating and one extra row per duplicate
occurrence, each carrying its animal’s own shape, label, and tooltip
with a note that it is a duplicate occurrence), *edges*
(parent-to-mating and mating-to-child edges, plus a dashed edge from
each duplicate occurrence back to the real animal), *duplicateToReal* (a
named lookup from each duplicate occurrence’s id back to the real animal
it represents), and `isolatedIds` (the ids of animals with no recorded
parents, mates, or offspring, which are left out of the diagram; the
function also prints a message naming them).

Each node already carries its own fixed **x**/**y** position (computed
by **makePedigreeMatingLayout** itself), so rendering it turns vis.js’s
usual physics/hierarchical layout off rather than turning one on.
**drawPedigreeDiagram** draws *diagramData* the way the Diagram tab does
– the tab calls the same function – so it reproduces the Diagram tab’s
rendering exactly: the legend, a slash through the symbol of an animal
whose `status` is DECEASED, the colored sections of an animal with more
than one affected condition, and a genuinely working **Export Diagram
(PNG)** button – try it below. Give it the `edgeStyle` the layout was
made with.[^5]

``` r

drawPedigreeDiagram(diagramData, edgeStyle = "direct")
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
names(diagramDataRectilinear)
```

    ## [1] "nodes"              "edges"              "duplicateToReal"   
    ## [4] "isolatedIds"        "conditions"         "conditionsNotDrawn"

``` r

nrow(diagramDataRectilinear$nodes)
```

    ## [1] 94

``` r

nrow(diagramDataRectilinear$edges)
```

    ## [1] 99

94 nodes and 99 edges here, versus 56 and 61 for the same 33-animal
*demoPed* under the *direct* style above – the difference is entirely
extra invisible “waypoint” nodes/edges that carry out the right-angle
routing (zero size, transparent color, excluded from the **Select by
id** dropdown below just like the mating dots above), not any change to
which animals or relationships are shown.[^6] *nodes* also gains an
extra `color.border` column under *rectilinear* –
**visNetwork::visNetwork()** reads it directly, so no extra rendering
code is needed.

Rendering it is the same call with `edgeStyle = "rectilinear"`, which
makes one difference: **drawPedigreeDiagram** raises the hover
highlight’s reach (**highlightNearest**’s *degree*) from `1` to `6`.
Under *rectilinear*, a plain individual’s nearest graph neighbor is
often one of the invisible waypoint nodes above rather than a visible
mating dot, so `degree = 1` (correct for *direct*) can highlight nothing
visible at all on hover; `6` restores visible feedback for the common
case. It is a deliberate compromise, not a complete fix, because the
invisible waypoints count as steps: on the bundled 375-animal rhesus
pedigree, hovering an animal lights everything that the *direct* style’s
`degree = 1` lights for all but 2 animals, whose parents’ mating dot is
just out of reach (their family’s connectors were rerouted around
crowded lines, which adds waypoints). One mating pair with nine or more
full siblings reaches the same limit; the widest pair in the bundled
pedigrees has four. A larger `degree` would cover these cases, but it
highlights more of the diagram on every hover, so the simpler, tighter
hover was kept. The live Shiny app’s Diagram tab applies this same
style-aware degree automatically when you switch the “Diagram Edge
Style” toggle.

``` r

drawPedigreeDiagram(diagramDataRectilinear, edgeStyle = "rectilinear")
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
undetermined) pair has no such precondition. The result of
**checkTwinRelations** should be passed to
**makePedigreeMatingLayout**’s optional *twinRelations* argument; the
layout function does not validate it itself. The argument adds a dashed
twin-connector edge between the pair, styled by zygosity code – the same
connectors shown in the live app’s Diagram tab.

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

### Kinship of Identical Twins

Of the three zygosity codes, only *MZ twin* changes a kinship value: a
*DZ twin* or *UZ twin* row leaves **kinship**’s result as it is.
Identical twins carry the same genes, so **kinship**, given a
*twinRelations* table, sets each declared *MZ twin* pair’s kinship to
the kinship an animal has with itself, and carries the change on to the
twins’ relatives. The pair above is a female and a male and cannot be an
*MZ twin* pair, so this small pedigree has two full sisters declared
identical twins and a daughter of the first of them:

``` r

mzPed <- data.frame(
  id = c("F1", "F2", "T1", "T2", "M3", "D1"),
  sire = c(NA, NA, "F1", "F1", NA, "M3"),
  dam = c(NA, NA, "F2", "F2", NA, "T1"),
  sex = c("M", "F", "F", "F", "M", "F"),
  stringsAsFactors = FALSE
)
mzPed$gen <- findGeneration(mzPed$id, mzPed$sire, mzPed$dam)
mzTwins <- checkTwinRelations(mzPed, data.frame(
  id1 = "T1", id2 = "T2", code = "MZ twin", stringsAsFactors = FALSE
))
plainKmat <- kinship(mzPed$id, mzPed$sire, mzPed$dam, mzPed$gen)
twinKmat <- kinship(mzPed$id, mzPed$sire, mzPed$dam, mzPed$gen,
                    twinRelations = mzTwins)
plainKmat[c("T1", "T2", "D1"), c("T1", "T2", "D1")]
```

    ##      T1    T2    D1
    ## T1 0.50 0.250 0.250
    ## T2 0.25 0.500 0.125
    ## D1 0.25 0.125 0.500

``` r

twinKmat[c("T1", "T2", "D1"), c("T1", "T2", "D1")]
```

    ##      T1   T2   D1
    ## T1 0.50 0.50 0.25
    ## T2 0.50 0.50 0.25
    ## D1 0.25 0.25 0.50

The twins’ kinship rises from 0.25, that of full sisters, to 0.5, and
the daughter’s kinship with her mother’s twin rises from 0.125, that of
a niece and her aunt, to 0.25, the same as with her own mother. A matrix
built this way is the one to pass on as *kinshipMatrix*, as the next
section explains.

### Passing a Kinship Matrix You Already Have

**makePedigreeMatingLayout** marks a mating unit as consanguineous when
its sire and dam are related, and it works that out by computing a
kinship matrix of the pedigree itself. If you already hold a kinship
matrix for the same pedigree, pass it as *kinshipMatrix* and the layout
uses it instead of making its own. The matrix needs the animal ids as
its row and column names. It is then the only source of the
consanguinity marks: *twinRelations* goes on drawing the twin connectors
and nothing else, so a matrix that should reflect declared monozygotic
twins has to be built with **kinship**’s own *twinRelations* argument
before it is passed in.

``` r

demoKmat <- kinship(demoPed$id, demoPed$sire, demoPed$dam, demoPed$gen)
layoutFromPed <- makePedigreeMatingLayout(demoPed)
layoutFromMatrix <- makePedigreeMatingLayout(demoPed, kinshipMatrix = demoKmat)
identical(layoutFromMatrix$edges, layoutFromPed$edges)
```

    ## [1] TRUE

``` r

unnamedMatrixMessage <- tryCatch(
  makePedigreeMatingLayout(demoPed, kinshipMatrix = unname(demoKmat)),
  error = conditionMessage
)
unnamedMatrixMessage
```

    ## [1] "makePedigreeMatingLayout() requires 'kinshipMatrix' to be a matrix (or Matrix) with row and column names set to individual ids, or NULL."

The layout built from the matrix has the same edges as the one that
computed its own, and a matrix without ids is refused with a message
that names *kinshipMatrix*.

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
may often want to use non-default values. The principal arguments are
described below. Further arguments (**updateProgress**, `breedingTable`,
`gestationTable`, `breedingAgeDefault`, `gestationDefault`,
`kinshipOverrides`, **twinRelations**, `guCutoff`, `zScoreCutoff` and
`axisPriority`) are described in
[`?reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md).

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

### Using known genotypes

Known genotypes give the gene drop real alleles to start from in place
of simulated ones. The Input tab reads them when “Pedigree(s) and
genotypes in one file” is chosen and the file has two allele columns
(*first* and *second*, *first_name* and *second_name*, or *allele_1* and
*allele_2*), and its QC Summary says which it read. A script gives a
pedigree the same integer codes with **addGenotype**. It numbers each
distinct allele label from 10001, in sorted order over both columns, and
adds the codes as the integer columns *first* and *second*. **reportGV**
finds those two columns by itself, and **getGVGenotype** shows what it
finds.

The next chunk reads the package’s one-file example, a rhesus MHC
pedigree in which some animals have allele labels in *first_name* and
*second_name*. It hands **addGenotype** the rows that have labels,
counts the animals with codes, runs **reportGV** and counts the
genotyped animals at each genome uniqueness value. Each of those animals
starts the gene drop from its own two alleles; the alleles of every
other animal are simulated or passed down from them.

``` r

genotypeFile <- system.file("extdata", "examples",
  "obfuscated_rhesus_mhc_ped_with_genotypes.csv",
  package = "nprcgenekeepr"
)
labelPed <- qcStudbook(getPedigree(genotypeFile),
  reportErrors = FALSE, reportChanges = FALSE
)
labelColumns <- c("first_name", "second_name")
hasLabels <- !is.na(labelPed$first_name) | !is.na(labelPed$second_name)
genotypePed <- addGenotype(
  labelPed[, !(names(labelPed) %in% labelColumns)],
  labelPed[hasLabels, c("id", labelColumns)]
)
c(animals = nrow(genotypePed), with_codes = sum(!is.na(genotypePed$first)))
```

    ##    animals with_codes 
    ##        375         31

``` r

genotypeGV <- reportGV(genotypePed,
  guIter = 200L,
  guThresh = 3L,
  byID = TRUE,
  updateProgress = NULL
)
genotypedGu <- genotypeGV$report$gu[genotypeGV$report$id %in%
  genotypePed$id[!is.na(genotypePed$first)]]
table(genotypedGu)
```

    ## genotypedGu
    ##   0  50 100 
    ##   4  15  12

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
    notch = TRUE,
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

### X-Chromosome Kinship

By default **kinship** gives the autosomal kinship coefficient. With
`chrtype = "x"` it gives X-chromosome kinship instead. A male carries a
single X, which comes from his mother alone; a female’s X-linked kinship
follows the same average-of-the-parents rule as the autosomes. Because
the calculation depends on sex, *sex* is then required: one value per
animal in the order of *id*, using the package’s `"M"` and `"F"` codes
(any other value, `NA` included, counts as unknown). An animal of
unknown sex that has recorded parents gets `NA` kinship with everyone.

``` r

xPed <- nprcgenekeepr::smallPed
xPed$gen <- findGeneration(xPed$id, xPed$sire, xPed$dam)
autosomeKmat <- kinship(xPed$id, xPed$sire, xPed$dam, xPed$gen)
xKmat <- kinship(xPed$id, xPed$sire, xPed$dam, xPed$gen,
                 chrtype = "x", sex = xPed$sex)
unique(data.frame(sex = xPed$sex, autosome = unname(diag(autosomeKmat)),
                  x = unname(diag(xKmat))))
```

    ##   sex autosome   x
    ## 1   M      0.5 1.0
    ## 2   F      0.5 0.5

``` r

xPairs <- data.frame(
  first = c("A", "B", "D", "E"), second = c("C", "C", "F", "F"),
  relation = c("father and son", "mother and son", "father and daughter",
               "mother and daughter"))
pairIndex <- as.matrix(xPairs[, c("first", "second")])
xPairs$autosome <- autosomeKmat[pairIndex]
xPairs$x <- xKmat[pairIndex]
xPairs
```

    ##   first second            relation autosome    x
    ## 1     A      C      father and son     0.25 0.00
    ## 2     B      C      mother and son     0.25 0.50
    ## 3     D      F father and daughter     0.25 0.50
    ## 4     E      F mother and daughter     0.25 0.25

The first table is each animal’s kinship with itself: on the X a male’s
is higher than his autosomal value, because he carries a single X, and a
female’s is unchanged. In the second, a father and his son share no X,
since a son’s X comes from his mother alone, while a mother and her son,
and a father and his daughter, share more of it than they do on the
autosomes.

## Colony Snapshots Over Time

A *snapshot* is one dated row of colony-level numbers: the settings and
counts that say what the numbers rest on, the values **reportGV**
reports for the colony as a whole, and summaries of the per-animal
kinship and genome uniqueness values. Rows for successive dates make a
*history*, which is what the Genetic-Health Trends tab of the Shiny
application keeps and plots. The functions in this section do the same
work in a script.

The chunks below use the example pedigree that ships with the package,
**qcPed**, and few gene-drop iterations so that each runs in a moment.
Use more for an analysis you will report (the default of **reportGV** is
1000).

### Recording a Snapshot

**createColonySnapshot** turns one **reportGV** result into a one-row
snapshot. Give it the pedigree the analysis was run on, the result, the
*membershipRule* that says who was analyzed (here `"wholePedigree"`,
every animal in the pedigree), and the same *guIter* and *guThresh* the
analysis used, because the snapshot records them and the result does not
carry them. **appendColonySnapshot** adds the row to a history (`NULL`
starts a new one) and returns the history in date order; it writes
nothing. The date is fixed here only so that the printed values are the
same each time the document is built; leave it out to date the snapshot
today.

``` r

set.seed(1L)
snapshotPed <- qcPed
snapshotGV <- reportGV(snapshotPed, guIter = 50L, guThresh = 1L)
firstSnapshot <- createColonySnapshot(snapshotPed, snapshotGV,
  "wholePedigree",
  guIter = 50L, guThresh = 1L, snapshotDate = as.Date("2018-01-01")
)
snapshotHistory <- appendColonySnapshot(NULL, firstSnapshot)
snapshotHistory[, c("snapshotDate", "membershipRule", "nAnimals", "fe", "fg")]
```

    ##   snapshotDate membershipRule nAnimals       fe       fg
    ## 1   2018-01-01  wholePedigree      280 77.04028 52.16436

The snapshot has 27 columns; the table shows five of them.

### Rebuilding Earlier Dates

A history of one row shows no trend. **backfillColonySnapshots**
rebuilds a snapshot for each date you name from the birth and exit dates
already in the pedigree, so you need not wait for seasons of recording.
It works out which animals were alive on each date, analyzes them and
their ancestors with **reportGV**, and summarizes the result as
**createColonySnapshot** does. Give it the full pedigree, not one
already trimmed to a focal list of animals. The rows are filed under
their own membership rule, `"reconstructedLiving"`, so they form a line
of their own and never mix with recorded rows. Passing the history as
*existingHistory* keeps its rows and adds the rebuilt ones.

Before the gene drop is spent, **previewBackfillSupport** gives the
counts each date rests on, without the analysis.

``` r

set.seed(1L)
earlierDates <- as.Date(c("2005-01-01", "2008-01-01", "2010-01-01"))
backfillPreview <- previewBackfillSupport(snapshotPed, dates = earlierDates)
backfillPreview
```

    ##   snapshotDate nLiving nPlacedByOffspring nPossiblyAlive pctSireKnown
    ## 1   2005-01-01      86                  0              0     56.97674
    ## 2   2008-01-01      79                  0              0     59.49367
    ## 3   2010-01-01      63                  0              0     68.25397
    ##   pctDamKnown
    ## 1    89.53488
    ## 2    91.13924
    ## 3    90.47619

``` r

earlierSnapshots <- backfillColonySnapshots(snapshotPed,
  dates = earlierDates,
  guIter = 50L, guThresh = 1L, existingHistory = snapshotHistory
)
snapshotHistory <- earlierSnapshots$history
snapshotHistory[, c("snapshotDate", "membershipRule", "nAnimals", "fe", "fg")]
```

    ##   snapshotDate      membershipRule nAnimals       fe       fg
    ## 1   2005-01-01 reconstructedLiving       86 66.68822 40.32350
    ## 2   2008-01-01 reconstructedLiving       79 71.95316 38.93590
    ## 3   2010-01-01 reconstructedLiving       63 63.03001 32.81522
    ## 4   2018-01-01       wholePedigree      280 77.04028 52.16436

*nLiving* is the number of animals each date rests on, and
*pctSireKnown* and *pctDamKnown* are the percentage of them whose sire
or dam is recorded. *nPlacedByOffspring* and *nPossiblyAlive* count
animals with no birth date
([`?backfillColonySnapshots`](https://github.com/rmsharp/nprcgenekeepr/reference/backfillColonySnapshots.md)
says how each is placed). Read these counts beside the trend: where few
sires are recorded the sex-ratio effective size reads low because of the
missing records, not because of the colony.

A rebuilt snapshot looks back with today’s records: a parent identified
later counts as known earlier, today’s genotypes are used for every
date, and only animals with a birth date, or with an offspring that has
one, are placed. Two close dates can differ only by the random sampling
every gene drop has.

A date that cannot be analyzed does not stop the others. It is listed in
the `skipped` element with the reason, and one warning says how many
dates failed. Here 0 dates were skipped.

### Saving, Reading and Checking a History

Neither **appendColonySnapshot** nor **backfillColonySnapshots** writes
a file. You keep the history yourself, as the application does when you
download it, with **write.csv** and `row.names = FALSE`.
**readSnapshotHistory** reads the file back (delimited text or Excel)
but does not check it, and it leaves the dates as text.
**checkSnapshotHistory** checks the structure and the values, stops with
a message that names the problem, and otherwise returns the history with
the dates as dates.

``` r

historyFile <- tempfile(fileext = ".csv")
write.csv(snapshotHistory, historyFile, row.names = FALSE)
readBack <- readSnapshotHistory(historyFile)
class(readBack$snapshotDate)
```

    ## [1] "character"

``` r

checkedHistory <- checkSnapshotHistory(readBack)
class(checkedHistory$snapshotDate)
```

    ## [1] "Date"

### Comparing Two Dates

**calcSnapshotDeltas** lists, metric by metric, the value on each of two
dates and the difference between them. The two dates must belong to one
membership-rule series, because rules are never compared with each
other. A history that holds both recorded and rebuilt rows therefore
needs to be told which series; without *membershipRule* the function
stops and names the rules it finds.

``` r

mixedRuleMessage <- tryCatch(
  calcSnapshotDeltas(checkedHistory, from = "2005-01-01", to = "2010-01-01"),
  error = conditionMessage
)
mixedRuleMessage
```

    ## [1] "Snapshot history holds several membershipRule values (reconstructedLiving, wholePedigree); pass 'membershipRule' to pick the series to compare."

``` r

deltas <- calcSnapshotDeltas(checkedHistory,
  from = "2005-01-01", to = "2010-01-01",
  membershipRule = "reconstructedLiving"
)
deltas[deltas$metric %in% c("nAnimals", "fe", "fg", "neSexRatio"), ]
```

    ##       metric     from       to      delta comparabilityFlag
    ## 1   nAnimals 86.00000 63.00000 -23.000000              <NA>
    ## 4         fe 66.68822 63.03001  -3.658216              <NA>
    ## 5         fg 40.32350 32.81522  -7.508285              <NA>
    ## 8 neSexRatio 25.26316 17.14286  -8.120301              <NA>

The *comparabilityFlag* column is `NA` when the two snapshots were made
with the same settings. When they were not, it names each setting that
differs, so a change caused by a different number of gene-drop
iterations is not mistaken for a change in the colony.

### Plotting the Trend

**plotSnapshotTrends** draws the history as one ggplot object with a
panel for each metric, the date along the bottom and one colored series
for each membership rule. The rebuilt series is dashed, and the caption
says that the dashed lines were rebuilt and not recorded at the time.
Where the history carries a standard error, as for founder genome
equivalents and mean genome uniqueness, the panel shows a ribbon for the
sampling uncertainty of the gene drop. A snapshot made with different
settings from the previous one of its series is drawn with a different
point shape and named in the caption. A trend needs at least two
snapshots, and *metrics* chooses the panels (the default draws every
metric column). *ncol* sets how many columns of panels to draw: three
keeps these three panels side by side, and a narrow figure needs fewer,
so that each panel stays wide enough for its title.

``` r

trendPlot <- plotSnapshotTrends(checkedHistory,
                                metrics = c("fe", "fg", "meanGu"), ncol = 3L)
trendPlot
```

![Trend lines of three colony genetic-health measures over the snapshot
dates. The rebuilt snapshots form a dashed line and the one recorded
snapshot is a single
point.](a2interactive_files/figure-html/snapshot-plot-1.png)

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
  - Specify the sex ratio between 0.5 and 20 (F/M)
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

Below are the descriptions of the principal function parameters
extracted from the documentation near the time this tutorial was
prepared. The function has further parameters (`maxCandidates`,
**exhaustive**, `maxExhaustiveCandidates`, `exhaustiveTimeLimit`, and
**ancestryRules**, which is used in the *Ancestry Rules* section below),
and it returns a list with the items **group**, **score**,
**candidates** (up to `maxCandidates` distinct candidate solutions, best
first) and, when **withKin** is **TRUE**, `groupKin`; see
[`?groupAddAssign`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
for their descriptions.

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
(01-01-2015) that are still in the colony.

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
values in the calls below. The default **sexRatio** of 0 means that no
sex ratio is imposed.

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
    ##  [1] "SXSVEH" "G8MCV7" "99BMJW" "5EDIEE" "6X6BG9" "2Z4YLY" "IH1KPA" "0X4W26"
    ##  [9] "XEC0M5" "3GECJJ" "Q7U139" "6F9FB8" "JLFKV8" "B1WVCN" "BKWE4D" "C18V6I"
    ## [17] "F45799" "S056D5" "QRZK48" "DHNQ1W" "D33J06" "38K2SR" "TEACA3" "5EDLL7"
    ## [25] "M9PVG5" "Y6DB6L" "LS184H" "AR5U44" "ZPS15A" "1CZM30"
    ## 
    ## [[2]]
    ##  [1] "9FRCIE" "50D77I" "AW400C" "Q8U9LB" "7B9CA6" "5KWNMZ" "92UG4N" "1KJ2MG"
    ##  [9] "PI4VHT" "87AQLF" "YLRNIK" "DCJJYS" "B228Q6" "MPIQ4N" "WLMGS1" "Z904TJ"
    ## [17] "VWC5ZH" "FG0SFA" "W0GUKI" "MFKT9C" "PVY432" "W5WIRP" "2F6J3U" "1FAZ0K"
    ## [25] "MKY9TK" "MTCAIG" "WJXIH9"
    ## 
    ## [[3]]
    ##  [1] "1E8KD1" "YTJ2UL" "WK89I9" "72LYDE" "465ERA" "FL170P" "CS23RV" "DKIM6U"
    ##  [9] "DI4AHD" "B134XZ" "SHG3RB" "5W621W" "MX4J7G" "QW2Z3R" "RVHVTZ" "46ZHKN"
    ## [17] "PU7RSG" "FB5L3N" "CRPXY7" "EX5K0S" "SCFSBF" "6KWVRI" "J3F6PD" "9MG040"
    ## [25] "7NE2UT" "X694YR" "FJS7RQ" "I5CI33" "I8ABC7" "WNEAS6" "1QVS67" "83HQBN"
    ## 
    ## [[4]]
    ##  [1] "5KFB90" "AFZKBS" "QCA36T" "967Y3D" "N79QXB" "DPXEQE" "8JUUJ9" "QQMBT1"
    ##  [9] "QWKFBH" "MYUMMX" "D4B0RM" "DRXMW4" "PBAFJF" "QCENKM" "ZQXZYB" "1SPLS8"
    ## [17] "EZ2F8A" "KX0RJ3" "R5AYJK" "9P0DES" "F7I2ED" "S5H1GC" "Y0TCYX" "YFCIHJ"
    ## [25] "WKY2SZ" "XYRDKV" "S7IWWA" "5ERY5Z" "1SSCJC" "MH88T6" "EMV4P6" "01QRQ4"
    ## [33] "AIHJ8Z" "5BPBUI" "KZY6PD" "ESUIAF" "321LLB" "CLSVU6" "BCJJKN" "0XTZQ1"
    ## [41] "414N7M" "SH3FB7" "7ZNY75"
    ## 
    ## [[5]]
    ##  [1] "80F2MI" "ILVQVB" "0SGJ12" "W6MDVK" "TXZUKC" "AP1YLW" "ZH3YG1" "PYPM1W"
    ##  [9] "CMMUKU" "G25E3F" "D9P18Y" "GTLA8R" "AR17R5" "1CIRC9" "3DTD2N" "XFWVVX"
    ## [17] "GCBYDW" "30J3CQ" "KEA4QG" "E5Q33K" "S3EBGZ" "AZ3L0D" "PJ72W1" "13B1QL"
    ## [25] "LVYYNY" "G58RGY" "1VP3UC" "S222R3" "NK802Y" "ZATMEE" "0IIAEN" "GIIEUD"
    ## 
    ## [[6]]
    ##  [1] "B2CKHA" "HE0SCR" "N5QBWD" "7RA57Q" "3YJIMV" "DH9WJQ" "WI38KZ" "RJ4JPC"
    ##  [9] "K3TNHP" "CHK1ZX" "TYEWF1" "TQEMY6" "N4NV8B" "Q17CG3" "0HYZ23" "GAS52W"
    ## [17] "WTE53B" "LYSLPP" "MB6NYQ" "H2J6UA" "5IAFMK" "BS3RLE" "T3QPW5" "3SKITJ"
    ## [25] "1GF3GM" "NN3GDQ"
    ## 
    ## [[7]]
    ## [1] NA

Notice that the list has one more element than the six groups requested.
The last element is not a breeding group. With harem groups it is a lone
`NA`, which is not an animal (the next section shows what it holds when
a sex ratio is set).

We can identify and list the males in each group with the following
code.

``` r

sapply(haremGrp$group, function(ids) {
  ids[ids %in% trimmedPed$id[trimmedPed$sex == "M"]]
})
```

    ## [[1]]
    ## [1] "SXSVEH"
    ## 
    ## [[2]]
    ## [1] "9FRCIE"
    ## 
    ## [[3]]
    ## [1] "1E8KD1"
    ## 
    ## [[4]]
    ## [1] "5KFB90"
    ## 
    ## [[5]]
    ## [1] "80F2MI"
    ## 
    ## [[6]]
    ## [1] "B2CKHA"
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

    ## [1] "Count: 30 Sex Ratio: 29"
    ## [1] "Count: 27 Sex Ratio: 26"
    ## [1] "Count: 32 Sex Ratio: 31"
    ## [1] "Count: 43 Sex Ratio: 42"
    ## [1] "Count: 32 Sex Ratio: 31"
    ## [1] "Count: 26 Sex Ratio: 25"
    ## [1] "Count: 1 Sex Ratio: Inf"

Examination of this table shows that of the 184 females 184 are included
in the six groups.

### Controlling Sex Ratios

The following group assignments control the sex ratio of the groups
formed. This is done by setting **sexRatio** to the desired number of
females per male (here 9, with **harem** left at its default of
**FALSE**).

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
    ##  [1] "PVY432" "E3JP0C" "0HYZ23" "321LLB" "ZATMEE" "KZY6PD" "W5WIRP" "B134XZ"
    ##  [9] "F45799" "PJ72W1" "1SSCJC" "1GF3GM" "WK89I9" "KZM9RB" "MYUMMX" "QCA36T"
    ## [17] "MTCAIG" "DI4AHD" "R5AYJK" "DH9WJQ" "X694YR" "BKWE4D" "S056D5" "YLRNIK"
    ## [25] "KXHGRH" "Y6DB6L" "LS184H" "BS3RLE"
    ## 
    ## [[2]]
    ##  [1] "ESUIAF" "RY1AZM" "G58RGY" "RJ4JPC" "F7I2ED" "6F9FB8" "NK802Y" "3SKITJ"
    ##  [9] "EMV4P6" "QWKFBH" "6KWVRI" "ZPS15A" "M9PVG5" "WQUN84" "Q17CG3" "BCJJKN"
    ## [17] "TQEMY6" "CRPXY7" "VWC5ZH" "AR17R5" "YTJ2UL" "CLSVU6" "7ZNY75" "414N7M"
    ## [25] "A6A1M1" "I8ABC7" "AZ3L0D" "0IIAEN" "S222R3" "6X6BG9" "J3F6PD" "SCFSBF"
    ## [33] "7NE2UT"
    ## 
    ## [[3]]
    ##  [1] "1CZM30" "QRWYQZ" "CHK1ZX" "S3EBGZ" "FB5L3N" "AFZKBS" "D4B0RM" "3DTD2N"
    ##  [9] "C18V6I" "2Z4YLY" "01QRQ4" "1QVS67" "GCBYDW" "K7900I" "92UG4N" "MFKT9C"
    ## [17] "Y0TCYX" "0XTZQ1" "DCJJYS" "30J3CQ" "AW400C" "IH1KPA" "G25E3F" "GIIEUD"
    ## [25] "SXSVEH" "XFWVVX" "1KJ2MG" "HE0SCR" "MB6NYQ" "Q7U139"
    ## 
    ## [[4]]
    ##  [1] "3GECJJ" "3QHAFI" "5KWNMZ" "DRXMW4" "1FAZ0K" "FL170P" "13B1QL" "TXZUKC"
    ##  [9] "WI38KZ" "8JUUJ9" "MH88T6" "0SGJ12" "GTLA8R" "JSAP3H" "QCENKM" "TEACA3"
    ## [17] "72LYDE" "JLFKV8" "WLMGS1" "50D77I" "PU7RSG" "W6MDVK" "5EDIEE" "YFCIHJ"
    ## [25] "IZDV8K" "QW2Z3R" "465ERA" "38K2SR" "967Y3D" "WTE53B" "RVHVTZ" "87AQLF"
    ## [33] "AR5U44" "TYEWF1" "Z7NBA2"
    ## 
    ## [[5]]
    ##  [1] "D9P18Y" "XL658N" "LVYYNY" "9P0DES" "MX4J7G" "FJS7RQ" "2F6J3U" "ZQXZYB"
    ##  [9] "46ZHKN" "EZ2F8A" "KX0RJ3" "B1WVCN" "WNEAS6" "T38W6H" "9MG040" "N79QXB"
    ## [17] "DKIM6U" "Q8U9LB" "AIHJ8Z" "CMMUKU" "W0GUKI" "ILVQVB" "PI4VHT" "5EDLL7"
    ## [25] "LN1DLY" "DPXEQE" "S5H1GC" "D33J06" "SH3FB7" "99BMJW" "5ERY5Z"
    ## 
    ## [[6]]
    ##  [1] "7B9CA6" "ER464J" "1SPLS8" "0X4W26" "7RA57Q" "1CIRC9" "XEC0M5" "FG0SFA"
    ##  [9] "AP1YLW" "GAS52W" "5BPBUI" "NN3GDQ" "83HQBN" "R6HV9A" "CS23RV" "H2J6UA"
    ## [17] "K3TNHP" "SHG3RB" "MPIQ4N" "PBAFJF" "T3QPW5" "B228Q6" "3YJIMV" "QRZK48"
    ## [25] "A98D7P" "1VP3UC" "WKY2SZ" "KEA4QG"
    ## 
    ## [[7]]
    ##  [1] "5IAFMK" "HLQ9SY" "B2CKHA" "GDXWJ1" "TR5L57" "XC304E" "1E8KD1" "5KFB90"
    ##  [9] "5PW7WT" "AEP5EG" "BW10CL" "CFD12A" "CHJ9D2" "FTVE03" "G2GYST" "G8MCV7"
    ## [17] "IRFJ09" "LMJWTN" "N4NV8B" "N5QBWD" "Q9LWGX" "RNQU14" "09LFE4" "3MMZD4"
    ## [25] "55BPSE" "5XVTVH" "8IG767" "9FRCIE" "FFGPS4" "FG6L7S" "LYSLPP" "NHWTJ9"
    ## [33] "P7RBPI" "TBCE78" "YI16QD" "2F1IV1" "4LHK19" "59NYZE" "5IYDXN" "6KLWVC"
    ## [41] "80F2MI" "8TV4MT" "AZ4D19" "BTTHAJ" "CHSCFG" "DHNQ1W" "EEGLWY" "FX9E4X"
    ## [49] "G91ZM6" "I5CI33" "J1R2EW" "LDND6J" "MKY9TK" "MQT080" "NSIC4I" "PHB6TE"
    ## [57] "PYPM1W" "WHQLH5" "XX0GYV" "XYRDKV" "YHHVC7" "YP910X" "Z904TJ" "ZH3YG1"
    ## [65] "0V4SAC" "0X1RZ9" "3YHBC1" "55VDSQ" "5W621W" "653J82" "6MEP2C" "76DIT4"
    ## [73] "80KACX" "B2YJJP" "E5Q33K" "EX5K0S" "FLIZQI" "GM371F" "MEUZ85" "PA9F3J"
    ## [81] "QQMBT1" "S7IWWA" "TJN1AD" "WJXIH9" "WNKKW3" "XY2CK7" "XZH41H" "YDRD81"
    ## [89] "Z25D52" "ZDRSG0" "3P9BX6" "7D09WH" "DGZLV3" "S63QDN" "ZW2X4N"

As before, the last element of the list is not a breeding group. Here it
holds the 95 candidates that were not placed in any of the six groups.

Again we can identify and list the males in each group with the
following code.

``` r

sapply(sexRatioGrp$group, function(ids) {
  ids[ids %in% trimmedPed$id[trimmedPed$sex == "M"]]
})
```

    ## [[1]]
    ## [1] "E3JP0C" "KZM9RB" "KXHGRH"
    ## 
    ## [[2]]
    ## [1] "RY1AZM" "WQUN84" "A6A1M1"
    ## 
    ## [[3]]
    ## [1] "QRWYQZ" "K7900I" "SXSVEH"
    ## 
    ## [[4]]
    ## [1] "3QHAFI" "JSAP3H" "IZDV8K" "Z7NBA2"
    ## 
    ## [[5]]
    ## [1] "XL658N" "T38W6H" "LN1DLY"
    ## 
    ## [[6]]
    ## [1] "ER464J" "R6HV9A" "A98D7P"
    ## 
    ## [[7]]
    ##  [1] "HLQ9SY" "B2CKHA" "GDXWJ1" "TR5L57" "XC304E" "1E8KD1" "5KFB90" "5PW7WT"
    ##  [9] "AEP5EG" "BW10CL" "CFD12A" "CHJ9D2" "FTVE03" "G2GYST" "IRFJ09" "LMJWTN"
    ## [17] "Q9LWGX" "RNQU14" "09LFE4" "3MMZD4" "55BPSE" "5XVTVH" "8IG767" "9FRCIE"
    ## [25] "FFGPS4" "FG6L7S" "NHWTJ9" "P7RBPI" "TBCE78" "YI16QD" "2F1IV1" "4LHK19"
    ## [33] "59NYZE" "5IYDXN" "6KLWVC" "80F2MI" "8TV4MT" "AZ4D19" "BTTHAJ" "CHSCFG"
    ## [41] "EEGLWY" "FX9E4X" "G91ZM6" "J1R2EW" "LDND6J" "MQT080" "NSIC4I" "PHB6TE"
    ## [49] "WHQLH5" "XX0GYV" "YHHVC7" "YP910X" "0V4SAC" "0X1RZ9" "3YHBC1" "55VDSQ"
    ## [57] "653J82" "6MEP2C" "76DIT4" "80KACX" "B2YJJP" "FLIZQI" "GM371F" "MEUZ85"
    ## [65] "PA9F3J" "TJN1AD" "WNKKW3" "XY2CK7" "XZH41H" "YDRD81" "Z25D52" "ZDRSG0"
    ## [73] "3P9BX6" "7D09WH" "DGZLV3" "S63QDN" "ZW2X4N"

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

    ## [1] "Count: 28 Sex Ratio: 8.33"
    ## [1] "Count: 33 Sex Ratio: 10"
    ## [1] "Count: 30 Sex Ratio: 9"
    ## [1] "Count: 35 Sex Ratio: 7.75"
    ## [1] "Count: 31 Sex Ratio: 9.33"
    ## [1] "Count: 28 Sex Ratio: 8.33"
    ## [1] "Count: 95 Sex Ratio: 0.23"

Examination of this table shows that of the 184 females 166 are included
in the six groups.

## Individual Mate-Pair Analysis

**groupAddAssign**, used throughout the previous section, forms whole
breeding groups. **reportMatePairs** instead answers a narrower question
– for a candidate population, which individual sire/dam pairs are even
eligible to be considered (opposite sex, both at or above **minAge**, or
of unknown age), and what does every available kinship/genetic-value
signal say about each pair? It composes the package’s existing
pair-eligibility machinery into a single report, returning two tables:
*pairs*, one row per eligible sire/dam combination, and *excluded*, one
row per pair dropped and why. It computes no composite ranking score of
its own – sort or filter the returned columns as your own workflow
requires. Marker-based kinship (**markerKinship**’s output) and each
parent’s genetic-value context (*indivMeanKin*/*gu*, from **reportGV**’s
report) can both be supplied as optional enrichment and default to `NA`
when not.

We reuse the *candidates* vector already built above, restricted further
to a small illustrative slice – one male and seven females – so the
output stays readable. One of those females is not in the kinship
matrix, so six pairs come back below and the *excluded* table is empty.
A full call against all 280 candidates would return one row per
opposite-sex, age-eligible pair, which runs into the tens of thousands.

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

### Ancestry Rules for Mate Pairs

Some centers do not want certain ancestry combinations paired (for
example, Indian-origin with Chinese-origin rhesus macaques).
**reportMatePairs** accepts the same center-configurable rules table the
**Breeding Groups** ancestry guardrails use, through *ancestryRules*. A
rule matches a pair whichever animal is the sire and whichever the dam.
A *block* rule moves the matching pair out of *pairs* and into
*excluded* with the reason `"ancestry rule"` – here “block” means “not
listed as eligible”, not “never placed together”. A *flag* rule keeps
the pair in *pairs* and annotates it. The pedigree must carry an
*ancestry* column, which the example pedigree below does.

``` r

ancPed <- qcStudbook(
  read.csv(system.file("extdata", "examples", "example_ancestry_pedigree.csv",
                       package = "nprcgenekeepr"),
           stringsAsFactors = FALSE, na.strings = c("", "NA")),
  minSireAge = 2, minDamAge = 2, reportChanges = FALSE, reportErrors = FALSE)
ancPed$gen <- findGeneration(ancPed$id, ancPed$sire, ancPed$dam)
ancKmat <- kinship(ancPed$id, ancPed$sire, ancPed$dam, ancPed$gen)
ancestryRules <- checkAncestryRules(readAncestryRules(
  system.file("extdata", "examples", "example_ancestry_rules.csv",
              package = "nprcgenekeepr")))
ancestryRules
```

    ##   ancestry1 ancestry2 severity
    ## 1    INDIAN   CHINESE    block
    ## 2    INDIAN    HYBRID    block
    ## 3    INDIAN   UNKNOWN     flag
    ## 4    INDIAN     OTHER     flag

``` r

ancMatePairs <- reportMatePairs(ancPed, ancKmat, ancestryRules = ancestryRules)
names(ancMatePairs)
```

    ## [1] "pairs"            "excluded"         "ancestryCoverage"

With rules supplied, *pairs* gains three columns: *ancestryRule* (the
matched rule as a sorted `"LEVEL-LEVEL"` string), *ancestrySeverity*
(`"flag"` or `"block"`) and *ancestryStatus* (`"violation"`, or
`"overridden"` for an overridden block rule). All three are `NA` for a
pair no rule matches. Here the only rows with a rule are the three
flagged pairs; the five blocked pairs are in *excluded*.

``` r

ancMatePairs$pairs[!is.na(ancMatePairs$pairs$ancestryRule),
                   c("sireId", "damId", "ancestryRule", "ancestrySeverity",
                     "ancestryStatus")]
```

    ##    sireId damId   ancestryRule ancestrySeverity ancestryStatus
    ## 9      I1    U1 INDIAN-UNKNOWN             flag      violation
    ## 11     O1    I2   INDIAN-OTHER             flag      violation
    ## 20     A1    U1 INDIAN-UNKNOWN             flag      violation

``` r

ancMatePairs$excluded
```

    ##   sireId damId        reason   ancestryRule
    ## 1     C1    I2 ancestry rule CHINESE-INDIAN
    ## 2     I1    C2 ancestry rule CHINESE-INDIAN
    ## 3     A1    C2 ancestry rule CHINESE-INDIAN
    ## 4     I1    H1 ancestry rule  HYBRID-INDIAN
    ## 5     A1    H1 ancestry rule  HYBRID-INDIAN

The third element, *ancestryCoverage*, lists every standardized ancestry
level with the number of distinct animals at that level (*n*) and
whether any rule names it (*covered*). A level with animals but
`covered = FALSE` – here JAPANESE – is one no rule speaks to, which is
worth a second look before relying on the rules as complete.

``` r

ancMatePairs$ancestryCoverage
```

    ##   ancestry n covered
    ## 1  CHINESE 2    TRUE
    ## 2   INDIAN 3    TRUE
    ## 3   HYBRID 1    TRUE
    ## 4 JAPANESE 2   FALSE
    ## 5    OTHER 1    TRUE
    ## 6  UNKNOWN 1    TRUE

A curator can override a *block* rule for one call with
*overriddenRules*, a data frame with *ancestry1* and *ancestry2* columns
(unordered, case-insensitive). The blocked pairs then return to *pairs*,
marked `"overridden"`, rather than silently reappearing.

``` r

overriddenMatePairs <- reportMatePairs(
  ancPed, ancKmat, ancestryRules = ancestryRules,
  overriddenRules = data.frame(ancestry1 = "CHINESE", ancestry2 = "INDIAN"))
table(overriddenMatePairs$pairs$ancestryStatus, useNA = "ifany")
```

    ## 
    ## overridden  violation       <NA> 
    ##          3          3         17

``` r

table(overriddenMatePairs$excluded$reason)
```

    ## 
    ## ancestry rule 
    ##             2

Naming a rule that is not in *ancestryRules*, a *flag* rule, or the same
rule twice is an error, as is giving *overriddenRules* without
*ancestryRules*. A valid rules table with zero rules is accepted: the
result has the ancestry columns, with nothing moved.

### Ancestry Rules for Formed Groups

**reportMatePairs** applies the rules to pairs.
**reportAncestryViolations** applies the same rules to groups that
already exist, for example the *group* element returned by
**groupAddAssign** without its final element, which holds the animals
left unused. Give it a list of animal-id vectors, one per group, the
pedigree with its *ancestry* column, and the rules table. It reports
every pair inside a group that matches a rule, *block* and *flag* rules
alike, and a *coverage* table: for each standardized ancestry level, how
many of the grouped animals sit at that level (*n*) and whether any rule
names it (*covered*). An id that is not in the pedigree stops the
function.

``` r

formedGroups <- list(c("C1", "I1", "J1"), c("I2", "U1", "H1"))
ancViolations <- reportAncestryViolations(formedGroups, ancPed, ancestryRules)
ancViolations$violations
```

    ##   group id1 id2 ancestry1 ancestry2           rule severity    status
    ## 1     1  I1  C1    INDIAN   CHINESE CHINESE-INDIAN    block violation
    ## 2     2  I2  H1    INDIAN    HYBRID  HYBRID-INDIAN    block violation
    ## 3     2  I2  U1    INDIAN   UNKNOWN INDIAN-UNKNOWN     flag violation

``` r

ancViolations$coverage
```

    ##   ancestry n covered
    ## 1  CHINESE 1    TRUE
    ## 2   INDIAN 2    TRUE
    ## 3   HYBRID 1    TRUE
    ## 4 JAPANESE 1   FALSE
    ## 5    OTHER 0    TRUE
    ## 6  UNKNOWN 1    TRUE

Each row of *violations* gives the group (its position in the list), the
two animals and their levels, the matched rule, its severity and its
status. The first group also holds a Japanese animal. No rule names that
level (*covered* is `FALSE`), so that animal appears in no violation;
the coverage table is there so that this silence is visible.

A rule named in *overriddenRules* (a data frame that gives the two
ancestry levels of the rule, in either order and in any case) still
reports its pairs, with the status `"overridden"` in place of
`"violation"`, so nothing is dropped silently. A row that matches no
rule in the rules table is an error, so a typo cannot override nothing.

``` r

ancViolationsOverridden <- reportAncestryViolations(
  formedGroups, ancPed, ancestryRules,
  overriddenRules = data.frame(ancestry1 = "CHINESE", ancestry2 = "INDIAN"))
ancViolationsOverridden$violations
```

    ##   group id1 id2 ancestry1 ancestry2           rule severity     status
    ## 1     1  I1  C1    INDIAN   CHINESE CHINESE-INDIAN    block overridden
    ## 2     2  I2  H1    INDIAN    HYBRID  HYBRID-INDIAN    block  violation
    ## 3     2  I2  U1    INDIAN   UNKNOWN INDIAN-UNKNOWN     flag  violation

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
    ##  [9] "invalidIdChars"           "invalidPlaceholderRows"  
    ## [11] "changedCols"

Each is defined below.

| Error | Definition |
|:---|:---|
| failedDatabaseConnection | Database connection failed: configuration or permissions are invalid |
| missingColumns | Columns that must be within the pedigree file are missing. |
| invalidDateRows | Values, which are supposed to be dates, cannot be interpreted as a date. |
| suspiciousParents | Parents were too young on the date of birth of the offspring to have been the parent. |
| femaleSires | Individuals listed as female and as a sire. |
| maleDams | Individuals are listed as male and as a dam. |
| sireAndDam | Individuals who are listed as both a sire and a dam. |
| duplicateIds | IDs listed more than once. |
| invalidIdChars | IDs (id, sire, or dam) that contain a period (‘.’), which is not allowed. |
| invalidPlaceholderRows | Rows with a placeholder value other than TRUE, FALSE, 1, 0 or blank (the optional column that marks stand-ins for unknown parents). |
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
    ## ! Parents with low age at birth of offspring are listed in /tmp/Rtmpwo65Ob/lowParentAge.csv.

The contents of *lowParentAge.csv* is shown below.

| dam | sire | id | sex | birth | recordStatus | placeholder | exit | sireBirth | damBirth | sireAge | damAge |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|---:|---:|
| d2 | s1 | o2 | F | 2009-03-17 | original | FALSE | NA | 2000-07-18 | 2015-09-16 | 8.66 | -6.50 |
| d2 | s2 | o3 | F | 2012-04-11 | original | FALSE | NA | 2006-06-19 | 2015-09-16 | 5.81 | -3.43 |
| d2 | s2 | o4 | M | 2006-04-13 | original | FALSE | NA | 2006-06-19 | 2015-09-16 | -0.18 | -9.43 |

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

    ##   id sire  dam sex gen      birth exit  age recordStatus placeholder
    ## 2 d2 <NA> <NA>   F   0 2006-04-13 <NA> 20.5     original       FALSE
    ## 4 s2 <NA> <NA>   M   0 2006-06-19 <NA> 20.4     original       FALSE
    ## 7 o3   s2   d2   F   1 2012-04-11 <NA> 14.5     original       FALSE
    ## 8 o4   s2   d2   M   1 2015-09-16 <NA> 11.1     original       FALSE

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
    ## Animal records where parent records are suspicious because of dates.
    ## One or more parents appear too young at time of birth.
    ##   dam sire id sex      birth recordStatus placeholder exit  sireBirth   damBirth sireAge
    ## 2  d2   s1 o2   F 2009-03-17     original       FALSE <NA> 2000-07-18 2015-09-16    8.66
    ## 3  d2   s2 o3   F 2012-04-11     original       FALSE <NA> 2006-06-19 2015-09-16    5.81
    ## 4  d2   s2 o4   M 2006-04-13     original       FALSE <NA> 2006-06-19 2015-09-16   -0.18
    ##   damAge
    ## 2   -6.5
    ## 3   -3.4
    ## 4   -9.4

The first two errors mentioned are of particular interest. Currently
**qcStudbook** automatically changes the sex of dams to *F* (female) and
sires to *M* (male) when **reportErrors** is set to .

## Genetic Loops

This feature is not supported within the Shiny application and is not
fully implemented.

To use the **findLoops** function run the following code on a pedigree
that has a loop in it. We are continuing to use the example pedigree
that comes with the software, *ExamplePedigree.csv*, which is held in
memory as `breederPed`.

``` r

exampleTree <- createPedTree(breederPed)
exampleLoops <- findLoops(exampleTree)
```

You can count the animals checked, the animals that are in loops, and
the total of the per-animal loop counts returned by **countLoops** with
the following code.

``` r

cat("Animals checked:", length(exampleLoops), "\n")
```

    ## Animals checked: 3694

``` r

cat("Animals in loops:", sum(unlist(exampleLoops)), "\n")
```

    ## Animals in loops: 145

``` r

nLoops <- countLoops(exampleLoops, exampleTree)
cat("Total of per-animal loop counts:", sum(unlist(nLoops[nLoops > 0L])), "\n")
```

    ## Total of per-animal loop counts: 258

You can list the first 10 sets of ids, sires and dams in loops with the
following line of code:

``` r

loopIds <- names(exampleLoops)[unlist(exampleLoops)]
breederPed[match(loopIds, breederPed$id), c("id", "sire", "dam")][1L:10L, ]
```

    ##          id   sire    dam
    ## 2519 MRC4BF 7ZEGLB L1VRM7
    ## 2572 SZ05LQ 7ZEGLB 4H5RS1
    ## 2695 6FDURN B2CKHA L1VRM7
    ## 2722 BWM2Z2 B2CKHA 4Y8JHT
    ## 2752 EZ2F8A 7ZEGLB DCJJYS
    ## 2755 FAPEMV 7ZEGLB 2SIP77
    ## 2905 X4UZJS B2CKHA L1VRM7
    ## 2922 ZQFCR5 7ZEGLB DCJJYS
    ## 2924 027TLR TR5L57 TEACA3
    ## 2941 1EXT8T TR5L57 ZPS15A

## Shrinking a Pedigree to a Genotyping Budget

**trimPedigree** cuts a pedigree down around the focal animals you name.
**shrinkPedigree** answers a different question: given which animals are
genotyped, which animals can be dropped and still leave a pedigree that
is informative within a genotyping-cost budget? It works on this
package’s pedigree data frame (the *id*, *sire* and *dam* columns). The
budget, *maxBits*, limits the pedigree’s bit size, which is twice the
number of non-founders less the number of founders. Three trims are
applied in order:

- The *unavailable* trim repeatedly removes animals that are not
  genotyped and have no offspring in the pedigree, then founder pairs
  that are not genotyped and have a single child and no other mate (that
  child becomes a founder), then any founder left without offspring,
  genotyped or not.
- The *non-informative* trim removes a genotyped animal that is nobody’s
  parent, has both parents known and genotyped, and is not affected,
  because it adds no genotype information beyond what its parents
  supply.
- The *affected-priority* trim, while the bit size is still above
  *maxBits*, removes one genotyped animal that is nobody’s parent at a
  time, choosing the removal that leaves the smallest bit size. It tries
  animals of unknown affected status first, then unaffected ones, then
  affected ones.

The optional *affected* vector marks the animals that show the trait you
care about; without it every animal counts as unaffected. *genotyped* is
a logical vector with one value per row of the pedigree, `NA` not
allowed. Suppose only the animals still living, those with no exit date,
are genotyped:

``` r

genotyped <- is.na(qcPed$exit)
shrinkResult <- shrinkPedigree(qcPed[, c("id", "sire", "dam")], genotyped)
unlist(shrinkResult[c("pedSizeOriginal", "pedSizeIntermed", "pedSizeFinal")])
```

    ## pedSizeOriginal pedSizeIntermed    pedSizeFinal 
    ##             280             258              44

``` r

lengths(shrinkResult$idList)
```

    ##   unavail noninform  affected 
    ##        19         3       214

The 280 animals of **qcPed** shrink to 258 after the first two trims and
44 at the end. *idList* groups the removed ids by the trim that took
them: *unavail*, *noninform* and *affected*. *idTrimmed* lists every
removed id in the order of removal, and *bitSize* records the bit size
before any trimming, after the first two trims, and after each round of
the third. The default *maxBits* is 16; a smaller budget asks the third
trim to go further.

``` r

shrinkResultSmall <- shrinkPedigree(qcPed[, c("id", "sire", "dam")], genotyped,
                                    maxBits = 8L)
c(default = nrow(shrinkResult$ped), smaller = nrow(shrinkResultSmall$ped))
```

    ## default smaller 
    ##      44      20

The smaller budget leaves 20 animals in place of 44.

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
point-and-click workflow and screenshots. Several of the small example
genotypes below (kinship, heterozygosity, exclusion, and Fst) match the
ones used there, so those numbers are the same ones shown in that
article’s tables; the candidate-parent likelihood example here differs
from the article’s.

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

**checkMarkerGenotypeFile** validates the column shape, rejects any
locus with more than two distinct alleles (the estimators below all
require biallelic markers), and stops on duplicate *id* x *locus* rows.
**buildMarkerGenotypeMatrix** then pivots the checked long-format table
into the wide *id* x *locus* matrix the rest of this section’s functions
consume, one cell per individual/locus combination (e.g. `"A/B"`), or
`NA` where that individual has no genotype call at that locus.

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
is only ever reported once the existence and uniqueness problems above
are already clean – a collision check on a mapping that doesn’t resolve
to real pedigree rows would be meaningless. The same second check also
reports a *pedB* animal whose id *mapping* already gives to a different
*pedA* animal (a `"mappedIdClash"` row), and a mapped pair whose
recorded parents conflict. A clean result from this function is what
licenses trusting the absence of a collision, not merely the absence of
a `"collision"` row in a dirty one.

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
Half-Sibling pairs, and lists only those pairs. Despite the “marker”
name shared with the rest of this section, it needs no genotype data at
all – only a kinship matrix, the pedigree, and the species’ chromosome
count and total autosomal genetic map length (in Morgans).

``` r

smallPed <- nprcgenekeepr::smallPed
smallPed$gen <- findGeneration(smallPed$id, smallPed$sire, smallPed$dam)
smallPedKmat <- kinship(smallPed$id, smallPed$sire, smallPed$dam, smallPed$gen,
                         sparse = FALSE)
## Rhesus macaque autosome count/map length are used here only as an
## example scale -- supply values appropriate to your own species.
rrv <- markerRealizedRelatednessVariance(smallPedKmat, smallPed, nChr = 20L,
                                          mapLength = 28)
rrv
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
    ## 218   M   N   0.250 Parent-Offspring 0.50 0.0000000000 0.00000000
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
    ## 1     L1     L2     1    0.5 0.3     2 23M4TN,6ZYRB6 Descriptive statistic only.

The real ids *F1*/*F2* (reusing the twin-pedigree ids from the
**Pedigree Diagram** section above) no longer appear in *idsUsed* –
every other column (the statistics themselves) is untouched. The exact
alias strings are randomly generated on every call and are not
reproduced here; what matters is that no real id from the input survives
into the de-identified table.

### Aliasing Ids with a Known Placeholder Status

**obfuscateId** gives each id a random alias. By default it reads an
id’s *shape* to decide whether it stands for an unknown parent: an id
like `"U0007"` gets a placeholder-shaped alias (the placeholder prefix
plus random characters) and every other id gets a plain one. That guess
is wrong for a real animal that happens to be named `"U1234"`.
**qcStudbook** records the truth in a *placeholder* column, and
**obfuscateId**’s *placeholder* argument takes that information, one
logical value per id: `TRUE` for a placeholder and `FALSE` for a real
animal. `NA` (or leaving the argument out) reads that id by its shape.

The aliases are random; the seed is fixed here only so the printed
values are reproducible.

``` r

ids <- c("U1234", "A100", "U0007", "B200")
isPlaceholder <- c(FALSE, FALSE, TRUE, FALSE)
set.seed(1)
obfuscateId(ids, size = 6L)
```

    ##    U1234     A100    U0007     B200 
    ## "UJNV6H" "68YXCH" "UGZN1S" "09N27H"

``` r

set.seed(1)
obfuscateId(ids, size = 6L, placeholder = isPlaceholder)
```

    ##    U1234     A100    U0007     B200 
    ## "JNV6H6" "8YXCHG" "UZN1S0" "9N27HX"

The first call reads *U1234* by its shape and gives it a
placeholder-shaped alias, so the real animal looks like an unknown
parent after de-identification. The second call marks it real, so it
gets a plain alias (random, so it could begin with `U` by chance; with
this seed it does not), while *U0007*, marked `TRUE`, keeps a
placeholder-shaped one. The argument must be logical and the same length
as *id*, or the call stops.

## MHC Haplotype Reporting

The MHC Haplotype Reporting tab of the Shiny application has four
counterparts for scripts. The input is a wide table with one row for
each animal: the animal’s id, then its two haplotype designations.
**checkMhcHaplotypeFile** checks that structure (exactly three columns,
the first an id, and one row for each animal) and gives the columns
fixed names whatever the file called them; the example data set
**rhesusGenotypes** calls the designation columns *first_name* and
*second_name*. A designation is an opaque label: it is never split or
compared with MHC region names. A trailing `?` marks an uncertain call,
and an empty cell is a missing one.

``` r

mhcChecked <- checkMhcHaplotypeFile(rhesusGenotypes)
names(rhesusGenotypes)
```

    ## [1] "id"          "first_name"  "second_name"

``` r

names(mhcChecked)
```

    ## [1] "id"         "haplotype1" "haplotype2"

``` r

head(mhcChecked, 3L)
```

    ##       id haplotype1  haplotype2
    ## 1 I67LRJ  A004_B002  A004_B048a
    ## 2 K0M2RD A004_B012b  A008_B017a
    ## 3 ZPVN1V A008_B015b A002a_B069a

**mhcHaplotypeFrequency** summarizes the table. The frequency of a
haplotype is its number of copies among the certain calls: twice the
animals, less the missing and the uncertain calls. Uncertain calls are
left out of the copy counts, the carrier counts and the frequencies, but
they are never hidden: *nUncertain* gives them for each haplotype and
the *counts* table for the file as a whole. A haplotype is flagged rare
(*isRare*) when its frequency is at or below *rareFrequencyThreshold*,
default 0.01, or its carrier count is at or below
*rareCarrierThreshold*, default 2. Both defaults are working filters,
not scientific claims.

``` r

mhcFrequency <- mhcHaplotypeFrequency(mhcChecked)
mhcFrequency$counts
```

    ##   nAnimals nCalls nMissing nUncertain denominator
    ## 1       31     62        0          2          60

``` r

head(mhcFrequency$summary)
```

    ##     haplotype nCopies nCarriers nUncertain  frequency isRare
    ## 1  A001_B001a       3         3          0 0.05000000  FALSE
    ## 2 A002a_B001a       2         2          0 0.03333333   TRUE
    ## 3 A002a_B012b       1         1          0 0.01666667   TRUE
    ## 4 A002a_B015a       1         1          0 0.01666667   TRUE
    ## 5 A002a_B024a       1         1          0 0.01666667   TRUE
    ## 6 A002a_B069a       2         2          0 0.03333333   TRUE

In this colony of 31 animals, 26 of the 33 haplotypes are flagged rare.
The smallest frequency, 0.017, is above the frequency threshold, so here
only the carrier count can flag a haplotype.

**mhcHaplotypeCarriers** goes from which haplotypes are rare to which
animals carry them: one row for each haplotype and carrying animal. By
default it lists only the haplotypes flagged rare; `rareOnly = FALSE`
lists them all. The *uncertain* column is `TRUE` when the animal’s only
calls of that haplotype are uncertain, a provisional carrier that is
listed here but is not counted as a carrier above.

``` r

rareCarriers <- mhcHaplotypeCarriers(mhcChecked)
allCarriers <- mhcHaplotypeCarriers(mhcChecked, rareOnly = FALSE)
head(rareCarriers)
```

    ##     haplotype     id uncertain
    ## 1 A002a_B001a BNHC69     FALSE
    ## 2 A002a_B001a K93DCQ     FALSE
    ## 3 A002a_B012b 6XRGWW     FALSE
    ## 4 A002a_B015a 4A4EC5     FALSE
    ## 5 A002a_B024a FHHNGA     FALSE
    ## 6 A002a_B069a 7UMJ31     FALSE

``` r

c(rare = nrow(rareCarriers), all = nrow(allCarriers))
```

    ## rare  all 
    ##   32   61

A carrier table names real animals, and a paired MHC type can identify
an animal on its own. **obfuscateMhcHaplotypes** replaces the ids in a
carrier table with the aliases that **obfuscatePed** gives the same
animals (its *map* output) and leaves the haplotype labels and the
*uncertain* column unchanged, because a haplotype name is shared
nomenclature and not an animal identifier. An id missing from the map
stops the call, so a real id cannot slip through.

``` r

set.seed(1L)
obfuscated <- obfuscatePed(rhesusPedigree[, c("id", "sire", "dam", "sex")],
                           map = TRUE)
hiddenCarriers <- obfuscateMhcHaplotypes(rareCarriers, obfuscated$map)
head(hiddenCarriers)
```

    ##     haplotype     id uncertain
    ## 1 A002a_B001a PA1H96     FALSE
    ## 2 A002a_B001a DY3FSE     FALSE
    ## 3 A002a_B012b 7P29L2     FALSE
    ## 4 A002a_B015a 1PHABI     FALSE
    ## 5 A002a_B024a T7QPMV     FALSE
    ## 6 A002a_B069a 4RBLMI     FALSE

The aliases are drawn at random, so the seed fixes them for this
document.

``` r

elapsed_time <- get_elapsed_time_str(start_time)
```

The current date and time is 2026-10-29 05:19:45.167121. The processing
time for this document was 25 seconds..

``` r

sessionInfo()
```

    ## R version 4.6.1 (2026-06-24)
    ## Platform: x86_64-pc-linux-gnu
    ## Running under: Ubuntu 24.04.5 LTS
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
    ## [1] nprcgenekeepr_2.0.0.9000 knitr_1.52               ggplot2_4.0.3           
    ## [4] stringi_1.8.9           
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] gtable_0.3.6         anytime_0.3.13       xfun_0.62            bslib_0.12.0        
    ##  [5] visNetwork_2.1.4     htmlwidgets_1.6.4    lattice_0.22-9       quadprog_1.5-8      
    ##  [9] vctrs_0.7.3          tools_4.6.1          generics_0.1.4       tibble_3.3.1        
    ## [13] pkgconfig_2.0.3      Matrix_1.7-5         data.table_1.18.6.1  checkmate_2.3.4     
    ## [17] RColorBrewer_1.1-3   S7_0.2.2             desc_1.4.3           readxl_1.6.0        
    ## [21] lifecycle_1.0.5      compiler_4.6.1       farver_2.1.2         stringr_1.6.0       
    ## [25] textshaping_1.0.5    Rlabkey_3.5.0        httpuv_1.6.17        htmltools_0.5.9     
    ## [29] sass_0.4.10          yaml_2.3.12          htmlTable_2.5.0      later_1.4.8         
    ## [33] pillar_1.11.1        pkgdown_2.2.1        jquerylib_0.1.4      DT_0.34.0           
    ## [37] cachem_1.1.0         sessioninfo_1.2.4    mime_0.13            tidyselect_1.2.1    
    ## [41] zip_3.0.2            digest_0.6.39        dplyr_1.2.1          labeling_0.4.3      
    ## [45] fastmap_1.2.0        grid_4.6.1           cli_3.6.6            magrittr_2.0.5      
    ## [49] withr_3.0.3          shinyBS_0.65.0       scales_1.4.0         promises_1.5.0      
    ## [53] backports_1.5.1      plotrix_3.8-14       lubridate_1.9.5      timechange_0.4.0    
    ## [57] rmarkdown_2.32       lambda.r_1.2.6       httr_1.4.9           otel_0.2.0          
    ## [61] futile.logger_1.4.9  cellranger_1.1.0     ragg_1.5.2           openxlsx_4.2.9      
    ## [65] shiny_1.14.0         evaluate_1.0.5       rlang_1.3.0          futile.options_1.0.1
    ## [69] Rcpp_1.1.2           xtable_1.8-8         glue_1.8.1           formatR_1.14        
    ## [73] renv_1.2.3           rstudioapi_0.19.0    jsonlite_2.0.0       R6_2.6.1            
    ## [77] systemfonts_1.3.2    fs_2.1.0

[^1]: Setting *minDamAge* to 3.5 and above will cause an error along
    with the creation of a file *lowParentAge.csv* in the session’s
    temporary directory
    ([`tempdir()`](https://rdrr.io/r/base/tempfile.html); the error
    message prints the path) that will list the parents with low age at
    the birth of an offspring: two dams in this pedigree were about 3.3
    years old at a birth. The sires are all older, so raising
    *minSireAge* alone to 3.5 does not trigger the error – exactly the
    sex-specific control the two floors provide.

[^2]: The *population* column is created and added to the pedigree
    object if it does not already exist.

[^3]: Animals with an unknown birth date, and animals that have left the
    colony, are not considered in this comparison.

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
