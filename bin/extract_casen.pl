#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# extract_casen.pl                   falk@lormoral
#                    14 Mar 2013

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

extract_casen.pl

=head1 USAGE

  perl extract_casen.pl text_tagged_with_casen

=head1 DESCRIPTION

Extracts the named entities recognised by the CasEN NER tool.
and produces a list of these, one entity per line.

=head1 REQUIRED ARGUMENTS

A (text) file with tagged named entities in the following format.

 Egypte: nouveaux troubles au <ent type="region" grf="tagTopo.grf_4">Caire</ent> et à <ent type="ville" grf="tagTopo.grf_3">Port-Saïd</ent> après un verdict
 {S}Des troubles ont éclaté samedi au <ent type="region" grf="tagTopo.grf_4">Caire</ent> et à <ent type="ville" grf="tagTopo.grf_3">Port-Saïd</ent> (nord-est), après un nouveau verdict de la justice égyptienne dans le procès d'une tragédie du football, aloudissant le climat déjà tendu dans le pays.
 {S}Un tribunal de <ent type="ville" grf="tagTopo.grf_3">Port-Saïd</ent>, siégeant au <ent type="region" grf="tagTopo.grf_4">Caire</ent> pour des raisons de sécurité, a annoncé 24 condamnations à des peines de prison _dont cinq à perpétuité_ ainsi que 28 acquittements, et a confirmé 21 condamnations à mort prononcées en janvier.
 
The script extracts the forms in the <<ent>> mark-up.

MWEs are split up and each form is listed separately.

=head1 OPTIONS

=cut


my %opts = (
	    'mwes_out' => '',
	   );

my @optkeys = (
	       'mwes_out:s',
	      );

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };
unless (@ARGV) { pod2usage(2); };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

use locale;
use POSIX qw(locale_h);
setlocale(LC_COLLATE, 'fr_FR.utf8');

open (my $fh, '<:encoding(utf-16)', $ARGV[0]) or die "Couldn't open $ARGV[0] for reading";

my %nes;
my %mwes;

while (my $line = <$fh>) {
  chomp($line);
  my @ents = ($line =~ m{ <ent.*?>([^<]+)</ent> }xmsg);

  foreach my $ent (@ents) {
    my @words = split(/\s+/, $ent);
    if (scalar(@words) > 1) {
      $mwes{$ent}++;
    }
    map { $nes{$_}++ } @words;
  }

}

close $fh;

print STDERR "Number of named entities found: ", scalar(keys %nes), "\n";

foreach my $word (sort keys %nes) {
  print "$word\n";
}

if ($opts{mwes_out}) {
  if (open $fh, '>:encoding(utf-8)', $opts{mwes_out}) {
    foreach my $mwe (sort keys %mwes) {
      print $fh "$mwe\n";
    }
    close $fh;
  } else {
    warn "Couldn't open $opts{mwes_out} for output: $!\n";
  }
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
