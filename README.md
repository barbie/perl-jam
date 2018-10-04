What is Perl Jam?
-----------------

The Perl Community is a wonderful thing. It is a collective of people who share
a common interest, the Perl programming language, but express that interest in
so many different ways. The projects, user groups and events all capture a
different part of the community, but it wasn't until the late 90s that the
community started to co-ordinate their activities.

In 1998 the first Perl Workshop took place in Germany, and in 1999 the first
YAPC Perl conference took place. These were the beginnings, but the events
themselves have grown and become further reaching than the initial core
developers that came along to those first events.

Perl Jam aims to collect together the knowledge and experience of organising
some great Perl events, and order them in such a way that anyone wishing to do
the same, can follow the footsteps of those who have gone before, and prepare
themselves for what will hopefully become a great event.

http://perljam.info


Intended Audience
-----------------

I assume readers have some interest in organising a technical conference. While
the book focuses on the Perl programming language, and the YAPC and Perl
Workshops, much of the content is applicable to any large technical event,
whether Open Source or commercial.


Reviewer Guidelines
-------------------

I appreciate all suggestions and critiques, especially:

 * is the work accurate?
 * is the work complete?
 * is the work coherent?
 * are there missing sections and subjects?
 * are the examples effective?
 * is the flow of information appropriate?

Building this Book
------------------

You need a modern version of Perl installed.  I recommend Perl 5.10.1, but
anything newer than 5.8.6 should work.

You should also have Pod::PseudoPod 0.16 or newer installed with its
dependencies.

From the top level directory of a checkout, build the individual chapters with:

    $ perl build/tools/build_chapters.pl

The chapter sources are in the sections/ directory.  Each chapter has a
corresponding chapter_nn.pod file.  Each file contains multiple POD links which
refer to other files in the sections/ directory.  Each of those files contains
a PseudoPOD Z<> anchor.

The build_chapters.pl program weaves these sections into chapters and writes
them to POD files in build/chapters.

(This process makes it easy to rearrange sections within and between chapters
without generating huge diffs.)

To build HTML from these woven chapters:

    $ perl build/tools/build_html.pl

This will produce nicely-formatted HTML in the build/html/ directory.  If
anything looks wrong, it's a mistake on my part (or a CSS problem) and patches
are very welcome.

To build an ePub eBook from the woven chapters:

    $ perl build/tools/build_epub.pl

This will produce an ePub eBook in the build/epub/ directory.

To build PDFs from the chapters:

    $ perl build/tools/build_pdf.pl

This will build PDFs in the build/pdf directory.  You must have App::pod2pdf
installed from the CPAN.


Contributing to Perl Jam
------------------------

For now, this draft work is licensed under a Creative Commons
Attribution-Noncommercial-No Derivative Works 3.0 License.  For more details,
see:

    http://creativecommons.org/licenses/by-nc-nd/3.0/

Please feel free to point people to this repository.  Suggestions and
contributions are welcome.  Please do not redistribute with modifications
(forking with Git is fine, but I request that you send me patches or pull
requests).

This book will be available as print-on-demand release in print from
Miss Barbell Productions:

    http://www.missbarbell.co.uk/
