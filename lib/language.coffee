unorm = require('unorm')

module.exports =
  StopPunctuation: ['.', ';', ',', '·', '"', 'ʽ', '“', '”']
  StopPunctuationRE: /[.,·;"ʽ”“]/
  CombiningAccents: /[\u0300-\u036Fʼ]/g
  Start: ['*', 0]
  Stop: ['STOP', 0]
  Starts: [['*', 0]]
  Stops: [['STOP', 0]]
  stripAccents: (string) ->
    unorm.nfkc(unorm.nfkd(string).replace(@CombiningAccents, ''))
