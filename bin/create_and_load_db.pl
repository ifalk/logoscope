#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# create_and_load_db.pl                   falk@lormoral
#                    19 Mar 2013

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

create_and_load_db.pl

=head1 USAGE

   

=head1 DESCRIPTION

Stub documentation for create_and_load_db.pl, 

=head1 REQUIRED ARGUMENTS

=head1 OPTIONS

=cut


my %opts = (
	    'an_option' => 'default value',
	   );

my @optkeys = (
	       'an_option:s',
	      );

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

1;

use DBI;

my $dbname = "logodb2013-03-18";

my $dbh = DBI->connect(          
    "dbi:mysql:dbname=information_schema", 
    "logo",                          
    'scope',                          
    { RaiseError => 1 },         
) or die $DBI::errstr;

my $databases = $dbh->selectcol_arrayref('show databases');

print Dumper($databases);

$dbh->do("DROP DATABASE `$dbname`");

$databases = $dbh->selectcol_arrayref('show databases');
print Dumper($databases);

$dbh->do("CREATE DATABASE `$dbname` CHARACTER SET utf8 COLLATE utf8_bin");

$databases = $dbh->selectcol_arrayref('show databases');

print Dumper($databases);

$dbh->disconnect();


my $dbh = DBI->connect(
  "DBI:mysql:dbname=$dbname;mysql_local_infile=1", 
  "logo",                          
  'scope',                          
  { RaiseError => 1 },
  ) or die $DBI::errstr;

$dbh->do("DROP TABLE IF EXISTS Words");
$dbh->do("CREATE TABLE Words(W_id INTEGER PRIMARY KEY, Word VARCHAR(25), Freq INT)");

my $in_file = '/home/falk/Logoscope/VC/logoscope/logoscope_2/2013-03-18_tinyCC2_results/2013-03-18.words';

my $nrecords = $dbh->do("LOAD DATA LOCAL INFILE '$in_file' INTO TABLE Words")
    or die $DBI::errstr;

print "Number of records loaded into table Words: $nrecords\n";



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
