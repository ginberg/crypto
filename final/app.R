library(shiny)
library(xts)
library(dygraphs)

# read data
crypto <- read.csv("../crypto-data.csv", stringsAsFactors = FALSE)
crypto$Date <- as.Date(crypto$Date)

ui <- fluidPage(
  titlePanel('Cryptocurrency dashboard'),
  sidebarLayout(
    sidebarPanel(
      selectInput('selectCoins', 'Select crypto(s)', choices = c("bitcoin", "ethereum", "litecoin", "neo"), selected = c("bitcoin", "ethereum"), multiple = T),
      selectInput('selectOutput', 'Select output', choices = c('Market Cap' = "market", Price = "price")),
      dateRangeInput('selectDate', 'Select date', start = min(crypto$Date), end = max(crypto$Date)),
      width = 2
    ),
    mainPanel(
      div(dygraphOutput("priceGraph", width = "100%", height = "800px"), class = "graph"), width = 10
    )
  )
)

server <- function(input, output) {
  
  # get data
  getData <- reactive({
    selectedCoins <- input$selectCoins
    selectedOutput <- input$selectOutput
    dates <- input$selectDate
    startDate <- dates[1]
    endDate <- dates[2]
    
    # filter data
    cryptoColumns <- colnames(crypto)
    coinColumns <- cryptoColumns[cryptoColumns %in% paste0(selectedOutput, selectedCoins)]
    selectedColumns <- append("Date", coinColumns)
    data <- crypto[crypto$Date >= startDate & crypto$Date <= endDate, selectedColumns, drop=FALSE]

    # formatting in case of market cap
    if(selectedOutput == "market"){
       data[coinColumns] <- lapply(data[coinColumns], FUN = function(x) x/1000000000)
    }
    colnames(data) <- gsub(selectedOutput, "", colnames(data))
    data
  })
  
  # generate graph
  output$priceGraph <- renderDygraph({
    data <- getData()
    time_series <- xts(data, order.by = data$Date)
    dygraph(time_series) %>% 
      dyRangeSelector(dateWindow = c(min(data$Date), max(data$Date))) 
  })
}

shinyApp(ui = ui, server = server)