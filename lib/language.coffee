unorm = require('unorm')

module.exports =
  StopPunctuation: ['.', ';', ',', '·', '"']
  StopPunctuationRE: /[.,·;"]/
  CombiningAccents: /[\u0300-\u036Fʼ]/g
  Start: '*'
  Stop: 'STOP-STOP'
  Starts: ['START-START']
  Stops: ['STOP-STOP']
  Features: ['partOfSpeech', 'case', 'gender', 'number', 'tense', 'voice', 'mood', 'person']
  stripAccents: (string) ->
    unorm.nfkc(unorm.nfkd(string).replace(@CombiningAccents, ''))
  token2tag: (token, features) ->
    token.lemma.replace(/\d+$/, '') + '-' + (token[feature] for feature in features when token[feature]).join('-')
