#!/usr/bin/perl
use strict;
use warnings;

use Devel::Trace::Flow qw(inject_trace);

my %params = (
    file => 't/sample.pl',
    copy => 't/sample_copy.pl',
);

inject_trace(%params);


