.onUnload <- function(libname, pkgname) {
  options(list(tinify.overwrite = NULL,
               tinify.suffix = NULL,
               tinify.quiet = NULL,
               tinify.return_path = NULL,
               tinify.resize = NULL))

  invisible()
}
