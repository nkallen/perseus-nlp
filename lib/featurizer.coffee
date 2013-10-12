SUBSTANTIVE_BUT_NOT_PRONOUN_OR_ARTICLES = /-adjective-|-noun-|-participle-/
VERB = /^-verb-/

###
Given a token, a candidate tag, and a history, produce a feature vector.
The feature vector is represented as a hash table.
###
class Featurizer
  constructor: (@morpheusAccentuated) ->

  featurize: (prevprev, prev, current, tokens, i) ->
    result = {}
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

    # Everything but the lemma;
    prevprevTag = prevprevParts[1..].join('-')
    prevTag = prevParts[1..].join('-')
    currentTag = currentParts[1..].join('-')
    result["bigram-tag:#{prevTag}:#{currentTag}"] = 1
    result["trigram-tag:#{prevprevTag}:#{prevTag}:#{currentTag}"] = 1
    result["bigram-skip-tag:#{prevprevTag}:#{currentTag}"] = 1

    # Everything but the lemma and pos.
    prevprevInflection = prevprevParts[2..].join('-')
    prevInflection = prevParts[2..].join('-')
    currentInflection = currentParts[2..].join('-')
    if prevInflection && currentInflection
      result["bigram-inflection:#{prevInflection}:#{currentInflection}"] = 1
    if prevprevInflection && prevInflection && currentInflection
      result["trigram-inflection:#{prevprevInflection}:#{prevInflection}:#{currentInflection}"] = 1
    if prevprevInflection && currentInflection
      result["bigram-skip-inflection:#{prevprevInflection}:#{currentInflection}"] = 1

    # Substantive accordance # FIXME RENAME ACCORDDANCE
    prevprevSubstantive = substantive(prevprevParts)
    prevSubstantive = substantive(prevParts)
    currentSubstantive = substantive(currentParts)
    if prevSubstantive && currentSubstantive
      result["bigram-substantive:#{prevSubstantive}:#{currentSubstantive}"] = 1
    if prevprevSubstantive && prevSubstantive && currentSubstantive
      result["trigram-substantive:#{prevprevSubstantive}:#{prevSubstantive}:#{currentSubstantive}"] = 1
    if prevprevSubstantive && currentSubstantive
      result["bigram-skip-substantive:#{prevprevSubstantive}:#{currentSubstantive}"] = 1

    prevprevPos = prevprevParts[1]
    prevPos = prevParts[1]
    currentPos = currentParts[1]

    result["bigram-pos:#{prevPos}:#{currentPos}"] = 1
    result["trigram-pos:#{prevprevPos}:#{prevPos}:#{currentPos}"] = 1
    result["bigram-skip-pos:#{prevprevPos}:#{currentPos}"] = 1

    ###
    STARTs and STOPs are outside token boundaries (0 <= i < tokens.length);
    if we're considering a real token, do the following...
    ###
    if token = tokens[i]
      result["label:#{current}"] = 1
      result["token:#{token}:#{current}"] = 1
      result["lemma:#{currentLemma}"] = 1

      if currentInflection
        result["inflection:#{currentInflection}"] = 1
        if VERB.test(current)
          # Verbs can have a prefix "past-indicative-augment" indicating tense as far
          # forward as the 4th letter, like "pare". Note: tests show poor precision
          # when using prefix and suffix features if the prefix or suffix is the full
          # length of the word!

          # TODO: put tense rather than currentInflection here
          if token.length > 1
            result["prefix-1:#{token[0...1]}:#{currentInflection}"] = 1
          if token.length > 2
            result["prefix-2:#{token[0...2]}:#{currentInflection}"] = 1
          if token.length > 3
            result["prefix-3:#{token[0...3]}:#{currentInflection}"] = 1
          if token.length > 4
            result["prefix-4:#{token[0...4]}:#{currentInflection}"] = 1

          # Verbs can have suffixes up to five letters indicating conjugation, like "ontai"
          if token.length > 4
            result["suffix-4:#{token[-4..-1]}:#{currentInflection}"] = 1
          if token.length > 5
            result["suffix-5:#{token[-5..-1]}:#{currentInflection}"] = 1

        # Substantives typically have two-letter suffixes indicating inflection, but
        # sometimes one letter. Note: pronouns and articles resemble declension
        # paradigms but differ enough to confuse things, so we omit them here.
        # They are frequent enough that should be learned by the `token` feature.
        if VERB.test(current) || SUBSTANTIVE_BUT_NOT_PRONOUN_OR_ARTICLES.test(current)
          if token.length > 1
            result["suffix-1:#{token[-1..-1]}:#{currentInflection}"] = 1
          if token.length > 2
            result["suffix-2:#{token[-2..-1]}:#{currentInflection}"] = 1
          if token.length > 3
            result["suffix-3:#{token[-3..-1]}:#{currentInflection}"] = 1

      # Morpheus produced the list of candidate tags given a morpheme, ignorin
      # accentuation. Here we note if we have an EXACT accentuation match.
      if @morpheusAccentuated.isMatch(tokens[i], current)
        result["accentuation-match"] = 1
    result

  # Accordance between substantives includes case, gender, and number.
  # Additionally, verbs accord: nominative and vocative cases indicate subjects.
  # And number accords, except when the gender is neuter.
  # Finally, infinitives often have accusative subjects. It would be better
  # to ignore the gender/number in those cases, since they don't accord, TBD.
  substantive = (labelParts) ->
    switch labelParts[1]
      when "adjective", "article", "noun", "pronoun", "participle"
        kase = labelParts[2]
        gender = labelParts[3]
        number = labelParts[4]
        "#{kase}-#{gender}-#{number}"
      when "verb" 
        return "infinitive" if labelParts[5] == "infinitive"
        number = labelParts[2]
        person = labelParts[6]
        "#{number}-#{person}"


module.exports = Featurizer