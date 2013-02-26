#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# get_sentences_4_word.pl                   falk@lormoral
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

=head1 NAME

get_sentences_4_word.pl

=head1 USAGE

   

=head1 DESCRIPTION

Stub documentation for get_sentences_4_word.pl, 

=head1 REQUIRED ARGUMENTS

Word id

=head1 OPTIONS

=cut


my %opts = (
  'db_dir' => '',
  'db_bn' => '',
  );

my @optkeys = (
  'db_dir:s',
  'db_bn=s',
  );

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };
unless (@ARGV) { pod2usage(2) };

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

my $query_id = $ARGV[0];

my $db_root = '.';
if ($opts{db_dir}) {
  $db_root = $opts{db_dir};
}


my $inv_w_fn = join('.', $opts{db_bn}, 'inv_w');

$inv_w_fn = join('/', $db_root, $inv_w_fn);

my %sent_ids;

open (my $fh, '<', $inv_w_fn) or die "Couldn't open $inv_w_fn for reading: $!\n";
while (my $line = <$fh>) {
  my ($w_id, $s_id, $pos) = split(/\s+/, $line);
  next unless ($w_id == $query_id);
  $sent_ids{$s_id} = ' ';
}
close $fh;

print STDERR "$query_id appears in ", scalar(keys %sent_ids), " sentences\n";

my $sent_fn = join('.', $opts{db_bn}, 'sentences');
$sent_fn = join('/', $db_root, $sent_fn);

open($fh, '<:encoding(utf-8)', $sent_fn) or die "Couldn't open $sent_fn for reading: $!\n";
while (my $line = <$fh>) {
  my ($s_id, $sent) = split(/\t/, $line);
  next unless ($sent_ids{$s_id});
  print $line;
}
close $fh;



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
