#!/usr/bin/perl -w

# First Credit Bureau front office (for getting reports)
# author: 11/05/2007 madiyar

# synopsis:
# cb1rep.pl [-debug] -login=my_login -password=my_password -method=GetAvailableReportsForId -rnn=111111111111
# cb1rep.pl [-debug] -login=my_login -password=my_password -method=GetReport -rnn=111111111111 -reportid=200000

# changes:
# 15/05/2007 madiyar - "GetAvailableReportsForId" returns not the raw xml, but extracted data (few lines with "reportid^importcode^reportname" format)

use Encode;
# use Data::Dumper;
use Getopt::Long;
my $optres = GetOptions (
                         "debug" => \$debug,
                         "login=s" => \$login,
                         "password=s" => \$password,
                         "method=s" => \$method,
                         "rnn=s" => \$rnn,
                         "reportid=i" => \$reportid
                        );

# use SOAP::Lite +trace ;

if ($debug) {
    eval "use SOAP::Lite +trace => 'debug' ;";
} else {
    eval "use SOAP::Lite ;";
}

#my $serviceNs = "http://ws.creditinfo.com/";
#my $serviceUrl = "http://www-test2.1cb.kz/WebServiceFCB/Service.asmx";

my $serviceNs = "http://ws.creditinfo.com/";
my $serviceUrl = "https://secure.1cb.kz/WebServiceFCB/Service.asmx";

#my $serviceNs = "http://ws.creditinfo.com/";
#my $serviceUrl = "https://secure.1cb.kz/WebService/Service.asmx";

# foreach (@ARGV)
# {
#     /\.(\w+)(?:=(.*))?/;
#     if( defined $1) { ${$1} = ($2) ? $2 : 1; }
# }

if( !defined $method )
{
    &err_msg("method not defined... exiting \n");
}
elsif( ( $method ne "GetAvailableReportsForId" ) and ( $method ne "GetReport" ) )
{
    print $method . "\n";
	&err_msg("unknown method ... exiting \n");
}

if( !defined $login || !defined $password )
{
    &err_msg("cannot access service: missing username or password ... exiting\n");
}

# prepare header elements

my $my_header = SOAP::Header->name("m:CigWsHeader" => \SOAP::Header->value(
                                                                    SOAP::Header->name("m:UserName" => $login),
                                                                    SOAP::Header->name("m:Password" => $password),
                                                                    SOAP::Header->name("m:Version" => '1_0'),
                                                                    SOAP::Header->name("m:Culture" => 'ru-RU'),
                                                                    SOAP::Header->name("m:SecurityToken" => ''),
                                                                    SOAP::Header->name("m:UserId" => '0')
                                                                        )
                                  )->attr({'xmlns:m' => $serviceNs});


# check parameters and prepare data elements

if( !defined $rnn )
{
    &err_msg("$method: RNN not specified ... exiting\n");
}

my $data1;
my $data2;

if( $method eq "GetAvailableReportsForId" )
{
    $data1 = SOAP::Data->name("m:idNumber" => $rnn);
    $data2 = SOAP::Data->name("m:xmlParams" => \SOAP::Data->value(
                                                                  SOAP::Data->name("keyValue" => \SOAP::Data->value(
                                                                                                                    SOAP::Data->name("idTypeImportCode" => "1")
                                                                                                                    # SOAP::Data->name("idTypeExportCode" => "Entity.Identification.Type.Rnn")
                                                                                                                    # SOAP::Data->name("idType" => "130")
                                                                                                                   )
                                                                                  )
                                                                 )
                             );
}
elsif( $method eq "GetReport" )
{
	
    if( !defined $reportid || $reportid eq '' )
    {
        &err_msg("GetReport: report id not specified ... exiting\n");
    }
    else
    {

        $data1 = SOAP::Data->name("m:reportId" => $reportid);
        $data2 = SOAP::Data->name("m:doc" => \SOAP::Data->value(
                     SOAP::Data->name("keyValue" => \SOAP::Data->value(
   		          	    SOAP::Data->name("reportImportCode" => "4"),
                        SOAP::Data->name("idNumber" => $rnn),
                        SOAP::Data->name("idNumberType" => "14"),
                        SOAP::Data->name("ConsentConfirmed" => "1")
                     )
                                                                                )
                                                               )
                                 );
    }
}


# initialize soap object

my $soap = SOAP::Lite
        ->uri($serviceNs)
        ->proxy($serviceUrl,proxy => [ "https" => "http://172.16.2.4:3128"] )
        ->on_action(sub{join '', @_});

if( $method eq "GetReport" )
{
	$soap->outputxml(1);
}    

# execute soap action

my $mres = $soap->call( SOAP::Data->name("m:$method")->attr({'xmlns:m' => $serviceNs}) => $my_header,$data1,$data2 );

#print $mres . "\n";

# print result

# print Dumper($mres->result);


#unless ($mres->fault)
#{
    if( $method eq "GetAvailableReportsForId" )
    {
        for my $tt ($mres->dataof('//CigResult/Result/EntitiesAndReports/Entity/Reports/Report'))
        {
            print $tt->attr->{'id'} . "^" . $tt->attr->{'importcode'} . "^" . Encode::encode( 'koi8-r', $tt->attr->{'name'} ) . "\n";
        }
    }
    elsif( $method eq "GetReport" )
    {
        print $mres . "\n";
    }
#}
#else
#{
#    print join "=",
#          "FaultCode", $mres->faultcode() . "\n" .
#          "FaultString", $mres->faultstring() . "\n" .
#          "TransportStatus", $soap->transport()->status() . "\n";
#}






sub err_msg
{
  my $msg = shift;
  print "$msg";
  exit( -1);
}
