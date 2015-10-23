#!perl
use 5.006;
use strict;
use warnings;

use File::Copy;

use Test::More tests => 57;

BEGIN {
    use_ok( 'Devel::Trace::Subs' ) || print "Bail out!\n";
}

use Devel::Trace::Subs qw(install_trace);

my $orig = 't/install_trace_orig.pl';
my $work = 't/install_trace.pl';
my $base = 't/orig/install_trace.pl';

copy $orig, $work;

install_trace(file => $work);

open my $work_fh, '<', $work or die $!;
open my $base_fh, '<', $base or die $!;

my @work = <$work_fh>;
my @base = <$base_fh>;

close $work_fh;
close $base_fh;

my $i = -1;

for my $e (@work){
    $i++;
    ok ($e eq $base[$i], "work line $i matches base")
}
