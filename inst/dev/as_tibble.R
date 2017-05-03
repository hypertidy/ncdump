## here we want the table from a variable with all coordinate values
## WIP
ok_var <- function(x, varname, ...) UseMethod("ok_var")
ok_var.character <- function(x, varname, ...) {
  nc <- ncdump::NetCDF(x)
  ok_var(nc, varname)
}
ok_var.NetCDF <- function(x, varname, ...) {
  avail <- x$variable$name
  varname %in% avail
  
}

var_as_tibble <- function(x, varname) {
  ## all the file metadata
  nc <- ncdump::NetCDF(x)
  yes <- ok_var(nc, varname)
  if (!yes) stop(sprintf("varname %s not found, available variable names are:\n %s", varname, paste(nc$variable$name, collapse = ", ")))
  con <- ncdf4::nc_open(x)
  tibble::as_tibble(setNames(list(as.vector(ncdf4::ncvar_get(con, varname))), varname))
}



#' @importFrom tibble tibble as_tibble
#' @importFrom dplyr %>% filter
dimvals_as_tibble <- function(x, varname) {
  nc <- ncdump::NetCDF(x)
  yes <- ok_var(nc, varname)
  stopifnot(yes)
  dims <- nc$variable %>% dplyr::filter(name == varname) %>% 
    dplyr::select(id) %>% inner_join(nc$vardim) %>% arrange(dimids)
  all_dimvals <- dims %>% transmute(id = dimids) %>% inner_join(nc$dimvals %>% mutate(row_num = row_number()), "id") 
  ## we must filter on create_dimvar
  len_dims <- dims %>% transmute(id = dimids) %>% inner_join(nc$dimension %>% dplyr::filter(create_dimvar)) %>% arrange(desc(id))
print(len_dims)
 tib <- list()
 
 ## TODO: this is the wrong order, it must follow the order of NetCDF(file)$vardim  
  ## work through each dimension, with the right array logic for each
 total_prod <- prod(len_dims$len)
  prod_dims <- 1
  for (i in seq_len(nrow(len_dims))) {
    vd <- all_dimvals %>% filter(id == len_dims$id[i]) %>% arrange(row_num) %>% dplyr::select(vals)
    tib[[len_dims$name[i]]] <- rep(vd$vals, each = prod_dims, length.out = total_prod)
    prod_dims <- prod_dims * len_dims$len[i]
  }
  tib <- as_tibble(tib)
  tib
}

nc_as_tibble <- function(x, varname, ...) {
  dplyr::bind_cols(var_as_tibble(x, varname), dimvals_as_tibble(x, varname))
}


x <- raadtools::sstfiles()$fullname[1]
## OISST
nc_as_tibble(x, "sst") %>% ggplot() + aes(lon, lat, fill = sst) + geom_raster()
## OISST anom
nc_as_tibble(x, "anom") %>% 
  filter(between(lon, 130, 180), between(lat, -70, -30)) %>% 
  ggplot() + aes(lon, lat, fill = anom) + geom_raster()


x <- raadtools::currentsfiles()$fullname[1]
library(dplyr)
library(tibble)
## OISST anom
library(ggplot2)
nc_as_tibble(x, "u") %>% bind_cols(var_as_tibble(x, "v")) %>% 
  filter(between(lon, 130, 180), between(lat, -70, -30)) %>% 
  ggplot() + aes(lon, lat, fill = sqrt(u * u + v * v)) + geom_raster()


f <-  "/rdsi/PRIVATE/raad/data/ftp.cdc.noaa.gov/Datasets/ncep.reanalysis2.dailyavgs/gaussian_grid/runof.sfc.gauss.1997.nc"
a <- nc_as_tibble(f, "runof")
ggplot(a %>% filter(time == 1726872), aes(lon, lat, fill = runof)) + geom_raster()
