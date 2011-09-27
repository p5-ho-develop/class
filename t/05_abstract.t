
use strict;
use warnings;

use Test::More tests => 3;
use Test::Exception;

package HOA::five;
use HO::abstract 'class';
use HO::class;

package HOA::four;
use subs 'init';
use HO::class;
HO::abstract->import('class','HO::four');

package main;

throws_ok { HOA::five->new } 
	  qr/Abstract class 'HOA::five' should not be instantiated./;

throws_ok { HO::abstract->import('unknown') } 
	  qr/Unknown action '.*' in use of HO::abstract\./;

throws_ok { HOA::four->new } 
	  qr/Abstract class 'HOA::four' should not be instantiated./;

