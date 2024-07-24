library(calibrate)
library(plotly)
library(ggplot2)
library(ggrepel)
library(shiny)
library(dplyr)
library(tidyverse)
library(ReactomeContentService4R)

# Load data containing Reactome pathways
pathway_data <- getSchemaClass(class = "Pathway", species = "human", all = TRUE)

# Define UI
ui <- fluidPage(
  
  # Use tags$style to embed CSS code within the Shiny UI - sets the background color
  tags$style(HTML("
    body {
      background-color: #FFFFFF; /* Change this hex code to the desired color */
    }
  ")),
  
  titlePanel("Pathway Selected Volcano Plots"),
  fluidRow(
    column(12, 
           HTML("<span style='font-family: Arial; color: gray40; font-size: 18px;'><b>This program generates volcano plots for the genes associated with a selected Reactome pathway. Please upload your data file and enter the Reactome pathway ID to begin.</b></span>"),
           br() # Add a line break for spacing
    )
  ),
  sidebarLayout(
    sidebarPanel(
      # Input: Data file upload
      fileInput("data_file", "Upload Data File"),
      
      # Input: Pathway Query Term
      textInput("displayNameInput", "Enter Pathway Query Term:", ""),
      
      # Input: Reactome ID
      textInput("ReactomeID", "Enter Reactome Pathway ID: (type ALL for full plot)", ""),
      
      # Slider inputs for FC and PV
      sliderInput("fc_slider", "Fold Change Threshold:", min = 0, max = 2, value = 0.58, step = 0.1),
      sliderInput("pv_slider", "Adjusted P-value Threshold:", min = 0, max = 0.1, value = 0.05, step = 0.001),
      sliderInput("font_size_slider", "Font Size for Labels:", min = 1, max = 6, value = 3, step = 1),
      sliderInput("label_offset_slider", "Labels offset:", min = 0.2, max = 1.0, value = 0.3, step = 0.1),
      
      
      # Action button to trigger data table update
      #actionButton("update_table", "Update Table"),
      
      # toggle box for Gene ID labels
      checkboxInput("labelToggle", "Show Gene IDs", value = TRUE),
      
      # Download button
      downloadButton("download_data", "Download Gene Table")
    ),
    mainPanel(
      plotlyOutput("scatterplot", height = "600px", width = "800px"),
      
      # Display modified data table
      dataTableOutput("modified_table")
    )
  ),
  # New tab for pathway selection
  tabPanel("Pathway Selection",
           fluidRow(
             column(12, 
                    dataTableOutput("filteredData")
             )
           )
  )
)

# Define server logic
server <- function(input, output) {
  # Render the program description
  output$description <- renderText({
    HTML("<span style='font-family: Arial; color: blue; font-size: 18px;'><b>This program generates volcano plots for the genes associated with a selected Reactome pathway. Please upload your data file and enter the Reactome pathway ID to begin.</b></span>")
  })
  
  # Filter pathway data based on query term
  filtered_df <- reactive({
    req(input$displayNameInput)
    filtered <- pathway_data[grepl(input$displayNameInput, pathway_data$displayName, ignore.case = TRUE), c("displayName", "stId")]
    if (nrow(filtered) == 0) {
      return("No matching data found.")
    } else {
      colnames(filtered) <- c("Pathway", "Reactome ID")
      return(filtered)
    }
  })
  
  # Render filtered pathway data table
  output$filteredData <- renderDataTable({
    filtered_df()
  })
  
  # Load data from the uploaded file
  uploaded_data <- reactive({
    req(input$data_file)
    read.csv(input$data_file$datapath)
  })
  
  # Apply changes to the subsetted data frame
  modified_data <- reactive({
    req(uploaded_data(), input$ReactomeID)
    
    # Define fold change and p-value thresholds using slider inputs
    FC <- input$fc_slider
    PV <- input$pv_slider
    
    # Get the Reactome pathway ID provided by the user
    pathway_id <- input$ReactomeID
    
    if (pathway_id == "ALL") {
      # Use all data without filtering
      subsetted_data <- uploaded_data()
    } else {
      # Get gene set based on Reactome pathway ID
      gene_set <- str_to_title(tolower(event2Ids(pathway_id)[[1]]))
      # Subset the data frame based on the gene set
      subsetted_data <- subset(uploaded_data(), GeneSymbol %in% gene_set)
    }
    
    # Check if subsetted data is empty
    if (nrow(subsetted_data) == 0) {
      # Return a message indicating no significant genes match the pathway
      return(data.frame(Message = "No significant genes match this pathway"))
    }
    
    # Create a new data frame with modifications applied
    modified <- subsetted_data
    
    # Label genes as up or down regulated
    modified$diffexpressed <- NA
    modified$diffexpressed[modified$log2FoldChange > FC & modified$padj < PV] <- "UP"
    modified$diffexpressed[modified$log2FoldChange < -FC & modified$padj < PV] <- "DOWN"
    
    # Assign gene labels
    modified$gene.label <- ifelse(abs(modified$log2FoldChange) > FC & modified$padj < PV & input$labelToggle, modified$GeneSymbol, NA)
    
    # Return the modified data frame
    modified
  })
  
  # Write modified_data() to a CSV file (optional)
  observeEvent(modified_data(), {
    write.csv(modified_data(), "modified_data.csv", row.names = FALSE)
  })
  
  # Render modified data table
  output$modified_table <- renderDataTable({
    # Filter modified data for genes labeled as UP or DOWN
    filtered_data <- subset(modified_data(), diffexpressed %in% c("UP", "DOWN"))
    # Select only desired columns
    filtered_data <- filtered_data[, c("GeneSymbol", "log2FoldChange", "padj")]
    # Rename columns
    names(filtered_data) <- c("Gene Symbol", "Log2 Fold Change", "Adjusted P-value")
    # Return the filtered data table
    filtered_data
  }, options = list(pageLength = -1, scrollX = TRUE, dom = 't'))
  
  # Define download handler for the data  # <---- Added block
  output$download_data <- downloadHandler(
    filename = function() {
      paste("filtered_data-", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      filtered_data <- subset(modified_data(), diffexpressed %in% c("UP", "DOWN"))
      write.csv(filtered_data[, c("GeneSymbol", "log2FoldChange", "padj")], file, row.names = FALSE)
    }
  )
  
  # Plotting logic
  output$scatterplot <- renderPlotly({
    # Check if the modified data frame contains a message
    if ("Message" %in% names(modified_data())) {
      # If so, display the message as a plot title
      p <- ggplot() +
        geom_text(aes(x = 0.5, y = 0.5, label = Message), size = 10, color = "red") +
        theme_void()
    } else {
      # Otherwise, proceed with generating the scatterplot
      p <- ggplot(data = modified_data(), aes(x = log2FoldChange, y = -log10(padj), col = diffexpressed, label = GeneSymbol)) +
        geom_vline(xintercept = c(-input$fc_slider, input$fc_slider), col = "gray", linetype = 'dashed', size = 1) +
        geom_hline(yintercept = -log10(input$pv_slider), col = "gray", linetype = 'dashed', size = 1) + 
        geom_point(size = 2) +
        scale_color_manual(values = c("blue", "red", "gray"), labels = c("Downregulated", "Upregulated", " ")) + 
        labs(color = 'Fold Change', x = "Log2 Fold Change", y = "-Log10 adj P-value") + 
        theme_classic() +
        theme( axis.line = element_line(colour = "black", size = 1, linetype = "solid"), 
               axis.title.x = element_text(size = 10, color = "black", face = "bold"),
               axis.title.y = element_text(size = 10, color = "black", face = "bold"),
               axis.text.x  = element_text(size = 10, color = "black", face = "bold"),
               axis.text.y  = element_text(size = 10, color = "black", face = "bold"),
               plot.title = element_text(size = 12, hjust = 0.1, face = "bold"))
      
      if (input$labelToggle) {
        p <- p + geom_text(aes(label = gene.label), nudge_y = input$label_offset_slider, size = input$font_size_slider)
      }
    }
    
    ggplotly(p)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)