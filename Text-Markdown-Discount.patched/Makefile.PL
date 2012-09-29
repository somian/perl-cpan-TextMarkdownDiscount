# #-# RC boilerpl keywords
# #-# $RCSfile: Makefile.PL,v $
# #-# $Author: somian $
# #-# $Date: 2012-09-29 13:28:58 $
# #-# $Revision: 1.3 $
# #-# $Source: /var/lib/cvs/softvendroot/Text-Markdown-Discount/Makefile.PL,v $
# #-# end boilerplate
# #-#
use strict;
use warnings;

use ExtUtils::MakeMaker;
use File::Spec;

# Add to mapping in this sub if ever any more installable scripts are added to this
# package; at this time, only "Markdown.[pl|plx|pls|perl]" is installed (if interactive
# prompt returns "yes" from user).
my %EXEfiles = ('Markdown' => 'xt/MarkdownXS.pl');
sub filename_pair {
    my @pair = (shift @_, undef);
    $pair[1] = $EXEfiles{$1} if $pair[0] =~ /^(Markdown)/gms;
    return $pair[1] ? @pair : ();
}

sub do_install_script {
    my $distsrc_scriptf = q[xt/MarkdownXS.pl];
    my $from_this_to_blib;
    my $scriptname_ext  = q[.plx];
    my $MyInstallBin = q[
  {
package MY;
  sub installbin {
    my $mm_instance = shift;
    my $inherit_default = $mm_instance->SUPER::installbin;
    my @names = map { ::filename_pair($_) } @{$mm_instance->{EXE_FILES}};
    my $prependence = sprintf "\%s : \%s\n\t\$(CP) \$^ \$@\n\n", $names[0], $names[1];
    return $prependence . $inherit_default;
  }
}
];  # Need to eval this later if we pass a non-empty arrayref in EXE_FILES, to
    # the WriteMakefile() ...to add appropriate rules to Makefile.

  # Ask user if they want Markdown.pl script installed (return val used in EXE_FILES below).
  # For EU::MM function prompt()
    my $msg_yn = <<'        EO_HERE_DOC';
Would you like to have the executable script "Markdown" installed for you when
the module files are installed? [no] yes or no :
        EO_HERE_DOC

    my $msg_we = <<'        EO_EREH_DOC';
What filename extension would you like to have the installed executable script
use? (suggested: .plx .perl .pls .pl) :
        EO_EREH_DOC

    my $action = ExtUtils::MakeMaker::prompt($msg_yn, 'no');
    if($action =~/[Yy][Ee]?[Ss]?/) {
        my $chosen = ExtUtils::MakeMaker::prompt($msg_we, '.plx');
        if ($chosen !~ /^[.]\w+$/gmx) {
            ExtUtils::MakeMaker::prompt(
               'That does not seem like a workable extn :-(. Using default ".plx"');
            $scriptname_ext = q[.plx];
        } else {
            $scriptname_ext = $chosen;
        }

        $from_this_to_blib = q[Markdown] . $scriptname_ext;
        Copy_Check_Clean($distsrc_scriptf, $from_this_to_blib)
            and
        eval $MyInstallBin; die $@ if $@;

        return [ $from_this_to_blib ]
    }
    return [ ];
}

# Determine name of 'discount' lib src files dir
opendir my $topdir, q[.];
my $nexte;
while (  defined( $nexte = readdir $topdir ) ) {
    last if $nexte =~ /discount[-]2[.]\d[.]\d*/
}
closedir $topdir;


my $extdir = $nexte || 'discount-2.1.5a';
my $myextlib = File::Spec->catfile($extdir, 'libmarkdown.a');
my $clean_files = join (" ",
                  map{ File::Spec->catfile($extdir, $_) }
                  qw (
Csio.o
basename.o
blocktags
cols
config.cmd
config.h
config.log
config.mak
config.md
config.sub
css.o
docheader.o
dumptree.o
echo
emmatch.o
flags.o
generate.o
html5.o
libmarkdown
libmarkdown.a
librarian.sh
main.o
makepage
markdown
markdown.o
mkd2html
mkd2html.o
mkdio.h
mkdio.o
mktags
pgm_options.o
resource.o
setup.o
tags.o
theme
theme.o
toc.o
theme
theme.o
toc.o
version.c
version.o
xml.o
xmlpage.o
                  ));

sub Copy_Check_Clean {
    my ($dist_src , $inst_from) = @_;
    my $rtv = 1;
    $clean_files .= ' '.$inst_from;
    my $tru = eval "use File::Copy 'cp'; 1";
    unless ($tru && !$@) {
        warn "Could not get File::Copy module to copy to $inst_from";
    }
    cp($dist_src , $inst_from) or do {
        warn
             "Tried to copy $dist_src to $inst_from but failed: ";
        $rtv = 0;
                                     };
    return $rtv;
}



sub MY::postamble {
    my $cygshell = $^O =~ /cygwin/i ? 'dash' : 'sh';
    my $gcc_fPIC = ($^O =~ /cygwin/i or $^O =~ /win/i) ? '' : ' -fPIC';
    return sprintf('
LIGHT_SHELL = '. ( $cygshell || 'sh' ).'
$(MYEXTLIB):
	%s
', qq{( cd $extdir; CC='\$(CC)$gcc_fPIC' \$(LIGHT_SHELL) configure.sh; make )\n});
}

# For cygwin - rebase problems: use verbose flag
sub MY::install {
    my($self, %attribs) = @_;
    my $s = ExtUtils::MM_Unix::install($self, %attribs);
    return '' unless $s;
    return $s unless %{$self->{XS}} && $^O =~ /cygwin/i;

    my $triffic = '';
    my $rebaseverstr = -f '/bin/rebase' ? `/bin/rebase -V 2>&1` : '0';
    my ($rebasever) = $rebaseverstr =~ /rebase version ([0-9.]+)/;
    $rebasever =~ s/(\d\.\d+)\./$1/;
    if ($rebasever > 3.01) {  # new rebase 3.0.2 with database
         $triffic = "\n".'ifeq (${REBASE_VERBOSE},)' .
                    "\n".'      CYGREBASE = /bin/rebase --verbose --no-dynamicbase -s' .
                    "\n".'else' .
                    "\n".'      CYGREBASE = /bin/rebase --no-dynamicbase -s' .
                    "\n".'endif' ."\n";
      my $INSTALLDIRS = $self->{INSTALLDIRS};
      my $INSTALLLIB = $self->{"INSTALL". ($INSTALLDIRS eq 'perl' ? 'ARCHLIB' : uc($INSTALLDIRS)."ARCH")};
      my $dll = "$INSTALLLIB/auto/$self->{FULLEXT}/$self->{BASEEXT}.$self->{DLEXT}";
      $s =~ s|^(pure_install :: pure_\$\(INSTALLDIRS\)_install\n\t)\$\(NOECHO\) \$\(NOOP\)\n|$1\$(CHMOD) \$(PERM_RWX) \$(DESTDIR)$dll\n\ttest -n "\$(DESTDIR)\" \|\| \$(CYGREBASE) $dll\n|m;
      $s = $triffic . $s;
    }
    $s;
}

WriteMakefile(
    NAME              => 'Text::Markdown::Discount',
    VERSION_FROM      => 'lib/Text/Markdown/Discount.pm',
    PREREQ_PM         => {},
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/Text/Markdown/Discount.pm',
       AUTHOR         => 'Masayoshi Sekimura <sekimura@cpan.org>') : ()),
    LIBS               => '-L' . $extdir,
    INC               => '-I. -I' . $extdir,
    MYEXTLIB          => $myextlib,
    EXE_FILES         => &do_install_script,
    clean             => { FILES => $clean_files },
);
