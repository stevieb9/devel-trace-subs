#package Template;
use strict;
use warnings;

use Data::Dumper;
use HTML::Template;

#open my $wfh, '>', 'x.html' or die $!;

my @tpl = <DATA>;

my $template = HTML::Template->new(arrayref => \@tpl);


my $stack = [
    {
        'in' => 'main::one',
        'sub' => '-',
        'line' => 8,
        'filename' => 'examples/building.pl',
        'package' => 'main'
    },
    {
        'line' => 14,
        'sub' => 'main::one',
        'filename' => 'examples/building.pl',
        'package' => 'main',
        'in' => 'main::two'
    },
    {
        'in' => 'main::three',
        'sub' => 'main::two',
        'line' => 21,
        'filename' => 'examples/building.pl',
        'package' => 'main'
    }
];

#$template->param(stack => $stack);

$template->param(STACK => $stack);
print $template->output;

1;

__DATA__
<html>
<head>
 <title>Devel::Trace::Flow</title>
</head>

<body>

<div align=left>

<table>
        <tr>
                <td><img src="/graphics/image.jpeg"></td>
        </tr>
</table>
</div>

<br><br>

<h3>Stack trace:</h3>

<table id=error border=0 cellspacing=0>
<TMPL_LOOP NAME=STACK>
        <tr><td>in:</td>  <td>&nbsp;</td> <td><TMPL_VAR NAME=in></td></tr>
        <tr><td>sub:</td>  <td>&nbsp;</td> <td><TMPL_VAR NAME=sub></td></tr>
        <tr><td>file:</td>    <td>&nbsp;</td> <td><TMPL_VAR NAME=filename></td></tr>
	    <tr><td>line:</td>    <td>&nbsp;</td> <td><TMPL_VAR NAME=line></td></tr>
        <tr><td>class:</td>   <td>&nbsp;</td> <td><TMPL_VAR NAME=package></td></tr>
        <tr><td colspan=3>&nbsp;</td></tr>
</TMPL_LOOP>

</table>
</body>
</html>

