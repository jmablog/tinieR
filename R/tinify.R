#' @title Shrink Image Files with TinyPNG
#'
#' @description Shrink an image's (PNG or JPG) filesize with the TinyPNG API.
#'
#' @details You can get a TinyPNG API key from <https://tinypng.com/developers>.
#'
#'   TinyPNG is smart enough to know when you are uploading the same file again,
#'   and so will not count repeat calls of `tinify()` on the same image file against
#'   your monthly API usage limit. This can be useful if, for example, you are using `tinify()`
#'   in an RMarkdown document as it won't count against your API usage every time you knit your
#'   document.
#'
#' @param file A string detailing the path to the file you wish to shrink,
#'   relative to the current working directory. Can include sub-directories and
#'   must include the file extension (.png or .jpg/.jpeg only).
#' @param overwrite Boolean. By default, tinify will create a new file with the
#'   suffix '_tiny' and preserve the original file. Set `TRUE` to instead overwrite
#'   the original file, with the same filename.
#' @param return_path Boolean. If TRUE, tinify returns the full absolute filepath to the
#'   newly shrunk file as a string.
#' @param details Boolean. If TRUE, provides details on the amount of
#'   shrinkage (% and Kb), and the number of TinyPNG API calls made this month.
#' @param key Optional. A string containing your TinyPNG API key.
#'   Not required if the API key is set using `tinify_api()`.
#'   If an API key is provided with `tinify_api()`, any other key
#'   provided in the function call will override the key set by `tinify_api()`.
#'
#' @return If `return_path = TRUE`, a string with the full absolute path to the newly shrunk image file.
#' @export
#' @seealso [tinify_key()] to set an API key globally so it does not need to be provided with every call of `tinify()`
#' @examples
#' \dontrun{
#' # Shrink a PNG file
#'
#' img <- system.file("extdata", "example.png", package = "tinieR")
#'
#' tinify(img)
#'
#' # Also works with JPEG/JPG files
#'
#' img_jpg <- system.file("extdata", "example.jpg", package = "tinieR")
#'
#' tinify(img_jpg)
#'
#' # Return absolute path to newly shrunk file:
#'
#' shrunk_img <- tinify(img, return_path = TRUE)
#'
#' # Show details:
#'
#' tinify(img, details = TRUE)
#'
#' # Overwrite original file in place:
#'
#' tinify(img, overwrite = TRUE)
#'
#' # Overwrite a global API key set in tinify_api():
#'
#' tinify(img, key = "NEW-API-KEY-HERE")
#'
#' # You can combine any number of the above:
#'
#' tinify(img,
#'        overwrite = TRUE,
#'        details = TRUE,
#'        return_path = TRUE)
#'
#' # Plays nice with the pipe:
#'
#' img %>% tinify()
#'
#' # And with purrr::map for multiple files:
#'
#' imgs <- c("example.png", "example2.png")
#'
#' purrr::map(imgs, ~tinify(.x))
#'
#' # An example method for shrinking an entire directory:
#'
#' imgs_dir <- fs::dir_ls("imgs", glob = "*.png")
#'
#' purrr::map(imgs_dir, ~tinify(.x, overwrite = TRUE))
#'}
tinify <- function(file,
                   overwrite = FALSE,
                   return_path = FALSE,
                   details = FALSE,
                   key = NULL) {

  if(!is.null(key) & is.character(key) & length(key) == 1) {
    tiny_api <- key
  } else if (!is.null(key) & !is.character(key) | !is.null(key) & length(key) > 1) {
    stop("Please provide your API key as a string")
  } else if(is.null(key) & Sys.getenv("TINY_API") != "") {
    tiny_api <- Sys.getenv("TINY_API")
  } else {
    stop("Please provide an API key with the 'key' argument or using 'tinify_key()'")
  }

  if(fs::file_exists(file)[[1]] == FALSE){
    stop(glue::glue("File '{file}' does not exist"), call. = F)
  }

  filepath <- fs::path_abs(file)

  ext <- fs::path_ext(filepath)

  if(identical(ext, "png")) {
    img_type <- "image/png"
  } else if(identical(ext, "jpg") | identical(ext, "jpeg")) {
    img_type <- "image/jpeg"
  } else {
    stop("TinyPNG can only handle .png or .jpg/.jpeg files", call. = F)
  }

  post <- httr::POST("https://api.tinify.com/shrink",
                     httr::authenticate("api", tiny_api, type = "basic"),
                     body = httr::upload_file(filepath, type = img_type),
                     encode = "multipart")

  if(httr::http_error(post)) {
    if(post$status_code == 401) {
      stop(glue::glue("{httr::http_status(post)$message} - Please make sure your API key is correct"),
           call. = F)
    } else {
      stop(httr::http_status(post)$message, call. = F)
    }
  }

  response <- httr::headers(post)$location

  if(identical(overwrite, TRUE)) {
    new_file <- filepath
  } else if(identical(overwrite, FALSE)){
    new_file <- glue::glue("{fs::path_ext_remove(filepath)}_tiny.{ext}")
  } else {
    stop("Please only provide 'overwrite' as TRUE or FALSE")
  }

  utils::download.file(response,
                       new_file,
                       quiet = TRUE)

  if(identical(details, TRUE)){
    old_file_name <- fs::path_file(filepath)
    new_file_name <- fs::path_file(new_file)
    init_size <- fs::file_size(filepath)
    new_size <- fs::file_size(new_file)
    pct_reduced <- round(((init_size - new_size)/init_size)*100, 1)
    comp_count <- httr::headers(post)$`compression-count`

    msg <- glue::glue("Filesize reduced by {pct_reduced}%:
                      {old_file_name} ({init_size}) => {new_file_name} ({new_size})
                      {comp_count} Tinify API calls this month")

    message(msg)
  } else if(!identical(details, FALSE)) {
    stop("Please only provide 'details' as TRUE or FALSE")
  }

  if(identical(return_path, TRUE)) {
    return(as.character(new_file))
  } else if(!identical(return_path, FALSE)) {
    stop("Please only provide 'return_path' as TRUE or FALSE")
  }

}
