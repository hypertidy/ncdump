
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/r-gris/nc.svg?branch=master)](https://travis-ci.org/r-gris/nc) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/r-gris/nc?branch=master&svg=true)](https://ci.appveyor.com/project/r-gris/nc) [![Coverage Status](https://img.shields.io/codecov/c/github/r-gris/nc/master.svg)](https://codecov.io/github/r-gris/nc?branch=master)

NetCDF metadata in tables in R
==============================

The `nc` package aims to simplify and systematize read-access to NetCDF in R.

The basic workflow hides the underlying details of calls to the NetCDF API.

Create an object that has a complete description of the file so that we can easily see the available variables (`vars`) and dimensions (`dims`), and perform queries that find the details we need in the form that we want, rather than just printed out on the screen.

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(nc)
#> 
#> Attaching package: 'nc'
#> The following object is masked from 'package:dplyr':
#> 
#>     vars

ifile <- system.file("extdata", "S2008001.L3m_DAY_CHL_chlor_a_9km.nc", package = "nc")
con <- NetCDF(ifile)
```

``` r
nc::vars(con)
#> # A tibble: 2 × 18
#>      name ndims natts          prec   units
#>     <chr> <int> <int>         <chr>   <chr>
#> 1 chlor_a     2    12         float mg m^-3
#> 2 palette     2     0 unsigned byte        
#> # ... with 13 more variables: longname <chr>, group_index <int>,
#> #   storage <int>, shuffle <int>, compression <int>, unlim <lgl>,
#> #   make_missing_value <lgl>, missval <dbl>, hasAddOffset <lgl>,
#> #   addOffset <dbl>, hasScaleFact <lgl>, scaleFact <dbl>, id <dbl>

dims(con)
#> # A tibble: 4 × 7
#>            name   len unlim group_index group_id    id create_dimvar
#>           <chr> <int> <lgl>       <int>    <int> <int>         <lgl>
#> 1           lat  2160 FALSE           1    65536     0          TRUE
#> 2           lon  4320 FALSE           1    65536     1          TRUE
#> 3           rgb     3 FALSE           1    65536     2         FALSE
#> 4 eightbitcolor   256 FALSE           1    65536     3         FALSE

## perform a join of variable to dimension, keeping only the varname and id
nc::vars(con) %>% dplyr::filter(name == "chlor_a") %>% transmute(varname = name, id) %>%  inner_join(con$vardim, "id") %>% inner_join(dims(con), c("dimids" = "id"))
#> # A tibble: 2 × 9
#>   varname    id dimids  name   len unlim group_index group_id
#>     <chr> <dbl>  <int> <chr> <int> <lgl>       <int>    <int>
#> 1 chlor_a     0      1   lon  4320 FALSE           1    65536
#> 2 chlor_a     0      0   lat  2160 FALSE           1    65536
#> # ... with 1 more variables: create_dimvar <lgl>
```

<!--

-->
