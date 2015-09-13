#!/usr/bin/perl
use strict;
use warnings;

use Devel::Trace::Subs qw(install_trace);

my %params = (
    file => '../test/lib/Devel/Examine',
#    file => 'Devel::Examine::Subs',
);

install_trace(%params);


