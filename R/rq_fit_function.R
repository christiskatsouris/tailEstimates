

> getAnywhere(rq.fit.br)
A single object matching ‘rq.fit.br’ was found
It was found in the following places
package:quantreg
namespace:quantreg
with value

function (x, y, tau = 0.5, alpha = 0.1, ci = FALSE, iid = TRUE, 
          interp = TRUE, tcrit = TRUE) 
{
  tol <- .Machine$double.eps^(2/3)
  eps <- tol
  big <- .Machine$double.xmax
  x <- as.matrix(x)
  p <- ncol(x)
  n <- nrow(x)
  ny <- NCOL(y)
  nsol <- 2
  ndsol <- 2
  if (qr(x)$rank < p) 
    stop("Singular design matrix")
  if (tau < 0 || tau > 1) {
    nsol <- 3 * n
    ndsol <- 3 * n
    lci1 <- FALSE
    qn <- rep(0, p)
    cutoff <- 0
    tau <- -1
  }
  else {
    if (p == 1) 
      ci <- FALSE
    if (ci) {
      lci1 <- TRUE
      if (tcrit) 
        cutoff <- qt(1 - alpha/2, n - p)
      else cutoff <- qnorm(1 - alpha/2)
      if (!iid) {
        h <- bandwidth.rq(tau, n, hs = TRUE)
        bhi <- rq.fit.br(x, y, tau + h, ci = FALSE)
        bhi <- coefficients(bhi)
        blo <- rq.fit.br(x, y, tau - h, ci = FALSE)
        blo <- coefficients(blo)
        dyhat <- x %*% (bhi - blo)
        if (any(dyhat <= 0)) {
          pfis <- (100 * sum(dyhat <= 0))/n
          warning(paste(pfis, "percent fis <=0"))
        }
        f <- pmax(eps, (2 * h)/(dyhat - eps))
        qn <- rep(0, p)
        for (j in 1:p) {
          qnj <- lm(x[, j] ~ x[, -j] - 1, weights = f)$resid
          qn[j] <- sum(qnj * qnj)
        }
      }
      else qn <- 1/diag(solve(crossprod(x)))
    }
    else {
      lci1 <- FALSE
      qn <- rep(0, p)
      cutoff <- 0
    }
  }
  z <- .Fortran("rqbr", as.integer(n), as.integer(p), as.integer(n + 
                                                                   5), as.integer(p + 3), as.integer(p + 4), as.double(x), 
                as.double(y), as.double(tau), as.double(tol), flag = as.integer(1), 
                coef = double(p), resid = double(n), integer(n), double((n + 
                                                                           5) * (p + 4)), double(n), as.integer(nsol), as.integer(ndsol), 
                sol = double((p + 3) * nsol), dsol = double(n * ndsol), 
                lsol = as.integer(0), h = integer(p * nsol), qn = as.double(qn), 
                cutoff = as.double(cutoff), ci = double(4 * p), tnmat = double(4 * 
                                                                                 p), as.double(big), as.logical(lci1))
  if (z$flag != 0) 
    warning(switch(z$flag, "Solution may be nonunique", "Premature end - possible conditioning problem in x"))
  if (tau < 0 || tau > 1) {
    sol <- matrix(z$sol[1:((p + 3) * z$lsol)], p + 3)
    dsol <- matrix(z$dsol[1:(n * z$lsol)], n)
    vnames <- dimnames(x)[[2]]
    dimnames(sol) <- list(c("tau", "Qbar", "Obj.Fun", vnames), 
                          NULL)
    return(list(sol = sol, dsol = dsol))
  }
  if (!ci) {
    coef <- z$coef
    dual <- z$dsol[1:n]
    names(coef) <- dimnames(x)[[2]]
    return(list(coefficients = coef, x = x, y = y, residuals = y - 
                  x %*% z$coef, dual = dual))
  }
  if (interp) {
    Tn <- matrix(z$tnmat, nrow = 4)
    Tci <- matrix(z$ci, nrow = 4)
    Tci[3, ] <- Tci[3, ] + (abs(Tci[4, ] - Tci[3, ]) * (cutoff - 
                                                          abs(Tn[3, ])))/abs(Tn[4, ] - Tn[3, ])
    Tci[2, ] <- Tci[2, ] - (abs(Tci[1, ] - Tci[2, ]) * (cutoff - 
                                                          abs(Tn[2, ])))/abs(Tn[1, ] - Tn[2, ])
    Tci[2, ][is.na(Tci[2, ])] <- -big
    Tci[3, ][is.na(Tci[3, ])] <- big
    coefficients <- cbind(z$coef, t(Tci[2:3, ]))
    vnames <- dimnames(x)[[2]]
    cnames <- c("coefficients", "lower bd", "upper bd")
    dimnames(coefficients) <- list(vnames, cnames)
    residuals <- y - drop(x %*% z$coef)
    return(list(coefficients = coefficients, residuals = residuals))
  }
  else {
    Tci <- matrix(z$ci, nrow = 4)
    coefficients <- cbind(z$coef, t(Tci))
    residuals <- y - drop(x %*% z$coef)
    vnames <- dimnames(x)[[2]]
    cnames <- c("coefficients", "lower bound", "Lower Bound", 
                "upper bd", "Upper Bound")
    dimnames(coefficients) <- list(vnames, cnames)
    c.values <- t(matrix(z$tnmat, nrow = 4))
    c.values <- c.values[, 4:1]
    dimnames(c.values) <- list(vnames, cnames[-1])
    p.values <- if (tcrit) 
      matrix(pt(c.values, n - p), ncol = 4)
    else matrix(pnorm(c.values), ncol = 4)
    dimnames(p.values) <- list(vnames, cnames[-1])
    list(coefficients = coefficients, residuals = residuals, 
         c.values = c.values, p.values = p.values)
  }
}