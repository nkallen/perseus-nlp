language = require('./language')

class Ngram
  constructor: (@size) ->
    @window = []
    i = 0
    @window.push(language.Start) while i++ < @size

  push: (token) ->
    @window.push(token)
    @window = @window[1..-1]
    throw new Error(@window.toString()) if @window.length > @size

  toArray: -> @window

module.exports = Ngram