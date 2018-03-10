library(data.table)
source("coin_data.R")

coinList <- listCoins()
coinSymbols <- coinList$symbol

availableOutputs <- c('Market Cap' = "market", Price = "price")
initialSelectedCoins <- c("BTC", "ETH", "XLM", "LTC", "NEO")
initialStartDate <- Sys.Date()-120
initialEndDate <- Sys.Date()
initialStartDateFormatted <- format(initialStartDate, "%Y%m%d")
initialEndDateFormatted <- format(initialEndDate, "%Y%m%d")
initialCacheDateFormatted <- format(Sys.Date()-360, "%Y%m%d")

# Get coin data
cachedCoinList <- data.table(listCoins())
initialCoinList <- cachedCoinList[symbol %in% initialSelectedCoins, ]
cachedCoinData <- data.table(getCoinData(initialCoinList, initialCacheDateFormatted, initialEndDateFormatted))

source("crypto_dashboard.R")