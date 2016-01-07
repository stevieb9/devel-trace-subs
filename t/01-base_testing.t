#!perl
use 5.006;
use strict;
use warnings;

use File::Copy;
use Test::More tests => 2;

BEGIN {
    use_ok( 'Devel::Trace::Subs' ) || print "Bail out!\n";
}

use Devel::Trace::Subs qw(trace);

# check/set env

{
    $ENV{DTS_ENABLE} = 1;
    my $pid = $$;
    trace(); # set the pid in env
    my $env_pid = $ENV{DTS_PID} ;

    is ( $pid, $env_pid, "ENV PID is the same as ours" );

    my $file = "DTS_" . join('_', ($$ x 3)) . ".dat";
    copy $file, 't/orig/store.fil';
}

