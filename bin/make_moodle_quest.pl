#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# make_moodle_quest.pl                   falk@lormoral
#                    12 Mar 2013

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

make_moodle_quest.pl

=head1 USAGE

  perl make_moodle_quest.pl --db_name=logodb 
                            --db_user=logo 
                            --db_pw=scope
                            --lc 
                            --test_title=title of test
       list-of-selected-words

=head1 DESCRIPTION

Generates 3 moodle questions for each word in the word list provided as argument.

The first question is of type I<description> and gives up to 5 random sentences containing the given word.

The second question is of type I<multiple choice> with check boxes to assess for what reason (according to the user) the given word is not known.

The third question is of type I<shortanswer> and allows the user to provide a remark or comment.

The questionnaire is produced as an xml file in the moodle XML format. 

The sample sentences included in the questions are retrieved from a data base which is accessed using the data base parameters given as options. 

=head1 REQUIRED ARGUMENTS

A list of detected unknown words expected in the format shown in the following sample:

 446	supporteurs	30
 592	ex-président	22
 971	jihadistes	14
 1160	bolivarienne	12
 1276	islamistes	11
 ...

=head1 OPTIONS

=over 2

=item db_name
=item db_user
=item db_pw

Data base parameters needed to acces the I<logoscope> data base.

=item unknown_type

Option stating the type of detected unknown words. This is needed because the multiple choice questions depend on this.
Currently allowed values are:

=over 2

=item lc - lower case words

=item uc - upper case words

=back

=item nbr_ex

Number of sample sentences to be produced. Default is 3.

=item test_title

This is used to create the text string which appears in the 
category element:

 <<category>>
  <<text>>$module$/Défaut pour I<test_title><</text>>
 <</category>>

=back

=cut


my %opts = (
  'db_name' => '',
  'db_user' => '',
  'db_pw' => '',
  'unknown_type' => '',
  'nbr_ex' => 3,
  'test_title' => '',
  );

my @optkeys = (
  'db_name=s',
  'db_user=s',
  'db_pw=s',
  'unknown_type=s',
  'nbr_ex:i',
  'test_title=s'
  );

unless (@ARGV) { pod2usage(2); };

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };


print STDERR "Options:\n";
print STDERR Dumper(\%opts);

use List::MoreUtils qw(first_index);

my %ALLOWED_TYPES = ( 
		     lc => { 
			    mc_answers => [
			      ["Je n'ai pas d'éléments pour savoir", '10'],
			      ["Ce n'est pas un mot", '10'],
			      ["... c'est une faute de frappe", '10'],
			      ["C'est un mot existant et c'est...", '10'],
			      ["... un nom de personne", '3'],
			      ["... un nom de lieu", '3'],
			      ["... un nom de marque ou d'organisation", '3'],
			      ["C'est un mot existant étranger", '20'],
			      ["C'est très probablement un mot inédit", '30'],
			      ["... c'est un emprunt", '1'],
			      ],
			   },
		     uc => {
			    mc_answers => [
					   ['Mot nouveau', '50'],
					   ['Faute de frappe', '30'],
					   ['Entité nomée', '10'],
					  ],
			   }
		    );

#### elements ( [ el. name, el. text content ]) to be created and edded to each mc question
my @mc_elements = (
		   [ 'shuffleanswers', '0' ],
		   [ 'single', 'false' ],
		   [ 'answernumbering', 'none' ],
		  );

unless ($ALLOWED_TYPES{$opts{unknown_type}}) { pod2usage(2) };



use XML::LibXML;

use DBI;

# binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

my $db_name = $opts{db_name};
my $db_user = $opts{db_user};
my $db_pw = $opts{db_pw};

my $dbh = DBI->connect(
  "DBI:mysql:dbname=$db_name;mysql_local_infile=1", 
  $db_user,
  $db_pw,
  { RaiseError => 1 },
) or die $DBI::errstr;

my %w_ids2s_ids;
my @w_ids2words;

open (my $fh, '<:encoding(utf-8)', $ARGV[0]) or die "Couldn't open $ARGV[0] for reading: $!\n";

while (my $line = <$fh>) {
  chomp($line);
  my ($w_id, @rest) = split(/\s+/, $line);
  my $freq = pop(@rest);
  my $word = join(' ', @rest);


  push(@w_ids2words, [ $w_id => $word ]);

  my $sth = $dbh->prepare("select S_id from Inv_W where W_id = $w_id")
    || die "$DBI::errstr";
  $sth->execute();
  
  if ($sth->rows < 0) {
    print STDERR "No sentence for $w_id ($word).\n";
  } else {
    while (my @result = $sth->fetchrow_array()) {
      $w_ids2s_ids{$w_id}->{$result[0]} = "";
    }
  }
  $sth->finish;
}

close $fh;

my $sth = $dbh->prepare("SELECT MAX(S_id ) FROM Sentences")
 || die "$DBI::errstr";
$sth->execute();

my $max_sid = 9999;
if ($sth->rows < 0) {
  print STDERR "Couldn't get maximum sentence id\n";
} else {
  while (my @result = $sth->fetchrow_array()) {
    $max_sid = $result[0];
  }
}
$sth->finish;


my %examples;

foreach my $ref (@w_ids2words) {
  my ($w_id, $word) = @{ $ref };

  my $sent_nbr = 0;

  if ($examples{$word}) {
    $sent_nbr = scalar(keys %{ $examples{$word} });
  }

  foreach my $s_id (keys %{ $w_ids2s_ids{$w_id} }) {
    
    last if ($sent_nbr >= $opts{nbr_ex});

    my $sth = $dbh->prepare("select Sentence from Sentences where S_id = $s_id")
      || die "$DBI::errstr";
    $sth->execute();

    if ($sth->rows < 0) {
      print STDERR "No sentence for $s_id ($word, $w_id).\n";
    } else {
      while (my @result = $sth->fetchrow_array()) {

	my @words = split(/\s/, $result[0]);
	my $nbr_words = scalar(@words);

	if ($nbr_words <= 10) {

	  # print STDERR "$s_id: $result[0]\n";

	  # get more neighbouring sentences (of the same source)
	  my $sid_start = 1;
	  my $sid_end = $max_sid;
	  if ($s_id - 2 > 0) {
	    if ($s_id + 2 <= $max_sid) {
	      $sid_start = $s_id-2;
	      $sid_end = $s_id+2;
	    } else {
	      $sid_end = $max_sid;
	      $sid_start = $max_sid-4;
	    }
	  } else {
	    $sid_start = 1;
	    $sid_end = 5;
	  }

	  my $sth2 = $dbh->prepare(
"SELECT S_id, Source_id, sentence FROM `Sentences` INNER JOIN Inv_so
ON Sentences.S_id = Inv_so.Sent_id WHERE Sent_id between $sid_start and $sid_end"
)
      || die "$DBI::errstr";
	  $sth2->execute();
	  if ($sth2->rows < 0) {
	    print STDERR "No neighbouring sentences for $s_id ($word, $w_id).\n";
	  } else {
	    my @table;
	    while (my @result = $sth2->fetchrow_array()) {
	      push @table, \@result;
	    }

	    my $sid_index = first_index { $_->[0] == $s_id } @table;
	    my $source_id = $table[$sid_index]->[1];

	    my $max_index;
	    if ($table[$sid_index+1] and $table[$sid_index+1]->[1] == $source_id) {
	      $max_index = $sid_index+1;
	    } else {
	      $max_index = $sid_index;
	    }

	    my $min_index = $sid_index;
	    if ($table[$max_index-2] and $table[$max_index-2]->[1] == $source_id) {
	      $min_index = $max_index-2;
	    } elsif ($table[$max_index-1] and $table[$max_index-1]->[1] == $source_id) {
	      $min_index = $max_index-1;
	    }

	    my $ex_text = join(' ', map { $table[$_]->[2] } ($min_index .. $max_index));
	    
	    $examples{$word}->{$ex_text}->{$s_id}++;
			       
	  }
	  $sth2->finish();
	} else {
	  $examples{$word}->{$result[0]}->{$s_id}++;
	}
      }

      $sent_nbr = scalar(keys %{ $examples{$word} });
    }
    $sth->finish;

  }
}


$dbh->disconnect();

##### create xml document

my $doc = XML::LibXML::Document->new( '1.0', 'utf-8' );

my $quiz = $doc->createElement ('quiz');

$doc->setDocumentElement($quiz);

my $quest = $doc->createElement('question');
$quest->addChild($doc->createAttribute( type => 'category' ));

my $cat = $doc->createElement('category');
my $cat_text = $doc->createElement('text');

my $text_content = $opts{test_title};
$text_content =~ s{/}{//}g;
$text_content = "\$module\$/Défaut pour $text_content";

$cat_text->addChild($doc->createTextNode($text_content));

$cat->addChild($cat_text);
$quest->addChild($cat);

$quiz->addChild($quest);

my @mc_answers = @{ $ALLOWED_TYPES{$opts{unknown_type}}->{mc_answers} };

foreach my $ref (@w_ids2words) {
  my ($w_id, $word) = @{ $ref };

  #### description
  $quest = $doc->createElement('question');
  $quest->addChild($doc->createAttribute( type => 'description' ));

  my $name = $doc->createElement('name');
  my $name_text = $doc->createElement('text');
  $name_text->addChild($doc->createTextNode("$word description"));
  $name->addChild($name_text);
  $quest->addChild($name);

  my $q_text = $doc->createElement('questiontext');
  $q_text->addChild($doc->createAttribute( format => 'html' ));

  my $q_text_text = $doc->createElement('text');

  my $cdata_content = "<p>Le mot <font color=red>$word</font> n'est pas un mot connu. A votre avis, quelle est la raison ?</p> <h4>Exemples :</h4>";

  foreach my $sent (keys %{ $examples{$word} }) {

    my $repl_string = quotemeta($word);
    $sent =~ s{\b$repl_string\b}{<font color=red>$word</font>}xmsg;
    $cdata_content = join("\n", $cdata_content, "<p>$sent</p>");

  };

  $q_text_text->addChild(XML::LibXML::CDATASection->new( $cdata_content ));

  $q_text->addChild($q_text_text);
  
  $quest->addChild($q_text);

  $quiz->addChild($quest);

  #### multiple choice
  $quest = $doc->createElement('question');
  $quest->addChild($doc->createAttribute( type => 'multichoice' ));

  $name = $doc->createElement('name');
  $name_text = $doc->createElement('text');
  $name_text->addChild($doc->createTextNode("$word mc"));
  $name->addChild($name_text);
  $quest->addChild($name);

  foreach my $ref (@mc_answers) { 
    my ($ans_text_content, $fraction) = @{ $ref };

    my $answer = $doc->createElement('answer');
    $answer->addChild($doc->createAttribute( fraction => $fraction ));
    my $ans_text = $doc->createElement('text');
    $ans_text->addChild($doc->createTextNode($ans_text_content));
    $answer->addChild($ans_text);

    $quest->addChild($answer);

    foreach my $el_ref (@mc_elements) {
      my ($el_name, $el_txt_content) = @{ $el_ref };
      my $el = $doc->createElement($el_name);
      $el->addChild($doc->createTextNode($el_txt_content));
      $quest->addChild($el);
    }
  }

  $quiz->addChild($quest);

  ### shortanswer

  $quest = $doc->createElement('question');
  $quest->addChild($doc->createAttribute( type => 'shortanswer' ));

  $name = $doc->createElement('name');
  $name_text = $doc->createElement('text');
  $name_text->addChild($doc->createTextNode("$word shortanswer"));
  $name->addChild($name_text);
  $quest->addChild($name);
  
  my $qtext_el = $doc->createElement('questiontext');
  $qtext_el->addChild($doc->createAttribute( format => 'html' ));
  my $qtext_el_text = $doc->createElement('text');
  $qtext_el_text->addChild($doc->createTextNode('Commentaire ou remarque ?'));
  $qtext_el->addChild($qtext_el_text);
  $quest->addChild($qtext_el);

  my $answer = $doc->createElement('answer');
  $answer->addChild($doc->createAttribute( fraction => '100' ));
  my $ans_text = $doc->createElement('text');
  $ans_text->addChild($doc->createTextNode('*'));
  $answer->addChild($ans_text);
  $quest->addChild($answer);
  
  $quiz->addChild($quest);

}

$doc->toFH(\*STDOUT, 1);



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
