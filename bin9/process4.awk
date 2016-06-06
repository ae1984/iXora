#!/bin/bash
cat $1 | win2koi | tr '\015' '\012' | tr -d '\014' > $1.crlf

# -------------------------------------------------------
# Processing merchant statements from HalykBank
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
          KZT = 0;
          i   = 0;
          DEVICE = "";
          CONTRACT = "";
          NAME = "";     # temporary name
          NAMERES = "";  # resulting name
          STATYPE = "";  # type of statement (post, retail, etc)
          print "\|BANK\| 001";  # 001 - HalykBank, 005 - ABN AMRO
         }

   # Look for the type of statement...
   NR == 43 {STATYPE = $4}

   # merchant contract No
   /Contract / {
                print "###CONTRACT###";
                print " ";
                print " ";
                CONTRACT = substr($NF,3,14);
                KZT = 0;
                NAMERES = NAME;
               }

   # Print header of file : period and type of statement
   /Date/ {if (NR == 49) {
                          print "\|REGD\| " $3;
                          printf ("|TYPE| %s\n", STATYPE)
          }              }

   # Get client`s Name
   /Financial Institution:/ {
            NAME = "";
            for (i=0; i<6; i++) {getline}       
            for (i=0; i<NF; i++) {if ($i == "Office:") {A2 = i}}
            A1 = 1;
            NAME = $1;
            for (i=A1+1; i<A2; i++) {NAME = NAME " " $i};
            NAMECNT = 0;
          }
   # Currency processing
   /KZT/  {
           KZT += 1;
           if (STATYPE == "Unique") {
                            print "\|CURR\| " $2;
                            print "\|CONT\| " CONTRACT;
                            # other KZT occur #
                            DEVICE = $4;
                            # skip 15 lines   #
                            for (i = 0; i<15; i++) {getline}
                            while (1 == 1)
                            {
                              if ((length($2) >= 16  && substr ($2,2,3) != "---") || (length($2) == 9 && substr ($2,2,3) != "---"))
                              {
                              # print TRX INFO  #
                              print "\|TRDT\| " $1;
                              print "\|CARD\| " $2;
                              print "\|AUTH\| 0" ;
                              print "\|NAME\| " NAMERES;
                              print "\|SUMA\| " $(NF-2);
                              print "\|DISC\| " $(NF-1);
                              print "\|SUMB\| " $NF
                              print "\|DEVC\| " DEVICE;
                              }
                              getline;
                              if ($1 == "TOTAL") {print $1; break; }
                            }
           } else {
           if (KZT == 1) {
                          # first occur #
                          print "\|CURR\| " $2;
                          print "\|CONT\| " CONTRACT;
                         }
                     # else{
                            # other KZT occur #
                            DEVICE = $4;
                            # skip 15 lines   #
                            for (i = 0; i<15; i++) {getline}
                            while (1 == 1)
                            {
                              if ((length($2) >= 16) || (length($2) == 9))
                              {
                              # print TRX INFO  #
                              print "\|TRDT\| " $1;
                              print "\|CARD\| " $2;
                              print "\|AUTH\| 0" ;
                              print "\|NAME\| " NAMERES;
                              print "\|SUMA\| " $(NF-2);
                              print "\|DISC\| " $(NF-1);
                              print "\|SUMB\| " $NF
                              print "\|DEVC\| " DEVICE;
                              }
                              getline;
                              if ($1 == "TOTAL") {print $1; break; }
                            }
                     #    } # end of 'else' for kzt == 1
                   } # end of statype = "unique"
          }
 ' > $1.head1k

########################################################
# 2 STEP - Make all numbers valid (format xxxxxxx.xxx)
########################################################
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


########################################################
# 3 STEP - Calculate totals
########################################################
cat $1.head2k | awk  '

   # Initial variables
   BEGIN {
          float CNT1;
          float CNT2;
          float CNT3;
          CNT1 = 0.
          CNT2 = 0.
          CNT3 = 0.
         }

   # Print totals
   {if ($1 == "###CONTRACT###")
         {if (CNT1 > 0) {#if there are some <> 0
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

   END { if (CNT1 > 0) {#if there are some <> 0
                          printf ("|TOTA| %.2f\n", CNT1);
                          printf ("|TOTD| %.2f\n", CNT2);
                          printf ("|TOTB| %.2f\n", CNT3);
                          CNT1 = 0;
                          CNT2 = 0;
                          CNT3 = 0;
                         }
        }

' > $1.headkzt



#***************************  USD PROCESSING ***********
#*******************************************************
#*******************************************************
#*******************************************************


########################################################
# 1 STEP - Make basic construction of file
########################################################

cat $1.crlf | awk '

   # Initial AWK variables
   BEGIN {
          USD = 0;
          i   = 0;
          DEVICE = "";
          CONTRACT = "";
          NAME = "";     # temporary name
          NAMERES = "";  # resulting name
          print "\|BANK\| 001";  # 001 - HalykBank, 005 - ABN AMRO
         }
   # Look for the type of statement...
   NR == 43 {STATYPE = $4}
   /Contract / {
                print "###CONTRACT###";
                print " ";
                print " ";
                CONTRACT = substr($NF,3,14);
                USD = 0;
                NAMERES = NAME;
               }

   # Print header of file : period and type of statement
   /Date/ {if (NR == 49) {
                          print "\|REGD\| " $3;
                          printf ("|TYPE| %s\n", STATYPE)
          }              }

   # Get client`s Name
   /Financial Institution:/ {
            NAME = "";
            for (i=0; i<6; i++) {getline}       
            for (i=0; i<NF; i++) {if ($i == "Office:") {A2 = i}}
            A1 = 1;
            NAME = $1;
            for (i=A1+1; i<A2; i++) {NAME = NAME " " $i};
            NAMECNT = 0;
          }
   /USD/  {
           USD += 1;
           if (STATYPE == "Unique") {
                            print "\|CURR\| " $2;
                            print "\|CONT\| " CONTRACT;
                            # other KZT occur #
                            DEVICE = $4;
                            # skip 15 lines   #
                            for (i = 0; i<15; i++) {getline}
                            while (1 == 1)
                            {
                              if ((length($2) >= 16  && substr ($2,2,3) != "---") || (length($2) == 9 && substr ($2,2,3) != "---"))
#                              if ((length($2) >= 16) || (length($2) == 9))
                              {
                              # print TRX INFO  #
                              print "\|TRDT\| " $1;
                              print "\|CARD\| " $2;
                              print "\|AUTH\| 0" ;
                              print "\|NAME\| " NAMERES;
                              print "\|SUMA\| " $(NF-2);
                              print "\|DISC\| " $(NF-1);
                              print "\|SUMB\| " $NF
                              print "\|DEVC\| " DEVICE;
                              }
                              getline;
                              if ($1 == "TOTAL") {print $1; break; }
                            }
           } else {
           if (USD == 1) {
                          # first occur #
                          print "\|CURR\| " $2;
                          print "\|CONT\| " CONTRACT;
                         }
                     else{
                            # other USD occur #
                            DEVICE = $4;
                            # skip 15 lines   #
                            for (i = 0; i<15; i++) {getline}
                            while (1 == 1)
                            {
                              if ((length($2) >= 16) || (length($2) == 9))
                              {
                              # print TRX INFO  #
                              print "\|TRDT\| " $1;
                              print "\|CARD\| " $2;
                              print "\|AUTH\| 0" ;
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
                   }
          }

 ' > $1.head1u

########################################################
# 2 STEP - Make all numbers valid (format xxxxxxx.xxx)
########################################################
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


########################################################
# 3 STEP - Calculate totals
########################################################
cat $1.head2u | awk  '

   # Initial variables
   BEGIN {
          float CNT1;
          float CNT2;
          float CNT3;
          CNT1 = 0.
          CNT2 = 0.
          CNT3 = 0.
         }

   # Print totals
   {if ($1 == "###CONTRACT###")
         {if (CNT1 > 0) {#if there are some <> 0
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

   END { if (CNT1 > 0) {#if there are some <> 0
                          printf ("|TOTA| %.2f\n", CNT1);
                          printf ("|TOTD| %.2f\n", CNT2);
                          printf ("|TOTB| %.2f\n", CNT3);
                          CNT1 = 0;
                          CNT2 = 0;
                          CNT3 = 0;
                         }
        }

' > $1.headusd

