context("Utility functions")

test_that("Unloading package removes all set options", {

  prev <- options()
  tinieR::.onUnload()

  expect_null(getOption("tinify.overwrite"))
  expect_null(getOption("tinify.suffix"))
  expect_null(getOption("tinify.quiet"))
  expect_null(getOption("tinify.return_path"))
  expect_null(getOption("tinify.resize"))

  on.exit(options(prev), add = TRUE, after = FALSE)

})
