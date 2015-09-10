#package Template;
use strict;
use warnings;

use HTML::Template;

my @tpl = <DATA>;


print @tpl;

open my $wfh, '>', 'x.html' or die $!;

print $wfh @tpl;

[
    {
        'called' => 'main::one',
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
        'called' => 'main::two'
    },
    {
        'called' => 'main::three',
        'sub' => 'main::two',
        'line' => 21,
        'filename' => 'examples/building.pl',
        'package' => 'main'
    }
];

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
        <TMPL_IF sub>
        <tr><td>method:</td>  <td>&nbsp;</td> <td><TMPL_VAR NAME=sub></td></tr>
        </TMPL_IF>
        <tr><td>file:</td>    <td>&nbsp;</td> <td><TMPL_VAR NAME=filename></td></tr>        
	<tr><td>line:</td>    <td>&nbsp;</td> <td><TMPL_VAR NAME=line></td></tr>
        <tr><td>class:</td>   <td>&nbsp;</td> <td><TMPL_VAR NAME=package></td></tr>
        <tr><td colspan=3>&nbsp;</td></tr>
</TMPL_LOOP>

</table>
</body>
</html>

