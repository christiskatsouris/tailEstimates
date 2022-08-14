# tailEstimates

## Optimal Portfolio Choice under tail events

Compute least squares estimates and IVX estimates with pairwise quantile predictive regressions for the VaR-CoVaR risk matrix proposed in the paper of [Katsouris, C. (2021)](https://arxiv.org/abs/2112.12031).

## Installation (under development)

The R package ‘tailEstimates’ will be able to be installed from Github.

## Usage 

```R

# After development the package will be able to be installed using
install.packages("tailEstimates")
library("tailEstimates")

```


## TENET Dataset

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

# Key References

$\textbf{[1]}$ Katsouris, C. (2021). Optimal Portfolio Choice and Stock Centrality for Tail Risk Events. arXiv preprint [arXiv:2112.12031](https://arxiv.org/abs/2112.12031).

$\textbf{[2]}$ Tobias, A., & Brunnermeier, M. K. (2016). CoVaR. The American Economic Review, 106(7), 1705. [DOI:10.1257/aer.20120555](https://www.aeaweb.org/articles?id=10.1257/aer.20120555).

$\textbf{[3]}$ Härdle, W. K., Wang, W., & Yu, L. (2016). Tenet: Tail-event driven network risk. Journal of Econometrics, 192(2), 499-513. [DOI:10.1016/j.jeconom.2016.02.013](https://www.sciencedirect.com/science/article/pii/S0304407616300161).  

$\textbf{[4]}$ Lee, J. H. (2016). Predictive quantile regression with persistent covariates: IVX-QR approach. Journal of Econometrics, 192(1), 105-118.

# Code of Coduct

Please note that the ‘tailEstimates’ project will be released with a Contributor Code of Coduct (under construction). By contributing to this project, you agree to abide by its terms.

# Declarations

The author declares no conflicts of interest.

In particular, the author declares that has no affiliations with or involvement in any organization or entity with any financial interest (such as honoraria; educational grants; participation in speakers’ bureaus; membership, employment, consultancies, stock ownership, or other equity interest; and expert testimony or patent-licensing arrangements), or non-financial interest (such as personal relationships and/or affiliations) in the subject matter or materials discussed in the manuscript and implemented in the R package.
