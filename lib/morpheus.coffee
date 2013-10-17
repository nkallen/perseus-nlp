language = require('./language')

class Morpheus
  constructor: (@unaccentuated) ->

  get: (exact, unaccentuated) ->
    unaccentuated ||= language.stripAccents(exact)
    return [] unless matches = @unaccentuated[unaccentuated]

    exactMatches = []
    fuzzyMatches = []
    for matched, i in matches by 3
      [form, lemma, postag] = [matches[i], matches[i+1], matches[i+2]]
      exactMatches.push([lemma, postag]) if form == exact
      fuzzyMatches.push([lemma, postag])

    return exactMatches if exactMatches.length
    return fuzzyMatches

module.exports = Morpheus