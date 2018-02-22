app <- ShinyDriver$new("../")
app$snapshotInit("crypto_test")

app$snapshot()
app$setInputs(selectCoins = c("bitcoin", "ethereum", "neo"))
app$setInputs(selectOutput = "price")
app$setInputs(selectDate = c("2017-02-18", "2018-01-28"))
app$setInputs(selectDate = c("2018-01-01", "2018-01-28"))
