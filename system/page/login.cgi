package Login_Page;

use Carp qw(croak);
use utf8;
use strict;
use warnings;
use Encode;

sub new{
    my $pkg = shift;
    bless {
        CONF => shift,
        html => shift,
        Handle => shift,
        query => shift,
        user => shift,
        dir => shift,
        option => shift
    },$pkg;
}

sub html_replace{
    my $self = shift;
    my $text = shift;
    my $print= shift;
    my @replace = qw||;
    my ($replace, $html);
    foreach(@replace){
        if(defined $print->{$_}){
            $replace->{$_} = "true";
        }else{
            $replace->{$_} = "false";
        }
    }
    foreach($text){
        while($_ =~ /<!--{(.*?)}-->/g){
            if(defined $replace->{$1} and $replace->{$1} eq "true"){
                my $p = $print->{$1};
                $_ =~ s/<!--{$1}-->/$p/;
            }
            elsif(defined $replace->{$1} and $replace->{$1} eq "false"){
                $_ =~ s/<!--{$1}-->//;
            }
        }
        $html .= $_;
    }
    return $html;
}

sub output{
    my $self = shift;
    my $dir = shift;
    my ($html, $HTML, $print, $cookie, $header);
    
    if(defined $self->{query}{id} and defined $self->{query}{passwd}){
    	require $self->{dir}."/login.pl";
    	my $login = Login->new($self->{CONF},$self->{Handle},$self->{dir});
    	if($login->login($self->{query}{id},$self->{query}{passwd})){
    		#Login ¬Œ÷
    		$cookie = $login->bake_cookie($self->{query}{id},$self->{user});
    		$header = "http://".$self->{CONF}{Domain}.$self->{CONF}{home};
    	}
    	else{
    		#Login Ž¸”s
    	}
    }
    if(!defined $header){
        if(!-f $self->{html}{form}){return "Error:Not found html file.\n";}
    	my $error = sub{close($HTML);return "Error:Cannot read html file.";};
	    open($HTML,"<:utf8",$self->{html}{form}) or $error->();
		foreach(<$HTML>){
	        $html .= $self->html_replace($_, $print);
	    }
	    close($HTML);
	    return "html",$html;
	}
	else{
		return "redirect",$header,$cookie
	}
}
1;
