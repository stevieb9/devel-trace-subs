#!/usr/bin/perl
use warnings;
use strict;

use Devel::Trace::Subs qw(install_trace remove_trace trace_dump);


install_trace(file => 'Data::Dump');

remove_trace(file => 'Data::Dump');

