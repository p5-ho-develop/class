#!/usr/bin/perl

# Test that our declared minimum Perl version matches our syntax
use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

my @MODULES = (
    'Perl::MinimumVersion 1.36',
	'Test::MinimumVersion 0.008',
);

# Don't run tests during end-user installs
use Test::More;
plan( skip_all => 'Author tests not required for installation' )
	unless ( $ENV{RELEASE_TESTING} or $ENV{AUTOMATED_TESTING} );

# Load the testing modules
while( my $MODULE = shift @MODULES ) {
	eval "use $MODULE";
	if ( $@ ) {
		next if @MODULES;
		$ENV{RELEASE_TESTING}
		? die( "Failed to load required release-testing module $MODULE" )
		: plan( skip_all => "$MODULE not available for testing" );
	}
}

all_minimum_version_from_metayml_ok();

1;
