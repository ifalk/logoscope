#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# get_articles_4_date.pl                   falk@jamballa.loria.fr
#                    10 Feb 2013

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

get_articles_4_date.pl

=head1 USAGE

 perl get_articles_4_date.pl feeds_2013-02-09.pl --source_dir=${TEXT_DIR}

=head1 DESCRIPTION

Gets the text content for the links provided in the file given as argument.
The text content is written to a directory given by the option I<source_dir>.


=head1 REQUIRED ARGUMENTS

A file name of the form I<character string>_YYYY-MM-DD.pl containing links to sites where the content should be retrieved.

The expected format is as follows:

 $VAR1 = {
          'http://www.lefigaro.fr/football-ligue-1-et-2/2013/02/09/02013-20130209ARTSPO00393-ajaccio-bordeaux-en-direct.php' => 1,
          'http://www.lefigaro.fr/mon-figaro/2013/02/09/10001-20130209ARTFIG00427-les-points-cles-de-l-avenir-de-psa.php' => 1,
          'http://www.lequipe.fr/Football/Actualites/La-juve-garde-le-rythme/349163#xtor=RSS-1' => 1,
        ....

If no file name is provided, the script will expect the links in a
file name I<feeds>_$(shell date +"%Y-%m-%d").pl, ie. with the date of
today.

=head1 OPTIONS

=over 2

=item source_dir

Directory where the retrieved content is written to.

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

use DateTime;
use File::Path qw(make_path);

my $file_name;
my $date;
if (@ARGV and $ARGV[0]) {
  $file_name = $ARGV[0];
  ($date,) = ($file_name =~ m{ (\d\d\d\d-\d\d-\d\d) }xms);
} 
else {
  my $today = DateTime->today();

  $file_name = join('_', 'feeds', $today->truncate( to => 'day')); 
  $file_name =~ s{T.*\z}{}xmsg;
  $file_name = $file_name . '.pl';

}

my %feeds = %{ do $file_name };

### check if source directory exists, if not create it.
make_path($opts{source_dir});

use lib "/home/falk/perl5/lib/perl5";
use Mojo::UserAgent;
use LWP::UserAgent;

use Logo::Utils;

my $mojo_ua = Mojo::UserAgent->new();

my $lwp_ua = LWP::UserAgent->new;
$lwp_ua->agent('Mozilla/6.0 (compatible;)');

sub get_lemonde_content {
  my ($link) = @_;
  my $tx = $mojo_ua->get($link);

  my $text = '';
  my $title = '';
  ### title
  my $title_els = $tx->res->dom->find('head > title');
  foreach my $t ($title_els->each()) {
    $title = join('', $title, $t->text());
  }
    
  ### header
  my $article_header = $tx->res->dom('article > h1, article > h2, article > h3');
  my $blog_header = $tx->res->dom('h1.entry-title');
  
  for my $h ($article_header->each(), $blog_header->each()) {
    my $type = $h->type();
    $text = join('', $text, $h->all_text(0), "\n");
  }
  
  my $article_entries = $tx->res->dom->find('div[id="articleBody"] h1, div[id="articleBody"] h2, div[id="articleBody"] h3, div[id="articleBody"] p:not([class="lire"])');
  
  my $blog_entries = $tx->res->dom->find('div.entry-content p');
  
  
  for my $e ($article_entries->each(), $blog_entries->each()) {
    my $new_text = $e->all_text(0);
    next if ($new_text =~ m{ \A \s* \z }xms);
    
    my $type = $e->type();
    $text = join('', $text, $new_text, "\n");
  }

  return ($title, $text);
}

sub get_liberation_content {
  my ($link) = @_;

  my $text = '';
  my $content = $lwp_ua->get($link)->decoded_content;
  my $dom = Mojo::DOM->new($content);
  
  my $title_entries = $dom->find('head > title');
  
  my $title = '';
  foreach my $e ($title_entries->each()) {
    $title = join('', $title, $e->all_text(1));
  }
  
  my $article_headers = $dom->find('div.article h1[itemprop="headline"]');
  
  # print STDERR "Article headers:\n";
  
  foreach my $h ($article_headers->each()) {
    $text = join('', $text, $h->all_text(1), "\n");
    # print $h->all_text(1), "\n";
  }
  
  # Article paragraphs excluding links to further readings
  # print STDERR "Article paragraphs:\n";
  
  my $article_entries = $dom->find('div[itemprop="articleBody"] p:not([class="others"])');
  
  for my $e ($article_entries->each()) {
    my $new_text = $e->all_text(0);
    
    next if ($new_text =~ m{ \A \s* \z }xms);
    
    # print STDERR $new_text, "\n";
    # my $type = $e->type();
    $text = join('', $text, $new_text, "\n");
    
  }
  
  # print STDERR $text, "\n";
  
  return ($title, $text);
}

sub get_lefigaro_content {
  my ($link) = @_;
  
  my $text = '';
  my $title = '';
  my $content = $lwp_ua->get($link)->decoded_content;

  my $dom = Mojo::DOM->new($content);

  my $buyable = $dom->find('div.buyable')->size();

  unless ($buyable == 0) {
    return ('', '');
  }

  ### title
  my $title_el = $dom->find('head title');
  foreach my $t ($title_el->each()) {
    $title = join('', $title, $t->text());
  }

  ### header and paragraphs are intermingled
  my $article_entries = $dom->find('*#article h1, *#article h2, *#article h3, *#article p');


  ### if we found no entries try another selector
  if ($article_entries->size() > 0) {
    for my $h ($article_entries->each()) {

      ### check if entry contains several <br/> indicating
      ### a result table
      my $nbr_br = $h->children('br')->size();
      # print STDERR "Number of br elements: $nbr_br\n";
      next if ($nbr_br > 1);

      $text = join('', $text, $h->all_text(0), "\n");
    }

    return ($title, $text);
  }


  $article_entries = $dom->find('div#Corps h2 > br');

  if ($article_entries->size() > 0) {
    for my $h ($article_entries->each()) {

      ### check if entry contains several <br/> indicating
      ### a result table
      my $nbr_br = $h->children('br')->size();
      # print STDERR "Number of br elements: $nbr_br\n";
      next if ($nbr_br > 1);

      $text = join('', $text, $h->text_before(1), "\n");
    }

    return ($title, $text);
  }
  
  return ($title, $text);

}


sub get_lesecho_content {
  my ($link) = @_;
  # my $tx = $mojo_ua->get($link);

  my $text = '';
  my $title = '';
  my $content = $lwp_ua->get($link)->decoded_content;
  my $dom = Mojo::DOM->new($content);

  ### don't use search results
  if ($dom->find('div.recherche')->size() > 0) {
    return $text;
  }

  ### title
  my $title_els = $dom->find('head > title');
  foreach my $el ($title_els->each()) {
    $title = join('', $title, $el->all_text(1));
  }
    
  ### header
  my $article_header = $dom->find('h1');

  for my $h ($article_header->each()) {
    my $type = $h->type();
    $text = join('', $text, $h->all_text(0), "\n");
  }
  
  my $article_entries = $dom->find('div.texte p');
  
  for my $e ($article_entries->each()) {
    my $new_text = $e->all_text(0);
    next if ($new_text =~ m{ \A \s* \z }xms);
    next if ($new_text =~ m{\A \s* Le \s+ direct \s+ de \s+ la \s+ journ}xmsi);
    next if ($new_text =~ m{\A \s* A \s+ lire \s+ aussi}xmsi);

    my $type = $e->type();
    $text = join('', $text, $new_text, "\n");
  }

  return ($title, $text);
}

sub get_lacroix_content {
  my ($link) = @_;
  # my $tx = $mojo_ua->get($link);

  my $text = '';
  my $title = '';
  my $content = $lwp_ua->get($link)->decoded_content;
  my $dom = Mojo::DOM->new($content);

  ### title
  my $title_els = $dom->find('head title');
  foreach my $el ($title_els->each()) {
    $title = join('', $title, $el->all_text(1));
  }
    
  ### header
  my $article_header = $dom->find('div.title');

  for my $h ($article_header->each()) {
    my $type = $h->type();
    $text = join('', $text, $h->all_text(0), "\n");
  }
  
  my $article_entries = $dom->find('div.block_txt p');
  
  for my $e ($article_entries->each()) {
    my $new_text = $e->all_text(0);

    my $type = $e->type();
    $text = join('', $text, $new_text, "\n");
  }

  return ($title, $text);
}

sub get_lequipe_content {
  my ($link) = @_;
  # my $tx = $mojo_ua->get($link);

  my $text = '';
  my $title = '';
  my $content = $lwp_ua->get($link)->decoded_content;
  my $dom = Mojo::DOM->new($content);


  ### title
  my $title_els = $dom->find('head title');
  foreach my $el ($title_els->each()) {
    $title = join('', $title, $el->all_text(1));
  }
    
  ### header
  my $article_header = $dom->find('article h1');

  for my $h ($article_header->each()) {
    my $type = $h->type();
    $text = join('', $text, $h->all_text(1), "\n");
  }
  
  my $article_entries = $dom->find('div.paragr');
  
  for my $e ($article_entries->each()) {

    ### check if entry contains several <br/> indicating
    ### a result table
    my $nbr_br = $e->find('br')->size();
    next if ($nbr_br > 2);

    my $new_text = $e->all_text(1);
    ### check if text is in fact some javascript
    my @js_matches = ($new_text =~ m{[=&{!+}]}g);
    next if (scalar(@js_matches) > 5);

    my $type = $e->type();
    $text = join('', $text, $new_text, "\n");
  }

  return ($title, $text);
}

my $count = 1;

foreach my $link (keys %feeds) {


  my $out_filename = join('#', $date, $count);



  print "Link: $link\n";

  my $title = '';
  my $text = '';


  #### le monde
  if ($link =~ m{ lemonde }xmsg) {

    ($title, $text) = get_lemonde_content($link);
    $out_filename = join('-', $out_filename, 'lemonde');

  }
  ##### liberation
  elsif ($link =~ m{ liberation }xmsg) {

    ($title, $text) = get_liberation_content($link);
    $out_filename = join('-', $out_filename, 'liberation');
    
  }
  ##### le figaro
  elsif ($link =~ m{ lefigaro }xmsg) {

    ($title, $text) = get_lefigaro_content($link);

    unless ($text) {
      print STDERR "buyable\n";
    }

    $out_filename = join('-', $out_filename, 'lefigaro');
  }
  ##### les echos
  elsif ($link =~ m{ lesechos }xmsg) {

    ($title, $text) = get_lesecho_content($link);

    $out_filename = join('-', $out_filename, 'lesechos');
  }
  ##### la croix
  elsif ($link =~ m{ la-croix }xmsg) {
    ($title, $text) = get_lacroix_content($link);

    $out_filename = join('-', $out_filename, 'lacroix');
  }
  ##### l'equipe
  elsif ($link =~ m{ lequipe }xmsg) {
    ($title, $text) = get_lequipe_content($link);

    $out_filename = join('-', $out_filename, 'lequipe');
  }


  if ($text) {

    $title =~ s{ \| .* \z }{}xmsg;
    $title =~ s{[/|]}{ }xmsg;
    $title =~ s{[,]}{}xmsg;
    $title =~ tr/ÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíîïñòóôõöùúûüýÿ/AAAAAACEEEEIIIINOOOOOUUUUYaaaaaaceeeeiiiinooooouuuuyy/;
    $title =~ s{ \s+ }{_}xmsg;

    $text = Logo::Utils::clean_text($text);

    # $out_filename = join('-', $out_filename, $title);
    $out_filename = join('.', $out_filename, 'txt');

    $out_filename = join('/', $opts{source_dir}, $out_filename);

    print "Output: $out_filename\n";

    if (open my $fh, '>:encoding(utf-8)', $out_filename) {
      print $fh $text, "\n";
      $count++;
    } else {
      warn "Couldn't open $out_filename for writing: $!\n";
    }
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
