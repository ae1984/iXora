#!/bin/bash
cat $1 | win2koi | tr '\015' '\012' | tr -d '\014' > $1.crlf

# -------------------------------------------------------
# Processing merchant statements from ABN AMRO
# -------------------------------------------------------
# * CHANGES
#   30/04/2004 isaev - ёҐ­ҐЮ ФЁО Д ©«®ў Ї® ATM, POS


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

    /---Office:----/ {
        i = index ($0, "---Office:---")
        NAME = substr ($0, 1, i - 1)
        }

    /Contract / {
        NAMERES = NAME;
        j = 100000
        for ( i = 1; i <= length(NAMERES); i++ )
        {
         j = i;
         if ( substr (NAMERES, i, 1) != " ") 
         {
           break;
         }
        }
        if ( j != 10000 ) { NAMERES = substr (NAMERES, j); }

        j = length (NAMERES)
        while (j > 0 ) {
          if ( substr (NAMERES, j, 1) != " ") {break}
          j = j - 1
        }
        if (j > 0) { NAMERES = substr (NAMERES, 1, j) }

        CONTRACT = $NF;
        KZT = 0;
        REGDT = "";
#        NAMERES = "";
        for (i = 0; i < 12; i++) {getline}
        STATYPE = $NF;
        j = NF - 1;
    }

   /KZT/  {
        if (STATYPE == "Retail") {
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
            while (1 == 1) {
                if ((length($2) >= 16  && substr ($2,2,3) != "---") || (length($2) == 9 && substr ($2,2,3) != "---")) {
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
    }

' > $1.head1k




cat $1.head1k | awk '
    {
        if ( (substr($1,2,4) == "SUMA") || (substr($1,2,4) == "DISC") || (substr($1,2,4) == "SUMB") ) {
            dCnt = split ($2, decim, ".");
            pCnt = split (decim[1], parts, ",");
            char Sum;
            Sum = "";
            for (i = 1; i <= pCnt; i++)
                Sum = Sum "" parts[i];
            Sum = Sum "." decim[2];
            print $1 " " Sum;
        } else
            print;
    } 
' > $1.head2k






cat $1.head2k | awk  '
    BEGIN {
        float CNT1;
        float CNT2;
        float CNT3;
        CNT1 = 0.
        CNT2 = 0.
        CNT3 = 0.
    }

    {
        if ($1 == "###CONTRACT###") {
            if (CNT1 > 0) {
                printf ("|TOTA| %.2f\n", CNT1);
                printf ("|TOTD| %.2f\n", CNT2);
                printf ("|TOTB| %.2f\n", CNT3);
                CNT1 = 0;
                CNT2 = 0;
                CNT3 = 0;
            }
        } else {
            if (substr($1,2,4) == "SUMA") {CNT1 += $2;}
            else if (substr($1,2,4) == "DISC") {CNT2 += $2;}
            else if (substr($1,2,4) == "SUMB") {CNT3 += $2;}
            print;
        }
    }

    END {
        if (CNT1 > 0) {
            printf ("|TOTA| %.2f\n", CNT1);
            printf ("|TOTD| %.2f\n", CNT2);
            printf ("|TOTB| %.2f\n", CNT3);
            CNT1 = 0;
            CNT2 = 0;
            CNT3 = 0;
        }
    }

' > $1.headkzt











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

    /---Office:----/ {
        i = index ($0, "---Office:---")
        NAME = substr ($0, 1, i - 1)
        }

    /Contract / {
        NAMERES = NAME;
        j = 100000
        for ( i = 1; i <= length(NAMERES); i++ )
        {
         j = i;
         if ( substr (NAMERES, i, 1) != " ") 
         {
           break;
         }
        }
        if ( j != 10000 ) { NAMERES = substr (NAMERES, j); }

        j = length (NAMERES)
        while (j > 0 ) {
          if ( substr (NAMERES, j, 1) != " ") {break}
          j = j - 1
        }
        if (j > 0) { NAMERES = substr (NAMERES, 1, j) }

        CONTRACT = $NF;
        KZT = 0;
        REGDT = "";
        for (i = 0; i < 12; i++) {getline}
        STATYPE = $NF;
        j = NF - 1;
    }

   /KZT/  {
        if (STATYPE == "ATM") {
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
            while (1 == 1) {
                if ((length($2) >= 16  && substr ($2,2,3) != "---") || (length($2) == 9 && substr ($2,2,3) != "---")) {
                    print "\|TRDT\| " $1;
                    print "\|CARD\| " $2;
                    print "\|AUTH\| " $3;
                    print "\|SLIP\| " $4;
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

' > $1.atm1k




cat $1.atm1k | awk '
    {
        if ( (substr($1,2,4) == "SUMA") || (substr($1,2,4) == "DISC") || (substr($1,2,4) == "SUMB") ) {
            dCnt = split ($2, decim, ".");
            pCnt = split (decim[1], parts, ",");
            char Sum;
            Sum = "";
            for (i = 1; i <= pCnt; i++)
                Sum = Sum "" parts[i];
            Sum = Sum "." decim[2];
            print $1 " " Sum;
        } else
            print;
    } 
' > $1.atm2k






cat $1.atm2k | awk  '
    BEGIN {
        float CNT1;
        float CNT2;
        float CNT3;
        CNT1 = 0.
        CNT2 = 0.
        CNT3 = 0.
    }

    {
        if ($1 == "###CONTRACT###") {
            if (CNT1 > 0) {
                printf ("|TOTA| %.2f\n", CNT1);
                printf ("|TOTD| %.2f\n", CNT2);
                printf ("|TOTB| %.2f\n", CNT3);
                CNT1 = 0;
                CNT2 = 0;
                CNT3 = 0;
            }
        } else {
            if (substr($1,2,4) == "SUMA") {CNT1 += $2;}
            else if (substr($1,2,4) == "DISC") {CNT2 += $2;}
            else if (substr($1,2,4) == "SUMB") {CNT3 += $2;}
            print;
        }
    }

    END {
        if (CNT1 > 0) {
            printf ("|TOTA| %.2f\n", CNT1);
            printf ("|TOTD| %.2f\n", CNT2);
            printf ("|TOTB| %.2f\n", CNT3);
            CNT1 = 0;
            CNT2 = 0;
            CNT3 = 0;
        }
    }

' > $1.atmkzt




















































#   USD PROCESSING ###################################################

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


    /---Office:----/ {
        i = index ($0, "---Office:---")
        NAME = substr ($0, 1, i - 1)
        }

   /Contract / {
        NAMERES = NAME;
        j = 100000
        for ( i = 1; i <= length(NAMERES); i++ )
        {
         j = i;
         if ( substr (NAMERES, i, 1) != " ") 
         {
           break;
         }
        }
        if ( j != 10000 ) { NAMERES = substr (NAMERES, j); }

        j = length (NAMERES)
        while (j > 0 ) {
          if ( substr (NAMERES, j, 1) != " ") {break}
          j = j - 1
        }
        if (j > 0) { NAMERES = substr (NAMERES, 1, j) }

        CONTRACT = $NF;
        USD = 0;
        REGDT = "";
        for (i=0; i<12; i++) {getline}
        STATYPE = $NF;
        j = NF - 1;
    }


   /USD/ {
        if (STATYPE == "Retail") {
            USD += 1;
            CRC = $2;
            DEVICE = $4;
            if (USD == 1) {
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
            while (1 == 1) {
                if ((length($2) >= 16  && substr ($2,2,3) != "---") || (length($2) == 9 && substr ($2,2,3) != "---")) {
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
    }
' > $1.head1u


# Change numbers format to Pragma standard
cat $1.head1u | awk  '
    {
        if ((substr($1,2,4) == "SUMA") || (substr($1,2,4) == "DISC") || (substr($1,2,4) == "SUMB")) {
            dCnt = split($2, decim, ".");
            pCnt = split(decim[1], parts, ",");
            char Sum;
            Sum = "";
            for (i = 1; i <= pCnt; i++)
                Sum = Sum "" parts[i];
            Sum = Sum "." decim[2];
            print $1 " " Sum;
        } else
            print;
    }
' > $1.head2u

        

cat $1.head2u | awk  '
    BEGIN {
        float CNT1;
        float CNT2;
        float CNT3;
        CNT1 = 0.
        CNT2 = 0.
        CNT3 = 0.
    }

    {
        if ($1 == "###CONTRACT###") {
            if (CNT1 > 0) {
                printf("|TOTA| %.2f\n", CNT1);
                printf("|TOTD| %.2f\n", CNT2);
                printf("|TOTB| %.2f\n", CNT3);
                CNT1 = 0;
                CNT2 = 0;
                CNT3 = 0;
            }
        } else {
            if (substr($1,2,4) == "SUMA") {CNT1 += $2;}
            else if (substr($1,2,4) == "DISC") {CNT2 += $2;}
            else if (substr($1,2,4) == "SUMB") {CNT3 += $2;}
            print;
        }
    }

    END {
        if (CNT1 > 0) {
            printf("|TOTA| %.2f\n", CNT1);
            printf("|TOTD| %.2f\n", CNT2);
            printf("|TOTB| %.2f\n", CNT3);
            CNT1 = 0;
            CNT2 = 0;
            CNT3 = 0;
        }
    }

' > $1.headusd







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


    /---Office:----/ {
        i = index ($0, "---Office:---")
        NAME = substr ($0, 1, i - 1)
        }

   /Contract / {
        NAMERES = NAME;
        j = 100000
        for ( i = 1; i <= length(NAMERES); i++ )
        {
         j = i;
         if ( substr (NAMERES, i, 1) != " ") 
         {
           break;
         }
        }
        if ( j != 10000 ) { NAMERES = substr (NAMERES, j); }

        j = length (NAMERES)
        while (j > 0 ) {
          if ( substr (NAMERES, j, 1) != " ") {break}
          j = j - 1
        }
        if (j > 0) { NAMERES = substr (NAMERES, 1, j) }

        CONTRACT = $NF;
        USD = 0;
        REGDT = "";
        for (i=0; i<12; i++) {getline}
        STATYPE = $NF;
        j = NF - 1;
    }


   /USD/ {
        if (STATYPE == "ATM") {
            USD += 1;
            CRC = $2;
            DEVICE = $4;
            if (USD == 1) {
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
            while (1 == 1) {
                if ((length($2) >= 16  && substr ($2,2,3) != "---") || (length($2) == 9 && substr ($2,2,3) != "---")) {
                    print "\|TRDT\| " $1;
                    print "\|CARD\| " $2;
                    print "\|AUTH\| " $3;
                    print "\|SLIP\| " $4;
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
' > $1.atm1u


# Change numbers format to Pragma standard
cat $1.atm1u | awk  '
    {
        if ((substr($1,2,4) == "SUMA") || (substr($1,2,4) == "DISC") || (substr($1,2,4) == "SUMB")) {
            dCnt = split($2, decim, ".");
            pCnt = split(decim[1], parts, ",");
            char Sum;
            Sum = "";
            for (i = 1; i <= pCnt; i++)
                Sum = Sum "" parts[i];
            Sum = Sum "." decim[2];
            print $1 " " Sum;
        } else
            print;
    }
' > $1.atm2u

        

cat $1.atm2u | awk  '
    BEGIN {
        float CNT1;
        float CNT2;
        float CNT3;
        CNT1 = 0.
        CNT2 = 0.
        CNT3 = 0.
    }

    {
        if ($1 == "###CONTRACT###") {
            if (CNT1 > 0) {
                printf("|TOTA| %.2f\n", CNT1);
                printf("|TOTD| %.2f\n", CNT2);
                printf("|TOTB| %.2f\n", CNT3);
                CNT1 = 0;
                CNT2 = 0;
                CNT3 = 0;
            }
        } else {
            if (substr($1,2,4) == "SUMA") {CNT1 += $2;}
            else if (substr($1,2,4) == "DISC") {CNT2 += $2;}
            else if (substr($1,2,4) == "SUMB") {CNT3 += $2;}
            print;
        }
    }

    END {
        if (CNT1 > 0) {
            printf("|TOTA| %.2f\n", CNT1);
            printf("|TOTD| %.2f\n", CNT2);
            printf("|TOTB| %.2f\n", CNT3);
            CNT1 = 0;
            CNT2 = 0;
            CNT3 = 0;
        }
    }

' > $1.atmusd






cat $1.crlf | awk '
    
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

    /---Office:----/ {
        i = index ($0, "---Office:---")
        NAME = substr ($0, 1, i - 1)
        }


   /Contract / {
        NAMERES = NAME;
        j = 100000
        for ( i = 1; i <= length(NAMERES); i++ )
        {
         j = i;
         if ( substr (NAMERES, i, 1) != " ") 
         {
           break;
         }
        }
        if ( j != 10000 ) { NAMERES = substr (NAMERES, j); }

        j = length (NAMERES)
        while (j > 0 ) {
          if ( substr (NAMERES, j, 1) != " ") {break}
          j = j - 1
        }
        if (j > 0) { NAMERES = substr (NAMERES, 1, j) }

        CONTRACT = $NF;
        KZT = 0;
        REGDT = "";
        for (i=0; i<12; i++) {getline}
        STATYPE = $NF;
        j = NF - 1;
    }


   /KZT/ {
        if (STATYPE == "Cash") {
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
            while (1 == 1) {
                if ((length($2) >= 16  && substr ($2,2,3) != "---") || (length($2) == 9 && substr ($2,2,3) != "---")) {
                    print "\|TRDT\| " $1;
                    print "\|CARD\| " $2;
                    print "\|AUTH\| " $3;
                    print "\|SLIP\| " $4;
                    print "\|NAME\| " NAMERES;
                    print "\|SUMA\| " $(NF-2);
                    print "\|DISC\| " $(NF-1);
                    print "\|SUMB\| " $NF
                    print "\|DEVC\| " DEVICE;
                }
                getline;
                if ($1 == "TOTAL") { print $1; break;}
            }
        }
    }
' > $1.cash1k


# Change numbers format to Pragma standard
cat $1.cash1k | awk  '
    {
        if ((substr($1,2,4) == "SUMA") || (substr($1,2,4) == "DISC") || (substr($1,2,4) == "SUMB")) {
            dCnt = split($2, decim, ".");
            pCnt = split(decim[1], parts, ",");
            char Sum;
            Sum = "";
            for (i = 1; i <= pCnt; i++)
                Sum = Sum "" parts[i];
            Sum = Sum "." decim[2];
            print $1 " " Sum;
        } else
            print;
    }
' > $1.cash2k

        

cat $1.cash2k | awk  '
    BEGIN {
        float CNT1;
        float CNT2;
        float CNT3;
        CNT1 = 0.
        CNT2 = 0.
        CNT3 = 0.
    }

    {
        if ($1 == "###CONTRACT###") {
            if (CNT1 > 0) {
                printf("|TOTA| %.2f\n", CNT1);
                printf("|TOTD| %.2f\n", CNT2);
                printf("|TOTB| %.2f\n", CNT3);
                CNT1 = 0;
                CNT2 = 0;
                CNT3 = 0;
            }
        } else {
            if (substr($1,2,4) == "SUMA") {CNT1 += $2;}
            else if (substr($1,2,4) == "DISC") {CNT2 += $2;}
            else if (substr($1,2,4) == "SUMB") {CNT3 += $2;}
            print;
        }
    }

    END {
        if (CNT1 > 0) {
            printf("|TOTA| %.2f\n", CNT1);
            printf("|TOTD| %.2f\n", CNT2);
            printf("|TOTB| %.2f\n", CNT3);
            CNT1 = 0;
            CNT2 = 0;
            CNT3 = 0;
        }
    }

' > $1.cashkzt


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

    /---Office:----/ {
        i = index ($0, "---Office:---")
        NAME = substr ($0, 1, i - 1)
        }

   /Contract / {
        NAMERES = NAME;
        j = 100000
        for ( i = 1; i <= length(NAMERES); i++ )
        {
         j = i;
         if ( substr (NAMERES, i, 1) != " ") 
         {
           break;
         }
        }
        if ( j != 10000 ) { NAMERES = substr (NAMERES, j); }

        j = length (NAMERES)
        while (j > 0 ) {
          if ( substr (NAMERES, j, 1) != " ") {break}
          j = j - 1
        }
        if (j > 0) { NAMERES = substr (NAMERES, 1, j) }

        CONTRACT = $NF;
        USD = 0;
        REGDT = "";
        for (i=0; i<12; i++) {getline}
        STATYPE = $NF;
        j = NF - 1;
    }


   /USD/ {
        if (STATYPE == "Cash") {
            USD += 1;
            CRC = $2;
            DEVICE = $4;
            if (USD == 1) {
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
            while (1 == 1) {
                if ((length($2) >= 16  && substr ($2,2,3) != "---") || (length($2) == 9 && substr ($2,2,3) != "---")) {
                    print "\|TRDT\| " $1;
                    print "\|CARD\| " $2;
                    print "\|AUTH\| " $3;
                    print "\|SLIP\| " $4;
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
' > $1.cash1u


# Change numbers format to Pragma standard
cat $1.cash1u | awk  '
    {
        if ((substr($1,2,4) == "SUMA") || (substr($1,2,4) == "DISC") || (substr($1,2,4) == "SUMB")) {
            dCnt = split($2, decim, ".");
            pCnt = split(decim[1], parts, ",");
            char Sum;
            Sum = "";
            for (i = 1; i <= pCnt; i++)
                Sum = Sum "" parts[i];
            Sum = Sum "." decim[2];
            print $1 " " Sum;
        } else
            print;
    }
' > $1.cash2u

        

cat $1.cash2u | awk  '
    BEGIN {
        float CNT1;
        float CNT2;
        float CNT3;
        CNT1 = 0.
        CNT2 = 0.
        CNT3 = 0.
    }

    {
        if ($1 == "###CONTRACT###") {
            if (CNT1 > 0) {
                printf("|TOTA| %.2f\n", CNT1);
                printf("|TOTD| %.2f\n", CNT2);
                printf("|TOTB| %.2f\n", CNT3);
                CNT1 = 0;
                CNT2 = 0;
                CNT3 = 0;
            }
        } else {
            if (substr($1,2,4) == "SUMA") {CNT1 += $2;}
            else if (substr($1,2,4) == "DISC") {CNT2 += $2;}
            else if (substr($1,2,4) == "SUMB") {CNT3 += $2;}
            print;
        }
    }

    END {
        if (CNT1 > 0) {
            printf("|TOTA| %.2f\n", CNT1);
            printf("|TOTD| %.2f\n", CNT2);
            printf("|TOTB| %.2f\n", CNT3);
            CNT1 = 0;
            CNT2 = 0;
            CNT3 = 0;
        }
    }

' > $1.cashusd
