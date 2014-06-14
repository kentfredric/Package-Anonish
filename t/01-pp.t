use Test::Most;

use Package::Anonish::PP;

subtest q[Create Fully Anonymous] => sub {
  my $a = Package::Anonish::PP->new;
  eq_or_diff( [ keys %$a ], ['package'], 'Anonymous Class is an object with a single key: package' );
};

subtest q[Create Named] => sub {
  my $b      = Package::Anonish::PP->new('Foo');
  my $global = do {
    no strict 'refs';
    \%{"::"};
  };
  ok( exists $global->{'Foo::'}, 'Namespace came into existance' );
};

subtest q[Add Method] => sub {
  my $a = Package::Anonish::PP->new;
  $a->add_method( 'foo', sub { 42 } );
  eq_or_diff( $a->{'package'}->foo, 42, 'Created method returns given value' );
};

subtest q[Bless Instance] => sub {
  my $a = Package::Anonish::PP->new;
  my $t1 = $a->bless( {} );
  isa_ok( $t1, $a->{'package'} );

  ok( $a->blessed($t1), 'Class confirms it blessed t1' );
  ok( !$a->blessed( {} ), 'Class says it did not bless a bare hash' );
};

subtest q[Child Classes] => sub {
  my $a = Package::Anonish::PP->new;
  $a->add_method( 'foo', sub { 42 } );
  my $b = $a->create_glob("TestABC");
  $b->add_method( 'bar', sub { 43 } );

  eq_or_diff( TestABC->bar, 43, 'Child class has new ->bar method' );
  eq_or_diff( TestABC->foo, 42, 'Child class has parents ->foo method' );
  eq_or_diff( [ sort keys %TestABC:: ], [qw(bar foo)], 'Child class has only 2 methods' );
};
done_testing;
