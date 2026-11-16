rm(list = ls())

global_scale <- 10

scaled_power <- function(x, power = 2, 
                         method = c("simple", "precise"),
                         scale = 10,
                         plot = TRUE,
                         ...) {
  if (!is.numeric(x)) {
    stop("Input 'x' must be numeric.", call. = FALSE)
  }
  
  method <- match.arg(method)
  
  # Local variables are isolated within the function environment
  pow_res <- x^power
  final_res <- pow_res * scale
  
  if (method == "simple") {
    final_res = round(final_res)
  }
  if (plot) {
    plot(x, final_res, xlab= "Input (x)", ...)
  }
    return(final_res)
}
# scaled_power(x = "three")

# Valid function calls:
scaled_power(x = c(1, 2, 3), power = 0.5, method = "simple")
scaled_power(c(1, 2, 3), power = 3, scale = 5)
scaled_power(c(1, 2, 3), power = 3, scale = 5, pch = 18, cex = 2)
scaled_power(c(1, 2, 3), power = 3, scale = 5, pch = 18, cex = 2, xlab = "My x")

res <- scaled_power(
  x = seq(-3, 3, by = 0.5), 
  power = 2, 
  scale = 5, 
  method = "precise",
  col = "firebrick", 
  pch = 19, 
  type = "b"
)