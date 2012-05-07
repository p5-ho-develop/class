

use strict;
use warnings;

use Test::More tests => 6;
use Test::Exception;

package HOA::five;
use HO::abstract 'class';
use HO::class;

package HOA::four;
use subs 'init';
use HO::class;
HO::abstract->import('class',__PACKAGE__);

package main;

throws_ok { HOA::five->new } 
	  qr/Abstract class 'HOA::five' should not be instantiated./;

throws_ok { HO::abstract->import('unknown') } 
	  qr/Unknown action '.*' in use of HO::abstract\./;

throws_ok { HOA::four->new } 
	  qr/Abstract class 'HOA::four' should not be instantiated./;

package HOB::six; use subs qw/init/; use HO::class;
package HOB::seven; use subs qw/init/; use HO::class;
package HOB::eight; use subs qw/init/; use HO::class;

package main;

use HO::abstract class => qw/HOB::six HOB::seven HOB::eight/;

foreach my $class (qw/HOB::six HOB::seven HOB::eight/)
{
    throws_ok { $class->new } 
	  qr/Abstract class '$class' should not be instantiated./;
}
