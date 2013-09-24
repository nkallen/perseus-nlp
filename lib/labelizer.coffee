CAPITAL = /^[Α-Ω]/

language = require('./language')

class Labelizer
  constructor: (@morpheusUnaccentuated, @nounLabels) ->
  labelize: (tokens, i) ->
    return ['comma-punctuation'] if tokens[i] == ','
    return ['punc-punctuation'] if tokens[i] == '·'

    tokenWithoutAccent = language.stripAccents(tokens[i])
    return @morpheusUnaccentuated[tokenWithoutAccent] if tokenWithoutAccent of @morpheusUnaccentuated
    return @nounLabels if CAPITAL.test(tokenWithoutAccent)
    return []

module.exports = Labelizer