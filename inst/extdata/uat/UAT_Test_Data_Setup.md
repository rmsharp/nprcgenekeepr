# UAT Test Data Setup Guide

## Required Test Files

### 1. Standard Pedigree File (testPedigree.csv)

Create or use existing file with columns:
- `id` - Animal identifier
- `sire` - Father's ID (NA for founders)
- `dam` - Mother's ID (NA for founders)
- `sex` - "M" or "F"
- `birth` - Birth date (YYYY-MM-DD format)
- `death` - Death date or NA
- `age` - Age in years (optional, can be calculated)

Minimum 50 animals recommended for meaningful analysis.

### 2. Pedigree with QC Errors (qcPed.csv)

Copy testPedigree.csv and introduce these errors:
- **Female Sire**: Set a female animal as sire of another animal
- **Male Dam**: Set a male animal as dam of another animal
- **Self-reference**: Set an animal as its own sire or dam
- **Birth before parent**: Set a birth date before parent's birth

Example errors to add:
```csv
id,sire,dam,sex,birth
F001,NA,NA,F,2010-01-01
M001,NA,NA,M,2010-06-01
CHILD1,F001,M001,M,2015-01-01  # Female sire error
CHILD2,M001,F001,F,2015-06-01  # Male dam error (M001 as dam)
```

### 3. Clean Pedigree (qcPedGood.csv)

A pedigree file with:
- All standard column names
- No QC errors
- Valid parent-offspring relationships
- Proper sex assignments

### 4. Non-Standard Column Names File (qcPedColNames.csv)

Copy clean pedigree and rename columns:
- `ID` instead of `id` (case change)
- `birth date` instead of `birth` (space)
- `ego_id` instead of `id` (alternate name)
- `si re` instead of `sire` (space in name)

### 5. Focal Animals File (focalAnimals.csv)

Single column CSV:
```csv
id
A001
A002
A003
B001
B002
```

### 6. Large Pedigree (largePedigree.csv)

For performance testing:
- 5000+ animals
- Multiple generations
- Mix of living and deceased

---

## Test Data Location

Place all test files in:
```
inst/extdata/testdata/
```

Or use existing files in:
```
inst/extdata/
```

---

## Creating Test Data Programmatically

```r
library(nprcgenekeepr)

# Generate synthetic pedigree
set.seed(42)

# Create founders (generation 0)
n_founders <- 20
founders <- data.frame(
  id = paste0("F", sprintf("%03d", 1:n_founders)),
  sire = NA_character_,
  dam = NA_character_,
  sex = rep(c("M", "F"), each = n_founders/2),
  birth = as.Date("2000-01-01") + sample(0:365, n_founders, replace = TRUE),
  stringsAsFactors = FALSE
)

# Create offspring generations
offspring <- data.frame()
current_gen <- founders

for (gen in 1:5) {
  males <- current_gen$id[current_gen$sex == "M"]
  females <- current_gen$id[current_gen$sex == "F"]

  n_offspring <- 30
  new_gen <- data.frame(
    id = paste0("G", gen, "_", sprintf("%03d", 1:n_offspring)),
    sire = sample(males, n_offspring, replace = TRUE),
    dam = sample(females, n_offspring, replace = TRUE),
    sex = sample(c("M", "F"), n_offspring, replace = TRUE),
    birth = as.Date(paste0(2000 + gen * 3, "-01-01")) +
            sample(0:365, n_offspring, replace = TRUE),
    stringsAsFactors = FALSE
  )

  offspring <- rbind(offspring, new_gen)
  current_gen <- new_gen
}

# Combine
testPedigree <- rbind(founders, offspring)

# Save clean version
write.csv(testPedigree, "inst/extdata/testdata/qcPedGood.csv",
          row.names = FALSE)

# Create version with errors
qcPed <- testPedigree
# Introduce female sire error
female_id <- qcPed$id[qcPed$sex == "F"][1]
qcPed$sire[10] <- female_id

# Introduce male dam error
male_id <- qcPed$id[qcPed$sex == "M"][1]
qcPed$dam[11] <- male_id

write.csv(qcPed, "inst/extdata/testdata/qcPed.csv",
          row.names = FALSE)

# Create non-standard column names version
qcPedColNames <- testPedigree
names(qcPedColNames) <- c("ID", "Sire ID", "Dam ID", "Sex", "Birth Date")
write.csv(qcPedColNames, "inst/extdata/testdata/qcPedColNames.csv",
          row.names = FALSE)

# Create focal animals file
focalAnimals <- data.frame(
  id = sample(testPedigree$id, 10)
)
write.csv(focalAnimals, "inst/extdata/testdata/focalAnimals.csv",
          row.names = FALSE)
```

---

## Environment Setup Checklist

- [ ] R version 4.0 or higher installed
- [ ] RStudio (optional but recommended)
- [ ] nprcgenekeepr module branch installed
- [ ] Required dependencies installed:
  - [ ] shiny
  - [ ] shinyBS
  - [ ] DT
  - [ ] ggplot2
  - [ ] lubridate
  - [ ] readxl (for Excel support)
- [ ] Test data files prepared and accessible
- [ ] Browser tested (Chrome/Firefox/Safari)
- [ ] Sufficient memory for large pedigree tests (8GB+ recommended)

---

## Quick Start Commands

```r
# Install module branch
devtools::install_github("rmsharp/nprcgenekeepr@module")

# Load and launch
library(nprcgenekeepr)
runGeneKeepr()

# Or launch with specific port
shiny::runApp(system.file("application", package = "nprcgenekeepr"),
              port = 3838)
```

---

## Browser Compatibility Notes

Test on:
- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Edge (latest)

Known considerations:
- File upload dialogs vary by browser
- Download behavior may differ (auto-download vs prompt)
- Popover positioning may vary slightly
