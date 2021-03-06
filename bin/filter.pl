#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# filter.pl                   falk@jamballa.loria.fr
#                    14 Feb 2013

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

filter.pl

=head1 USAGE

  perl filter.pl --word_list=list of words retrieved from corpus
                 --exc_list=list of known words

=head1 DESCRIPTION

The script takes as input a list of words retrieved from a corpus and returns those words which are not in a list of known words.

The output format is the same as the format of the file giving the input list of words (option I<word_list>).

=head1 REQUIRED ARGUMENTS



=head1 OPTIONS

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

File containing a list of known words.

=back


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

my $count = 0;
while (my $line = <$fh>) {
  chomp($line);
  $line =~ s{ \222 }{'}g;
  $line =~ s{ ' }{'}g;
  my ($id, @rest) = split(/\s+/, $line);
  next if ($id <= 100);

  my $freq = pop(@rest);
  my $word = join(' ', @rest);

  next unless($freq);

  ### does not contain any letter
  next unless ($word =~ m{ \p{L} }xms);

  ### contains '--'
  next if ($word =~ m{ -- }xmsg);

  ### contains https?://
  next if ($word =~ m{https?://});

  ### contains .(fr|com) at end
  # next if ($word =~ m{ \. fr \z}xms;
  # next if ($word =~ m{ \. com \z}xms;

  ### contains '=' and '&'

  next if ($word =~ m{=} and $word =~ m{&});
  next if ($word =~ m{@});

  ### matches a number 2e, 17e, etc.
  # next if ($word =~ m{ \A \d+ e r?\z}xms);

  ### matches a time 14H00, 23h00
  next if ($word =~ m{ \A [0-2]? [0-9] [Hh] [0-6]? [0-9]? \z }xms);

  ### matches .com or .fr at the end
  next if ($word =~ m{ \. (com|fr|org) / }xms);
  next if ($word =~ m{ \. (com|fr|org) \z }xms);

  ### replace œ by oe
  $word =~ s{œ}{oe}xmsg;

  ### remove '-' at beginning and end of word
  ### remove non-letter characters at beginning and end of word
  $word =~ s{\A [-–­]+ }{}xms;
  # $word =~ s{ \A [^\p{L}] }{}xms;
  $word =~ s{[-–­]+ \z}{}xms;
  # $word =~ s{[^\p{L}] \z}{}xms;

  ### remove '-' followed by pronoun at end of word (or là)
  $word =~ s{ - (t-)? (je|tu|il|elle|nous|vous|ils|elles|lui|le|la|les|on|là) \z }{}xms;

  ### has less than 2 letters
  next if (length($word) < 2);

  next if $exclude{$word};
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
