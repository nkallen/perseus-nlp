class Morpheus
  constructor: (@unaccentuated) ->

  get: (exact, unaccentuated) ->
    return [] unless tokens = @unaccentuated[unaccentuated]

    exactMatches = ([lemma, tokens[i+1]] for lemma, i in tokens by 2 when lemma == exact)
    return exactMatches if exactMatches.length
    return ([lemma, tokens[i+1]] for lemma, i in tokens by 2)

module.exports = Morpheus