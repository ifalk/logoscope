#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# db_test.pl                   falk@lormoral
#                    01 Mar 2013

use warnings;
use strict;
use English;

use Data::Dumper;
use Carp;
use Carp::Assert;

use Pod::Usage;
use Getopt::Long;

use utf8;

use DBI;

=head1 NAME

load_db.pl

=head1 USAGE

  perl load_db.pl --db_user database user
                  --db_pw password of that user
                  --db_dir  directory with data files to load into the db tables
                  --basename database name component

=head1 DESCRIPTION

=over 2

=item Creates a database called C<logodb>I<basename>

=item Connects to the database with user and password given as options. 

=item Creates
tables in this database and loads the data given in I<db_dir> options into these tables.

=back

=head1 REQUIRED ARGUMENTS



=head1 OPTIONS

=over 2

=item db_user

User name for the database connection.

=item db_pw

Password of the database user.

=item db_dir

Directory containing (text) data files to be loaded into the database

=item basename

The basename of the (text) files to be loaded into the database. For example the file containing word data will is called F<basename.words>.

=back


=cut

my %opts = (
	    'db_user' => '',
	    'db_pw' => '',
	    'db_dir' => '',
	    'basename' => '',
  );

my @optkeys = (
	       'db_user=s',
	       'db_pw=s',
	       'db_dir=s',
	       'basename=s',
  );

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

my $db_user = $opts{db_user};
my $db_pw = $opts{db_pw};

my $basename = $opts{basename};


my $dbh = DBI->connect(          
  "dbi:mysql:dbname=information_schema", 
  $db_user,
  $db_pw,
  { RaiseError => 1 },         
  ) or die $DBI::errstr;

my $dbname = join('', 'logodb', $opts{basename});

eval { $dbh->do("DROP DATABASE `$dbname`"); };
warn $@ if $@;

$dbh->do("CREATE DATABASE `$dbname` CHARACTER SET utf8 COLLATE utf8_bin");
$dbh->disconnect();

$dbh = DBI->connect(
  "DBI:mysql:dbname=$dbname;mysql_local_infile=1", 
  $db_user,
  $db_pw,
  { RaiseError => 1 },
) or die $DBI::errstr;

$dbh->do("DROP TABLE IF EXISTS Words");
$dbh->do("CREATE TABLE Words(W_id INTEGER PRIMARY KEY, Word VARCHAR(25), Freq INT)");

my $db_dir = $opts{db_dir};
my $basename = $opts{basename};

my $words_file = join('.', $basename, 'words');

my $in_file = join('/', $db_dir, $words_file);
my $nrecords = $dbh->do("LOAD DATA LOCAL INFILE '$in_file' INTO TABLE Words")
    or die $DBI::errstr;

print "Number of records loaded into table Words: $nrecords\n";

my $inv_w = join('.', $basename, 'inv_w');

$in_file = join('/', $db_dir, $inv_w);
$dbh->do("DROP TABLE IF EXISTS Inv_W");
$dbh->do("CREATE TABLE Inv_W(W_id INT, S_id INT, W_pos INT)");
$nrecords = $dbh->do("LOAD DATA LOCAL INFILE '$in_file' INTO TABLE Inv_W")
  or die $DBI::errstr;

print "Number of records loaded into table Inv_W: $nrecords\n";

my $sentences = join('.', $basename, 'sentences');
$in_file = join('/', $db_dir, $sentences);

$dbh->do("DROP TABLE IF EXISTS Sentences");
$dbh->do("CREATE TABLE Sentences(S_id INT PRIMARY KEY, Sentence TEXT)");
$nrecords = $dbh->do("LOAD DATA LOCAL INFILE '$in_file' INTO TABLE Sentences")
  or die $DBI::errstr;

print "Number of records loaded into table Sentences: $nrecords\n";

my $inv_so = join('.', $basename, 'inv_so');
$in_file = join('/', $db_dir, $inv_so);

$dbh->do("DROP TABLE IF EXISTS Inv_so");
$dbh->do("CREATE TABLE Inv_so(Sent_id INT PRIMARY KEY, Source_id INT)");
$nrecords = $dbh->do("LOAD DATA LOCAL INFILE '$in_file' INTO TABLE Inv_so")
  or die $DBI::errstr;

print "Number of records loaded into table Inv_so: $nrecords\n";

my $sources = join('.', $basename, 'sources');
$in_file = join('/', $db_dir, $sources);

$dbh->do("DROP TABLE IF EXISTS Sources");
$dbh->do("CREATE TABLE Sources(Source_id INT PRIMARY KEY, Source TEXT)");
$nrecords = $dbh->do("LOAD DATA LOCAL INFILE '$in_file' INTO TABLE Sources")
  or die $DBI::errstr;

print "Number of records loaded into table Sources: $nrecords\n";

$dbh->disconnect();


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
