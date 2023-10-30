package api;

use Carp qw(croak);
use utf8;
use strict;
use warnings;
use Encode;

sub new{
    my $pkg = shift;
    bless {
        CONF => shift,
        Handle => shift,
        query => shift,
        user => shift,
        dir => shift,
        option => shift
    },$pkg;
}

sub add{
    my $self = shift;
    my $print = "";
    
	if(defined $self->{query}{id} and defined $self->{query}{passwd}){
    	require $self->{dir}."/login.pl";
    	my $login = Login->new($self->{CONF},$self->{Handle},$self->{dir});
    	if($login->login($self->{query}{id},$self->{query}{passwd})){
    		#Login 成功
			$print .= '{"status": "success"}';
			require $self->{dir}."/add_item.pl";
			my $exe = Add_item->new($self->{Handle});
			if(!$self->{query}{url}){
				$self->{query}{url} = "upload form app";
			}
			if(!$self->{query}{title}){
				$self->{query}{title} = "upload form app";
			}
			$exe->add($self->{query}{id},$self->{query});
    	}
    	else{
    		#Login 失敗
			$print .= '{"status": "failure"}';
    	}
    }else{
		$print .= '{"status": "error", "code": 041}';
    }
	return $print;
}
1;
