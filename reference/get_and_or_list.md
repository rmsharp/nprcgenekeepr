# Returns a one element character string with correct punctuation for a list made up of the elements of the character vector argument

Returns a one element character string with correct punctuation for a
list made up of the elements of the character vector argument

## Usage

``` r
get_and_or_list(c_vector, conjunction = "and")
```

## Arguments

- c_vector:

  Character vector containing the list of words to be put in a list.

- conjunction:

  The conjunction to be used as the connector. This is usually
  `and' or `or' with \`and' being the default.

## Value

A character vector of length one containing the a single correctly
punctuated character string that list each element in the first
arguments vector with commas between if there are more than two elements
with the last two elements joined by the selected conjunction.

## Examples

``` r
get_and_or_list(c("Bob", "John")) # "Bob and John"
#> [1] "Bob and John"
get_and_or_list(c("Bob", "John"), "or") # "Bob or John"
#> [1] "Bob or John"
get_and_or_list(c("Bob", "John", "Sam", "Bill"), "or")
#> [1] "Bob, John, Sam, or Bill"
# "Bob, John, Sam, or Bill"
```
