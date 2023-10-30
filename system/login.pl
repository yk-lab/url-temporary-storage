package Login;

use Carp qw(croak);
use utf8;
use strict;
use warnings;
use Encode;
use DBI;
use CGI::Cookie;
use CGI::Session;

sub new{
    my $pkg = shift;
    bless {
        CONF => shift,
        Handle => shift,
        dir => shift,
        option => shift
    },$pkg;
}

sub is_exist{
	my $self = shift;
	my $arg  = shift;
	
	if(!defined $arg){
		die;
	}
	
	my $dbh = $self->{Handle};
	my $sth = $dbh->prepare("select `mailAddr` from `users` where `mailAddr` = ".$dbh->quote($arg).";");
	$sth->execute;
	my $row = $sth->rows;
	$sth->finish;
	if($row == 0){
		return 0;
	}
	else{
		return 1;
	}
	die;
}

sub login{
	my $self = shift;
	my $id = shift;
	my $passwd = shift;
	
	if(!defined $id or !defined $passwd){
		die;
	}
	
	my $dbh = $self->{Handle};
	my $sth = $dbh->prepare("select `mailAddr` from `users` where `mailAddr` = ".$dbh->quote($id)." and `password` = ".$dbh->quote($passwd).";");
	$sth->execute;
	my $row = $sth->rows;
	$sth->finish;
	if($row == 1){
		return 1;
	}
	else{
		return 0;
	}
	
	return 0;
}

sub bake_cookie{
	my $self = shift;
	my $id = shift;
	my $user = shift;
	
	require $self->{dir}."/cookie.pm";
	my $Cookie = Cookie->new();
	
    my $session = new CGI::Session("driver:MySQL", $user->{session}, {Handle=>$self->{Handle}});
    $session->param('user_id',$id);
    $session->expire("+1d");
    my $expires=$Cookie->makeexpiresdate("1");
    $session->close();
    return  qq|Set-Cookie: sid=$user->{session}; expires=$expires; domain=$self->{CONF}{Domain}; path=$self->{CONF}{home};\n|;
}
1;
