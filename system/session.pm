package mysession;

use Carp qw(croak);
use DBI;

sub new{
  my $pkg = shift;
  bless {
    db => lc(shift),
    id => shift,
    match => shift,
    option => shift
  },$pkg;
}

sub mysql{
  my $self = shift;
  my $exe_option = shift;
  $self->{option}{table_name} = ($self->{option}{table_name})?$self->{option}{table_name}:"session";
  if($exe_option eq "get-id_info"){
    my $sth = $self->{option}{Handle}->prepare("select `data` from `".$self->{option}{table_name}."` where `id`=".$self->{option}{Handle}->quote($self->{id})." and `expires`>=".$self->{option}{Handle}->quote(time()).";");
    $sth->execute;
    my $d = $sth->fetchrow_array();
    $sth->finish;
    ($d,undef) = split /\;/,$d;
    if($d =~ /\{(.*?)\}/){
      foreach(split(/\,/,$1)){
        my($name,$value)=split(/\=\>/,$_);
        if($name =~ /'(.*?)'/){$name = $1;}
        if($value =~ /'(.*?)'/){$value = $1;}
        $name =~ s/[^a-zA-Z0-9\_]//g;
        $data->{$name} = $value;
      }
    }
    return $data;
  }
  elsif($exe_option eq "create-id"){
    my $dbh = $self->{option}{Handle};
    my $sth = $dbh->prepare("INSERT INTO `".$self->{option}{table_name}."` (`id`, `data`) VALUES (".$dbh->quote($self->{id}).", "..");");
    $sth->execute;
    $sth->finish;
  }
  elsif($exe_option eq "existence-check"){
    use DBI;
    my $sth = $self->{option}{Handle}->prepare("select `id` from `".$self->{option}{table_name}."` where `id`=".$self->{option}{Handle}->quote($self->{id}).";");
    $sth->execute;
    my $row = $sth->rows;
    $sth->finish;
    if($row > 0){
      return 1;
    }
    else{
      return 0;
    }
  }
}

sub file{
}

sub create_id{
  my @ele = ('a'..'z','0'..'9');
  $self->{id}="";
  foreach(0..9){
    $self->{id} .= $ele[int(rand(scalar @ele))];
  }
  @ele = ('');
  return $self->{id};
}

sub id{
  my $self = shift;
  if($self->{id} and $self->{id} ne ""){
    if($self->{db} eq "mysql"){
      $self->{id_data} = $self->mysql("get-id_info");
    }
    else{
      $self->file("get-id_info");
    }
  }
  if(!$self->{carrier} or $self->{carrier} eq ""){
    my $host = gethostbyaddr(pack("C4", split('\.', $ENV{'REMOTE_ADDR'})), 2);
    if($ENV{'HTTP_USER_AGENT'}=~/^DoCoMo/){$self->{carrier}="docomo";}
    elsif($ENV{'HTTP_USER_AGENT'}=~/^J-PHONE|^Vodafone|^SoftBank/){$self->{carrier}="au";}
    elsif($ENV{'HTTP_USER_AGENT'}=~/^UP.Browser|^KDDI/){$self->{carrier}="sb";}
    elsif($host =~ /\.?spmode\.ne\.jp$/i){$self->{carrier}="docomo";}
    else{$self->{carrier}="";}
  }
  if($self->{id} and $self->{id} ne "" and !$self->{match} or $self->{match} eq "none"){
    $self->{create_flag} = 0;
  }
  elsif($self->{id} and $self->{id} ne "" and $self->{match} eq "ip||carrier" and $self->{id_data}{_ip} eq $ENV{'REMOTE_ADDR'} or ($self->{id_data}{_carrier} and $self->{id_data}{_carrier} eq $self->{carrier})){
    $self->{create_flag} = 0;
  }
  elsif($self->{id} and $self->{id} ne "" and $self->{match} eq "ip||guid" and $self->{id_data}{_ip} eq $ENV{'REMOTE_ADDR'} or ($self->{id_data}{_guid} and $self->{id_data}{_guid} eq $self->{guid})){
    $self->{create_flag} = 0;
  }
  else{
    $self->{create_flag} = 1;
  }
  if($self->{create_flag}){
    do{
      $self->{id} = $self->create_id();
    }while($self->mysql("existence-check"));
  }
  $self->save();
  return $self->{id};
#  return $self->{id_data}{_ip};
}

sub save{
  my $self = shift;
  if($self->{db} eq "mysql"){
    use DBI;
    $self->{option}{table_name} = ($self->{option}{table_name})?$self->{option}{table_name}:"session";
    $self->{id_info}{extension} = "{'_ip' => '".$ENV{'REMOTE_ADDR'}."','_carrier' => '".$self->{carrier}."','_lastTime' => '".time()."'}";
#    $self->{id_info}{extension} = {'_ip' => $ENV{'REMOTE_ADDR'},'_carrier' => $self->{carrier},'_lastTime' => time()};
    my $dbh = $self->{option}{Handle};
    my $sth = $dbh->prepare("REPLACE INTO `".$self->{option}{table_name}."` (`id`,`expires`,`data`) VALUES (".$self->{option}{Handle}->quote($self->{id}).",".$dbh->quote($self->{expireTime}).",".$dbh->quote($self->{id_info}{extension}).");");
    $sth->execute;
    $sth->finish;
    return 1;
  }else{
    return "$self->{db}";
  }
}

sub expire{
  my $self = shift;
  my $_ETime = shift;
  my %_map = (
    s => 1,
    m => 60,
    h => 3600,
    d => 86400,
    w => 604800,
    M => 2592000,
    y => 31536000
  );
  if($_ETime =~ m/^[+-]?\d+$/){
    $self->{expireTime} = time()+$_ETime;
  }
  else{
    my ($koef, $d) = $_ETime =~ m/^([+-]?\d+)([smhdwMy])$/;
    unless ( defined($koef) && defined($d) ) {
      die "";
    }else{
      $self->{expireTime} = time()+($koef * $_map{ $d });
    }
  }
  $self->save();
}

sub close{
  my $self = shift;
  $self="";
}

1;
