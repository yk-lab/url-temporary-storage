package Switch_item_status;

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
        option => shift
    },$pkg;
}

sub read{
	my $self = shift;
	my $id = shift;
	
	my $dbh = $self->{Handle};
    
	my $sth = $dbh->prepare("update `items` set `status` = 'read' where `id` = ".$dbh->quote($id).";");
    my $rv = $sth->execute();
    $sth->finish();
	$dbh->commit;
	return 1;
}

sub unread{
	my $self = shift;
	my $id = shift;
	
	my $dbh = $self->{Handle};
    
	my $sth = $dbh->prepare("update `items` set `status` = 'unread' where `id` = ".$dbh->quote($id)." and `user` = ".$dbh->quote($self->{user}{id}).";");
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
