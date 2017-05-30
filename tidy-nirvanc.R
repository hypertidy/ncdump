## NetCDF is the thing

## we 

## NOMINATE the entity
NetCDF(f) %>% nominate(variables) ## %>% do sets of variablesy things
NetCDF(f) %>% nominate(dimensions) ## %>% do dimensiony subsettting things
NetCDF(f) %>% nominate(attributes) ## do metadata things

## ACTIVATE the variable (?)
NetCDF(f) %>% activate(sst)
## filtrate  (hyper_filter?) processes user name = name-expr elements for any dimensions

## hyper_index gives a hyperslab, the index of start, count, name

## hyper_slice applies the hyperslab to a file-variable

## hyper_tibble does all the above and gives a data frame

file <- file.path(getOption("default.datadir"), 
                  "data/ftp.cdc.noaa.gov/Datasets/ncep.reanalysis2/gaussian_grid/uwnd.10m.gauss.2002.nc")

NetCDF(file) %>% activate(uwnd) %>% 
  hyper_filter()


NetCDF(file) %>% activate(uwnd) %>% 
  hyper_filter(lon = lon > 300, time = time < 1771000  )


## we can pass this on the the hyper_index generator
hf <- NetCDF(file) %>% activate(uwnd) %>% 
  hyper_filter(lon = lon > 300, time = time < 1771000  )

hf %>% hyper_index()

## or we can use it directly anyway
NetCDF(file) %>% activate(uwnd) %>% 
  hyper_index(lat = lat > 80,  lon = lon > 300, time = time < 1771000  )


hf %>% hyper_index() %>% hyper_slice() %>% str()

## or we can use it directly anyway
NetCDF(file) %>% activate(uwnd) %>% 
  hyper_slice(lat = lat > 80,  lon = lon > 300, time = time < 1771000  )  %>% str()

hyper_tibble <- function(x, ...) {
  UseMethod("hyper_tibble")
}

hyper_tibble.NetCDF <- function(x, ...) {
  x %>% hyper_filter(...) %>% hyper_tibble()
}

hyper_tibble.hyperfilter <- function(x, ...) {
  slab <- hyper_slice(x, ...)
  tib <- list()
  tib[[activ]] <- as.vector(slab)
  tib <- as_tibble(tib)
  prod_dims <- 1
  total_prod <- prod(dim(slab))
  
  trans <- x #??
  for (i in seq_along(trans)) {
    nm <- names(trans)[i]
    nr <- nrow(trans[[i]])
    tib[[nm]] <- rep(trans[[nm]][[nm]], each = prod_dims, length.out = total_prod)
    prod_dims <- prod_dims * nr
  }
  tib
  
}