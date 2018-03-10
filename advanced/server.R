server <- function(input,output){

  ## Cache results
  
  cachedCoinList <- data.table(listCoins())
  initialCoinList <- cachedCoinList[symbol %in% initialSelectedCoins, ]
  cachedCoinData <- data.table(getCoinData(initialCoinList, initialCacheDateFormatted, initialEndDateFormatted))
    
  callModule(cryptoDashboard, "cryptoDashboard", cachedCoinList, cachedCoinData)
}