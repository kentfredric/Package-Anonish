use strict;
use warnings;

package Package::Anonish::PP;

our $VERSION = '0.001000';

# ABSTRACT: Create lightweight anonymous metaclass objects.

# AUTHORITY

use Carp qw(carp croak);
use Scalar::Util ();
use Sub::Install qw(install_sub);
use Pred::Types qw(identifier);
use Package::Generator;
use Package::Stash;

sub new {
  my ($package, $name) = @_;
  $package = $package->blessed($package) || $package;
  $name ||= Package::Generator->new_package;
  eval "package $name";
  croak($@) if $@;
  return bless {
    package => $name,
    stash   => Package::Stash->new($name),
  }, $package;
}

sub bless {
  my ($self, $ref) = @_;
  CORE::bless $ref, $self->{'package'};
}

sub add_method {
  my ($self, $name, $code) = @_;
  install_sub({
    code => $code,
    into => $self->{'package'},
    as => $name,
  });
}

sub blessed {
  my ($self, $obj) = @_;
  Scalar::Util::blessed($obj);
}

sub exists_in {
  my ( $self, $fn ) = @_;
  return $self->{stash}->has_symbol( '&' . $fn );
}

sub methods {
  my ($self) = @_;
  grep !/^(?:(?:isa|can|DESTROY|AUTOLOAD)$|\*)/, $self->{stash}->list_all_symbols('CODE');
}

sub install_glob {
  my ( $self, $name ) = @_;
  my $new = $self->new($name);
  my @keys = grep !/\A(?:\*|(?:can|isa|DESTROY|AUTOLOAD)$)/, $self->{stash}->list_all_symbols('CODE');
  foreach my $key (@keys) {
    unless ( exists_in( $new, $key ) ) {
      $new->add_method( $key, $self->{stash}->get_symbol( '&' . $key ) );
    }
  }
  return $new;
}

sub create_glob {
  my ($self, $name) = @_;
  return $self->install_glob($name);
}

1
__END__
