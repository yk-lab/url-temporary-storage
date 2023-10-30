package Add_item;

use Carp qw(croak);
use utf8;
use strict;
use warnings;
use Encode;
use DBI;

sub new{
    my $pkg = shift;
    bless {
        Handle => shift,
    },$pkg;
}

sub add{
	my $self = shift;
	my $id = shift;
	my $query = shift;
	
	my($sec,$min,$hour,$mday,$mon,$year,undef,undef,undef) = localtime(time);
	$year += 1900;
	$mon += 1;
	my $datetime = "$year-$mon-$mday $hour:$min:$sec";
	
	my $dbh = $self->{Handle};
	my $sth = $dbh->prepare("INSERT INTO `items` (`time` ,`user` ,`title` ,`url` ,`status`) VALUES (".$dbh->quote($datetime).",  ".$dbh->quote($id).",  ".$dbh->quote($query->{title}).",  ".$dbh->quote($query->{url}).",  'unread');");
    my $rv = $sth->execute();
    $dbh->commit;
    my $rows = $sth->rows;
    $sth->finish();
    if($rows == 1){
    	return 1;
    }
   	return 0;
}
1;
