app <- ShinyDriver$new("../")
app$snapshotInit("crypto_test")

app$setInputs(selectCoins = c("bitcoin", "ethereum", "litecoin"))
app$snapshot()
app$setInputs(selectCoins = c("bitcoin", "ethereum"))
app$setInputs(selectCoins = c("bitcoin", "ethereum", "neo"))
app$setInputs(selectOutput = "price")
app$setInputs(selectDate = c("2018-01-01", "2018-01-28"))
