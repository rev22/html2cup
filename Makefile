TARGETS=


all: $(TARGETS)

clean:
	rm -f $(TARGETS)

%.html: %.html.coffee
	(sh -c "coffee $< >$@.new" && mv $@.new $@ && touch -r $< $@) || rm -f $@

%.regen.html.coffee: %.html bin/html2cup
	(sh -c "bin/html2cup $< >$@.new" && mv $@.new $@) || rm -f $@

%.html: %.htmlcup bin/html2cup
	(sh -c "bin/html2cup $< >$@.new" && mv $@.new $@) || rm -f $@

%.js: %.coffee
	coffee -c $<


%.php: %.in.phpcup
	script/cup2php $< $@

%.phpcup: %.in.php
	script/php2cup_body $< $@

%.out.php: %.phpcup
	script/cup2php $< $@

%.out.phpcup: %.php
	script/php2cup_body $< $@

