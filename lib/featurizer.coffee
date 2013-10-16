postag = require('perseus-util').greek.postag

POS = postag.partOfSpeech
CASE = postag.case
GENDER = postag.gender
NUMBER = postag.number
TENSE = postag.tense
VOICE = postag.voice
MOOD = postag.mood
PERSON = postag.person

###
Given a token, a candidate tag, and a history, produce a feature vector.
The feature vector is represented as a hash table.
###
class Featurizer
  constructor: (@morpheusAccentuated) ->

  unigram: (pen, current, tokens, i) ->
    return unless 0 < i < tokens.length
    token = tokens[i]

    [currentLemma, currentTag] = current
    currentInflection =  (CASE | GENDER | NUMBER | TENSE | VOICE | MOOD | PERSON) & currentTag

    pen.df('lemma', currentLemma)
    pen.df('tag', currentTag)
    pen.df('inflection', currentInflection)

    pen.condition('full', current, token)
    pen.condition('prefix-1', currentTag, token[0...1]) if token.length > 1
    pen.condition('prefix-2', currentTag, token[0...2]) if token.length > 2
    pen.condition('prefix-3', currentTag, token[0...3]) if token.length > 3
    pen.condition('prefix-4', currentTag, token[0...4]) if token.length > 4

    pen.condition('suffix-1', currentTag, token[-1...-1]) if token.length > 1
    pen.condition('suffix-2', currentTag, token[-2...-1]) if token.length > 2
    pen.condition('suffix-3', currentTag, token[-3...-1]) if token.length > 3
    pen.condition('suffix-4', currentTag, token[-4...-1]) if token.length > 4
    pen.condition('suffix-5', currentTag, token[-5...-1]) if token.length > 5

  bigram: (pen, prev, current, tokens, i) ->
    [prevLemma,    prevTag]    = prev
    [currentLemma, currentTag] = current
    prevInflection    =  (CASE | GENDER | NUMBER | TENSE | VOICE | MOOD | PERSON) & prevTag
    currentInflection =  (CASE | GENDER | NUMBER | TENSE | VOICE | MOOD | PERSON) & currentTag
    prevAccordance    = (POS | CASE | GENDER | NUMBER | PERSON) & prevTag
    currentAccordance = (POS | CASE | GENDER | NUMBER | PERSON) & currentTag
    prevPos           = POS & prevTag
    currentPos        = POS & currentTag

    pen.bigram('full' ,      prev,           current)
    pen.bigram('lemma',      prevLemma,      currentLemma)
    pen.bigram('tag',        prevTag,        currentTag)
    pen.bigram('inflection', prevInflection, currentInflection)
    pen.bigram('accordance', prevAccordance, currentAccordance)
    pen.bigram('pos',        prevPos,        currentPos)

  trigram: (pen, prevprev, prev, current, tokens, i) ->
    [prevprevLemma, prevprevTag] = prevprev
    [prevLemma,     prevTag]     = prev
    [currentLemma,  currentTag]  = current
    prevprevInflection = (CASE | GENDER | NUMBER | TENSE | VOICE | MOOD | PERSON) & prevprevTag
    prevInflection     = (CASE | GENDER | NUMBER | TENSE | VOICE | MOOD | PERSON) & prevTag
    currentInflection  = (CASE | GENDER | NUMBER | TENSE | VOICE | MOOD | PERSON) & currentTag
    prevprevAccordance = (POS | CASE | GENDER | NUMBER | PERSON) & prevprevTag
    prevAccordance     = (POS | CASE | GENDER | NUMBER | PERSON) & prevTag
    currentAccordance  = (POS | CASE | GENDER | NUMBER | PERSON) & currentTag
    prevprevPos        = POS & prevprevTag
    prevPos            = POS & prevTag
    currentPos         = POS & currentTag

    pen.trigram('full',       prevprev,             prev,           current)
    pen.trigram('lemma',      prevprevLemma,        prevLemma,      currentLemma)
    pen.trigram('tag',        prevprevTag,          prevTag,        currentTag)
    pen.trigram('inflection', prevprevInflection,   prevInflection, currentInflection)
    pen.trigram('accordance', prevprevAccordance,   prevAccordance, currentAccordance)
    pen.trigram('pos',        prevprevPos,          prevPos,        currentPos)

    pen.bigram('full-skip',       prevprev,           current)
    pen.bigram('lemma-skip',      prevprevLemma,      currentLemma)
    pen.bigram('tag-skip',        prevprevTag,        currentTag)
    pen.bigram('inflection-skip', prevprevInflection, currentInflection)
    pen.bigram('accordance-skip', prevprevAccordance, currentAccordance)
    pen.bigram('pos-skip',        prevprevPos,        currentPos)

  featurize: (pen, prevprev, prev, current, tokens, i) ->
    @unigram(pen, current, tokens, i)
    @bigram(pen, prev, current, tokens, i)
    @trigram(pen, prevprev, prev, current, tokens, i)

module.exports = Featurizer