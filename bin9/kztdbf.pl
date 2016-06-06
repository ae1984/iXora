#!/usr/bin/perl 
use XBase;


                my $tb = XBase->create("name" => "kaztelc.dbf",
                "field_names" => [ "BANK_ID", "SUBDIVIS","BILL_ID","ABONENT_ID","ORDER_DATE","ORDER_NUM","MONEY" ],
                "field_types" => [ "N",      "N",  "N",   "N",    "C",     "N",      "N" ],
                "field_lengths" => [ 4,       6,   15,    15,      19,      10,        14 ],
                "field_decimals" => [ 0,       0,    0,     0,      0,       0,        2 ]);

#$tb->close;
my $tb = new XBase "kaztelc.dbf" or die XBase->errstr;
  
open (TXB, "<$ARGV[1]") or die ("Cannot open $ARGV[1]"); 
 @txb = <TXB>;
close (TXB);

$i=0; 

foreach $txb(@txb) {
  $tb -> write_record($i);


                     ($BANK_ID,$SUBDIVIS,$BILL_ID,$ABONENT_ID,$ORDER_DATE,$ORDER_NUM,$MONEY) = 
                      split('\|',$txb,9);
                      

                      $tb -> update_record_hash($i, "BANK_ID"  => $BANK_ID, "SUBDIVIS"     => $SUBDIVIS,
                                                    "BILL_ID"    => $BILL_ID,   "ABONENT_ID"   => $ABONENT_ID,
                                                    "ORDER_DATE"  => $ORDER_DATE, "ORDER_NUM" => $ORDER_NUM, 
                                                    "MONEY"   => $MONEY );
   $i++;   
};

$tb->close;

#system ("rm -f $ARGV[1]");
system ("mv -f kaztelc.dbf $ARGV[1]");
#system ("rm -f KAZ*");
