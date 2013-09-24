perseus-nlp
===========

This is a set of resources related to natural-language-processing tasks on the Perseus corpus.

Currently, it trains a global-linear tagger using the Perseus treebank data, and uses morpheus to limit the number of possible tags for a given morpheme (there are ~800 possible tags for a given greek word, such as `noun-dual-masculine-dative`, which is far too many to compute in a reasonable amount of time).

Clone this repository recursively; initialize all the submodules, then `make train` on the command line. The process takes several hours to run about 10 iterations of Perceptron. 

Once the data is trained you can run simple tests from the command line:

```sh
bin/test τὸν μὲν δὴ παῖδα εὗρον αὐτοῦ οἱ μετιόντες οὐκέτι περιεόντα ἀλλὰ πρῶτον κατακοπέντα
...
[ [ 'τὸν', 'article-accusative-masculine-singular' ],
  [ 'μὲν', 'particle' ],
  [ 'δὴ', 'particle' ],
  [ 'παῖδα', 'noun-accusative-masculine-singular' ],
  [ 'εὗρον', 'verb-plural-aorist-active-indicative-third' ],
  [ 'αὐτοῦ', 'adjective-genitive-masculine-singular' ],
  [ 'οἱ', 'pronoun-dative-feminine-singular' ],
  [ 'μετιόντες',
    'participle-nominative-masculine-plural-present-active' ],
  [ 'οὐκέτι', 'adverb' ],
  [ 'περιεόντα',
    'participle-accusative-masculine-singular-present-active' ],
  [ 'ἀλλὰ', 'adverb' ],
  [ 'πρῶτον', 'adjective-accusative-neuter-singular' ],
  [ 'κατακοπέντα',
    'participle-accusative-masculine-singular-aorist-passive' ] ]
```

[Look here](https://github.com/nkallen/perseus-nlp/blob/master/lib/featurizer.coffee) for features currently considered for greek. Generally, prefixes, suffixes, tag bigrams and trigrams, and morpheus accentuation matches are taken into consideration.
