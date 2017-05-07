library(ncdump)
library(testthat)
context("Basic read")

ifile <- system.file("extdata", "S2008001.L3m_DAY_CHL_chlor_a_9km.nc", package = "ncdump")
con <- NetCDF(ifile)
test_that("File exists and can be read", {
  expect_true(file.exists(ifile))
  expect_that(con, is_a("NetCDF"))
  expect_that(vars(con), is_a("tbl_df"))
  expect_that(atts(con), is_a("tbl_df"))
  expect_that(dims(con), is_a("tbl_df"))
})


context("Differentiate attributes global and var-based")
test_that("get global attributes", {
  expect_that(atts(con), is_a("tbl_df"))
  ## something changed here, need to explore 
  #expect_that(atts(con, "chlor_a"), is_a("tbl_df"))
  expect_that(dimvars(con), is_a("tbl_df"))
})


test_that("internal functions works", {
  ncatts(ifile) %>% expect_named(c("global", "var", "childvar"))
  vars(con) %>% expect_s3_class("tbl_df") %>% expect_length(19) %>% expect_named(c("name", "ndims", "natts", "prec", "units", "longname", "group_index", 
                                                                                   "storage", "shuffle", "compression", "unlim", "make_missing_value", 
                                                                                   "missval", "hasAddOffset", "addOffset", "hasScaleFact", "scaleFact", 
                                                                                   ".variable_", ".group_"))
  dims(con)  %>% expect_s3_class("tbl_df") %>% expect_length(9)  %>% expect_named(c("name", "len", "unlim", "group_index", "group_id", "id", "create_dimvar", 
                                ".dimension_", ".group_"))
}
          
          )
