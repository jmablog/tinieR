#'@title Shrink Image Files with TinyPNG
#'
#'@description Shrink an image's (PNG or JPG) filesize with the TinyPNG API.
#'
#'@section Note: If any argument is provided to `tinify()` when called, it will overwrite the
#'  default option set by `tinify_defaults()`.
#'
#'@section TinyPNG API: You can get a TinyPNG API key from
#'  <https://tinypng.com/developers>. TinyPNG is smart enough to know when you
#'  are uploading the same file again, and so will not count repeat calls of
#'  `tinify()` on the same image file against your monthly API usage limit. This
#'  can be useful if, for example, you are using `tinify()` in an RMarkdown
#'  document as it won't count against your API usage every time you knit your
#'  document. But, be aware that use of `resize` also counts as an additional
#'  API call, as the image is first reduced in filesize, then a second API call
#'  is made to resize the newly tinified file.
#'
#'@param file String, required. A string detailing the path to the file you wish
#'  to shrink, relative to the current working directory or as an absolute file
#'  path. Can include sub-directories and must include the file extension (.png
#'  or .jpg/.jpeg only).
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
#'@param key String, optional. A string containing your TinyPNG API key. Not
#'  required if the API key is set using `tinify_api()`. If an API key is
#'  provided with `tinify_api()`, any other key provided in the function call
#'  will override the key set by `tinify_api()`.
#'
#'@return If `return_path = "proj"`, `return_path = "rel"`, or `return_path =
#'  "abs"`, a string with the project, relative, or absolute path to the newly
#'  tinified image file. If no project can be identified for `return_path =
#'  "proj"`, returns `NA`. If `return_path = "all"`, a named list with all file
#'  paths included as `$project`, `$relative`, and `$absolute` respectively. If
#'  `return_path = NULL`, no return value.
#'
#'@export
#'@seealso [tinify_key()] to set an API key globally so it does not need to be
#'  provided with every call of `tinify()`
#'@seealso [tinify_defaults()] to set default arguments so they do not need to
#'  be provided with every call of `tinify()`
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
#' shrunk_img <- tinify(img, return_path = "abs")
#'
#' # Suppress messages detailing file reduction amount:
#'
#' tinify(img, quiet = TRUE)
#'
#' # Overwrite original file in place:
#'
#' tinify(img, overwrite = TRUE)
#'
#' # Change suffix on new file:
#'
#' tinify(img, suffix = "_small")
#'
#' # Resize an image with the method "scale", only providing a width:
#'
#' tinify(img, resize = list(method = "scale", width = 300))
#'
#' # Or resize an image with any other method by providing both width and height:
#'
#' tinify(img, resize = list(method = "cover", width = 300, height = 150))
#'
#' # Overwrite a global API key set in tinify_api():
#'
#' tinify(img, key = "NEW-API-KEY-HERE")
#'
#' # You can combine any of the above:
#'
#' tinify(img,
#'        overwrite = TRUE,
#'        quiet = TRUE,
#'        return_path = "rel")
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
#' purrr::map(imgs_dir, ~tinify(.x, overwrite = TRUE, quiet = TRUE))
#'}
tinify <- function(file,
                   overwrite,
                   suffix,
                   quiet,
                   return_path,
                   resize,
                   key = NULL) {

  # Check arguments against defaults from tinify_defaults ======================

  if(missing(overwrite)) {
    overwrite <- getOption("tinify_overwrite", default = FALSE)
  }

  if(missing(suffix)) {
    suffix <- getOption("tinify_suffix", default = "_tiny")
  }

  if(missing(quiet)) {
    quiet <- getOption("tinify_quiet", default = FALSE)
  }

  if(missing(return_path)) {
    return_path <- getOption("tinify_return_path", default = NULL)
  }

  if(missing(resize)) {
    resize <- getOption("tinify_resize", default = NULL)
  }

  # Error checking =============================================================

  # API key
  if(!is.null(key) & is.character(key) & length(key) == 1) {
    tiny_api <- key
  } else if (!is.null(key) & !is.character(key) | !is.null(key) & length(key) > 1) {
    stop("Please provide your API key as a string")
  } else if(is.null(key) & Sys.getenv("TINY_API") != "") {
    tiny_api <- Sys.getenv("TINY_API")
  } else {
    stop("Please provide an API key with the 'key' argument or using 'tinify_key()'")
  }

  # Check file exists
  if(fs::file_exists(file)[[1]] == FALSE){
    stop(glue::glue("File '{file}' does not exist"), call. = F)
  }

  # Set absolute path to original file
  filepath <- fs::path_abs(file)

  # Extract extension of original file
  ext <- fs::path_ext(filepath)

  # Check overwrite argument and set new file path as requested
  # Either overwriting original file completely or appending suffix to
  # new filename
  if(identical(overwrite, TRUE)) {
    new_file <- filepath
    if(suffix != "_tiny") {
      warning("'suffix' is ignored when 'overwrite' is TRUE")
    }
  } else if(identical(overwrite, FALSE)){
    if(is.character(suffix) & suffix != "") {
      new_file <- glue::glue("{fs::path_ext_remove(filepath)}{suffix}.{ext}")
    } else {
    stop("Please provide 'suffix' as a non-empty character string when 'overwrite' is FALSE")
    }
  } else {
    stop("Please only provide 'overwrite' as TRUE or FALSE")
  }

  # Check file type and reject anything not png or jpg
  if(identical(ext, "png")) {
    img_type <- "image/png"
  } else if(identical(ext, "jpg") | identical(ext, "jpeg")) {
    img_type <- "image/jpeg"
  } else {
    stop("TinyPNG can only handle .png or .jpg/.jpeg files", call. = F)
  }

  # Check resize list is provided with appropriate arguments
  if(!is.null(resize)) {

    # Check resize is a list of min length 2 and max length 3
    if(!is.list(resize) | length(resize) < 2 | length(resize) > 3){
      stop("Resize must be a list that includes a 'method' and one or both of 'width' or 'height'")
    }

    # Check 'method' and at least one of 'width' or 'height' are named in resize
    if(!("method" %in% names(resize) & ("width" %in% names(resize) | "height" %in% names(resize)))) {
      stop("Resize must be a list that includes a 'method' and one or both of 'width' or 'height'")
    }

    # Check resize method is a string specifying one of the available options
    if(!(resize$method %in% c("fit", "scale", "cover", "thumb"))) {
      stop('Method must be one of "fit", "scale", "cover" or "thumb"')
    }

    # Check width and/or height are numbers
    if("width" %in% names(resize) & !is.numeric(resize$width) | "height" %in% names(resize) & !is.numeric(resize$height)) {
      stop("Width and/or height must be a number")
    }

    # Check only one of width or height provided for method 'scale'
    if(identical(resize$method, "scale") & "width" %in% names(resize) & "height" %in% names(resize)) {
      stop("You must provide a width OR height for method 'scale', not both")
    }

    # Check both width and height provided for other methods besides 'scale'
    if(!identical(resize$method, "scale") & (!("width" %in% names(resize)) | !("height" %in% names(resize)))) {
      stop(paste0("You must provide a width AND height for method '", resize$method, "'"))
    }

  }

  # Check details argument correctly provided
  if(!identical(quiet, TRUE) & !identical(quiet, FALSE)) {
    stop("Please only provide 'quiet' as TRUE or FALSE")
  }

  # Check return_path argument correctly provided
  if(!is.null(return_path)) {
    if(!(return_path %in% c("proj", "rel", "abs", "all"))){
      stop('Please only provide return_path as "proj", "rel", "abs", or "all"')
    }
  }

  # Main function body =========================================================

  # Store initial filesize before tinifying
  init_size <- fs::file_size(filepath)

  # Send POST request to TinyPNG API, uploading original file
  post <- httr::POST("https://api.tinify.com/shrink",
                     httr::authenticate("api", tiny_api, type = "basic"),
                     body = httr::upload_file(filepath, type = img_type),
                     encode = "multipart")

  # Display http error code if error returned by TinyPNG API
  if(httr::http_error(post)) {
    if(post$status_code == 401) {
      stop(glue::glue("{httr::http_status(post)$message} - Please make sure your API key is correct"),
           call. = F)
    } else {
      stop(httr::http_status(post)$message, call. = F)
    }
  }

  # Set URL of tinified file on TinyPNG servers
  response <- httr::headers(post)$location

  # Download tinified file as-is if not resizing
  if(is.null(resize)){

    utils::download.file(response,
                         new_file,
                         quiet = TRUE,
                         mode = "wb")

  }

  # Resizing
  if(!is.null(resize)) {

    # Extract filename from full path of tinified file on TinyPNG servers to insert
    # into POST URL when sending to TinyPNG
    img <- fs::path_file(response)

    # Convert resize options list into JSON
    resize_json <- jsonlite::toJSON(list(resize = resize), auto_unbox = TRUE)

    # Resend tinified file from new URL to also be resized with TinyPNG API
    # With resize options sent as JSON
    resize_post <- httr::POST(glue::glue("https://api.tinify.com/output/{img}"),
                              httr::authenticate("api", tiny_api, type = "basic"),
                              httr::content_type_json(),
                              body = resize_json,
                              encode = "raw")

    # Return http error code if error received from TinyPNG API
    if(httr::http_error(resize_post)) {
        stop(httr::http_status(resize_post)$message, call. = F)
      }

    # Extract matrix of image binary returned by http request
    resized_img <- httr::content(resize_post)

    # Write to file
    if(identical(ext, "png")) {
      png::writePNG(resized_img, new_file)
    } else if(identical(ext, "jpg") | identical(ext, "jpeg")){
      jpeg::writeJPEG(resized_img, new_file, quality = 1)
    }

  }

  # Calculate and display details of file size changes and API calls if requested
  if(identical(quiet, FALSE)) {
    old_file_name <- fs::path_file(filepath)
    new_file_name <- fs::path_file(new_file)
    new_size <- fs::file_size(new_file)
    pct_reduced <- round(((init_size - new_size)/init_size)*100, 1)
    comp_count <- httr::headers(post)$`compression-count`

    msg <- glue::glue("Filesize reduced by {pct_reduced}%:
                      {old_file_name} ({init_size}) => {new_file_name} ({new_size})
                      {comp_count} Tinify API calls this month")

    message(msg)
  }

  # Return the file path of the new tinified file, either relative to current
  # working dir or as absolute file path, or both as a named list
  if(identical(return_path, "abs")) {

    # return the absolute file path to the tinified image file

    return(as.character(new_file))

  } else if(identical(return_path, "rel")) {

    # return the relative path to the tinified image file, from wherever the working
    # directory at the time of calling tinify() is

    loc_path <- fs::path_dir(file)
    loc_file <- fs::path_file(new_file)

    return(as.character(glue::glue("{loc_path}/{loc_file}")))

  } else if(identical(return_path, "proj")) {

    # return the path to the newly tinified file, from the root project folder

    tryCatch({
    proj_dir <- glue::glue(
      "{rprojroot::find_root(path = new_file, criterion = rprojroot::is_rstudio_project)}/"
    )
    proj_file <- suppressWarnings(stringr::str_remove(new_file, stringr::coll(proj_dir)))
    return(proj_file)
    },
    error = function (err) {
      proj_file <- NA
      return(proj_file)
    })

  } else if(identical(return_path, "all")) {

    # return all 3 of the return_path options in a named list

    abs_file <- as.character(new_file)

    loc_path <- fs::path_dir(file)
    loc_file <- fs::path_file(new_file)
    rel_file <- as.character(glue::glue("{loc_path}/{loc_file}"))

    tryCatch({
      proj_dir <- glue::glue(
        "{rprojroot::find_root(path = new_file, criterion = rprojroot::is_rstudio_project)}/"
      )
      proj_file <- suppressWarnings(stringr::str_remove(new_file, stringr::coll(proj_dir)))
      return(list(absolute = abs_file, relative = rel_file, project = proj_file))
    },
    error = function (err) {
      proj_file <- NA
      return(list(absolute = abs_file, relative = rel_file, project = proj_file))
    })

  }

}
