#!/usr/bin/perl
#/usr/bin/perl 
use XBase;

                my $tb = XBase->create("name" => "txb.dbf",
                "field_names"    => [ "LS", "FIO","K_STREET","HOUSE","FLAT","SUMMA","DATA_UPL","FILIAL" ],
                "field_types"    => [ "N",  "C",  "C",       "C",    "C",    "N",     "D",      "C" ],
                "field_lengths"  => [  8,    18,   30,        10,     5,      15,      8,        9 ],
                "field_decimals" => [ undef,undef,undef,     undef,  undef,   2,     undef,     undef ]);



my $tb = new XBase "txb.dbf" or die XBase->errstr;


  
open (TXB, "<$ARGV[0]") or die ("Cannot open $ARGV[0]"); 
 @txb = <TXB>;
close (TXB);

$i=0; 

foreach $txb(@txb) {
  $tb -> write_record($i);


                     ($LS,$FIO,$K_STREET,$HOUSE,$FLAT,$SUMMA,$DATA_UPL,$FILIAL) = 
                      split('\|',$txb,8);
                      $tb -> update_record_hash($i, "LS"  => $LS,
                                                    "FIO" => $FIO, 
                                                    "K_STREET" => $K_STREET,
                                                    "HOUSE"   => $HOUSE,
                                                    "FLAT"  => $FLAT,
                                                    "SUMMA"  => $SUMMA,
                                                    "DATA_UPL"  => $DATA_UPL,
                                                    "FILIAL" => $FILIAL );
   $i++;   
};

$tb->close;

system ("mv -f txb.dbf $ARGV[0]" + ".dbf");

