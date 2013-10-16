vector = require('./vector')

class Scorer
  constructor: (@v, @featurizer) ->
    @dot = new vector.Dot(@v)
  unigram: (current, tokens, i) ->
    @dot.sum = 0
    @featurizer.unigram(@dot, current, tokens, i)
    @dot.sum
  bigram: (prev, current, tokens, i) ->
    @dot.sum = 0
    @featurizer.bigram(@dot, prev, current, tokens, i)
    @dot.sum
  trigram: (prevprev, prev, current, tokens, i) ->
    @dot.sum = 0
    @featurizer.trigram(@dot, prevprev, prev, current, tokens, i)
    @dot.sum


module.exports = Scorer