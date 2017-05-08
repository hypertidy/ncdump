sample_file <- function(x, ...) {
  dplyr::sample_n(x, 1L) %>% dplyr::select(date, fullname)
}
library(ncdump)
library(tibble)
library(dplyr, warn.conflicts = FALSE)
library(maps)
library(raadtools)
set.seed(1)

files <- lapply(list(
sstfiles(time.resolution = "daily")
 ,sstfiles(time.resolution = "monthly")
 ,chlafiles()
 ,currentsfiles()
 ,derivicefiles()
 ,derivaadcfiles("si_200_interpolated_summer_climatology") %>% mutate(date = as.POSIXct(NA))
 #,icefiles(product = "amsr")
 ,ocfiles(time.resolution = "monthly", product = "SeaWiFS", varname = "CHL", type= "L3m")
 ,sshfiles(ssha = TRUE)
,(windfiles() %>% dplyr::transmute(fullname = ufullname, date))
), sample_file) %>% bind_rows()


## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------

f <-  files$fullname[1]
print(gsub(getOption("default.datadir"), "", f))
## the idea is to find out what's the file
NetCDF(f) %>% dimension_values() %>% group_by(name) %>% summarize_at("vals", funs(min, max))
(x <- NetCDF(f) )

## then build up a query, returning a subsett-ed set of tables of each dimension's coordinates
trans <- x %>% filtrate(lon = lon > 100, lat = between(lat, -30, 20))
## extract the hyperslab index from the transform tables
hslab <- bind_rows(lapply(trans, function(x) tibble(name = x$name[1], start = min(x$step), count = length(x$step))))

## open the file and pull out that slab 
con <- ncdf4::nc_open(x$file$filename[1])
slab <- ncdf4::ncvar_get(con, nctive(x), 
                         start = hslab$start, 
                         count = hslab$count)

## (this will be wrapped up in an easy function but it's important to keep things general)
image(trans$lon$lon, trans$lat$lat, slab, col = viridis::viridis(100))
map("world2", add = TRUE)

## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------


f <-  files$fullname[2]
print(gsub(getOption("default.datadir"), "", f))

(x <- NetCDF(f) )

## the idea is to find out what's the file
x %>% dimension_values() %>% group_by(name) %>% summarize_at("vals", funs(min, max))

## then build up a query, returning a subsett-ed set of tables of each dimension's coordinates
(trans <- x %>% filtrate(lon = lon > 250, lat = lat < -10))
## extract the hyperslab index from the transform tables
## notice how this and the next block is completely devoid of references to the dimension or variable names
hslab <- bind_rows(lapply(trans, function(x) tibble(name = x$name[1], start = min(x$step), count = length(x$step))))

## open the file and pull out that slab 
con <- ncdf4::nc_open(x$file$filename[1])
slab <- ncdf4::ncvar_get(con, nctive(x), 
                         start = hslab$start, 
                         count = hslab$count)

## (this will be wrapped up in an easy function but it's important to keep things general)
## note that this file uses south-up convention
image(trans$lon$lon, rev(trans$lat$lat), slab[,ncol(slab):1,1], col = viridis::viridis(100))
map("world2", add = TRUE)

## see how we got a 3D slab this time, because we didn't subset on time
dim(slab)

## this time the slab will be 2D , in longitude ~ time
(trans <- x %>% filtrate(lon = lon == 147.5, lat = lat < 0 & lat > -70))
## extract the hyperslab index from the transform tables
## notice how this and the next block is completely devoid of references to the dimension or variable names
hslab <- bind_rows(lapply(trans, function(x) tibble(name = x$name[1], start = min(x$step), count = length(x$step))))

## open the file and pull out that slab 
con <- ncdf4::nc_open(x$file$filename[1])
slab <- ncdf4::ncvar_get(con, nctive(x), 
                         start = hslab$start, 
                         count = hslab$count)


image(rev(trans$lat$lat), trans$time$time, slab[nrow(slab):1, ], col = viridis::viridis(100))


## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------


f <-  files$fullname[3]
print(gsub(getOption("default.datadir"), "", f))

(x <- NetCDF(f) )
x %>% dimension_values() %>% group_by(name) %>% summarize_at("vals", funs(min, max))

(trans <- x %>% filtrate(longitude = longitude > 0, latitude = latitude > -50))
## extract the hyperslab index from the transform tables
## notice how this and the next block is completely devoid of references to the dimension or variable names
hslab <- bind_rows(lapply(trans, function(x) tibble(name = x$name[1], start = min(x$step), count = length(x$step))))

## open the file and pull out that slab 
con <- ncdf4::nc_open(x$file$filename[1])
slab <- ncdf4::ncvar_get(con, nctive(x), 
                         start = hslab$start, 
                         count = hslab$count)

## (this will be wrapped up in an easy function but it's important to keep things general)
## note that this file uses south-up convention
image(trans$longitude$longitude, trans$latitude$latitude, log(slab), col = viridis::viridis(100))
map("world2", add = TRUE)




## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------

f <-  files$fullname[4]
print(gsub(getOption("default.datadir"), "", f))

## now we really want to activate a different variable, because the default chosen is not of interest
(x <- NetCDF(f) )

(x <- NetCDF(f) %>% activate("u"))

x %>% dimension_values() %>% group_by(name) %>% summarize_at("vals", funs(min, max))

(trans <- x %>% filtrate(lon = between(lon, 100, 150), lat = lat > -50 & lat < 20))
## extract the hyperslab index from the transform tables
## notice how this and the next block is completely devoid of references to the dimension or variable names
hslab <- bind_rows(lapply(trans, function(x) tibble(name = x$name[1], start = min(x$step), count = length(x$step))))

## open the file and pull out that slab 
con <- ncdf4::nc_open(x$file$filename[1])
uslab <- ncdf4::ncvar_get(con, nctive(x), 
                         start = hslab$start, 
                         count = hslab$count)

## get the other slab while we are at it
x <- activate(x, "v")
vslab <- ncdf4::ncvar_get(con, nctive(x), 
                         start = hslab$start, 
                         count = hslab$count)

## (this will be wrapped up in an easy function but it's important to keep things general)
## note that this file uses south-up convention
image(trans$lon$lon, trans$lat$lat, uslab, col = viridis::viridis(100))

## use u and v together
image(trans$lon$lon, trans$lat$lat, sqrt(uslab^2 + vslab^2), col = viridis::viridis(100))
map("world2", add = TRUE)



## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------


f <-  files$fullname[5]
print(gsub(getOption("default.datadir"), "", f))


(nc_object <- NetCDF(f) %>% activate("days_since_ice_melt"))
nc_object %>% dimension_values() %>% group_by(name) %>% summarize_at("vals", funs(min, max))

## what's wrong here??

#(trans <- nc_object %>% filtrate(x = x > 0, y = y < 0))


## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------

f <-  files$fullname[6]
print(gsub(getOption("default.datadir"), "", f))
## the idea is to find out what's the file
NetCDF(f) %>% dimension_values() %>% group_by(name) %>% summarize_at("vals", funs(min, max))
(x <- NetCDF(f) )

## then build up a query, returning a subsett-ed set of tables of each dimension's coordinates
trans <- x %>% filtrate(lon = lon > 100, lat = between(lat, -50, -30))
## extract the hyperslab index from the transform tables
hslab <- bind_rows(lapply(trans, function(x) tibble(name = x$name[1], start = min(x$step), count = length(x$step))))

## open the file and pull out that slab 
con <- ncdf4::nc_open(x$file$filename[1])
slab <- ncdf4::ncvar_get(con, nctive(x), 
                         start = hslab$start, 
                         count = hslab$count)

## (this will be wrapped up in an easy function but it's important to keep things general)
image(trans$lon$lon, trans$lat$lat, slab, col = viridis::viridis(100))
map("world2", add = TRUE)

## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------

f <-  files$fullname[7]
print(gsub(getOption("default.datadir"), "", f))
## the idea is to find out what's the file
NetCDF(f) %>% dimension_values() %>% group_by(name) %>% summarize_at("vals", funs(min, max))
(x <- NetCDF(f) )

## then build up a query, returning a subsett-ed set of tables of each dimension's coordinates
trans <- x %>% filtrate(lon = lon > 100, lat = between(lat, -50, -30))
## extract the hyperslab index from the transform tables
hslab <- bind_rows(lapply(trans, function(x) tibble(name = x$name[1], start = min(x$step), count = length(x$step))))

## open the file and pull out that slab 
con <- ncdf4::nc_open(x$file$filename[1])
slab <- ncdf4::ncvar_get(con, nctive(x), 
                         start = hslab$start, 
                         count = hslab$count)

cpal <- palr::chlPal(palette = TRUE)
image(trans$lon$lon, rev(trans$lat$lat), slab[,ncol(slab):1], col = cpal$cols[-1], breaks = cpal$breaks)
map("world2", add = TRUE)



## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------

f <-  files$fullname[8]
print(gsub(getOption("default.datadir"), "", f))
## the idea is to find out what's the file
NetCDF(f) %>% dimension_values() %>% group_by(name) %>% summarize_at("vals", funs(min, max))
(x <- NetCDF(f) %>% activate("sla") )

## then build up a query, returning a subsett-ed set of tables of each dimension's coordinates
trans <- x %>% filtrate(lon = lon > 100 & lon < 340, lat = between(lat, 0, 50))
## extract the hyperslab index from the transform tables
hslab <- bind_rows(lapply(trans, function(x) tibble(name = x$name[1], start = min(x$step), count = length(x$step))))

## open the file and pull out that slab 
con <- ncdf4::nc_open(x$file$filename[1])
slab <- ncdf4::ncvar_get(con, nctive(x), 
                         start = hslab$start, 
                         count = hslab$count)


image(trans$lon$lon, trans$lat$lat, slab, col = viridis::viridis(100), asp = 1/cos(-40 * pi/180), xlim = c(0, 360))
map("world2", add = TRUE)



## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------

f <-  files$fullname[9]
print(gsub(getOption("default.datadir"), "", f))
## the idea is to find out what's the file
NetCDF(f) %>% dimension_values() %>% group_by(name) %>% summarize_at("vals", funs(min, max))
(x <- NetCDF(f) )

## then build up a query, returning a subsett-ed set of tables of each dimension's coordinates
trans <- x %>% filtrate(lon = lon > 300, lat = between(lat, 0, 50), time = time < 1770732)
## extract the hyperslab index from the transform tables
hslab <- bind_rows(lapply(trans, function(x) tibble(name = x$name[1], start = min(x$step), count = length(x$step))))

## open the file and pull out that slab 
con <- ncdf4::nc_open(x$file$filename[1])
slab <- ncdf4::ncvar_get(con, nctive(x), 
                         start = hslab$start, 
                         count = hslab$count)

for (i in seq(nrow(trans$time))) {
image(trans$lon$lon, rev(trans$lat$lat), slab[,ncol(slab):1,i], col = viridis::viridis(100), asp = 1/cos(-40 * pi/180))
map("world2", add = TRUE)
}


## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------
## ------------------------------------------------------------------------------

f <-  file.path(getOption("default.datadir"), "data_local/acecrc.org.au/ROMS/s_corney/cpolar/ocean_his_3101.nc")

(x <- NetCDF(f) %>% activate("salt"))
x %>% dimension_values() %>% group_by(name) %>% summarize_at("vals", funs(min, max))


## then build up a query, returning a subsett-ed set of tables of each dimension's coordinates
trans <- x %>% filtrate(eta_rho = eta_rho < 100, xi_rho = between(xi_rho, 500, 600), ocean_time = ocean_time < 9.465984e+08 + 12, s_rho = s_rho > -0.17741935)
## extract the hyperslab index from the transform tables
(hslab <- bind_rows(lapply(trans, function(x) tibble(name = x$name[1], start = min(x$step), count = length(x$step)))))

## open the file and pull out that slab 
con <- ncdf4::nc_open(x$file$filename[1])
slab <- ncdf4::ncvar_get(con, nctive(x), 
                         start = hslab$start, 
                         count = hslab$count)

## much more to think about ...
