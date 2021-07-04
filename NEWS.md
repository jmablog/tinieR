## tinieR 0.4.4

* Now uses the [cli](https://cli.r-lib.org/) package to provide nicer console messages.
* Updated internals.
* Can no longer just set any option in `tinify_defaults()` to `NULL` to reset to package defaults as this could be unclear. See the vignette ["Setting default options"](https://jmablog.github.io/tinieR/articles/setting-defaults.html) for full details on changing and resetting default options with `tinify_defaults()`.

## tinieR 0.4.3

* Added ability to set project defaults with a `tinify.yml` file in the project root directory.
* Image dimensions are now reported in success message when `resize` argument is used.

## tinieR 0.4.2

* Updated names of options set by `tinify_defaults()` to match convention (e.g. `tinify_overwrite` -> `tinify.overwrite`).
* Now removes all options set by `tinify_defaults()` on unloading of package.
* Fixed some file path errors in `return_path` that should work better across all platforms.

## tinieR 0.4.1

* Modified behaviour of `tinify_defaults()`: now prints changes made to the console, and if called without any arguments, prints all current default settings.
* Moved bulk of Readme into vignette (["Full walkthrough"](https://jmablog.github.io/tinieR/articles/tinieR.html)).

## tinieR 0.4.0

* Added ability to set global defaults for `tinify()` arguments with `tinify_defaults()`.
* Added new `suffix` argument in `tinify()` to change the "_tiny" suffix applied to tinified file names.
* Added new `return_path = "proj"` option to `return_path` argument in `tinify()` to return the path to the newly tinified file relative to the project directory, no matter the current working directory.

## tinieR 0.3.0

* Deprecated argument `details` in `tinify()` function. Tinify now displays the details message by default. This behaviour can be suppressed with the new argument `quiet = TRUE`.
* Added a `NEWS.md` file to track changes to the package.
