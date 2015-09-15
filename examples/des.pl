#!/usr/bin/perl
use warnings;
use strict;

use Devel::Examine::Subs;
use Devel::Trace::Subs qw(trace_dump);

$ENV{DTS_ENABLE} = 1;
$ENV{DES_TRACE} = 1;

my $des = Devel::Examine::Subs->new(file => 't/sample.pl');

$des->all;

trace_dump();
