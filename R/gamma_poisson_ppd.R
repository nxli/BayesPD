#' Title Poisson model of parameter theta, given gamma prior and the data. Sampling the posterior predictive distribution.
#'
#' @param sample_size How many samples to produce.
#' @param gamma_a1 First parameter of theta1.
#' @param gamma_b1 Second parameter of theta1.
#' @param y1 Given data of the Possion distribution with gamma prior for the parameter theta1.
#' @param gamma_a2 First parameter of theta2.
#' @param gamma_b2 Second parameter of theta2.
#' @param y2 Given data of the Possion distribution with gamma prior for the parameter theta2.
#' @param confidence_interval Confidence interval to be calculated.
#' @param using_MCMC Whether to use MCMC to sampling the posterior predictive distribution.
#' @param poisson_fitting_mean Some given parameter for Poisson distribution to be tested.
#'
#' @return Sampling of the posterior predictive distribution.
#' @export
#'
#' @examples 
#' gamma_poisson_ppd(sample_size = 5000, gamma_a1 = 2, gamma_b1 = 1, 
#' y1 = menchild30bach, gamma_a2 = 2, gamma_b2 = 1, 
#' y2 = menchild30nobach, using_MCMC = FALSE)
#'
#' gamma_poisson_ppd(sample_size = 5000, gamma_a1 = 2, gamma_b1 = 1, 
#' y1 = menchild30bach, gamma_a2 = 2, gamma_b2 = 1, 
#' y2 = menchild30nobach, using_MCMC = TRUE)
#' 
#' gamma_poisson_ppd(sample_size = 5000, gamma_a1 = 2, gamma_b1 = 1, 
#' y1 = menchild30bach, gamma_a2 = 2, gamma_b2 = 1, 
#' y2 = menchild30nobach, confidence_interval = c(0.025, 0.975), 
#' using_MCMC = FALSE, poisson_fitting_mean = 1.4)
gamma_poisson_ppd <- function(sample_size, gamma_a1, gamma_b1, y1, gamma_a2, gamma_b2, y2, confidence_interval = NULL, using_MCMC = FALSE, poisson_fitting_mean = NULL) {

	if(sample_size %% 1 != 0 || sample_size <= 0) {
		stop("Error: sample size should be positive integer!")
	}
	if(!vector_check(gamma_a1, 1) || !vector_check(gamma_b1, 1) || !vector_check(gamma_a2, 1) || !vector_check(gamma_b2, 1)) {
		stop("Error: only single numerical values allowed for the parameters of gamma_1 and gamma_2.")
	}
	if(!vector_check(y1) && !vector_check(y1, 1)) {
		stop("Error: y1 should be a vector!")
	}
	if(!vector_check(y2) && !vector_check(y2, 1)) {
		stop("Error: y2 should be a vector!")
	}

	n1 <- length(y1)
	n2 <- length(y2)

	if(using_MCMC) {
		# Sampling from the prior distribution.
		theta1 <- stats::rgamma(sample_size, gamma_a1, gamma_b1)
		# MCMC of the posterior predictive of Poisson distribution
		y_tilde1 <- stats::rpois(sample_size, theta1)
		# Sampling from the prior distribution.
		theta2 <- stats::rgamma(sample_size, gamma_a2, gamma_b2)
		# MCMC of the posterior predictive of Poisson distribution
		y_tilde2 <- stats::rpois(sample_size, theta2)
	} else {
		# Since the posterior predictive distribution of a Poisson model with Gamma prior is Negative Binomial distribution, only need to compute the two parameters of the Negative Binomial distribution.
		
		p1 <- (gamma_b1 + n1) / (gamma_b1 + n1 + 1)
		p2 <- (gamma_b2 + n2) / (gamma_b2 + n2 + 1)
		# Sampling from the Negative Binomial posterior predictive distribution.
		y_tilde1 <- stats::rnbinom(sample_size, sum(y1) + gamma_a1, p1)
		y_tilde2 <- stats::rnbinom(sample_size, sum(y2) + gamma_a2, p2)
	}

	graphics::plot(table(y_tilde1), type = "h", lwd = 1, main = "y_tilde1")
	graphics::plot(table(y_tilde2), type = "h", lwd = 1, main = "y_tilde2")

	# Parameter theta in a Poisson model given Gamma prior is again Gamma distribution.
	theta1_posterior <- stats::rgamma(sample_size, sum(y1) + gamma_a1, n1 + gamma_b1)
	theta2_posterior <- stats::rgamma(sample_size, sum(y2) + gamma_a2, n2 + gamma_b2)
	
	if(!is.null(poisson_fitting_mean)) {
		# Given Poisson fitting mean then show that if it is a good fit for data group 1.
		graphics::plot(0:max(y1)+0.2, stats::dpois(0:max(y1), poisson_fitting_mean), type="h", col="red")
		graphics::points(table(y1)/n2)
		# Given Poisson fitting mean then show that if it is a good fit for data group 2.
		graphics::plot(0:max(y2)+0.2, stats::dpois(0:max(y2), poisson_fitting_mean), type="h", col="red")
		graphics::points(table(y2)/n2)
	}

	# sampling data then check 
	zeroes = rep(NA, sample_size)
	ones = rep(NA, sample_size)
	for(i in 1:sample_size) {
		# Per data set sampled, we find the total number of y == 0 and y == 1 then draw the graph of all the samples.
		y = stats::rpois(218, theta2_posterior[i])
		zeroes[i] = sum(y == 0)
		ones[i] = sum(y == 1)
	}
	# Check if the given data is an outlier to see if Poisson model is a proper model to use.
	graphics::plot(zeroes, ones, xlim=c(min(zeroes),max(zeroes)), ylim=c(min(ones),max(ones)), pch='.')
	graphics::points(sum(y2 == 0), sum(y2 == 1), col="red")

	if(!is.null(confidence_interval)) {
		if(!vector_check(confidence_interval, 2) || confidence_interval[1] >= confidence_interval[2] || confidence_interval[1] < 0 || confidence_interval[2] > 1) {
			stop("Error: Confidence interval is not a valid pair of percentages.")
		}
		theta2_minus_theta1_quantile <- stats::quantile(theta2_posterior - theta1_posterior, confidence_interval)
		y_tidle2_minus_ytilde1_quantile <- stats::quantile(y_tilde2 - y_tilde1, confidence_interval)
		return(list(theta2_minus_theta1_quantile = theta2_minus_theta1_quantile, y_tidle2_minus_ytilde1_quantile = y_tidle2_minus_ytilde1_quantile))
	}
	
}

