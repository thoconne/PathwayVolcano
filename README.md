![PathwayVolcanoBanner](images/image1.png)

**Pathway Volcano:  Latest version = PathwayVolcano_041525.R**

Pathway Volcano is an R Shiny script that uses the Reactome API along with graphical functions in R to generate pathway specific volcano plots from differential expression data.

The following packages are called in the script, but must be installed before running the program:
```r
library(plotly)
library(ggplot2)
library(shiny)
library(dplyr)
library(tidyverse)
library(ReactomeContentService4R)
```

**Differential Expression File Input**

The input must be a csv file that contains a column for GeneSymbols, log2FoldChange and padj.  The column names must be exactly as written (case sensitive).  Any additional columns in your dataset will be ignored. 

**Requirements**
To use Pathway Volcano, the user will have to have a version of R and RStudio loaded.  
For instructions on downloading and installing R visit the Comprehensive R Archive Network (CRAN) http://cran.r-project.org/ and select the download appropriate for your system.  
To install RStudio visit the RStudio download page at http://posit.co/download/rstudio-desktop/ and select the download appropriate for your system.  Follow the prompts on the downloaded installers for each program.

**Install ReactomeContentService4R:**  Prior to installing Pathway Volcano you must install the ReactomeContentService4R package to enable the connection to the Reactome database 
- remotes::install_github("reactome/ReactomeContentService4R")

 **Installation of Pathway Volcano:**  install the package from GitHub by entering the following command in R studio to install

- remotes::install_github("thoconne/PathwayVolcano")

 **Launch Pathway Volcano:**  load and launch the package by entering the following commands
- library(PathwayVolcano)
- runPathwayVolcano()

See **Cancer Cachexia Analysis** in the docs directory to see a fully worked example. [Example Analysis](docs/Example_Analysis.md)  
This dataaset can be selected with the **Use Example Dataset** option from the home page.
