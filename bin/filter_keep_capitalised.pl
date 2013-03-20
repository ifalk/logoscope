#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# filter_keep_capitalised.pl                   falk@lormoral
#                    11 Mar 2013

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

filter_keep_capitalised.pl

=head1 USAGE

   perl filter_keep_capitalised.pl --word_list=list of words to be filtered
                              --exc_list=list of known words


=head1 DESCRIPTION

Keeps those words in I<word_list> for which the lower case version is not present in I<exc_list>

The output format is the same as the format of the file giving the input list of words (option I<word_list>).

=head1 REQUIRED ARGUMENTS

=over 2

=item word_list 

File containing list of words retrieved from the corpus. The expected
format is the following.

 id     word    #frequency

 1	!	130
 2	"	2156
 3	#	13
 4	$	3
 ....
 101	de	13696
 102	la	6721
 103	le	5287
 104	à	5200
 105	l	4179

The first 100 lines are reserved for punctuation marks.

=item exc_list

File containing a list of known words, one word per line.

=item words2sentences

This option must be provided if the I<discard> option is not set.

File containing index of words into sentences. It gives the position of the word in the sentence. The expected format is as follows:

 w id sent id  position in sent.

 98	1	0
 3142	1	1
 16	1	2
 110	1	3
 1411	1	4

=head1 OPTIONS

=cut


my %opts = (
	    'word_list' => '',
	    'exc_list' => '',
	   );

my @optkeys = (
	       'word_list=s',
	       'exc_list=s',
	      );

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

my %exclude;

open(my $fh, '<:encoding(utf-8)', $opts{exc_list}) or 
  die "Couldn't open $opts{exc_list} for reading: $!\n";

while (my $line = <$fh>) {
  chomp($line);
  $line =~ s{ \A \s+ }{}xmsg;
  $line =~ s{ \s+? \z }{}xmsg;
  $exclude{$line}++;
}

close $fh;

open($fh, '<:encoding(utf-8)', $opts{word_list}) or
  die "Couldn't open $opts{word_list} for reading: $!\n";

use locale;
use POSIX qw(locale_h);
setlocale(LC_COLLATE, 'fr_FR.utf8');

my $count = 0;

while (my $line = <$fh>) {
  chomp($line);

  my ($id, @rest) = split(/\s+/, $line);

  my $freq = pop(@rest);
  my $word = join(' ', @rest);

  ### ignore acronyms
  next if ($word =~ m{ \A [\p{Lu}\p{Lt}]+ \z }xms);

  ### ignore if not capitalised
  next if ($word =~ m{ \A [^\p{Lu}\p{Lt}] }xms);

  my $downcase = lc($word);
  next if ($exclude{$downcase});

  print join("\t", $id, $word, $freq), "\n";
  $count++;
}


print STDERR "Number of unknown words: $count\n";
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
