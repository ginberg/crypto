library(parallel)
source("scraper.R")

#' Get historic crypto currency market data
#'
#' Scrape the crypto currency historic market tables from
#' Coinmarketcap <https://coinmarketcap.com> and display
#' the results in a date frame.
#' 
#' @param coins coin list, sorted on rank
#' @param startDate
#' @param endDate 
#'
#' @return Crypto currency historic OHLC market data in a dataframe:
#'   \item{slug}{Coin url slug}
#'   \item{symbol}{Coin symbol}
#'   \item{name}{Coin name}
#'   \item{date}{Market date}
#'   \item{ranknow}{Current Rank}
#'   \item{open}{Market open}
#'   \item{high}{Market high}
#'   \item{low}{Market low}
#'   \item{close}{Market close}
#'   \item{volume}{Volume 24 hours}
#'   \item{market}{USD Market cap}
#'   \item{close_ratio}{Close rate, min-maxed with the high and low values that day}
#'   \item{spread}{Volatility premium, high minus low for that day}
#'
getCoinData <- function(coins, startDate, endDate) {
    cat("Retrieves coin market history from coinmarketcap.")
    i <- "i"
    options(scipen = 999)
    
    length <- as.numeric(length(coins$url))
    zrange <- 1:as.numeric(length(coins$url))
    
    ptm <- proc.time()
    pb <- txtProgressBar(max = length, style = 3)
    progress <- function(n) setTxtProgressBar(pb, n)
    opts <- list(progress = progress)
    attributes <- paste0(coins$url, "?start=", startDate, "&end=", endDate)
    slug <- coins$slug
    results <- lapply(zrange, FUN = function(i) scraper(attributes[i], slug[i]))
    close(pb)
    print(proc.time() - ptm)

    marketdata <- NULL
    for(i in zrange){
      result_slug <- slug[i]
      result <- results[[i]][, c("Date", "Close", "Market Cap")]
      colnames(result) <- c("Date", paste0("price", result_slug), paste0("market", result_slug))
      if(is.null(marketdata)){
        marketdata <- result
      } else{
        marketdata <- left_join(marketdata, result, by = "Date") 
      }
    }
    marketdata$Date <- suppressWarnings(lubridate::mdy(unlist(marketdata$Date)))
    cols <- c(2:length(colnames(marketdata)))
    marketdata[, cols] <- apply(marketdata[, cols], 2, function(x) gsub(",", "", x))
    marketdata[, cols] <- suppressWarnings(apply(marketdata[, cols], 2, function(x) as.numeric(x)))
    return(marketdata)
  }

#' Retrieves name, symbol, slug and rank for all tokens
#'
#' List all of the crypto currencies that have existed on Coinmarketcap
#' and use this to populate the URL base for scraping historical market
#' data. It retrieves name, slug, symbol and rank of cryptocurrencies from
#' CoinMarketCap and creates URLS for \code{scraper()} to use.
#'
#' @param coin Name, symbol or slug of crypto currency
#' @param ... No arguments, return all coins
#'
#' @return Crypto currency historic OHLC market data in a dataframe:
#'   \item{symbol}{Coin symbol (not-unique)}
#'   \item{name}{Coin name}
#'   \item{slug}{Coin URL slug (unique)}
#'   \item{rank}{Current rank by market cap}
#'   \item{url}{Historical market tables urls for scraping}
#'
listCoins <- function(coin = NULL) {
  today <- gsub("-", "", lubridate::today())
  json <-
    "https://files.coinmarketcap.com/generated/search/quick_search.json"
  coins <- jsonlite::read_json(json, simplifyVector = TRUE)
  name <- coins$name
  slug <- coins$slug
  symbol <- coins$symbol
  c1 <- subset(coins, name %in% coin)
  c2 <- subset(coins, symbol %in% coin)
  c3 <- subset(coins, slug %in% coin)
  if (nrow(c1) > 0)
    coins <- c1
  if (nrow(c2) > 0)
    coins <- c2
  if (nrow(c3) > 0)
    coins <- c3
  coins <-
    data.frame(
      symbol = coins$symbol,
      name = coins$name,
      slug = coins$slug,
      rank = coins$rank
    )
  length <- as.numeric(length(coins$slug))
  cmcurl <-paste0("https://coinmarketcap.com/currencies/", coins$slug, "/historical-data/")
  baseurl <- c(cmcurl)
  coins$symbol <- as.character(toupper(coins$symbol))
  coins$name <- as.character(coins$name)
  coins$slug <- as.character(coins$slug)
  coins$url <- as.character(baseurl)
  coins$rank <- as.numeric(coins$rank)
  return(coins)
}