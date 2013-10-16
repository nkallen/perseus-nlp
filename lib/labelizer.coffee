CAPITAL = /^[Α-Ω]/

language = require('./language')

class Labelizer
  constructor: (@morpheus, @nounLabels, @default) ->
    @default ||= []

  labelize: (tokens, i) ->
    return ['comma-punctuation'] if tokens[i] == ','
    return ['punc-punctuation'] if tokens[i] == '·'
    tokenWithoutAccent = language.stripAccents(tokens[i])
    morpheus = @morpheus.get(tokens[i], tokenWithoutAccent)
    return morpheus if morpheus != undefined
    return @nounLabels if CAPITAL.test(tokenWithoutAccent)
    return @default

module.exports = Labelizer