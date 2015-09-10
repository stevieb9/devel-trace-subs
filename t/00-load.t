#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Devel::Trace::Flow' ) || print "Bail out!\n";
}

