use Test::Most;

use Package::Anonish::PP;

my $a = Package::Anonish::PP->new;
eq_or_diff([keys %$a], ['package']);
my $b = Package::Anonish::PP->new('Foo');
my $global = do {
    no strict 'refs';
    \%{"::"};
};
ok( exists $global->{'Foo::'} );

$a->add_method('foo', sub{ 42 });
eq_or_diff($a->{'package'}->foo, 42);

my $t1 = $a->bless({});
isa_ok($t1, $a->{'package'});

ok($a->blessed($t1));
ok(!$a->blessed({}));

my $b = $a->create_glob("TestABC");
$b->add_method('bar', sub { 43 });
eq_or_diff(TestABC->bar, 43);
eq_or_diff(TestABC->foo, 42);
eq_or_diff([sort keys %TestABC::],[qw(bar foo)]);
done_testing;
