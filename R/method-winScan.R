#' @param x data.frame on which to calculate window statistics.
#' @param groups vector with the name of variables on which to group the data.frame. 
#' It can be set to NULL, if there are no groups. Default: NULL
#' @param position name of variable which contains the positions on which to calculate the windows. 
#' If set to NULL, a "rolling" window will be computed instead. Default: NULL
#' @param values vector of variables on which to calculate statistics. 
#' @param win_size size of the window.
#' @param win_step step of the window. Default: 0.5*win_size.
#' @param funs vector of functions to compute for each window. Default: "mean".
#' @param cores number of processing cores.
#'
#' @export
#' @docType methods
#' @rdname winScan
#'
#' @details 
#' A "rolling" window is based on consecutive rows in the \code{data.frame}. For example, if
#' `win_size = 10` and `win_step = 5`, then, on a data.frame with 100 rows there will be
#' 20 windows, each containing 10 rows of the data.frame.
#' A "position" window is based on a variable containing positions.
#'
#' @examples
#' ... to be added
setMethod("winScan", "data.frame", function(x, 
																						groups = NULL, 
																						position = NULL, 
																						values, 
																						win_size, 
																						win_step = 0.5*win_size, 
																						funs = "mean",
																						cores = 1){
	### Parse requested functions to a list ###
	funs <- as.list(funs)
	names(funs) <- sapply(funs, paste)  # name functions' list elements
	
	### Check group and position variables ###
	if(is.null(groups)){
		# Create mock group variable
		x$group <- 1
		groups <- "group"
	}
	
	if(is.null(position)){
		# Create mock position variable
		x <- x %>% group_by_(.dots = groups) %>% mutate(pos = 1:n())
	} else {
		# Rename position variable for downstream functions
		x <- rename_(x, "pos" = position)
		assertthat::assert_that(is.numeric(x$pos))
	}
	
	### Compute window statistics per group ###
	out = x %>% group_by_(.dots = groups) %>% 
		do(.winSlider(., values, win_size, win_step, funs, cores)) %>%
		as.data.frame()
	
	return(out)
	
})



#' \code{.winSlider()} is an internal function called by \code{winScan()}. 
#' It creates sliding window coordinates and applies a list of 
#' functions to each window.
#'
#' @inheritParams winScan
#' 
#' @export
#' 
#' @rdname winScan
.winSlider <- function (x, values, win_size, win_step, funs, cores) 
{
	
	### Define window start ###
	win_start <- seq(0, max(x$pos), win_step)
	
	# Remove the last value, so that last window 
	# is before the end of the positions
	win_start <- win_start[-length(win_start)]
	
	### Loop through windows ###
	funs_out <- parallel::mclapply(win_start, .winStats, win_size, funs, values, x, mc.cores = cores)
	funs_out <- do.call(rbind, funs_out)
	
	### Make output data.frame ###
	out <- data.frame(win_start = win_start, win_end = win_start + win_size)
	out$win_mid <- floor((out$win_start + out$win_end)/2)
	out <- cbind(out, funs_out)
	
	names(out)[4:ncol(out)] <- as.vector(t(outer(values, c("n", funs), paste, sep="_")))
	
	return(out)
}


#' \code{.winStats()} is an internal function called by \code{mclapply()}
#' in \code{.winSlide()}.
#'
#' @inheritParams winScan
#'
#' @export
#'
#' @rdname winScan
.winStats <- function(win_start, win_size, funs, values, x){
	
	# subset window data
	x_win <- x %>% filter(pos > win_start & pos <= (win_start+win_size)) %>%
		as.data.frame()
	
	# Vector to hold window stats
	win_stats <- c()
	
	# Calculate statistics for each "values" column
	for(i_col in values){
		n <- sum(!is.na(x_win[, i_col]))
		
		custom_stats <- sapply(funs, function(f, x) eval(parse(text = f))(x), x = x_win[, i_col])
		
		# Return error if functions did not return a single value
		if(is.list(custom_stats)) stop("custom statistics did not return single value")
		
		win_stats <- c(win_stats, n, custom_stats)
	}
	
	return(win_stats)
	
}
