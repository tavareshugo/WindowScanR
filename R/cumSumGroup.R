#' Cumulative sum across groups
#'
#' @param x vector of numeric values.
#' @param group vector of grouping variable.
#'
#' @return A numeric vector.
#' @export
#' @rdname cumSumGroup
#'
#' @examples
#' ### Some example data ###
#' group <- factor(rep(c("A", "B", "C"), each = 10))
#' position <- c(1:10, 1:10, 51:60)
#' values <- rep(1, 30)
#' 
#' ### Plot with original positions ###
#' # Groups "A" and "B" overlap
#' plot(position, values, col = group)
#' 
#' ### Plot with cumsum ###
#' # Notice how the points strech in distance
#' # That's because we keep calculating the
#' # cumulative sum within groups
#' plot(cumsum(position), values, col = group)
#' 
#' ### Plot with cumSumGroup ###
#' # Now, on the x-axis, the points are separated 
#' # by 1 unit WITHIN groups. But cumulatively
#' # ACROSS groups
#' plot(cumSumGroup(group, position), values, col = group)
cumSumGroup = function(x, group){
	
	# Convert variables to correct classes
	group = as.character(group)
	x = as.numeric(x)
	
	# Empty vector for output
	x2 = c()
	
	# Initialise variable to store current maximum
	max = 0
	
	for(i in unique(group)){
		group_position = x[which(group==i)] # extract positions of this group
		x2 = c(x2, group_position + max)  # add the maximum so far
		max = max(x2)  # change maximum
	}
	
	return(x2)
}
