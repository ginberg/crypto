library(shiny)
library(dygraphs)
library(parallel)

cryptoDashboardUI <- function(id) {
  ns <- NS(id)
  
  fluidPage(
    tagList(tags$head(
      tags$link(rel="stylesheet", type="text/css", href="style.css")
    )),
    p(),
    div(titlePanel('Cryptocurrency dashboard'), class = "title"),
    sidebarLayout(
      div(sidebarPanel(
      selectInput(ns('selectCoins'), 'Select crypto(s)', choices = coinSymbols, selected = initialSelectedCoins, multiple = T),
      selectInput(ns('selectOutput'), 'Select output', choices = availableOutputs, selected = c("Market Cap")),
      dateRangeInput(ns('selectDate'), 'Select date', start =  initialStartDate, end = initialEndDate), width = 2),
      class = "selection"
    ),
    mainPanel(
      div(dygraphOutput(ns("priceGraph"), width = "100%", height = "800px"), class = "graph"), width = 10
  )))
}

cryptoDashboard <- function(input, output, session, cachedCoinList, cachedCoinData) {
  
  # get data
  getData <- reactive({
    selectedCoins <- input$selectCoins
    selectedOutput <- input$selectOutput
    dates <- input$selectDate
    startDate <- dates[1]
    endDate <- dates[2]
    
    # only retrieve new data when it's not in the cache
    if(length(setdiff(selectedCoins, initialSelectedCoins)) == 0 & startDate %in% cachedCoinData$Date){
      coinNames <- cachedCoinList[symbol %in% selectedCoins, ] %>% pull("slug")
      coinColumns <- paste0(selectedOutput, coinNames)
      selectedCols <- append("Date", coinColumns)
      data <- cachedCoinData[Date >= startDate & Date <= endDate, ..selectedCols]
      # formatting
      if(selectedOutput == "market"){
        data[, (coinColumns) := lapply(.SD, "/", 1000000000), .SDcols = coinColumns] # in billion
      }
      colnames(data) <- gsub(selectedOutput, "", colnames(data))
      data
    } else{
      coinList <- cachedCoinList[symbol %in% selectedCoins, ]
      data <- data.table(getCoinData(coinList, format(startDate, "%Y%m%d"), format(endDate, "%Y%m%d")))
      coinColumns <- colnames(data)[grepl(selectedOutput, colnames(data))]
      selectedCols <- append("Date", coinColumns)
      data <- data[, ..selectedCols]
      # formatting
      if(selectedOutput == "market"){
        data[, (coinColumns) := lapply(.SD, "/", 1000000000), .SDcols = coinColumns] # in billion
      }
      colnames(data) <- gsub(selectedOutput, "", colnames(data))
      data
    }
  })
  
  # get output name
  getOutput <- reactive({
    selectedOutput <- input$selectOutput
    df <- stack(availableOutputs)
    df[df$values == selectedOutput, "ind"]
  })
  
  # generate graph
  output$priceGraph <- renderDygraph({
    req(nrow(getData()) > 0)

    dygraph(data = getData(), main = getOutput(), ylab = ifelse(input$selectOutput == "market", "USD (billion)", "USD")) %>% 
      dyHighlight(highlightCircleSize = 5, 
                  highlightSeriesBackgroundAlpha = 0.2,
                  hideOnMouseOut = TRUE, highlightSeriesOpts = list(strokeWidth = 3)) %>%
      dyRangeSelector() %>%
      dyOptions(maxNumberWidth = 6, logscale = TRUE) %>%
      dyLegend(labelsSeparateLines = TRUE)
  })
}