#' compare_pomdp
#'
#' Compare the pomdp solution to historical data
#' @inheritParams sarsop
#' @inheritParams compute_policy
#' @param obs a given sequence of observations
#' @param action the corresponding sequence of actions
#' @return a list, containing: a data frame with columns for time, obs, action, and optimal action,
#' and an array containing the posterior belief distribution at each time t
#' @export
#' @examples
#' \dontrun{ ## Takes > 5s
#' ## Use example code to generate matrices for pomdp problem:
#' source(system.file("examples/fisheries-ex.R", package = "appl"))
#' alpha <- sarsop(transition, observation, reward, discount, precision = 10)
#' sim <- compare_pomdp(transition, observation, reward, discount,
#'                      obs = rnorm(21, 15, .1), action = rep(1, 21),
#'                      alpha = alpha)

#'
#' }
#'
compare_pomdp <- function(transition, observation, reward, discount, obs, action,
                      state_prior = rep(1, dim(observation)[[1]]) / dim(observation)[[1]],
                      alpha = NULL, ...){

    Tmax <- length(obs)
    n_states <- dim(observation)[1]
    optimal <- numeric(Tmax)
    optimal[1] <- NA
    state_posterior <- array(NA, dim = c(Tmax, n_states))
    if(is.null(state_prior))  state_prior <- rep(1, n_states) / n_states
    state_posterior[1,] <- state_prior

    for(t in 2:Tmax){
      out <- compute_policy(alpha, transition, observation, reward, state_posterior[t-1,], action[t-1])
      optimal[t] <- out$policy[obs[t]]
      state_posterior[t,] <- update_belief(state_posterior[t-1,], transition, observation, obs[t], action[t-1])
    }

    list(df = data.frame(time = 1:Tmax, obs, action, optimal),
         state_posterior = as.data.frame(state_posterior))
  }


  update_belief <- function(state_prior, transition, observation, z0, a0){
    belief <-
      vapply(1:length(state_prior), function(i){
            state_prior %*% transition[, i, a0] * observation[i, z0, a0]
      }, numeric(1))
    belief / sum(belief)
  }


