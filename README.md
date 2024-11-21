# PathwayVolcano:  Latest version = Pathway_specific_volcano_082024_v4.R
To use Pathway Volcano, the user will have to have a version of R and RStudio loaded.  For instructions on downloading and installing R visit the Comprehensive R Archive Network (CRAN) http://cran.r-project.org/ and select the download appropriate for your system.  To install RStudio visit the RStudio download page at http://posit.co/download/rstudio-desktop/ and select the download appropriate for your system.  Follow the prompts on the downloaded installers for each program.

Pathway Volcano is an R Shiny script that uses the Reactome API along with graphical functions in R to generate pathway specific volcano plots for differential expression data.
The following packages are called in the script, but must be installed before running the program:
library(plotly)
library(ggplot2)
library(shiny)
library(dplyr)
library(tidyverse)
library(ReactomeContentService4R)

The input must be a csv file that contains a column for GeneSymbols, log2FoldChange and padj.  The column names must be exactly as written.  Any additional columns in your dataset will be ignored.  The test dataset Test_RNASeq_data.csv is provided as an example.
Upon launching the program, the Reactome API is called, and a list of all pathways is generated which in the current version of Reactome (version 90, released October 2, 2024), contain 2742 pathways. 
The Enter Pathway Query Term box allows the user to enter a term which will then return a list of all of the Reactome Pathways with that term in the name.  
To view the entire experimental dataset, the term All is input resulting in all of the genes shown.
When a query term such as “glucose” is input, a table of Reactome pathways containing this term is generated and includes the Reactome ID and the full name of the pathway.
Next the user can copy and paste the Reactome ID for the selected pathway into the Enter Reactome Pathway box.  Using the Reactome ID for the Glucose Metabolism pathway, R-HSA-70326, the volcano plot showing only the genes in the experimental dataset that are involved in the Glucose Metabolism pathway.  
Below the volcano plot is a table of all of the genes in the experimental dataset which are part of this pathway along with the Log2 fold change and adjusted p-value.
Hovering at the upper right side of the volcano plot window gives some of the interactivity options including to zoom, pan, box select, lasso select, zoom in, zoom out, autoscale and reset axes.
The box and lasso select options focus on specific regions of the plot by graying out the genes outside of the selected regions.  
An option to download a png file of the plot is also provided.  
Slider bars in the left panel allow interactive changes of the fold change and p-value thresholds.  Note that for simplicity, the p-value threshold is adjusted as the raw value and then translated into the -log10 value on the plot.  
Gene IDs can be toggled on or off at the bottom and the font size and offset of the labels adjusted by slider bars to optimize the clarity of the plots.  
A button to download the gene table is at the bottom of the panel.   
