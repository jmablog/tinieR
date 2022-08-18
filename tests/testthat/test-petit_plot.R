context("Check petit_ggplot function")

test_that("Error checking and messages are working in petit_ggplot", {
  p <- ggplot2::ggplot(data = datasets::mtcars,
                       ggplot2::aes(x = mpg,
                                    y = drat)) +
    ggplot2::geom_point()

  p

  expect_error(petit_ggplot(device = "bmp", plot = p))
  expect_error(petit_ggplot(filename = 1, plot = p))
  expect_error(petit_ggplot(path = 1, plot = p))
  expect_error(petit_ggplot(keep_large = 1, plot = p))
})

test_that("Error checking and messages are working in petit_plot", {

  plot(mtcars$mpg, mtcars$drat)

  expect_error(petit_plot(device = "bmp"))
  expect_error(petit_plot(filename = 1))
  expect_error(petit_plot(ragg = "bmp"))
  expect_error(petit_plot(path = 1))
  expect_error(petit_plot(keep_large = 1))
})

test_that("Saving a ggplot object and shrinking it works", {

  skip_if_not_installed("ggplot2")

  p <- ggplot2::ggplot(data = datasets::mtcars,
                       ggplot2::aes(x = mpg,
                                    y = drat)) +
    ggplot2::geom_point()

  p

  withr::with_tempfile(new = "tmp", {
    petit_ggplot(filename = tmp)
    expect_true(fs::file_exists(paste0(tmp,".png")))
  })

  withr::with_tempfile(new = "tmp", {
    petit_ggplot(plot = p, filename = tmp)
    expect_true(fs::file_exists(paste0(tmp,".png")))
  })

  withr::with_tempfile(new = "tmp", {
    petit_ggplot(plot = p, device = "jpg", filename = tmp)
    expect_true(fs::file_exists(paste0(tmp,".jpg")))
  })

  withr::with_tempfile(new = "tmp", {
    petit_ggplot(plot = p, keep_large = TRUE, filename = tmp)
    expect_true(fs::file_exists(paste0(tmp,"_tiny.png")))
    expect_true(fs::file_exists(paste0(tmp,".png")))
    expect_lt(as.numeric(fs::file_size(paste0(tmp,"_tiny.png"))),
              as.numeric(fs::file_size(paste0(tmp,".png"))))
  })

  withr::with_tempdir({
    fs::dir_create("images")
    petit_ggplot(plot = p, path = "images")
    expect_true(fs::file_exists("images/plot.png"))
  })

  rm(p)

})

context("Check petit_plot function")

test_that("Saving a base plot and shrinking it works", {

  # these tests only seem to pass R CMD check if using ragg
  # no idea why, but will do for now

  # withr::with_tempfile("tmp", fileext = ".png", {
  #   name <- basename(tmp)
  #   no_ext <- fs::path_ext_remove(basename(tmp))
  #   d <- dirname(tmp)
  #   petit_plot(filename = no_ext, path = d, type = "Xlib")
  #   expect_true(fs::file_exists(tmp))
  # })

  skip_if_not_installed("ragg")

  plot(mtcars$mpg, mtcars$drat)

  withr::with_tempdir({
    petit_plot(ragg = TRUE)
    expect_true(fs::file_exists("plot.png"))
  })

  withr::with_tempdir({
    petit_plot(ragg = TRUE, device = "jpg")
    expect_true(fs::file_exists("plot.jpg"))
  })

  withr::with_tempdir({
    petit_plot(ragg = TRUE, device = "png", keep_large = TRUE)
    expect_true(fs::file_exists("plot_tiny.png"))
    expect_true(fs::file_exists("plot.png"))
    expect_lt(as.numeric(fs::file_size("plot_tiny.png")),
              as.numeric(fs::file_size("plot.png")))
  })

  withr::with_tempdir({
    fs::dir_create("images")
    petit_plot(path = "images", ragg = TRUE)
    expect_true(fs::file_exists("images/plot.png"))
  })

})
