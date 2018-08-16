  package HO::accessor
# ++++++++++++++++++++
; use strict; use warnings;
our $VERSION='0.05';

; use Class::ISA
; require Carp

; my %classes
; my %accessors

; our %type = ('@'=>sub () {[]}, '%'=>sub () {{}}, '$'=>sub () {undef})

; our %init =
    ( 'hash' => sub
        { my ($self,%args) = @_
        ; while(my ($method,$value)=each(%args))
            { my $access = "_$method"
            ; $self->[$self->$access] = $value
            }
        ; return $self
        },
      'hashref' => sub
        { my ($self,$args) = @_
        ; while(my ($method,$value)=each(%$args))
            { my $access = "_$method"
            ; $self->[$self->$access] = $value
            }
        ; return $self
        }
    )

; our %ro_accessor =
    ( '$' => sub { my ($n,$class) = @_
                 ; my $idx = "_$n"
                 ; return sub ()
                     { Carp::confess("Not a class method '$n'.")
                         unless ref($_[0])
                     ; $_[0]->[$_[0]->${idx}]
                     }
                 }
    , '@' => sub { my ($n,$class) = @_
                 ; my $iname = "_$n"
                 ; return sub
                     { my ($obj,$idx) = @_
                     ; if(@_==1)
                        { return @{$obj->[$obj->${iname}]}
                        }
                       else
                        { return $obj->[$obj->${iname}]->[$idx]
                        }
                 }}
    , '%' => sub { my ($n,$class) = @_
                 ; my $iname = "_$n"
                 ; return sub
                     { my ($obj,$key) = @_
                     ; (@_==1) ? {%{$obj->[$obj->${iname}]}}
                               : $obj->[$obj->${iname}]->{$key}
                     }
                 }
    )

; our %rw_accessor =
    ( '$' => sub { my ($n,$class) = @_
                 ; my $nidx = "_$n"
                 ; return sub
                     { my ($obj,$val) = @_
                     ; Carp::confess("Not a class method '$n'.")
                         unless ref($obj)
                     ; return $obj->[$obj->${nidx}] if @_==1
                     ; $obj->[$obj->${nidx}] = $val
                     ; return $obj
                     }
                 }
    , '@' => sub { my ($n,$class) = @_
                 ; my $nidx = "_$n"
                 ; return sub
                     { my ($obj,$idx,$val) = @_
                     ; Carp::confess("Not a class method '$n'.")
                         unless ref $obj
                     ; if(@_==1) # get values
                         { # etwas mehr Zugriffsschutz da keine Ref
                           # einfache Anwendung in bool Kontext
                         ; return @{$obj->[$obj->${nidx}]}
                         }
                       elsif(@_ == 2)
                         { unless(ref $idx eq 'ARRAY')
                             {  return $obj->[$obj->${nidx}]->[$idx]     # get one index
                             }
                           else
                             { $obj->[$obj->${nidx}] = $idx                 # set complete array
                             ; return $obj
                             }
                         }
                       elsif(@_==3)
                         { if(ref($idx))
                             { if($val eq '<')
                                 { $$idx = shift @{$obj->[$obj->${nidx}]}
                                 }
                               elsif($val eq '>')
                                 { $$idx = pop @{$obj->[$obj->${nidx}]}
                                 }
                               else
                                 { if(@$val == 0)
                                     { @$idx = splice(@{$obj->[$obj->${nidx}]})
                                     }
                                   elsif(@$val == 1)
                                     { @$idx = splice(@{$obj->[$obj->${nidx}]},$val->[0]);
                                     }
                                   elsif(@$val == 2)
                                     { @$idx = splice(@{$obj->[$obj->${nidx}]},$val->[0],$val->[1]);
                                     }
                                 }
                             }
                            elsif($idx eq '<')
                             { push @{$obj->[$obj->${nidx}]}, $val
                             }
                            elsif($idx eq '>')
                             { unshift @{$obj->[$obj->${nidx}]}, $val
                             }
                            else
                             { $obj->[$obj->${nidx}]->[$idx] = $val     # set one index
                             }
                          ; return $obj
                          }
                     }
                 }
    , '%' => sub { my ($n,$i) = @_
                 ; my $nidx = "_$n"
                 ; return sub { my ($obj,$key) = @_
                 ; if(@_==1)
                     { return $obj->[$obj->${nidx}] # for a hash an reference is easier to handle
                     }
                   elsif(@_==2)
                     { if(ref($key) eq 'HASH')
                         { $obj->[$obj->${nidx}] = $key
                         ; return $obj
                         }
                        else
                         { return $obj->[$obj->${nidx}]->{$key}
                         }
                     }
                   else
                     { shift(@_)
                     ; my @kv = @_
                     ; my $ni = $obj->${nidx}
                     ; while(@kv)
                         { my ($k,$v) = splice(@kv,0,2)
                         ; $obj->[$ni]->{$k} = $v
                         }
                     ; return $obj
                     }
                 }}
    )

; our $class

; my $object_builder = sub
    { my ($obj,$constructor,$args) = @_
    ; foreach my $typedefault (@$constructor)
        { push @{$obj}, ref($typedefault) ? $typedefault->($obj,$args)
                                          : $typedefault
        }
    }

; sub import
    { my ($package,$ac,$init,$new) = @_
    ; $ac   ||= []

    ; my $caller = $HO::accessor::class || CORE::caller

    ; die "HO::accessor::import already called for class $caller."
        if $classes{$caller}

    ; $classes{$caller}=$ac

    ; my @build = reverse Class::ISA::self_and_super_path($caller)
    ; my @constructor
    ; my @class_accessors

    ; my $count=0
    ; foreach my $class (@build)
        { $classes{$class} or next
        ; my @acc=@{$classes{$class}} or next
        ; while (@acc)
            { my ($accessor,$type)=splice(@acc,0,2)
            ; my $proto = ref($type) eq 'CODE' ? $type : $type{$type}
            ; unless(ref $proto eq 'CODE')
                { Carp::carp("Unknown property type '$type', in setup for class $caller.")
                ; $proto=sub{undef}
                }
            ; my $val=$count
            ; my $acc=sub {$val}
            ; push @class_accessors, $accessor
            ; $accessors{$caller}{$accessor}=$acc
            ; $constructor[$acc->()] = $proto
            ; $count++
            }
        }
    # FIXME: Die init Methode sollte Zugriff auf $self haben k�nnen.
    ; { no strict 'refs'
      ; if($new)
          { *{"${caller}::new"}=
              ($init || $caller->can('init')) ?
                sub
                  { my ($self,@args)=@_
                  ; my $obj = bless [], ref $self || $self
                  ; $object_builder->($obj,\@constructor,\@args)
                  ; return $obj->init(@args)
                  }
              : sub
                  { my ($self,@args)=@_
                  ; my $obj = bless [], ref $self || $self
                  ; $object_builder->($obj,\@constructor,\@args)
                  ; return $obj
                  }
          }

      ; foreach my $acc (@class_accessors)
          { *{"${caller}::${acc}"}=$accessors{$caller}{$acc}
          }
      }

    # setup init method
    ; if($init)
        { unless(ref($init) eq 'CODE' )
            { $init = $init{$init}
            ; unless(defined $init)
                { Carp::croak("There is no init defined for init argument $init.")
                }
            }
        ; no strict 'refs'
        ; *{"${caller}::init"}= $init
        }
    }

# Package Method
; sub accessors_for_class
    { my ($self,$class)=@_
    ; return $classes{$class}
    }

# Package Function
; sub _value_of
    { my ($class,$accessorname) = @_
    ; return $accessors{$class}{$accessorname}->()
    }

; 1

__END__

=head1 NAME

HO::accessor

=head1 SYNOPSIS

    package HO::World::Consumer;
    use base 'HO::World::Owner';

    use HO::accessor [ industry => '@', profit => '$' ];

=head1 DESCRIPTION

=over 4

=item import

=item accessors_for_class

=item method

=item ro

=item rw

=back

=head1 SEE ALSO

L<Class::ArrayObjects> by Robin Berjon (RBERJON)

L<Class::BuildMethods> by Ovid -- add inside out data stores to a class.

=head1 AUTHOR

Sebastian Knapp, E<lt>news@young-workers.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007-2017 by Sebastian Knapp

You may distribute this code under the same terms as Perl itself.

=cut

