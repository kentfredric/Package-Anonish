package Package::Anonish::PP;

use Carp qw(carp croak);
use Scalar::Util ();
use Sub::Install qw(install_sub);
use Pred::Types qw(identifier);
use Package::Stash;

sub new {
  bless {
		package => Package::Stash->new({})
  }, __PACKAGE__;
}

sub bless_in {
  my ($self, $ref) = @_;
  bless $ref, (''. $self->{'package'});
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

sub install_glob {
  my ($self, $name) = @_;
  bless {
    package => Package::Stash->new($name)
  }, __PACKAGE__;
}

sub create_glob {
  my ($self, $name) = @_;
  return $self->install_glob($name);
}

1
__END__
