package Get;

use utf8;
use strict;
use warnings;

sub Browser{
    my $self = shift;
    my ($ua, $unknown) = shift, shift;
    if(!defined $ua){$ua = $ENV{'HTTP_USER_AGENT'};}
    if(!defined $unknown){$unknown = "Unknown";}
    my $browser;
    if($ua =~ /Nintendo 3DS/){
        $browser = "Nintendo 3DS NetFront Browser";
    }
    elsif($ua =~ /Opera/){
        $ua =~ /Version\/([\d.]+)/;
        $browser = "Opera $1";
    }
    elsif($ua =~ /MSIE/){
        $ua =~ /MSIE ([\d.]+)/;
        $browser = "IE $1";
    }
    elsif($ua =~ /Chrome/){
        $ua =~ /Chrome\/([\d]+)\.([\d]+)/;
        $browser = "Chrome $1.$2";
    }
    elsif($ua =~ /Safari/ and $ua =~ /Mobile/){
        $ua =~ /Version\/([\d]+)\.([\d]+)/;
        $browser = "Safari Mobile $1.$2";
    }
    elsif($ua =~ /Safari/){
        $ua =~ /Version\/([\d]+)\.([\d]+)/;
        $browser = "Safari $1.$2";
    }
    elsif($ua =~ /Firefox/){
        $ua =~ /Firefox\/([\d.]+)/;
        $browser = "Firefox $1";
    }
    elsif($ua =~ /gecko/i){
        $browser = "gecko";
    }
    else{
        $browser = $unknown;
    }
    return $browser;
}

sub OS{
    my $self = shift;
    my ($ua, $unknown) = shift, shift;
    if(!defined $ua){$ua = $ENV{'HTTP_USER_AGENT'};}
    if(!defined $unknown){$unknown = "Unknown";}
    my $Error = $main::Error;
    my $errorFlag;
    my $os;
    if($ua =~ /Windows/){
        if($ua =~ /Windows NT 5.0/){$os = "Windows 2000";}
        elsif($ua =~ /Windows NT 5.1/){$os = "Windows XP";}
        elsif($ua =~ /Windows NT 5.2/){$os = "Windows XP";}
        elsif($ua =~ /Windows NT 6.0/){$os = "Windows Vista";}
        elsif($ua =~ /Windows NT 6.1/){$os = "Windows 7";}
        elsif($ua =~ /Windows NT 6.2/){$os = "Windows 8";}
        elsif($ua =~ /Windows NT 6.3/){$os = "Windows 8.1";}
        else{$os = "Windows";}
    }
    elsif($ua =~ /iPhone/){
        $ua =~ /iPhone OS ([\d_]+)/;
        my $ver = $1;
        $ver =~ s/_/\./g;
        $os = "iPhone OS $ver";
    }
    elsif($ua =~ /Mac OS X/){
        $ua =~ /Mac OS X ([\d]+)\_([\d]+)/;
        $os = "Mac OS X $1.$2";
    }
    elsif($ua =~ /Google Web Preview/){
        $os = "Google Web Preview";
    }
    elsif($ua =~ /Android/){
        $ua =~ /Android ([\d]+)\.([\d]+)/;
        $os = "Android $1.$2";
    }
    elsif($ua =~ /Nintendo 3DS/){
        $os = "Nintendo 3DS";
    }
    else{
        $os = $unknown;
    }
    return $os;
}
1;