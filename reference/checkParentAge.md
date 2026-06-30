# Check parent ages to be at least `minParentAge`

Ensure parents are sufficiently older than offspring

## Usage

``` r
checkParentAge(sb, minParentAge = 2L, reportErrors = FALSE)
```

## Arguments

- sb:

  A dataframe containing a table of pedigree and demographic
  information.

- minParentAge:

  numeric values to set the minimum age in years for an animal to have
  an offspring. Defaults to 2 years. The check is not performed for
  animals with missing birth dates.

- reportErrors:

  logical value if TRUE will scan the entire file and make a list of all
  errors found. The errors will be returned in a list of list where each
  sublist is a type of error found.

## Value

A dataframe containing rows for each animal where one or more parent was
less than `minParentAge`. It contains all of the columns in the original
`sb` dataframe with the following added columns:

1.  `sireBirth` – sire's birth date

2.  `sireAge` – age of sire in years on the date indicated by `birth`.

3.  `damBirth` – dam's birth date

4.  `damAge` – age of dam in years on the date indicated by `birth`.

## Examples

``` r
library(nprcgenekeepr)
qcPed <- nprcgenekeepr::qcPed
checkParentAge(qcPed, minParentAge = 2L)
#>  [1] dam       sire      id        sex       gen       birth     exit     
#>  [8] age       sireBirth damBirth  sireAge   damAge   
#> <0 rows> (or 0-length row.names)
checkParentAge(qcPed, minParentAge = 3L)
#>  [1] dam       sire      id        sex       gen       birth     exit     
#>  [8] age       sireBirth damBirth  sireAge   damAge   
#> <0 rows> (or 0-length row.names)
checkParentAge(qcPed, minParentAge = 5L)
#>       dam   sire     id sex gen      birth       exit  age sireBirth   damBirth
#> 63 EX98QB UAJJG4 L8Q55X   F   2 1993-09-23 2007-05-16 13.6      <NA> 1989-02-18
#>    sireAge damAge
#> 63      NA   4.59
checkParentAge(qcPed, minParentAge = 6L)
#>        dam   sire     id sex gen      birth       exit  age  sireBirth
#> 63  EX98QB UAJJG4 L8Q55X   F   2 1993-09-23 2007-05-16 13.6       <NA>
#> 90  L42X7I ULYO4W BA0JYM   F   2 2004-02-29       <NA> 15.3       <NA>
#> 98  MRGPPA U7F4QJ JUMNN0   F   3 1993-12-31 2008-04-30 14.3       <NA>
#> 102 O4Z4IB UYLDPW HFEQNK   F   2 1996-03-20 2017-02-04 20.9       <NA>
#> 125 RY6OPR 549AEC 80EOVS   F   3 2005-12-10       <NA> 13.5 1998-09-27
#> 156 ZYTIYY UP4NEJ E5BLUE   F   1 1980-08-22 1998-11-18 18.2       <NA>
#>       damBirth sireAge damAge
#> 63  1989-02-18      NA   4.59
#> 90  1998-09-17      NA   5.45
#> 98  1988-03-19      NA   5.79
#> 102 1990-08-29      NA   5.56
#> 125 2000-02-29     7.2   5.78
#> 156 1974-12-21      NA   5.67
head(checkParentAge(qcPed, minParentAge = 10L))
#>       dam   sire     id sex gen      birth       exit  age  sireBirth
#> 1  0DXI08 HRQJQR G6P0W4   F   1 1979-02-02 2000-04-15 21.2 1969-12-04
#> 2  0RV8OM QBLTI6 8IJUQO   F   3 1999-02-03 2017-04-27 18.2 1987-12-27
#> 11 3CQZ3E U0M96T MRGPPA   F   2 1988-03-19 2008-03-20 20.0       <NA>
#> 12 3O7TMT 5EP5AL L6D4ZC   M   2 1988-06-25 2009-04-10 20.8 1976-09-30
#> 13 43TUN9 L6D4ZC AXDMJM   F   3 1999-11-09       <NA> 19.6 1988-06-25
#> 15 4WB10I 5EP5AL DO4NKS   M   2 1991-08-04 2013-02-08 21.5 1976-09-30
#>      damBirth sireAge damAge
#> 1  1965-01-04    9.16  14.08
#> 2  1992-06-22   11.10   6.62
#> 11 1981-09-22      NA   6.49
#> 12 1981-09-15   11.73   6.78
#> 13 1990-07-14   11.37   9.32
#> 15 1982-03-30   14.84   9.35
```
