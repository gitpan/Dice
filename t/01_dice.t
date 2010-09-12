#!/usr/bin/perl
use Test::More qw(no_plan);
use Test::Differences;
use Dice;

sub regexp {
    my %vars = ( times => 20, @_ );
    my $regexp = join( '|', ( $vars{'first'} .. $vars{'last'} ) );
    like( $vars{value}, qr/$regexp/, "test $_/$vars{times}" )
      for ( 1 .. $vars{times} );
}
regexp(
    'value' => Dice::roll("3d6"),
    'first' => 3,
    'last'  => 18,
    'times' => 100
);
regexp(
    'value' => Dice::roll("d6-1"),
    'first' => 1,
    'last'  => 5,
    'times' => 20
);
regexp(
    'value' => Dice::roll("d2+d3"),
    'first' => 2,
    'last'  => 5,
    'times' => 20
);
regexp(
    'value' => Dice::roll("4d{1}6"),
    'first' => 3,
    'last'  => 18,
    'times' => 1
);
is( Dice::roll("1d1=1"),     '1*' );
is( Dice::roll("1d1>1"),     '1' );
is( Dice::roll("1d1>=1"),    '1*' );
is( Dice::roll("1>>1"),      '1>>2' );
is( Dice::roll("(1d1=1)+1"), '2*' );
is( Dice::roll("1d1=1+1"),   '1' );
is( Dice::roll("2=1+1"),     '2*' );
