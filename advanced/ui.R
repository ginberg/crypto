# ui part

shinyUI(
  fluidPage(
    tagList(tags$head(
      tags$link(rel="stylesheet", type="text/css", href="style.css")
    )),
    p(),
    div(titlePanel('Cryptocurrency dashboard'), class = "title"),
    sidebarLayout(
      div(sidebarPanel(
          selectInput('selectCoins', 'Select crypto(s)', choices = coinSymbols, selected = initialSelectedCoins, multiple = T),
          selectInput('selectOutput', 'Select output', choices = availableOutputs, selected = c("Market Cap")),
          dateRangeInput('selectDate', 'Select date', start =  initialStartDate, end = initialEndDate), width = 2),
          class = "selection"
      ),
      mainPanel(
         div(dygraphOutput("priceGraph", width = "100%", height = "800px"), class = "graph"), width = 10
      )
    )
  )
)