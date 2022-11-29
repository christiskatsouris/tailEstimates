###########################################
# R Script Details:
###########################################

# Script name: main_estimation_method.R (first draft March 2019)

# Program aim: This R program estimates the proposed risk matrix (first working paper in 2019) 
# (the current Script was modified accordingly in subsequent versions)

# written by: 

# Christis G. Katsouris (March 2019)
# Department of Economics
# University of Southampton
# Southampton, United Kingdom

############################################################################
### REQUIRED PACKAGES
############################################################################

install.packages("xlsx")
library(xlsx)

install.packages("readxl")
library("readxl")

install.packages("quantreg")
library(quantreg)

library(data.table)
library(readxl)

library(Matrix)
library(matlib)

############################################################################
# IMPORTING DATASETS
############################################################################

# read the file which includes log returns of 100 firms and 7 macro state

x0 = read.csv("100_firms_returns_and_macro_2015-04-15.csv", header = TRUE)

# all firms' characteristics from balance sheet information of 100 firms
Bal_sheet_full = read.csv(file = "Bal_sheet.csv")

# 7 macro state variables
macro  = as.matrix(x0[, 102:108])

# estimated Value at Risk of 100 firms
VaR = as.matrix(read.csv("VaR_movingwindows_20150617.csv")[-1])[, 1:100]

# log returns of 100 firms
xx0 = x0[, 2:101]
# where xx0 the log-returns of the 100 firms

###############################################################################
#FUNCTION 1: Estimate the CoVaRs (Preliminary notes) ##########
###############################################################################

# NOTE: This function is not called by another function, it just estimates and
# saves the CoVaRs in the folder directory

# INPUT:  DATASET (TENET DATASET)  
# OUTPUT: ESTIMATED CoVaRs AND VaRs SAVED IN EXCEL FILES (.csv)
# Note that the output of this function will have one less time dimension as the input

dataset = read.csv("100_firms_returns_and_macro_2015-04-15.csv", header = TRUE)
returns = as.matrix(dataset[, 2:101])    
macro  = as.matrix(dataset[, 102:108])

time <-  60
nhist <- 40
Nr_C  <- 10

returns <- returns[1:time,1:Nr_C]
returns <- as.matrix(returns)
macro   <- macro[1:time,]
macro   <- as.matrix(macro)

mov.wind <- 1
lower_window <- mov.wind   
upper_window <- nhist + (mov.wind - 1)

returns_historical <- as.matrix(returns[lower_window:upper_window, ])
macro_historical   <- as.matrix(macro[lower_window:upper_window, ])

###############################################################################
#FUNCTION 1: Estimate the CoVaRs ##########
###############################################################################

#RiskMatrix( Nr_C = Nr_C, time=time, nhist=nhist, returns=returns_historical, macro=macro_historical, currenttime = 1)

RiskMatrix <- function( Nr_C = Nr_C, returns=returns_historical, macro=macro_historical, currenttime = currenttime)
{#begin of function
  
  Nr_C <- Nr_C
  currenttime <- currenttime
  returns <- returns_historical
  macro <- macro_historical
  
  #Note here we need to match the lag of the two series since the macro in the model is M_{t-1}
  nr <- NROW(returns)
  returns <- returns_historical[1:(nr - 1), , drop = FALSE]
  macro   <- macro_historical[2:nr, , drop = FALSE]
  
  returns <- as.matrix(returns)
  macro <- as.matrix(macro)
  
  macro1 <- macro[ ,1]
  macro1 <- as.matrix(macro1)
  
  macro2 <- macro[ ,2]
  macro2 <- as.matrix(macro2)
  
  macro3 <- macro[ ,3]
  macro3 <- as.matrix(macro3)
  
  macro4 <- macro[ ,4]
  macro4 <- as.matrix(macro4)
  
  macro5 <- macro[ ,5]
  macro5 <- as.matrix(macro5)
  
  macro6 <- macro[ ,6]
  macro6 <- as.matrix(macro6)
  
  macro7 <- macro[ ,7]
  macro7 <- as.matrix(macro7)
  
  return<-0
  other.return<-0
  CoVaR.est <- 0
  var_est <- 0
  
  #j goes across firms also since we have N rows of blocks with T elements in each block

  for (i in 1:Nr_C)
  {#begin of outer loop
    
    #Each i iteration first estimates the CoVaR_i|i = VaR_i
    var_est<- 0 
    return <- 0
    return <- returns[ , i]
    return <- as.matrix(return)
    
    model_var <- rq( return  ~ macro, tau = 0.05 )
    #get the fitted values of the model
    var_est <- fitted.values(model_var)
    var_est <- as.vector(var_est)
    var_est <- as.matrix(var_est)
    ###Saving the VaR block
    index1 <- paste(as.character(i), sep="" )
    index2 <- paste(as.character(i), sep="" )
    index  <- paste(index1,index2, sep="_" )
    name   <- paste("CoVaR", as.character(index),"t", as.character(currenttime),sep="_")
    file   <- paste( as.character(name), ".csv", sep="" )
    write.csv( var_est, file = paste( as.character(name),".csv", sep="" ) )
    
    for (j in 1:Nr_C)
    {#begin of inner loop
      
      CoVaR.est <- 0
      
      if (i!=j)
      {#condition to estimate
        current.return <- returns[ , j]  
        current.return <- as.matrix(current.return)
        
        ###Estimation of CoVaR_j|i
        model_covar <- rq( current.return ~ macro + return , tau = 0.05)
        
        ###Extract the coefficients of the CoVaR_12 model
        coef_const  <- coefficients(model_covar)[["(Intercept)"]]
        coef_const  <- as.numeric(coef_const)
        
        coef_macro1 <- coefficients(model_covar)[["macroVIX"]]
        coef_macro1 <- as.numeric(coef_macro1)
        
        coef_macro2 <- coefficients(model_covar)[["macroLiquidity"]]
        coef_macro2 <- as.numeric(coef_macro2)
        
        coef_macro3 <- coefficients(model_covar)[["macroX3MTB"]]
        coef_macro3 <- as.numeric(coef_macro3)
        
        coef_macro4 <- coefficients(model_covar)[["macroYield"]]
        coef_macro4 <- as.numeric(coef_macro4)
        
        coef_macro5 <- coefficients(model_covar)[["macroCredit"]]
        coef_macro5 <- as.numeric(coef_macro5)
        
        coef_macro6 <- coefficients(model_covar)[["macroGSPC"]]
        coef_macro6 <- as.numeric(coef_macro6)
        
        coef_macro7 <- coefficients(model_covar)[["macroIYR"]]
        coef_macro7 <- as.numeric(coef_macro7)
        
        coef_return <- coefficients(model_covar)[["return"]]
        coef_return <- as.numeric(coef_return)
        
        ###Calculate the terms of the CoVaR
        term1 <- coef_macro1 * macro1
        term2 <- coef_macro2 * macro2
        term3 <- coef_macro3 * macro3
        term4 <- coef_macro4 * macro4
        term5 <- coef_macro5 * macro5
        term6 <- coef_macro6 * macro6
        term7 <- coef_macro7 * macro7
        
        overall_macro_term <- term1 + term2 + term3 + term4 + term5 + term6 + term7
        overall_macro_term <- as.matrix(overall_macro_term)
        
        VaR_term <- coef_return*var_est
        VaR_term <- as.matrix(VaR_term)
        
        constant_term <- matrix(nrow = (nr-1)  , ncol = 1, coef_const)
        
        ###Put all the terms of the CoVaR together
        CoVaR.est <- constant_term + overall_macro_term + VaR_term
        
        index1 <- paste(as.character(i), sep="" )
        index2 <- paste(as.character(j), sep="" )
        index <-  paste(index2,index1,sep="_" )
        name  <-  paste("CoVaR", as.character(index), "t", as.character(currenttime), sep="_" )
        file <- paste( as.character(name), ".csv", sep="" )
        write.csv( CoVaR.est, file = paste( as.character(name),".csv", sep="" ) )
        
      }#end of estimate condition
    }#end of inner loop
  }#end of outer loop     
}#end of function


###############################################################################
# FUNCTION 2: Constuction of time-varying CoVaR Matrices ##########
###############################################################################

# INPUT:  Nr_C , time   
# OUTPUT: ESTIMATED LIST OF CoVaRs AND VaRs

construction_covar_matrix<-function(Nr_C = Nr_C, time=time, currenttime=currenttime)
{#begin of function
  
  #Define the dimensions of the matrix
  Nr_C <- Nr_C
  time <- time
  currenttime <- currenttime
  
  #Initialize the matrix with null values
  Covar_matrix=as.data.frame(matrix(NA,time,Nr_C*Nr_C))
  
  for (i in 1:Nr_C)
  {#begin of i loop
    for (j in 1:Nr_C)
    {#begin of j loop
      name_to_call=paste("CoVaR","_",i,"_",j, "_","t","_", as.character(currenttime),".csv",sep="")
      tempo=read.csv(as.character(name_to_call))
      tempo=as.data.frame(tempo[,2])
      colnames(tempo)=as.character(paste("_",i,"_",j, "_","t","_", as.character(currenttime),sep=""))
      
      #construct the indices of the Covar matrix
      if (i==1)
      {#begin of if-statement
        Covar_matrix[ , j ]=tempo
      }#end of if-statement
      
      if ( (i >= 2) || (i <= Nr_C -1))
      {#begin of if-statement
        min <-(i-1)*Nr_C
        Covar_matrix[ , (min + j) ]=tempo
      }#end of if-statement
    }#end of j loop
  }#end of i loop
  
  the.list=list()
  for (j in 1:time)
  {
    matrix_tempo=data.frame(matrix(NA,Nr_C,Nr_C))
    tempo=Covar_matrix[j,]
    for (i in 1:Nr_C)
    {
      min=Nr_C*(i-1)+1
      max=Nr_C*i
      tempo_row=tempo[,min:max]
      matrix_tempo[i,]=tempo_row
    }
    the.list[[j]]=matrix_tempo
  }
  return(the.list)
}#end of function


###############################################################################
# FUNCTION 3: Constuction of symmetrized time-varying CoVaR Matrices ##########
###############################################################################

covar_symmetric_function <- function(Nr_C = Nr_C, time = time , sigma_tilda = sigma_tilda )
{#begin of function
  Nr_C <- Nr_C
  time <- time
  sigma_tilda = sigma_tilda
  the.list1=list()
  
  for (k in 1:time)
  {
    sigma_tilda1 <- sigma_tilda[[k]]
    sigma_tilda1 <- as.matrix(sigma_tilda1)
    #Lets symmetrize the matrix
    sigma_tilda1 <- abs(sigma_tilda1 )
    sigma_tilda1_sym <- 0.5*( sigma_tilda1 + t(sigma_tilda1 ) )
    
    the.list1[[k]]=sigma_tilda1_sym
  }
  return(the.list1)
}#end of function


###############################################################################
# FUNCTION 4: Optimal weights estimation ##########
###############################################################################

optimal_weights_function_foc <- function( Nr_C = Nr_C, time = time, covar_symmetric_list = covar_symmetric_list)
{#begin of function
  
  #Assign the input values of the function
  Nr_C <- Nr_C
  time <- time
  covar_symmetric_list = covar_symmetric_list
  
  #Dimensions are nrow=Nr_C and ncol=T
  optimal.weights.matrix <- matrix(NA, nrow = time  , ncol = Nr_C )
  
  for (k in 1:time)
  {#begin of time for loop
    
    #Initialize the optimal weights vector in each replication
    optimal.weights <- matrix(NA, nrow = Nr_C, ncol=1)
    
    covar_symmetric_matrix <- covar_symmetric_list[[k]]
    covar_symmetric_matrix <- as.matrix(covar_symmetric_matrix)
    
    ones <- matrix(1, Nr_C , 1)
    sigma_tidla_inverse <- solve(covar_symmetric_matrix)
    numerator   <- sigma_tidla_inverse%*%ones
    denominator <- ( t(ones) %*% (sigma_tidla_inverse) %*% (ones) )
    denominator <- as.numeric(denominator)
    
    optimal.weights <- (1/denominator)*numerator
    optimal.weights.matrix[k,] <- optimal.weights
    optimal.weights <- matrix(NA, nrow=Nr_C, ncol=1)
  }#end of time for loop
  return(optimal.weights.matrix)
}#end of function


###############################################################################
# FUNCTION 5: Function to estimate expected portfolio returns ##########
###############################################################################

#DATASET
#####################################################
#For illustration purposes take a subset of firms and time period from initial dataset
#Extract returns and macro variables separately

dataset = read.csv("100_firms_returns_and_macro_2015-04-15.csv", header = TRUE)
# log returns of 100 firms
returns = as.matrix(dataset[, 2:101])    
# 7 macro state variables
macro  = as.matrix(dataset[, 102:108])

time  <- NROW(dataset)
time  <- as.numeric(time)


#####################################################
# First call function 1 to estimate --> SENT WHOLE DATASET IN FUNCTION 1
# Method 1: Rolling estimation with updated information (moving window)
#Estimation of optimal weight for minimum variance strategy

dataset = read.csv("100_firms_returns_and_macro_2015-04-15.csv", header = TRUE)

time <-  30
nhist <- 15
Nr_C  <- 10

GO <- All_in_estimation( Nr_C = Nr_C, time = time, nhist = nhist, dataset = dataset )   

All_in_estimation <- function( Nr_C = Nr_C, time = time, nhist = nhist, dataset = dataset )   
{#begin of function
  
  dataset <- dataset
  returns <- as.matrix( dataset[, 2:101] )    
  macro   <- as.matrix( dataset[, 102:108] )
  
  Nr_C  <- Nr_C
  time  <- time
  nhist <- nhist
  
  # Define the matrices to store estimates
  portfolio.returns <- matrix(0, nrow = (time - nhist), ncol = 1)
  
  # Initialize the vectors
  w.vector <-0
  returns.historical <- 0
  macro.historical   <- 0
  
  estimate_risk_matrix <- 0
  sigma_tilda <- 0
  covar_symmetric_list <- 0
  the.optimal.weights.foc <- 0
  
  for (mov.wind in 1:(time-nhist))
  {# begin of for loop
    
    returns = as.matrix(dataset[, 2:101])    
    macro  = as.matrix(dataset[, 102:108])
    
    lower_window <- mov.wind   
    upper_window <- nhist + (mov.wind - 1)
    
    returns <- returns[1:time,1:Nr_C]*100
    returns <- as.matrix(returns)
    macro   <- macro[1:time,]
    macro   <- as.matrix(macro)
    
    returns_historical <- as.matrix(returns[lower_window:upper_window, ])
    macro_historical   <- as.matrix(macro[lower_window:upper_window, ])
    
    # Estimation of symmetrized sigma tilda matrix
    # Step 1: Estimate Sigma tilda matrix
    estimate_risk_matrix <- RiskMatrix( Nr_C = Nr_C, returns = returns_historical, macro = macro_historical, currenttime = mov.wind )
    
    # Step 2: Estimate Sigma tilda matrix (list) --> Call function 2
    sigma_tilda <- construction_covar_matrix( Nr_C = Nr_C, time = (nhist-1) , currenttime = mov.wind )
    
    # Step 3: Estimate symmetrized Sigma tilda matrix (list) --> Call function 3
    covar_symmetric_list <- covar_symmetric_function(Nr_C = Nr_C, time = (nhist-1), sigma_tilda = sigma_tilda )
    
    # Estimation of strategy 1: minimum variance strategy
    the.optimal.weights.foc <- optimal_weights_function_foc( Nr_C = Nr_C, time = (nhist-1), covar_symmetric_list = covar_symmetric_list )
    
    # Now pick the estimated w.vector of the last time period from above i.e, (nhist-1)
    w.vector <- the.optimal.weights.foc[(nhist-1),]
    w.vector <- as.matrix(w.vector)
    
    portfolio.returns[mov.wind] <- as.numeric( t(w.vector) %*% ( as.matrix( returns[(nhist + (mov.wind-1)), ]) ) )
    
    w.vector <-0
    returns.historical <- 0
    macro.historical   <- 0
    
    estimate_risk_matrix <- 0
    sigma_tilda <- 0
    covar_symmetric_list <- 0
    the.optimal.weights.foc <- 0
  }#end of for loop
  name   <- paste("portfolio_returns_minv", sep="")
  file   <- paste( as.character(name), ".csv", sep="" )
  write.csv( portfolio.returns, file = paste( as.character(name),".csv", sep="" ) )
  return(portfolio.returns)
}#end of function 


########################################################################################


hist(portfolio.returns)

mean.portfolio <- mean(GO)
mean.portfolio <- as.numeric(mean.portfolio)
mean.portfolio

var.portfolio <- var(GO)
var.portfolio <- as.numeric(var.portfolio)
var.portfolio

sharpe.ratio <- mean.portfolio / var.portfolio
sharpe.ratio

######################

mean.portfolio <- mean(portfolio.returns)
mean.portfolio <- as.numeric(mean.portfolio)
mean.portfolio

var.portfolio <- var(portfolio.returns)
var.portfolio <- as.numeric(var.portfolio)
var.portfolio

sharpe.ratio <- mean.portfolio / var.portfolio
sharpe.ratio

hist(portfolio.returns)

