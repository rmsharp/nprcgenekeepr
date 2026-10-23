## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:49 (S1043; the owner picked it at the Phase 0 picker and chose the
## scope at the PRE-RED question: all eight). The inventory, re-run S1043 (the
## exports at the S541 pass, 217, against today's NAMESPACE, 236, each name
## searched in the script): six script-callable functions the script never
## names, checkMhcHaplotypeFile(), mhcHaplotypeFrequency(),
## mhcHaplotypeCarriers(), obfuscateMhcHaplotypes(), reportAncestryViolations()
## and shrinkPedigree(), and two parameters, kinship(chrtype) (which needs the
## also-new sex) and makePedigreeMatingLayout(kinshipMatrix). A parameter found
## loosely is not a parameter shown: twinRelations is a real argument in the
## script only on makePedigreeMatingLayout(); kinship(twinRelations) and the GV
## functions are not shown (left to the BACKLOG item).
##
## The five places, in file order, each a labelled set of chunks that runs on
## data shipped with the package. The objects a chunk defines are the contract
## the result tests below read:
##   ### Passing a Kinship Matrix You Already Have   (after Twin/Zygosity)
##     layout-kinship-matrix   demoKmat, layoutFromPed, layoutFromMatrix,
##                             unnamedMatrixMessage     (needs demoPed, from the
##                             pedigree-diagram-demo-data chunk)
##   ### X-Chromosome Kinship                (last part of Genetic Value Analysis)
##     kinship-x-chromosome    xPed, autosomeKmat, xKmat   (smallPed)
##   ### Ancestry Rules for Formed Groups    (after Ancestry Rules for Mate Pairs)
##     ancestry-violations             formedGroups, ancViolations
##     ancestry-violations-overridden  ancViolationsOverridden
##                             (need ancPed and ancestryRules, from the
##                             mate-pairs-ancestry-setup chunk)
##   ## Shrinking a Pedigree to a Genotyping Budget  (before Marker Genetics)
##     shrink-pedigree         genotyped, shrinkResult
##     shrink-pedigree-budget  shrinkResultSmall
##                             (qcPed, the living animals genotyped; measured
##                             S1043: 280 rows to 258 after the first two trims,
##                             to 44 at the default budget, 19 / 3 / 214
##                             removed by the three trims, no draw at random)
##   ## MHC Haplotype Reporting              (after Marker Genetics)
##     mhc-check      mhcChecked
##     mhc-frequency  mhcFrequency
##     mhc-carriers   rareCarriers, allCarriers
##     mhc-obfuscate  obfuscated, hiddenCarriers   (sets a seed: the aliases
##                                                 are drawn at random)
##                             (rhesusGenotypes, 31 animals, all in
##                             rhesusPedigree)
##
## S1040's lesson, a drafted "2 dates" was false because "2 in all" counted
## notes: the prose of the five places states no number as a literal. Any count
## in it is inline R, computed from the objects above, so the text cannot drift
## from the output.

## sourceLines(), plainText(), chunkCode(), expectNames(), insideChunk(),
## sectionProse() and chunkOptionText() are in helper-pageText.R.
scriptPath <- file.path("vignettes", "a2interactive.Rmd")

places <- list(
  kinshipMatrix = list(
    title = "### Passing a Kinship Matrix You Already Have",
    before = "### Twin/Zygosity Connectors",
    after = "## Genetic Value Analysis",
    names = c("makePedigreeMatingLayout", "kinshipMatrix", "twinRelations"),
    prereq = "pedigree-diagram-demo-data",
    chunks = "layout-kinship-matrix"
  ),
  xKinship = list(
    title = "### X-Chromosome Kinship",
    before = "### Detailed look at the Genetic Value Report object",
    after = "## Colony Snapshots Over Time",
    names = c("kinship", "chrtype = \"x\"", "sex", "mother"),
    prereq = character(0L),
    chunks = "kinship-x-chromosome"
  ),
  formedGroups = list(
    title = "### Ancestry Rules for Formed Groups",
    before = "### Ancestry Rules for Mate Pairs",
    after = "## Pedigree Errors",
    names = c("reportAncestryViolations", "overriddenRules", "coverage"),
    prereq = "mate-pairs-ancestry-setup",
    chunks = c("ancestry-violations", "ancestry-violations-overridden")
  ),
  shrink = list(
    title = "## Shrinking a Pedigree to a Genotyping Budget",
    before = "## Genetic Loops",
    after = "## Marker Genetics",
    names = c("shrinkPedigree", "genotyped", "maxBits", "bit size"),
    prereq = character(0L),
    chunks = c("shrink-pedigree", "shrink-pedigree-budget")
  ),
  mhc = list(
    title = "## MHC Haplotype Reporting",
    before = "### Aliasing Ids with a Known Placeholder Status",
    after = NA_character_,
    names = c("checkMhcHaplotypeFile", "mhcHaplotypeFrequency",
              "mhcHaplotypeCarriers", "obfuscateMhcHaplotypes",
              "obfuscatePed", "uncertain", "rare"),
    prereq = character(0L),
    chunks = c("mhc-check", "mhc-frequency", "mhc-carriers", "mhc-obfuscate")
  )
)

## The line numbers of the "## " and "### " headings that are headings: a line
## inside a code chunk that starts with "## " is an R comment.
headingLines <- function(lines) {
  which(grepl("^#{2,3} ", lines) & !insideChunk(lines))
}

tutorialLines <- function() sourceLines(scriptPath)

## The lines of the place whose heading is `title`: from the heading to the line
## before the next heading of the same or a higher level, and for the last
## place to the line before the closing 'elapsed-time' chunk. character(0) when
## the heading is absent or stands more than once.
placeLines <- function(title, lines = tutorialLines()) {
  headings <- headingLines(lines)
  start <- headings[trimws(lines[headings]) == title]
  if (length(start) != 1L) return(character(0L))
  level <- nchar(sub(" .*$", "", title))
  levels <- nchar(sub(" .*$", "", lines[headings]))
  after <- headings[headings > start & levels <= level]
  end <- if (length(after) > 0L) after[1L] - 1L else length(lines)
  closing <- grep("^```\\{r elapsed-time[,}]", lines)
  if (length(closing) == 1L && closing > start) end <- min(end, closing - 1L)
  lines[start:end]
}

## One place's chunks run once, in order, in a fresh environment, after the
## earlier chunks of the script that it needs, with every warning and error
## kept. NULL when the place is absent.
runPlace <- local({
  cache <- list()
  function(key) {
    if (is.null(cache[[key]])) {
      place <- places[[key]]
      lines <- tutorialLines()
      section <- placeLines(place$title, lines)
      if (length(section) == 0L) return(NULL)
      env <- new.env(parent = globalenv())
      warned <- character(0L)
      failed <- character(0L)
      keep <- function(code) {
        withCallingHandlers(
          tryCatch(
            suppressMessages(eval(parse(text = code), envir = env)),
            error = function(e) failed <<- c(failed, conditionMessage(e))
          ),
          warning = function(w) {
            warned <<- c(warned, conditionMessage(w))
            invokeRestart("muffleWarning")
          }
        )
      }
      for (label in place$prereq) {
        code <- chunkCode(lines, label)
        if (!is.null(code)) keep(code)
      }
      for (label in place$chunks) {
        code <- chunkCode(section, label)
        if (!is.null(code)) keep(code)
      }
      cache[[key]] <<- list(env = env, warnings = warned, errors = failed)
    }
    cache[[key]]
  }
})

test_that("the five new places stand where the inventory put them, ahead of the closing chunks", {
  lines <- tutorialLines()
  titles <- trimws(lines[headingLines(lines)])
  for (key in names(places)) {
    place <- places[[key]]
    at <- which(titles == place$title)
    expect_true(length(at) == 1L, info = paste("not one heading:", key))
    if (length(at) == 1L) {
      if (at > 1L) expect_identical(titles[at - 1L], place$before, info = key)
      if (is.na(place$after)) {
        expect_identical(at, length(titles), info = key)
      } else {
        expect_identical(titles[at + 1L], place$after, info = key)
      }
    }
  }
  ## The timing and session-information chunks stay the last two chunks.
  mhcAt <- grep(paste0("^", places$mhc$title, "$"), trimws(lines))
  elapsedAt <- grep("^```\\{r elapsed-time[,}]", lines)
  sessionAt <- grep("^```\\{r session-info[,}]", lines)
  expect_length(elapsedAt, 1L)
  expect_length(sessionAt, 1L)
  expect_true(length(mhcAt) == 1L && length(elapsedAt) == 1L &&
                mhcAt < elapsedAt && elapsedAt < sessionAt)
})

test_that("each place names the functions and arguments it is about, in prose", {
  for (key in names(places)) {
    section <- placeLines(places[[key]]$title)
    expect_gt(length(section), 0L)
    ## The prose only: a name in a chunk's code does not count.
    text <- plainText(sectionProse(section))
    expectNames(text, places[[key]]$names, where = key)
  }
})

test_that("each place holds its labelled chunks, in order, and the earlier chunks it needs exist", {
  lines <- tutorialLines()
  for (key in names(places)) {
    place <- places[[key]]
    for (label in place$prereq) {
      expect_false(is.null(chunkCode(lines, label)),
                   info = paste(key, "needs the chunk", label))
    }
    section <- placeLines(place$title, lines)
    expect_gt(length(section), 0L)
    positions <- vapply(place$chunks, function(label) {
      hit <- grep(paste0("^```\\{r ", label, "[,}]"), section)
      if (length(hit) == 1L) hit else NA_integer_
    }, integer(1L))
    expect_false(anyNA(positions), info = paste(
      key, "missing:", paste(place$chunks[is.na(positions)], collapse = ", ")))
    expect_false(is.unsorted(positions), info = key)
  }
})

test_that("the chunks hide no warning, read no clock and fix the seed where aliases are drawn", {
  for (key in names(places)) {
    place <- places[[key]]
    section <- placeLines(place$title)
    expect_gt(length(section), 0L)
    for (label in place$chunks) {
      expect_false(any(grepl("warning = FALSE", chunkOptionText(section, label),
                             fixed = TRUE)), info = label)
      code <- chunkCode(section, label)
      expect_false(is.null(code), info = paste("no chunk labelled", label))
      expect_false(any(grepl("suppressWarnings|Sys\\.Date|Sys\\.time", code)),
                   info = label)
    }
  }
  code <- chunkCode(placeLines(places$mhc$title), "mhc-obfuscate")
  expect_true(any(grepl("set\\.seed\\(", code)),
              info = "mhc-obfuscate sets no seed")
})

test_that("the prose of the five places gives no number as a literal", {
  for (key in names(places)) {
    section <- placeLines(places[[key]]$title)
    expect_gt(length(section), 0L)
    prose <- sectionProse(section)
    withDigits <- prose[grepl("[0-9]", prose)]
    expect_length(withDigits, 0L)
  }
})

test_that("every place's chunks run in order on their own and give no warning and no error", {
  skip_on_cran()
  for (key in names(places)) {
    run <- runPlace(key)
    expect_false(is.null(run), info = paste("no place for", key))
    if (!is.null(run)) {
      expect_length(run$warnings, 0L)
      expect_length(run$errors, 0L)
    }
  }
})

test_that("a kinship matrix you already have gives the same diagram, and one without ids is refused", {
  skip_on_cran()
  run <- runPlace("kinshipMatrix")
  expect_false(is.null(run), info = "no 'Passing a Kinship Matrix' place")
  if (!is.null(run)) {
    env <- run$env
    expect_true(all(c("demoKmat", "layoutFromPed", "layoutFromMatrix",
                      "unnamedMatrixMessage") %in% ls(env)))
    if (is.matrix(env$demoKmat) || inherits(env$demoKmat, "Matrix")) {
      expect_identical(rownames(env$demoKmat), env$demoPed$id)
      expect_identical(colnames(env$demoKmat), env$demoPed$id)
    }
    if (is.list(env$layoutFromPed) && is.list(env$layoutFromMatrix)) {
      expect_identical(env$layoutFromMatrix$nodes, env$layoutFromPed$nodes)
      expect_identical(env$layoutFromMatrix$edges, env$layoutFromPed$edges)
    }
    if (is.character(env$unnamedMatrixMessage)) {
      expect_length(env$unnamedMatrixMessage, 1L)
      expect_match(env$unnamedMatrixMessage, "kinshipMatrix", fixed = TRUE)
    }
  }
})

test_that("X-chromosome kinship gives males 1 and females one half on the diagonal, unlike the autosomal matrix", {
  skip_on_cran()
  run <- runPlace("xKinship")
  expect_false(is.null(run), info = "no 'X-Chromosome Kinship' place")
  if (!is.null(run)) {
    env <- run$env
    expect_true(all(c("xPed", "autosomeKmat", "xKmat") %in% ls(env)))
    if (is.data.frame(env$xPed) && !is.null(env$xKmat) &&
          !is.null(env$autosomeKmat)) {
      xDiagonal <- diag(as.matrix(env$xKmat))
      autosomeDiagonal <- diag(as.matrix(env$autosomeKmat))
      expect_true(all(xDiagonal[env$xPed$sex == "M"] == 1))
      expect_true(all(xDiagonal[env$xPed$sex == "F"] == 0.5))
      expect_true(all(autosomeDiagonal == 0.5))
      expect_gt(sum(env$xPed$sex == "M"), 0L)
      expect_gt(sum(env$xPed$sex == "F"), 0L)
      expect_false(isTRUE(all.equal(as.matrix(env$xKmat),
                                    as.matrix(env$autosomeKmat))))
    }
  }
})

test_that("the formed-group report lists each violating pair, and an overridden rule is still listed", {
  skip_on_cran()
  run <- runPlace("formedGroups")
  expect_false(is.null(run), info = "no 'Ancestry Rules for Formed Groups' place")
  if (!is.null(run)) {
    env <- run$env
    expect_true(all(c("formedGroups", "ancViolations",
                      "ancViolationsOverridden") %in% ls(env)))
    if (is.list(env$formedGroups)) {
      expect_true(all(unlist(env$formedGroups) %in% env$ancPed$id))
    }
    if (is.list(env$ancViolations)) {
      expect_identical(names(env$ancViolations), c("violations", "coverage"))
      violations <- env$ancViolations$violations
      expect_gt(nrow(violations), 0L)
      expect_true(all(violations$status == "violation"))
      expect_setequal(env$ancViolations$coverage$ancestry,
                      c("CHINESE", "INDIAN", "HYBRID", "JAPANESE", "OTHER",
                        "UNKNOWN"))
    }
    if (is.list(env$ancViolations) && is.list(env$ancViolationsOverridden)) {
      overridden <- env$ancViolationsOverridden$violations
      ## An overridden rule is marked, never dropped.
      expect_identical(nrow(overridden), nrow(env$ancViolations$violations))
      expect_true("overridden" %in% overridden$status)
    }
  }
})

test_that("shrinking qcPed to its living animals removes animals in all three trims, and a smaller budget leaves fewer", {
  skip_on_cran()
  run <- runPlace("shrink")
  expect_false(is.null(run), info = "no 'Shrinking a Pedigree' place")
  if (!is.null(run)) {
    env <- run$env
    expect_true(all(c("genotyped", "shrinkResult", "shrinkResultSmall") %in%
                      ls(env)))
    qcPed <- nprcgenekeepr::qcPed
    expect_identical(env$genotyped, is.na(qcPed$exit))
    result <- env$shrinkResult
    if (is.list(result)) {
      expect_identical(result$pedSizeOriginal, nrow(qcPed))
      ## The three trims each take animals out.
      expect_true(all(lengths(result$idList) > 0L))
      expect_identical(result$pedSizeOriginal - result$pedSizeFinal,
                       length(result$idTrimmed))
      expect_identical(nrow(result$ped), result$pedSizeFinal)
      expect_gt(result$pedSizeFinal, 0L)
    }
    if (is.list(result) && is.list(env$shrinkResultSmall)) {
      expect_lt(env$shrinkResultSmall$pedSizeFinal, result$pedSizeFinal)
    }
  }
})

test_that("the MHC place checks, summarizes and lists carriers as the functions do, and hides the real ids", {
  skip_on_cran()
  run <- runPlace("mhc")
  expect_false(is.null(run), info = "no 'MHC Haplotype Reporting' place")
  if (!is.null(run)) {
    env <- run$env
    expect_true(all(c("mhcChecked", "mhcFrequency", "rareCarriers",
                      "allCarriers", "obfuscated", "hiddenCarriers") %in%
                      ls(env)))
    if (is.data.frame(env$mhcChecked)) {
      expect_identical(names(env$mhcChecked),
                       c("id", "haplotype1", "haplotype2"))
      expect_identical(nrow(env$mhcChecked), nrow(rhesusGenotypes))
    }
    expect_equal(env$mhcFrequency, mhcHaplotypeFrequency(rhesusGenotypes))
    expect_equal(env$rareCarriers, mhcHaplotypeCarriers(rhesusGenotypes))
    expect_equal(env$allCarriers,
                 mhcHaplotypeCarriers(rhesusGenotypes, rareOnly = FALSE))
    if (is.data.frame(env$rareCarriers) && is.data.frame(env$allCarriers)) {
      expect_lt(nrow(env$rareCarriers), nrow(env$allCarriers))
    }
    if (is.data.frame(env$hiddenCarriers) && is.data.frame(env$rareCarriers) &&
          is.list(env$obfuscated)) {
      expect_identical(env$hiddenCarriers$id,
                       unname(env$obfuscated$map[env$rareCarriers$id]))
      expect_identical(env$hiddenCarriers$haplotype, env$rareCarriers$haplotype)
      expect_identical(env$hiddenCarriers$uncertain, env$rareCarriers$uncertain)
    }
  }
})
