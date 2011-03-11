#!/usr/bin/perl

use strict;
use warnings;

use IO::File;
use Pod::PseudoPod::HTML;
use File::Spec::Functions qw( catfile catdir splitpath );

# P::PP::H uses Text::Wrap which breaks HTML tags
local *Text::Wrap::wrap;
*Text::Wrap::wrap = sub { $_[2] };

my @chapters = get_chapter_list();
my $anchors  = get_anchors(@chapters);
my @indices;

sub Pod::PseudoPod::HTML::end_L
{
    my $self = shift;
    if ($self->{scratch} =~ s/\b(\w+)$//)
    {
        my $link = $1;
        die "Unknown link $link\n" unless exists $anchors->{$link};
        $self->{scratch} .= '<a href="' . $anchors->{$link}[0] . "#$link\">"
                                        . $anchors->{$link}[1] . '</a>';
    }
}

push @indices, write_toc();

for my $chapter (@chapters)
{
    my $out_fh = get_output_fh($chapter);
    my $parser = Pod::PseudoPod::HTML->new();

    $parser->output_fh($out_fh);

    # output a complete html document
    $parser->add_body_tags(1);

    # add css tags for cleaner display
    $parser->add_css_tags(1);

    $parser->no_errata_section(1);
    $parser->complain_stderr(1);

    $parser->parse_file($chapter);

    push @indices, store_chapter($chapter);
}

write_index(\@indices);

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
            $anchors{$2} = [ $file . '.html', $1 ];
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
    my $htmldir = catdir( qw( build html ) );

    $name       =~ s/\.pod/\.html/;
    $name       = catfile( $htmldir, $name );

    open my $fh, '>:utf8', $name
        or die "Cannot write to '$name': $!\n";

    return $fh;
}

sub store_chapter {
    my $chapter = shift;
    my $name    = ( splitpath $chapter )[-1];

    $name       =~ s/\.pod/\.html/;

    my $fh = IO::File->new($chapter,'r') or die "Cannot open file [$chapter]: $!\n";

    while(<$fh>) {
        if(/=head0 (.*)/) {
            return { file => $name, title => $1 };
        }
    }

    return { file => $name, title => 'No Title Found' }
}

sub write_index {
    my $indices = shift;

    my $file = catfile( qw( build html index.html) );
    my $fh = IO::File->new($file,'w+') or die "Cannot open file [$file]: $!\n";

    print $fh "<html>\n<head>\n";
    print $fh "<title>Perl Jam : Contents</title>\n";
    print $fh "<link rel='stylesheet' href='style.css' type='text/css'>\n";
    print $fh "</head>\n<body>\n";

    printf $fh "<h1>Perl Jam : Contents</h1>\n";
    printf $fh "<ul>\n";
    printf $fh "<li><a href='$_->{file}'>$_->{title}</a></li>\n" for(@$indices);
    printf $fh "</ul>\n";

    printf $fh "<p>Copyright &copy; 2011 Barbie. All rights reserved</p>\n";

    print $fh "</body>\n</html>\n";
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
