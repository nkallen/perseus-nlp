CAPITAL = /^[Α-Ω]/

language = require('./language')

class Labelizer
  constructor: (@morpheus, @nounLabels) ->
  labelize: (tokens, i) ->
    return ['comma-punctuation'] if tokens[i] == ','
    return ['punc-punctuation'] if tokens[i] == '·'
    tokenWithoutAccent = language.stripAccents(tokens[i])
    morpheus = @morpheus.get(tokenWithoutAccent)
    return morpheus if morpheus != undefined
    return @nounLabels if CAPITAL.test(tokenWithoutAccent)
    return []

module.exports = Labelizer