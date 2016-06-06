#!/usr/bin/perl -w
use LWP::UserAgent;
use Crypt::SSLeay; 

use URI::URL;
use HTTP::Request;
use HTTP::Request::Common;

#$ENV{'HTTPS_PROXY'} = 'http://172.16.1.18:8080'; 

my $ua = LWP::UserAgent->new;

my $tel          = $ARGV[0];
my  $amt         = $ARGV[1];
my  $user        = "RKC1";
my  $pwd         = "TJqoe83jq19";
my  $branch      = "Test_branch";
#my  $src_type    = $ARGV[2];
my  $trade_point = "Test_point";
my  $src_type    = "4";

#‘®§¤ ­ЁҐ БЮ ­§ ЄФЁЁ Ї« БҐ¦ 

my $url = url "https://212.13.155.29:8443/work.html?USERNAME=$user&PASSWORD=$pwd&ACT=0&MSISDN=$tel&PAY_AMOUNT=$amt&BRANCH=$branch&SOURCE_TYPE=$src_type&TRADE_POINT=$trade_point";

my $res = $ua->request(GET $url);
if ($res->is_success) {
    print $res->content  ;
    print " \n" ;
} else {
    print "Error: Request Fail \n";
}  
