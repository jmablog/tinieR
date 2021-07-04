#'Set defaults for `tinify()` function
#'
#'@description Set some default options for `tinify()` in the global environment, so it is no
#'longer necessary to explicitly provide each argument with every call of
#'`tinify()`.
#'
#'If called without any arguments, `tinify_defaults()` will print
#'the current default options set to the console.
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
#'@param return_path String or `NULL`, optional. One of "`proj`", "`rel`", "`abs`", or
#'  "`all`". If "`proj`", will return the file path of the newly tinified image
#'  file relative to the Rstudio project directory (looking for an .Rproj file).
#'  If no project can be identified, returns `NA`. If "`rel`", will return the
#'  file path of the newly tinified image file, relative to the \strong{current}
#'  working directory at the time `tinify()` is called. If "`abs`", will return
#'  the absolute file path of the newly tinified image file. If "`all`", will
#'  return a named list with all file paths. Set to `NULL` to stop returning a
#'  file path.
#'@param resize Named list or `NULL`, optional. A named list with the elements `method` as
#'  a string, and `width` and/or `height` as numerics. Please note you can only
#'  reduce an image's dimensions and make an image smaller with TinyPNG API, not
#'  make an image larger. Method must be set to one of "scale", "fit", "cover",
#'  or "thumb". If using "scale", you only need to provide `width` OR `height`,
#'  not both. If using any other method, you must supply both a `width` AND
#'  `height`. See <https://tinypng.com/developers/reference#resizing-images> and
#'  the examples for more. Set to `NULL` to stop resizing.
#'@seealso [tinify()] to shrink image filesizes
#'@seealso [tinify_key()] to set a default TinyPNG.com API key
#'@export
#' @examples
#' \dontrun{
#'
#' tinify_defaults(quiet = TRUE, suffix = "_small")
#'
#' # show current defaults set
#'
#' tinify_defaults()
#' #> Tinify 'overwrite' set to: FALSE
#' #> Tinify 'suffix' set to: "_small"
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

  #  print defaults if all arguments missing ===================================

  if (missing(overwrite) & missing(suffix) & missing(quiet) & missing(return_path) & missing(resize)) {

    .tinify_print_defaults()

  } else {

    # Error checking ===========================================================

    ## Check for arguments and set to defaults if missing ----------------------

    tinify_opts <- .tinify_getset_opts(overwrite,
                                       suffix,
                                       quiet,
                                       return_path,
                                       resize)

    ## Generic argument error checking -----------------------------------------

    .tinify_error_check(overwrite = tinify_opts$overwrite,
                        suffix = tinify_opts$suffix,
                        quiet = tinify_opts$quiet,
                        return_path = tinify_opts$return_path,
                        resize = tinify_opts$resize)

    # Main function body =======================================================

    ## overwrite ---------------------------------------------------------------

    if(!missing(overwrite)){
      options(tinify.overwrite = overwrite)
      cli::cli_alert_success("Tinify {.var overwrite} changed to: {.field {overwrite}}")
    }

    ## suffix ------------------------------------------------------------------

    if(!missing(suffix)){
      options(tinify.suffix = suffix)
      cli::cli_alert_success("Tinify {.var suffix} changed to: {.field {suffix}}")
    }

    ## quiet -------------------------------------------------------------------

    if(!missing(quiet)){
      options(tinify.quiet = quiet)
      cli::cli_alert_success("Tinify {.var quiet} changed to: {.field {quiet}}")
    }

    ## return_path -------------------------------------------------------------

    if(!missing(return_path)){
      options(tinify.return_path = return_path)
      if(!is.null(return_path)) {
        cli::cli_alert_success("Tinify {.var return_path} changed to: {.field \"{return_path}\"}")
      } else {
        cli::cli_alert_success("Tinify {.var return_path} changed to: {.field No return}")
      }
    }

    ## resize ------------------------------------------------------------------

    if(!missing(resize)){
      options(tinify.resize = resize)
      if(!is.null(resize)) {
        for (i in 1:length(resize)) {
            if (is.character(resize[[i]])) {
              cli::cli_alert_success('Tinify {.var resize} {(names(resize)[i])} changed to: {.field \"{resize[[i]]}\"}')
            } else {
              cli::cli_alert_success('Tinify {.var resize} {(names(resize)[i])} changed to: {.field {resize[[i]]}}')
            }
          }
      } else {
        cli::cli_alert_success("Tinify {.var resize} changed to: {.field No resize}")
      }
    }

  }

}

#' Prints the currently set tinify_defaults
#' @noRd
#' @keywords internal
.tinify_print_defaults <- function() {

    # overwrite ----------------------------------------------------------------

    cli::cli_alert_info("Tinify {.var overwrite} default is: {.field {getOption('tinify.overwrite', default = FALSE)}}")

    # suffix -------------------------------------------------------------------

    cli::cli_alert_info("Tinify {.var suffix} default is: {.field \"{if (!is.null(getOption('tinify.suffix'))) getOption('tinify.suffix') else '_tiny'}\"}")

    # quiet --------------------------------------------------------------------

    cli::cli_alert_info("Tinify {.var quiet} default is: {.field {getOption('tinify.quiet', default = FALSE)}}")

    # return_path --------------------------------------------------------------

    cli::cli_alert_info("Tinify {.var return_path} default is: {.field {if (!is.null(getOption('tinify.return_path'))) getOption('tinify.return_path') else 'No return'}}")

    # resize -------------------------------------------------------------------

    if(!is.null(getOption("tinify.resize"))) {
      resize <- getOption("tinify.resize")
      for (i in 1:length(resize)) {
        if (is.character(resize[[i]])) {
          cli::cli_alert_info('Tinify {.var resize} {(names(resize)[i])} default is: {.field \"{resize[[i]]}\"}')
        } else {
          cli::cli_alert_info('Tinify {.var resize} {(names(resize)[i])} default is: {.field {resize[[i]]}}')
        }
      }
    } else {
      cli::cli_alert_info("Tinify {.var resize} default is: {.field No resize}")
    }

}
