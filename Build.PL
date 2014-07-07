use 5.008;
use strict;
use warnings FATAL => 'all';
use Module::Build;
use Config;

# defined version via env
# will be overwritten by git
my $version = $ENV{'VERSION'};

if (-d ".git") {
    my ($dir, $manifest);
    open $manifest, ">", "MANIFEST" or die "MANIFEST: $!";
    print $manifest "MANIFEST\n";
    print $manifest `git ls-files`, "\n";
    $version = `git describe --abbrev=4 --dirty --always`;
}

if ($version)
{
	$version =~ s/(?:\A\s*|\s*\z)//g;
	# update README and other parts to set the version
	open (my $fh, "<:raw", "lib/IO/CSS.pm") or die "fatal $!";
	my @lines = <$fh>; close($fh);
	@lines = map { s/^our \$VERSION = \'[^\']+\'/our \$VERSION = '$version'/; $_ } @lines;
	open ($fh, ">:raw", "lib/IO/CSS.pm") or die "fatal $!";
	print $fh @lines; close($fh);
}

my $builder = Module::Build->new(
    module_name         => 'IO::CSS',
    license             => 'perl',
    dist_author         => q{Marcel Greter <marcel.greter@ocbnet.ch>},
    dist_abstract       => 'Open a CSS file with automatic charset detection',
    dist_version_from   => 'lib/IO/CSS.pm',
    release_status      => 'stable',
    create_license      => 1,
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {},
    meta_merge => {
      resources => {
        repository  => 'https://github.com/mgreter/IO-CSS',
      },
    },
    add_to_cleanup     => [ 'IO-CSS-*' ],
    extra_compiler_flags => '',
    extra_linker_flags => '',
);

$builder->create_build_script();
