.onLoad <- function(libname, pkgname) {

  tryCatch({
  tinify_yml <- rprojroot::find_rstudio_root_file("tinify.yml")

  if(file.exists(tinify_yml)) {
      yml_ops <- yaml::read_yaml(tinify_yml)
      names(yml_ops) <- paste0("tinify.", names(yml_ops))

      ops <- options()
      toset <- !(names(yml_ops) %in% names(ops))
      if(any(toset)) {
        options(yml_ops[toset])
      }
      invisible()
    }
  },
  error = function(err) {
    invisible()
  })

}

.onUnload <- function(libname, pkgname) {
  options(list(tinify.overwrite = NULL,
               tinify.suffix = NULL,
               tinify.quiet = NULL,
               tinify.return_path = NULL,
               tinify.resize = NULL))

  invisible()
}

#' Checking function for common argument options setting/getting
#' @noRd
#' @keywords internal
.tinify_getset_opts <- function(overwrite,
                                suffix,
                                quiet,
                                return_path,
                                resize) {

  opts = list()

  if(missing(overwrite)) {
    opts$overwrite <- getOption("tinify.overwrite", default = FALSE)
  } else {
    opts$overwrite <- overwrite
  }

  if(missing(suffix)) {
    opts$suffix <- getOption("tinify.suffix", default = "_tiny")
  } else {
    opts$suffix <- suffix
  }

  if(missing(quiet)) {
    opts$quiet <- getOption("tinify.quiet", default = FALSE)
  } else {
    opts$quiet <- quiet
  }

  if(missing(return_path)) {
    opts$return_path <- getOption("tinify.return_path", default = NULL)
  } else {
    opts$return_path <- return_path
  }

  if(missing(resize)) {
    opts$resize <- getOption("tinify.resize", default = NULL)
  } else {
    opts$resize <- resize
  }

  return(opts)

}

#' Error checking function for common argument error checks
#' @noRd
#' @keywords internal
.tinify_error_check <- function(overwrite,
                                suffix,
                                quiet,
                                return_path,
                                resize) {

  # Check overwrite argument and set new file path as requested
  # Either overwriting original file completely or appending suffix to
  # new filename
  if(identical(overwrite, TRUE)) {
    if(suffix != "_tiny") {
      cli::cli_warn("{.field suffix} is ignored when {.field overwrite} is {.code TRUE}")
    }
  } else if(identical(overwrite, FALSE)) {
    if(is.null(suffix)) {
      cli::cli_abort("Please provide {.field suffix} as a non-empty character string when {.field overwrite} is {.code FALSE}")
    } else if(length(suffix) != 1) {
      cli::cli_abort("Please provide {.field suffix} as a non-empty character string when {.field overwrite} is {.code FALSE}")
    } else if(!is.character(suffix) | suffix == "") {
      cli::cli_abort("Please provide {.field suffix} as a non-empty character string when {.field overwrite} is {.code FALSE}")
    }
  } else {
    cli::cli_abort("Please only provide {.field overwrite} as {.code TRUE} or {.code FALSE}")
  }

  # Check resize list is provided with appropriate arguments
  if(!is.null(resize)) {

    # Check resize is a list of min length 2 and max length 3
    if(!is.list(resize) | length(resize) < 2 | length(resize) > 3){
      cli::cli_abort("Resize must be a list that includes a {.field method} and one or both of {.field width} or {.field height}")
    }

    # Check 'method' and at least one of 'width' or 'height' are named in resize
    if(!("method" %in% names(resize) & ("width" %in% names(resize) | "height" %in% names(resize)))) {
      cli::cli_abort("Resize must be a list that includes a {.field method} and one or both of {.field width} or {.field height}")
    }

    # Check resize method is a string specifying one of the available options
    if(!(resize$method %in% c("fit", "scale", "cover", "thumb"))) {
      cli::cli_abort('Method must be one of {.field fit}, {.field scale}, {.field cover} or {.field thumb}')
    }

    # Check width and/or height are numbers
    if("width" %in% names(resize) & !is.numeric(resize$width) | "height" %in% names(resize) & !is.numeric(resize$height)) {
      cli::cli_abort("{.field Width} and/or {.field height} must be a number")
    }

    # Check only one of width or height provided for method 'scale'
    if(identical(resize$method, "scale") & "width" %in% names(resize) & "height" %in% names(resize)) {
      cli::cli_abort("You must provide a {.field width} OR {.field height} for method {.field scale}, not both")
    }

    # Check both width and height provided for other methods besides 'scale'
    if(!identical(resize$method, "scale") & (!("width" %in% names(resize)) | !("height" %in% names(resize)))) {
      cli::cli_abort("You must provide a {.field width} AND {.field height} for method {.field {resize$method}}")
    }

  }

  # Check details argument correctly provided
  if(!identical(quiet, TRUE) & !identical(quiet, FALSE)) {
    cli::cli_abort("Please only provide {.field quiet} as {.code TRUE} or {.code FALSE}")
  }

  # Check return_path argument correctly provided
  if(!is.null(return_path)) {
    if(length(return_path) > 1 || !(return_path %in% c("proj", "rel", "abs", "all"))){
      cli::cli_abort('Please only provide return_path as {.field "proj"}, {.field "rel"}, {.field "abs"}, or {.field "all"}')
    }
  }

}
