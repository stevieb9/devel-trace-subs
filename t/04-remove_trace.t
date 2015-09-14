#!perl
use 5.006;
use strict;
use warnings;

use File::Copy;

use Test::More tests => 51;

BEGIN {
    use_ok( 'Devel::Trace::Subs' ) || print "Bail out!\n";
}

use Devel::Trace::Subs qw(remove_trace);

my $work = 't/install_trace.pl';
my $base = 't/orig/remove_trace.pl';

remove_trace(file => $work);

open my $work_fh, '<', $work or die $!;
open my $base_fh, '<', $base or die $!;

my @work = <$work_fh>;
my @base = <$base_fh>;

close $work_fh;
close $base_fh;

while (my ($i, $e) = each @work){
    ok ($e eq $base[$i], "work line $i matches base")
}

eval { unlink $work; };

ok (! $@, "work file $work unlinked successfully");
