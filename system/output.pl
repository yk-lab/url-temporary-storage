package Output;

use utf8;
use Encode;
use strict;
use warnings;
use DBI;
#use JSON;

use Carp qw(croak);

sub new{
  my $pkg = shift;
  bless {
    html_var => shift,
    option => shift
  },$pkg;
}

sub add_css_file{
  my $self = shift;
  my $css_url = shift;
  my $rel = shift;
  my $option = shift;
  if(!defined $rel or $rel eq ""){$rel = "stylesheet";}
  if(!defined $option or $option eq ""){$option = "";}
  if(lc $self->{html_var} eq "html5"){
    return qq|<link rel="$rel" href="$css_url" $option/>\n|;
  }
}

sub add_script_file{
  my $self = shift;
  my $js_url = shift;
  my $type = shift;
  my $char = shift;
  my $option = shift;
  if(!defined $type or $type eq ""){$type = "text/javascript";}
  if(!defined $char or $char eq ""){$char = "utf-8";}
  if(!defined $option or $option eq ""){$option = "";}
  if(lc $self->{html_var} eq "html5"){
    return qq|<script type="$type" charset="$char" src="$js_url" $option></script>\n|;
  }
}

sub html_s{
    my $self = shift;
    my $text = shift;
    my $Conf = shift;
    my $print = shift;
    my $dbh = shift;

    my @replace = qw|YYYY title css_file script_file css script head site_name site_description globalNav home_url main sidebar foot_script_file foot_script foot script_end|;
    
    my $replace;
    foreach(@replace){
        if(defined $print->{$_}){
            $replace->{$_} = "true";
        }else{
            $replace->{$_} = "false";
        }
    }
    
    my $html;
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

sub validation{
    my $self = shift;
    my $type = shift;
    my $print = shift;
    my $CONF = shift;
    
    if($type eq "HTML"){
	    if(!defined $print->{title}){
	        $print->{title} = $CONF->{SiteName};
	    }
    }
    
    my $Date = sub{
    	my ($day,$mon,$year) = (localtime(time))[3..5];
		$year += 1900;
		$mon += 1;
		return ($year, $mon, $day);
    };
    
    $print->{site_description} = $CONF->{site_description};
    ($print->{YYYY},$print->{M},$print->{D}) = $Date->();
    
    return $print;
}

sub html{
    my $self = shift;
    my $CONF = shift;
    my $html_file = shift;
    my $print = shift;
    my $dbh = shift;
    my ($HTML, $html);
    
    $print->{home_url} = $CONF->{home};
    $print->{site_name} = $CONF->{SiteName};
    
    $print = $self->validation("HTML",$print,$CONF);
    
    if(defined $print->{http_errCode} and $print->{http_errCode} ne ""){
        $html .= "Status: $print->{http_errCode}\n";
    }
    if(defined $print->{set_cookie} and $print->{set_cookie} ne ""){
        $html .= $print->{set_cookie};
    }
    $html .= "Content-type: text/html; charset=utf-8\n\n";
    if(!-f $html_file){return "Error:Not found Template HTML file.";}
    my $error = sub{close($HTML);return "Error: Connot read Template HTML file.";};
    open($HTML,"<:utf8",$html_file) or $error->();
    foreach (<$HTML>){
        $_ = $self->html_s($_,$CONF,$print,$dbh);
        $html .= $_;
    }
    close($HTML);
    return $html;
}

sub header_redirect{
    my $self = shift;
    my $print = shift;
    my $return = "";
    if(defined $print->{set_cookie} and $print->{set_cookie} ne ""){
        $return .= $print->{set_cookie};
    }
    if(defined $print->{http_errCode} and $print->{http_errCode} ne ""){
        $return .= "Status: $print->{http_errCode}\n";
    }
    $return .= "Location: ".$print->{header_redirect}."\n\n";
    return $return;
}

sub json{
    my $self = shift;
    my $json = shift;
	
    return "Content-type: application/json; charset=utf-8\n\n".$json;
}

sub Error{
    my $self = shift;
    my $CONF = shift;
    my $error_status = shift;
    my $error_code = shift;
    my $text = shift;
    my $Text;
    if(!$error_status){
        $error_status = 404;
    }
    print "Status: $error_status\n";
    if(-f $CONF->{install}{dir}."/system/html/err/".$error_code.".html"){
        my $HTML;
        open($HTML,'<:utf8',$CONF->{install}{dir}."/system/html/err/".$error_code.".html");
        $Text = do { local $/; <$HTML> };
        close($HTML);
    }
    else{
        if(!defined $text or $text eq ""){$text = ($error_status eq "404")?"Not found":($error_status eq "500")?"System Error":"";}
        $Text = "Error：".$text."![".$error_code."]";
    }
    return $Text;
}
1;
