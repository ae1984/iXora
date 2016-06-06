#!/usr/bin/perl -w

# script for conversion of the html file to wiki article
# author: 17/11/2008 madiyar

# synopsis:
# cb1pump.pl [-debug] -login=my_login -password=my_password -method=GetBatchStatus2 -batchid=3477

use HTML::WikiConverter;
my $wc = new HTML::WikiConverter( dialect => 'MediaWiki', encoding => 'windows-1251' );

open (sfile, "<$ARGV[0]") or die ("Cannot open $ARGV[0]"); 
@sfile = <sfile>;
close (sfile);

my $html = "";

foreach $sfile(@sfile) {
    $html = join "\n", $html, $sfile;
}

my $wiki = $wc->html2wiki( html => $html );

print $wiki, "\n";



