#' Set TinyPNG.com API Key
#'
#' Set your TinyPNG API key in the system environment, so it is
#' no longer necessary to explicitly provide an API key with every
#' call of `tinify()`.
#'
#' You can get a TinyPNG API key from <https://tinypng.com/developers>.
#'
#' @param key A string containing your TinyPNG.com API key.
#' @seealso [tinify()] to shrink image filesizes
#' @seealso [tinify_defaults()] to set default arguments so they do not need to be
#'  provided with every call of `tinify()`
#' @export
#' @examples
#' \dontrun{
#' tinify_key("YOUR-API-KEY-HERE")
#' }
tinify_key <- function(key) {

  if(!is.character(key) | length(key) > 1){
    cli::cli_abort("API key must be a string")
  }

  Sys.setenv(TINY_API = key)
  cli::cli_alert_success("TinyPNG API key set")
}
