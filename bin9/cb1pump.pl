#!/usr/bin/perl -w

# script for data upload to First Credit Bureau
# author: 11/05/2007 madiyar

# synopsis:
# cb1pump.pl [-debug] -login=my_login -password=my_password -method=GetBatchStatus2 -batchid=3477
# cb1pump.pl [-zip] [-debug] -login=my_login -password=my_password -method=UploadZippedData2 -file2send=kred.zip

# changes:
# 15/05/2007 madiyar - new [-zip] option for compressing outgoing xml-file
#                      both methods return not the raw xml, but processed "parameter=value" data
# 23/05/2007 madiyar - now, if -zip option is used, .zip extension is not just appended at the end of the filename, but replaces the original extension
# 13/09/2007 madiyar - UploadZippedData2 returns raw xml
# 24/10/2007 madiyar - UploadZippedData2 - schemaId = 3
# 09/04/2013 madiyar - UploadZippedData2 gets schemaId as a parameter

use Getopt::Long;
my $optres = GetOptions (
                         "debug" => \$debug,
                         "zip" => \$add2zip,
                         "login=s" => \$login,
                         "password=s" => \$password,
                         "method=s" => \$method,
                         "batchid=i" => \$batchid,
                         "schid=i" => \$schid,
                         "file2send=s" => \$file2send
                        );

if ($debug) {
    eval "use SOAP::Lite +trace => 'debug';";
} else {
    eval "use SOAP::Lite;";
}

use Archive::Zip qw(:ERROR_CODES :CONSTANTS);

my $serviceNs = "https://ws.creditinfo.com";
my $serviceUrl = "https://secure.1cb.kz/WebService/DataPump/DataPumpService.asmx";

# foreach (@ARGV)
# {
#     /\.(\w+)(?:=(.*))?/;
#     if( defined $1) { ${$1} = ($2) ? $2 : 1; }
# }

if( !defined $method )
{
    &err_msg("method not defined... exiting\n");
}
elsif( ( $method ne "GetBatchStatus2" ) and ( $method ne "UploadZippedData2" ) )
{
    &err_msg("unknown method ... exiting\n");
}

if( !defined $login || !defined $password )
{
    &err_msg("cannot access service: missing username or password ... exiting\n");
}

my $buffer;

# check parameters

if( $method eq "UploadZippedData2" )
{
    if( !defined $schid )
    {
        &err_msg("UploadZippedData2: missing SchemaID ... exiting\n");
    }

	if( !defined $file2send )
    {
        &err_msg("UploadZippedData2: xml-file or zip-file is not specified ... exiting\n");
    }
    else
    {
        if ($add2zip)
        {
            $_ = $file2send;
            s/(\.\w+)?$/.zip/;
            my $zipName = $_;
            my $zip = Archive::Zip->new();
            my $member = $zip->addFile( $file2send ) or &err_msg("UploadZippedData2: could not add file to zip-archive ... exiting\n");
            # $member->desiredCompressionMethod( COMPRESSION_DEFLATED );
            # $member->desiredCompressionLevel( 9 );
            err_msg("UploadZippedData2: zip-archive write error ... exiting\n") unless $zip->writeToFileNamed($zipName) == AZ_OK;
            $file2send = $zipName;
        }
        
        open(my_handle, $file2send) || &err_msg("UploadZippedData2: could not open file for sending ... exiting\n");
        binmode my_handle;
        
        $size = -s $file2send;
        read(my_handle,$buffer,$size);
        close my_handle or &err_msg("UploadZippedData2: can't close file for sending ($!) ... exiting\n");
    }
}
elsif( $method eq "GetBatchStatus2" )
{
    if( !defined $batchid || $batchid eq '' )
    {
        &err_msg("GetBatchStatus2: batch id not specified ... exiting\n");
    }
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



# prepare data elements and initialize soap object

my $data1;
my $data2;

my $soap = SOAP::Lite
        ->proxy($serviceUrl,proxy=>["https"=>"http://172.16.2.4:3128"])
        ->uri($serviceNs)
        ->on_action(sub{join '/', @_})
        ->outputxml(1);

if( $method eq "UploadZippedData2" )
{
    $data1 = SOAP::Data->name("m:zippedXML" => $buffer);
    $data2 = SOAP::Data->name("m:schemaId" => $schid);
}
elsif( $method eq "GetBatchStatus2" )
{
    $data1 = SOAP::Data->name("m:batchId" => $batchid);
}


# execute soap action

my $mres = $soap->call( SOAP::Data->name("m:$method")->attr({'xmlns:m' => $serviceNs}) => $my_header,$data1,$data2 );


# print result

print $mres . "\n";


sub err_msg
{
  my $msg = shift;
  print "$msg";
  exit( -1);
}
