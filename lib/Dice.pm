use strict;
use warnings;

package Dice;
my @ISA    = qw(Exporter);
my @EXPORT = qw(roll);
use Parse::RecDescent;
use Data::Dumper;
use List::Util qw(max reduce);

#$::RD_TRACE=30;
#Parse::RecDescent::redirect_reporting_to(*STDOUT);
#$::RD_HINT = '1';
my $g = Parse::RecDescent->new(<<'EOG');
main: first /\Z/ {$item[1]}
first: multiple | more 
multiple: more /x/ num {[$item[0],$item[1],$item[3]];}
more: <leftop:  double /;/ double> { [$item[0], @{$item[1]}]; }
double: cond '>>' cond {[$item[0],$item[1],$item[3]];} 
double: cond
cond: sum ('=='|'>='|'<='|'<>'|'='|'<'|'>'|'!=') sum {[$item[0],$item[1],$item[2], $item[3]];}
cond: sum
sum: <leftop:  summand /([+-])/ summand> { [$item[0], @{$item[1]}]; }
summand: dice | num
dice: 'd'  num { [$item[0],['scalar',1],['scalar',0],$item[2]]} 
dice: num 'd'  '{' num '}' num  {[$item[0],$item[1],$item[4],$item[6]]}
dice: num 'd' num  {[$item[0],$item[1],['scalar',0],$item[3]]}
num: /\d+/ { ['scalar', $item[1]]; } 
num: '(' double ')'  {$item[2]}
EOG
my %table;

sub ezec {
    my ( $func, @args ) = @_;
    $table{$func}->(@args);
}

#dispatch table
$table{sum} = sub {

    my $v = ezec( @{ shift() } );
    my $x = $v;
    $v =~ s/\*//g;
    while (@_) {
        my $op = shift;
        my $p  = ezec( @{ shift() } );
        $v = $v + $p if $op eq '+';
        $v = max( $v - $p, 1 ) if $op eq '-';
    }
    return "$v*" if $x =~ /\*/;
    return $v;
};
$table{cond} = sub {
    my $l  = ezec( @{ $_[0] } );
    my $r  = ezec( @{ $_[2] } );
    my $op = $_[1];
    $op = '==' if $op eq '=';
    $op = '!=' if $op eq '<>';
    if ( eval("$l$op$r") ) {
        return "$l*";
    }
    else { return $l; }
};
$table{'scalar'} = sub {
    return shift;
};
$table{'more'} = sub {
    my @rolls;
    my $v = ezec( @{ shift() } );
    push @rolls, $v;
    while (@_) {
        my $p = ezec( @{ shift() } );
        push @rolls, $p;
    }
    return join( "; ", @rolls );
};
$table{'multiple'} = sub {
    my @rolls;
    my $op       = shift();
    my $multiple = ezec( @{ shift() } );
    for ( 1 .. $multiple ) {
        push @rolls, ezec(@$op);
    }
    return join( "\n", @rolls );
};
$table{double} = sub {
    my $f = ezec( @{ $_[0] } );
    my $s = ezec( @{ $_[1] } );
    return "$f>>" . ( $f + $s );
};
$table{dice} = sub {
    my $v  = 0;
    my $ct = ezec( @{ $_[0] } );
    my @rolls;
    push @rolls, int( 1 + rand( ezec( @{ $_[2] } ) ) ) for ( 1 .. $ct );
    map { $v += $_ } sort @rolls[ 0 .. $#rolls - ezec( @{ $_[1] } ) ];
    return $v;
};

sub roll {
    my $output = $g->main( join( " ", @_ ) );
    my $result;
    eval { $result = ezec(@$output); };
    if ($@) {
        $result = "dice not recognized";
    }

    #print "->" . Dumper( $output, $@ );
    return $result;
}

1;

# ABSTRACT: facility for dice managment with advanced grammar

__END__
=pod

=head1 NAME

Dice - facility for dice managment with advanced grammar

=head1 VERSION

version 0.26.1

=head1 AUTHOR

Valerio Crini <vcrini@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Valerio Crini.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

