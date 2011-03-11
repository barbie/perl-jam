#!/usr/bin/perl

use strict;
use warnings;

use File::Path 'mkpath';
use File::Spec::Functions qw( catfile catdir splitpath );

my @TOC;
my $sections_href = get_section_list();

clear_all();

for my $chapter (get_chapter_list())
{
    my $text = process_chapter( $chapter, $sections_href );
    push @TOC, write_chapter( $chapter, $text );
}

die( "Scenes missing from chapters:", join "\n\t", '', keys %$sections_href )
    if keys %$sections_href;

write_toc(\@TOC);

exit;

sub get_chapter_list
{
    my $glob_path = catfile( 'sections', 'chapter_??.pod' );
    return glob( $glob_path );
}

sub get_section_list
{
    my %sections;
    my $sections_path = catfile( 'sections', '*.pod' );

    for my $section (glob( $sections_path ))
    {
        next if $section =~ /\bchapter_??/;
        my $anchor = get_anchor( $section );
        $sections{ $anchor } = $section;
    }

    return \%sections;
}

sub get_anchor
{
    my $path = shift;

    open my $fh, '<:utf8', $path or die "Can't read '$path': $!\n";
    while (<$fh>) {
        next unless /Z<(\w*)>/;
        return $1;
    }

    die "No anchor for file '$path'\n";
}

sub process_chapter
{
    my ($path, $sections_href) = @_;
    my $text                 = read_file( $path );

    $text =~ s/^L<(\w+)>/insert_section( $sections_href, $1, $path )/emg;

    $text =~ s/(=head1 .*)\n\n=head2 \*{3}/$1/g;
    return $text;
}

sub read_file
{
    my $path = shift;
    open my $fh, '<:utf8', $path or die "Can't read '$path': $!\n";
    return scalar do { local $/; <$fh>; };
}

sub insert_section
{
    my ($sections_href, $name, $chapter) = @_;

    die "Unknown section '$name' in '$chapter'\n"
        unless exists $sections_href->{ $1 };

    my $text = read_file( $sections_href->{ $1 } );
    delete $sections_href->{ $1 };
    return $text;
}

sub write_chapter
{
    my ($path, $text) = @_;
    my $name          = ( splitpath $path )[-1];
    my $chapter_dir   = catdir( 'build', 'chapters' );
    my $chapter_path  = catfile( $chapter_dir, $name );

    mkpath( $chapter_dir ) unless -e $chapter_dir;

    my @toc;
    my @text = split(m!$/!,$text);
    for my $line (@text) {
        if($line =~ /^=head(\d) (.*?)\s*$/) {
            my ($level,$title,$ref) = ($1,$2,$2);
            $ref =~ s/ /_/g;
            $ref =~ s/[^\w -]/-/g;
            $ref .= "_$level";
            $text =~ s/(=head$level $title)/Z<$ref>\n\n$1/;
            push @toc, [$level, $title, $ref, $name];
        }
    }

    open my $fh, '>:utf8', $chapter_path
        or die "Cannot write '$chapter_path': $!\n";

    print {$fh} $text;

    warn "Writing '$path'\n";

    $chapter_path  = catfile( $chapter_dir, 'chapter_all.pod' );
    open my $fha, '>>:utf8', $chapter_path
        or die "Cannot write '$chapter_path': $!\n";

    print {$fha} $text;
    return @toc;
}

sub write_toc
{
    my $toc = shift;

    my $chapter_dir   = catdir( 'build', 'chapters' );
    my $chapter_path  = catfile( $chapter_dir, 'chapter_toc.pod' );

    open my $fh, '>:utf8', $chapter_path
        or die "Cannot write '$chapter_path': $!\n";

    print $fh "=head$_->[0] $_->[1] [$_->[2],$_->[3]]\n\n"    for(@$toc);
}

sub clear_all {
    my $chapter_dir   = catdir( 'build', 'chapters' );
    my $chapter_path  = catfile( $chapter_dir, 'chapter_all.pod' );
    unlink $chapter_path;
}
