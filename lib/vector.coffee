class Dot
  constructor: (@v) ->
    @sum = 0
  trigram: (name, prevprev, prev, current) ->
    if x = @v.trigram[name]?[prevprev]?[prev]?[current]
      @sum += x
  bigram: (name, prev, current) ->
    if x = @v.bigram[name]?[prev]?[current]
      @sum += x
  condition: (name, current, condition) ->
    if x = @v.condition[name]?[current]?[condition]
      @sum += x
  df: (name, current) ->
    if x = @v.df[name]?[current]
      @sum += x
  fact: (name) ->
    if x = @v.fact[name]
      @sum += x

class PlusEq
  constructor: (@v) ->
  trigram: (name, prevprev, prev, current) ->
    @v.trigram[name] ||= {}
    @v.trigram[name][prevprev] ||= {}
    @v.trigram[name][prevprev][prev] ||= {}
    @v.trigram[name][prevprev][prev][current] ||= 0
    @v.trigram[name][prevprev][prev][current]++
  bigram: (name, prev, current) ->
    @v.bigram[name] ||= {}
    @v.bigram[name][prev] ||= {}
    @v.bigram[name][prev][current] ||= 0
    @v.bigram[name][prev][current]++
  condition: (name, current, condition) ->
    @v.condition[name] ||= {}
    @v.condition[name][current] ||= {}
    @v.condition[name][current][condition] ||= 0
    @v.condition[name][current][condition]++
  df: (name, current) ->
    @v.df[name] ||= {}
    @v.df[name][current] ||= 0
    @v.df[name][current]++
  fact: (name) ->
    @v.fact[name] ||= 0
    @v.fact[name]++

class MinusEq
  constructor: (@v) ->
  trigram: (name, prevprev, prev, current) ->
    @v.trigram[name] ||= {}
    @v.trigram[name][prevprev] ||= {}
    @v.trigram[name][prevprev][prev] ||= {}
    @v.trigram[name][prevprev][prev][current] ||= 0
    @v.trigram[name][prevprev][prev][current]--
  bigram: (name, prev, current) ->
    @v.bigram[name] ||= {}
    @v.bigram[name][prev] ||= {}
    @v.bigram[name][prev][current] ||= 0
    @v.bigram[name][prev][current]--
  condition: (name, current, condition) ->
    @v.condition[name] ||= {}
    @v.condition[name][current] ||= {}
    @v.condition[name][current][condition] ||= 0
    @v.condition[name][current][condition]--
  df: (name, current) ->
    @v.df[name] ||= {}
    @v.df[name][current] ||= 0
    @v.df[name][current]--
  fact: (name) ->
    @v.fact[name] ||= 0
    @v.fact[name]--

zero = () ->
  trigram: {}
  bigram: {}
  condition: {}
  df: {}
  fact: {}

module.exports =
  zero: zero
  PlusEq: PlusEq
  MinusEq: MinusEq
  Dot: Dot