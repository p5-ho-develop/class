
use strict;
use warnings;

use Test::More tests => 1;
use Test::Exception;

package HOA::five;
use HO::abstract 'class';
use HO::class;

package main;

throws_ok { HOA::five->new } qr/Abstract class 'HOA::five' should not be instatiated./;
