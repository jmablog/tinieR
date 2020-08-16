context("Check API key submission")

test_that("Submitted API key is a string", {

  expect_error(tinify_key())
  expect_error(tinify_key(123))
  expect_error(tinify_key(factor("one")))
  expect_error(tinify_key(c("one", "two")))
  expect_error(tinify_key(TRUE))
  expect_error(tinify_key(NA))
  expect_error(tinify_key(NULL))

})

test_that("Renv variable is set", {

  prev <- Sys.getenv("TINY_API")
  tinify_key("my-key")
  expect_equal(Sys.getenv("TINY_API"), "my-key")
  on.exit(Sys.setenv(TINY_API = prev), add = TRUE, after = FALSE)

})
