Viterbi = require('../lib/viterbi.coffee')
should = require('should')

describe 'Viterbi', ->
  it 'works when given reasonable scores', ->
    labels = [['adverb'], ['particle', 'verb-singular-present-active-imperative-second', 'verb-singular-imperfect-active-indicative-third']]
    scores = {}
    scores[['ἀεὶ', 'adverb']] = 1
    scores[['μέν', 'particle']] = 1
    scores[['μέν', 'verb-singular-present-active-imperative-second']] = 0
    scores[['μέν', 'verb-singular-imperfect-active-indicative-third']] = 0
    scores[[undefined, 'STOP']] = 0
    f = (prevprev, prev, current, tokens, i) ->
      scores[[tokens[i], current]]

    viterbi = new Viterbi(f, 3)
    viterbi.label(['ἀεὶ', 'μέν'], labels).should.eql(['adverb', 'particle'])

  it 'works when all scores are 0', ->
    labels = [['adverb'], ['particle', 'verb-singular-present-active-imperative-second', 'verb-singular-imperfect-active-indicative-third']]
    f = (prevprev, prev, current, tokens, i) -> 0

    viterbi = new Viterbi(f, 3)
    viterbi.label(['ἀεὶ', 'μέν'], labels).should.eql(['adverb', 'verb-singular-imperfect-active-indicative-third'])