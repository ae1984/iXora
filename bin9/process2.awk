#!/bin/bash
cat $1 | win2koi | tr '\015' '\012' | tr -d '\014' > $1.crlf

# -------------------------------------------------------
# Processing merchant statements from ABN AMRO
# -------------------------------------------------------


#***************************  KZT PROCESSING ***********
#*******************************************************
#*******************************************************
#*******************************************************

########################################################
# 1 STEP - Make basic construction of file
########################################################

cat $1.crlf | awk '

   # Initial AWK variables
   BEGIN {
          CRC = "";                                    
   	  KZT = 0;
   	  i   = 0;
   	  j   = 0;
   	  TMP = "";
   	  DEVICE = "";
   	  CONTRACT = "";
   	  NAME = "";     # temporary name
   	  NAMERES = "";  # resulting name
   	  REGDT = "";    # registration date (posting date)
   	  STATYPE = "Statement";  # type of statement (post, retail)
   	  print "\|BANK\| 005"; # HalykBank = 001, ABN AMRO = 005
         }

   /Financial Institution:/ {
            for (i=0; i<9; i++) {getline}
            NAME = $1;
            j = 0;
            for (i=1; i<=NF; i++)
                {
                 TMP = substr($i,1,3);
                 if (TMP == "---") { j = i; }
                }
            for (i=2; i<j; i++) {NAME = NAME " " $i}
            NAMECNT = 0;
          }

   /Contract / {
                CONTRACT = $NF;
                KZT = 0;
                NAMERES = NAME;
                for (i=0; i<12; i++) {getline}
                STATYPE = $NF;
               }

   /KZT/  {
           KZT += 1;
                          CRC = $2;
                          DEVICE = $4;

           if (KZT == 1) {
                          LINESTOSKIP = 20;

                          if (REGDT == "") {
                             getline; 
                             getline;
                             getline;
                             REGDT = substr ( $(NF - 2), 6, 10 );
                             print "\|REGD\| " REGDT;
                             print "\|TYPE\| " STATYPE;
                             print "###CONTRACT###";  
                             print " ";
                             print " ";
                             print "\|CURR\| " CRC;
                             print "\|CONT\| " CONTRACT;
                             LINESTOSKIP = 17;
                          }

                          }

                         for (i = 0; i < LINESTOSKIP; i++) {getline}
                         while (1 == 1)
                         {
                           if ((length($2) >= 16  && substr ($2,2,3) != "---") || (length($2) == 9 && substr ($2,2,3) != "---"))
                           {
                           print "\|TRDT\| " $1;
                           print "\|CARD\| " $2;
                           print "\|AUTH\| " $3;
                           print "\|NAME\| " NAMERES;
                           print "\|SUMA\| " $(NF-2);
                           print "\|DISC\| " $(NF-1);
                           print "\|SUMB\| " $NF
                           print "\|DEVC\| " DEVICE;
                           }
                           getline;
                           if ($1 == "TOTAL") {print $1; break; }
                         }
          }
 ' > $1.head1k


cat $1.head1k | awk  '
{
     if ( (substr($1,2,4) == "SUMA") || (substr($1,2,4) == "DISC") || (substr($1,2,4) == "SUMB") )
     {
        dCnt = split ($2, decim, ".");
	pCnt = split (decim[1], parts, ",");
        char Sum;
	Sum = "";
	for (i = 1; i <= pCnt; i++)
  	    Sum = Sum "" parts[i];
  	    Sum = Sum "." decim[2];
  	print $1 " " Sum;
     } else print;
} ' > $1.head2k

cat $1.head2k | awk  '
   BEGIN {
   	  float CNT1;
   	  float CNT2;
   	  float CNT3;
   	  CNT1 = 0.
   	  CNT2 = 0.
   	  CNT3 = 0.
         }

   {if ($1 == "###CONTRACT###")
         {if (CNT1 > 0) {
                          printf ("|TOTA| %.2f\n", CNT1);
                          printf ("|TOTD| %.2f\n", CNT2);
                          printf ("|TOTB| %.2f\n", CNT3);
                          CNT1 = 0;
                          CNT2 = 0;
                          CNT3 = 0;
                         }
         }
         else
         {
          if (substr($1,2,4) == "SUMA") {CNT1 += $2;}
          else
          if (substr($1,2,4) == "DISC") {CNT2 += $2;}
          else
          if (substr($1,2,4) == "SUMB") {CNT3 += $2;}
          print;
         }
   }

   END { if (CNT1 > 0) {
                          printf ("|TOTA| %.2f\n", CNT1);
                          printf ("|TOTD| %.2f\n", CNT2);
                          printf ("|TOTB| %.2f\n", CNT3);
                          CNT1 = 0;
                          CNT2 = 0;
                          CNT3 = 0;
                         }
        }

' > $1.headkzt


#   USD PROCESSING ###################################################3

cat $1.crlf | awk '

   BEGIN {
          CRC = "";                                    
   	  USD = 0;
   	  i   = 0;
   	  j   = 0;
   	  TMP = "";
   	  DEVICE = "";
   	  CONTRACT = "";
   	  NAME = "";     # temporary name
   	  NAMERES = "";  # resulting name
   	  REGDT = "";    # registration date (posting date)
   	  STATYPE = "Statement";  # type of statement (post, retail)
   	  print "\|BANK\| 005"; # HalykBank = 001, ABN AMRO = 005
         }


   /Financial Institution:/ {
            for (i=0; i<9; i++) {getline}
            NAME = $1;
            j = 0;
            for (i=1; i<=NF; i++)
                {
                 TMP = substr($i,1,3);
                 if (TMP == "---") { j = i; }
                }
            for (i=2; i<j; i++) {NAME = NAME " " $i}
            NAMECNT = 0;
          }

   /Contract / {
                CONTRACT = $NF;
                USD = 0;
                NAMERES = NAME;
                for (i=0; i<12; i++) {getline}
                STATYPE = $NF;
               }

   /USD/  {
          USD += 1;
                          CRC = $2;
                          DEVICE = $4;

           if (USD == 1) {

                          LINESTOSKIP = 20;

                          if (REGDT == "")
                          {
                             getline;
                             getline;
                             getline;
                             REGDT = substr ( $(NF - 2), 6, 10 );
                             print "\|REGD\| " REGDT;
                             print "\|TYPE\| " STATYPE;
                             print "###CONTRACT###";
                             print " ";
                             print " ";
                             print "\|CURR\| " CRC;
                             print "\|CONT\| " CONTRACT;
                             LINESTOSKIP = 17;
                          }

                          }

                         for (i = 0; i < LINESTOSKIP; i++) {getline}
                         while (1 == 1)
                         {
                           if ((length($2) >= 16  && substr ($2,2,3) != "---") || (length($2) == 9 && substr ($2,2,3) != "---"))
                           {
                           print "\|TRDT\| " $1;
                           print "\|CARD\| " $2;
                           print "\|AUTH\| " $3;
                           print "\|NAME\| " NAMERES;
                           print "\|SUMA\| " $(NF-2);
                           print "\|DISC\| " $(NF-1);
                           print "\|SUMB\| " $NF
                           print "\|DEVC\| " DEVICE;
                           }
                           getline;
                           if ($1 == "TOTAL") {print $1; break; }
                         }
          }


 ' > $1.head1u


# Change numbers format to Pragma standard
cat $1.head1u | awk  '
{
     if ( (substr($1,2,4) == "SUMA") || (substr($1,2,4) == "DISC") || (substr($1,2,4) == "SUMB") )
     {
        dCnt = split ($2, decim, ".");
	pCnt = split (decim[1], parts, ",");
        char Sum;
	Sum = "";
	for (i = 1; i <= pCnt; i++)
  	    Sum = Sum "" parts[i];
  	    Sum = Sum "." decim[2];
  	print $1 " " Sum;
     } else print;
} ' > $1.head2u



cat $1.head2u | awk  '
   BEGIN {
   	  float CNT1;
   	  float CNT2;
   	  float CNT3;
   	  CNT1 = 0.
   	  CNT2 = 0.
   	  CNT3 = 0.
         }

   {if ($1 == "###CONTRACT###")
         {if (CNT1 > 0) {
                          printf ("|TOTA| %.2f\n", CNT1);
                          printf ("|TOTD| %.2f\n", CNT2);
                          printf ("|TOTB| %.2f\n", CNT3);
                          CNT1 = 0;
                          CNT2 = 0;
                          CNT3 = 0;
                         }
         }
         else
         {
          if (substr($1,2,4) == "SUMA") {CNT1 += $2;}
          else
          if (substr($1,2,4) == "DISC") {CNT2 += $2;}
          else
          if (substr($1,2,4) == "SUMB") {CNT3 += $2;}
          print;
         }
   }

   END { if (CNT1 > 0) {
                          printf ("|TOTA| %.2f\n", CNT1);
                          printf ("|TOTD| %.2f\n", CNT2);
                          printf ("|TOTB| %.2f\n", CNT3);
                          CNT1 = 0;
                          CNT2 = 0;
                          CNT3 = 0;
                         }
        }

' > $1.headusd
