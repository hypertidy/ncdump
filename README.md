
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/r-gris/ncdump.svg?branch=master)](https://travis-ci.org/r-gris/ncdump) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/r-gris/ncdump?branch=master&svg=true)](https://ci.appveyor.com/project/r-gris/ncdump) [![Coverage Status](https://img.shields.io/codecov/c/github/r-gris/ncdump/master.svg)](https://codecov.io/github/r-gris/ncdump?branch=master)

NetCDF metadata in tables in R
==============================

The `ncdump` package aims to simplify the way we can approach NetCDF in R.

Currently the only real functionality is to return the complete file metadata in tidy form. There is some experimental function to return specific entities, but in my experience the existing tools `ncdf4`, `raster`, `rgdal`, `RNetCDF` and `rhdf5` are sufficient for easily accessing almost everything. Where they fall down is in providing easy and complete information about what is available in the files, so that's where `ncdump::NetCDF` comes in.

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
#> 1 /perm_storage/home/mdsumner/R/x86_64-pc-linux-gnu-library/3.4/ncdump/extdat
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

Rationale
---------

The main problems with the existing packages are that they are either too high-level or too low-level and it's this twilight zone in the middle where `ncdump` comes in, where the user needs to reach down a bit deeper to make things work. Using the wrappers around the raw API `ncdf4` and `RNetCDF` is very raw, and for the most part is analogous to the NetCDF API itself, though you don't have to compile the code. These packages aren't the same, and neither can read all kinds of NetCDF files. Both do support API features like NetCDF 4, server interfaces (OpenDAP and Thredds and the like), support for HDF, and parallel processing but it depends on how you build the underlying libaries. The details on this are not on the agenda here.

The worker for most low-level NetCDF access is the command line utility `ncdump -h` - if not called with the `h`eader argument you can actually dump the data contents in various ways, including binary forms to other formats. The header is usually what you are expected to read to figure out how to program against the contents. It's not completely automatable, because it's so general it's unlikely that your generalized code will solve any particular practical task and there's no general libary for NetCDF that will give you practical outcomes for all types of data. It's a non-virtuous cycle.

The `raster` package is excellent for NetCDF, but it only works "off-the-shelf" for regularly xy-gridded data in 2D, 3D or 4D variables. The mapping of dimensions to these variables is patchy, because the format is so general and many data variables have rectilinear or curvilinear coordinates, which are either ignored by raster or cause it to stop without reading anything. If you know what you want you can get it to work with any 2D or higher variable. Raster is a high-level domain-specific library, for GIS-y rasters, or grids that use an affine transform to define their coordinate system in xy.

GDAL, available in `rgdal` has similar limitations to raster for the same affine/GIS reason, but also makes different choices when approaching higher dimensions. Essentially all higher dimensions get unrolled as extra bands for a GDAL data set. They are completely independently implemented, GDAL has an in-built NetCDF driver (also a GMT variant) and raster uses `ncdf4` directly. (Raster will use `rgdal` when it can for many formats, but you cannot actually override raster's used of ncdf4 without uninstalling that package. It's all quite complicated and poorly understood unfortunately, and it keeps changing).

There is another package `rhdf5` which provides excellent modern facilities for HDF5 and NetCDF4, and notably this can read NetCDF files with compound types that no other package can do. This would be perfect if it could also read NetCDF "classic format", i.e. version 3.x prior to NetCDF 4.

I use `ncdump` in conjunction with `angstroms` and various other projects. I can perform joins and select/filter tasks on the tables it returns, but it's not designed in any high-level consistent way, it just gives all the information it can get.

Development
-----------

A format method for the object above could recreate the print out you see from ncdump itself.

A future package may wrap the various NetCDF R packages to do the actual read, but each is useful in different ways. The main ones are `RNetCDF`, `ncdf4` and `rhdf5` (Bioconductor).

This project was split out of the "R and NetCDF interface development" project. <https://github.com/mdsumner/rancid>

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
