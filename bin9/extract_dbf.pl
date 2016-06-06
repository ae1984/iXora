#!/usr/bin/perl
use XBase;

              my $tb = XBase->create("name" => "txb.dbf",
               	"field_names"    => [    "AIM", "AIM1", "BANKPLAT", "ACCOUNT", "BANKPOL", "CODPOL", "CODOUT", "PAYMENT", "NDOK", "KOPER", "SEND", "DATLAST", "PAPKA", "WORTH", "USER", "TAXESNUMA", "TAXESNUM", "REFER",  "RF", "KNP", "BCLASSD", "ELO", "RECNO", "PLATEL", "POLUCH", "FIORUK", "FIOGB", "SYMBOL", "GROUPE", "GROUPECR", "PRIOR", "ORDCAT", "EKP", "IN", "DB",  "CR", "OUT" ],
                "field_types"    => [     "C",    "C",      "C",       "C",       "C",      "C",       "C",      "N",     "C",     "C",    "C",      "D",      "C",     "C",    "C",       "C",         "C",      "C",    "C",   "C",     "C",     "C",    "C",     "C",       "C",      "C",     "C",     "C",      "C",       "C",       "C",      "C",    "C",   "N",  "N",  "N",   "N"  ],
                "field_lengths"  => [      170,   250,       9,        25,         9,        20,       20,       19,       9,       2,      2,        8,        3,       1,      8,        12,          12,       15,      16,    3,       6,       1,      9,      120,       120,      20,      20,       6,       25,        25,         2,        3,     10,    19,   19,    19,   19   ],
                "field_decimals" => [      0,      0,        0,         0,         0,        0,         0,       2,        0,       0,      0,        0,        0,       0,      0,         0,           0,        0,      0,     0,       0,       0,      0,       0,         0,        0,       0,       0,        0,         0,         0,        0,      0,     2,    2,    2,     2   ]); 


my $tb = new XBase "txb.dbf" or die XBase->errstr;


  
open (TXB, "<$ARGV[0]") or die ("Cannot open $ARGV[0]"); 
 @txb = <TXB>;
close (TXB);

$i=0; 

foreach $txb(@txb) {
  $tb -> write_record($i);


                     ($AIM, $AIM1, $BANKPLAT, $ACCOUNT, $BANKPOL, $CODPOL, $CODOUT, $PAYMENT, $NDOK, $KOPER, $SEND, $DATLAST, $PAPKA, $WORTH, $USER, $TAXESNUMA, $TAXESNUM, $REFER, $RF, $KNP, $BCLASSD, $ELO, $RECNO, $PLATEL, $POLUCH, $FIORUK, $FIOGB, $SYMBOL, $GROUPE, $GROUPECR, $PRIOR, $ORDCAT, $EKP, $IN, $DB, $CR, $OUT) = 
                      split('\|',$txb,37);
                      $tb -> update_record_hash($i, "AIM"  => $AIM,
													"AIM1"  => $AIM1,
													"BANKPLAT"  => $BANKPLAT,
													"ACCOUNT"  => $ACCOUNT,
													"BANKPOL"  => $BANKPOL,
													"CODPOL"  => $CODPOL,
													"CODOUT"  => $CODOUT,
													"PAYMENT"  => $PAYMENT,
													"NDOK"  => $NDOK,
													"KOPER"  => $KOPER,
													"SEND"  => $SEND,
													"DATLAST"  => $DATLAST,
													"PAPKA"  => $PAPKA,
													"WORTH"  => $WORTH,
													"USER"  => $USER,
													"TAXESNUMA"  => $TAXESNUMA,
													"TAXESNUM"  => $TAXESNUM,
													"REFER"  => $REFER,
													"RF"  => $RF,
													"KNP"  => $KNP,
													"BCLASSD"  => $BCLASSD,
													"ELO"  => $ELO,
													"RECNO"  => $RECNO,
													"PLATEL"  => $PLATEL,
													"POLUCH"  => $POLUCH,
													"FIORUK"  => $FIORUK,
													"FIOGB"  => $FIOGB,
													"SYMBOL"  => $SYMBOL,
													"GROUPE"  => $GROUPE,
													"GROUPECR"  => $GROUPECR,
													"PRIOR"  => $PRIOR,
													"ORDCAT"  => $ORDCAT,
													"EKP"  => $EKP,
													"IN"  => $IN,
													"DB"  => $DB,
													"CR"  => $CR,
													"OUT"  => $OUT);

					system("print 111");
   $i++;   
};

$tb->close;

system ("mv -f txb.dbf $ARGV[0]" );

