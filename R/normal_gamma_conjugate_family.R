#' Title Univariate normal distribution with normal-gamma conjugate distribution
#'
#' @param sample_size How many samples to produce.
#' @param mu_0 The mean of normal distribution of theta given sigma squared.
#' @param sigma_0_sequare Sample variance.
#' @param kappa_0 The number of prior observations.
#' @param nu_0 The number of samples of prior observations.
#' @param y.1 Data set number 1.
#' @param y.2 Data set number 2.
#' @param y.3 Data set number 3.
#' @param confidence_interval Confidence interval to be calculated.
#'
#' @return The comparison of three data sets.
#' @export
#'
#' @examples 
#' normal_gamma_conjugate_family(sample_size = 10000, mu_0 = 5, sigma_0_sequare = 4, 
#' kappa_0 = 1, nu_0 = 2, y.1 = school1, 
#' y.2 = school2, y.3 = school3, confidence_interval = c(0.025, 0.975))
normal_gamma_conjugate_family <- function(sample_size, mu_0, sigma_0_sequare, kappa_0, nu_0, y.1, y.2 = NULL, y.3 = NULL, confidence_interval = c(0.025, 0.975)) {

	if(sample_size %% 1 != 0 || sample_size <= 0) {
		stop("Error: sample size should be positive integer!")
	}

	if(!vector_check(mu_0, 1) || !vector_check(sigma_0_sequare, 1) || !vector_check(kappa_0, 1) || !vector_check(nu_0, 1)) {
		stop("Error: only single numerical values allowed for the parameters.")
	}
	if(!is.null(y.2) && !vector_check(y.2) && !vector_check(y.2, 1)) {
		stop("Error: y.2 should be a vector!")
	}
	if(!is.null(y.3) && !vector_check(y.3) && !vector_check(y.3, 1)) {
		stop("Error: y.3 should be a vector!")
	}
	if(!vector_check(confidence_interval, 2) || confidence_interval[1] >= confidence_interval[2] || confidence_interval[1] < 0 || confidence_interval[2] > 1) {
			stop("Error: Confidence interval is not a valid pair of percentages.")
	}

	# The mean of the first group of data
	y_bar.1 <- mean(y.1)
	# The variance of the first group of data
	y_var.1 <- stats::var(y.1)
	# The standard deviation of the first group of data
	y_sd.1 <- stats::sd(y.1)
	# The number of data in y.1
	length.1 <- length(y.1)
	# Compute kappa_n
	kappa_n.1 <- kappa_0 + length.1
	# Compute mu_n
	mu_n.1 <- (kappa_0 * mu_0 + length.1 * y_bar.1) / kappa_n.1
	# Compute nu_n
	nu_n.1 <- nu_0 + length.1
	# Compute sigma_n^2
	sigma_n_square.1 <- (1 / nu_n.1) * (nu_0 * sigma_0_sequare + (length.1 - 1) * y_var.1 + ((kappa_0 * length.1) / kappa_n.1) * (y_bar.1 - mu_0)^2)
	# sampling from the posterior distribution
	sigma_square_inverse.1 <- stats::rgamma(sample_size, nu_n.1 / 2, nu_n.1*sigma_n_square.1 / 2)
	sigma_square.1 <- 1 / sigma_square_inverse.1
	theta.1 <- stats::rnorm(sample_size, mu_n.1, sqrt(sigma_square.1 / kappa_n.1))

	# Mean of the posterior inference of theta
	theta_bar.1 <- mean(theta.1)
	confidence_interval_theta.1 <- stats::quantile(theta.1, confidence_interval)

	# Mean of the posterior inference of sigma
	sigma_bar.1 <- mean(sqrt(sigma_square.1))
	confidence_interval_sigma_bar.1 <- stats::quantile(sqrt(sigma_square.1), confidence_interval)
	# MCMC for posterior predictive
	y_tilde.1 <- stats::rnorm(sample_size, theta.1, sqrt(sigma_square.1))

	if(is.null(y.2)) {
		return(list(theta_bar.1 = theta_bar.1, confidence_interval_theta.1 = confidence_interval_theta.1, sigma_bar.1 = sigma_bar.1, confidence_interval_sigma_bar.1 = confidence_interval_sigma_bar.1, y_tilde.1 = y_tilde.1))
	}

	# The mean of the second group of data
	y_bar.2 <- mean(y.2)
	# The variance of the second group of data
	y_var.2 <- stats::var(y.2)
	# The standard deviation of the second group of data
	y_sd.2 <- stats::sd(y.2)
	# The number of data in y.2
	length.2 <- length(y.2)
	# Compute kappa_n
	kappa_n.2 <- kappa_0 + length.2
	# Compute mu_n
	mu_n.2 <- (kappa_0 * mu_0 + length.2 * y_bar.2) / kappa_n.2
	# Compute nu_n
	nu_n.2 <- nu_0 + length.2
	# Compute sigma_n^2
	sigma_n_square.2 <- (1 / nu_n.2) * (nu_0 * sigma_0_sequare + (length.2 - 1) * y_var.2 + ((kappa_0 * length.2) / kappa_n.2) * (y_bar.2 - mu_0)^2)
	# sampling from the posterior distribution
	sigma_square_inverse.2 <- stats::rgamma(sample_size, nu_n.2 / 2, nu_n.2*sigma_n_square.2 / 2)
	sigma_square.2 <- 1 / sigma_square_inverse.2
	theta.2 <- stats::rnorm(sample_size, mu_n.2, sqrt(sigma_square.2 / kappa_n.2))

	# Mean of the posterior inference of theta
	theta_bar.2 <- mean(theta.2)
	confidence_interval_theta.2 <- stats::quantile(theta.2, confidence_interval)

	# Mean of the posterior inference of sigma
	sigma_bar.2 <- mean(sqrt(sigma_square.2))
	confidence_interval_sigma_bar.2 <- stats::quantile(sqrt(sigma_square.2), confidence_interval)
	# MCMC for posterior predictive
	y_tilde.2 <- stats::rnorm(sample_size, theta.2, sqrt(sigma_square.2))

	if(is.null(y.3)) {
		return(list(inference.1 = list(theta_bar.1 = theta_bar.1, confidence_interval_theta.1 = confidence_interval_theta.1, sigma_bar.1 = sigma_bar.1, confidence_interval_sigma_bar.1 = confidence_interval_sigma_bar.1, y_tilde.1 = y_tilde.1), inference.2 = list(theta_bar.2 = theta_bar.2, confidence_interval_theta.2 = confidence_interval_theta.2, sigma_bar.2 = sigma_bar.2, confidence_interval_sigma_bar.2 = confidence_interval_sigma_bar.2, y_tilde.2 = y_tilde.2)))
	}

	# The mean of the third group of data
	y_bar.3 <- mean(y.3)
	# The variance of the third group of data
	y_var.3 <- stats::var(y.3)
	# The standard deviation of the third group of data
	y_sd.3 <- stats::sd(y.3)
	# The number of data in y.3
	length.3 <- length(y.3)
	# Compute kappa_n
	kappa_n.3 <- kappa_0 + length.3
	# Compute mu_n
	mu_n.3 <- (kappa_0 * mu_0 + length.3 * y_bar.3) / kappa_n.3
	# Compute nu_n
	nu_n.3 <- nu_0 + length.3
	# Compute sigma_n^2
	sigma_n_square.3 <- (1 / nu_n.3) * (nu_0 * sigma_0_sequare + (length.3 - 1) * y_var.3 + ((kappa_0 * length.3) / kappa_n.3) * (y_bar.3 - mu_0)^2)
	# sampling from the posterior distribution
	sigma_square_inverse.3 <- stats::rgamma(sample_size, nu_n.3 / 2, nu_n.3*sigma_n_square.3 / 2)
	sigma_square.3 <- 1 / sigma_square_inverse.3
	theta.3 <- stats::rnorm(sample_size, mu_n.3, sqrt(sigma_square.3 / kappa_n.3))

	# Mean of the posterior inference of theta
	theta_bar.3 <- mean(theta.3)
	confidence_interval_theta.3 <- stats::quantile(theta.3, confidence_interval)

	# Mean of the posterior inference of sigma
	sigma_bar.3 <- mean(sqrt(sigma_square.3))
	confidence_interval_sigma_bar.3 <- stats::quantile(sqrt(sigma_square.3), confidence_interval)
	# MCMC for posterior predictive
	y_tilde.3 <- stats::rnorm(sample_size, theta.3, sqrt(sigma_square.3))

	theta_smaller.1.2.3 <- mean(theta.1 < theta.2 & theta.2 < theta.3)
	theta_smaller.1.3.2 <- mean(theta.1 < theta.3 & theta.3 < theta.2)
	theta_smaller.2.1.3 <- mean(theta.2 < theta.1 & theta.1 < theta.3)
	theta_smaller.2.3.1 <- mean(theta.2 < theta.3 & theta.3 < theta.1)
	theta_smaller.3.1.2 <- mean(theta.3 < theta.1 & theta.1 < theta.2)
	theta_smaller.3.2.1 <- mean(theta.3 < theta.2 & theta.2 < theta.1)

	y_tilde_smaller.1.2.3 <- mean(y_tilde.1 < y_tilde.2 & y_tilde.2 < y_tilde.3)
	y_tilde_smaller.1.3.2 <- mean(y_tilde.1 < y_tilde.3 & y_tilde.3 < y_tilde.2)
	y_tilde_smaller.2.1.3 <- mean(y_tilde.2 < y_tilde.1 & y_tilde.1 < y_tilde.3)
	y_tilde_smaller.2.3.1 <- mean(y_tilde.2 < y_tilde.3 & y_tilde.3 < y_tilde.1)
	y_tilde_smaller.3.1.2 <- mean(y_tilde.3 < y_tilde.1 & y_tilde.1 < y_tilde.2)
	y_tilde_smaller.3.2.1 <- mean(y_tilde.3 < y_tilde.2 & y_tilde.2 < y_tilde.1)


	theta_biggest.1 <- mean(theta.1 > theta.2 & theta.1 > theta.3)
	y_tilde_biggest.1 <- mean(y_tilde.1 > y_tilde.2 & y_tilde.1 > y_tilde.3)

	return(list(inference.1 = list(theta_bar.1 = theta_bar.1, confidence_interval_theta.1 = confidence_interval_theta.1, sigma_bar.1 = sigma_bar.1, confidence_interval_sigma_bar.1 = confidence_interval_sigma_bar.1, y_tilde.1 = y_tilde.1), inference.2 = list(theta_bar.2 = theta_bar.2, confidence_interval_theta.2 = confidence_interval_theta.2, sigma_bar.2 = sigma_bar.2, confidence_interval_sigma_bar.2 = confidence_interval_sigma_bar.2, y_tilde.2 = y_tilde.2), inference.3 = list(theta_bar.3 = theta_bar.3, confidence_interval_theta.3 = confidence_interval_theta.3, sigma_bar.3 = sigma_bar.3, confidence_interval_sigma_bar.3 = confidence_interval_sigma_bar.3, y_tilde.3 = y_tilde.3), theta_smaller.1.2.3 = theta_smaller.1.2.3, theta_smaller.1.3.2 = theta_smaller.1.3.2, theta_smaller.2.1.3 = theta_smaller.2.1.3, theta_smaller.2.3.1 = theta_smaller.2.3.1, theta_smaller.3.1.2 = theta_smaller.3.1.2, theta_smaller.3.2.1 = theta_smaller.3.2.1, y_tilde_smaller.1.2.3 = y_tilde_smaller.1.2.3, y_tilde_smaller.1.3.2 = y_tilde_smaller.1.3.2, y_tilde_smaller.2.1.3 = y_tilde_smaller.2.1.3, y_tilde_smaller.2.3.1 = y_tilde_smaller.2.3.1, y_tilde_smaller.3.1.2 = y_tilde_smaller.3.1.2, y_tilde_smaller.3.2.1 = y_tilde_smaller.3.2.1, theta_biggest.1 = theta_biggest.1, y_tilde_biggest.1 = y_tilde_biggest.1))

}