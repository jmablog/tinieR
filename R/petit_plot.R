#' @title Save a plot to a file and automatically shrink it
#'
#' @description Save a plot to a file and automatically shrink it with `tinify()`.
#'
#' @details These are convenience functions to wrap saving either a base R plot with
#'   `png()` or `jpeg()` devices, or a [ggplot](https://ggplot2.tidyverse.org) object with `ggplot2::ggsave()`, before passing the resulting
#'   image file directly to `tinify()`.  Can also make use of the [ragg](https://ragg.r-lib.org)
#'   package for base plots if installed.
#'
#' @section Using with base R plots: To save and shrink a base R plot, print the plot and call
#'   `petit_plot()` immediately after. Under the hood, this uses `recordPlot()` to capture
#'   and replay the last plot created within the chosen device with the applied options:
#'
#'   ```
#'   plot(mtcars$mpg, mtcars$drat)
#'
#'   petit_plot(filename = "mtcars")
#'   ```
#'
#' @section Using with ggplot: To save and shrink a [ggplot](https://ggplot2.tidyverse.org), either create, modify, or show
#'   the plot and call `petit_plot()` immediately after, in a similar process to base R plots:
#'
#'   ```
#'   ggplot(data = palmerpenguins::penguins,
#'          aes(flipper_length_mm, body_mass_g)) +
#'   geom_point(aes(color = species))
#'
#'   petit_plot(filename = "penguins")
#'   ```
#'
#'   Or use `petit_ggplot()` to capture specifically the last ggplot created or modified:
#'
#'   ```
#'   ggplot(data = palmerpenguins::penguins,
#'          aes(flipper_length_mm, body_mass_g)) +
#'   geom_point(aes(color = species))
#'
#'   petit_ggplot(filename = "penguins")
#'   ```
#'
#'   Or provide the plot object explicitly to `petit_ggplot()` with `plot`:
#'
#'   ```
#'   p <- ggplot(data = palmerpenguins::penguins,
#'               aes(flipper_length_mm, body_mass_g)) +
#'        geom_point(aes(color = species))
#'
#'   petit_ggplot(filename = "penguins", plot = p)
#'   ```
#'
#' @param filename String, required. The name to give the output image file. Do
#'   not include a file extension.
#' @param path String, optional. If `NULL`, defaults to the current working directory. The
#'   path to save the image file into, relative to the current working directly. Do not include
#'   the final trailing path separator.
#' @param device String, optional. Defaults to `"png"`. One of `"png"` or `"jpg"`,
#'   to choose the output image file type. TinyPNG only supports `png` or `jpg` image types.
#' @param plot Object, optional. The plot object to export. Defaults to the last plot
#'   modified or created (using `ggplot2::last_plot()`) if not provided.
#' @param ragg Boolean, optional. Defaults to `FALSE`. Whether to use the [ragg](https://ragg.r-lib.org)
#'   package as the device backend to generate the image. Will error if [ragg](https://ragg.r-lib.org) is
#'   not installed, but does not need to be loaded.
#' @param keep_large Boolean, optional. Defaults to `FALSE`. Whether to keep the
#'   unshrunk original image file alongside the tiny version, or just keep the
#'   shrunk file.
#' @param suffix String, optional. If `keep_large` is `TRUE`, the suffix to add
#'   to the shrunk file. Ignored if `keep_large` is `FALSE`.
#' @param quiet Boolean, optional. If set to `TRUE`, `tinify()` displays no
#'  information messages as it shrinks files.
#' @param return_path String or `NULL`, optional. One of "`proj`", "`rel`", "`abs`", or
#'  "`all`". If "`proj`", will return the file path of the newly tinified image
#'  file relative to the Rstudio project directory (looking for an .Rproj file).
#'  If no project can be identified, returns `NA`. If "`rel`", will return the
#'  file path of the newly tinified image file, relative to the \strong{current}
#'  working directory at the time `tinify()` is called. If "`abs`", will return
#'  the absolute file path of the newly tinified image file. If "`all`", will
#'  return a named list with all file paths. If `NULL` (the default), no file
#'  path is returned.
#' @param key String, optional. A string containing your TinyPNG API key. Not
#'  required if the API key is set using `tinify_api()`. Any other key provided
#'  as an argument will override the key set by `tinify_api()`.
#' @param ... Additional plot options, passed directly to either `png()`/`ragg::agg_png()`,
#'   `jpeg()`/`ragg::agg_jpeg()`, or `ggplot2::ggsave()` depending on method used.
#'
#' @return If `return_path = "proj"`, `return_path = "rel"`, or `return_path =
#'  "abs"`, a string with the project, relative, or absolute path to the newly
#'  tinified image file. If no project can be identified for `return_path =
#'  "proj"`, returns `NA`. If `return_path = "all"`, a named list with all file
#'  paths included as `$project`, `$relative`, and `$absolute` respectively. If
#'  `return_path = NULL`, no return value.
#'
#' @seealso [tinify()]
#' @seealso [tinify_key()] to set an API key globally
#' @seealso [tinify_defaults()] to set default arguments that will be used if not
#'  provided explicitly
#'
#' @export

petit_plot <- function(filename = "plot",
                       path = NULL,
                       device = "png",
                       ragg = FALSE,
                       keep_large = FALSE,
                       suffix,
                       quiet,
                       return_path,
                       key = NULL,
                       ...) {
  # Error checks ==============================================================

  # check file name and path arguments are characters
  if(!is.character(filename)) {
    cli::cli_abort("Make sure {.field filename} is a string")
  }
  if(!is.null(path) & !is.character(path)) {
    cli::cli_abort("Make sure {.field path} is a string or {.code NULL}")
  }

  # Check file extension and reject anything not png or jpg
  if(!(identical(device, "png") | identical(device, "jpg"))) {
    cli::cli_abort("TinyPNG can only handle {.file png} or {.file jpg} files, please only provide one of these options in the {.field device} argument")
  }

  # check boolean for keep_large and ragg arguments
  if(!(identical(keep_large, TRUE) | identical(keep_large, FALSE))) {
    cli::cli_abort("{.field keep_large} should only be {.code TRUE} or {.code FALSE}")
  }
  if(!(identical(ragg, TRUE) | identical(ragg, FALSE))) {
    cli::cli_abort("{.field ragg} should only be {.code TRUE} or {.code FALSE}")
  }

  # check for ragg library if option chosen
  if((identical(ragg, TRUE) & !requireNamespace("ragg", quietly = TRUE))) {
    ragg = FALSE
    cli::cli_warn("{.pkg ragg} library not found, falling back to base devices...")
  }

  # check API key
  key <- .tinify_key_check(key)

  # fill in any tinify arguments not provided with defaults
  tinify_opts <- .tinify_getset_opts(overwrite = !keep_large,
                                     suffix,
                                     quiet,
                                     return_path,
                                     resize = NULL)

  # and then check those against common errors
  .tinify_error_check(overwrite = tinify_opts$overwrite,
                      suffix = tinify_opts$suffix,
                      quiet = tinify_opts$quiet,
                      return_path = tinify_opts$return_path,
                      resize = tinify_opts$resize)
  # ===========================================================================

  # create full output file name from filename, device, and path
  if (!is.null(path)) {
    out <- file.path(path, paste0(filename, ".", device))
  } else {
    out <- file.path(paste0(filename, ".", device))
  }

  cli::cli_status("{cli::symbol$tick} Exporting plot...")
  Sys.sleep(0.5)

  # save last plot printed to an object
  current_plot <- grDevices::recordPlot()

  # and then print that plot to the chosen device
  if(ragg) {
    if (identical(device, "png")) {
      ragg::agg_png(filename = out,
          ...)
    } else if (identical(device, "jpg")) {
      ragg::agg_jpeg(filename = out,
           ...)
    }
  } else {
    if (identical(device, "png")) {
      grDevices::png(filename = out,
          ...)
    } else if (identical(device, "jpg")) {
      grDevices::jpeg(filename = out,
           ...)
    }
  }
  grDevices::replayPlot(current_plot)
  grDevices::dev.off()

  # pass created plot file through tinify function
  tinify(file = out,
         overwrite = tinify_opts$overwrite,
         suffix = tinify_opts$suffix,
         quiet = tinify_opts$quiet,
         return_path = tinify_opts$return_path,
         resize = tinify_opts$resize,
         key = key)

}

#' @rdname petit_plot
#' @export

petit_ggplot <- function(filename = "plot",
                         path = NULL,
                         plot = ggplot2::last_plot(),
                         device = "png",
                         keep_large = FALSE,
                         suffix,
                         quiet,
                         return_path,
                         key = NULL,
                         ...) {

  # Error checks ==============================================================
  # check ggplot2 present before anything else
  if(!requireNamespace("ggplot2", quietly = TRUE)) {
    cli::cli_abort("{.pkg ggplot2} library not found")
  }

  if(!is.character(filename)) {
    cli::cli_abort("Make sure {.field filename} is a string")
  }
  if(!is.null(path) & !is.character(path)) {
    cli::cli_abort("Make sure {.field path} is a string or {.code NULL}")
  }

  # check API key
  key <- .tinify_key_check(key)

  # Check file extension and reject anything not png or jpg
  if(!(identical(device, "png") | identical(device, "jpg"))) {
    cli::cli_abort("TinyPNG can only handle {.file png} or {.file jpg} files, please only choose one of these options in the {.field device} argument")
  }

  # check boolean for keep_large argument
  if(!(identical(keep_large, TRUE) | identical(keep_large, FALSE))) {
    cli::cli_abort("{.field keep_large} should only be {.code TRUE} or {.code FALSE}")
  }

  # fill in any tinify args not provided with defaults
  tinify_opts <- .tinify_getset_opts(overwrite = !keep_large,
                                     suffix,
                                     quiet,
                                     return_path,
                                     resize = NULL)

  # and then check those against common errors
  .tinify_error_check(overwrite = tinify_opts$overwrite,
                      suffix = tinify_opts$suffix,
                      quiet = tinify_opts$quiet,
                      return_path = tinify_opts$return_path,
                      resize = tinify_opts$resize)
  # ===========================================================================

  # create final output file name based on file name given and device
  out <- paste0(filename, ".", device)

  # save plot object using ggsave
  cli::cli_status("{cli::symbol$tick} Exporting plot...")
  Sys.sleep(0.5)

  suppressMessages(
    ggplot2::ggsave(out,
                    path = path,
                    plot = plot,
                    device = device,
                    ...)
  )

  if (!is.null(path)) {
    out <- file.path(path, out)
  }

  # pass created plot file through tinify function
  tinify(file = out,
         overwrite = tinify_opts$overwrite,
         suffix = tinify_opts$suffix,
         quiet = tinify_opts$quiet,
         return_path = tinify_opts$return_path,
         resize = tinify_opts$resize,
         key = key)

}
