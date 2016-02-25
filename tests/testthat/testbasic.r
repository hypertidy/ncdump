library(rancid)
context("Basic read")

ifile <- system.file("extdata", "S2008001.L3m_DAY_CHL_chlor_a_9km.nc", package = "rancid")
test_that("File exists and can be read", {
  expect_true(file.exists(ifile))
  expect_that(nc <- NetCDF(ifile), is_a("NetCDF"))
  expect_that(vars(nc), is_a("tbl_df"))
  expect_that(atts(nc), is_a("NetCDF_attributes"))
  expect_that(dims(nc), is_a("tbl_df"))
})
