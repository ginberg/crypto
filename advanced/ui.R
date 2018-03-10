# ui part

shinyUI(
  fluidPage(
    tagList(tags$head(
      tags$link(rel="stylesheet", type="text/css", href="style.css")
    )),
    p(),
    cryptoDashboardUI("cryptoDashboard")
  )
)