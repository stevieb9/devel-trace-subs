package Devel::Trace::Flow;
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use Devel::Trace::Flow::HTML qw(html);
use Devel::Trace::Flow::Text qw(text);
use Exporter;
use Storable;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                    trace
                    trace_dump
                );

our $VERSION = '0.01';

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

    # then from anywhere, dump the output

    trace_dump('stack'); # prints with Dumper the stack trace

    trace_dump('flow'); # prints with Dumper the code flow

=head1 EXPORT

    C<trace, trace_dump>

=head1 FUNCTIONS

=head2 C<trace>

Parameters: None

Puts the call onto the stack trace. Call it in scalar context to retrieve the
data structure as it currently sits.


=head2 C<trace_dump>

Parameters: C<'stack'>, C<'flow'>

If C<stack> is passed in, we'll use C<Data::Dumper> to print out the
stack flow information to C<STDOUT>.

If C<flow> is passed in, we'll print with C<Data::Dumper> the code flow
information.

If no parameters are passed in, we'll dump the entire structure.

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
