#!/usr/bin/perl
use warnings;
use strict;

use Devel::Trace::Subs qw(install_trace remove_trace);

my $remove = $ARGV[0] if $ARGV[0];

my $inject = ['trace() if $ENV{DTS_ENABLE} && $ENV{DES_TRACE};'];

if (! $remove){
    install_trace(file => '../devel-examine-subs/lib/Devel/Examine', extensions => ['pm'], inject => $inject);
}
else {
    remove_trace(file => 'devel-examine-subs/lib/Devel/Examine');
}
