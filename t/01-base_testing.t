#!perl
use 5.006;
use strict;
use warnings;

use File::Copy;
use Mock::Sub;
use Test::More tests => 10;

BEGIN {
    use_ok( 'Devel::Trace::Subs' ) || print "Bail out!\n";
}

use Devel::Trace::Subs qw(trace trace_dump);

# check/set env

{
    my $ret = trace();
    is ($ret, undef, "trace() returns if DTS_ENABLE isnt set");
}
{
    $ENV{DTS_ENABLE} = 1;
    my $pid = $$;
    trace(); # set the pid in env
    my $env_pid = $ENV{DTS_PID} ;

    is ( $pid, $env_pid, "ENV PID is the same as ours" );

    my $file = "DTS_" . join('_', ($$ x 3)) . ".dat";
    copy $file, 't/orig/store.fil';
}
{
    local $SIG{__WARN__} = sub { };

    $ENV{DTS_ENABLE} = 1;

    my $mock = Mock::Sub->new;
    my $caller = $mock->mock('CORE::caller');
    $caller->return_value(undef);

    trace();

    trace_dump(file => 't/orig/dump.txt');

    open my $fh, '<', 't/orig/dump.txt' or die $!;

    my @lines = <$fh>;

    like ($lines[8], qr/\s+in:\s+-/, "ok");
    like ($lines[9], qr/\s+sub:\s+-/, "ok");
    like ($lines[10], qr/\s+file:\s+-/, "ok");

    close $fh;
    eval { unlink 't/orig/dump.txt' or die $!; };
    is ($@, '', "unlinked temp file ok" );
}
{
    $ENV{DTS_ENABLE} = 1;
    $ENV{DTS_FLUSH_FLOW} = 1;

    my $new_std;
    open my $stdout, '>', \$new_std or die $!;
    my $old_std = select $stdout;

    trace();

    close $stdout;
    select $old_std;

    like ($new_std, qr/main()/, "DTS_FLUSH_FLOW env works");
}
{
    $ENV{DTS_ENABLE} = 1;

    my $data = trace();

    is (ref $data, 'HASH', 'asking for a return in trace() does the right thing');
}
{
    undef $ENV{DTS_PID};
    eval { trace_dump(); };
    like ($@, qr/call trace_dump\(\) without calling trace/, "trace_dump() barfs properly if trace isn't called first");
}
