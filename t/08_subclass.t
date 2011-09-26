
use strict;
use warnings;

use Test::More tests => 1;

use HO::class;

package H::one;

sub one {1}

package main;

HO::class::make_subclass(
  of => ['H::one'],
  in => '',
  name => 'H::onebase',
  codegen => ''
);

is(H::onebase->one,1,'subclass with one base');

