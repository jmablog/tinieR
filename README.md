
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
devtools::install_github("jmablog/tinier")
```

## Authentication with TinyPNG.com

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

## Shrinking An Image

To shrink an image file's size, provide a path to the file relative to the current working directory:

``` r
tinify("example.png")
```

By default, `tinify` will create a new file with the suffix '_tiny' in the same directory as the original file. To instead overwrite the original file with the newly shrunk file, use `overwrite = TRUE`:

``` r
tinify("example.png", overwrite = TRUE)
```

## Using The Shrunk Image

Tinify can also return the absolute file path to the newly shrunk file, as a string, with `return_path = TRUE`. This can be passed in to another function that takes an image file path to automate shrinking filesizes when, for example, knitting a document:

``` r
shrunk_img <- tinify("imgs/example.png", return_path = TRUE)

knitr::include_graphics(shrunk_img)
```

## TinyPNG API Monthly Allowance and Other Details

TinyPNG is quite generous at 500 free images per month, but if you're using `tinify()` as part a script that may be run multiple times, you should be aware of your API usage. Fortunately TinyPNG is smart enough to know when you are uploading the same file over again, and so will not count repeat calls of `tinify()` on the **exact same** image file against your monthly API usage limit. This is handy if you are using `tinify()` in an RMarkdown document as it won't count against your API usage every time you knit your document. However be careful if saving new images to file from other workflows, such as creating plots, as changes to these will most likely count as new files when uploaded to TinyPNG.

You can check your API usage, as well as see how much the file size has changed, with `details = TRUE`:

``` r
tinify("example.png", details = TRUE)

> Filesize reduced by 50%:
> example.png (20Kb) => example_tiny.png (10Kb)
> 10 Tinify API calls this month
```

## Further Examples

You can combine any number of the above arguments:

``` r
tinify("example.png", overwrite = TRUE, details = TRUE, return_path = TRUE)
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

purrr::map(imgs_dir, ~tinify(.x, overwrite = TRUE))
```

## Future Plans

- Include other [TinyPNG](https://tinypng.com) API image editing functions, like image resizing and retaining metadata.
- Add ability to provide a desired file path for the newly shrunk file, instead of defaulting to the same location as the input file.
- Add ability to use URL for a web resource instead of a local file.
