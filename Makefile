.PHONY: clean

FILES = sections/00-metadata.md \
	sections/00-preface.md \
	sections/01-introduction.md \
	sections/02-proposal.md \
	sections/03-initial-preparation.md \
	sections/04-final-preparation.md \
	sections/05-the-event.md \
	sections/06-aftermath.md \
	sections/07-history.md \
	sections/08-glossary.md \
	sections/09-code-of-conduct.md \
	sections/10-about-the-author.md

all: pdf epub

pdf:
	pandoc $(FILES) -o perl-jam.pdf

epub:
	pandoc $(FILES) -o perl-jam.epub

clean:
	rm -f perl-jam.pdf perl-jam.epub
