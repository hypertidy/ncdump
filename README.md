
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/r-gris/ncdump.svg?branch=master)](https://travis-ci.org/r-gris/ncdump) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/r-gris/ncdump?branch=master&svg=true)](https://ci.appveyor.com/project/r-gris/ncdump) [![Coverage Status](https://img.shields.io/codecov/c/github/r-gris/ncdump/master.svg)](https://codecov.io/github/r-gris/ncdump?branch=master)

NetCDF metadata in tables in R
==============================

The `ncdump` package aims to simplify and systematize read-access to NetCDF in R.

Currently the only functionality is to return the complete file metadata in tidy form, and some experimental function to return specific tables.

The `ncdump` philosophy is to hide the underlying details of calls to the NetCDF API and provide wrappers to do those operations.

Create an object that has a complete description of the file so that we can easily see the available **variables** and **dimensions** and **attributes**, and perform queries that find the details we need in a form we can used, rather than just printed out on the screen.

``` r
library(dplyr)
library(ncdump)

ifile <- system.file("extdata", "S2008001.L3m_DAY_CHL_chlor_a_9km.nc", package = "ncdump")
con <- NetCDF(ifile)
```

Note that this is just the *metadata* in the file, but we've organized it into a tidy list of tables so we can use it.

It looks good when we print those tables out, and it's pretty clear how we can use this information to drive the reader functions in the API packages.

``` r
for (i in seq_along(con)) {
  print(names(con)[i])
  print(con[[i]])
}
#> [1] "dimension"
#> # A tibble: 4 × 7
#>            name   len unlim group_index group_id    id create_dimvar
#>           <chr> <int> <lgl>       <int>    <int> <int>         <lgl>
#> 1           lat  2160 FALSE           1    65536     0          TRUE
#> 2           lon  4320 FALSE           1    65536     1          TRUE
#> 3           rgb     3 FALSE           1    65536     2         FALSE
#> 4 eightbitcolor   256 FALSE           1    65536     3         FALSE
#> [1] "unlimdims"
#> NULL
#> [1] "dimvals"
#> # A tibble: 6,739 × 2
#>       id     vals
#>    <int>    <dbl>
#> 1      0 89.95834
#> 2      0 89.87500
#> 3      0 89.79167
#> 4      0 89.70834
#> 5      0 89.62500
#> 6      0 89.54167
#> 7      0 89.45834
#> 8      0 89.37500
#> 9      0 89.29167
#> 10     0 89.20834
#> # ... with 6,729 more rows
#> [1] "groups"
#> # A tibble: 3 × 6
#>      id               name ndims nvars natts
#>   <int>              <chr> <int> <int> <int>
#> 1 65536                        4     4    65
#> 2 65537 processing_control     0     0     4
#> 3 65538   input_parameters     0     0    21
#> # ... with 1 more variables: fqgn <chr>
#> [1] "file"
#> # A tibble: 1 × 10
#>                                                                      filename
#>                                                                         <chr>
#> 1 C:/Users/mdsumner/Documents/R/win-library/3.3/ncdump/extdata/S2008001.L3m_D
#> # ... with 9 more variables: writable <lgl>, id <int>, safemode <lgl>,
#> #   format <chr>, is_GMT <lgl>, ndims <dbl>, natts <dbl>,
#> #   unlimdimid <dbl>, nvars <dbl>
#> [1] "variable"
#> # A tibble: 2 × 18
#>      name ndims natts          prec   units
#>     <chr> <int> <int>         <chr>   <chr>
#> 1 chlor_a     2    12         float mg m^-3
#> 2 palette     2     0 unsigned byte        
#> # ... with 13 more variables: longname <chr>, group_index <int>,
#> #   storage <int>, shuffle <int>, compression <int>, unlim <lgl>,
#> #   make_missing_value <lgl>, missval <dbl>, hasAddOffset <lgl>,
#> #   addOffset <dbl>, hasScaleFact <lgl>, scaleFact <dbl>, id <dbl>
#> [1] "vardim"
#> # A tibble: 4 × 2
#>      id dimids
#>   <dbl>  <int>
#> 1     0      1
#> 2     0      0
#> 3     3      3
#> 4     3      2
#> [1] "attribute"
#> [1] "NetCDF attributes:"
#> [1] "Global"
#> [1] "\n"
#> # A tibble: 1 × 65
#>                          product_name instrument
#>                                 <chr>      <chr>
#> 1 S2008001.L3m_DAY_CHL_chlor_a_9km.nc    SeaWiFS
#> # ... with 63 more variables: title <chr>, project <chr>, platform <chr>,
#> #   temporal_range <chr>, processing_version <chr>, date_created <chr>,
#> #   history <chr>, l2_flag_names <chr>, time_coverage_start <chr>,
#> #   time_coverage_end <chr>, start_orbit_number <int>,
#> #   end_orbit_number <int>, map_projection <chr>, latitude_units <chr>,
#> #   longitude_units <chr>, northernmost_latitude <dbl>,
#> #   southernmost_latitude <dbl>, westernmost_longitude <dbl>,
#> #   easternmost_longitude <dbl>, geospatial_lat_max <dbl>,
#> #   geospatial_lat_min <dbl>, geospatial_lon_max <dbl>,
#> #   geospatial_lon_min <dbl>, grid_mapping_name <chr>,
#> #   latitude_step <dbl>, longitude_step <dbl>, sw_point_latitude <dbl>,
#> #   sw_point_longitude <dbl>, geospatial_lon_resolution <dbl>,
#> #   geospatial_lat_resolution <dbl>, geospatial_lat_units <chr>,
#> #   geospatial_lon_units <chr>, spatialResolution <chr>, data_bins <int>,
#> #   number_of_lines <int>, number_of_columns <int>, measure <chr>,
#> #   data_minimum <dbl>, data_maximum <dbl>,
#> #   suggested_image_scaling_minimum <dbl>,
#> #   suggested_image_scaling_maximum <dbl>,
#> #   suggested_image_scaling_type <chr>,
#> #   suggested_image_scaling_applied <chr>, `_lastModified` <chr>,
#> #   Conventions <chr>, institution <chr>, standard_name_vocabulary <chr>,
#> #   Metadata_Conventions <chr>, naming_authority <chr>, id <chr>,
#> #   license <chr>, creator_name <chr>, publisher_name <chr>,
#> #   creator_email <chr>, publisher_email <chr>, creator_url <chr>,
#> #   publisher_url <chr>, processing_level <chr>, cdm_data_type <chr>,
#> #   identifier_product_doi_authority <chr>, identifier_product_doi <chr>,
#> #   keywords <chr>, keywords_vocabulary <chr>
#> [1] "\n"
#> [1] "Variable attributes:"
#> character(0)
```

Development
-----------

A format method for the object above could recreate the print out you see from ncdump itself.

A future package may wrap the various NetCDF R packages to do the actual read, but each is useful in different ways. The main ones are `RNetCDF`, `ncdf4` and `rhdf5` (Bioconductor).
