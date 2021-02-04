context("Check tinify defaults are correctly set")

test_that("Throws error if no arguments provided at all", {

  expect_error(tinify_defaults())

})

test_that("Overwrite is a boolean", {

  expect_error(tinify_defaults(overwrite = 123))
  expect_error(tinify_defaults(overwrite = "123"))
  expect_error(tinify_defaults(overwrite = factor("one")))
  expect_error(tinify_defaults(overwrite = c("one", "two")))
  expect_error(tinify_defaults(overwrite = NA))
  expect_error(tinify_defaults(overwrite = list(one = "one", two = "two")))
  expect_error(tinify_defaults(overwrite = data.frame(one = "one", two = "two")))

  prev <- getOption("tinify_overwrite")

  tinify_defaults(overwrite = TRUE)
  expect_equal(TRUE, getOption("tinify_overwrite"))
  tinify_defaults(overwrite = FALSE)
  expect_equal(FALSE, getOption("tinify_overwrite"))
  tinify_defaults(overwrite = NULL)
  expect_equal(NULL, getOption("tinify_overwrite"))

  on.exit(options(tinify_overwrite = prev), add = TRUE, after = FALSE)

})

test_that("Suffix is a string of length 1", {

  expect_error(tinify_defaults(suffix = 123))
  expect_error(tinify_defaults(suffix = TRUE))
  expect_error(tinify_defaults(suffix = factor("one")))
  expect_error(tinify_defaults(suffix = c("one", "two")))
  expect_error(tinify_defaults(suffix = NA))
  expect_error(tinify_defaults(suffix = list(one = "one", two = "two")))
  expect_error(tinify_defaults(suffix = data.frame(one = "one", two = "two")))

  prev <- getOption("tinify_suffix")

  tinify_defaults(suffix = "_small")
  expect_equal("_small", getOption("tinify_suffix"))
  tinify_defaults(suffix = NULL)
  expect_equal(NULL, getOption("tinify_suffix"))

  on.exit(options(tinify_suffix = prev), add = TRUE, after = FALSE)

})

test_that("Quiet is a boolean", {

  expect_error(tinify_defaults(quiet = 123))
  expect_error(tinify_defaults(quiet = "123"))
  expect_error(tinify_defaults(quiet = factor("one")))
  expect_error(tinify_defaults(quiet = c("one", "two")))
  expect_error(tinify_defaults(quiet = NA))
  expect_error(tinify_defaults(quiet = list(one = "one", two = "two")))
  expect_error(tinify_defaults(quiet = data.frame(one = "one", two = "two")))

  prev <- getOption("tinify_quiet")

  tinify_defaults(quiet = TRUE)
  expect_equal(TRUE, getOption("tinify_quiet"))
  tinify_defaults(quiet = FALSE)
  expect_equal(FALSE, getOption("tinify_quiet"))
  tinify_defaults(quiet = NULL)
  expect_equal(NULL, getOption("tinify_quiet"))

  on.exit(options(tinify_quiet= prev), add = TRUE, after = FALSE)

})

test_that("Return path is a string of length 1", {

  expect_error(tinify_defaults(return_path = 123))
  expect_error(tinify_defaults(return_path = TRUE))
  expect_error(tinify_defaults(return_path = factor("one")))
  expect_error(tinify_defaults(return_path = c("one", "two")))
  expect_error(tinify_defaults(return_path = NA))
  expect_error(tinify_defaults(return_path = list(one = "one", two = "two")))
  expect_error(tinify_defaults(return_path = data.frame(one = "one", two = "two")))

  prev <- getOption("tinify_return_path")

  tinify_defaults(return_path = "rel")
  expect_equal("rel", getOption("tinify_return_path"))
  tinify_defaults(return_path = "abs")
  expect_equal("abs", getOption("tinify_return_path"))
  tinify_defaults(return_path = "proj")
  expect_equal("proj", getOption("tinify_return_path"))
  tinify_defaults(return_path = "all")
  expect_equal("all", getOption("tinify_return_path"))
  tinify_defaults(return_path = NULL)
  expect_equal(NULL, getOption("tinify_return_path"))

  on.exit(options(tinify_return_path = prev), add = TRUE, after = FALSE)

})

test_that("Resize is a list of correct arguments", {

  expect_error(tinify_defaults(resize = "fit"))
  expect_error(tinify_defaults(resize = TRUE))
  expect_error(tinify_defaults(resize = 123))
  expect_error(tinify_defaults(resize = NA))
  expect_error(tinify_defaults(resize = factor("one", "two")))
  expect_error(tinify_defaults(resize = c("one", "two")))

  expect_error(tinify_defaults(resize = list(method = "wrong", width = 300, height = 300)))
  expect_error(tinify_defaults(resize = list(method = "scale", width = 300, height = 300)))
  expect_error(tinify_defaults(resize = list(method = "fit", width = 300)))
  expect_error(tinify_defaults(resize = list(method = "scale", width = "300")))
  expect_error(tinify_defaults(resize = list(method = "fit", width = "300", height = 300)))
  expect_error(tinify_defaults(resize = list(method = "wrong")))
  expect_error(tinify_defaults(resize = list(method = "wrong", width = 300, height = 300, test = "broken")))
  expect_error(tinify_defaults(resize = list(method = "scale")))
  expect_error(tinify_defaults(resize = list(method = "wrong")))
  expect_error(tinify_defaults(resize = list(test = "wrong", width = 300, height = 300)))
  expect_error(tinify_defaults(resize = list(method = "cover", width = 300, height = TRUE)))
  expect_error(tinify_defaults(resize = list(method = "cover", width = 300)))
  expect_error(tinify_defaults(resize = list(method = "thumb", height = 300)))

  prev <- getOption("tinify_resize")

  tinify_defaults(resize = list(method = "scale", width = 300))
  expect_equal(list(method = "scale", width = 300), getOption("tinify_resize"))
  tinify_defaults(resize = list(method = "cover", width = 300, height = 150))
  expect_equal(list(method = "cover", width = 300, height = 150), getOption("tinify_resize"))
  tinify_defaults(resize = NULL)
  expect_equal(NULL, getOption("tinify_resize"))

  on.exit(options(tinify_resize= prev), add = TRUE, after = FALSE)

})
