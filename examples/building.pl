#!/usr/bin/perl
use strict;
use warnings;

use Devel::Trace::Subs qw(trace trace_dump);
use Devel::Examine::Subs;

$ENV{DTS_ENABLE} = 1;

one();
two();

trace_dump(
#    want => 'flow',
#    type => 'html',
#    file => '/home/steve/index.html',
);

sub one {
    trace();
    two();
    print 1;
}

sub two {
    trace();
    my $des = Devel::Examine::Subs->new(file => 'examples/building.pl');
    three();
    print 2;
}

sub three {
    trace();
    print 3;
}


