
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/mdsumner/rancid.svg?branch=master)](https://travis-ci.org/mdsumner/rancid) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/mdsumner/rancid?branch=master&svg=true)](https://ci.appveyor.com/project/mdsumner/rancid) [![Coverage Status](https://img.shields.io/codecov/c/github/mdsumner/rancid/master.svg)](https://codecov.io/github/mdsumner/rancid?branch=master)

R And NetCDF Interface Development
==================================

The `nc` package aims to simplify and systematize read-access to NetCDF in R.

The basic workflow hides the underlying details of calls to the NetCDF API.

Create an object that has a complete description of the file so that we can easily see the available variables (`vars`) and dimensions (`dims`), and perform queries that find the details we need in the form that we want, rather than just printed out on the screen.

``` r
library(dplyr)
library(rancid)

ifile <- system.file("extdata", "S2008001.L3m_DAY_CHL_chlor_a_9km.nc", package = "rancid")
nc <- NetCDF(ifile)
```

``` r
## tidyverse steals a name again
rancid::vars(nc)
#> # A tibble: 2 × 18
#>      name ndims natts          prec   units
#>     <chr> <int> <int>         <chr>   <chr>
#> 1 chlor_a     2    12         float mg m^-3
#> 2 palette     2     0 unsigned byte        
#> # ... with 13 more variables: longname <chr>, group_index <int>,
#> #   storage <int>, shuffle <int>, compression <int>, unlim <lgl>,
#> #   make_missing_value <lgl>, missval <dbl>, hasAddOffset <lgl>,
#> #   addOffset <dbl>, hasScaleFact <lgl>, scaleFact <dbl>, id <dbl>

dims(nc)
#> # A tibble: 4 × 7
#>            name   len unlim group_index group_id    id create_dimvar
#>           <chr> <int> <lgl>       <int>    <int> <int>         <lgl>
#> 1           lat  2160 FALSE           1    65536     0          TRUE
#> 2           lon  4320 FALSE           1    65536     1          TRUE
#> 3           rgb     3 FALSE           1    65536     2         FALSE
#> 4 eightbitcolor   256 FALSE           1    65536     3         FALSE

## perform a join of variable to dimension, keeping only the varname and id
rancid::vars(nc) %>% dplyr::filter(name == "chlor_a") %>% transmute(varname = name, id) %>%  inner_join(nc$vardim, "id") %>% inner_join(dims(nc), c("dimids" = "id"))
#> # A tibble: 2 × 9
#>   varname    id dimids  name   len unlim group_index group_id
#>     <chr> <dbl>  <int> <chr> <int> <lgl>       <int>    <int>
#> 1 chlor_a     0      1   lon  4320 FALSE           1    65536
#> 2 chlor_a     0      0   lat  2160 FALSE           1    65536
#> # ... with 1 more variables: create_dimvar <lgl>
```

<!--

-->
There is a complicated and incomplete suite of NetCDF support in R with some clear missing functionality. Here we document the available support and outline some directions for improvement.

**NOTE** All content here needs review in light of some changes on CRAN since December 2015.

-   CRAN now does support Windows ncdf4.
-   Raster has dropped use of ncdf.
-   RNetCDF also now includes explicit support for NetCDF-4
-   HDF4 is off my radar as NASA ocean colour have moved to NetCDF-4
-   Pretty much this will all be covered by R-hub

More soon

NetCDF terminology
------------------

-   Groups: this is a NetCDF-4 feature, essentially allowing one file to contain multiple NetCDF-classic type files.
-   Compound types: these are data types identical to structs. Portability across systems is the complicating factor for these.
-   HDF5: this is the grand-daddy library from which NetCDF-4 is derived. NetCDF-4 is a subset of HDF5, simplified in order to provide a system more like classic NetCDF but with new features - compression, tiling, groups, and compound types (others?).

There is a complex set of overlapping support - HDF5 and NetCDF-4 can in some ways read each others data sources, but neither can read HDF4 and the use of groups and compound types is generally low, at least in the R-community.

Links
-----

-   The roc package for HDF4 L3bin files in R: <https://github.com/mdsumner/roc>
-   Geospatial Data Abstraction Library (GDAL): <http://www.gdal.org>
-   Open Source Geospatial for Windows (OSGeo4W): <http://trac.osgeo.org/osgeo4w/>
-   Build notes:
-   <http://scigeo.org/articles/howto-install-latest-geospatial-software-on-linux.html>
-   <https://github.com/mdsumner/nectar>
-   RNetCDF 2.0 fork:
-   <https://github.com/BertrandBrelier/RNetCDF>
-   <http://wiki.scinethpc.ca/wiki/images/3/3c/NetCDF.pdf>
-   ncdf4: <http://cirrus.ucsd.edu/~pierce/ncdf/>

General support
---------------

RNetCDF and ncdf apparently lack some features for NetCDF version 4 (though it does build against it, including features for HDF4, HDF5, Thredds/OpenDAP). There is currently (2014-12-08) no CRAN package for HDF, there have been h5r, rhdf5, and some packages use it internally (RcppArmadillo, others?), and there has been Windows binary support of some of these. rhdf5 is available on Bioconductor (and maybe others?)

rgdal2 is another complication, not yet on CRAN and with no support for building on Windows - it requires gdal-config installed, and so it might work if GDAL was built from source with all utilities using MingW. (?)

Windows support
---------------

NetCDF on CRAN is stuck at version 3, only ncdf and RNetCDF are integrated with the "win-builder" on CRAN, so they get identical binary versions of the library. GDAL on CRAN does not include NetCDF (either version 3 or 4, or HDF4 or HDF5)

Non-R support
-------------

OSGeo4W provides binaries for NetCDF4, HDF4, HDF5, OpenDAP Thredds but rgdal cannot be easily built with these (\*need details about the compiler/s used for OSGeo4W), it can all be done with MinGW but the final packaging on Windows to R is done via cross-compilation for CRAN.

Utilities ncdump and vdp allow "dumping" of files to either text or binary format, which provides a workaround as do tools like the GDAL utilities, but the aim here is for tight coupling to make things simpler and more flexible in R directly.

Specific projects
-----------------

ncdf4 has author-hosted Windows binaries, but these do not currently support compound types.

RNetCDF has been forked for compound types by Bertran Brelier, but this package does not provide documentation and is not synchronized with a newer release of RNetCDF.

Requirements
------------

These are features and tasks that I want done.

1.  Ability to read NASA L3 bin files from the new NetCDF-4 format. This format includes both groups and compound types. Essentially it's a data.frame of bin number, weights, variable sum and ssq, a few other one-to-one matching values and small amount of global metadata such as "number of rows" for the sinusoidal grid, Sensor name, date, etc. This is done by the rrshdf4 package for the old HDF4 format, and provided via the roc package.
2.  Support for NetCDF4 in the CRAN Windows builds, or a systematic replacement for CRAN that allows provision of identical features on Linux and Windows.
3.  Rationalization of the NetCDF support provided in the R packages. Raster does not use GDAL to read NetCDF but provides its own interface either via ncdf or ncdf4. This should be able to use RNetCDF as an alternative, including whether v3 or v4 is available. Ultimately it would be preferable that GDAL understood the workarounds in raster, so then it could be used instead with the advantage that non-R languages would gain the same extra functionality.
4.  A smarter R interface for NetCDF files. This would avoid the need for raw file connections and matching attributes, dimensions and variables. Rather, you would request a variable from a source and all that stuff would be sorted out. Ideal would be with demand-paged streaming and with options for different downstream formats - either raster or other Spatial objects, via other converters.

Tasks
-----

-   build a project to manage the different R packages for testing
-   document v4 features available to ncdf4, ncdf and RNetCDF and what build options control different parts, include at least Thredds URL, with and without external compression, internal compression, tiling, groups, compound types and GMT variants.
-   document what is provided by GDAL from the general v4 features above (groups?)
-   example suite for the use of RNetCDF(2.0) for compound types in the L3 bin files (including, can HDF5 provide some of the required support if built in??)
-   define a pathway for extending ncdf4 to include compound types (just one level is sufficient if the recursive need is too hard)

Related projects
----------------

rgdal2, ff, dplyr, data.table and raster are examples for supporting demand-paged data read.
