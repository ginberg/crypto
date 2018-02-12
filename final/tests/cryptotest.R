app <- ShinyDriver$new("../")
app$snapshotInit("cryptotest")

app$setInputs(selectCoins = c("bitcoin", "ethereum", "litecoin"))
app$setInputs(selectOutput = "price")
app$snapshot()
