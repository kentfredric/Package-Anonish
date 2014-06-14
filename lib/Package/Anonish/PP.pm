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

sub new {
  my ($package, $name) = @_;
  $package = $package->blessed($package) || $package;
  $name ||= Package::Generator->new_package;
  eval "package $name";
  croak($@) if $@;
  return bless {
    package => $name,
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

sub _get_stash {
  my ($self) = @_;
  no strict 'refs';
  return \%{ $self->{package} . '::' };
}

sub exists_in {
  my ( $self, $fn ) = @_;
  return defined &{ $self->_get_stash()->{$fn} };
}

sub methods {
  my ($self) = @_;

  grep !/^(?:(?:isa|can|DESTROY|AUTOLOAD)$|\*)/, keys %{ $self->_get_stash() };
}

sub install_glob {
  my ( $self, $name ) = @_;
  my $new   = $self->new($name);
  my $stash = $self->_get_stash();
  my @keys  = grep !/\A(?:\*|(?:can|isa|DESTROY|AUTOLOAD)$)/, keys %{$stash};
  foreach my $key (@keys) {
    unless ( exists_in( $new, $key ) ) {
      $new->add_method( $key, \&{ $stash->{$key} } );
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
