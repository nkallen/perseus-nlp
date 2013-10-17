perseus-nlp
===========

This is a set of resources related to natural-language-processing tasks on the Perseus corpus.

Currently, it trains a global-linear tagger using the Perseus treebank data, and uses morpheus to limit the number of possible tags for a given morpheme (there are ~800 possible tags for a given greek word, such as `noun-dual-masculine-dative`, which is far too many to compute in a reasonable amount of time).

Clone this repository recursively; initialize all the submodules, then `make train` on the command line. The process takes several hours to run about 10 iterations of Perceptron. 

Once the data is trained you can run simple tests from the command line:

```sh
bin/test τὸν μὲν δὴ παῖδα εὗρον αὐτοῦ οἱ μετιόντες οὐκέτι περιεόντα ἀλλὰ πρῶτον κατακοπέντα
...
[
  [
    "τὸν",  "ὁ",
    {
      "partOfSpeech": "article",
      "case": "accusative",
      "gender": "masculine",
      "number": "singular"
    }
  ],
  [
    "μὲν", "μέν",
    {
      "partOfSpeech": "particle"
    }
  ],
  [
    "δὴ", "δή",
    {
      "partOfSpeech": "particle"
    }
  ],
  [
    "παῖδα", "παῖς",
    {
      "partOfSpeech": "noun",
      "case": "accusative",
      "gender": "masculine",
      "number": "singular"
    }
  ],
  [
    "εὗρον", "εὑρίσκω",
    {
      "partOfSpeech": "verb",
      "number": "plural",
      "person": "third",
      "tense": "aorist",
      "voice": "active",
      "mood": "indicative"
    }
  ],
  [
    "αὐτοῦ", "αὐτός",
    {
      "partOfSpeech": "adjective",
      "case": "genitive",
      "gender": "masculine",
      "number": "singular"
    }
  ],
  [
    "οἱ", "ὁ",
    {
      "partOfSpeech": "article",
      "case": "nominative",
      "gender": "masculine",
      "number": "plural"
    }
  ],
  [
    "μετιόντες", "μέτειμι2",
    {
      "partOfSpeech": "participle",
      "case": "nominative",
      "gender": "masculine",
      "number": "plural",
      "tense": "present",
      "voice": "active"
    }
  ],
  [
    "οὐκέτι", "οὐκέτι",
    {
      "partOfSpeech": "adverb"
    }
  ],
  [
    "περιεόντα", "περίειμι1",
    {
      "partOfSpeech": "participle",
      "case": "accusative",
      "gender": "masculine",
      "number": "singular",
      "tense": "present",
      "voice": "active"
    }
  ],
  [
    "ἀλλὰ", "ἀλλά",
    {
      "partOfSpeech": "adverb"
    }
  ],
  [
    "πρῶτον", "πρῶτος",
    {
      "partOfSpeech": "adjective",
      "case": "accusative",
      "gender": "masculine",
      "number": "singular"
    }
  ],
  [
    "κατακοπέντα", "κατακόπτω",
    {
      "partOfSpeech": "participle",
      "case": "accusative",
      "gender": "masculine",
      "number": "singular",
      "tense": "aorist",
      "voice": "passive"
    }
  ]
]

```

[Look here](https://github.com/nkallen/perseus-nlp/blob/master/lib/featurizer.coffee) for features currently considered for greek. Generally, prefixes, suffixes, tag bigrams and trigrams, and morpheus accentuation matches are taken into consideration.
