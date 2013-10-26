###
This is an implementation of the Viterbi algorithm. There are a number of noteworthy
performance optimizations.

Firstly, while the dynamic programming table represents three dimensions, as in
`scores[token_idx][prev_idx][current_idx]`, it is actually stored in a typed,
1-dimensional array; indexing is performed using the linear equation
`scores[token_idx * x^2 + current_idx * x + prev_idx]`. This has better memory density
and locality. Note that `current_idx` precedes `prev_idx`, optimizing for the case
where prev_idx is the innermost loop. This is equivalent to column-major order.

Secondly, the programming tables are pre-allocated. This avoids pressure on the garbage-
collector.
###

language = require('./language')

class Viterbi
  MAX_SENTENCE_LENGTH = 100

  constructor: (@scorer, @maxTableWidth) ->
    @scores = new Int32Array(MAX_SENTENCE_LENGTH * @maxTableWidth * @maxTableWidth)
    @pointers = new Int32Array(MAX_SENTENCE_LENGTH * @maxTableWidth * @maxTableWidth)
    @X = @maxTableWidth * @maxTableWidth
    @Y = @maxTableWidth

  label: (tokens, labels) ->
    throw "Invalid sentence length" if tokens.length > MAX_SENTENCE_LENGTH

    X = @X
    Y = @Y
    for token, i in tokens
      labelsForPrevPrev = if i - 2 < 0 then language.Starts else labels[i - 2]
      labelsForPrev     = if i - 1 < 0 then language.Starts else labels[i - 1] 
      labelsForCurrent  = labels[i]

      if labelsForCurrent.length > @maxTableWidth
        console.warn(tokens[i] + " has too many labels (#{labelsForCurrent.length} labels > #{@maxTableWidth})")
        return

      for current, k in labelsForCurrent
        unigramScore = @scorer.unigram(current, tokens, i)
        for prev, j in labelsForPrev
          bigramScore = @scorer.bigram(prev, current, tokens, i)
          max = Number.NEGATIVE_INFINITY
          back = 0
          for prevprev, l in labelsForPrevPrev
            prevScore = if i == 0 then 0 else @scores[(i - 1) * X + j * Y + l]
            trigramScore = @scorer.trigram(prevprev, prev, current, tokens, i)
            score = prevScore + unigramScore + bigramScore + trigramScore
            if score >= max
              max = score
              back = l
          idx = i * X + k * Y + j
          @scores[idx] = max
          @pointers[idx] = back

    max = Number.NEGATIVE_INFINITY
    end = null
    labelsForPrevPrev = if labels.length - 2 < 0 then language.Starts else labels[labels.length - 2]
    labelsForPrev     = labels[labels.length - 1]
    unigramScore      = @scorer.unigram(language.Stop, tokens, tokens.length)
    for prev, i in labelsForPrev
      bigramScore = @scorer.bigram(prev, language.Stop, tokens, tokens.length)
      for prevprev, j in labelsForPrevPrev
        trigramScore = @scorer.trigram(prevprev, prev, language.Stop, tokens, tokens.length)
        idx = (tokens.length - 1) * X + i * Y + j
        score = @scores[idx] + unigramScore + bigramScore + trigramScore
        if score >= max
          max = score
          end = [j, i]

    [prev, current] = end
    result = []
    for i in [(tokens.length - 1) .. 0] by -1
      result.unshift(labels[i][current])
      [prev, current] = [@pointers[i * X + current * Y + prev], prev]

    result

  trace: (tokens, labels) ->
    [@label(tokens, labels), @scores, @pointers]

module.exports = Viterbi