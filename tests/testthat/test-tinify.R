context("Check tinify function")

test_that("API key is correctly provided", {

  img <- system.file("extdata", "example.png", package = "tinieR")
  tmp <- tempfile(fileext = ".png")
  fs::file_copy(img, tmp)

  prev <- Sys.getenv("TINY_API")
  tinify_key("wrong-key")

  expect_error(tinify(tmp, key = 123))
  expect_error(tinify(tmp, key = factor("one")))
  expect_error(tinify(tmp, key = c("one", "two")))
  expect_error(tinify(tmp, key = TRUE))
  expect_error(tinify(tmp, key = NA))
  expect_error(tinify(tmp, key = "wrong-key"))
  Sys.setenv(TINY_API = "")
  expect_error(tinify(tmp))

  on.exit(unlink(tmp), add = TRUE, after = FALSE)
  on.exit(Sys.setenv(TINY_API = prev), add = TRUE, after = FALSE)

})

test_that("Error if input file doesn't exist", {

  expect_error(tinify("doesnt-exist.png"), "does not exist")

})

test_that("Give error message if non-png or -jpg file used as input", {

  img <- system.file("extdata", "example.gif", package = "tinieR")
  expect_error(tinify(img), "TinyPNG can only handle .png or .jpg/.jpeg files")

})

test_that("Other arguments only accept TRUE or FALSE", {

  img <- system.file("extdata", "example.png", package = "tinieR")
  tmp <- tempfile(fileext = ".png")
  fs::file_copy(img, tmp)

  expect_error(tinify(tmp, overwrite = 123))
  expect_error(tinify(tmp, overwrite = factor("TRUE")))
  expect_error(tinify(tmp, overwrite = c("TRUE", "FALSE")))
  expect_error(tinify(tmp, overwrite = NULL))
  expect_error(tinify(tmp, overwrite = NA))
  expect_error(tinify(tmp, overwrite = "TRUE"))

  expect_error(tinify(tmp, return_path = 123))
  expect_error(tinify(tmp, return_path = factor("TRUE")))
  expect_error(tinify(tmp, return_path = c("TRUE", "FALSE")))
  expect_error(tinify(tmp, return_path = NULL))
  expect_error(tinify(tmp, return_path = NA))
  expect_error(tinify(tmp, return_path = "TRUE"))

  expect_error(tinify(tmp, details = 123))
  expect_error(tinify(tmp, details = factor("TRUE")))
  expect_error(tinify(tmp, details = c("TRUE", "FALSE")))
  expect_error(tinify(tmp, details = NULL))
  expect_error(tinify(tmp, details = NA))
  expect_error(tinify(tmp, details = "TRUE"))

  unlink(tmp)

})

test_that("Details returns information", {

  img <- system.file("extdata", "example.png", package = "tinieR")
  tmp <- tempfile(fileext = ".png")
  fs::file_copy(img, tmp)

  expect_message(tinify(tmp, details = TRUE), "Filesize reduced by")

  unlink(tmp)

})

test_that("API error messages are displayed when API call unsuccessful", {

  fake_tmp <- tempfile(fileext = ".png")

  expect_error(tinify(fake_tmp))

})

test_that("Shrinking PNG and JPG files in place works", {

  img_png <- system.file("extdata", "example.png", package = "tinieR")
  tmp_png <- as.character(fs::path_abs(tempfile(fileext = ".png")))
  fs::file_copy(img_png, tmp_png)

  img_jpg <- system.file("extdata", "example.jpg", package = "tinieR")
  tmp_jpg <- as.character(fs::path_abs(tempfile(fileext = ".jpg")))
  fs::file_copy(img_jpg, tmp_jpg)

  expect_identical(tinify(tmp_png, overwrite = TRUE, return_path = TRUE), tmp_png)
  expect_identical(tinify(tmp_jpg, overwrite = TRUE, return_path = TRUE), tmp_jpg)

  expect_lt(as.numeric(fs::file_size(tmp_png)), as.numeric(fs::file_size(img_png)))
  expect_lt(as.numeric(fs::file_size(tmp_jpg)), as.numeric(fs::file_size(img_jpg)))

  unlink(tmp_png)
  unlink(tmp_jpg)

})

test_that("Shrinking PNG and JPG files and creating as new file works", {

  img_png <- system.file("extdata", "example.png", package = "tinieR")
  tmp_png <- fs::path_abs(tempfile(fileext = ".png"))
  fs::file_copy(img_png, tmp_png)

  img_jpg <- system.file("extdata", "example.jpg", package = "tinieR")
  tmp_jpg <- fs::path_abs(tempfile(fileext = ".jpg"))
  fs::file_copy(img_jpg, tmp_jpg)

  tinify(tmp_png)
  tinify(tmp_jpg)

  expect_true(fs::file_exists(glue::glue("{fs::path_ext_remove(tmp_png)}_tiny.png")))
  expect_true(fs::file_exists(glue::glue("{fs::path_ext_remove(tmp_jpg)}_tiny.jpg")))

  unlink(tmp_png)
  unlink(tmp_jpg)

})
