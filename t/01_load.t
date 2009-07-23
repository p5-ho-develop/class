#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'HO::class' );
}

diag( "Testing HO::class $HO::class::VERSION, Perl $], $^X" );
