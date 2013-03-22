#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# get_corpus_neo.pl                   falk@lormoral
#                    21 Mar 2013

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

get_corpus_neo.pl

=head1 USAGE

   

=head1 DESCRIPTION

Stub documentation for get_corpus_neo.pl, 

=head1 REQUIRED ARGUMENTS

=head1 OPTIONS

=cut


my %opts = (
	    'ws' => '',
	   );

my @optkeys = (
	       'ws=s',
	      );

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

unless (@ARGV) { pod2usage(2); };

use XML::LibXML;


my $dom = XML::LibXML->load_xml(location => $ARGV[0]);

my @neo_els = $dom->findnodes('//neologisme');

my %neos;

foreach my $neo_el (@neo_els) {
  my $neo = $neo_el->textContent();
  $neos{$neo}++;
}

print "Number of neologisms accounted for: ", scalar(keys %neos), "\n";

open (my $fh, '<:encoding(utf8)', $opts{ws}) or die "Coudn't open $opts{ws} for input: $!\n";

my %ws;

while (my $line = <$fh>) {
  chomp($line);
  $ws{$line}++;
}

close $fh;

my @in_ws = grep { $ws{$_} } keys %neos;
my @not_in_ws = grep { not(defined($ws{$_})) } keys %neos;

print "In wortschatz: ", scalar(@in_ws), "\n";

use locale;
use POSIX qw(locale_h);
setlocale(LC_COLLATE, 'fr_FR.utf8');

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

foreach my $neo (sort @in_ws) {
  print $neo, "\n";
}

print STDERR "Not in Wortschatz: ", scalar(@not_in_ws), "\n";

foreach my $neo (sort @not_in_ws) {
  print STDERR $neo, "\n";
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
