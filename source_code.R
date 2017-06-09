repo <- "https://cloud.r-project.org"

# How to use the MAVIS package:
if (!require(MAVIS)) {
  install.packages("MAVIS", repos = repo)
  library(MAVIS)
}
startmavis()

# Load/install the packages we require
# I'm loading lattice simply to obtain plots to visualize the data.
sapply(c("metafor", "lattice"), function(package_name) {
  if (!require(package_name, character.only = TRUE)) {
    install.packages(package_name, repos = repo)
    library(package_name, character.only = TRUE)
  }
})

# Load the dataset we need
data <- dat.bangertdrowns2004
head(data)
# Run ?dat.bangertdrowns2004 to see what the dataset represents

# Plotting our data
densityplot(
  ~ yi, data, xlab = "Standardized mean difference",
  main = "Density plot of effect sizes"
)
xyplot(
  x ~ Group.1, aggregate(
    as.numeric(data$id), by = list(data$year), FUN = length
  ), type = "o", main = "Effect sizes over time", grid = TRUE,
  xlab = "Year", ylab = "Number of effect sizes"
)
histogram(
  ~ grade, data, main = "Effect size distribution by grade",
  type = "count", ylab = "Number of effect sizes"
)
histogram(
  ~ wic + feedback + info + pers + imag + meta,
  main = "Proportions of potential moderators",
  scales = list(x = list(at = c(0, 1), labels = c("no", "yes"))),
  xlab = "Potential categorical moderators",
  data, layout = c(3, 2), type = "count",
  ylab = "Number of effect sizes"
)
densityplot(
  ~ ni, data, xlab = "Sample sizes",
  main = "Density plot of sample sizes"
)
densityplot(~ length, data, plot.points = FALSE, auto.key = TRUE)
densityplot(~ minutes, data, plot.points = FALSE)

# Conduct meta-analysis
(res.0 <- rma(
  yi = yi, vi = vi, ni = ni, data = data,
  measure = "SMD", test = "knha"
))
confint(res.0, level = .95) # Obtain CI on heterogeneity estimates

# Forest plot
forest(
  res.0, slab = paste0(data$author, " (", data$year, ")"),
  xlim = c(-2.5, 2.5), cex = .75
)
op <- par(cex = 1, font = 1)
text(-2.5, 50, "Author(s) (Year)", pos = 4)
text(2.9775, 50, "SMD [95% CI]", pos = 2)

# Moderation analysis with categorical variable
(res.1 <- rma(
  yi = yi, vi = vi, ni = ni, data = data,
  mods = ~ factor(grade),
  measure = "SMD", test = "knha"
))

# Publication bias
funnel(res.0) # Funnel plot
regtest(res.0) # Test of asymmetry
