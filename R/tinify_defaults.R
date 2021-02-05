#'Set defaults for `tinify()` function
#'
#'@description Set some default options for `tinify()` in the global environment, so it is no
#'longer necessary to explicitly provide each argument with every call of
#'`tinify()`.
#'
#'If called without any arguments, `tinify_defaults()` will print
#'the current default options set to the console.
#'
#'To set any option back to the package default, set it to `NULL`.
#'
#'@param overwrite Boolean, defaults to `FALSE`. By default, tinify will create
#'  a new file with the suffix '_tiny' and preserve the original file. Set
#'  `TRUE` to instead overwrite the original file, with the same file name.
#'@param suffix String, defaults to `"_tiny"`. By default, tinify will create a
#'  new file with the suffix '_tiny' and preserve the original file. Provide a
#'  new character string here to change the suffix from '_tiny' to your own
#'  choice. Empty strings (`""`) are not accepted. `suffix` is ignored when
#'  `overwrite` is set to `TRUE`.
#'@param quiet Boolean, defaults to `FALSE`. By default, tinify provides details
#'  on file names, amount of file size reduction (% and Kb), and the number of
#'  TinyPNG API calls made this month. If set to `TRUE`, tinify displays no
#'  messages as it shrinks files.
#'@param return_path String, optional. One of "`proj`", "`rel`", "`abs`", or
#'  "`all`". If "`proj`", will return the file path of the newly tinified image
#'  file relative to the Rstudio project directory (looking for an .Rproj file).
#'  If no project can be identified, returns `NA`. If "`rel`", will return the
#'  file path of the newly tinified image file, relative to the \strong{current}
#'  working directory at the time `tinify()` is called. If "`abs`", will return
#'  the absolute file path of the newly tinified image file. If "`all`", will
#'  return a named list with all file paths.
#'@param resize Named list, optional. A named list with the elements `method` as
#'  a string, and `width` and/or `height` as numerics. Please note you can only
#'  reduce an image's dimensions and make an image smaller with TinyPNG API, not
#'  make an image larger. Method must be set to one of "scale", "fit", "cover",
#'  or "thumb". If using "scale", you only need to provide `width` OR `height`,
#'  not both. If using any other method, you must supply both a `width` AND
#'  `height`. See <https://tinypng.com/developers/reference#resizing-images> and
#'  the examples for more.
#'@seealso [tinify()] to shrink image filesizes
#'@seealso [tinify_key()] to set a default TinyPNG.com API key
#'@export
#' @examples
#' \dontrun{
#'
#' tinify_defaults(quiet = TRUE, suffix = "_small")
#'
#' # set an option back to the package default
#'
#' tinify_defaults(quiet = NULL)
#'
#' # show current defaults set
#'
#' tinify_defaults()
#' #> Tinify 'overwrite' set to: FALSE
#' #> Tinify 'suffix' set to: "_tiny"
#' #> Tinify 'quiet' set to: FALSE
#' #> Tinify 'return_path' set to: No return
#' #> Tinify 'resize' set to: No resize
#'
#' }
tinify_defaults <- function(overwrite,
                       suffix,
                       quiet,
                       return_path,
                       resize) {

  if(!missing(overwrite)){
    if(!identical(overwrite, TRUE) & !identical(overwrite, FALSE) & !identical(overwrite, NULL)) {
      stop("Please provide 'overwrite' as TRUE or FALSE, or NULL")
    } else {
      options(tinify_overwrite = overwrite)
    }
    message(glue::glue("Tinify 'overwrite' set to: {getOption('tinify_overwrite', default = FALSE)}"))
  }

  if(!missing(suffix)){
    if (is.null(suffix)) {
      options(tinify_suffix = suffix)
    } else if(!is.character(suffix) | length(suffix) > 1 | suffix == "") {
      stop("Please provide 'suffix' as a non-empty character string, or NULL")
    } else {
      options(tinify_suffix = suffix)
    }
    suf_set <- if (!is.null(getOption('tinify_suffix'))) glue::glue("\"{getOption('tinify_suffix')}\"") else '\"_tiny\"'
    message(glue::glue("Tinify 'suffix' set to: {suf_set}"))
  }

  if(!missing(quiet)){
    if(!identical(quiet, TRUE) & !identical(quiet, FALSE) & !identical(quiet, NULL)) {
      stop("Please provide 'quiet' as TRUE or FALSE, or NULL")
    } else {
      options(tinify_quiet = quiet)
    }
    message(glue::glue("Tinify 'quiet' set to: {getOption('tinify_quiet', default = FALSE)}"))
  }

  if(!missing(return_path)){
    if (is.null(return_path)) {
      options(tinify_return_path = return_path)
    } else if(!(return_path %in% c("proj", "rel", "abs", "all"))) {
      stop("Please provide 'return_path' as one of  'proj', 'rel', 'abs', or 'all', or NULL")
    } else {
      options(tinify_return_path = return_path)
    }
    ret_set <- if (!is.null(getOption('tinify_return_path'))) glue::glue("\"{getOption('tinify_return_path')}\"") else 'No return'
    message(glue::glue("Tinify 'return_path' set to: {ret_set}"))
  }

  if(!missing(resize)){

    if (is.null(resize)) {
      options(tinify_resize = resize)
    } else if(!is.list(resize) | length(resize) < 2 | length(resize) > 3){
      # Check resize is a list of min length 2 and max length 3
      stop("Resize must be a list that includes a 'method' and one or both of 'width' or 'height'")
    } else if(!("method" %in% names(resize) & ("width" %in% names(resize) | "height" %in% names(resize)))) {
      # Check 'method' and at least one of 'width' or 'height' are named in resize
      stop("Resize must be a list that includes a 'method' and one or both of 'width' or 'height'")
    } else if(!(resize$method %in% c("fit", "scale", "cover", "thumb"))) {
      # Check resize method is a string specifying one of the available options
      stop('Method must be one of "fit", "scale", "cover" or "thumb"')
    } else if("width" %in% names(resize) & !is.numeric(resize$width) | "height" %in% names(resize) & !is.numeric(resize$height)) {
      # Check width and/or height are numbers
      stop("Width and/or height must be a number")
    } else if(identical(resize$method, "scale") & "width" %in% names(resize) & "height" %in% names(resize)) {
      # Check only one of width or height provided for method 'scale'
      stop("You must provide a width OR height for method 'scale', not both")
    } else if(!identical(resize$method, "scale") & (!("width" %in% names(resize)) | !("height" %in% names(resize)))) {
      # Check both width and height provided for other methods besides 'scale'
      stop(paste0("You must provide a width AND height for method '", resize$method, "'"))
    } else {
      options(tinify_resize = resize)
    }
    if(!is.null(resize)) {
      for (i in 1:length(resize)) {
          if (is.character(resize[[i]])) {
            message(glue::glue('Tinify \'resize\' {(names(resize)[i])} set to: \"{resize[[i]]}\"'))
          } else {
            message(glue::glue('Tinify \'resize\' {(names(resize)[i])} set to: {resize[[i]]}'))
          }
        }
    } else {
      message(glue::glue("Tinify 'resize' set to: No resize"))
    }
  }

  if (missing(overwrite) & missing(suffix) & missing(quiet) & missing(return_path) & missing(resize)) {
    message(glue::glue("Tinify 'overwrite' set to: {getOption('tinify_overwrite', default = FALSE)}"))
    suf_set <- if (!is.null(getOption('tinify_suffix'))) glue::glue("\"{getOption('tinify_suffix')}\"") else '\"_tiny\"'
    message(glue::glue("Tinify 'suffix' set to: {suf_set}"))
    message(glue::glue("Tinify 'quiet' set to: {getOption('tinify_quiet', default = FALSE)}"))
    ret_set <- if (!is.null(getOption('tinify_return_path'))) glue::glue("\"{getOption('tinify_return_path')}\"") else 'No return'
    message(glue::glue("Tinify 'return_path' set to: {ret_set}"))
    if(!is.null(getOption("tinify_resize"))) {
      resize <- getOption("tinify_resize")
      for (i in 1:length(resize)) {
          if (is.character(resize[[i]])) {
            message(glue::glue('Tinify \'resize\' {(names(resize)[i])} set to: \"{resize[[i]]}\"'))
          } else {
            message(glue::glue('Tinify \'resize\' {(names(resize)[i])} set to: {resize[[i]]}'))
          }
        }
    } else {
      message(glue::glue("Tinify 'resize' set to: No resize"))
    }
  }

}
