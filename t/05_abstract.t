

use strict;
use warnings;

use Test::More tests => 12;
use Test::Exception;

package HOA::five;
use HO::abstract 'class';
use HO::class;

package HOA::four;
use subs 'init';
use HO::class;
HO::abstract->import('class',__PACKAGE__);

package main;

#############################
# Checks HO::abstract
#############################

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

#############################
# Checks HO::class
#############################

package HOB::zro;

use HO::class
  _ro => one => '$' => 'abstract',
  _rw => two => '$' => 'abstract',
  _method => three => sub { 42 };
  
package HOB::on;

BEGIN { our @ISA = 'HOB::zro'; };

use HO::class;

sub one { my ($s,$a) = @_; $s->[&_one] = $a if defined $a; return }

package main;

my $zero = HOB::zro->new;
my $one = HOB::on->new;

throws_ok { $zero->one } 
    qr/Can't locate object method "one" via package "HOB::zro" at.*/;
    
ok($zero->can('_one'),'index created');
ok($zero->_one =~ /^\d+$/, 'index is numeric');
    
throws_ok { $one->two }
    qr/Can't locate object method "two" via package "HOB::on" at.*/;

is($one->three,42,'following definition');

ok($one->can('one'),'for sure');
