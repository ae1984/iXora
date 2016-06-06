#!/usr/bin/perl
use XBase;

              my $tb = XBase->create("name" => "txb.dbf",
                "field_names"    => [ "ORDER_DATE", "WORKPLACE", "ABONENT_ID", "PHONE", "MONEY_TYPE", "MONEY","DOCUMENT", "NOTE" ],
                "field_types"    => [     "D",          "C",         "N",        "C",       "N",        "N",      "N",     "C"   ],
                "field_lengths"  => [      8,            32,          8,          8,         6,          12,       6,       32   ],
                "field_decimals" => [      0,            0,           0,          0,         0,          2,        0,        0   ]);   


my $tb = new XBase "txb.dbf" or die XBase->errstr;


  
open (TXB, "<$ARGV[0]") or die ("Cannot open $ARGV[0]"); 
 @txb = <TXB>;
close (TXB);

$i=0; 

foreach $txb(@txb) {
  $tb -> write_record($i);


                     ($ORDER_DATE,   $WORKPLACE, $ABONENT_ID, $PHONE, $MONEY_TYPE, $MONEY, $DOCUMENT, $NOTE) = 
                      split('\|',$txb,8);
                      $tb -> update_record_hash($i, "ORDER_DATE"  => $ORDER_DATE,
                                                    "WORKPLACE"  => $WORKPLACE, 
                                                    "ABONENT_ID"  => $ABONENT_ID, 
                                                    "PHONE"  => $PHONE, 
                                                    "MONEY_TYPE"  => $MONEY_TYPE, 
                                                    "MONEY"  => $MONEY, 
                                                    "DOCUMENT"  => $DOCUMENT, 
                                                    "NOTE" => $NOTE);
   $i++;   
};

$tb->close;

system ("mv -f txb.dbf $ARGV[0]" );

