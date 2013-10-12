unorm = require('unorm')

module.exports =
  StopPunctuation: ['.', ';', ',', '·', '"', 'ʽ', '“', '”']
  StopPunctuationRE: /[.,·;"ʽ”“]/
  CombiningAccents: /[\u0300-\u036Fʼ]/g
  Start: '*'
  Stop: 'STOP-STOP-STOP'
  Starts: ['START-START-START']
  Stops: ['STOP-STOP-STOP']
  Features: ['partOfSpeech', 'case', 'gender', 'number', 'tense', 'voice', 'mood', 'person']
  stripAccents: (string) ->
    unorm.nfkc(unorm.nfkd(string).replace(@CombiningAccents, ''))
  token2tag: (token, features) ->
    token.lemma.replace(/\d+$/, '') + '-' + (token[feature] for feature in features when token[feature]).join('-')
