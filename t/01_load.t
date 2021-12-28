#!perl -T

use Test2::V0;

plan(2);

use HO::class ; BEGIN { ok(1,'HO::class') };
use HO::abstract ; BEGIN { ok(1,'HO::abstract') };

diag( "Testing HO::class $HO::class::VERSION, Perl $], $^X" );
