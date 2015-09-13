#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

use Test::More tests => 1;

BEGIN {
    use_ok( 'Devel::Trace::Subs' ) || print "Bail out!\n";
}

use Devel::Trace::Subs qw(trace);

# check/set env

{
    my $store = Devel::Trace::Subs::_store({}, $$);
    print "$store\n";
}

