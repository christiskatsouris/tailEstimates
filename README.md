# tailEstimates

## Optimal Portfolio Choice under tail events

This R package has two main purposes:

$\textbf{(a).}$ To implement the optimization and estimation procedure tha provides in-sample and out-of-sample estmates for the VaR-DCoVaR risk matrix proposed in the study of [Katsouris, C. (2021)](https://arxiv.org/abs/2112.12031).

$\textbf{(b).}$ To compute the elements of the VaR-DCoVaR risk matrix with both OLS and IVX estimates (as a user defined option) based on pairwise quantile predictive regression models fitted on the nodes of the graph.

## Installation (under development)

The R package ‘tailEstimates’ will be able to be installed from Github.

## Usage 

```R

# After development the package will be able to be installed using
install.packages("tailEstimates")
library("tailEstimates")

```


## TENET Dataset ([Härdle et al. (2016)](https://www.sciencedirect.com/science/article/pii/S0304407616300161))

### Firm Specific Variables

- Leverage = Total Assets / Total Equity.
- Maturity Mismatch = Short term Debt / Total liabilities.
- Size = Log of Total Book Equity.
- Market-to-book = Market Value of Total Equity / Book Value of Total Equity.

### Macroeconomic Variables

- Variable 1 = the implied volatility index (VIX).
- Variable 2 = the short term liquidity spread calculated as the difference between the three-month repo rate and the three-month bill rate.
- Variable 3 = the changes in the three-month Treasury bill rate.
- Variable 4 = the changes in the slope of the yield curve corresponding to the yield spread between the ten year Treasury rate and the three-month bill rate from FRB.
- Variable 5 = the changes in the credit spread between BAA rated bonds and the Treasury rate.
- Variable 6 = the weekly S&P500 index returns.
- Variable 7 = the weekly Dow Jones US Real Estate index returns.

## Empirical Application

This short empirical study can help us to better understand the methodology used for fitting predictive regression models based on the IVX instrumentation of KMS (2015) by considering equation-by-equation estimates. Moreover, since the TENET dataset includes both system covariates (such as the macroeconomic variables) as well as firm-specific variables, we can also investigate with more details the statistical procedure for constructing the dynamic VaR-DCoVaR risk matrix as well as related asymptotic theory properties.   

-	Step 1: For $y_t$ we use the stock returns of each firm and for $x_t$ the set of macroeconomic and firm variables corresponding to each firm. First, we construct the lag $x_t$ variables and regress $y_t$ on $x_t$ to obtain the A matrix with the estimated coefficients of this multivariate regression. Then, we estimate the residuals of the predictive regression, and we obtain the coefficients of the Rn matrix, which is simply estimated by solving with respect to the residuals in a regression model with no intercept. 

-	Step 2: Estimation of predictive regression matrices. First, we estimate the autoregressive residuals, the residuals correlation matrix and the corresponding covariance matrix. These estimations help us to obtain the Omega matrices.

-	Step 3: Instrument construction. This step includes the construction/estimation of all necessary instrumental variables/matrices to apply the IVX methodology.  Thus, in this step we obtain estimates of the matrices $R_z$, $Z$, $y_t$, $x_t$ and the computation of the Aivx and Wixv matrices. 

### Estimation Examples

```R

# Firm 1
# Predictive Regression model with both nonstationary regressors and exogenous stationary regressors

# Nonstationary regressors represent the macroeconomic variables
# Stationary regressors represent the firm characteristic variables

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

```


# Key References

$\textbf{[1]}$ Katsouris, C. (2021). Optimal Portfolio Choice and Stock Centrality for Tail Risk Events. arXiv preprint [arXiv:2112.12031](https://arxiv.org/abs/2112.12031).

$\textbf{[2]}$ Tobias, A., & Brunnermeier, M. K. (2016). CoVaR. The American Economic Review, 106(7), 1705. [DOI:10.1257/aer.20120555](https://www.aeaweb.org/articles?id=10.1257/aer.20120555).

$\textbf{[3]}$ Härdle, W. K., Wang, W., & Yu, L. (2016). Tenet: Tail-event driven network risk. Journal of Econometrics, 192(2), 499-513. [DOI:10.1016/j.jeconom.2016.02.013](https://www.sciencedirect.com/science/article/pii/S0304407616300161).  

$\textbf{[4]}$ Lee, J. H. (2016). Predictive quantile regression with persistent covariates: IVX-QR approach. Journal of Econometrics, 192(1), 105-118. [https://doi.org/10.1016/j.jeconom.2015.04.003](https://www.sciencedirect.com/science/article/pii/S0304407615003000).

$\textbf{[5]}$ Kostakis, A., Magdalinos, T., & Stamatogiannis, M. P. (2015). "Robust econometric inference for stock return predictability". The Review of Financial Studies, 28(5), 1506-1553.

# Code of Coduct

Please note that the ‘tailEstimates’ project will be released with a Contributor Code of Coduct (under construction). By contributing to this project, you agree to abide by its terms.

# Declarations

The author declares no conflicts of interest.

In particular, the author declares that has no affiliations with or involvement in any organization or entity with any financial interest (such as honoraria; educational grants; participation in speakers’ bureaus; membership, employment, consultancies, stock ownership, or other equity interest; and expert testimony or patent-licensing arrangements), or non-financial interest (such as personal relationships and/or affiliations) in the subject matter or materials discussed in the manuscript and implemented in the R package.

# Acknowledgments

The author greatfully acknowledges financial support from Graduate Teaching Assistantships at the School of Economic, Social and Political Sciences of the University of Southampton as well as from the Vice-Chancellor's PhD Scholarship of the University of Southampton, for the duration of the academic years 2018 to 2021. The author also gratefully acknowledges previously obtained funding from Research Grants of interdisciplinary Centers of research excellence based at the University of Cyprus (UCY) as well as at the University College London (UCL).

Part of the aspects implemented in the R package 'tailEstimates', are discussed in the PhD thesis of the author (Christis G. Katsouris) titled: "Aspects of Estimation and Inference for Predictive Regression Models", completed under the supervision of Professor Jose Olmo and Professor Anastasios Magdalinos. In his PhD thesis, Katsouris C. generalises the work of Phillips P.C.B (under the guidance of his advisor Magdalinos T.) on robust econometric inference for nonstationary time series models, under more general persistence conditions than his predecessors. Furthermore, he proposes testing methodologies for structural break detection in predictive regressions.

The author will be joining the University of Exeter Business School as a Visiting Lecturer in Economics (Education and Scholarship) at the Department of Economics in September 2022.

# Historical Background

> Standing on the shoulders of giants.
> 
> $\textit{''If I have been able to see further, it was only because I stood on the shoulders of giants."}$
> $- \text{Isaac Newton, 1676}$ 

$\textbf{John Von Neumann}$ (28 December 1903 – 8 February 1957) was a Hungarian-American mathematician, physicist, computer scientist, engineer and polymath. He was regarded as having perhaps the widest coverage of any mathematician of his time and was said to have been "the last representative of the great mathematicians who were equally at home in both pure and applied mathematics". Von Neumann made major contributions to many fields, including mathematics (measure theory, functional analysis, ergodic theory, group theory, lattice theory, representation theory, operator algebras, matrix theory, geometry, and numerical analysis), physics (quantum mechanics, hydrodynamics, nuclear physics and quantum statistical mechanics), economics (game theory and general equilibrium theory), computing (linear programming, scientific computing, stochastic computing), and statistics. He was a pioneer of the application of operator theory to quantum mechanics in the development of functional analysis, and a key figure in the development of game theory and the concepts of cellular automata and the digital computer. Von Neumann published over 150 papers in his life. His last work, an unfinished manuscript written while he was in the hospital, was later published in book form as The Computer and the Brain (Source: [Wikipedia](https://en.wikipedia.org/wiki/John_von_Neumann)). 
