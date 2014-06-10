package Package::Anonish::PP;

use Carp qw(carp croak);
use Scalar::Util ();
use Sub::Install qw(install_sub);
use Pred::Types qw(identifier);
use Package::Generator;

sub new {
  bless {
    package => Package::Generator->new_package
  }, __PACKAGE__;
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
  my ($self, $fn) = @_;
  no strict 'refs';
  return (defined &{$self->{'package'} . '::' . $fn});
}

sub install_glob {
  my ($self, $name) = @_;
  my $new = bless {
    package => $name,
  }, __PACKAGE__;
  my @keys = grep
    !/\A(?:\*|(?:can|isa|DESTROY|AUTOLOAD)$)/,
    %{$self->{'package'} . "::"};
  foreach my $key (@keys) {
    unless (exists_in($new, $key)) {
      $new->add_method($key, \&{$self->{'package'} . "::$key"});
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
