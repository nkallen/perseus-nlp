class Scorer
  constructor: (@v, @featurizer) ->
  score: (prevprev, prev, current, tokens, i) =>
    @v.dot(@featurizer.featurize(prevprev, prev, current, tokens, i))

module.exports = Scorer