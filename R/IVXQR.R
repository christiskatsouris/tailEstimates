###########################################
R Script Details:
###########################################

Script name: IVXQR.R

Program aim: This R program implements the IVX-QR estimator proposed by Lee (JoE, 2016).  

adapted by: 

Christis G. Katsouris (August 2021)
Department of Economics
University of Southampton
Southampton, United Kingdom


###########################################
# R package Installations
###########################################

install.packages("kdensity")
install.packages("clusterGeneration")
install.packages("pracma")
install.packages("nnet")
install.packages("quantreg")
install.packages("GA")
install.packages("doParallel")

library( Matrix)
library( mvtnorm)
# library( matrixcalc )
library( clusterGeneration )
library( pracma )
library( nnet )
library( quantreg )
library( GA )
library( kdensity )

######################################################################################

dataset <- read.csv("tenet_dataset.csv", header = TRUE)
returns <- as.matrix( dataset[, 2] )    
macro   <- as.matrix( dataset[, 3:10] )

###############################################################################
# FUNCTION : IVXQR borrowed from Lee (Journal of Econometrics, 2016)        ###
###############################################################################

IVXQR <- function( returns = returns, macro = macro , tau = tau )
{# begin of function
  
  # Initialization of variables
  macro   <- macro 
  returns <- returns
  
  # returns <- as.matrix( returns[ ,1] )
  
  y   <- returns
  x   <- macro
  tau <- tau
  
  # Lag Adjustment
  n  <- nrow( x )
  p  <- ncol( x )
  
  y.t    <- as.matrix( y[2:n,1] )
  x.t    <- as.matrix( x[2:n,  ] )
  x.lag  <- as.matrix( x[1:(n-1), ] )
  
  ####################################
  # Autoregression Estimation
  # Rn contains the estimated coefficients of the autoregression matrix Rn
  ####################################
  
  Rn <- matrix(0, p, p)
  
  for ( i in 1:p )
  {
    Rn[i, i] <- lm( x.t[, i] ~ 0 + x.lag[, i] )$coefficients
  }
  
  model <- lm( x.t ~  x.lag - 1)
  matrix.coeff <- model$coefficients
  
  coef <- matrix( 0, 7, 7)
  for (i in 1:7)
  {
    coef[i,i] <- matrix.coeff[i,i]  
  }
  
  # autoregressive residual estimation: ( n x p ) matrix with estimated residuals
  # Note that these are the individual residuals from each AR(1) separately in each column
  u.hat <- as.matrix( x.t - x.lag %*% Rn )
  
  ####################################
  # Ordinary QR with intercept
  ####################################
  
  model.QR <- rq( y.t  ~ x.lag, tau = tau )
  model.QR.summary <- summary( model.QR, se = "boot", bsmethod= "xy" )
  model.QR.coef    <- as.data.frame( model.QR.summary$coefficients )
  model.QR.coef    <- as.matrix(  model.QR.coef$Value )
  #coef    <-  model.QR.coef
  
  residuals.QR.model <- as.matrix( residuals( model.QR ) )
  # hist( residuals.QR.model  )
  
  # We can also estimate the residuals as below
  # residuals.estimated <- matrix( 0, nrow = nrow(x.lag) , ncol = 1)
  # ones <- matrix( 1, nrow = nrow(x.lag) , ncol = 1)
  # regressors <- cbind(ones, x.lag )
  # fitted.design.matrix <- regressors%*%model.QR.coef
  # residuals.estimated  <- ( y.t - fitted.design.matrix )
  
  # fitted.design.matrix.alternative <- ones%*%coef[1,1] + as.matrix(coef[2,1]*x.lag[ ,1]) + as.matrix(coef[3,1]*x.lag[ ,2])+ as.matrix(coef[4,1]*x.lag[ ,3])+ as.matrix(coef[5,1]*x.lag[ ,4])+ as.matrix(coef[6,1]*x.lag[ ,5])+ as.matrix(coef[7,1]*x.lag[ ,6])+ as.matrix(coef[8,1]*x.lag[ ,7])+ as.matrix(coef[9,1]*x.lag[ ,8])
  # diff <-  fitted.design.matrix - fitted.design.matrix.alternative 
  # residuals.estimated - residuals.QR.model
  
  #  estimating lambda
  e.tau <- matrix( 0, nrow = nrow(x.lag) , ncol = 1)
  
  for ( i in 1:(n-1) )
  {
    if ( residuals.QR.model[i,1] < 0 )
    {
      e.tau[i,1] <- 1
    }
  }
  
  # lambda <- cor( e.tau, u.hat )
  lambda <- as.matrix( ( ( t(e.tau) %*% u.hat  ) / (n-1) ) / sqrt( tau*(1-tau) ) )
  
  # Choosing delta
  lambda0 <-  matrix( 0, nrow = 1, ncol = ncol(lambda) )
  
  for (i in 1:ncol(lambda) )
  {
    if ( lambda[1,i] >= 1 )
    {
      lambda0[1,i] = 1
    }
    
    if ( lambda[1,i] < 1 )
    {
      lambda0[1,i] = 0.01*round( 100*lambda[1,i] )
    }
  }
  
  ltb       <- as.matrix( ltb )
  n.row.lk  <- nrow(ltb)
  n.col.lk  <- ncol(ltb)
  
  ones <- matrix( 1 , nrow = nrow(ltb), ncol = 1 )
  cvec <- - ones
  
  c     <- -6
  cz    <- -5
  delta <- ( 1-(log(-c)-log(-cz))/ log(n) ) 
  
  # IVX construction
  n_ivx  <-  n^(delta)
  z      <-  matrix( 0 , nrow = n, ncol = ncol(x) )
  z[1, ] <- x[1, ]
  
  # Nonstationary Quantile Predictive Regression Model with single regressor
  rho_z  <- ( 1 + cz / n_ivx )
  for ( t in 2:n )
  {
    z[t, ] <- rho_z*z[t-1, ] + ( x[t, ] - x[t-1, ] ) 
  }
  
  # Nonstationary Quantile Predictive Regression Model with multiple regressors
  Rz <- (1 - 1 /n_ivx )*diag(p)
  for ( t in 2:n )
  {
    z[t, ] <- z[t-1, ]%*% Rz + ( x[t, ] - x[t-1, ] ) 
  }
    
  # IVX QR with dequantiling
  intercept.ones <- matrix( 1, nrow = nrow(y.t) , ncol = 1)
  z.lag.deq <- z[1:(n-1), ]
  beta.tau  <- model.QR.coef[1,1]
  y.t.tau   <- y.t - intercept.ones*beta.tau 
  
  # Next we obtain the IVX-QR estimates after dequantiling
  model.IVX.QR         <- rq( y.t.tau  ~ z.lag.deq - 1, tau = tau )
  model.IVX.QR.summary <- summary( model.IVX.QR, se = "boot", bsmethod= "xy" )
  model.IVX.QR.coef    <- as.data.frame( model.IVX.QR.summary$coefficients )
  IVX.QR.coef          <- as.matrix( model.IVX.QR.coef$Value )
  
  #residuals.QR.model <- as.matrix( residuals( model.IVX.QR ) )
  # Estimate the kernel density function 
  # kernel.density.residuals.QR.model <- kdensity( residuals.QR.model, start = "gumbel", kernel = "gaussian", normalized = TRUE)
  # d.residuals <- density(  residuals.QR.model ) 
  # plot(d.residuals)
  
  x.values <- as.matrix( d.residuals$x )
  y.values <- as.matrix( d.residuals$y )
  position.first.positive <- min( which( x.values > 0 ) )
 
  f_u <- y.values[(position.first.positive - 1), 1]
  
  # IVX QR t stats for simulation 
  ttau              <- tau*(1-tau)
  zzinv             <- inv( t(z.lag.deq)%*%(z.lag.deq) ) 
  sigma.IVX.QR.coef <- ( ttau/ ( f_u^2 ) )*(zzinv)
  chi.square.test   <- t(IVX.QR.coef)%*%( inv(sigma.IVX.QR.coef) )%*%(IVX.QR.coef)  
  
  return( list(IVX.QR.coef, sigma.IVX.QR.coef, chi.square.test )   )
  
}# end of function 

############################################################################################################

## Notice that estimating the VaR-DCoVaR matrix based on IVX instrumentation we need to 
## make an additional correction for including a generated regressor in the set of 
## regressors to be filtered out with the IVX instrumentation

# Additional Estimation Example:

model.IVX.QR         <- rq( y.t  ~ z.lag.deq , tau = tau )
model.IVX.QR.summary <- summary( model.IVX.QR, se = "boot", bsmethod= "xy" )
model.IVX.QR.coef    <- as.data.frame( model.IVX.QR.summary$coefficients )
IVX.QR.coef          <- as.matrix( model.IVX.QR.coef$Value )

var.forecast <-  IVX.QR.coef[1,1 ] +  t( as.matrix( x[n,  ] ) )%*%as.matrix( IVX.QR.coef[2:8,1 ])

############################################################################################################
