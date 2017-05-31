## NetCDF is the thing

## we 

## NOMINATE the entity
NetCDF(f) %>% nominate(variables) ## %>% do sets of variablesy things
NetCDF(f) %>% nominate(dimensions) ## %>% do dimensiony subsettting things
NetCDF(f) %>% nominate(attributes) ## do metadata things

## ACTIVATE the variable (?)
NetCDF(f) %>% activate(sst)
## hyper_filter gives "hyperfilter",  processes user name = name-expr elements for any dimensions

## hyper_index gives a "hyperindex", the index of start, count, name

## hyper_slice gives a raw slab array, applies the hyperindex to a file-variable with ncvar_get

## hyper_tibble does all the above and gives a data frame

file <- file.path(getOption("default.datadir"), 
                  "data/ftp.cdc.noaa.gov/Datasets/ncep.reanalysis2/gaussian_grid/uwnd.10m.gauss.2002.nc")
library(dplyr)
NetCDF(file) %>% activate(uwnd) %>% 
  hyper_filter()

NetCDF(file) %>% activate(uwnd) %>% 
  hyper_filter() %>% hyper_index()

NetCDF(file) %>% activate(uwnd) %>% 
  hyper_filter(lon = lon > 300, time = time < 1771000  )


## we can pass this on the the hyper_index generator
hf <- NetCDF(file) %>% activate(uwnd) %>% 
  hyper_filter(lon = lon > 300, time = time < 1771000  )

hf %>% hyper_index()

hf %>% hyper_slice()

## or we can use it directly anyway
NetCDF(file) %>% activate(uwnd) %>% 
  hyper_index(lat = lat > 80,  lon = lon > 300, time = time < 1771000  )

NetCDF(file) %>% activate(uwnd) %>% 
  hyper_slice(lat = lat > 80,  lon = lon > 300, time = time < 1771000  )


hf %>% hyper_index() %>% hyper_slice() 

## or we can use it directly anyway
NetCDF(file) %>% activate(uwnd) %>% 
  hyper_slice(lat = lat > 80,  lon = lon > 300, time = time < 1771000  )  %>% str()

library(ggplot2)
NetCDF(file) %>% hyper_filter()


d <- NetCDF(file) %>% hyper_tibble(lon = between(lon, 100, 180),
                                   lat = between(lat, -50, -10), 
                                   time = index(time) < 11, 
                                   level = level == 10) 
  ggplot(d, aes(lon, lat, fill = uwnd)) + 
  geom_raster() + facet_wrap(~time)
  
  
  
file <- 
  d <- NetCDF(file) %>% hyper_tibble(lon = between(lon, 100, 180),
                                     lat = between(lat, -50, -10), 
                                     time = time == 1779450) 
  ggplot(d, aes(lon, lat, fill = uwnd)) + 
    geom_raster() + facet_wrap(~level)
  
  
d1 <- NetCDF(f) %>% activate(temp) %>%
  hyper_tibble(xi_rho = xi_rho < 2 , ocean_time = ocean_time < 947376000)

ggplot(d, aes(eta_rho, s_rho, fill = temp)) +geom_raster()


(d <- NetCDF(f) %>% activate(temp) %>% hyper_tibble(xi_rho = xi_rho > 1000, s_rho = s_rho < -0.951618, ocean_time = ocean_time < 947376000))
ggplot(d, aes(xi_rho, eta_rho, fill = temp)) +
geom_raster() + facet_wrap(~ocean_time)

