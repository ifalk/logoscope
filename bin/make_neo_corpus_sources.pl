#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# make_neo_corpus_sources.pl                   falk@lormoral
#                    22 Mar 2013

use warnings;
use strict;
use English;

use Data::Dumper;
use Carp;
use Carp::Assert;

use Pod::Usage;
use Getopt::Long;

use utf8;

=head1 NAME

make_neo_corpus_sources.pl

=head1 USAGE

  perl make_neo_corpus_sources.pl 
          --sources_dir= directory where output text files are stored   
          neologism corpus in xml format

=head1 DESCRIPTION

The script takes as input a neologisms corpus in xml format.
The corpus gives for each neologism one or more text fragments containing this neologism. These text fragments are collected by the script and stored in the directory given by option I<sources_dir>.

=head1 REQUIRED ARGUMENTS

The neologism corpus in xml format. The format is shown in the following sample:

 <?xml version="1.0" encoding="utf-8"?>
  <corpus>

    <fiche id="L00001">
	<terme>abracadabrantesquement</terme>
	<type origine="abracadabrantesque" nature="adv">Xment</type>
	<date>2001</date>
	<contexte>article politique</contexte>
	<sources>
		<texte url="http://www.bruxelles-francophone.be/topic2035.html" type="forum" date="2009">
  LA BELGIQUE FRANCOPHONE DEPECEE MORCEAU PAR MORCEAU
  au fil des réformes institutionnelles … Revisitons l’étal de   1962 à 2005…
  ...
               <texte url="",  type="", date="">  
               ...


=head1 OPTIONS

=over 2

=item source_dir

Directory where the text fragments are stored. For example, the texts occuring in the above sample would be stored as:

   C<source_dir>/L00001_1.txt
   C<source_dir>/L00001_2.txt

=back

=cut


my %opts = (
	    'source_dir' => '',
	   );

my @optkeys = (
	       'source_dir=s',
	      );

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

unless (@ARGV) { pod2usage(2) };

use XML::LibXML;

use File::Path qw(make_path);

use Logo::Utils;

make_path($opts{source_dir});

my $dom = XML::LibXML->load_xml(location => $ARGV[0]);

my %id2url;

my @fiche_els = $dom->findnodes('//fiche');

foreach my $fiche_el (@fiche_els) {
  my $fiche_id = $fiche_el->getAttribute('id');

  next unless ($fiche_id);

  # my @text_els = $xpc->findnodes('.//texte', $fiche_el);
  my @text_els = $fiche_el->findnodes('.//texte');

  for my $text_nbr (0 .. $#text_els) {
    my $text_el = $text_els[$text_nbr];

    my $text_url = $text_el->getAttribute('url');
    my $text_name = join('_', $fiche_id, $text_nbr+1);

    my $text_content = $text_el->textContent();

    $text_content = Logo::Utils::clean_text($text_content);

    $text_content =~ s{ \x{A0} }{ }xmsg; 
    $text_content =~ s/[’\222]‘/'/g;
    $text_content =~ s/\.+/./g;
    $text_content =~ s/…/./g;
    $text_content =~ s/,([^\s])/, $1/g;

    my $out_filename = join('.', $text_name, 'txt');
    $out_filename = join('/', $opts{source_dir}, $out_filename);

    $id2url{$out_filename} = $text_url;

    if (open my $fh, '>:encoding(utf-8)', $out_filename) {
      print $fh $text_content, "\n";
      close $fh;
    } else {
      warn "Couldn't open $out_filename for writing: $!\n";
    }

  }
}

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');


foreach my $outname (sort keys %id2url) {
  print "Output file name: $outname\n";
  print "Text url: $id2url{$outname}\n";
}


1;





__END__

=head1 EXIT STATUS

=head1 CONFIGURATION

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

created by template.el.

It looks like the author of this script was negligent
enough to leave the stub unedited.


=head1 AUTHOR

Ingrid Falk, E<lt>E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Ingrid Falk

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
