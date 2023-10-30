package Cookie;

use Carp qw(croak);
use utf8;
use strict;
use warnings;
use Encode;

sub new{
    my $pkg = shift;
    bless {
    },$pkg;

}

sub makeexpiresdate{my $delta;my($gmt, @t, @m, @w);$delta = $_[0];@t = gmtime(time() + $delta*60*60*24);@m = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');@w = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');$gmt = sprintf("%s, %02d-%s-%04d %02d:%02d:%02d GMT",$w[$t[6]], $t[3], $m[$t[4]], $t[5]+1900, $t[2], $t[1], $t[0]);return $gmt;}
sub makeexpirestime{my $delta;my($gmt, @t, @m, @w);$delta = $_[0];@t = gmtime(time() + $delta*60*60);@m = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');@w = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');$gmt = sprintf("%s, %02d-%s-%04d %02d:%02d:%02d GMT",$w[$t[6]], $t[3], $m[$t[4]], $t[5]+1900, $t[2], $t[1], $t[0]);return $gmt;}


1;
