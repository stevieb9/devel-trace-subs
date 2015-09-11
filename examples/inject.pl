#!/usr/bin/perl
use strict;
use warnings;

use Devel::Trace::Flow qw(inject_trace);

my %params = (
    file => '../devel-examine-subs/lib/Devel/Examine',
);

inject_trace(%params);


