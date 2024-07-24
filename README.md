# PathwayVolcano
R Shiny script to use the Reactome API to generate pathway specific volcano plots for RNA data
This script will take tables of transcriptomics data and allow the data to be filtered by pathways defined in the Reactome database
The input must be a file that contains a column for GeneSymbols, log2FoldChange and padj.  The column names must be exactly as written.  Any additional columns in your dataset will be ignored.
