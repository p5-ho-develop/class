
; use strict
; use Test::More tests => 7

; use_ok('HO::class')

; package H::first
; use HO::class _method => hw => sub { 'Hallo Welt!' }

; package main
; my $o1 = H::first->new
; is($o1->hw,'Hallo Welt!')
; my $o2=$o1->new
; is($o2->hw,'Hallo Welt!')

; $o2->[$o2->_hw] = sub { 'Hello world!' }
; is($o2->hw,'Hello world!')

; package H::second
; use HO::class 
    _method => version => sub { '1.2' },
    _method => void => undef

; package H::third
; use HO::class
    _method => version => sub { '1.3' },
    _method => void => sub { 'NULL' }
 
; package main
; my $m1 = H::second->new
; is($m1->version,'1.2')
; eval { $m1->void }
; ok($@,"Exception: $@")

; my $m2 = H::third->new
; is($m2->version,'1.3')
