library(shiny)
crypto <- read.csv("crypto-data.csv", stringsAsFactors = FALSE)

ui <- fluidPage(
  titlePanel('Cryptocurrency dashboard'),
  sidebarLayout(
    sidebarPanel(
      selectInput('selectCoins', 'Select crypto(s)', choices = c("BTC", "ETH", "LTC"), multiple = T),
      selectInput('selectOutput', 'Select output', choices = c('Market Cap' = "market", Price = "price")),
      dateRangeInput('selectDate', 'Select date', start = min(crypto$Date), end = max(crypto$Date))
    ),
    mainPanel(dygraphOutput("priceGraph"))
  )
)

server <- function(input, output) {}

shinyApp(ui = ui, server = server)