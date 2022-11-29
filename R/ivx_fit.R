ivx_fit <- function(y, x, h = 1) 
  
{#begin of function
  
  nr <- NROW(x)
  
  xlag <- x[1:(nr - 1), , drop = FALSE]
  xt <- x[2:nr, , drop = FALSE]
  yt <- y[2:nr, , drop = FALSE]
  
  xt   <- as.matrix(xt)
  yt   <- as.matrix(yt)
  xlag <- as.matrix(xlag)
  
  cnames <- colnames(xt)
  
  nr <- NROW(xt)
  nn <- NROW(xlag)
  l  <- NCOL(xlag)
  
  lm1  <- lm(yt ~ xt)
  Aols <- coefficients(lm1)
  
  #epshat contains the residuals of the predictive regression
  epshat <- matrix(residuals(lm1))
  
  rn <- matrix(0, l, l)
  for (i in 1:l)
  {
    rn[i, i] <- lm( xt[, i] ~ 0 + xlag[, i] )$coefficients
  }
  
  # autoregressive residual estimation 
  u <- xt - xlag %*% rn
  
  # residuals' correlation matrix
  corrmat <- cor(cbind(epshat, u))
  
  # covariance matrix estimation 
  covepshat <- crossprod(epshat) / nn
  covu <- matrix(0, l, l)
  
  for (i in 1:nn)
  {
    covu <- covu + crossprod(u[i, , drop = FALSE])
  }
  covu <- covu / nn
  covuhat <- matrix(0, 1, l)
  
  for (i in 1:l) 
  {
    covuhat[, i] <- sum(epshat * u[, i])
  }
  
  covuhat <- t(covuhat) / nn
  
  m <- floor(nn^(1 / 3)) # bandwith parameter
  uu <- matrix(0, l, l)
  
  for (i in 1:m) 
  {
    a <- matrix(0, l, l)
    for (j in (i + 1):nn) 
    {
      a <- a + t(u[j, , drop = F]) %*% u[j - i, , drop = F]
    }
    uu <- uu + (1 - i / (m + 1)) * a
  }
  
  uu <- uu / nn
  
  # Estimation of the Omegauu matrix 
  Omegauu <- covu + uu + t(uu)
  
  q <- matrix(0, m, l)
  for (i in 1:m) 
  {
    p <- matrix(0, nn - i, l)
    
    for (j in (i + 1):nn)
    {
      p[j - i, ] <- u[j, , drop = F] * epshat[j - i] 
    }
    q[i, ] <- (1 - i / (1 + m)) * colSums(p)
  }
  
  residue <- apply(q, 2, sum) / nn
  Omegaeu <- covuhat + residue # resideue should be transposed
  
  h <- 1
  # instrument construction
  
  n <- nn - h + 1
  Rz <- (1 - 1 / (nn^0.95)) * diag(l)
  
  diffx <- xt - xlag
  
  z <- matrix(0, nn, l)
  z[1, ] <- diffx[1, ]
  
  
  for (i in 2:nn) 
  {
    z[i, ] <- z[i - 1, ] %*% Rz + diffx[i, ]
  }
  
  Z  <- rbind(matrix(0, 1, l), z[1:(n - 1), , drop = F])
  zz <- rbind(matrix(0, 1, l), z[1:(nn - 1), , drop = F])
  ZK <- matrix(0, n, l)
  
  for (i in 1:n) 
  {
    ZK[i, ] <- colSums(zz[i:(i + h - 1), , drop = F])
  }
  
  yy <- matrix(0, n, 1)
  
  for (i in 1:n)
  {
    yy[i] <- sum(yt[i:(i + h - 1), drop = F])
  }
  
  xK <- matrix(0, n, l)
  
  for (i in 1:n)
  {
    xK[i, ] <- colSums(xlag[i:(i + h - 1), , drop = F])
  }
  
  meanxK <- colMeans(xK)
  
  Yt <- yy - mean(yy)
  Xt <- matrix(0, n, l)
  
  for (i in 1:l)
  {
    Xt[, i] <- xK[, i, drop = F] - meanxK[i] * matrix(1, n, 1)
  }
  
  # Computation of the Aivx matrix 
  Aivx <- t(Yt) %*% Z %*% pracma::pinv(t(Xt) %*% Z)
  meanzK <- colMeans(ZK)
  FM     <- covepshat - t(Omegaeu) %*% pracma::inv(Omegauu) %*% Omegaeu
   
  M <- crossprod(ZK) * covepshat[1] - kronecker(n * tcrossprod(meanzK), FM)
  H <- matrix(1, l, l)
  Q <- pinv(t(Z) %*% Xt) %*% M %*% pinv(t(Xt) %*% Z)
  
  Wivx        <- Aivx %*% pracma::pinv(Q) %*% t(Aivx)
  Wivx_pvalue <- 1 - pchisq(Wivx, l)
  WivxInd     <- Aivx / diag(Q)^(1/2) # t(diag(Q)^(1/2))
  WivxInd_pvalue <- 1 - pchisq(WivxInd[1, ]^2, 1)
  
  coefficients_ivx        <- drop(Aivx)
  names(coefficients_ivx) <- cnames
  
  coefficients_ols <- coefficients(summary(lm1))
  rownames(coefficients_ols) <- c("(intercept)", cnames)
  
  data_output <- cbind(Yt,Xt)
  
  output <- structure(list(coefficients_ivx =  coefficients_ivx,
                         coefficients_ols = coefficients_ols,
                         horizon = h,
                         cnames = cnames,
                         delta = drop(corrmat),
                         ar = diag(rn),
                         Wivx = drop(Wivx),
                         Wivx_pvalue = Wivx_pvalue,
                         WivxInd = drop(WivxInd),
                         WivxInd_pvalue = WivxInd_pvalue,
                         varcovIVX = Q, 
                         estimated_series = data_output ))
  
 return(output)
  
}#end of function

###############################################################################################################

## References:

# [1]. R package ivx (see, https://github.com/kvasilopoulos/ivx)
# [2]. Matlab Code for ivx implementation of the paper KMS (2015). 
