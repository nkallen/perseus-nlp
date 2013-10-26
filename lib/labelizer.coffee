CAPITAL = /^[Α-Ω]/

language = require('./language')

class Labelizer
  constructor: (@morpheus, @nounLabels, @default) ->
    @default ||= ['unknown', 0]

  labelize: (tokens, i) ->
    tokenWithoutAccent = language.stripAccents(tokens[i])
    morpheus = @morpheus.get(tokens[i], tokenWithoutAccent)
    return morpheus if morpheus.length > 0
    # return @nounLabels if CAPITAL.test(tokenWithoutAccent)
    return @default

module.exports = Labelizer