#!/usr/bin/perl
# 09/03/2006 madiar - скрипт для листинга/отправки/получения файлов по ftp
# Synopsis:
#   ftpw.pl --method=[list] --host=[host] --login=[login] --password=[password] --dir=[dir]
#   ftpw.pl --method=[get/put] --host=[host] --login=[login] --password=[password] --source_file=[filename] --target_file=[file_name]
#   ftpw.pl --method=[del] --host=[host] --login=[login] --password=[password] --file=[filename]
#
# Changes:
# 12/04/2006 madiar - добавилась опция для удаления файлов
#

use Net::FTP;

# my $method = shift;
# my $host = shift;
# my $login = shift;
# my $password = shift;
# my $source_file = shift;
# my $target_file = shift;
# my $dir = shift;

foreach (@ARGV)
{
    /--(\w+)(?:=(.*))?/;
    ${$1} = ($2) ? $2 : 1;
}

my $ftp = Net::FTP->new($host);
$ftp->login($login, $password);

if( !defined $ftp )
{
   # print "could not login ... exiting\n";
   exit( -1);
}

my $t = "";

if( $method eq "put" )
{
   if( -f $source_file )
   {
      $t = $ftp->put( "$source_file", "$target_file");
      if( $t ne $target_file )
      {
         &err_msg("nothing copied ... exiting\n");
      }
   }
   else
   {
      &err_msg("file $source_file not found ... exiting\n");
   }
}
elsif( $method eq "get" )
{
   $t = $ftp->get( "$source_file",  "$target_file");
   if( $t ne $target_file )
   {
      &err_msg("nothing copied ... exiting\n");
   }
}
elsif( $method eq "list" )
{
   if( $dir eq "" )
   {
   $dir = "\.";
   }
   @entries = $ftp->ls( "$dir");
   foreach (@entries)
   {
      print "$_\n";
   }
}
elsif( $method eq "del" )
{
   $ftp->delete("$file");
}
else
{
   &err_msg("unknown method ... exiting\n");
}

$ftp->quit;

1;


sub err_msg
{
  my $msg = shift;
  # print "$msg";
  $ftp->quit;
  exit( -1);
}
