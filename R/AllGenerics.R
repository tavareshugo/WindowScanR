#' Apply several functions in a sliding window
#' 
#' \code{winScan()} applies a list of functions to each of a list of variables, using
#' a sliding window approach. This can be a "rolling" window or a "position" window (see details).
#' If required, the windows can be defined independently for one or more grouping variables.
#'
#' @param x a data.frame object on which to calculate window statistics.
#' @param ... other arguments passed to specific methods.
#'
#' @return a data.frame of window-computed statistics.
#' @rdname winScan
#' @examples
#' ... to be filled in
setGeneric("winScan", function(x, ...) standardGeneric("winScan"))


# Set old class for tbl_df
## see http://stackoverflow.com/questions/35642191/tbl-df-with-s4-object-slots
setOldClass(c("tbl_df", "tbl", "data.frame"))
