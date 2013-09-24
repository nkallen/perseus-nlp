OBJDIR := build
targets = trigrams.json bigrams.json

.PHONY: clean
.PHONY: all
.PHONY: train
.PHONY: bigrams
.PHONY: trigrams
.PHONY: sentences

train: $(OBJDIR)/morpheus.unaccentuated.json $(OBJDIR)/morpheus.accentuated.json
	 for x in `find vendor/treebank -name '*grc?.json'`;\
	 do bin/sentences < $$x;\
	 done | bin/train > $(OBJDIR)/v.json
sentences:
	 for x in `find vendor/treebank -name '*grc?.json'`;\
	 do bin/sentences < $$x;\
	 done
bigrams: $(OBJDIR)/bigrams.json
trigrams: $(OBJDIR)/trigrams.json

$(OBJDIR)/morpheus.unaccentuated.json: $(OBJDIR)/morpheus.tsv
	cat $(OBJDIR)/morpheus.tsv | bin/token2tag unaccentuated > $(OBJDIR)/morpheus.unaccentuated.json
$(OBJDIR)/morpheus.accentuated.json: $(OBJDIR)/morpheus.tsv
	cat $(OBJDIR)/morpheus.tsv | bin/token2tag accentuated > $(OBJDIR)/morpheus.accentuated.json
$(OBJDIR)/morpheus.tsv: $(OBJDIR)/greek.morph.uni.xml
	bin/morphemes2tsv $(OBJDIR)/greek.morph.uni.xml > $(OBJDIR)/morpheus.tsv
$(OBJDIR)/greek.morph.uni.xml:
	tar -xvzf vendor/p4_misc/parses/greek.morph.uni.tgz -C $(OBJDIR)
$(OBJDIR)/bigrams.json:
	for x in `find vendor/treebank -name '*grc?.json'`;\
	do bin/ngram-treebank 2 < $$x;\
	done | bin/tsv2json > $(OBJDIR)/bigrams.json
$(OBJDIR)/trigrams.json:
	for x in `find vendor/treebank -name '*grc?.json'`;\
	do bin/ngram-treebank 3 < $$x;\
	done | bin/tsv2json > $(OBJDIR)/trigrams.json
$(OBJDIR):
	mkdir $(OBJDIR)

clean:
	rm -rf build/*
