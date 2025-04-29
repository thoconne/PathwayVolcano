# install.R — installs PathwayVolcano and its dependencies

# Install devtools if it's not already available
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Install PathwayVolcano from GitHub
devtools::install_github("thoconne/PathwayVolcano")

# Install ReactomeContentService4R (GitHub-only dependency)
if (!requireNamespace("ReactomeContentService4R", quietly = TRUE)) {
  devtools::install_github("reactome/ReactomeContentService4R")
}

message("Installation complete. You can now run PathwayVolcano using:")
message("library(PathwayVolcano)")