#!/usr/bin/env perl
#
# Test script for REG::repeat
#
# Match the list of regular expressions between $min and $max times. If
# $min is not defined, zero is used. If $min is defined and $max is not,
# then $min is the exact number of repeats. If both are not defined, it
# croaks.
#

use strict;
use warnings;

use Test::More;
BEGIN{ use_ok( 'REG' ); }  # test #1: check to see if module can be compiled
my $test_count = 1;        # 1 for the use_ok() in BEGIN

TBD

# tell Test::More we're done
done_testing( $test_count );
