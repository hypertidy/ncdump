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

nc_as_tibble <- function(x, varname) {
  ## all the file metadata
  nc <- ncdump::NetCDF(x)
  yes <- ok_var(nc, varname)
  if (!yes) stop(sprintf("varname %s not found, available variable names are:\n %s", varname, paste(nc$variable$name, collapse = ", ")))
  tibble::as_tibble(setNames(list(as.vector(ncdf4::ncvar_get(con, varname))), varname))
}

#' @importFrom dplyr %>% filter
nc_dimvals <- function(x, varname) {
  nc <- ncdump::NetCDF(x)
  yes <- ok_var(nc, varname)
  stopifnot(yes)
  dims <- nc$variable %>% dplyr::filter(name == varname) %>% 
    dplyr::select(id) %>% inner_join(nc$vardim) %>% arrange(dimids)
  all_dimvals <- dims %>% transmute(id = dimids) %>% inner_join(nc$dimvals, "id")
  len_dims <- dims %>% transmute(id = dimids) %>% inner_join(nc$dimension) %>% arrange(desc(id))
  
  
}
