#!/usr/bin/perl

use strict;
use warnings;

use IO::File;
use Pod::PseudoPod::LaTeX;
use File::Spec::Functions qw( catfile catdir splitpath );

# P::PP::H uses Text::Wrap which breaks HTML tags
#local *Text::Wrap::wrap;
#*Text::Wrap::wrap = sub { $_[2] };

sub Pod::PseudoPod::LaTeX::start_Verbatim
{
    my $self = shift;

    $self->{scratch} .= "\\vspace{-6pt}\n"
                     .  "\\scriptsize\n"
                     .  "\\begin{verbatim}\n";
    $self->{flags}{in_verbatim}++;
}

sub Pod::PseudoPod::LaTeX::end_Verbatim
{
    my $self = shift;
    $self->{scratch} .= "\n\\end{verbatim}\n"
                     .  "\\vspace{-6pt}\n";

    #    $self->{scratch} .= "\\addtolength{\\parskip}{5pt}\n";
    $self->{scratch} .= "\\normalsize\n";
    $self->{flags}{in_verbatim}--;
    $self->emit();
}

my @chapters = get_chapter_list();
my $anchors  = get_anchors(@chapters);
my @indices;

#push @indices, write_toc();

for my $chapter (@chapters)
{
    my $out_fh = get_output_fh($chapter);
    my $parser = Pod::PseudoPod::LaTeX->new();

    $parser->output_fh($out_fh);
    $parser->parse_file($chapter);
}

exit;

sub get_anchors
{
    my %anchors;

    for my $chapter (@_)
    {
        my ($file)   = $chapter =~ /(chapter_\d+)./;
        my $contents = slurp( $chapter );

        while ($contents =~ /^=head\d (.*?)\n\nZ<(.*?)>/mg)
        {
            $anchors{$2} = [ $file . '.tex', $1 ];
        }
    }

    return \%anchors;
}

sub slurp
{
    return do { local @ARGV = @_; local $/ = <>; };
}

sub get_chapter_list
{
    my $glob_path = catfile( qw( build chapters chapter_??.pod ) );
    return glob $glob_path;
}

sub get_output_fh
{
    my $chapter = shift;
    my $name    = ( splitpath $chapter )[-1];
    my $htmldir = catdir( qw( build latex ) );

    $name       =~ s/\.pod/\.tex/;
    $name       = catfile( $htmldir, $name );

    open my $fh, '>:utf8', $name
        or die "Cannot write to '$name': $!\n";

    return $fh;
}

sub write_toc {
    my $file = catfile( qw( build html toc.html) );
    my $fh = IO::File->new($file,'w+') or die "Cannot open file [$file]: $!\n";

    print $fh "<html>\n<head>\n";
    print $fh "<title>Perl Jam : Table Of Contents</title>\n";
    print $fh "<link rel='stylesheet' href='style.css' type='text/css'>\n";
    print $fh "</head>\n<body>\n";

    printf $fh "<h1>Perl Jam : Table Of Contents</h1>\n";

    my $chapter_dir   = catdir( 'build', 'chapters' );
    my $file_toc  = catfile( $chapter_dir, 'chapter_toc.pod' );
    my $fh_toc = IO::File->new($file_toc,'r') or die "Cannot open file [$file_toc]: $!\n";

    my $level = -1;
    while(<$fh_toc>) {
        next    unless(/^=head(\d) (.*?)\s* \[([^,]+),([^\]]+)\]$/);
        my ($toc_level,$toc_title,$toc_ref,$toc_file) = ($1,$2,$3,$4);
        $toc_file =~ s/\.pod/\.html/;

        if($toc_level == $level)   { printf $fh "</li>\n"; }
        while($toc_level < $level) { printf $fh "</li>\n</ul></li>\n"; $level--; }
        while($toc_level > $level) { printf $fh "\n<ul>\n"; $level++ }
        printf $fh "<li><a href='${toc_file}#${toc_ref}'>$toc_title</a>";
    }

    while($level > 0) { printf $fh "</li>\n</ul></li>\n"; $level--; }

    print $fh "</ul>\n</body>\n</html>\n";

    return { file => 'toc.html', title => 'Table Of Contents' }
}
