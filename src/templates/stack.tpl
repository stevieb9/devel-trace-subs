
Stack trace:

[% FOREACH entry IN stack %]
    in:      [% entry.in %]
    sub:     [% entry.sub %]
    file:    [% entry.filename %]
    line:    [% entry.line %]
    package: [% entry.package %]
[% END %]
