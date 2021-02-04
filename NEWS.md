## tinieR 0.4.0

* Added ability to set global defaults for `tinify()` arguments with `tinify_defaults()`.
* Added new `suffix` argument in `tinify()` to change the "_tiny" suffix applied to tinified file names.
* Added new `return_path = "proj"` option to `return_path` argument in `tinify()` to return the path to the newly tinified file relative to the project directory, no matter the current working directory.

## tinieR 0.3.0

* Deprecated argument `details` in `tinify()` function. Tinify now displays the details message by default. This behaviour can be suppressed with the new argument `quiet = TRUE`.
* Added a `NEWS.md` file to track changes to the package.
