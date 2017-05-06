## use ncdump to treat NetCDF like a virtual DB
library(ncdf4)
library(dplyr)
library(ncdump)
f <- "/rdsi/PRIVATE/raad/data/eclipse.ncdc.noaa.gov/pub/OI-daily-v2/NetCDF/2017/AVHRR/avhrr-only-v2.20170502_preliminary.nc"
x <- NetCDF(f)
x
nctive(x)
## push sst to the front for an extraction
x <- activate(x, "sst")
hyper_slab <- filtrate(x, lon = lon > 100, lat = lat < 30)
## it's alive, test the extraction
nc <- nc_open(f)

var <- ncvar_get(nc, "sst", start = bind_rows(hyper_slab)$start, count = bind_rows(hyper_slab)$count)
image(var)
## push a different var to the front
x <- activate(x, "anom")
hyper_slab <- filtrate(x, lon = between(lon, 50, 147), lat = between(lat, -42, 20))
var <- ncvar_get(nc, "sst", start = bind_rows(hyper_slab)$start, count = bind_rows(hyper_slab)$count)
image(var)


hyper_slab