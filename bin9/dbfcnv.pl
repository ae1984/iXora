#!/usr/bin/perl 
use XBase;
my @fields;
my $database = new XBase($ARGV[0]);
#tr/\xC0-\xFF/\xFE\xE0\xE1\xF6\xE4\xE5\xF4\xE3\xF5\xE8-\xEF\xFF\xF0-\xF3\xE6\xE2\xFC\xFB\xE7\xF8\xFD\xF9\xF7\xFA\xDE\xC0\xC1\xD6\xC4\xC5\xD4\xC3\xD5\xC8-\xCF\xDF\xD0-\xD3\xC6\xC2\xDC\xDB\xC7\xD8\xDD\xD9\xD7\xDA/;
my @ft=$database->field_types;
#$outf=
open(BD,">$ARGV[1]");
for ($j=0; $j<=$database->last_record; $j++) {
	($_, @fields) = $database->get_record($j);
	for ($i=0; $i<@fields; $i++) {
		#if   ($ft[$i] eq "C"){$fields[$i]=~tr/\xFE\xE0\xE1\xF6\xE4\xE5\xF4\xE3\xF5\xE8-\xEF\xFF\xF0-\xF3\xE6\xE2\xFC\xFB\xE7\xF8\xFD\xF9\xF7\xFA\xDE\xC0\xC1\xD6\xC4\xC5\xD4\xC3\xD5\xC8-\xCF\xDF\xD0-\xD3\xC6\xC2\xDC\xDB\xC7\xD8\xDD\xD9\xD7\xDA/\xC0-\xFF/} 
		if($ft[$i] eq "D"){$fields[$i]=~s/(.{4,})(.{2,})(.{2,})/\3\/\2\/\1/}
	}
	print BD join("|", @fields), "\n";
	#for ($k=0; $k<@fields; $k++) {print BD $fields[$k], "#"}
	#for ($k=0; $k<@fields; $k++) {print @fields[$k], "#"}
	#print BD "\n";
	#print BD @fields,"\n";
	#$database->go_next;
} 
$database->close;
close(BD)
