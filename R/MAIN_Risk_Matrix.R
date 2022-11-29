###########################################
# R Script Details:
###########################################

# Script name: MAIN_Risk_Matrix.R

# Program aim: This R program estimates of the Risk Matrix before symmetrization.  

# written by: 

# Christis G. Katsouris (December 2020)
# Department of Economics
# University of Southampton
# Southampton, United Kingdom

# This program reproduces the empirical application reported in the paper: 
# "Optimal Portfolio Choice and Stock Centrality for Tail Risk Events" by Christis G. Katsouris

# For running this program as it is, it requires the data files of the TENET paper. 

# It should work with other data sets as well provided that the cross-section of returns 
# and macroeconomic variables are stored to separate data files (e.g., 2 different .csv files)

###############################################################################
### MAIN FUNCTION 1: Estimation of the Forecasted Risk Matrices            ####
###############################################################################

Risk_Matrix_forecast_function <- function( Nr_C = Nr_C, returns = returns, macro = macro, tau = tau )
{#begin of function
  
  # Initialize inputs
  Nr_C  <- Nr_C
  nhist <- nhist
  tau   <- tau
  
  returns <- returns
  macro   <- macro
  
  # Note here we need to match the lag of the two series since the macro in the model is M_{t-1}
  nr <- nrow(returns)
  p  <- ncol(macro)
  
  the_returns <- as.matrix( returns[2: nr, ] )
  the_macro   <- as.matrix( diff( macro[1:nr,] ) )
  
  returns <- the_returns
  macro   <- the_macro  
  
  nr <- nrow( returns )
  
  # Pick the last observation of the moving window to construct forecasts
  current.macro <- macro[nr,  ]
  current.macro <- as.matrix(as.vector(current.macro))
  
  macro.lag <- as.matrix( macro[1:(nr - 1), , drop = FALSE] )
  returns.t <- as.matrix( returns[2:nr, , drop = FALSE] )
  
  return.t       <- 0
  other.return.t <- 0
  var.forecast   <- 0
  covar.forecast <- 0
  
  forecast.risk.matrix <- matrix( 0, nrow = Nr_C  , ncol = Nr_C )
  
  for (i in 1:Nr_C)
  {#begin of outer loop
    
    # Each i iteration first estimates the CoVaR_i|i = VaR_i
    var.forecast <- 0
    return.t     <- as.matrix( returns.t[ , i] )
    
    model.var <- rq( return.t  ~ macro.lag, tau = tau )
    model.var.summary <- summary( model.var, se = "boot", bsmethod= "xy" )
    model.var.coef    <- as.data.frame( model.var.summary$coefficients )
    model.var.coef    <- as.matrix( model.var.coef$Value )
    var.forecast              <- model.var.coef[1,1] + t(current.macro)%*%as.matrix(model.var.coef[2:(p+1),1])
    forecast.risk.matrix[i,i] <- var.forecast #one-period ahead forecast of VaR at time t = 251
    
    ##################################
    for (j in 1:Nr_C)
    {#begin of inner loop
      
      if (j!=i)
      {# condition to estimate
        
        other.return.t <- as.matrix( returns.t[ , j] ) 
        ###Estimation of CoVaR_j|i
        model.covar <- rq( other.return.t ~ macro.lag + return.t , tau = tau )
        model.covar.summary   <- summary( model.covar, se = "boot", bsmethod= "xy" )
        model.covar.estimates <- as.data.frame( model.covar.summary$coefficients )
        model.covar.coef      <- as.matrix( model.covar.estimates$Value )
        covar.forecast <- model.covar.coef[1,1]  + t(current.macro)%*%as.matrix(model.covar.coef[2:(p+1),1] ) + model.covar.coef[(p+2),1]*var.forecast
        forecast.risk.matrix[j,i] <- covar.forecast - var.forecast
        covar.forecast <- 0
        
      }#end of estimate condition
    }#end of inner loop
  }#end of outer loop     
  
  return( forecast.risk.matrix )
  
}#end of function

###############################################################################
