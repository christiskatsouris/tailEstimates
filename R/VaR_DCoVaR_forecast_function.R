###########################################
# R Script Details:
###########################################

# Script name: VaR_DCoVaR_forecast_function.R

# Program aim: This R program estimates of VaR-DCoVaR (tau) matrix.  

# written by: 

# Christis G. Katsouris (December 2020)
# Department of Economics
# University of Southampton
# Southampton, United Kingdom

###############################################################################
### MAIN FUNCTION 2: Estimation of the Forecasted VaR-DCoVaR Risk Matrices ####
###############################################################################

source("Risk_Matrix_forecast_function.R")

VaR_DCoVar_forecast_function <- function( Nr_C = Nr_C, nhist = nhist, returns = returns_hist, macro = macro_hist, tau = tau )
{#begin of function
  
  # Initialize inputs
  Nr_C  <- Nr_C
  nhist <- nhist
  tau   <- tau
 
  returns <- returns_hist
  macro   <- macro_hist
  
  nr <- NROW(returns)
  p <- ncol(macro)
  
  # Step 1: Estimate the VaR-DCoVaR matrix (no change of signs in this step)
  VaR.DCoVar.forecast <- Risk_Matrix_forecast_function( Nr_C = Nr_C, nhist = nhist, returns=returns_hist, macro=macro_hist, tau = tau )
  
  # Step 2: Take the negative VaRs and DCoVaRs
  VaR.DCoVar.forecast.positive <- VaR.DCoVar.forecast
  for (i in 1: Nr_C )
  {
    for (j in 1: Nr_C )
    {  
      VaR.DCoVar.forecast.positive[i,j] <- - ( VaR.DCoVar.forecast[i,j] )
    }
  }
  
  # Second I construct the non-symmetric version of the proposed Gamma risk matrix
  # Take the estimated VaRs into a vector
  VaR.forecasts <- matrix( 0, nrow = Nr_C, ncol = 1 )
  for (i in 1:Nr_C )
  {
    VaR.forecasts[i,1] <- abs( VaR.DCoVar.forecast.positive[i,i] )
  }
  VaR.DCoVar.forecast.positive.new <- diag( Nr_C )
  
  # Step 3: Construct our proposed risk matrix 
  for (i in 1:Nr_C)
  {
    for (j in 1:Nr_C)
    {# begin for-loop
      if (j!=i)
      {# begin if 
        VaR.DCoVar.forecast.positive.new[j,i] <- ( ( VaR.forecasts[j,1]*VaR.forecasts[i,1] )^0.5 ) * VaR.DCoVar.forecast.positive[j,i]
      }# end if
    }# end for-loop
  }
  
  # Next I replace the diagonal with the positive estimated VaRs
  for (i in 1:Nr_C )
  {
    VaR.DCoVar.forecast.positive.new[i,i] <- VaR.forecasts[i,1]
  }
  
  # Step 4: Take the symmetric part of the Gamma matrix
  risk.matrix <- 0.5 * ( VaR.DCoVar.forecast.positive.new + t(VaR.DCoVar.forecast.positive.new) )
  
  return( risk.matrix )
  
}#end of function
