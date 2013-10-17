#!/usr/bin/env coffee

fs = require('fs')
path = require('path')
express = require('express')
Perceptron = require('../lib/perceptron')
Viterbi = require('../lib/viterbi')
vector = require('../lib/vector')
Featurizer = require('../lib/featurizer')
Morpheus = require('../lib/morpheus')
Labelizer = require('../lib/labelizer')
language = require('../lib/language')
Scorer = require('../lib/scorer')
postag = require('perseus-util').greek.postag

MAX_TABLE_WIDTH = 193

allLabels = JSON.parse(fs.readFileSync(path.join(__dirname, '../resources/labels.json')))
nounLabels = ('proper-' + label for label in allLabels when /^noun/.test(label))
morpheus = new Morpheus(JSON.parse(fs.readFileSync(path.join(__dirname, '../build/morpheus.unaccentuated.json'))))

featurizer = new Featurizer(morpheus)
labelizer = new Labelizer(morpheus, nounLabels)
v = JSON.parse(fs.readFileSync(path.join(__dirname, '../build/v.json')))
scorer = new Scorer(v, featurizer)
viterbi = new Viterbi(scorer, MAX_TABLE_WIDTH)

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
    PP: vector.PP
    Dot: vector.Dot
    v: v
    X: viterbi.X
    Y: viterbi.Y
    postag: postag
  )
)

console.warn("Listening on port #{process.env.PORT}")
app.listen(process.env.PORT)