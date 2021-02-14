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
