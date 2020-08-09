
# tinieR


Shrink image filesizes with the [TinyPNG](https://tinypng.com) API. Works with .png and .jpg/.jpeg files, and can return the new image filepath to enable embedding in other image workflows/functions.

## Installation

You can install the latest version of tinieR from [Github](https://github.com) with:

``` r
devtools::install_github("jmablog/tinieR")
```

## Authentication with TinyPNG.com

You will need an API key from [TinyPNG](https://tinypng.com). You can [signup to get one here](https://tinypng.com/developers).

Once you have your API key, you can set it for your current R session with:

``` r
library(tinieR)

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

## Usage

To shrink an image, provide a path to the file relative to the current working directory:

``` r
tinify("example.png")
```

By default, `tinify` will create a new file with the suffix '_tiny' in the same directory as the original file (e.g. "example_tiny.png" using the above example).

To instead overwrite the original file with the new smaller file, use `overwrite = TRUE`:

``` r
tinify("example.png", overwrite = TRUE)
```

Tinify can also return the absolute file path to the newly shrunk file, as a string, with `return_path = TRUE`. This can be passed in to another function that takes an image file path to automate shrinking filesizes when, for example, knitting a document:

``` r
shrunk_img <- tinify("imgs/example.png", return_path = TRUE)

knitr::include_graphics(shrunk_img)
```

TinyPNG is smart enough to know when you are uploading the same file again, and so will not count repeat calls of `tinify()` on the same image file against your monthly API usage limit. This is handy if you are using `tinify()` in an RMarkdown document as it won't count against your API usage every time you knit your document.

You can check your API usage, as well as see how much the file size has changed, with `details = TRUE`:

``` r
tinify("example.png", details = TRUE)

> Filesize reduced by 50%:
> example.png (20Kb) => example_tiny.png (10Kb)
> 10 Tinify API calls this month
```

You can combine any number of the above:

``` r
tinify("example.png", overwrite = TRUE, details = TRUE, return_path = TRUE)
```

Tinify also plays nice with the pipe:

``` r
img <- "example.png"

img %>% tinify()
```

And with purrr::map for multiple files:

``` r
imgs <- c("example.png", "example2.png")

purrr::map(imgs, ~tinify(.x))
```

An example method for shrinking an entire directory:

``` r
imgs_dir <- fs::dir_ls("imgs", glob = "*.png")

purrr::map(imgs_dir, ~tinify(.x, overwrite = TRUE))
```
