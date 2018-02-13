app <- ShinyDriver$new("../")
app$snapshotInit("crypto_test")

app$setInputs(selectOutput = "price")
app$setInputs(selectCoins = "bitcoin")
app$snapshot()
