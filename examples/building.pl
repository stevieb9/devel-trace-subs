#!/usr/bin/perl
use strict;
use warnings;

use Devel::Trace::Flow qw(trace trace_dump);
use Devel::Examine::Subs;

one();
two();

trace_dump(
#    want => 'flow',
    type => 'html',
    file => '/home/steve02/Desktop/index.html',
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


