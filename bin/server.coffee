#!/usr/bin/env coffee

fs = require('fs')
path = require('path')
express = require('express')
Perceptron = require('../lib/perceptron')
Viterbi = require('../lib/viterbi')
language = require('../lib/language')
Featurizer = require('../lib/featurizer')
Labelizer = require('../lib/labelizer')
Scorer = require('../lib/scorer')
SparseVector = require('../lib/vector')
Morpheus = require('../lib/morpheus')

sentence = process.argv[2..]

console.warn("#{new Date()}\tLoading constant databases (ngrams, morphological data, etc.).")
allLabels = JSON.parse(fs.readFileSync(path.join(__dirname, '../resources/labels.json')))
nounLabels = ('proper-' + label for label in allLabels when /^noun/.test(label))
morpheus = new Morpheus(
  JSON.parse(fs.readFileSync(path.join(__dirname, '../build/morpheus.accentuated.json'))),
  JSON.parse(fs.readFileSync(path.join(__dirname, '../build/morpheus.unaccentuated.json'))))
featurizer = new Featurizer(morpheus)
labelizer = new Labelizer(morpheus, nounLabels)
v = new SparseVector(JSON.parse(fs.readFileSync(path.join(__dirname, '../build/seed.json'))))
scorer = new Scorer(v, featurizer)
viterbi = new Viterbi(scorer, 180)
console.warn("#{new Date()}\tDone loading databases.")

app = express()
app.use(express.responseTime())
app.use(express.compress())
app.set('view engine', 'ejs')
app.set('views', __dirname)

app.get('/', (req, res) ->
  labels = labelss = scores = pointers = null
  if req.query.sentence
    tokens = req.query.sentence.split(/\s+/)
    labelss = (labelizer.labelize(tokens, i) for token, i in tokens)
    [labels, scores, pointers] = viterbi.trace(tokens, labelss)

  res.render('trace',
    labels: labels
    labelss: labelss
    scores: scores
    pointers: pointers
    tokens: tokens
    sentence: req.query.sentence
    starts: language.Starts
    scorer: scorer
    featurizer: featurizer
    v: v
    X: viterbi.X
    Y: viterbi.Y
  )
)

app.listen(process.env.PORT)