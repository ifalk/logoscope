package Logo::Utils;

use 5.006;
use strict;
use warnings;

use lib "/home/falk/perl5/lib/perl5";
use Mojo::UserAgent;
use LWP::UserAgent;

=head1 NAME

Logo::Utils - The great new Logo::Utils!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Logo::Utils;

    my $foo = Logo::Utils->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 clean_text

=cut

sub clean_text {
  my ($text) = @_;

  $text =~ s{ \x{A0} }{ }xmsg; 
  $text =~ s/[’\222]‘/'/g;
  $text =~ s/\.+/./g;
  $text =~ s/…/./g;
  $text =~ s/,([^\s])/, $1/g;

  return $text;
}

=head2 is_email_address

=cut

sub is_email_address {
  my ($string) = @_;

  return Email::Valid->address($string);
}

=head1 AUTHOR

Ingrid Falk, C<< <ifalk at unistra.fr> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-logo-utils at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Logo-Utils>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Logo::Utils


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Logo-Utils>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Logo-Utils>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Logo-Utils>

=item * Search CPAN

L<http://search.cpan.org/dist/Logo-Utils/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Ingrid Falk.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Logo::Utils
