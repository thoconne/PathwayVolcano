library(ggplot2)
library(shiny)
library(dplyr)
library(stringr)

# Install from GitHub
if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
devtools::install_github("reactome/ReactomeContentService4R")

library(ReactomeContentService4R)

# Load data containing Reactome pathways
#pathway_data <- getSchemaClass(class = "Pathway", species = "human", all = TRUE)
pathway_data <- ReactomeContentService4R::getSchemaClass(class = "Pathway", species = "human", all = TRUE)


# Define UI
ui <- fluidPage(
  
  # Use tags$style to embed CSS code within the Shiny UI - sets the background color
  tags$style(HTML("
    body {
      background-color: #fcf5f6; /* Change this hex code to the desired color */
    }
    
    .title-stripe {
      background-color: #910a21; /* Change this color to your desired stripe color */
      padding: 15px;
      text-align: center;
      color: white;
      font-family: Georgia, sans-serif;
      font-size: 24px;
      font-weight: bold;
    }

    .striped-text {
      background-color: #a30822; /* Change this to your desired color */
      padding: 15px;
      color: white; /* Text color */
      font-family: Georgia, sans-serif;
      font-size: 18px;
      font-weight: bold;
      border-radius: 5px; /* Optional: Adds rounded corners */
    }
    
    .custom-sidebar {
      background-color: #5fbf56; /* background color*/
      padding: 15px;
      border-radius: 5px;
    }
    
    .dataTables_wrapper {
      background-color: #f0f8ff; /* Light blue background behind the table */
      padding: 15px;
      border-radius: 5px;
    }
    
    .shiny-input-container > label {
      font-size: 16px; /* Adjust this value to increase/decrease label size */
      font-weight: bold; /* Optional: Makes the label bold */
      color: #333333; /* Optional: Change the label color */
      font-family: Georgia, sans-serif;
    }
    
    table.dataTable {
      background-color: #fffcfd; /* White background for the table itself */
      border-collapse: separate;
            font-weight: bold; /* Optional: Makes the label bold */
            font-size: 18px; /* Adjust this value to increase/decrease label size */
      border-spacing: 0 10px; /* Add some space between rows */
    }
    
    table.dataTable th, table.dataTable td {
      background-color: #fffcfd; /* Light cyan background for table cells */
            font-size: 18px; /* Adjust this value to increase/decrease label size */
            font-weight: bold; /* Optional: Makes the label bold */
      padding: 10px;
    }
    
    /* Ensure plot and table have the same width and are centered */
    #scatterplot, #modified_table {
      width: 75%;
      margin: 0 auto;
    }

    .plot-container {
      position: relative;
      width: 100%;
      #padding-bottom: 66.66%; /* Aspect ratio 1.5 (height / width = 2/3) */
      height: 0;
    }
    .plot-container iframe {
      position: absolute;
      width: 100%;
      height: 100%;
    }
    
  ")),
  
  # Title panel with a colored stripe
  div(class = "title-stripe", "PATHWAY VOLCANO"),
  
  div(class = "striped-text", 
      style = "text-align: center; margin: 0 auto;", 
      "Pathway specific volcano plot for differential expression data using the Reactome Pathway Database."),
  
  fluidRow(
    column(12, 
           #HTML("<span style='font-family: Georgia; color: gray40; font-size: 18px;'><b>This program generates volcano plots for the genes associated with a selected Reactome pathway. Please upload your data file and enter the Reactome pathway ID to begin.</b></span>"),
           br(), # Add a line break for spacing
           actionLink("show_instructions", "Click here for detailed instructions", style = "font-size: 20px; color: #910a21; font-weight: bold;") # Link with increased font size
    )
  ),
  sidebarLayout(
    sidebarPanel(
      style = "background-color: #f0dfe1; padding: 15px; border-radius: 5px",
      
      # Input: Data file upload
      fileInput("data_file", "Upload Data File"),
      actionButton("load_example", "Use Example Dataset"),
      
      # Input: Pathway Query Term
      textInput("displayNameInput", "Enter Pathway Query Term:", ""),
      
      # Input: Reactome ID
      textInput("ReactomeID", "Enter Reactome Pathway ID: (type ALL for full plot)", ""),
      
      # Slider inputs for FC and PV
      sliderInput("fc_slider", "Fold Change Threshold:", min = 0, max = 2, value = 0.58, step = 0.1),
      sliderInput("pv_slider", "Adjusted P-value Threshold:", min = 0, max = 0.1, value = 0.05, step = 0.001),
      sliderInput("font_size_slider", "Font Size for Labels:", min = 1, max = 6, value = 3, step = 1),
      sliderInput("label_offset_slider", "Labels offset:", min = 0.05, max = 1.0, value = 0.1, step = 0.1),
      
      
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
  # Observe event to trigger the modal when the link is clicked
  observeEvent(input$show_instructions, {
    showModal(modalDialog(
      title = "Instructions",
      "Here are the instructions for using this application:",
      tags$ul(
        tags$li("Upload your data file using the 'Upload Data File' button."),
        tags$li("Enter the Reactome Pathway ID in the text box provided."),
        tags$li("Use the sliders to adjust the fold change and p-value thresholds."),
        tags$li("Check the 'Show Gene IDs' box to display gene labels on the volcano plot."),
        tags$li("Download the filtered gene table using the 'Download Gene Table' button.")
      ),
      easyClose = TRUE,
      footer = modalButton("Close")
    ))
  })
  
  # Render the program description
  #output$description <- renderText({
  #  HTML("<span style='font-family: Georgia; color: blue; font-size: 18px;'><b>This program generates volcano plots for the genes associated with a selected Reactome pathway. Please upload your data file and enter the Reactome pathway ID to begin.</b></span>")
  #})
  
  # Filter pathway data based on query term
  filtered_df <- reactive({
    req(input$displayNameInput)
    filtered <- pathway_data[grepl(input$displayNameInput, pathway_data$displayName, ignore.case = TRUE), c("displayName", "stId")]
    if (nrow(filtered) == 0) {
      return("No matching data found.")
    } else {
      filtered <- filtered[, c(2,1)]
      colnames(filtered) <- c("Reactome ID", "Pathway")
      return(filtered)
    }
  })
  
  # Render filtered pathway data table
  output$filteredData <- renderDataTable({
    filtered_df()
  })
  
  # Load data from the uploaded file
  uploaded_data <- reactive({
    # If the user clicks "Use Example Dataset"
    if (input$load_example > 0 && is.null(input$data_file)) {
      example_path <- system.file("extdata", "GSE51931_Cachexia_vs_Control_Liver.csv", package = "PathwayVolcano")
      data <- read.csv(example_path)
    } else {
      req(input$data_file)
      data <- read.csv(input$data_file$datapath)
    }
    
    # Format GeneSymbol column
    if ("GeneSymbol" %in% colnames(data)) {
      data$GeneSymbol <- str_to_title(data$GeneSymbol)
    }
    
    return(data)
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
    
    # Ensure levels are always set for consistent coloring
    modified$diffexpressed <- factor(modified$diffexpressed, levels = c("DOWN", "UP"))
    
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
  }, options = list(pageLength = 10, scrollX = TRUE, dom = 'l'))
  
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
        scale_color_manual(values = c("DOWN" = "blue", "UP" = "red")) + 
        labs(color = 'Fold Change', x = "Log2 Fold Change", y = "-Log10 adj P-value") + 
        theme_classic() +
        theme(
          axis.line = element_line(colour = "black", size = 1, linetype = "solid"), 
          axis.title.x = element_text(size = 10, color = "black", face = "bold"),
          axis.title.y = element_text(size = 10, color = "black", face = "bold"),
          axis.text.x  = element_text(size = 10, color = "black", face = "bold"),
          axis.text.y  = element_text(size = 10, color = "black", face = "bold"),
          plot.title = element_text(size = 12, hjust = 0.1, face = "bold")
        )
      
      if (input$labelToggle) {
        p <- p + geom_text(aes(label = gene.label), nudge_y = input$label_offset_slider, size = input$font_size_slider)
      }
    }
    
    plotly::ggplotly(p)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)