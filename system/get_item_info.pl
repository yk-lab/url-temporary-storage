package Get_item_info;

use Carp qw(croak);
use utf8;
use strict;
use warnings;
use Encode;
use DBI;

sub new{
    my $pkg = shift;
    bless {
        CONF => shift,
        Handle => shift,
        user => shift,
        dir => shift,
        option => shift
    },$pkg;
}

sub right{
	my $self = shift;
	my $id = shift;
	
	my $dbh = $self->{Handle};
	my $sth = $dbh->prepare("select `id` from `items` where `id` = ".$dbh->quote($id)." and `user` = ".$dbh->quote($self->{user}{id}).";");
    my $rv = $sth->execute();
    my $rows = $sth->rows;
    $sth->finish();
    if($rows == 1){
    	return 1;
    }
   	return 0;
}

sub url{
	my $self = shift;
	my $id = shift;
	my $url;
	
	my $dbh = $self->{Handle};
    
	my $sth = $dbh->prepare("select `id`,`url` from `items` where `id` = ".$dbh->quote($id)." and `user` = ".$dbh->quote($self->{user}{id}).";");
    my $rv = $sth->execute();
    my $rows = $sth->rows;
    if($rows > 0){
        while (my $_ = $sth->fetchrow_hashref()){
            $url = $_->{url};
        }
    }
    $sth->finish();
	
	return $url;
}
1;
