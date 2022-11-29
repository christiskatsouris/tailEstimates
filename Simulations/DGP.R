###########################################
# R Script Details:
###########################################

# Script name: DGP.R

# Program aim: This R program simulates the data generating process of the predictive regression system.   

# written by: 

# Christis G. Katsouris (December 2020)
# Department of Economics
# University of Southampton
# Southampton, United Kingdom

# This program reproduces the simulation study reported in the paper: 
# "Optimal Portfolio Choice and Stock Centrality for Tail Risk Events" by Christis G. Katsouris

############################################################################
############################################################################

library(quantreg)
library(Matrix)
library(matlib)
library(GA)
library(igraph)
library(nnet)
library(mvtnorm)

library(vars)

library(parallel)
library(doParallel)
library(MASS)
library(foreach)

###############################################################

options(digits=12) 
no_cores=4
cl = makeCluster(no_cores)       

registerDoParallel(cores=4)

###############################################################

source("Risk_Matrix_forecast_function.R")
source("VaR_DCoVar_forecast_function.R")
source("optimal_weights_function_GA.R")
source("optimal_number_of_assets_function_GA_most_central.R")
source("optimal_number_of_assets_function_GA_less_central.R")

###############################################################################
# FUNCTION: Bootstrapping the predictive regression model ##########
###############################################################################

bootstrap_data_function <- function( Nr_C = Nr_C, time = time, returns=returns, macro=macro  )
{# begin of function 
  
  Nr_C    <- Nr_C
  time    <- time
  returns <- as.matrix(returns)
  macro   <- as.matrix(macro) 
  
  ### Step 1: Run OLS predictive regressions to obtain the model coefficients
  
  nr <- NROW(returns)
  p  <- ncol(macro)
  
  returns.t <- as.matrix( returns[2:nr, ] )
  macro.t   <- as.matrix( macro[2:nr, ] )
  macro.lag <- as.matrix( macro[1:(nr-1), ] )
  
  ##############################################
  ### Step 1A: Fit a VAR(1) model for the autoregressive model
  ##############################################
  
  coefficients.xt.model.matrix <- matrix( 0, nrow = ncol(macro) , ncol = ncol(macro) )
  intercepts.xt.model.matrix   <- matrix( 0, nrow = ncol(macro) , ncol = 1)
  
  VAR_model <- VAR( y = macro, p = 1 )
  B.estimates <- as.matrix( Bcoef(VAR_model) )
  B.matrix    <- as.matrix( B.estimates[ ,1:p ] )
  mu.x.vector <- as.matrix( B.estimates[ ,(p+1)]  )
  
  eigenvalues.B.matrix <- as.matrix( roots(VAR_model) )
  ux.t.hat             <- as.matrix( residuals( VAR_model ) )
  ux.t.hat.centered    <- matrix(0, nrow = nrow(ux.t.hat), ncol = ncol(ux.t.hat) )
  for (j in 1: ncol(ux.t.hat) )
  {
    ux.t.hat.centered[ ,j] <-  ( as.matrix( ux.t.hat[ ,j] ) - mean( as.matrix(ux.t.hat[ ,j])) )
  }
  
  ### Next I construct the bootstrap residuals 
  ux.t.hat.star <- matrix(0, nrow =nrow(ux.t.hat), ncol = ncol(ux.t.hat) )  
  data <- 0
  x    <- 0
  
  for (j in 1: ncol(ux.t.hat) )
  {
    x     <- as.matrix( ux.t.hat.centered[ ,j] )
    nboot <- 10000
    data  <- matrix(sample(x, size = length(x) * nboot, replace = T), nrow = nboot)
    
    for (i in 1:nrow(ux.t.hat) )
    {
      ux.t.hat.star[i,j] <- mean( data[ ,i] )
    }
    data <- 0
    x <- 0
  }
  
  #########################################################################################################
  ### Bias Correction for the coefficient matrix (Reference: Testing for Multiple Horizon Predictability)
  #########################################################################################################
 
  Omega.x.hat <- as.matrix( cov( ux.t.hat ) )
  unit.matrix <- diag( ncol(ux.t.hat) )
  
  term1 <- inv( unit.matrix - t(B.matrix)  )
  term2 <- t(B.matrix)%*%( inv( unit.matrix - t(B.matrix)%*%B.matrix  ) )
  
  term3 <- 0 
  for (j in 1:ncol(ux.t.hat) )
  {
    term3 <- term3 + eigenvalues.B.matrix[j,1]*( inv( unit.matrix - eigenvalues.B.matrix[j,1]*t(B.matrix) ) )
  }
  
  term3 <- as.matrix(term3)
  
  macro.lag.tilde <- matrix( 0, nrow = nrow(macro.lag), ncol= ncol(macro.lag) )
  for (j in 1:ncol(macro.lag) )  
  {
    macro.lag.tilde[ ,j] <- ( as.matrix( macro.lag[ ,j] ) -  mean( macro.lag[ ,j] ) )
  }
  
  term4 <- inv( t( macro.lag.tilde )%*%macro.lag.tilde )
  B.matrix.hat.bc <- as.matrix( B.matrix + Omega.x.hat%*%( term1 + term2 + term3  )%*%term4 )
  
  ##############################################
  ### Step 1B: Fit the predictive regression model 
  ##############################################
  
  model.yt   <- lm( returns.t ~ macro.lag )
  model.coef <- as.matrix( model.yt$coefficients )
  
  beta.coefficients <- as.matrix( model.coef[2:8, ] )
  mu.y.vector       <- as.matrix( model.coef[1, ] )
  uy.t.hat          <- as.matrix( residuals(model.yt) )
  
  uy.t.hat.centered    <- matrix(0, nrow = nrow(uy.t.hat), ncol = ncol(uy.t.hat) )
  for (j in 1: ncol(uy.t.hat) )
  {
    uy.t.hat.centered[ ,j] <-  ( as.matrix( uy.t.hat[ ,j] ) - mean( as.matrix(uy.t.hat[ ,j])) )
  }
  
  ### Next I construct the bootstrap residuals 
  uy.t.hat.star <- matrix(0, nrow =nrow(uy.t.hat), ncol = ncol(uy.t.hat) )  
  data <- 0
  x <- 0
  
  for (j in 1: ncol(uy.t.hat) )
  {
    x     <- as.matrix( uy.t.hat.centered[ ,j] )
    nboot <- 10000
    data  <- matrix(sample(x, size = length(x) * nboot, replace = T), nrow = nboot)
    
    for (i in 1:nrow(uy.t.hat) )
    {
      uy.t.hat.star[i,j] <- mean( data[ ,i] )
    }
    data <- 0
    x <- 0
  }
  
  #####################################################################
  ### Step 2: Generate the bootstrap sample {yt*, xt*, t =1,...,n =313}
  #####################################################################
  
  ##############################################
  # Generate the xt_star series
  ##############################################
  x.t.star      <- matrix( 0, nrow = nrow(macro.lag), ncol = ncol(macro.lag)  )
  x.t.star[1, ] <- ux.t.hat.star[1,]
  
  ones.matrix   <- matrix( 1, nrow = nrow(macro.lag), ncol = ncol(macro.lag) )
  intrecepts.x  <- matrix( 0, nrow = nrow(macro.lag), ncol = ncol(macro.lag) )
  
  # Define the matrix of intercepts
  for (j in 1:ncol(macro.lag) )
  {
    intrecepts.x[, j]  <- as.matrix( ones.matrix[ ,j] )*as.numeric( mu.x.vector[j,1] )
  }
  
  # Define the x.t.star series
  for ( j in 1: ncol(macro.lag)  )
  {
    for ( t in 2: nrow(macro.lag) )
    {
      x.t.star[t,j] <- intrecepts.x[t,j] +  ( B.matrix.hat.bc[ ,j] ) %*% ( as.matrix(x.t.star[t-1, ]) ) +  as.matrix( ux.t.hat.star[t,j] )
    }
  }
  
  ##############################################
  # Generate the yt_star series
  ##############################################
  y.t.star      <- matrix(0, nrow = (nrow(returns.t)), ncol = ncol(returns.t) )
  y.t.star[1, ] <- uy.t.hat.star[1,]
  
  ones.matrix   <- matrix( 1, nrow = nrow(returns.t), ncol = ncol(returns.t) )
  intrecepts.y  <- matrix( 0, nrow = nrow(returns.t), ncol = ncol(returns.t) )
  
  # Define the matrix of intercepts
  for (j in 1:ncol(returns.t) )
  {
    intrecepts.y[, j]  <- as.matrix( ones.matrix[ ,j] )*as.numeric( mu.y.vector[j,1] )
  }
  
  for ( j in 1: ncol(returns.t)  )
  {
    for ( t in 2: nrow(returns.t) )
    {
      y.t.star[t,j] <- intrecepts.y[t,j] +  ( beta.coefficients[ ,j] ) %*% ( as.matrix(x.t.star[t-1, ]) ) +  as.matrix( uy.t.hat.star[t,j] )
    }
  }
  
  return( list( y.t.star = y.t.star, x.t.star = x.t.star) )
  
}# end of function 
###############################################################################

###############################################################################
### MAIN OF THE PROGRAM: INPUT - ESTIMATE - OUTPUT ######
###############################################################################

start_time <- Sys.time()

dataset    <- read.csv("100_firms_returns_and_macro_2015-04-15.csv", header = TRUE)

set.seed(1234)
time  <-  314
nhist <-  250
Nr_C  <-  30

window_size <-  250

returns <- as.matrix(dataset[, 2:( 101 ) ])    
macro   <- as.matrix(dataset[, 102:108])

returns <- as.matrix( returns[ (1:time), (1:Nr_C) ] )
macro   <- as.matrix( macro[1:time,] )


bootstrap_data <-  bootstrap_data_function( Nr_C=30, time=314, returns=returns, macro=macro ) 
returns        <-  as.matrix( bootstrap_data$y.t.star )
macro          <-  as.matrix( bootstrap_data$x.t.star )

returns
macro

mylist <- list()
mylist[[1]] <- returns
mylist[[2]] <- macro

capture.output( mylist, file = "bootstrap_data_30nodes.txt" )


end_time <- Sys.time()
end_time - start_time

###############################################################################
