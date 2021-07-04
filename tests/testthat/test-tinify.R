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
  expect_error(tinify(img), "TinyPNG can only handle")

})

test_that("Other arguments only accept correct input", {

  img <- system.file("extdata", "example.png", package = "tinieR")
  tmp <- tempfile(fileext = ".png")
  fs::file_copy(img, tmp)

  expect_error(tinify(tmp, overwrite = 123))
  expect_error(tinify(tmp, overwrite = factor("TRUE")))
  expect_error(tinify(tmp, overwrite = c("TRUE", "FALSE")))
  expect_error(tinify(tmp, overwrite = NULL))
  expect_error(tinify(tmp, overwrite = NA))
  expect_error(tinify(tmp, overwrite = "TRUE"))

  expect_error(tinify(tmp, quiet = 123))
  expect_error(tinify(tmp, quiet = factor("TRUE")))
  expect_error(tinify(tmp, quiet = c("TRUE", "FALSE")))
  expect_error(tinify(tmp, quiet = NULL))
  expect_error(tinify(tmp, quiet = NA))
  expect_error(tinify(tmp, quiet = "TRUE"))

  expect_error(tinify(tmp, return_path = 123))
  expect_error(tinify(tmp, return_path = TRUE))
  expect_error(tinify(tmp, return_path = factor("TRUE")))
  expect_error(tinify(tmp, return_path = c("TRUE", "FALSE")))
  expect_error(tinify(tmp, return_path = NA))
  expect_error(tinify(tmp, return_path = "TRUE"))

  expect_error(tinify(tmp, suffix = 123))
  expect_error(tinify(tmp, suffix = TRUE))
  expect_error(tinify(tmp, suffix = factor("TRUE")))
  expect_error(tinify(tmp, suffix = c("TRUE", "FALSE")))
  expect_error(tinify(tmp, suffix = NA))
  expect_error(tinify(tmp, suffix = list(one = "one", two = "two")))

  unlink(tmp)

})

test_that("Messages returns information correctly and can be suppressed with quiet", {

  img <- system.file("extdata", "example.png", package = "tinieR")
  tmp <- tempfile(fileext = ".png")
  fs::file_copy(img, tmp)

  expect_message(tinify(tmp), "Image tinified by")
  expect_message(tinify(tmp, quiet = TRUE), NA)

  unlink(tmp)

})

test_that("API error messages are displayed when API call unsuccessful", {

  fake_tmp <- tempfile(fileext = ".png")

  expect_error(tinify(fake_tmp))

})

test_that("Shrinking PNG and JPG files in place works", {

  img_png <- system.file("extdata", "example.png", package = "tinieR")
  tmp_png <- as.character(fs::path_abs(tempfile(fileext = ".png")))
  fs::file_copy(img_png, tmp_png, overwrite = TRUE)

  img_jpg <- system.file("extdata", "example.jpg", package = "tinieR")
  tmp_jpg <- as.character(fs::path_abs(tempfile(fileext = ".jpg")))
  fs::file_copy(img_jpg, tmp_jpg, overwrite = TRUE)

  expect_identical(tinify(tmp_png, overwrite = TRUE, return_path = "abs"), tmp_png)
  expect_identical(tinify(tmp_jpg, overwrite = TRUE, return_path = "abs"), tmp_jpg)

  expect_lt(as.numeric(fs::file_size(tmp_png)), as.numeric(fs::file_size(img_png)))
  expect_lt(as.numeric(fs::file_size(tmp_jpg)), as.numeric(fs::file_size(img_jpg)))

  expect_warning(tinify(tmp_jpg, overwrite = TRUE, suffix = "_small"))

  unlink(tmp_png)
  unlink(tmp_jpg)

})

test_that("Shrinking PNG and JPG files and creating as new file works", {

  img_png <- system.file("extdata", "example.png", package = "tinieR")
  tmp_png <- as.character(fs::path_abs(tempfile(fileext = ".png")))
  tmp_png2 <- as.character(fs::path_abs(tempfile(fileext = ".png")))
  fs::file_copy(img_png, tmp_png, overwrite = TRUE)
  fs::file_copy(img_png, tmp_png2, overwrite = TRUE)

  img_jpg <- system.file("extdata", "example.jpg", package = "tinieR")
  tmp_jpg <- as.character(fs::path_abs(tempfile(fileext = ".jpg")))
  tmp_jpg2 <- as.character(fs::path_abs(tempfile(fileext = ".jpg")))
  fs::file_copy(img_jpg, tmp_jpg, overwrite = TRUE)
  fs::file_copy(img_jpg, tmp_jpg2, overwrite = TRUE)

  tinify(tmp_png)
  tinify(tmp_jpg)

  expect_true(fs::file_exists(glue::glue("{fs::path_ext_remove(tmp_png)}_tiny.png")))
  expect_true(fs::file_exists(glue::glue("{fs::path_ext_remove(tmp_jpg)}_tiny.jpg")))

  suffix <- "_small"

  tinify(tmp_png2, suffix = suffix)
  tinify(tmp_jpg2, suffix = suffix)

  expect_true(fs::file_exists(glue::glue("{fs::path_ext_remove(tmp_png2)}_small.png")))
  expect_true(fs::file_exists(glue::glue("{fs::path_ext_remove(tmp_jpg2)}_small.jpg")))

  unlink(tmp_png)
  unlink(tmp_jpg)
  unlink(tmp_png2)
  unlink(tmp_jpg2)

})

test_that("Return_path argument returns correct paths", {

  img_png <- system.file("extdata", "example.png", package = "tinieR")
  tmp_png_1 <- as.character(fs::path_abs(tempfile(fileext = ".png")))
  tmp_png_2 <- as.character(fs::path_abs(tempfile(fileext = ".png")))
  tmp_png_3 <- as.character(fs::path_abs(tempfile(fileext = ".png")))
  tmp_png_4 <- as.character(fs::path_abs(tempfile(fileext = ".png")))
  fs::file_copy(img_png, tmp_png_1)
  fs::file_copy(img_png, tmp_png_2)
  fs::file_copy(img_png, tmp_png_3)
  fs::file_copy(img_png, tmp_png_4)


  path_1 <- tinify(tmp_png_1, overwrite = TRUE, return_path = "abs")
  path_2 <- tinify(tmp_png_2, overwrite = TRUE, return_path = "rel")
  path_3 <- tinify(tmp_png_3, overwrite = TRUE, return_path = "proj")
  path_list <- tinify(tmp_png_4, overwrite = TRUE, return_path = "all")

  expect_identical(tmp_png_1, path_1)
  expect_identical(tmp_png_2, path_2)
  expect_identical(NA, path_3)
  expect_identical(tmp_png_4, path_list$relative)
  expect_identical(NA, path_list$project)

  unlink(tmp_png_1)
  unlink(tmp_png_2)
  unlink(tmp_png_3)

})

test_that("Resize argument only accepts correct input", {

  img_png <- system.file("extdata", "example.png", package = "tinieR")
  tmp_png <- fs::path_abs(tempfile(fileext = ".png"))
  fs::file_copy(img_png, tmp_png, overwrite = TRUE)

  expect_error(tinify(tmp_png, resize = "fit"))
  expect_error(tinify(tmp_png, resize = TRUE))
  expect_error(tinify(tmp_png, resize = 123))
  expect_error(tinify(tmp_png, resize = NA))
  expect_error(tinify(tmp_png, resize = factor("one", "two")))
  expect_error(tinify(tmp_png, resize = c("one", "two")))

  expect_error(tinify(tmp_png, resize = list(method = "wrong", width = 300, height = 300)))
  expect_error(tinify(tmp_png, resize = list(method = "scale", width = 300, height = 300)))
  expect_error(tinify(tmp_png, resize = list(method = "fit", width = 300)))
  expect_error(tinify(tmp_png, resize = list(method = "scale", width = "300")))
  expect_error(tinify(tmp_png, resize = list(method = "fit", width = "300", height = 300)))
  expect_error(tinify(tmp_png, resize = list(method = "wrong")))
  expect_error(tinify(tmp_png, resize = list(method = "wrong", width = 300, height = 300, test = "broken")))
  expect_error(tinify(tmp_png, resize = list(method = "scale")))
  expect_error(tinify(tmp_png, resize = list(method = "wrong")))
  expect_error(tinify(tmp_png, resize = list(test = "wrong", width = 300, height = 300)))
  expect_error(tinify(tmp_png, resize = list(method = "cover", width = 300, height = TRUE)))
  expect_error(tinify(tmp_png, resize = list(method = "cover", width = 300)))
  expect_error(tinify(tmp_png, resize = list(method = "thumb", height = 300)))

  unlink(tmp_png)

})

test_that("Resizing PNG and JPG images works", {

  img_png <- system.file("extdata", "example.png", package = "tinieR")
  tmp_png <- as.character(fs::path_abs(tempfile(fileext = ".png")))
  fs::file_copy(img_png, tmp_png, overwrite = TRUE)

  img_jpg <- system.file("extdata", "example.jpg", package = "tinieR")
  tmp_jpg <- as.character(fs::path_abs(tempfile(fileext = ".jpg")))
  fs::file_copy(img_jpg, tmp_jpg, overwrite = TRUE)

  expect_message(tinify(tmp_png, resize = list(method = "scale", width = 300)), "and resized")
  expect_message(tinify(tmp_jpg, resize = list(method = "fit", width = 300, height = 150)), "and resized")

  #expect_true(fs::file_exists(glue::glue("{fs::path_ext_remove(tmp_png)}_tiny.png")))
  #expect_true(fs::file_exists(glue::glue("{fs::path_ext_remove(tmp_jpg)}_tiny.jpg")))

  unlink(tmp_png)
  unlink(tmp_jpg)

})
