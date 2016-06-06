#!/usr/bin/perl
use XBase;

                my $tb = XBase->create("name" => "txb.dbf",
                "field_names"    => [ "TYPE", "DEB1", "DEB2", "DEB3", "CRE1", "CRE2","CRE3", "SUMMA", "DESC", "DATA"],
                "field_types"    => [ "N",      "C",    "C",    "C",    "C",    "C",   "C",   "N",      "C",  "D"  ],
                "field_lengths"  => [   2,       20,     20,     20,     20,     20,    20,    15,       60,   8  ],
                "field_decimals" => [   0,        0,      0,      0,      0,      0,     0,    2,         0,   0   ]);



my $tb = new XBase "txb.dbf" or die XBase->errstr;


  
open (TXB, "<$ARGV[0]") or die ("Cannot open $ARGV[0]"); 
 @txb = <TXB>;
close (TXB);

$i=0; 

foreach $txb(@txb) {
  $tb -> write_record($i);


                     ($TYPE,   $DEB1, $DEB2, $DEB3, $CRE1, $CRE2, $CRE3, $SUMMA,  $DESC, $DATA) = 
                      split('\|',$txb,10);
                      $tb -> update_record_hash($i, "TYPE"  => $TYPE,
                                                    "DEB1"  => $DEB1, 
                                                    "DEB2"  => $DEB2, 
                                                    "DEB3"  => $DEB3, 
                                                    "CRE1"  => $CRE1, 
                                                    "CRE2"  => $CRE2, 
                                                    "CRE3"  => $CRE3, 
                                                    "SUMMA" => $SUMMA, 
                                                    "DESC"  => $DESC, 
                                                    "DATA"  => $DATA);
   $i++;   
};

$tb->close;

system ("mv -f txb.dbf $ARGV[0]" + ".dbf");

