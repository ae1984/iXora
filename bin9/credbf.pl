#!/usr/bin/perl 
use XBase;

if ($ARGV[0] eq "c") {
                my $tb = XBase->create("name" => "txb.dbf",
                "field_names" => [ "LICSCH", "FIO","SOPL","ADRESS","DATAPR","RNNPLAT","NOPER","NUMFIL", "KODKNTR" ],
                "field_types" => [ "C",      "C",  "N",   "C",    "D",     "C",      "N",    "C",     "N" ],
                "field_lengths" => [ 6,       30,   16,    50,      8,      12,        5,      8,      3  ],
                "field_decimals" => [ 0,       0,    2,     0,  undef,       0,        0,      0,   undef ]);
             }
             else {
                my $tb = XBase->create("name" => "txb.dbf",
                "field_names" => [ "LICSCH", "FIO","POKSH","SOPL","ADRESS","DATAPR","RNNPLAT","NOPER","NUMFIL", "KODKNTR" ],
                "field_types" => [ "C",      "C",  "N",       "N",   "C",    "D",     "C",      "N",    "C",     "N" ],
                "field_lengths" => [ 6,       30,    6,        16,    50,      8,      12,        5,      8,      3  ],
                "field_decimals" => [ undef,undef,undef,        2,   undef,undef, undef,undef,undef,   undef ]);
             }

#$tb->close;
my $tb = new XBase "txb.dbf" or die XBase->errstr;
  
open (TXB, "<$ARGV[1]") or die ("Cannot open $ARGV[1]"); 
 @txb = <TXB>;
close (TXB);

$i=0; 

foreach $txb(@txb) {
  $tb -> write_record($i);

  if ($ARGV[0] eq "c") {
                     ($LICSCH,$FIO,$SOPL,$ADRESS,$DATAPR,$RNNPLAT,$NOPER,$NUMFIL,$KODKNTR) = 
                      split('\|',$txb,9);
                      
                      $tb -> update_record_hash($i, "LICSCH"  => $LICSCH, "FIO"     => $FIO,
                                                    "SOPL"    => $SOPL,   "ADRESS"   => $ADRESS ,
                                                    "DATAPR"  => $DATAPR, "RNNPLAT" => $RNNPLAT, 
                                                    "NOPER"   => $NOPER,  "NUMFIL"   => $NUMFIL, 
                                                    "KODKNTR" => $KODKNTR );
               }

               else {
                     ($LICSCH,$FIO,$POKSH,$SOPL,$ADRESS,$DATAPR,$RNNPLAT,$NOPER,$NUMFIL,$KODKNTR) = 
                      split('\|',$txb,10);
                      $tb -> update_record_hash($i, "LICSCH"  => $LICSCH, "FIO"     => $FIO, "POKSH" => $POKSH,
                                                    "SOPL"    => $SOPL,   "ADRESS"   => $ADRESS ,
                                                    "DATAPR"  => $DATAPR, "RNNPLAT" => $RNNPLAT, 
                                                    "NOPER"   => $NOPER,  "NUMFIL"   => $NUMFIL, 
                                                    "KODKNTR" => $KODKNTR );
               }
   $i++;   
};

$tb->close;

#system ("rm -f $ARGV[1]");
system ("mv -f txb.dbf $ARGV[1]");
#system ("rm -f TXB*");
