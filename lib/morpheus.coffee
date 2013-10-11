class Morpheus
  constructor: (@accentuated, @unaccentuated) ->

  get: (unaccentuatedToken) ->
    @unaccentuated[unaccentuatedToken]

  isMatch: (token, tag) ->
    @accentuated[token]?[tag]

module.exports = Morpheus