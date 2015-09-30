use 5.012;
use strict;
use warnings;

use Cwd;
use ExtUtils::MakeMaker;
use File::Find;

WriteMakefile(
    NAME             => 'Devel::Trace::Subs',
    AUTHOR           => q{Steve Bertrand <steveb@cpan.org>},
    VERSION_FROM     => 'lib/Devel/Trace/Subs.pm',
    ABSTRACT_FROM    => 'lib/Devel/Trace/Subs.pm',
    LICENSE          => 'artistic_2',
    PL_FILES         => {},
    MIN_PERL_VERSION => '5.012',
    CONFIGURE_REQUIRES => {
        'Cwd' => 0,
        'ExtUtils::MakeMaker' => 0,
        'File::Find' => 0,
        'Tie::File' => 0,
    },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url => 'https://github.com/stevieb9/devel-trace-subs.git',
                web => 'https://github.com/stevieb9/devel-trace-subs',
            },
        },
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Devel::Examine::Subs' => '1.45',
        'HTML::Template' => 0,
        'Template' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Devel-Trace-Subs-*' },
);
