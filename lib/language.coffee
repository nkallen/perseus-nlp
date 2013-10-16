unorm = require('unorm')

module.exports =
  StopPunctuation: ['.', ';', ',', '·', '"', 'ʽ', '“', '”']
  StopPunctuationRE: /[.,·;"ʽ”“]/
  CombiningAccents: /[\u0300-\u036Fʼ]/g
  Start: ['*', -1]
  Stop: ['STOP', -2]
  Starts: [['*', -1]]
  Stops: [['STOP', -2]]
  stripAccents: (string) ->
    unorm.nfkc(unorm.nfkd(string).replace(@CombiningAccents, ''))
