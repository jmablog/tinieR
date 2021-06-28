
# tinieR

<!-- badges: start -->
  [![R build status](https://github.com/jmablog/tinieR/workflows/R-CMD-check/badge.svg)](https://github.com/jmablog/tinieR/actions)
[![codecov](https://codecov.io/gh/jmablog/tinieR/branch/master/graph/badge.svg)](https://codecov.io/gh/jmablog/tinieR)
  <!-- badges: end -->

Shrink image filesizes with the [TinyPNG](https://tinypng.com) API.

From the TinyPNG website: "TinyPNG uses smart lossy compression techniques to reduce the file size of your files. By selectively decreasing the number of colors in the image, fewer bytes are required to store the data. The effect is nearly invisible but it makes a very large difference in file size!"

Original: | Tinified:
--- | ---
![](man/figures/example.png) | ![](man/figures/example_tiny.png)
example.png: **17 Kb** | example_tiny.png: **6 Kb**

TinieR works with .png and .jpg/.jpeg files, and can return the new image filepath to enable embedding in other image workflows/functions.

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
library(tinieR)

tinify_key("YOUR-API-KEY-HERE")
```

Be careful including your API key in any scripts you write, especially if you're going to be publicly or privately sharing those scripts with others! You might consider setting your API key instead in your [.Renviron file](https://support.rstudio.com/hc/en-us/articles/360047157094-Managing-R-with-Rprofile-Renviron-Rprofile-site-Renviron-site-rsession-conf-and-repos-conf) (~/.Renviron). If you use the variable name `TINY_API` in .Renviron, `tinify()` should find it, and you can skip using `tinify_api()` or providing an API at each call of `tinify()`.

## Basic use

To shrink an image file's size, provide a path to the file relative to the current working directory to `tinify()`:

``` r
tinify("example.png")

#> Filesize reduced by 50%:
#> example.png (20K) => example_tiny.png (10K)
#> 10 Tinify API calls this month
```

By default, `tinify()` will create a new file with the suffix '_tiny' in the same directory as the original file.

## Advanced use

For details on all the options **tinieR** provides, [see the "full walkthrough" vignette here](https://jmablog.github.io/tinieR/articles/tinieR.html).

To set default options for use with `tinify()`, see the ["setting default options"](https://jmablog.github.io/tinieR/articles/setting-defaults.html) vignette.
