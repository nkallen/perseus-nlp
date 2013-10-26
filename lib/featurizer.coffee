greek = require('perseus-util').greek
postag = greek.postag
partOfSpeech = greek.PartOfSpeech

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
    return unless 0 <= i < tokens.length
    token = tokens[i]

    [currentLemma, currentTag] = current
    currentInflection =  (CASE | GENDER | NUMBER) & currentTag
    currentPos        = POS & currentTag

    pen.df('lemma', currentLemma)
    pen.df('pos', currentPos)

    pen.condition('full', current, token)

    currentAttributes = postag.toHash(currentTag).partOfSpeech
    if isInflected(currentAttributes)
      pen.df('inflection', currentInflection)

    if suffixMatters(currentAttributes)
      pen.condition('suffix-1', currentTag, token[-1..-1]) if token.length > 1
      pen.condition('suffix-2', currentTag, token[-2..-1]) if token.length > 2
      pen.condition('suffix-3', currentTag, token[-3..-1]) if token.length > 3
      pen.condition('suffix-4', currentTag, token[-4..-1]) if token.length > 4
      pen.condition('suffix-5', currentTag, token[-5..-1]) if token.length > 5

    if prefixMatters(currentAttributes)
      pen.condition('prefix-1', currentTag, token[0...1]) if token.length > 1
      pen.condition('prefix-2', currentTag, token[0...2]) if token.length > 2
      pen.condition('prefix-3', currentTag, token[0...3]) if token.length > 3
      pen.condition('prefix-4', currentTag, token[0...4]) if token.length > 4

  bigram: (pen, prev, current, tokens, i) ->
    [prevLemma,    prevTag]    = prev
    [currentLemma, currentTag] = current
    prevInflection    =  (CASE | GENDER | NUMBER) & prevTag
    currentInflection =  (CASE | GENDER | NUMBER) & currentTag
    prevAccordance    = (POS | CASE | GENDER | NUMBER | PERSON) & prevTag
    currentAccordance = (POS | CASE | GENDER | NUMBER | PERSON) & currentTag
    prevPos           = POS & prevTag
    currentPos        = POS & currentTag

    pen.bigram('full' ,      prev,           current)
    pen.bigram('lemma',      prevLemma,      currentLemma)
    pen.bigram('tag',        prevTag,        currentTag)
    pen.bigram('pos',        prevPos,        currentPos)

    prevAttributes = postag.toHash(prevTag).partOfSpeech
    currentAttributes = postag.toHash(currentTag).partOfSpeech

    if isInflected(prevAttributes) && isInflected(currentAttributes)
      pen.bigram('inflection', prevInflection, currentInflection)
    if doesAccord(prevAttributes) && doesAccord(currentAttributes)
      pen.bigram('accordance', prevAccordance, currentAccordance)

  trigram: (pen, prevprev, prev, current, tokens, i) ->
    [prevprevLemma, prevprevTag] = prevprev
    [prevLemma,     prevTag]     = prev
    [currentLemma,  currentTag]  = current
    prevprevInflection = (CASE | GENDER | NUMBER) & prevprevTag
    prevInflection     = (CASE | GENDER | NUMBER) & prevTag
    currentInflection  = (CASE | GENDER | NUMBER) & currentTag
    prevprevAccordance = (POS | CASE | GENDER | NUMBER | PERSON) & prevprevTag
    prevAccordance     = (POS | CASE | GENDER | NUMBER | PERSON) & prevTag
    currentAccordance  = (POS | CASE | GENDER | NUMBER | PERSON) & currentTag
    prevprevPos        = POS & prevprevTag
    prevPos            = POS & prevTag
    currentPos         = POS & currentTag

    pen.trigram('full',       prevprev,             prev,           current)
    pen.trigram('lemma',      prevprevLemma,        prevLemma,      currentLemma)
    pen.trigram('tag',        prevprevTag,          prevTag,        currentTag)
    pen.trigram('pos',        prevprevPos,          prevPos,        currentPos)

    prevprevAttributes = postag.toHash(prevprevTag).partOfSpeech
    prevAttributes = postag.toHash(prevTag).partOfSpeech
    currentAttributes = postag.toHash(currentTag).partOfSpeech

    if isInflected(prevprevAttributes) && isInflected(prevAttributes) && isInflected(currentAttributes)
      pen.trigram('inflection', prevprevInflection, prevInflection, currentInflection)
    if doesAccord(prevprevAttributes) && doesAccord(prevAttributes) && doesAccord(currentAttributes)
      pen.trigram('accordance', prevprevAccordance, prevAccordance, currentAccordance)

    return unless i > 1

    pen.bigram('full-skip',       prevprev,           current)
    pen.bigram('lemma-skip',      prevprevLemma,      currentLemma)
    pen.bigram('tag-skip',        prevprevTag,        currentTag)
    pen.bigram('pos-skip',        prevprevPos,        currentPos)

    if isInflected(prevprevAttributes) && isInflected(currentAttributes)
      pen.bigram('inflection-skip', prevprevInflection, currentInflection)
    if doesAccord(prevprevAttributes) && doesAccord(currentAttributes)
      pen.bigram('accordance-skip', prevprevAccordance, currentAccordance)

  featurize: (pen, prevprev, prev, current, tokens, i) ->
    @unigram(pen, current, tokens, i)
    @bigram(pen, prev, current, tokens, i)
    @trigram(pen, prevprev, prev, current, tokens, i)

  isInflected = (pos) ->
    return true if pos == partOfSpeech.pronoun
    return true if pos == partOfSpeech.article
    return true if pos == partOfSpeech.noun
    return true if pos == partOfSpeech.adjective
    return true if pos == partOfSpeech.numeral
    return true if pos == partOfSpeech.participle
    false

  doesAccord = (pos) ->
    return true if pos == partOfSpeech.verb
    return true if pos == partOfSpeech.pronoun
    return true if pos == partOfSpeech.article
    return true if pos == partOfSpeech.noun
    return true if pos == partOfSpeech.adjective
    return true if pos == partOfSpeech.participle
    false

  prefixMatters = (pos) ->
    return true if pos == partOfSpeech.verb

  suffixMatters = (pos) ->
    return true if pos == partOfSpeech.verb
    return true if pos == partOfSpeech.noun
    return true if pos == partOfSpeech.adjective
    return true if pos == partOfSpeech.participle

module.exports = Featurizer