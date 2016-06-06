#!/usr/bin/perl -w
use LWP::UserAgent;
use Crypt::SSLeay; 

use URI::URL;
use HTTP::Request;
use HTTP::Request::Common;

#$ENV{'HTTPS_PROXY'} = 'http://192.168.1.13:3128'; 

my $ua = LWP::UserAgent->new;

my $payid         = $ARGV[0];

my  $user        = "3RKC1";
my  $pwd         = "TJqoe83jq19";

#‘®§¤ ­ЁҐ БЮ ­§ ЄФЁЁ Ї« БҐ¦ 

my $url = url "https://212.13.155.29:8443/work.html?USERNAME=$user&PASSWORD=$pwd&ACT=1&PAY_ID=$payid";

my $res = $ua->request(GET $url);
if ($res->is_success) {
    print $res->content;
    print " \n" ;
} else {
    print "Error: Request Fail \n";
}  
