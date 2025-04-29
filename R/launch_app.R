#' Launch the PathwayVolcano Shiny App
#'
#' This function launches the interactive Shiny app for exploring pathway-specific volcano plots.
#' @export
runPathwayVolcano <- function() {
  app_file <- system.file("app", "app.R", package = "PathwayVolcano")
  if (app_file == "") stop("Cannot find app.R in inst/app")
  shiny::runApp(app_file, launch.browser = TRUE)
}
