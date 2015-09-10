package Devel::Trace::Flow;
use 5.006;
use strict;
use warnings;
#use diagnostics;

use Data::Dumper;
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

    push @{$data->{flow}}, (caller(1))[3];

    push @{$data->{stack}}, {
        called   => (caller(1))[3] || '-',
        package  => (caller(1))[0] || '-',
        sub      => (caller(2))[3] || '-',
        filename => (caller(1))[1],
        line     => (caller(1))[2],
    };

    _store($data);
}
sub trace_dump {

    if (! $ENV{DTF_PID}){
        die "Can't call trace_dump() without calling trace()\n";
    }

    my $want = shift;

    my $data = _store();

    if ($want eq 'stack'){
        print Dumper $data->{stack};
    }
    if ($want eq 'flow'){
        print Dumper $data->{flow};
    }
    if (! $want){
        print Dumper $data;
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

    # append $data here to $struct

    store($data, $store);

}

END {
    unlink $ENV{DTF_STORE} if $ENV{DTF_STORE};
}

__END__

=head1 NAME

Devel::Trace::Flow - Generate, track, store and print code flow and stack
traces


=head1 SYNOPSIS


    use Devel::Trace::Flow;

    ...

=head1 EXPORT

=head1 FUNCTIONS

=head2 function1

=cut

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-devel-trace-flow at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Devel-Trace-Flow>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


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
