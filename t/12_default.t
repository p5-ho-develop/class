
use strict;
use warnings;

use Test2::V0;

plan(6);

package Alphabet;

use HO::class
  _ro => 'alphabet' => sub {['a','b','c']},
  _ro => 'map' => sub {{'a' => 1,'b' => 26,'c' => 8}},
  _lvalue => 'index' => sub { 1024 };

package main;

my $a = Alphabet->new;
is([$a->alphabet],['a','b','c'],'array default');
is(scalar $a->map, {'a' => 1,'b' => 26,'c' => 8},'hash default');
is($a->index, 1024, 'lvalue default value');


package Alphacat;

use HO::class
  _ro => 'alphacat' => [ '@', sub {['a','b','c']} ],
  _ro => 'map' => ['%', sub {{'a' => 1,'b' => 26,'c' => 8}} ],
  _lvalue => 'parent' => ['$', sub{ Alphabet->new }];

package main;

my $b = Alphacat->new;
is([$a->alphabet],['a','b','c'],'array default');
is(scalar $a->map, {'a' => 1,'b' => 26,'c' => 8},'hash default');
is($b->parent, $a, 'default for lvalue member');

done_testing();


