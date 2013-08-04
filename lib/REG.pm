#!/
# --------------------------------------
#
#   Title: Regular Expression Generator
# Purpose: Create regular expressions by calling a chain of building blocks.
#
#    Name: REG
#    File: REG.pm
# Created: July 29, 2013
#
# Copyright: Copyright 2013 by Shawn H Corey.  All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

# --------------------------------------
# Package
package REG;
{

# --------------------------------------
# Pragmatics

use 5.8.0;

use strict;
use warnings;

# UTF-8 for everything
use warnings   qw( FATAL utf8 );
use utf8;
use open       qw( :encoding(UTF-8) :std );
use charnames  qw( :full :short );
binmode(DATA, ":encoding(UTF-8)");

# --------------------------------------
# Version
our $VERSION = v0.1.0;

# --------------------------------------
# Modules

# Standard modules
use Carp;
use English      qw( -no_match_vars );  # Avoids regex performance penalty
use Scalar::Util qw( blessed reftype );

# --------------------------------------
# Configuration Parameters

my %error_message = (
  not_regexp       => "an argument that is not a REGEXP was found",
  not_scalar       => "an argument that is not a SCALAR was found",
  none_required    => "arguments found where none are required",
  invalid_number   => "invalid number of arguments",
  invalid_repeat_2 => "invalid repeat( %s, %s, ... )",
  no_args_found    => "no arguments found",
);

# conditional compile DEBUGging statements
# See http://lookatperl.blogspot.ca/2013/07/a-look-at-conditional-compiling-of.html
use constant DEBUG => $ENV{DEBUG};

# --------------------------------------
# Variables

# --------------------------------------
# Subroutines

# --------------------------------------
#       Name: _parse_arg0
#      Usage: ( $class, $reg ) = _parse_arg0( $arg0 );
#    Purpose: Extract the class and regular expression from the first argument.
# Parameters:  $arg0 -- is a blessed object or a class
#    Returns: $class -- the class
#               $reg -- regular expression object
#
my $_parse_arg0 = sub {
  my $reg   = shift @_;
  my $class = $reg;

  if( my $blessed = blessed $reg ){
    $class = $blessed;
  }else{
    $reg = '';
  }

  return ( $class, $reg );
};

# --------------------------------------
#       Name: join
#      Usage: $reg = $reg->join( @res );
#             $reg =  REG->join( @res );
#    Purpose: Join a list of regular expressions to this one.
# Parameters: @res -- list of regular expressions
#    Returns: $reg -- regular expression generator object
#
sub join {
  my ( $class, $reg ) = $_parse_arg0->( shift @_ );

  if( ! @_ ){
    croak $error_message{no_args_found};
  }

  for ( @_ ){
    if( reftype( $_ ) ne 'REGEXP' ){
      croak $error_message{not_regexp};
    }
  }

  return bless qr{$reg@_}ms, $class;
}

# --------------------------------------
#       Name: literal
#      Usage: $reg = $reg->literal( @strings );
#             $reg =  REG->literal( @strings );
#    Purpose: Match literal strings.
# Parameters: @strings -- list of strings
#    Returns:     $reg -- regular expression generator object
#
sub literal {
  my ( $class, $reg ) = $_parse_arg0->( shift @_ );

  if( ! @_ ){
    croak $error_message{no_args_found};
  }

  for ( @_ ){
    if( ref( $_ ) ){
      croak $error_message{not_scalar};
    }
  }

  return bless qr{$reg\Q@_\E}ms, $class;
}

# --------------------------------------
#       Name: ignore_case
#      Usage: $reg = $reg->ignore_case( @strings );
#             $reg =  REG->ignore_case( @strings );
#    Purpose: Match the strings but ignore their case.
# Parameters: @strings -- list of strings
#    Returns:     $reg -- regular expression generator object
#
sub ignore_case {
  my ( $class, $reg ) = $_parse_arg0->( shift @_ );

  if( ! @_ ){
    croak $error_message{no_args_found};
  }

  for ( @_ ){
    if( ref( $_ ) ){
      croak $error_message{not_scalar};
    }
  }

  return bless qr{$reg\Q@_\E}ims, $class;
}

# --------------------------------------
#       Name: white_space
#      Usage: $reg = $reg->white_space();
#             $reg =  REG->white_space();
#    Purpose: Match Perl's white space
# Parameters: (none)
#    Returns: $reg -- regular expression generator object
#
sub white_space {
  my ( $class, $reg ) = $_parse_arg0->( shift @_ );

  if( @_ ){
    croak $error_message{none_required};
  }

  return bless qr{$reg\s+}ms, $class;
}

# --------------------------------------
#       Name: optional_space
#      Usage: $reg = $reg->optional_space();
#             $reg =  REG->optional_space();
#    Purpose: Match optional Perl white space
# Parameters: (none)
#    Returns: $reg -- regular expression generator object
#
sub optional_space {
  my ( $class, $reg ) = $_parse_arg0->( shift @_ );

  if( @_ ){
    croak $error_message{none_required};
  }

  return bless qr{$reg\s*}ms, $class;
}

# --------------------------------------
#       Name: none_or_once
#      Usage: $reg = $reg->none_or_once( @res );
#             $reg =  REG->none_or_once( @res );
#    Purpose: Match the list of regular expressions none or once.
# Parameters: @res -- list of regular expressions
#    Returns: $reg -- regular expression generator object
#
sub none_or_once {
  my ( $class, $reg ) = $_parse_arg0->( shift @_ );

  if( ! @_ ){
    croak $error_message{no_args_found};
  }

  for ( @_ ){
    if( reftype( $_ ) ne 'REGEXP' ){
      croak $error_message{not_regexp};
    }
  }

  return bless qr{$reg(?:@_)?}ms, $class;
}

# --------------------------------------
#       Name: none_or_most
#      Usage: $reg = $reg->none_or_most( @res );
#             $reg =  REG->none_or_most( @res );
#    Purpose: Match the list of regular expressions none or as many as possible.
# Parameters: @res -- list of regular expressions
#    Returns: $reg -- regular expression generator object
#
sub none_or_most {
  my ( $class, $reg ) = $_parse_arg0->( shift @_ );

  if( ! @_ ){
    croak $error_message{no_args_found};
  }

  for ( @_ ){
    if( reftype( $_ ) ne 'REGEXP' ){
      croak $error_message{not_regexp};
    }
  }

  return bless qr{$reg(?:@_)*}ms, $class;
}

# --------------------------------------
#       Name: once_or_most
#      Usage: $reg = $reg->once_or_most( @res );
#             $reg =  REG->once_or_most( @res );
#    Purpose: Match the list of regular expressions once or as many as possible.
# Parameters: @res -- list of regular expressions
#    Returns: $reg -- regular expression generator object
#
sub once_or_most {
  my ( $class, $reg ) = $_parse_arg0->( shift @_ );

  if( ! @_ ){
    croak $error_message{no_args_found};
  }

  for ( @_ ){
    if( reftype( $_ ) ne 'REGEXP' ){
      croak $error_message{not_regexp};
    }
  }

  return bless qr{$reg(?:@_)+}ms, $class;
}

# --------------------------------------
#       Name: none_or_least
#      Usage: $reg = $reg->none_or_least( @res );
#             $reg =  REG->none_or_least( @res );
#    Purpose: Match the list of regular expressions none or as few times as possible.
# Parameters: @res -- list of regular expressions
#    Returns: $reg -- regular expression generator object
#
sub none_or_least {
  my ( $class, $reg ) = $_parse_arg0->( shift @_ );

  if( ! @_ ){
    croak $error_message{no_args_found};
  }

  for ( @_ ){
    if( reftype( $_ ) ne 'REGEXP' ){
      croak $error_message{not_regexp};
    }
  }

  return bless qr{$reg(?:@_)*?}ms, $class;
}

# --------------------------------------
#       Name: once_or_least
#      Usage: $reg = $reg->once_or_least( @res );
#             $reg =  REG->once_or_least( @res );
#    Purpose: Match the list of regular expressions none or as few times as possible.
# Parameters: @res -- list of regular expressions
#    Returns: $reg -- regular expression generator object
#
sub once_or_least {
  my ( $class, $reg ) = $_parse_arg0->( shift @_ );

  if( ! @_ ){
    croak $error_message{no_args_found};
  }

  for ( @_ ){
    if( reftype( $_ ) ne 'REGEXP' ){
      croak $error_message{not_regexp};
    }
  }

  return bless qr{$reg(?:@_)+?}ms, $class;
}

# --------------------------------------
#       Name: repeat
#      Usage: $reg = $reg->repeat( $min,  $max,  @res );
#             $reg =  REG->repeat( $min,  $max,  @res );
#             $reg = $reg->repeat( $min,  undef, @res );
#             $reg = $reg->repeat( undef, $max,  @res );
#    Purpose: Match the list of regular expressions between $min and $max times.
#             If $min is not defined, zero is used.
#             If $min is defined and $max is not, then $min is the exact number of repeats.
#             If both are not defined, it croaks.
# Parameters: @res -- list of regular expressions
#    Returns: $reg -- regular expression generator object
#
sub repeat {
  my ( $class, $reg ) = $_parse_arg0->( shift @_ );
  my $min = shift @_ || 0;
  my $max = shift @_;

  if( ! @_ ){
    croak $error_message{no_args_found};
  }

  for ( @_ ){
    if( reftype( $_ ) ne 'REGEXP' ){
      croak $error_message{not_regexp};
    }
  }

  if( ! defined $max ){

    if( $min <= 1 ){
      croak sprintf( $error_message{invalid_repeat_2}, $min, $max );
    }
    return bless qr[$reg(?:@_){$min,}]ms, $class;

  }elsif( $max == $min ){

    if( $min <= 1 ){
      croak sprintf( $error_message{invalid_repeat_2}, $min, $max );
    }
    return bless qr[$reg(?:@_){$min}]ms, $class;

  }elsif( $max < $min ){
      croak sprintf( $error_message{invalid_repeat_2}, $min, $max );

  }

  return bless qr[$reg(?:@_){$min,$max}]ms, $class;
}

# --------------------------------------
#       Name: capture
#      Usage: $reg = $reg->capture( @res );
#             $reg =  REG->capture( @res );
#    Purpose: Capture the list of regular expressions.
# Parameters: @res -- list of regular expressions
#    Returns: $reg -- regular expression generator object
#
sub capture {
  my ( $class, $reg ) = $_parse_arg0->( shift @_ );

  if( ! @_ ){
    croak $error_message{no_args_found};
  }

  for ( @_ ){
    if( reftype( $_ ) ne 'REGEXP' ){
      croak $error_message{not_regexp};
    }
  }

  return bless qr{$reg(@_)}ms, $class;
}

# --------------------------------------
#       Name: charset
#      Usage: $reg = $reg->charset( $charset );
#             $reg =  REG->charset( $charset );
#    Purpose: Add a character set to the regular expression
# Parameters: $charset -- as defined in `perldoc pelre`
#    Returns: $reg -- regular expression generator object
#
sub charset {
  my ( $class, $reg ) = $_parse_arg0->( shift @_ );

  if( @_ != 1 ){
    croak $error_message{invalid_numder};
  }

  my $charset = shift @_;

  if( ref( $charset )){
    croak $error_message{not_scalar};
  }

  return bless qr{[$_[0]]}ms, $class;
}

# --------------------------------------
#       Name: string_begin
#      Usage: $reg = $reg->string_begin();
#             $reg =  REG->string_begin();
#    Purpose: Match Perl's white space
# Parameters: (none)
#    Returns: $reg -- regular expression generator object
#
sub string_begin {
  my ( $class, $reg ) = $_parse_arg0->( shift @_ );

  if( @_ ){
    croak $error_message{none_required};
  }

  return bless qr{\A}ms, $class;
}

# --------------------------------------
#       Name: string_end
#      Usage: $reg = $reg->string_end();
#             $reg =  REG->string_end();
#    Purpose: Match Perl's white space
# Parameters: (none)
#    Returns: $reg -- regular expression generator object
#
sub string_end {
  my ( $class, $reg ) = $_parse_arg0->( shift @_ );

  if( @_ ){
    croak $error_message{none_required};
  }

  return bless qr{$reg\z}ms, $class;
}

# --------------------------------------
#       Name: line_begin
#      Usage: $reg = $reg->line_begin();
#             $reg =  REG->line_begin();
#    Purpose: Match Perl's white space
# Parameters: (none)
#    Returns: $reg -- regular expression generator object
#
sub line_begin {
  my ( $class, $reg ) = $_parse_arg0->( shift @_ );

  if( @_ ){
    croak $error_message{none_required};
  }

  return bless qr{$reg^}ms, $class;
}

# --------------------------------------
#       Name: line_end
#      Usage: $reg = $reg->line_end();
#             $reg =  REG->line_end();
#    Purpose: Match Perl's white space
# Parameters: (none)
#    Returns: $reg -- regular expression generator object
#
sub line_end {
  my ( $class, $reg ) = $_parse_arg0->( shift @_ );

  if( @_ ){
    croak $error_message{none_required};
  }

  return bless qr{$reg$}ms, $class;
}


}1;
__DATA__
__END__

=head1 NAME

REG - Create regular expressions by calling a chain of building blocks.

=head1 VERSION

This document refers to REG version v0.1.0

=head1 SYNOPSIS

  use REG;

  my $re_test = REG->string_begin()
                   ->optional_space()
                   ->ignore_case( 'test' )
                   ->optional_space()
                   ->string_end();

=head1 DESCRIPTION

TBD

=head1 REQUIREMENTS

(none)

=head1 METHODS

=head2 join

I<Usage:>

    $reg = $reg->join( @res );
    $reg =  REG->join( @res );

I<Parameters>

=over

=item @res

list of regular expressions

=back

I<Returns>

=over

=item $reg

regular expression generator object

=back

TBD Join a list of regular expressions to this one.

=head2 literal

I<Usage:>

    $reg = $reg->literal( @strings );
    $reg =  REG->literal( @strings );

I<Parameters>

=over

=item @strings

list of strings

=back

I<Returns>

=over

=item $reg

regular expression generator object

=back

TBD Match literal strings.

=head2 ignore_case

I<Usage:>

    $reg = $reg->ignore_case( @strings );
    $reg =  REG->ignore_case( @strings );

I<Parameters>

=over

=item @strings

list of strings

=back

I<Returns>

=over

=item $reg

regular expression generator object

=back

TBD Match the strings but ignore their case.

=head2 white_space

I<Usage:>

    $reg = $reg->white_space();
    $reg =  REG->white_space();

I<Parameters>

=over

=item (none)

=back

I<Returns>

=over

=item $reg

regular expression generator object

=back

TBD Match Perl's white space

=head2 optional_space

I<Usage:>

    $reg = $reg->optional_space();
    $reg =  REG->optional_space();

I<Parameters>

=over

=item (none)

=back

I<Returns>

=over

=item $reg

regular expression generator object

=back

TBD Match optional Perl white space

=head2 none_or_once

I<Usage:>

    $reg = $reg->none_or_once( @res );
    $reg =  REG->none_or_once( @res );

I<Parameters>

=over

=item @res

list of regular expressions

=back

I<Returns>

=over

=item $reg

regular expression generator object

=back

TBD Match the list of regular expressions none or once.

=head2 none_or_most

I<Usage:>

    $reg = $reg->none_or_most( @res );
    $reg =  REG->none_or_most( @res );

I<Parameters>

=over

=item @res

list of regular expressions

=back

I<Returns>

=over

=item $reg

regular expression generator object

=back

TBD Match the list of regular expressions none or as many as possible.

=head2 once_or_most

I<Usage:>

    $reg = $reg->once_or_most( @res );
    $reg =  REG->once_or_most( @res );

I<Parameters>

=over

=item @res

list of regular expressions

=back

I<Returns>

=over

=item $reg

regular expression generator object

=back

TBD Match the list of regular expressions once or as many as possible.

=head2 none_or_least

I<Usage:>

    $reg = $reg->none_or_least( @res );
    $reg =  REG->none_or_least( @res );

I<Parameters>

=over

=item @res

list of regular expressions

=back

I<Returns>

=over

=item $reg

regular expression generator object

=back

TBD Match the list of regular expressions none or as few times as possible.

=head2 once_or_least

I<Usage:>

    $reg = $reg->once_or_least( @res );
    $reg =  REG->once_or_least( @res );

I<Parameters>

=over

=item @res

list of regular expressions

=back

I<Returns>

=over

=item $reg

regular expression generator object



=back

TBD Match the list of regular expressions none or as few times as possible.

=head2 repeat

I<Usage:>

    $reg = $reg->repeat( $min,  $max,  @res );
    $reg =  REG->repeat( $min,  $max,  @res );
    $reg = $reg->repeat( $min,  undef, @res );
    $reg = $reg->repeat( undef, $max,  @res );

I<Parameters>

=over

=item @res

list of regular expressions

=back

I<Returns>

=over

=item $reg

regular expression generator object

=back

TBD Match the list of regular expressions between $min and $max times. If $min is not defined, zero is used. If $min is defined and $max is not, then $min is the exact number of repeats. If both are not defined, it croaks.

=head2 capture

I<Usage:>

    $reg = $reg->capture( @res );
    $reg =  REG->capture( @res );

I<Parameters>

=over

=item @res

list of regular expressions

=back

I<Returns>

=over

=item $reg

regular expression generator object

=back

TBD Capture the list of regular expressions.

=head2 charset

I<Usage:>

    $reg = $reg->charset( $charset );
    $reg =  REG->charset( $charset );

I<Parameters>

=over

=item $charset

as defined in `perldoc pelre`

=back

I<Returns>

=over

=item $reg

regular expression generator object

=back

TBD Add a character set to the regular expression

=head2 string_begin

I<Usage:>

    $reg = $reg->string_begin();
    $reg =  REG->string_begin();

I<Parameters>

=over

=item (none)

=back

I<Returns>

=over

=item $reg

regular expression generator object

=back

TBD Match Perl's white space

=head2 string_end

I<Usage:>

    $reg = $reg->string_end();
    $reg =  REG->string_end();

I<Parameters>

=over

=item (none)

=back

I<Returns>

=over

=item $reg

regular expression generator object

=back

TBD Match Perl's white space

=head2 line_begin

I<Usage:>

    $reg = $reg->line_begin();
    $reg =  REG->line_begin();

I<Parameters>

=over

=item (none)

=back

I<Returns>

=over

=item $reg

regular expression generator object

=back

TBD Match Perl's white space

=head2 line_end

I<Usage:>

    $reg = $reg->line_end();
    $reg =  REG->line_end();

I<Parameters>

=over

=item (none)

=back

I<Returns>

=over

=item $reg

regular expression generator object

=back

TBD Match Perl's white space

TBD

=head1 DIAGNOSTICS

(none)

=head1 CONFIGURATION AND ENVIRONMENT

(none)

=head1 INCOMPATIBILITIES

(none)

=head1 BUGS AND LIMITATIONS

(none known)

Please report any bugs or feature requests to
C<bug-REG at rt.cpan.org>, or through the web
interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=REG>.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc REG

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=REG>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/REG>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/REG>

=item * Search CPAN

L<http://search.cpan.org/dist/REG>

=back

=head1 SEE ALSO

(none)

=head1 ORIGINAL AUTHOR

Shawn H Corey  C<< <SHCOREY at cpan dot org> >>

=head2 Contributing Authors

(Insert your name here if you modified this program or its documentation.
 Do not remove this comment.)

=head1 ACKNOWLEDGEMENTS

(none)

=head1 COPYRIGHT & LICENCES

Copyright 2013 by Shawn H Corey.  All rights reserved.

=head2 Software Licence

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

=head2 Document Licence

Permission is granted to copy, distribute and/or modify this document under the
terms of the GNU Free Documentation License, Version 1.2 or any later version
published by the Free Software Foundation; with the Invariant Sections being
ORIGINAL AUTHOR, COPYRIGHT & LICENCES, Software Licence, and Document Licence.

You should have received a copy of the GNU Free Documentation Licence
along with this document; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

=cut
