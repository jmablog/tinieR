
# tinieR

<!-- badges: start -->
  [![R build status](https://github.com/jmablog/tinieR/workflows/R-CMD-check/badge.svg)](https://github.com/jmablog/tinieR/actions)
[![codecov](https://codecov.io/gh/jmablog/tinieR/branch/master/graph/badge.svg)](https://codecov.io/gh/jmablog/tinieR)
  <!-- badges: end -->

Shrink image filesizes with the [TinyPNG](https://tinypng.com) API. Works with .png and .jpg/.jpeg files, and can return the new image filepath to enable embedding in other image workflows/functions.

## Installation

You can install the latest version of tinieR from [Github](https://github.com) with:

``` r
# install.packages("devtools")
devtools::install_github("jmablog/tinieR")
```

## Authentication with TinyPNG

You will need an API key from [TinyPNG](https://tinypng.com). You can signup to get one [here](https://tinypng.com/developers).

Once you have your API key, you can set it for your current R session with:

``` r
library(tinier)

tinify_key("YOUR-API-KEY-HERE")
```

Or you can provide your API key as an argument to `tinify()` at every call:

``` r
my_key <- "YOUR-API-KEY-HERE"

tinify("example.png", key = my_key)
```

Providing an API key as an argument to `tinify()` will override any API key set with `tinify_api()`. This could be useful if utilising multiple API keys.

Be careful including your API key in any scripts you write, especially if you're going to be publicly or privately sharing those scripts with others! You might consider setting your API key instead in your .Renviron file (~/.Renviron). If you use the variable name `TINY_API` in .Renviron, `tinify()` should find it, and you can skip using `tinify_api()` or providing an API at each call of `tinify()`.

To edit your .Renviron in Rstudio:

``` r
usethis::edit_r_environ()
```

Then save into .Renviron:

``` r
TINY_API = "YOUR-API-KEY-HERE"
```

Restart your R session, and your TinyPNG API key will be stored as an environment variable that `tinify()` will automatically find.

## Shrinking an image

To shrink an image file's size, provide a path to the file relative to the current working directory.:

``` r
tinify("example.png")

#> Filesize reduced by 50%:
#> example.png (20K) => example_tiny.png (10K)
#> 10 Tinify API calls this month
```

By default, `tinify` will create a new file with the suffix '_tiny' in the same directory as the original file. You can change this suffix to your own using `suffix = "yoursuffix"`:

``` r
tinify("example.png", suffix = "_small")

#> Filesize reduced by 50%:
#> example.png (20K) => example_small.png (10K)
#> 11 Tinify API calls this month
```

`suffix` must not be an empty string. To instead overwrite the original file with the newly tinified file, use `overwrite = TRUE`:

``` r
tinify("example.png", overwrite = TRUE)

#> Filesize reduced by 50%:
#> example.png (20K) => example.png (10K)
#> 12 Tinify API calls this month
```

If you use `overwrite`, then `suffix` is ignored.

Tinify will provide messages detailing the file size reduction (in % and as [FS bytes](https://fs.r-lib.org/reference/fs_bytes.html)) along with the number of API calls made each month when called. You can suppress these messages with `quiet = TRUE`:

``` r
tinify("example.png", quiet = TRUE)
```

## Using the tinified image

Tinify can also return the file path to the tinified file, as a string, with `return_path`. Set to `return_path = "abs"` to return the absolute file path to the tinified file, which can be passed in to another function that takes an image file path to automate shrinking filesizes when, for example, knitting a document:

``` r
shrunk_img <- tinify("imgs/example.png", return_path = "abs", quiet = TRUE)

knitr::include_graphics(shrunk_img)
```

Set to `return_path = "proj"` to return the path to the newly tinified file relative to the **project** directory, no matter the current working directory. This looks for an [Rstudio project](https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects) file (.Rproj) in the current directory or above, and return the path from there. 

``` r
setwd("imgs")

tinify("example.png", return_path = "proj", quiet = TRUE)
#> "imgs/examples.png"
```

Or, set to `return_path = "rel"` to return the file path relative to the **current** working directory at the time the file was tinified.

``` r
setwd("imgs")

tinify("example.png", return_path = "rel", quiet = TRUE)
#> "./examples.png"
```

Either of these options may be useful if sharing a script with others across platforms, if you can be sure your project setups will be the same and you are being strict with working directories. Finally, set to `return_path = "all"` to return both types of file path as a named list:

```r
shrunk_img_list <- tinify("imgs/example.png", return_path = "all", quiet = TRUE)

knitr::include_graphics(shrunk_img_list$absolute)
knitr::include_graphics(shrunk_img_list$project)
knitr::include_graphics(shrunk_img_list$relative)
```

## Resizing image dimensions

You can also use the `resize` argument to change the image dimensions along with it's filesize (**note:** you can only *decrease* image dimensions and make it smaller with TinyPNG, not make an image bigger). I recommend reading the [TinyPNG API documentation on resizing methods](https://tinypng.com/developers/reference#resizing-images) first, to familiarise yourself with the various options you can use to change image dimensions.

`resize` takes a named list, containing a `method` string and at least one of `width` or `height`, or both `width` AND `height` depending on your chosen resize method, to specify the dimensions in pixels you would like the image resized:

```r
resize_opts <- list(method = "fit", width = 300, height = 150)

tinify("imgs/example.png", resize = resize_opts)
```

Be aware that resizing and shrinking the filesize of an image counts as 2 API calls - see below.

## TinyPNG API monthly allowance and other details

TinyPNG is quite generous at 500 free API calls per month (I only hit around 50 calls in total during the entire development and testing of this package!), but if you're using `tinify()` as part a script that may be run multiple times, you should be aware of your API usage. Fortunately TinyPNG is smart enough to know when you are uploading the same file over again, and so will not count repeat calls of `tinify()` on the **exact same** image file against your monthly limit. This is handy if you are using `tinify()` in an RMarkdown document as it won't count against your API usage every time you knit your document. However be careful if saving new images to file from other workflows, such as creating plots, as changes to these will most likely count as new files when uploaded to TinyPNG.

Resizing an image also counts as **an extra API call**, as the image is first uploaded to TinyPNG and the filesize reduced, then this new image is resized with a second call to the API.

## Changing default options for tinify

You can change the defaults for `tinify()` using `tinify_defaults()`. `tinify_defaults()` takes all the same arguments as `tinify()` except `file` and `key`.

Any arguments set in `tinify_defaults()` will apply to all subsequent calls of `tinify()`:

``` r
tinify("example.png")

#> Filesize reduced by 50%:
#> example.png (20K) => example_tiny.png (10K)
#> 13 Tinify API calls this month

tinify_defaults(suffix = "_small")

tinify("example2.png")

#> Filesize reduced by 50%:
#> example2.png (20K) => example2_small.png (10K)
#> 14 Tinify API calls this month
```

Any set defaults can be overruled on a case-by-case basis by supplying the argument again when calling `tinify()`:

``` r

tinify_defaults(suffix = "_small")

tinify("example2.png", suffix = "_shrunk")

#> Filesize reduced by 50%:
#> example2.png (20K) => example2_shrunk.png (10K)
#> 15 Tinify API calls this month

tinify("example3.png")

#> Filesize reduced by 50%:
#> example2.png (20K) => example2_small.png (10K)
#> 16 Tinify API calls this month
```

To reset any argument back to the package default, use `tinify_defaults()` with the argument set to `NULL`:

``` r
tinify("example.png")

#> Filesize reduced by 50%:
#> example.png (20K) => example_tiny.png (10K)
#> 17 Tinify API calls this month

tinify_defaults(quiet = TRUE)

tinify("example2.png")

tinify_defaults(quiet = NULL)

tinify("example3.png")

#> Filesize reduced by 50%:
#> example3.png (20K) => example3_tiny.png (10K)
#> 19 Tinify API calls this month
```

## Further examples

You can combine any number of the above arguments:

``` r
tinify("example.png", overwrite = TRUE, quiet = TRUE, return_path = "abs")
```

Tinify also works nicely with the pipe:

``` r
img <- "example.png"

img %>% tinify()
```

And with purrr::map for multiple files:

``` r
imgs <- c("example.png", "example2.png")

purrr::map(imgs, ~tinify(.x))
```

Below is an example method for shrinking an entire directory:

``` r
imgs_dir <- fs::dir_ls("imgs", glob = "*.png")

purrr::map(imgs_dir, ~tinify(.x, overwrite = TRUE, quiet = TRUE))
```

## Command Line Usage

If you just want to quickly shrink an image in a directory, you can always just call `tinify()` from the command line. Just make sure **tinieR** is installed as a global package to your R install, then at the command line run:

```r
R -e "tinieR::tinify('example.png')"
```

For this to work, you will need to ensure your TinyPNG.com API key is in your global .Renviron file, as detailed above, or else provide it explicitly at runtime with `tinieR::tinify('example.png', key = 'YOUR_API_KEY')`.
