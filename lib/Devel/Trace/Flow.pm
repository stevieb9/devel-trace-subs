package Devel::Trace::Flow;
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use Devel::Examine::Subs;
use Devel::Trace::Flow::HTML qw(html);
use Devel::Trace::Flow::Text qw(text);
use Exporter;
use Storable;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                    trace
                    trace_dump
                    inject_trace
                );

our $VERSION = '0.02';

$SIG{INT} = sub { 'this ensures END runs if ^C is pressed'; };

sub trace {

    _env();

    my $data = _store();

    my $flow_count = ++$ENV{DTF_FLOW_COUNT};

    push @{$data->{flow}}, {
                            name => $flow_count,
                            value => (caller(1))[3] || 'main()'
                        };

    push @{$data->{stack}}, {
        in       => (caller(1))[3] || '-',
        package  => (caller(1))[0] || '-',
        sub      => (caller(2))[3] || '-',
        filename => (caller(1))[1] || '-',
        line     => (caller(1))[2] || '-',
    };

    _store($data);

    if (defined wantarray){
        return $data;
    }
}
sub trace_dump {

    if (! $ENV{DTF_PID}){
        die "Can't call trace_dump() without calling trace()\n";
    }

    my %p = @_;

    my $want = $p{want};
    my $out_type = $p{type};
    my $file = $p{file};

    my $data = _store();

    if ($want && $want eq 'stack'){
        if ($out_type eq 'html') {
            html(
                file => $file,
                want => $want,
                data => $data->{stack}
            );
        }
        else {
            text(
                want => 'stack',
                data => $data->{stack},
                file => $file
            );
        }
    }
    if ($want && $want eq 'flow'){
        if ($out_type eq 'html') {
            html(
                file => $file,
                want => $want,
                data => $data->{flow}
            );
        }
        else {
            text(
                want => 'flow',
                data => $data->{flow},
                file => $file
            );
        }
    }
    if (! $want){
        if ($out_type eq 'html') {
            html(
                file => $file,
                data => $data
            );
        }
        else {
            text(
                data => {
                    flow => $data->{flow},
                    stack => $data->{stack}
                },
                file => $file
            );
        }
    }
}
sub inject_trace {

    my %p = @_;

    my $file = $p{file};
    my $copy = $p{copy};
    my $include = $p{include};
    my $exclude = $p{exclude};

    my $des = Devel::Examine::Subs->new(
                                        file => $file,
                                        copy => $copy,
                                        include => $include,
                                        exclude => $exclude,
                                        no_indent => 1,
                                    );

    $des->inject_after(
        search => qr/sub\s+\w+\s+(?:\(.*?\)\s+)?\{/,
        code => ["\ttrace();\n"],
    );

}
sub _env {

    my $pid = $$;
    $ENV{DTF_PID} = $pid;

    return $pid;
}

sub _store {

    my $data = shift;

    my $pid = $ENV{DTF_PID};
    my $store = "DTF_" . join('_', ($pid x 3)) . ".dat";

    $ENV{DTF_STORE} = $store;

    my $struct;

    if (-f $store){
        $struct = retrieve($store);
    }
    else {
        $struct = {};
    }

    return $struct if ! $data;

    store($data, $store);

}

END {
    unlink $ENV{DTF_STORE} if $ENV{DTF_STORE};
}

__END__

=head1 NAME

Devel::Trace::Flow - Generate, track, store and print code flow and stack
traces.


=head1 SYNOPSIS

    use Devel::Trace::Flow qw(trace trace_dump);

    # add a trace() call to the top of all your subs

    trace();

    # then from anywhere (typically calling script), dump the output

    trace_dump();

=head1 DESCRIPTION

This module facilitates keeping track of a project's code flow and stack
trace information in calls between subroutines.

Optionally, you can use this module to automatically inject the appropriate
C<trace()> calls into some or all subs in individual files, all Perl files
within a directory structure, or even in production files by specifying its
C<Module::Name>.

=head1 EXPORT

    C<trace, trace_dump>

=head1 FUNCTIONS

=head2 C<trace>

Parameters: None

Puts the call onto the stack trace. Call it in scalar context to retrieve the
data structure as it currently sits.


=head2 C<trace_dump>

Dumps the output of the collected data.

All of the following parameters are optional.

C<want =E<gt> 'string'>, C<type =E<gt> 'html'>,
C<file =E<gt> 'file.ext'>

C<want>: Takes either C<'flow'> or C<'stack'>, and will output the respective
data collection. If this parameter is omitted, both code flow and stack trace
information is dumped.

C<type>: Has only a single value, C<'html>. This will dump the output in HTML
format.

C<file>: Takes the name of a file as a parameter. The dump will write output
to the file specified. The program will C<die> if the file can not be opened
for writing.

=head2 C<inject_trace>

Automatically injects the necessary code into Perl files to facilitate stack
tracing.

Parameters:

C<file =E<gt> 'filename'> - Mandatory: 'filename' can be the name of a single
file, a directory, or even a 'Module::Name'. If the filename is a directory,
we'll iterate recursively through the directory, and make the changes to all
C<.pl> and C<.pm> files underneath of it. If filename is a 'Module::Name',
we'll load the file for that module dynamically, and modify it. CAUTION: this
will edit live production files.

C<copy =E<gt> 'filename'> - Optional: The name of a backup file. We'll copy
the file in C<file> parameter and copy it to the file name specified, and
only work on the copied version, leaving the original file alone.

C<include =E<gt> [qw(sub1 sub2)]> - Optional: An array reference with the
names of subroutines you want to include. If C<include> is sent in, only
these subs will be modified, ie. all others will be excluded by default.

C<exclude> =E<gt> [qw(sub1 sub2)]> - Optional: This has the exact opposite
effect as C<include>. Note that if C<exclude> is sent in, C<include> is
rendered useless.


=cut

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-devel-trace-flow at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Devel-Trace-Flow>.  I will
be notified, and then you'll automatically be notified of progress on your
bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Devel::Trace::Flow


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Devel-Trace-Flow>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Devel-Trace-Flow>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Devel-Trace-Flow>

=item * Search CPAN

L<http://search.cpan.org/dist/Devel-Trace-Flow/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1; # End of Devel::Trace::Flow
