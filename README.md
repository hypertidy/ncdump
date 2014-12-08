# R And NetCDF Interface Development

There is a complicated and incomplete suite of NetCDF support in R with some clear missing functionality. Here we document the available support and outline some directions for improvement. 

## NetCDF terminology

* Groups - this is a NetCDF-4 feature, essentially allowing one file to contain multiple NetCDF-classic type files. 
* Compound types - these are data types identical to structs. Portability across systems is the complicating factor for these. 
* HDF5 - this is the grand-daddy library from which NetCDF-4 is derived. NetCDF-4 is a subset of HDF5, simplified in order to provide a system more like classic NetCDF but with new features - compression, tiling, groups, and compound types (others?). 

There is a complex set of overlapping support - HDF5 and NetCDF-4 can in some ways read each others data sources, but neither can read HDF4 and the use of groups and compound types is generally low, at least in the R-community. 


## Links

* The roc package for HDF4 L3bin files in R: https://github.com/mdsumner/roc
* Geospatial Data Abstraction Library (GDAL): http://www.gdal.org
* Open Source Geospatial for Windows (OSGeo4W): http://trac.osgeo.org/osgeo4w/
* Build notes: 
  + http://scigeo.org/articles/howto-install-latest-geospatial-software-on-linux.html 
  + https://github.com/mdsumner/nectar
* RNetCDF 2.0 fork: 
  + https://github.com/BertrandBrelier/RNetCDF 
  + http://wiki.scinethpc.ca/wiki/images/3/3c/NetCDF.pdf
* ncdf4: http://cirrus.ucsd.edu/~pierce/ncdf/


## General support

RNetCDF and ncdf apparently lack some features for NetCDF version 4 (though it does build against it, including features for HDF4, HDF5, Thredds/OpenDAP). 
There is currently (2014-12-08) no CRAN package for HDF, there have been h5r, rhdf5, and some packages use it internally (RcppArmadillo, others?), and there has been Windows binary support of some of these. rhdf5 is available on Bioconductor (and maybe others?)

rgdal2 is another complication, not yet on CRAN and with no support for building on Windows - it requires gdal-config installed, and so it might work if GDAL was built from source with all utilities using MingW. (?)

## Windows support 

NetCDF on CRAN is stuck at version 3, only ncdf and RNetCDF are integrated with the "win-builder" on CRAN, so they get identical binary versions of the library. GDAL on CRAN does not include NetCDF (either version 3 or 4, or HDF4 or HDF5)

## Non-R support

OSGeo4W provides binaries for NetCDF4, HDF4, HDF5, OpenDAP Thredds but rgdal cannot be easily built with these (*need details about the compiler/s used for OSGeo4W), it can all be done with MinGW but the final packaging on Windows to R is done via cross-compilation for CRAN. 

Utilities ncdump and vdp allow "dumping" of files to either text or binary format, which provides a workaround as do tools like the GDAL utilities, but the aim here is for tight coupling to make things simpler and more flexible in R directly. 

## Specific projects

ncdf4 has author-hosted Windows binaries, but these do not currently support compound types. 

RNetCDF has been forked for compound types by Bertran Brelier, but this package does not provide documentation and is not synchronized with a newer release of RNetCDF. 

## Requirements 

These are features and tasks that I want done. 

1. Ability to read NASA L3 bin files from the new NetCDF-4 format. This format includes both groups and compound types. Essentially it's a data.frame of bin number, weights, variable sum and ssq, a few other one-to-one matching values and small amount of global metadata such as "number of rows" for the sinusoidal grid, Sensor name, date, etc. This is done by the roc package for the old HDF4 format. 
2. Support for NetCDF4 in the CRAN Windows builds, or a systematic replacement for CRAN that allows provision of identical features on Linux and Windows. 
3. Rationalization of the NetCDF support provided in the R packages. Raster does not use GDAL to read NetCDF but provides its own interface either via ncdf or ncdf4. This should be able to use RNetCDF as an alternative, including whether v3 or v4 is available. Ultimately it would be preferable that GDAL understood the workarounds in raster, so then it could be used instead with the advantage that non-R languages would gain the same extra functionality. 
4. A smarter R interface for NetCDF files. This would avoid the need for raw file connections and matching attributes, dimensions and variables. Rather, you would request a variable from a source and all that stuff would be sorted out. Ideal would be with demand-paged streaming and with options for different downstream formats - either raster or other Spatial objects, via other converters. 

## Tasks

- build a project to manage the different R packages for testing 
- document v4 features available to ncdf4, ncdf and RNetCDF and what build options control different parts, include at least Thredds URL, with and without external compression, internal compression, tiling, groups, compound types and GMT variants. 
- document what is provided by GDAL from the general v4 features above (groups?)
- example suite for the use of RNetCDF(2.0) for compound types in the L3 bin files (including, can HDF5 provide some of the required support if built in??)
- define a pathway for extending ncdf4 to include compound types (just one level is sufficient if the recursive need is too hard)



## Related projects

rgdal2, ff, dplyr, data.table and raster are examples for supporting demand-paged data read. 

