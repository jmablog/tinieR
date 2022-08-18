#'@title Shrink image files with TinyPNG
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
#'@param return_path String or `NULL`, optional. One of "`proj`", "`rel`", "`abs`", or
#'  "`all`". If "`proj`", will return the file path of the newly tinified image
#'  file relative to the Rstudio project directory (looking for an .Rproj file).
#'  If no project can be identified, returns `NA`. If "`rel`", will return the
#'  file path of the newly tinified image file, relative to the \strong{current}
#'  working directory at the time `tinify()` is called. If "`abs`", will return
#'  the absolute file path of the newly tinified image file. If "`all`", will
#'  return a named list with all file paths. If `NULL` (the default), no file
#'  path is returned.
#'@param resize Named list or `NULL`, optional. A named list with the elements `method` as
#'  a string, and `width` and/or `height` as numerics. Please note you can only
#'  reduce an image's dimensions and make an image smaller with TinyPNG API, not
#'  make an image larger. Method must be set to one of "scale", "fit", "cover",
#'  or "thumb". If using "scale", you only need to provide `width` OR `height`,
#'  not both. If using any other method, you must supply both a `width` AND
#'  `height`. See <https://tinypng.com/developers/reference#resizing-images> and
#'  the examples for more. If `NULL` (the default), no resizing takes place.
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


  # Error checking =============================================================

  ## Check for arguments and set to defaults if missing ------------------------

  tinify_opts <- .tinify_getset_opts(overwrite,
                                     suffix,
                                     quiet,
                                     return_path,
                                     resize)

  ## Generic argument error checking -------------------------------------------

  .tinify_error_check(overwrite = tinify_opts$overwrite,
                      suffix = tinify_opts$suffix,
                      quiet = tinify_opts$quiet,
                      return_path = tinify_opts$return_path,
                      resize = tinify_opts$resize)

  ## tinify specific error checking --------------------------------------------

  # API key
  # if(!is.null(key) & is.character(key) & length(key) == 1) {
  #   tiny_api <- key
  # } else if (!is.null(key) & !is.character(key) | !is.null(key) & length(key) > 1) {
  #   cli::cli_abort("Please provide your API key as a string")
  # } else if(is.null(key) & Sys.getenv("TINY_API") != "") {
  #   tiny_api <- Sys.getenv("TINY_API")
  # } else {
  #   cli::cli_abort("Please provide an API key with the {.field key} argument or using {.code tinify_key()}")
  # }

  tiny_api <- .tinify_key_check(key)

  # Check file exists
  if(fs::file_exists(file)[[1]] == FALSE) {
    msg = as.character(glue::glue("File {.file <file>} does not exist", .open = "<", .close = ">"))
    cli::cli_abort(msg)
  }

  # Set absolute path to original file
  filepath <- fs::path_abs(file)

  # Extract extension of original file
  ext <- fs::path_ext(filepath)

  # Check file extension and reject anything not png or jpg
  if(identical(ext, "png")) {
    img_type <- "image/png"
  } else if(identical(ext, "jpg") | identical(ext, "jpeg")) {
    img_type <- "image/jpeg"
  } else {
    cli::cli_abort("TinyPNG can only handle {.file png} or {.file jpg/jpeg} files")
  }

  # Main function body =========================================================

  if(identical(tinify_opts$quiet, FALSE)) {
  sb <- cli::cli_status("{cli::symbol$arrow_up} Uploading image to TinyPNG...")
  Sys.sleep(0.25)
  }

  # Store initial filesize and dimensions before tinifying
  # (up here incase overwrite = TRUE)
  init_size <- fs::file_size(filepath)
  if(!is.null(tinify_opts$resize)) {
    if(identical(ext, "png")) {
      init_dims <- dim(png::readPNG(filepath))[1:2]
      names(init_dims) <- c("height", "width")
    } else if(identical(ext, "jpg") | identical(ext, "jpeg")) {
      init_dims <- dim(jpeg::readJPEG(filepath))[1:2]
      names(init_dims) <- c("height", "width")
    }
  }

  # Send POST request to TinyPNG API, uploading original file
  post <- httr::POST("https://api.tinify.com/shrink",
                     httr::authenticate("api", tiny_api, type = "basic"),
                     body = httr::upload_file(filepath, type = img_type),
                     encode = "multipart")

  # Display http error code if error returned by TinyPNG API
  if(httr::http_error(post)) {
    if(post$status_code == 401) {
      cli::cli_abort("{httr::http_status(post)$message} - Please make sure your API key is correct")
    } else {
      cli::cli_abort("{httr::http_status(post)$message}")
    }
  }

  # Set URL of tinified file on TinyPNG servers
  response <- httr::headers(post)$location

  if(identical(tinify_opts$quiet, FALSE)) {
  cli::cli_status_update(id = sb, "{cli::symbol$arrow_down} Saving tinified image...")
  Sys.sleep(0.25)
  }

  # Check overwrite argument and set new file path as requested
  # Either overwriting original file completely or appending suffix to
  # new filename
  if(identical(tinify_opts$overwrite, TRUE)) {
    new_file <- filepath
  } else if(identical(tinify_opts$overwrite, FALSE)) {
    new_file <- glue::glue("{fs::path_ext_remove(filepath)}{tinify_opts$suffix}.{ext}")
  }

  # Download tinified file as-is if not resizing
  if(is.null(tinify_opts$resize)){

    utils::download.file(response,
                         new_file,
                         quiet = TRUE,
                         mode = "wb")

  }

  # Resizing ===================================================================
  if(!is.null(tinify_opts$resize)) {

    if(identical(tinify_opts$quiet, FALSE)) {
      cli::cli_status_update(id = sb, "{cli::symbol$circle_dotted} Resizing...")
      Sys.sleep(0.5)
    }

    # Extract filename from full path of tinified file on TinyPNG servers to insert
    # into POST URL when sending to TinyPNG
    img <- fs::path_file(response)

    # Convert resize options list into JSON
    resize_json <- jsonlite::toJSON(list(resize = tinify_opts$resize), auto_unbox = TRUE)

    # Resend tinified file from new URL to also be resized with TinyPNG API
    # With resize options sent as JSON
    resize_post <- httr::POST(glue::glue("https://api.tinify.com/output/{img}"),
                              httr::authenticate("api", tiny_api, type = "basic"),
                              httr::content_type_json(),
                              body = resize_json,
                              encode = "raw")

    # Return http error code if error received from TinyPNG API
    if(httr::http_error(resize_post)) {
        cli::cli_abort("{httr::http_status(resize_post)$message}")
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


  # Calculate and display details of file size =================================
  # changes and API calls unless quiet = T

  if(identical(tinify_opts$quiet, FALSE)) {
    old_file_name <- fs::path_file(filepath)
    new_file_name <- fs::path_file(new_file)
    new_size <- fs::file_size(new_file)

    pct_reduced <- round(((init_size - new_size)/init_size)*100, 1)
    comp_count <- httr::headers(post)$`compression-count`

    if(!is.null(tinify_opts$resize)) {

      # Calculate new image dimensions if using resize
      if(identical(ext, "png")) {
        new_dims <- dim(png::readPNG(new_file))[1:2]
        names(new_dims) <- c("height", "width")
      } else if(identical(ext, "jpg") | identical(ext, "jpeg")) {
        new_dims <- dim(jpeg::readJPEG(new_file))[1:2]
        names(new_dims) <- c("height", "width")
      }

      cli::cli_status_clear(id = sb)
      cli::cli_div(theme = list (.alert = list(color = "green")))
      cli::cli_alert_success("Image tinified by {pct_reduced}% and resized")
      cli::cli_end()
      cli::cli_alert_info("{old_file_name} ({init_size}, w: {init_dims['width']}px, h: {init_dims['height']}px) {cli::symbol$arrow_right} {new_file_name} ({new_size}, w: {new_dims['width']}px, h: {new_dims['height']}px)")
      cli::cli_alert_info("{comp_count} Tinify API calls this month")

    } else {

      cli::cli_status_clear(id = sb)
      cli::cli_div(theme = list (.alert = list(color = "green")))
      cli::cli_alert_success("Image tinified by {pct_reduced}%")
      cli::cli_end()
      cli::cli_alert_info("{old_file_name} ({init_size}) {cli::symbol$arrow_right} {new_file_name} ({new_size})")
      cli::cli_alert_info("{comp_count} Tinify API calls this month")

    }
  }

  # Returning file paths =======================================================
  # Return the file path of the new tinified file, either relative to current
  # working dir or as absolute file path, or both as a named list

  if(identical(tinify_opts$return_path, "abs")) {

    # return the absolute file path to the tinified image file

    return(as.character(new_file))

  } else if(identical(tinify_opts$return_path, "rel")) {

    # return the relative path to the tinified image file, from wherever the working
    # directory at the time of calling tinify() is

    loc_path <- fs::path_dir(file)
    loc_file <- fs::path_file(new_file)

    return(as.character(fs::path_join(c(loc_path, loc_file))))

  } else if(identical(tinify_opts$return_path, "proj")) {

    # return the path to the newly tinified file, from the root project folder

    tryCatch({
    proj_dir <- glue::glue(
      "{rprojroot::find_root(path = new_file, criterion = rprojroot::is_rstudio_project)}"
    )
    proj_file <- fs::path_rel(start = proj_dir, path = new_file)
    return(as.character(proj_file))
    },
    error = function (err) {
      proj_file <- NA
      return(proj_file)
    })

  } else if(identical(tinify_opts$return_path, "all")) {

    # return all 3 of the return_path options in a named list

    abs_file <- as.character(new_file)

    loc_path <- fs::path_dir(file)
    loc_file <- fs::path_file(new_file)
    rel_file <- as.character(fs::path_join(c(loc_path, loc_file)))

    tryCatch({
      proj_dir <- glue::glue(
        "{rprojroot::find_root(path = new_file, criterion = rprojroot::is_rstudio_project)}"
      )
      proj_file <- as.character(fs::path_rel(start = proj_dir, path = new_file))
      return(list(absolute = abs_file, relative = rel_file, project = proj_file))
    },
    error = function (err) {
      return(list(absolute = abs_file, relative = rel_file, project = NA))
    })

  }

}
