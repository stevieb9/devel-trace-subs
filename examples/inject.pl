#!/usr/bin/perl
use strict;
use warnings;

use Devel::Trace::Subs qw(install_trace);

my %params = (
#    file => '../devel-examine-subs/lib/Devel/Examine',
    file => 'Devel::Examine::Subs',
);

install_trace(%params);


