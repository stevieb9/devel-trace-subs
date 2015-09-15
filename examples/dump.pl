#!/usr/bin/perl
use warnings;
use strict;

use Devel::Trace::Subs qw(install_trace remove_trace trace_dump);

my $remove = $ARGV[0] if $ARGV[0];

if (! $remove){
    install_trace(file => 'Data::Dump');
}
else {
    remove_trace(file => 'Data::Dump');
}

