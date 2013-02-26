#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# filter_capitalised.pl                   falk@jamballa.loria.fr
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

filter_capitalised.pl

=head1 USAGE

   perl filter_capitalised.pl --word_list=list of words to be filtered
                              --exc_list=list of known words
                              --words2sentences=index of words into sentences

=head1 DESCRIPTION

Checks for unknwon capitalised words whether they occur at the beginning of a sentence. In this case, if the uncapitalised version is known, the word can be discarded.


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

File containing a list of known words, one word per line.

=item words2sentences

File containing index of words into sentences. It gives the position of the word in the sentence. The expected format is as follows:

 w id sent id  position in sent.

 98	1	0
 3142	1	1
 16	1	2
 110	1	3
 1411	1	4


=back

=cut


my %opts = (
	    'word_list' => '',
	    'exc_list' => '',
	    'words2sentences' => '',
	   );

my @optkeys = (
	       'word_list=s',
	       'exc_list=s',
	       'words2sentences=s'
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

my %capitalised;

open($fh, '<:encoding(utf-8)', $opts{word_list}) or
  die "Couldn't open $opts{word_list} for reading: $!\n";

my @word_list = <$fh>;

my %capitalised_known;

foreach my $line (@word_list) {
  chomp($line);
  my ($id, $word, $freq) = split(/\s+/, $line);

  ### is word capitalised?
  if ($word =~ m{ \A ([\p{Lu}\p{Lt}]\p{Ll}+)+ \z }xms) {
    my $downcase = lc($word);
    ### is downcase word known?
    if ($exclude{$downcase}) {
      $capitalised_known{$id}++;
    }
  }

}

close $fh;


my %word_pos;

open($fh, '<:encoding(utf-8)', $opts{words2sentences}) or
  die "Couldn't open $opts{words2sentences} for reading: $!\n";

while (my $line = <$fh>) {
  chomp($line);
  my ($w_id, $s_id, $pos) = split(/\s+/, $line);


  next unless ($capitalised_known{$w_id});
  $word_pos{$w_id}->{$pos}++;
}

close $fh;

foreach my $line (@word_list) {
  chomp($line);
  my ($id, $word, $freq) = split(/\s+/, $line);

  ### is word all uppercase?
  if ($word =~ m{ \A \p{IsUpper}+ \z }xms) {
    my $downcase = lc($word);
    ### is downcase word known?
    unless ($exclude{$downcase}) {
      print join("\t", $id, $word, $freq), "\n";
    }
    next;
  }

  if ($capitalised_known{$id}) {
    ### does not occur at the beginning of the sentence
    unless ($word_pos{$id}->{1}) {
      print join("\t", $id, $word, $freq), "\n";
      next;
    }

    ### This means the capitalised word occurs at the beginning of the
    ### sentence in most cases
    if ($word_pos{$id}->{1} > $freq/2) {
      # print STDERR "Excluded: ", join("\t", $id, $word, $freq), "\n";
      # print STDERR Dumper($word_pos{$id});
      next;
    }

    print join("\t", $id, $word, $freq), "\n";
    # print STDERR Dumper($word_pos{$id});
    next;
    
  }

  print join("\t", $id, $word, $freq), "\n";

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
