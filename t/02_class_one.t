
use strict;
use warnings;
use Test::More tests => 1;

package THO::one;

use HO::class
  _rw => rw_scalar => '$',
  _rw => rw_array => '@',
  _rw => rw_hash => '%',
  _ro => ro_scalar => '$',
  _ro => ro_array => '@',
  _ro => ro_hash => '%';

package main;

my $obj = THO::one->new;

isa_ok($obj,'THO::one');
