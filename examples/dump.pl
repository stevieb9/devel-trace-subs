#!/usr/bin/perl
use warnings;
use strict;

use Devel::Trace::Subs qw(install_trace remove_trace trace_dump);
use Data::Dump;

$ENV{DTS_ENABLE} = 1;

my $href = {a => 1, b => 2};

install_trace(file => 'Data::Dump');
use Data::Dump;

dd $href;

trace_dump();

remove_trace(file => 'Data::Dump');

