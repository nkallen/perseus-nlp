fs = require('fs')
SparseVector = require('./vector')
Scorer = require('./scorer')
language = require('./language')
PAD = "                                                             "

class Perceptron
  constructor: (@featurizer, @labelizer, @makeViterbi) ->

  apply: (trainings, iterations, seed) ->
    trainings = Perceptron.validate(@labelizer, trainings)
    @applyWithoutValidate(trainings, iterations, seed)

  applyWithoutValidate: (trainings, iterations, seed) ->
    v = seed || SparseVector.zero()
    viterbi = @makeViterbi(new Scorer(v, @featurizer))

    for i in [0...iterations]
      console.warn("#{new Date}\tPerceptron iteration #{i}")

      for [tokens, trainingLabels], i in trainings
        labels = (@labelizer.labelize(tokens, j) for token, j in tokens)
        process.stderr.write("#{"Training #{i + 1}/#{trainings.length} #{tokens.join(' ')}#{PAD}"[0..80]}\r")

        continue unless computedLabels = viterbi.label(tokens, labels)
        if computedLabels.some((computedLabel, i) -> computedLabel != trainingLabels[i])
          v.plusEq(@globalFeaturize(tokens, trainingLabels))
          v.minusEq(@globalFeaturize(tokens, computedLabels))
    v

  globalFeaturize: (tokens, labels) ->
    result = SparseVector.zero()
    prevprev = prev = '*'
    for token, i in tokens
      current = labels[i]
      result.plusEq(@featurizer.featurize(prevprev, prev, current, tokens, i))
      [prevprev, prev] = [prev, current]
    result.plusEq(@featurizer.featurize(prevprev, prev, language.Stop, tokens, tokens.length))
    result

  @validate: (labelizer, trainings) ->
    console.warn("#{new Date}\tValidating training data.")
    errors = []
    result = []
    for [tokens, trainingLabels] in trainings
      labels = (labelizer.labelize(tokens, i) for token, i in tokens)
      skip = false
      for token, i in tokens
        if !labels[i].length
          errors.push("#{tokens[i]} has no labels; skipping sentence.")
          skip = true
        if labels[i].indexOf(trainingLabels[i]) == -1
          errors.push("#{tokens[i]} has label #{trainingLabels[i]}, but is not in the list [#{labels[i].join(',')}]")
          skip = true
      unless skip
        result.push([tokens, trainingLabels])
    console.warn("#{new Date}\tSkipped #{trainings.length - result.length} out of #{trainings.length} training samples; see train.log for details.")
    fs.writeFileSync('train.log', errors.join('\n'))
    result

module.exports = Perceptron