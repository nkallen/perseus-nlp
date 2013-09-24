###
  A simple, mutable, sparse-vector implementation. Vectors
  are mutable to produce less garbage.
###
class SparseVector
  @zero = () -> new SparseVector({})

  constructor: (@hash) ->

  plusEq: (that) ->
    that = that.hash if that instanceof SparseVector

    for key, value of that
      if key of this.hash
        this.hash[key] += that[key]
      else
        this.hash[key] = value
    this

  minusEq: (that) ->
    that = that.hash if that instanceof SparseVector

    for key, value of that
      if key of this.hash
        this.hash[key] -= value
      else
        this.hash[key] = -value
    this

  dot: (that) ->
    that = that.hash if that instanceof SparseVector

    result = 0.0
    for key, value of that when key of this.hash
      result += this.hash[key] * value
    result

module.exports = SparseVector