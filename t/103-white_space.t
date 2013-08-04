#!/usr/bin/env perl
#
# Test script for REG::white_space
#
# Match Perl's white space
#

use strict;
use warnings;

use Test::More;
BEGIN{ use_ok( 'REG' ); }  # test #1: check to see if module can be compiled
my $test_count = 1;        # 1 for the use_ok() in BEGIN

TBD

# tell Test::More we're done
done_testing( $test_count );
