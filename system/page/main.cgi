package main;

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
    my ($html, $HTML, $print);
    
    if($self->{query}{mode} eq "add"){
    	require $self->{dir}."/add_item.pl";
    	my $exe = Add_item->new($self->{Handle});
    	$exe->add($self->{user}{id},$self->{query});
    }
    
    require $self->{dir}."/get_item_list.pl";
    my $get = Get_item_list->new($self->{CONF},$self->{Handle});
    
    $html = qq|<form method="post">|;
    $html .= qq|タイトル：<input type="text" name="title"/><br/>|;
    $html .= qq|ＵＲＬ：<input type="text" name="url"/><br/>|;
    $html .= qq|<button type="submit" name="mode" value="add">追加</button>|;
    $html .= qq|</form>|;
    
    my $list = $get->unread($self->{user}{id},"desc");
    $html .= "<ul>";
    foreach(@$list){
        $html .= qq|<li><a href="$self->{CONF}{home}open?n=$_->{id}" title="$_->{url}" target="_blank">$_->{title}</a></li>\n|;
    }
    $html .= "</ul>";
    
	return $html;
}
1;
