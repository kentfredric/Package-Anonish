use Test::Most;

use Package::Anonish::PP;

my $a = Package::Anonish::PP->new;
eq_or_diff([keys %$a], ['package']);

$a->add_method('foo', sub{42});
eq_or_diff(\&{$a->{'package'}."::foo"}, sub { 42 });

my $t1 = $a->bless_in({});
isa_ok($t1, $a->{'package'});

ok($a->blessed($t1));
ok(!$a->blessed({}));

my $b = $a->create_glob("TestABC");
$b->add_method('bar', sub { 42 });
eq_or_diff(\&TestABC::bar, sub { 42 });

done_testing;
