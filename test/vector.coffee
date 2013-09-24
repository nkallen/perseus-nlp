should = require('should')
Vector = require('../lib/vector')

describe 'Vector', ->
  describe 'dot', ->
    it 'is awesome', ->
      v1 = new Vector(a: 1, b: 2)
      b2 = new Vector(b: 2, c: 3)
      v1.dot(b2).should.eql(4)

  describe 'plusEq', ->
    it 'is awesome', ->
      v1 = new Vector(a: 1, b: 2)
      b2 = new Vector(b: 2, c: 3)
      v1.plusEq(b2).hash.should.eql(a: 1, b: 4, c: 3)

  describe 'minusEq', ->
    it 'is awesome', ->
      v1 = new Vector(a: 1, b: 2)
      b2 = new Vector(b: 2, c: 3)
      v1.minusEq(b2).hash.should.eql(a: 1, b: 0, c: -3)