package Devel::Trace::Subs;
use 5.006;
use strict;
use warnings;

use Data::Dumper;
use Devel::Examine::Subs;
use Devel::Trace::Subs::HTML qw(html);
use Devel::Trace::Subs::Text qw(text);
use Exporter;
use Storable;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                    trace
                    trace_dump
                    install_trace
                    remove_trace
                );

our $VERSION = '0.08';

$SIG{INT} = sub { 'this ensures END runs if ^C is pressed'; };

sub trace {

    return unless $ENV{DTS_ENABLE};

    _env();

    my $data = _store();

    my $flow_count = ++$ENV{DTS_FLOW_COUNT};

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

    if (! $ENV{DTS_PID}){
        die "\nCan't call trace_dump() without calling trace()\n\n" .
            'Make sure to set $ENV{DTS_ENABLE} = 1;' . "\n\n";
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
        if ($out_type && $out_type eq 'html') {
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
sub install_trace {

    my %p = @_;

    my $file = $p{file};
    my $extensions = $p{extensions};
    my $include = $p{include};
    my $exclude = $p{exclude};

    my $des_use = Devel::Examine::Subs->new(file => $file,);

    remove_trace(file => $file);

    # this is a DES pre_proc

    $des_use->inject(inject_use => _inject_use());

    my $des = Devel::Examine::Subs->new(
                                        file => $file,
                                        extensions => $extensions,
                                     );

    $des->inject(
        inject_after_sub_def => _inject_code(),
    );
}
sub remove_trace {
    
    my %p = @_;
    my $file = $p{file};

    my $des = Devel::Examine::Subs->new( file => $file ); 

    $des->remove(delete => [qr/injected by Devel::Trace::Subs/]);
}
sub _inject_code {
    return [
        'trace() if $ENV{DTS_ENABLE}; # injected by Devel::Trace::Subs',
    ];
}
sub _inject_use {
    return [
        'use Devel::Trace::Subs qw(trace trace_dump); ' .
        '# injected by Devel::Trace::Subs',
    ];
}
sub _env {

    my $pid = $$;
    $ENV{DTS_PID} = $pid;

    return $pid;
}
sub _store {

    my $data = shift;

    my $pid = $ENV{DTS_PID} || shift;
    my $store = "DTS_" . join('_', ($pid x 3)) . ".dat";

    $ENV{DTS_STORE} = $store;

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
sub _fold_placeholder {};

END {
    unlink $ENV{DTS_STORE} if $ENV{DTS_STORE};
}

__END__

=head1 NAME

Devel::Trace::Subs - Generate, track, store and print code flow and stack
traces.


=head1 SYNOPSIS

    use Devel::Trace::Subs qw(trace);

    # add a trace() call to the top of all your subs

    trace(); # or even better: $trace() if $ENV{DTS_ENABLE};

    # enable the module anywhere in the stack (preferably the calling script)

    $ENV{DTS_ENABLE} = 1;

    # then from anywhere (typically near the end of the calling script) dump the output

    trace_dump();

    # automate the installation into a file (or all files in a directory)

    install_trace(file => 'filename'); # or directory, or 'Module::Name'

    # remove the effects of install_trace()

    remove_trace(file => 'filename')


=head1 DESCRIPTION

This module facilitates keeping track of a project's code flow and stack
trace information in calls between subroutines.

Optionally, you can use this module to automatically inject the appropriate
C<trace()> calls into all subs in individual files, all Perl files within a 
directory structure, or even in production files by specifying its 
C<Module::Name>.

It also has the facility to undo what was done by the automatic installation
mentioned above.

=head1 EXPORT

None by default. See L<EXPORT_OK>

=head1 EXPORT_OK

C<trace, trace_dump, install_trace, remove_trace>

=head1 FUNCTIONS

=head2 C<trace>

Parameters: None

In order to enable tracing, you must set C<$ENV{DTS_ENABLE}> to a true value
somewhere in the call stack (preferably in the calling script). Simply set to
a false value (or remove it) to disable this module.

Puts the call onto the stack trace. Call it in scalar context to retrieve the
data structure as it currently sits.

Note: It is best to write the call to this function within an C<if> statement, eg:
C<trace() if $ENV{DTS_ENABLE};>. That way, if you decide to disable tracing,
you'll short circuit the process of having the module's C<trace()> function
being loaded and doing this for you.

=head2 C<trace_dump>

Dumps the output of the collected data.

All of the following parameters are optional.

C<want =E<gt> 'string'>, C<type =E<gt> 'html'>,
C<file =E<gt> 'file.ext'>

C<want>: Takes either C<'flow'> or C<'stack'>, and will output the respective
data collection. If this parameter is omitted, both code flow and stack trace
information is dumped.

C<type>: Has only a single value, C<'html'>. This will dump the output in HTML
format.

C<file>: Takes the name of a file as a parameter. The dump will write output
to the file specified. The program will C<die> if the file can not be opened
for writing.

=head2 C<install_trace>

Automatically injects the necessary code into Perl files to facilitate stack
tracing.

Parameters:

C<file =E<gt> 'filename'> - Mandatory: 'filename' can be the name of a single
file, a directory, or even a 'Module::Name'. If the filename is a directory,
we'll iterate recursively through the directory, and make the changes to all
C<.pl> and C<.pm> files underneath of it (by default). If filename is a 
'Module::Name', we'll load the file for that module dynamically, and modify it. 
CAUTION: this will edit live production files.

C<extensions =E<gt> ['pl', 'pm']> - Optional: By default, we change all C<.pm>
and C<.pl> files. Specify only the extensions you want by adding them into this
array reference, less the dot.

=head2 C<remove_trace>

Automatically remove all remnants of this module from a file or files, that were
added by this module's C<install_trace()> function.

Parameters: C<file =E<gt> 'filename'>

Where 'filename' can be the name of a file, a directory or a 'Module::Name'.

=cut

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-devel-trace-flow at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Devel-Trace-Subs>.  I will
be notified, and then you'll automatically be notified of progress on your
bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Devel::Trace::Subs


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Devel-Trace-Subs>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Devel-Trace-Subs>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Devel-Trace-Subs>

=item * Search CPAN

L<http://search.cpan.org/dist/Devel-Trace-Subs/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1; # End of Devel::Trace::Subs

