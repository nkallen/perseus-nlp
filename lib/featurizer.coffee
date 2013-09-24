SUBSTANTIVE = /^adjective|^article|^noun|^pronoun|^participle/
VERB = /^verb/

###
Given a token, a candidate tag, and a history, produce a feature vector.
The feature vector is represented as a hash table.

TODO
- NOM/VOC + VERB ACCORDANCE ngram
- everything minus lemma ngram
###
class Featurizer
  constructor: (@morpheusAccentuated) ->

  featurize: (prevprev, prev, current, tokens, i) ->
    result = {}
    ###
    TODO: accordance between number of nominative/vocative substanvies and
    number of verbs.
    ###
    result["bigram-full:#{prev}:#{current}"] = 1
    result["trigram-full:#{prevprev}:#{prev}:#{current}"] = 1
    result["bigram-skip-full:#{prevprev}:#{current}"] = 1

    prevprevParts = prevprev.split('-')
    prevParts = prev.split('-')
    currentParts = current.split('-')

    prevprevLemma = prevprevParts[0]
    prevLemma = prevParts[0]
    currentLemma = currentParts[0]
    result["bigram-lemma:#{prevLemma}:#{currentLemma}"] = 1
    result["trigram-lemma:#{prevprevLemma}:#{prevLemma}:#{currentLemma}"] = 1
    result["bigram-skip-lemma:#{prevprevLemma}:#{currentLemma}"] = 1

    # Everything but the lemma
    prevprevInflection = prevprevParts[1..].join('-')
    prevInflection = prevParts[1..].join('-')
    currentInflection = currentParts[1..].join(-)
    result["bigram-inflection:#{prevInflection}:#{currentInflection}"] = 1
    result["trigram-inflection:#{prevprevInflection}:#{prevInflection}:#{currentInflection}"] = 1
    result["bigram-skip-inflection:#{prevprevInflection}:#{currentInflection}"] = 1

    prevprevPos = prevprevParts[1]
    prevPos = prevParts[1]
    currentPos = currentParts[1]
    result["bigram-pos:#{prevPos}:#{currentPos}"] = 1
    result["trigram-pos:#{prevprevPos}:#{prevPos}:#{currentPos}"] = 1
    result["bigram-skip-pos:#{prevprevPos}:#{currentPos}"] = 1

    prevprevSubstantive = substantiveLabel(prevprevParts)
    prevSubstantive     = substantiveLabel(prevParts)
    currentSubstantive  = substantiveLabel(currentParts)
    if prevSubstantive && currentSubstantive
      result["bigram-substantive:#{prevSubstantive}:#{currentSubstantive}"] = 1
    if prevprevSubstantive && prevSubstantive && currentSubstantive
      result["trigram-substantive:#{prevprevSubstantive}:#{prevSubstantive}:#{currentSubstantive}"] = 1
    if prevprevSubstantive && currentSubstantive
      result["bigram-skip-substantive:#{prevprevSubstantive}:#{currentSubstantive}"] = 1

    ###
    STARTs and STOPs are outside token boundaries (i < 0 || i > tokens.length);
    if we're considering a real token, do the following...
    ###
    if token = tokens[i]
      result["token:#{token}:#{current}"] = 1
      if VERB.test(current)
        # Verbs can have a prefix "past-indicative-augment" indicating tense as far
        # forward as the 4th letter, like "pare". Note: tests show poor precision
        # when using prefix and suffix features if the prefix or suffix is the full
        # length of the word!
        if token.length > 1
          result["prefix-1:#{token[0...1]}:#{current}"] = 1
        if token.length > 2
          result["prefix-2:#{token[0...2]}:#{current}"] = 1
        if token.length > 3
          result["prefix-3:#{token[0...3]}:#{current}"] = 1
        if token.length > 4
          result["prefix-4:#{token[0...4]}:#{current}"] = 1

        # Verbs can have suffixes up to five letters indicating conjugation, like "ontai"
        if token.length > 3
          result["suffix-3:#{token[-3..-1]}:#{current}"] = 1
        if token.length > 4
          result["suffix-4:#{token[-4..-1]}:#{current}"] = 1
        if token.length > 5
          result["suffix-5:#{token[-5..-1]}:#{current}"] = 1

      # Substantives (adjective article noun pronoun participle) typically have two
      # letter suffixes indicating inflection, but sometimes one letter.
      if VERB.test(current) || SUBSTANTIVE.test(current)
        if token.length > 1
          result["suffix-1:#{token[-1..-1]}:#{current}"] = 1
        if token.length > 2
          result["suffix-2:#{token[-2..-1]}:#{current}"] = 1

      # Morpheus produced the list of candidate tags given a morpheme, ignorin
      # accentuation. Here we note if we have an EXACT accentuation match.
      if @morpheusAccentuated[tokens[i]]?[current]
        result["accentuation-match"] = 1
    result

  substantiveLabel = (labelParts) ->
    switch labelParts[1]
      when "adjective", "article", "noun", "pronoun", "participle"
        kase = labelParts[2]
        gender = labelParts[3]
        number = labelParts[4]
        "#{kase}-#{gender}-#{number}"
      else 
        null

module.exports = Featurizer