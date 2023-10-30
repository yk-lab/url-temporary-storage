package Get_item_list;

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
        option => shift
    },$pkg;
}

sub unread{
	my $self = shift;
	my $id = shift;
	my $option = shift;
	my $list;
	
	my $order;
	if($option eq "desc"){
		$order = " ORDER BY `time` desc";
	}
	
	my $dbh = $self->{Handle};
    
#    eval{
		my $sth = $dbh->prepare("select `id`,`title`,`url` from `items` where `user` = ".$dbh->quote($id)." and `status` = 'unread'".$order.";");
        my $rv = $sth->execute();
        my $rows = $sth->rows;
        if($rows > 0){
            while (my $_ = $sth->fetchrow_hashref()){
                $_->{title} = Encode::decode('UTF-8',$_->{title});
                push @$list, $_;
            }
        }
        $sth->finish();
#    };
	
	return $list;
}
1;
