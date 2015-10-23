#!perl
use 5.006;
use strict;
use warnings;

use File::Copy;

use Test::More tests => 152;

BEGIN {
    use_ok( 'Devel::Trace::Subs' ) || print "Bail out!\n";
}

use Devel::Trace::Subs qw(remove_trace);

my $default = 't/install_trace.pl';
my $pl = 't/ext/install_trace.pl';
my $pm = 't/ext/install_trace.pm';
my $base = 't/orig/remove_trace.pl';
my $dir = 't/ext';

{
    remove_trace(file => $default);

    open my $work_fh, '<', $default or die $!;
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
}
{
    remove_trace(file => $dir);

    open my $pl_fh, '<', $pl or die $!;
    open my $pm_fh, '<', $pm or die $!;
    open my $base_fh, '<', $base or die $!;

    my @pl = <$pl_fh>;
    my @pm = <$pm_fh>;
    my @base = <$base_fh>;

    close $pl_fh;
    close $pm_fh;

    my $i = -1;

    for my $e (@base){
        $i++;
        ok ($e eq $pl[$i], "base line $i matches *.pl");
        ok ($e eq $pm[$i], "base line $i matches *.pm");
    }
}

for ($default, $pl, $pm){
    eval { unlink $_; };
    ok (! $@, "$_ test file unlinked successfully");
}

eval { rmdir 't/ext' or die "can't remove t/ext test dir!: $!"; };
is ($@, '', "successfully rmdir t/ext test dir");

