![PathwayVolcanoBanner](images/image1.png)

**PathwayVolcano:  Latest version = PathwayVolcano_012825.R**

To use Pathway Volcano, the user will have to have a version of R and RStudio loaded.  For instructions on downloading and installing R visit the Comprehensive R Archive Network (CRAN) http://cran.r-project.org/ and select the download appropriate for your system.  To install RStudio visit the RStudio download page at http://posit.co/download/rstudio-desktop/ and select the download appropriate for your system.  Follow the prompts on the downloaded installers for each program.

Pathway Volcano is an R Shiny script that uses the Reactome API along with graphical functions in R to generate pathway specific volcano plots for differential expression data.

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

The input must be a csv file that contains a column for GeneSymbols, log2FoldChange and padj.  The column names must be exactly as written (case sensitive).  Any additional columns in your dataset will be ignored. Example data is in the data directory [Example Data](data/GSE51931_Cachexia_vs_Control_Liver.csv) 

**Launching the Program**

To launch the program, simply load the R script in R Studio and select Run App at the top right of the program window.   The program will appear in a web page.  The program calls the Reactome API and a list of all pathways is generated which in the current version of Reactome (version 91, released Feb 10th, 2024), contain 2751 pathways. 

See **Cancer Cachexia Analysis** in the docs directory to see a fully worked example. [Example Analysis](docs/Example_Analysis.md)  

