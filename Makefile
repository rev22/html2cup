TARGETS=

all: $(TARGETS)

clean:
	rm -f $(TARGETS)

%.html: %.html.coffee htmlcup-loader.coffee
	(sh -c "coffee $< >$@.new" && mv $@.new $@ && touch -r $< $@) || rm -f $@

%.regen.html.coffee: %.html bin/html2coffee
	(sh -c "bin/html2coffee $< >$@.new" && mv $@.new $@) || rm -f $@

%.html: %.htmlcup bin/html2coffee
	(sh -c "bin/html2coffee $< >$@.new" && mv $@.new $@) || rm -f $@

%.js: %.coffee
	coffee -c $<


%.php: %.in.phpcup
	cup2php $< $@

%.phpcup: %.in.php
	php2cup_body $< $@

%.out.php: %.phpcup
	cup2php $< $@

%.out.phpcup: %.php
	php2cup_body $< $@

