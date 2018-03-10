server <- function(input,output){

  # add module server part
  callModule(cryptoDashboard, "cryptoDashboard", cachedCoinList, cachedCoinData)

}