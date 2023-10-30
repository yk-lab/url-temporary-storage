#!/usr/bin/perl

#BEGIN{$|=1;print"Content-type:text/html\n\n";open(STDERR,">&STDOUT");}

#-d:NYTProf

use utf8;
use strict;
use warnings;
use Encode;
use DBI;
#use JSON;
use CGI;

#=============================================================================#
#                                                                             #
#       以下変更の必要がある場合のみ変更してください                          #
#                                                                             #
	my $CONF;
		$CONF->{Domain} = "localhost";
		$CONF->{home} = "/";
		$CONF->{SiteName} ="パソコン・スマホＵＲＬ共有";
		$CONF->{site_description} = "異なる機器の間でのＵＲＬのやり取りをサポートします！";
	
	my $SQL;
		$SQL->{srv_host} = "db.local";
		$SQL->{usr_name} = "user";
		$SQL->{password} = "password";
		$SQL->{db_name}  = "db_name";
	my $TABLE;
		$TABLE->{user} = "user";
		$TABLE->{item} = "item";
		$TABLE->{session} = "session";
		$TABLE->{login} = "login";
	my $DIR;
		$DIR->{system} = "./system";
		$DIR->{log_login} = "./log";
		$DIR->{log_debug} = "./log_debug";

	my $is_debug = 0; #on:1 off:0
	my $debug_log = 0; #on:1 off:0 （前提：$is_debug = 1）
#                                                                             #
#       ここまで                                                               #
#                                                                             #
#=============================================================================#

###
###    以下はむやみにいじらないこと
###

#BEGIN{$|=1;print"Content-type:text/html\n\n";open(STDERR,">&STDOUT");}
my $process;
if($is_debug){
	#BEGIN{$|=1;print"Content-type:text/html\n\n";open(STDERR,">&STDOUT");}
	use Time::HiRes;
	$process->{start} = Time::HiRes::time;
}

require $DIR->{system}."/cookie.pm";
my $Cookie = Cookie->new();

sub url_encode($){my $str=shift;$str=~s/([^\w ])/'%'.unpack('H2', $1)/eg;$str =~ tr/ /+/;return $str;}
sub url_decode($){my $str=shift;$str=~tr/\+/ /;$str=~s/%([0-9A-Fa-f][0-9A-Fa-f])/pack('H2', $1)/eg;return $str;}
sub Post_Query{my %QUERY;read(STDIN, my $QUERY, $ENV{'CONTENT_LENGTH'});foreach(split(/&/, $QUERY)){my ($Name, $Value)=split(/=/, $_);my $name=lc("$Name");$Value=url_decode("$Value");$Value =~ s/\t//g;utf8::decode($Value = $Value);$QUERY{"$name"} = $Value;}return(%QUERY);}

require($DIR->{system}."/get.pl");

my $get_host = sub{
    my $ip = shift;
    if(!defined $ip){
        $ip = $ENV{'REMOTE_ADDR'};
    }
    my $host = $ENV{'REMOTE_HOST'};
    if(!defined $host || $host eq $ip){
        $host = gethostbyaddr(pack("C4",split(/\./,$ip)),2) || $ip;
    }
    return $host;
};

my $user;
$user->{ip} = $ENV{'REMOTE_ADDR'};
$user->{host} = $get_host->($user->{ip});
$user->{UA} = $ENV{'HTTP_USER_AGENT'};
$user->{os} = Get->OS($user->{UA});
$user->{browser} = Get->Browser($user->{UA});
$user->{request}{url} = $ENV{'REQUEST_URI'};

require $DIR->{system}."/output.pl";
my $output = Output->new("html5");
my $print;
$print->{css_file}    .= $output->add_css_file("http://yui.yahooapis.com/3.14.1/build/cssreset/cssreset-min.css");
$print->{css_file}    .= $output->add_css_file($CONF->{home}."css/common.css");
$print->{css_file}    .= $output->add_css_file($CONF->{home}."css/whhg.css");
$print->{script_file} .= $output->add_script_file($CONF->{home}."js/jquery-1.11.0.min.js");

my $dbh;
$dbh = DBI->connect('DBI:mysql:'.$SQL->{db_name}.':'.$SQL->{srv_host}, $SQL->{usr_name}, $SQL->{password}
	,{RaiseError => 1, PrintError => 0, AutoCommit => 0 });

use CGI::Cookie;
{
#    use CGI::Session('-ip_match');
    use CGI::Session;
    my %cookies = fetch CGI::Cookie;
    my $sid = ($cookies{'sid'})?$cookies{'sid'}->value:undef;
    my $session = new CGI::Session("driver:MySQL", $sid, {Handle=>$dbh});
    $sid = $session->id();
    $user->{session} = $sid;
    $user->{id} = $session->param('user_id');
    $session->expire("+1d");
    my $expires=$Cookie->makeexpiresdate("1");
    $print->{set_cookie}.=qq|Set-Cookie: sid=$sid; expires=$expires; domain=$CONF->{Domain}; path=$CONF->{home};\n|;
    $session->close();
}

if(defined $user->{id}){
	$print->{globalNav}  = qq|<li><a href="<!--{home_url}-->"><i class="icon-home"></i>Home</a></li>\n|;
	$print->{globalNav} .= qq|<li><a href="<!--{home_url}-->setting/"><i class="icon-settingsthree-gears"></i>設定</a></li>\n|;
	$print->{globalNav} .= qq|<li><a href="<!--{home_url}-->help/"><i class="icon-question-sign"></i>ヘルプ</a></li>\n|;
}
else{
	$print->{globalNav}  = qq|<li><a href="<!--{home_url}-->"><i class="icon-home"></i>Home</a></li>\n|;
	$print->{globalNav} .= qq|<li><a href="<!--{home_url}-->login/">ログイン</a></li>\n|;
	$print->{globalNav} .= qq|<li><a href="<!--{home_url}-->signup/">新規登録</a></li>\n|;
}

my $request = $ENV{'REQUEST_URI'};
my %request;
if($request =~ /(.*?)\?(.*)$/){
	$request{dir} = $1;
    $request{query} = "?".$2;
}else{
	$request{dir} = $request;
    $request{query} = "";
}

my $flag = 0;

if($request{dir} =~ m|^/api/.*|i or $request{dir} =~ m|^/api&|i){
	if($request{dir} =~ m|^/api/add/.*|i or $request{dir} =~ m|^/api/add|i){
		my $q = new CGI;
		my %query = (id => $q->param('id'), passwd => $q->param('passwd'), url => $q->param('url'), title => $q->param('title'));
		require $DIR->{system}."/page/api.cgi";
		my $view = api->new($CONF,$dbh,\%query,$user,$DIR->{system});
	    $print->{json} = $view->add();
	}
	$flag = 1;
}

if(!$flag && defined $user->{id}){
	if($request{dir} eq "/" or $request{dir} eq ""){
		require $DIR->{system}."/page/main.cgi";
		my %query = Post_Query();
		my $view = main->new($CONF,$dbh,\%query,$user,$DIR->{system});
		$print->{main} = $view->output();
	}
	elsif($request{dir} =~ m|^/open/.*|i or $request{dir} =~ m|^/open$|i){
		require $DIR->{system}."/get_item_info.pl";
		my $info = Get_item_info->new($CONF,$dbh,$user,$DIR->{system});
		if($request{query} =~ /[\?&]n=(\d+)/){
			if($info->right($1)){
				$print->{header_redirect} = $info->url($1);
				require $DIR->{system}."/switch_item_status.pl";
				my $switch = Switch_item_status->new($CONF,$dbh,$user,$DIR->{system});
				$switch->read($1);
			}
			else{
				
			}
		}
	}
	elsif($request{dir} =~ m|^/login/.*|i or $request{dir} =~ m|^/login$|i){
	#    require $Conf->{install}{dir}."/system/admin.cgi";
	#    my $view = TOP_Page->new($Conf,$Conf->{install}{dir}."/system/html/toppage.html",$dbh);
	#    $print->{main} = $view->output();
	}
	elsif($request{dir} =~ m|^/signup/.*|i or $request{dir} =~ m|^/signup$|i){
	#    require $Conf->{install}{dir}."/system/admin.cgi";
	#    my $view = TOP_Page->new($Conf,$Conf->{install}{dir}."/system/html/toppage.html",$dbh);
	#    $print->{main} = $view->output();
	}
	else{
	#    print encode("UTF-8",$output->error($CONF,"404","404","Not Found"));
	}
}
elsif(!$flag && !defined $user->{id}){
	if($request{dir} eq "/" or $request{dir} eq ""){
		require $DIR->{system}."/page/topPage.cgi";
		my $view = TOP_Page->new($CONF,$DIR->{system}."/html/toppage.html",$dbh);
		$print->{main} = $view->output();
	}
	elsif($request{dir} =~ m|^/login/.*|i or $request{dir} =~ m|^/login$|i){
		$print->{title} = "ログイン-".$CONF->{SiteName};
		$print->{script_file} .= $output->add_script_file($CONF->{home}."js/gridforms.js");
		require $DIR->{system}."/page/login.cgi";
		my %query = Post_Query();
		my $view = Login_Page->new($CONF,{form => $DIR->{system}."/html/login.html"},$dbh,\%query,$user,$DIR->{system});
		my @login = $view->output();
		if($login[0] eq "html"){
		    $print->{main} = $login[1];
		}
		elsif($login[0] eq "redirect"){
			$user->{id} = $query{id};
		    $print->{header_redirect} = $login[1];
		    $print->{set_cookie}.=$login[2];
		}
	}
	elsif($request{dir} =~ m|^/signup/.*|i or $request{dir} =~ m|^/signup$|i){
		$print->{title} = "アカウントの新規作成-".$CONF->{SiteName};
		$print->{script_file} .= $output->add_script_file($CONF->{home}."js/gridforms.js");
		require $DIR->{system}."/page/signup.cgi";
		my $view = Signup_Page->new($CONF,{form => $DIR->{system}."/html/signup.html"},$dbh);
		my %query = Post_Query();
		$print->{main} = $view->output(\%query);
	}
	elsif($request{dir} =~ m|^/open/.*|i or $request{dir} =~ m|^/open$|i){
	}
	else{
	#    print encode("UTF-8",$output->error($CONF,"404","404","Not Found"));
	}
}


if(defined $print->{header_redirect}){
    print encode("UTF-8",$output->header_redirect($print));
}
elsif(defined $print->{json}){
    print encode("UTF-8",$output->json($print->{json}));
}
else{
    my $template_html = $DIR->{system}."/html/temp.html";
    print encode("UTF-8",$output->html($CONF, $template_html, $print, $dbh));
}

$dbh->disconnect;

if($is_debug){
	$process->{end} = Time::HiRes::time;
	$process->{time} = $process->{end} - $process->{start};
	$process->{time} = int($process->{time}*1000000);
	$process->{time} = $process->{time}/1000000;
	print "<p>".$process->{time}."</p>";
}

exit;
