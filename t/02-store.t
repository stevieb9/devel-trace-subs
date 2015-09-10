#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

use Test::More tests => 2;

BEGIN {
    use_ok( 'Devel::Trace::Flow' ) || print "Bail out!\n";
}

use Devel::Trace::Flow qw(trace);

# check/set env

{
    my $store = Devel::Trace::Flow::_store($$);
    print "$store\n";
}

