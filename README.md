# tailEstimates

## Optimal Portfolio Choice under tail events

This R package has two main purposes:

$\textbf{(a).}$ To implement the optimization and estimation procedure that provides in-sample and out-of-sample estimates for the VaR-DCoVaR risk matrix proposed in the study of [Katsouris, C. (2021)](https://arxiv.org/abs/2112.12031).

$\textbf{(b).}$ To compute the elements of the VaR-DCoVaR risk matrix with both OLS and IVX estimates (as a user defined option) based on pairwise quantile predictive regression models fitted on the nodes of the graph.

## Installation (under development)

The R package ‘tailEstimates’ will be able to be installed from Github.

## Usage 

```R

# After development the package will be able to be installed using
install.packages("tailEstimates")
library("tailEstimates")

```

## TENET Dataset

The dataset for our empirical application is obtained from [Härdle et al. (2016)](https://www.sciencedirect.com/science/article/pii/S0304407616300161), which includes a panel of the top 100 publicly traded US financial institutions by market capitalization. These high market capitalized financial institutions are categorized into four groups: (i) depositories, (ii) insurance companies, (iii) broker-dealers, and (iv) other financial institutions. Moreover, the stock returns of these firms are computed as rt = 100 log( Pt - Pt-1), where $P_t$ denotes the log prices. Let $Y_t$ be the matrix of log-returns of a set of $N$ assets, that is, $Y_t= (y_{1,t},...,y_{N,t})$ and $X_t$ be the matrix of common covariates for all financial institutions. Then, the set of regressors consists of $X_t = [ M_t \ \vdots \ B_t ]$ where $M_t = [ m_{1,t},...,m_{k,t}]$ where $k$ the number of macroeconomic variables and $B_t = [ b_{1,t},..., b_{N,t} ]$ with $b_{i,t}=[ b_{1,t},...,b_{r,t}]$ where $r$ the number of common firm characteristics. 

### Firm Specific Variables

- Leverage = Total Assets / Total Equity.
- Maturity Mismatch = Short term Debt / Total liabilities.
- Size = Log of Total Book Equity.
- Market-to-book = Market Value of Total Equity / Book Value of Total Equity.

### Macroeconomic Variables

- Variable 1 = the implied volatility index (VIX)*.
- Variable 2 = the short term liquidity spread calculated as the difference between the three-month repo rate and the three-month bill rate.
- Variable 3 = the changes in the three-month Treasury bill rate.
- Variable 4 = the changes in the slope of the yield curve corresponding to the yield spread between the ten year Treasury rate and the three-month bill rate from FRB.
- Variable 5 = the changes in the credit spread between BAA rated bonds and the Treasury rate.
- Variable 6 = the weekly S&P500 index returns.
- Variable 7 = the weekly Dow Jones US Real Estate index returns.

*The VIX is considered a robust financial variable which can capture financial conditions and time-varying volatility effects across the US financial markets.

## Empirical Application

The empirical study provides insights regarding the procedure for fitting predictive regression models using the IVX instrumentation of KMS (2015) by considering equation-by-equation estimates. Moreover, since the TENET dataset includes both system covariates (such as the macroeconomic variables) as well as firm-specific variables, we can also investigate with more details the statistical procedure for constructing the dynamic VaR-DCoVaR risk matrix as well as related asymptotic theory properties.   

-	Step 1: For $y_t$ we use the stock returns of each firm and for $x_t$ the set of macroeconomic and firm variables corresponding to each firm. First, we construct the lag $x_t$ variables and regress $y_t$ on $x_t$ to obtain the A matrix with the estimated coefficients of this multivariate regression. Then, we estimate the residuals of the predictive regression, and we obtain the coefficients of the Rn matrix, which is simply estimated by solving with respect to the residuals in a regression model with no intercept. 

-	Step 2: Estimation of predictive regression matrices. First, we estimate the autoregressive residuals, the residuals correlation matrix and the corresponding covariance matrix. These estimations help us to obtain the Omega matrices.

-	Step 3: Instrument construction. This step includes the construction/estimation of all necessary instrumental variables/matrices to apply the IVX methodology.  Thus, in this step we obtain estimates of the matrices $R_z$, $Z$, $y_t$, $x_t$ and the computation of the Aivx and Wixv matrices. 

### Estimation Examples 1 (Conditional Mean Predictive Regression)

We fit the predictive regression models to a subset of the financial institutions from the TENET paper $(N=40)$. The estimations were done with the help of the R package  'ivx'. Firstly, as it appears the macroeconomic variables since are common across all predictive regressions could possibly have similar effect in the predictive ability of the stock returns but this is not true in all cases. A formal Wald-type hypothesis testing is also necessary to draw related conclusions. Furthermore, we can observe that the coefficients show different degree of persistence across variables and across the equation-by-equation predictive regressions for the cross-section of firms.   

```R

# Predictive Regression model with both nonstationary regressors and exogenous stationary regressors
# Nonstationary regressors represent the macroeconomic variables
# Stationary regressors represent the firm characteristic variables

######################
# Firm 1
######################

$coefficients_ivx
         VIX    Liquidity        X3MTB        Yield       Credit         GSPC          IYR        LEV.1         MM.1       SIZE.1        MTB.1 
 0.000170558 -0.046851942 -0.047916642  0.012450139  0.027512718 -0.152131917 -0.022165772 -0.025384947 -0.236026228  0.041882907 -0.026078263 

$coefficients_ols
                 Estimate   Std. Error    t value    Pr(>|t|)
(intercept)  0.9695197511 0.7009755278  1.3831007 0.167659055
VIX          0.0008075845 0.0007939275  1.0172019 0.309874316
Liquidity    0.0356281353 0.0334936327  1.0637286 0.288304275
X3MTB        0.0086309744 0.0355966516  0.2424659 0.808584298
Yield        0.0201886162 0.0079891317  2.5270101 0.012015940
Credit       0.0366477426 0.0128812353  2.8450488 0.004744993
GSPC        -0.5797704937 0.2403147036 -2.4125469 0.016439260
IYR          0.1900759067 0.1548954508  1.2271239 0.220734945

LEV.1       -0.0424506894 0.0134424506 -3.1579576 0.001750051
MM.1        -0.4191338885 0.2824838149 -1.4837448 0.138922989
SIZE.1       0.0485205358 0.0175600837  2.7631153 0.006077775
MTB.1       -0.0657711515 0.0528333893 -1.2448785 0.214144749

$ar
 [1]  0.98912636  0.84615665  0.07760762  0.99858887  1.00036641 -0.06066777 -0.04922636  0.99959036  1.00005729  0.99480468  1.00033744

######################
# Firm 40
######################

$coefficients_ivx
          VIX     Liquidity         X3MTB         Yield        Credit          GSPC           IYR        LEV.40         MM.40       SIZE.40        MTB.40 
 0.0001757807 -0.1067297328  0.0346327725  0.0046821559  0.0722115562 -0.0271626190  0.0772338555 -0.0145678173 -5.4013499129  0.1617595088  0.1206624350 

$coefficients_ols
                Estimate  Std. Error     t value   Pr(>|t|)
(intercept)  1.112344188 2.021351883  0.55029715 0.58252371
VIX         -0.001607709 0.001249803 -1.28637017 0.19930245
Liquidity    0.019459936 0.049630125  0.39209926 0.69526235
X3MTB       -0.001674978 0.054631195 -0.03065974 0.97556121
Yield        0.001370419 0.010734272  0.12766765 0.89849724
Credit       0.089015110 0.027562549  3.22956734 0.00137689
GSPC        -0.277105820 0.367020047 -0.75501549 0.45083004
IYR          0.137638621 0.237392997  0.57979225 0.56248844

LEV.40      -0.038549653 0.019102121 -2.01808228 0.04446957
MM.40       -3.233131058 7.690884279 -0.42038483 0.67450430
SIZE.40      0.136530494 0.061136250  2.23321670 0.02626950
MTB.40      -0.088333116 0.185614364 -0.47589591 0.63449375

$ar
 [1]  0.98912636  0.84615665  0.07760762  0.99858887  1.00036641 -0.06066777 -0.04922636  0.99989941  0.99682082  0.99524963  1.00007511
```

### Remarks: 

Notice that the above data structure that encompasses both a set of nonstationary regressors and a set of exogenous stationary covariates in predictive regression models is a novel aspect in the literature which worths further study, especially in terms of asymptotic theory analysis for econometric inference purposes. In other words, these initial estimates are for illustration purposes, since unless otherwise specified both the paper as well as the corresponding R implementation  corresponds to estimation and inference based on the predictive (quantile) regression model with persistent regressors (that is, nonstationary regressors modeled using the LUR specification). 

### Estimation Examples 2 (Conditional Quantile Predictive Regression)

```R

# Predictive Regression model with nonstationary regressors (modeled using the LUR specification)
# Nonstationary (e.g., persistent) regressors represent the macroeconomic variables

######################
# Firm 1
######################


```

## Estimation Methodology 

The estimation methodology of the VaR-DCoVaR Risk matrix consists of the main novelity of the proposed framework which involves the construction of a large covariance-type matrix based on nodewise pairewise quantile predictive regression models. 

```R
###########################################
R Script Details:
###########################################

Script name: MAIN_Risk_Matrix.R

Program aim: This R program estimates of the Risk Matrix before symmetrization.  

written by: 

Christis G. Katsouris
Department of Economics
University of Southampton
Southampton, United Kingdom

This program reproduces the empirical application reported in the paper: 
"Optimal Portfolio Choice and Stock Centrality for Tail Risk Events" by Christis G. Katsouris

For running this program as it is, it requires the data files of the TENET paper. 

It should work with other data sets as well provided that the cross-section of returns 
and macroeconomic variables are stored to separate data files (e.g., 2 different .csv files)

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
  
  #Note here we need to match the lag of the two series since the macro in the model is M_{t-1}
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

###########################################
R Script Details:
###########################################

Script name: MAIN_VAR_DCOVAR.R

Program aim: This R program estimates of VaR-DCoVaR (tau) matrix.  

written by: 

Christis G. Katsouris
Department of Economics
University of Southampton
Southampton, United Kingdom

###############################################################################
### MAIN FUNCTION 2: Estimation of the Forecasted VaR-DCoVaR Risk Matrices ####
###############################################################################

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

```

## Parallel Computing within R (R Script usage)

Notice that parallel computing techniques can be applied when running an R Script on a personal computer. Some examples are given below:  

```R

## Load package
library(snow)

## Setup parallel
cluster <- makeCluster(4)

## Export objects
clusterExport( cluster, c( "input_parameters_to_function", "Seed") )

# The above example provides a way to use parallel techniques using the build-in cluster capabilities of R
# without the need to use HPC and different R scripts


```

# Key References

$\textbf{[1]}$ Katsouris, C. (2021). Optimal Portfolio Choice and Stock Centrality for Tail Risk Events. arXiv preprint [arXiv:2112.12031](https://arxiv.org/abs/2112.12031).

$\textbf{[2]}$ Tobias, A., & Brunnermeier, M. K. (2016). CoVaR. The American Economic Review, 106(7), 1705. [DOI:10.1257/aer.20120555](https://www.aeaweb.org/articles?id=10.1257/aer.20120555).

$\textbf{[3]}$ Härdle, W. K., Wang, W., & Yu, L. (2016). Tenet: Tail-event driven network risk. Journal of Econometrics, 192(2), 499-513. [DOI:10.1016/j.jeconom.2016.02.013](https://www.sciencedirect.com/science/article/pii/S0304407616300161).  

$\textbf{[4]}$ Lee, J. H. (2016). Predictive quantile regression with persistent covariates: IVX-QR approach. Journal of Econometrics, 192(1), 105-118. [https://doi.org/10.1016/j.jeconom.2015.04.003](https://www.sciencedirect.com/science/article/pii/S0304407615003000).

$\textbf{[5]}$ Kostakis, A., Magdalinos, T., & Stamatogiannis, M. P. (2015). Robust econometric inference for stock return predictability. The Review of Financial Studies, 28(5), 1506-1553. [https://doi.org/10.1093/rfs/hhu139](https://academic.oup.com/rfs/article/28/5/1506/1867633).

# Code of Coduct

Please note that the ‘tailEstimates’ project will be released with a Contributor Code of Coduct (under construction). By contributing to this project, you agree to abide by its terms.

# Declarations

The author declares no conflicts of interest.

In particular, the author declares that has no affiliations with or involvement in any organization or entity with any financial interest (such as honoraria; educational grants; participation in speakers’ bureaus; membership, employment, consultancies, stock ownership, or other equity interest; and expert testimony or patent-licensing arrangements), or non-financial interest (such as personal relationships and/or affiliations) in the subject matter or materials discussed in the manuscript and implemented in the R package.

# Acknowledgments

The author greatfully acknowledges financial support from the [Department of Economics](http://business-school.exeter.ac.uk/about/departments/economics/) of the [Faculty of Environment, Science and Economy](https://www.exeter.ac.uk/departments/ese/) at the University of Exeter, United Kingdom. 

Christis G. Katsouris is a Lecturer in Economics at the [University of Exeter Business School](http://business-school.exeter.ac.uk/). He is also a member of the [Time Series and Machine Learning Group](https://www.personal.soton.ac.uk/cz1y20/Reading_Group/mlts-group-2022.html) at the [School of Mathematical Sciences](https://www.southampton.ac.uk/about/faculties-schools-departments/school-of-mathematical-sciences) (Statistics Division) of the University of Southampton. 

The author greatfully acknowledges financial support from Graduate Teaching Assistantships at the School of Economic, Social and Political Sciences of the University of Southampton as well as from the Vice-Chancellor's PhD Scholarship of the University of Southampton, for the duration of the academic years 2018 to 2021. The author also gratefully acknowledges previously obtained funding from Research Grants of interdisciplinary Centers of research excellence based at the University of Cyprus (UCY) as well as at the University College London (UCL).

Part of the aspects implemented in the R package 'tailEstimates', are discussed in the PhD thesis of the author (Christis G. Katsouris) titled: "Aspects of Estimation and Inference for Predictive Regression Models", completed under the supervision of Professor Jose Olmo and Professor Anastasios Magdalinos. 

# Historical Background

$\textbf{John Von Neumann}$ (28 December 1903 – 8 February 1957) was a Hungarian-American mathematician, physicist, computer scientist, engineer and polymath. He was regarded as having perhaps the widest coverage of any mathematician of his time and was said to have been "the last representative of the great mathematicians who were equally at home in both pure and applied mathematics". Von Neumann made major contributions to many fields, including mathematics (measure theory, functional analysis, ergodic theory, group theory, lattice theory, representation theory, operator algebras, matrix theory, geometry, and numerical analysis), physics (quantum mechanics, hydrodynamics, nuclear physics and quantum statistical mechanics), economics (game theory and general equilibrium theory), computing (linear programming, scientific computing, stochastic computing), and statistics. He was a pioneer of the application of operator theory to quantum mechanics in the development of functional analysis, and a key figure in the development of game theory and the concepts of cellular automata and the digital computer. Von Neumann published over 150 papers in his life. His last work, an unfinished manuscript written while he was in the hospital, was later published in book form as The Computer and the Brain (Source: [Wikipedia](https://en.wikipedia.org/wiki/John_von_Neumann)). 
