## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:43 (found S940, decided S950: the owner ruled that the guide's
## words change for both statements; the app does not). The colony manager
## guide said two things about the Breeding Groups tab that the app does not
## do, seen in the committed pictures and in the code:
##
##  1. "Include kinship in display of groups" was said to decide whether the
##     Group Detail sub-tab shows the within-group kinship table. It does not:
##     the table is built from the retained kinship matrix whatever the box
##     says (R/modBreedingGroups.R, bgGroupKinView), and the picture whose
##     caption said "no kinship shown" shows the table with the box unchecked.
##     The box only decides whether the groups' kinship matrices are also
##     returned by the module (groupKinship), which nothing in the app reads.
##     The user manual (vignettes/manual_components/_breeding_group_formation
##     .Rmd) already said so. The second Group Detail caption also said "the
##     same 6-group run", but the capture script ticks the box and presses Form
##     Groups again, so it is a second run (its candidate table's scores differ
##     from the first picture's).
##  2. "This particular run produced 7 groups" for a request of 6: the seventh
##     box is the animals that fit no group (four in S950's picture, seven in
##     the S956 retake; the words say the count the picture shows), which
##     the Groups and Statistics sub-tabs head "Group 7", the Group Detail
##     selector calls "Unused", and the candidate table's Groups column counts.
##     S961 (BACKLOG.md:36) changed the app: the Groups sub-tab, the Statistics
##     table and the Group Detail selector all call the box "Unused animals"
##     now. The candidate table's Groups count and the download file names
##     (Group-7.csv) are left as they were, by the owner's ruling. The S961
##     retake of the three pictures that show the box (breeding_group_1,
##     breeding_group_6_infants_with_dam, breeding_group_sex_ratio_specification)
##     has six animals in the sex-ratio picture's box, so its words say six.
##
## The first group of blocks pins what the app really does, on a nine-animal
## pedigree built here (two founders, their three full-brother sons, four
## unrelated females; two groups asked for leave the third son and one more
## male in a leftover box). They pass before the guide changes, and they are
## what keeps the new guide words true. The pedigree carries an age column, as
## the Input tab's QC step adds one: without it every pairwise kinship is
## ignored and no animal is ever left over.
##
## The second group reads the guide and fails until its words change. The
## tests that read the guide read ../../vignettes/articles/..., which
## .Rbuildignore excludes: a built package holds no copy, so they skip in a
## built package and under `devtools::check()`, and run from the source tree,
## where the close-out suite runs.

pkg_root <- testthat::test_path("..", "..")
guidePath <- file.path(pkg_root, "vignettes", "articles",
                       "colony-manager-guide.qmd")
picturesDir <- file.path(pkg_root, "vignettes", "articles", "shiny_app_use")

bgWordingPictures <- c(
  "breeding_group_sex_ratio_specification.png",
  "breeding_group_first_group_no_kinship_seeds_indicated.png",
  "breeding_group_6_seed_grps_grp_6_kinship.png"
)

# Nine animals with an age column. related = TRUE: S and D are the parents of
# M1, M2 and M3 (full brothers, kinship 0.25 with each other and with S), and
# F1-F4 are unrelated females. related = FALSE: nobody has a parent.
bgWordingPed <- function(related = TRUE) {
  ids <- c("S", "D", "M1", "M2", "M3", "F1", "F2", "F3", "F4")
  ped <- data.frame(
    id = ids,
    sire = c(NA, NA, "S", "S", "S", NA, NA, NA, NA),
    dam = c(NA, NA, "D", "D", "D", NA, NA, NA, NA),
    sex = c("M", "F", "M", "M", "M", "F", "F", "F", "F"),
    birth = as.Date("2015-01-01") - seq_along(ids) * 90L,
    exit = as.Date(NA),
    stringsAsFactors = FALSE
  )
  if (!related) {
    ped$sire <- NA_character_
    ped$dam <- NA_character_
  }
  ped$age <- as.numeric(Sys.Date() - ped$birth) / 365.25
  ped
}

# One Form Groups run in testServer at a fixed seed (the same seed gives the
# same groups). Returns what the guide's new words describe: the groups, the
# module's returned kinship, the three tabs' text, the Group Detail kinship
# download and the choices the Group Detail selector was given.
runBgWording <- function(ped, withKinship = FALSE, nGroups = 2) {
  oldOptions <- options(nprcgenekeepr.bg_seed = 7L)
  on.exit(options(oldOptions), add = TRUE)
  selectorChoices <- NULL
  out <- NULL
  testthat::local_mocked_bindings(
    updateSelectInput = function(session, inputId, label = NULL,
                                 choices = NULL, selected = NULL, ...) {
      if (identical(inputId, "viewGrp")) {
        selectorChoices <<- choices
      }
      invisible(NULL)
    },
    .package = "nprcgenekeepr"
  )
  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({ ped }), geneticValues = NULL),
    {
      session$setInputs(
        animalSource = "all", nGroups = nGroups, maxKinship = 0.25,
        sexRatio = "none", nIterations = 5, withKinship = withKinship
      )
      session$setInputs(formGroups = 1)
      session$flushReact()
      session$setInputs(viewGrp = "1")
      returned <- session$getReturned()
      out <<- list(
        hasUnused = groupResults()$candidates[[1L]]$hasUnused,
        groups = returned$groups(),
        nGroups = returned$nGroups(),
        groupKinship = returned$groupKinship(),
        groupsHtml = as.character(output$groupsDisplay$html),
        statsHtml = as.character(output$groupStats),
        candidateHtml = as.character(output$candidateComparison),
        kin = utils::read.csv(output$downloadGroupKin, row.names = 1,
                              check.names = FALSE)
      )
    }
  )
  out$selectorChoices <- selectorChoices
  out
}

# The cell values of an HTML table, one row per line.
tableCells <- function(html, nCol) {
  cells <- regmatches(html, gregexpr("<td[^>]*>[^<]*</td>", html))[[1L]]
  matrix(trimws(gsub("<[^>]+>", "", cells)), ncol = nCol, byrow = TRUE)
}

# The numbers in the Groups tab's headings "Group N (M animals)".
groupHeadings <- function(html) {
  text <- gsub("\\s+", " ", gsub("<[^>]+>", " ", html))
  found <- regmatches(
    text, gregexpr("Group [0-9]+ \\([0-9]+ animals\\)", text)
  )[[1L]]
  list(
    n = as.integer(sub("Group ([0-9]+) .*", "\\1", found)),
    animals = as.integer(sub(".*\\(([0-9]+) animals\\)", "\\1", found))
  )
}

readGuideText <- function() {
  skip_if_not(file.exists(guidePath), "colony manager guide not present")
  gsub("\\s+", " ", paste(readLines(guidePath, warn = FALSE), collapse = " "))
}

# The first piece of text matching a (perl) pattern, or "" when there is none,
# so a missing paragraph fails on its words, not on an empty vector.
firstMatch <- function(text, pattern) {
  hit <- regmatches(text, regexpr(pattern, text, perl = TRUE))
  if (length(hit) == 0L) "" else hit
}

# Caption and alt text of one picture, as written in the guide.
pictureText <- function(text, file) {
  pattern <- paste0(
    "!\\[([^]]*)\\]\\(shiny_app_use/", gsub(".", "\\.", file, fixed = TRUE),
    "\\)\\{fig-alt=\"([^\"]*)\"\\}"
  )
  hit <- regmatches(text, regexec(pattern, text))[[1L]]
  expect_length(hit, 3L)
  list(caption = hit[2L], alt = hit[3L])
}

# ---- control: the guide cites the three pictures and they exist -----------

test_that("the guide cites the three Breeding Groups pictures the words describe", {
  text <- readGuideText()
  skip_if_not(dir.exists(picturesDir), "picture folder not present")
  for (pic in bgWordingPictures) {
    expect_true(grepl(paste0("shiny_app_use/", pic), text, fixed = TRUE),
                label = paste("guide cites", pic))
    expect_true(file.exists(file.path(picturesDir, pic)),
                label = paste("file exists:", pic))
  }
})

# ---- what the app does: these pass now and keep the new words true --------

test_that("the kinship box does not change the Group Detail kinship table", {
  skip_if_not_installed("shiny")
  unchecked <- runBgWording(bgWordingPed(), withKinship = FALSE)
  checked <- runBgWording(bgWordingPed(), withKinship = TRUE)

  # Same seed, same groups, so the two runs differ only in the box.
  expect_identical(unchecked$groups, checked$groups)
  # The table is there with the box unchecked: one row and column per member.
  expect_gt(nrow(unchecked$kin), 0L)
  expect_setequal(rownames(unchecked$kin), unchecked$groups[[1L]])
  expect_setequal(colnames(unchecked$kin), unchecked$groups[[1L]])
  # ... and it is the same table with the box checked.
  expect_identical(unchecked$kin, checked$kin)
  # What the box does decide: the kinship the module hands on to other code.
  expect_null(unchecked$groupKinship)
  expect_false(is.null(checked$groupKinship))
})

test_that("animals that fit no group end in a last box named Unused animals", {
  skip_if_not_installed("shiny")
  r <- runBgWording(bgWordingPed(), nGroups = 2)

  expect_true(r$hasUnused)
  # Two groups asked for, three boxes: the third holds animals placed nowhere.
  expect_equal(r$nGroups, 3L)
  leftover <- r$groups[[3L]]
  expect_gt(length(leftover), 0L)
  expect_length(intersect(leftover, unlist(r$groups[1:2])), 0L)

  # The Groups sub-tab heads the two groups "Group n (m animals)" and the last
  # box "Unused animals (k animals)": no "Group 3".
  headings <- groupHeadings(r$groupsHtml)
  expect_equal(headings$n, 1:2)
  expect_equal(headings$animals, lengths(r$groups[1:2]))
  expect_match(
    gsub("\\s+", " ", gsub("<[^>]+>", " ", r$groupsHtml)),
    sprintf("Unused animals \\(%d animals\\)", length(leftover))
  )
  expect_false(grepl("Group 3", r$groupsHtml, fixed = TRUE))

  # The Statistics sub-tab names its last row "Unused animals", not 3.
  stats <- tableCells(r$statsHtml, nCol = 4L)
  expect_equal(stats[, 1L], c("1", "2", "Unused animals"))
  expect_equal(as.integer(stats[, 2L]), lengths(r$groups))

  # The Group Detail selector calls it "Unused animals"; its values stay the
  # group numbers (the capture script sets the box by value).
  expect_equal(names(r$selectorChoices),
               c("Group 1", "Group 2", "Unused animals"))
  expect_equal(as.integer(r$selectorChoices), 1:3)
})

test_that("the candidate table's Groups column counts the last box too", {
  skip_if_not_installed("shiny")
  r <- runBgWording(bgWordingPed(), nGroups = 2)

  candidates <- tableCells(r$candidateHtml, nCol = 3L)
  expect_gte(nrow(candidates), 1L)
  expect_equal(as.integer(candidates[1L, 3L]), 3L)
})

test_that("when every animal fits a group there is no last box", {
  skip_if_not_installed("shiny")
  r <- runBgWording(bgWordingPed(related = FALSE), nGroups = 2)

  expect_false(r$hasUnused)
  expect_equal(r$nGroups, 2L)
  expect_equal(groupHeadings(r$groupsHtml)$n, 1:2)
  expect_equal(names(r$selectorChoices), c("Group 1", "Group 2"))
  # No box, so nothing is called "Unused animals" on any tab.
  expect_false(grepl("Unused", r$groupsHtml, fixed = TRUE))
  expect_false(grepl("Unused", r$statsHtml, fixed = TRUE))
  expect_equal(tableCells(r$statsHtml, nCol = 4L)[, 1L], c("1", "2"))
})

# ---- the guide's words: these fail until the guide changes ----------------

test_that("the Group Detail paragraph says the kinship table shows either way", {
  text <- readGuideText()
  paragraph <- firstMatch(
    text, "Each formed group's full membership.*?(?= !\\[Group Detail)"
  )
  expect_true(nzchar(paragraph), label = "the Group Detail paragraph exists")
  expect_match(
    paragraph,
    paste0("shown whether or not \\*\\*Include kinship in display of groups",
           "\\*\\* is checked"),
    perl = TRUE
  )
  expect_match(paragraph, "the box does not change what this sub-tab shows",
               fixed = TRUE)
  expect_no_match(paragraph, "was checked before forming", fixed = TRUE)
})

test_that("the first Group Detail picture says the box is unchecked", {
  text <- readGuideText()
  pic <- pictureText(
    text, "breeding_group_first_group_no_kinship_seeds_indicated.png"
  )
  expect_match(pic$caption, "with the kinship box unchecked", fixed = TRUE)
  expect_match(pic$caption, "the kinship table is shown anyway", fixed = TRUE)
  expect_match(pic$alt, "with the kinship box unchecked", fixed = TRUE)
  expect_no_match(pic$caption, "no kinship shown", fixed = TRUE)
  expect_no_match(pic$alt, "without kinship values", fixed = TRUE)
})

test_that("the second Group Detail picture is a second run with the box checked", {
  text <- readGuideText()
  pic <- pictureText(text, "breeding_group_6_seed_grps_grp_6_kinship.png")
  expect_match(pic$caption, "group 6 of a second run", fixed = TRUE)
  expect_match(pic$caption, "formed with the kinship box checked", fixed = TRUE)
  expect_match(pic$caption, "the kinship table is shown in the same way",
               fixed = TRUE)
  expect_match(pic$alt, "from a second run formed with the kinship box checked",
               fixed = TRUE)
  expect_no_match(pic$caption, "same 6-group run", fixed = TRUE)
  expect_no_match(pic$caption, "kinship values included", fixed = TRUE)
})

test_that("the sex-ratio paragraph says 6 groups and a seventh box of leftovers", {
  text <- readGuideText()
  paragraph <- firstMatch(
    text, "The screenshot below shows one working example.*?(?= !\\[Breeding)"
  )
  expect_true(nzchar(paragraph), label = "the sex-ratio paragraph exists")
  expect_match(
    paragraph,
    paste0("this particular run produced 6 groups, each drawn toward the ",
           "target ratio where enough candidates of each sex were available, ",
           "and a seventh box that lists the six animals that fit no group"),
    fixed = TRUE
  )
  expect_no_match(paragraph, "produced 7 groups", fixed = TRUE)
})

test_that("the sex-ratio picture's alt text says 6 groups and a seventh box", {
  text <- readGuideText()
  pic <- pictureText(text, "breeding_group_sex_ratio_specification.png")
  expect_match(pic$alt, "showing 6 groups formed in one run", fixed = TRUE)
  expect_match(pic$alt,
               "plus a seventh box listing the six animals that fit no group",
               fixed = TRUE)
  expect_no_match(pic$alt, "7 groups formed", fixed = TRUE)
})

test_that("a paragraph after the sex-ratio picture explains the last box", {
  text <- readGuideText()
  paragraph <- firstMatch(
    text,
    paste0("breeding_group_sex_ratio_specification\\.png\\)",
           "\\{fig-alt=\"[^\"]*\"\\} \\K.*?(?= \\*\\*Seeding groups)")
  )
  expect_true(nzchar(paragraph),
              label = "the paragraph after the picture exists")
  expect_match(paragraph, "That last box is not a group", fixed = TRUE)
  expect_match(paragraph, "only when some candidates fit in no group",
               fixed = TRUE)
  expect_match(
    paragraph,
    paste0("The **Groups** sub-tab, the **Statistics** table and the ",
           "**Group Detail** selector all call it 'Unused animals'"),
    fixed = TRUE
  )
  expect_no_match(paragraph, "'Group 7' here", fixed = TRUE)
  expect_no_match(paragraph, "calls it 'Unused'", fixed = TRUE)
  expect_match(paragraph, "the Groups count in the candidate table",
               fixed = TRUE)
})
