#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# make_exclusion_list.pl                   falk@administrateur
#                    26 Feb 2013

use warnings;
use strict;
use English;

use Data::Dumper;
use Carp;
use Carp::Assert;

use Pod::Usage;
use Getopt::Long;

use utf8;

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');


=head1 NAME

make_exclusion_list.pl

=head1 USAGE

 perl make_exclusion_list.pl --prolex=prolex known named entities
                             --mwes=multiwords
      known word list    

=head1 DESCRIPTION

Merges various resources into one exclusion list.

Format of resulting exclusion list is one word per line.

=head1 REQUIRED ARGUMENTS

Predefined known word list (one word per line).

=head1 OPTIONS

=over 2

=item prolex

List of known named entities from unitex distribution.

Format:

 18 Brumaire an VIII,18 Brumaire an VIII.N+PR+Pragmonyme+Histoire:ms
 18 Brumaire,18 Brumaire.N+PR+Pragmonyme+Histoire:ms
 3M,3M.N+PR+DetZ+Anthroponyme+Collectif+Groupement+Entreprise:ms:fs
 A'ana,A'ana.N+PR+DetZ+Toponyme+Territoire+Region:ms:fs:mp:fp
 A\.N\. Moller=Maersk,A\.N\. Moller=Maersk.N+PR+DetZ+Anthroponyme+Collectif+Grou pement+Entreprise:ms:fs
 Aa,Aa.N+PR+Toponyme+Hydronyme:ms
 Aalto,Alvar Aalto.N+PR+Hum+DetZ+Anthroponyme+Individuel+Celebrite:ms
 Aar,Aar.N+PR+Toponyme+Hydronyme:fs
 Aarau,Aarau.N+PR+DetZ+Toponyme+Ville:ms:fs
 Aare,Aare.N+PR+Toponyme+Hydronyme:fs
 Aare,Aare.N+PR+Toponyme+Hydronyme:ms:fs:mp:fp
 Aaron,Aaron.N+PR+Hum+DetZ+Anthroponyme+Individuel+Celebrite:ms
...

Only the form before the first ',' is kept.

=item mwes

File containing multiword expressions as used by tinyCC, one
expression per line. In these expressions, tinyCC replaces spaces by
'_', so these expressions (uncapitalised version) are included into
the merged exclusion list.

=back

=cut


my %opts = (
  'prolex' => '',
  'mwes' => '',
  );

my @optkeys = (
  'prolex=s',
  'mwes:s',
  );

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };
unless (@ARGV) { pod2usage(2); };


print STDERR "Options:\n";
print STDERR Dumper(\%opts);

my %logo_known;

open (my $fh, '<:encoding(utf-8)', $ARGV[0]) or die "Couldn't open $ARGV[0] for reading: $!\n";
while (my $line = <$fh>) {
  chomp($line);
  $line =~ s{ \A \s+ }{}xmsg;
  $line =~ s{ \s+? \z }{}xmsg;
  $logo_known{$line}++;
}

close $fh;

my %prolex;

my $prolex_in_logo_known = 0;
my $in_prolex = 0;
open($fh, '<:encoding(utf-16)', $opts{prolex}) or die "Couldn't open $opts{prolex} for reading: $!\n";
while (my $line = <$fh>) {
  my($word, @rest) = split(/,/, $line);
  $in_prolex++;
  next if ($word =~ m{\s}xmsg);
  unless ($logo_known{$word}) {
    $logo_known{$word}++;
    $prolex_in_logo_known++;
  }
}
close $fh;

my %mwes;

if ($opts{mwes}) {
  if (open($fh, '<:encoding(utf8)', $opts{mwes})) {
    while (my $line = <$fh>) {
      chomp($line);
      my $mwe = $line;
      $mwe =~ s{ \s+ }{_}xmsg;
      $mwe = lc($mwe);
      $logo_known{$mwe}++;
    }
  } else {
    warn "Couldn't open $opts{mwes} for reading: $!\n";
  }
}

print STDERR "Number of words in Prolex: $in_prolex\n";
print STDERR "Number of Prolex words in logo known words list: $prolex_in_logo_known\n";
print STDERR "Number of words in merged exclusion list: ", scalar(keys %logo_known), "\n";

use locale;
use POSIX qw(locale_h);
setlocale(LC_COLLATE, 'fr_FR.utf8');

foreach my $word (sort keys %logo_known) {
  print $word, "\n";
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
