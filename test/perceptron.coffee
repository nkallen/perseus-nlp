should = require('should')
Perceptron = require('../lib/perceptron')
Viterbi = require('../lib/viterbi')

describe 'Perceptron', ->
  xit 'is awesome', ->
    trainings = [
      [['this', 'is', 'a', 'cat'], ['a', 'b', 'c', 'd']]
    ]
    labels = ['a', 'b', 'c', 'd']
    labelize = (tokens, i) ->
      labels

    f = () ->
      foo: 1
      bar: 1
    perceptron = new Perceptron(f, labelize, (score) -> new Viterbi(score, labels.length))
    perceptron.apply(trainings, 5).should.eql(foo: -1, bar: -1)
