  package HO::mixin;
# ******************
  our $VERSION = '0.01';
# **********************
; use strict; use warnings

; use Carp ()
; use Package::Subroutine ()
; use Data::Dumper

; our $class

; sub import
    { my ($self, $mixin, @args) = @_
    ; my $class = $HO::mixin::class || CORE::caller
    ; unless (defined $mixin)
        { Carp::croak("Which class do you want to mix into ${self}?")
        }
    ; eval "require $mixin"

    ; if($HO::class::class_args{$mixin})
        { $HO::class::mixin_classes{$class} = [] unless
            defined $HO::class::mixin_classes{$class}
        ; push @{$HO::class::mixin_classes{$class}}, @{$HO::class::class_args{$mixin}}
        }

    ; $HO::accessor::classes{$class} = [] unless
        defined $HO::accessor::classes{$class}
    ; my $mix = $HO::accessor::classes{$mixin}
    ; $mix = [] unless ref $mix
    ; push @{$HO::accessor::classes{$class}}, @$mix
    ; my %acc = @$mix
    ; my @methods = grep { !(/^new$/ || defined($acc{$_})) }
        grep { ! $HO::class::class_methods{$mixin}{$_} }
        Package::Subroutine->findsubs( $mixin )
    ; Package::Subroutine->export_to($class)->($mixin,@methods)
    }

; 1

__END__
