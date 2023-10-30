#!/usr/bin/perl

#BEGIN{$|=1;print"Content-type:text/html\n\n";open(STDERR,">&STDOUT");}

#-d:NYTProf

use utf8;
use strict;
use warnings;
use Encode;
use DBI;

sub url_encode($){my $str=shift;$str=~s/([^\w ])/'%'.unpack('H2', $1)/eg;$str =~ tr/ /+/;return $str;}
sub url_decode($){my $str=shift;$str=~tr/\+/ /;$str=~s/%([0-9A-Fa-f][0-9A-Fa-f])/pack('H2', $1)/eg;return $str;}
sub Post_Query{my %QUERY;read(STDIN, my $QUERY, $ENV{'CONTENT_LENGTH'});foreach(split(/&/, $QUERY)){my ($Name, $Value)=split(/=/, $_);my $name=lc("$Name");$Value=url_decode("$Value");$Value =~ s/\t//g;utf8::decode($Value = $Value);$QUERY{"$name"} = $Value;}return(%QUERY);}

my %query = Post_Query();

print "Content-type: text/html\n\n";
foreach my $key(keys %query){
	print $query{$key}."<br/>\n";
}

exit;
