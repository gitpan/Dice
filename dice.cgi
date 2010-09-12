#!/usr/bin/perl
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Dice;
my $q     = new CGI;
my $dice  = $q->param('dice') || "1d6+1";
my @rows  = split( '\n', Dice::roll($dice) );
my $table = $q->start_table();
$table .= $q->th( [ '', split( /[;x]/, $dice ) ] );
my $count  = 1;
my $script = <<HERE;
    <!--
    document.write("for suggestions <a hre" + "f=mai" + "lto:vc" + "rini" + "@gmail." + "com" + ">e" + "mai" + "l me</" + "a>" + "")
      //--><noscript>for suggestions <a href=mailto:vcrini[AT]gmailDOTcom>email me</a></noscript>
HERE

for (@rows) {
    my @row = ( split( /; /, $_ ) );
    if ( @rows > 1 ) {
        $table .= $q->Tr( $q->td( [ $count . ".", @row ] ) );
    }
    else {
        $table .= $q->Tr( $q->td( [ " ", @row ] ) );
    }
    $count++;
}
$table .= $q->end_table();
print $q->header,
  $q->start_html( -title => 'dice roller 0.2.5', -script => $script ),
  $q->h4('Enter your dice then hit \'generate\''),
  $q->h6('go below for some example'),
  $q->start_form( -action => $q->script_name ),
  $q->textfield(
    -name      => 'dice',
    -default   => $dice,
    -override  => 1,
    -size      => 30,
    -maxlength => 80
  ),
  $q->submit( -value => 'generate' ),
  $table, $q->end_form,
  $q->h5("e.g."),
  $q->h6("d20 "),
  $q->h6("3d6+1d4 "),
  $q->h6("1d3-1 "),
  $q->h6(
    "4d{1}6 discard lowest value, say you have 1,5,5,3 only 5,5,3 are kept "),
  $q->h6("d3;d4 rolls a d3 then a d4 "),
  $q->h6("d3;d4x3 rolls a d3 then a d4 on 3 rows"),
  $q->h6(
    "d2>1 if it satisfies condition then postfix a '*': 1d2>1 it prints 1 or 2*"
  ),
  $q->h6("d6+5>>1d6 equal to d6+5; d6+5+1d6"),
  $q->h5("more examples"),
  $q->h6( "(d20=20)+10;1d12>>12+1d6: if a 'natural' 20 is rolled - that corresponds to 30 then damage is 1d12+1d6+12  "
  ),
  $q->end_html;
