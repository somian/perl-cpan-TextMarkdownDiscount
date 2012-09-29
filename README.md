perl-cpan-TextMarkdownDiscount
==============================

## Masayoshi Sekimura's CPAN module "Text-Markdown-Discount": fiddling with MakeMaker build details

### As per Sekimura's CPAN description:

> Perl extension interface for Discount, an implementation of
> [John Gruber's markdown](http://daringfireball.net/projects/markdown/ "Markdown home page")
> in C [developed by David Loren Parsons](http://www.pell.portland.or.us/ "Markdown-Discount project home page")

* * *

This repo / project was primarily created for myself, to hold / document
the tweaking done with the ExtUtils::MakeMaker -based build configuration
(Makefile.PL). No changes were made to the actual perl module / library,
either in the XS part or the Perl part, when this repo was created.

### Initial changes to build process (in Makefile.PL)

+ Let the subdir containing the Discount library (C code) be found based
  on dir name pattern instead of hard coded (so that a newer release of
  Discount can be dropped in without need for rewriting Makefile.PL).

+ Use prompt at Makefile-generation time determine whether the script-executable
  Markdown is installed at `make install` time. This code also allows the
  user to choose what extention to use for the installed script (not only .pl
  is possible, but Perl best practices also recommends the alternate ".plx"
  extention as a good way to differentiate an executable perl script (userspace
  file) from an older non-module perl library (.pl). Other possibilities offered
  are ".perl" or ".pls".

+ Some code to detect that build is running on Cygwin (cygwinperl) is added.
  Installing compiled C modules on cygwinperl lately involves automated (in
  ExtUtils) execution of a utility named `rebase` to address the "base address
  clash" problem that exists for Cygwin Perl (and Python) binaries and extensions.
  The added code detects cygwinperl and flips `-verbose` switch on to watch
  what `rebase` is doing.

Additional files: ordinary patch to Makefile.PL (generated using commandline:

   > `LC_ALL=C TZ=UTC0 diff -rbB -U5` ...

* * *

Started from Text-Markdown-Discount-0.04 of 01 Jan 2012, at
[search.cpan.org URL for src kit archive](http://search.cpan.org/CPAN/authors/id/S/SE/SEKIMURA/Text-Markdown-Discount-0.04.tar.gz "tar.gz file")

* * *

#### Last updated:  2012-09-29T10:34:19 UTC-04:00

