#!/bin/sh
#####################################################################################
#
# aitrunc.sh
# 05.09.2003 sasco
# 22.10.2003 suchkov - encrypted password for connect to ftp
#
# The script will check if database is stopped, stop AI journal and truncate AI files
# Then this script will make a full backup of database and copy it through FTP
# to the backup server and generate there .backup file in order to make
# administrator on backup server to stop DB and restore full backup
#
# COMMENT: All backups are in $DBDIR/savedb/AI* directories 
#
#####################################################################################

. /pragma/bin9/dbenv
. /pragma/bin9/aienv

echo -n "Input Administrator Password:"

if [ $passw ]; then
    tes="yes"
    else
    
    passw=`perl -e 'use Term::ReadKey;                                                                                     
             ReadMode("cbreak");                                                                                    
             while ($key ne "\n")                                                                                   
             {                                                                                                      
                 $key = ReadKey(0);                                                                                 
                 if ($key =~ m/[\~\!\@\#\$\%\^\&\*\(\)\-_;:\?,\.<>\{\}\[\]abcdefghijklmnopqrstuvwxyz0123456789]/i)
                 {                                                                                                  
                     $pass = $pass . $key;                                                                          
                     print "*";                                                                                     
                 }                                                                                                  
             }                                                                                                      
             ReadMode("normal");
             print ":$pass";' | awk -F: '{print $2}'`
    
    if [ $passw ]; then 
    
            res=`awk -F: '/bankadm_unix/ {print $2}' /pragma/bin9/passwd`
            tes=`genkey.exe -c $passw $res`
        else
            tes="no"
    fi
    
fi
    
if [ $tes = "yes" ]; then 

echo "\nOK!"

export passw

TIME=`date "+%d-%m-%y.%H-%M"`
TDIR=$SAVEDBDIR/AI$TIME
REST=$TDIR/$DBNAME.res
BKFILE=$DBNAME.Z
RSTFILE=$DBNAME.res

OLDDIR=`pwd`
cd $SAVEDBDIR
mkdir AI$TIME
cd $OLDDIR

###############################################
# FTP a file and make a list of everything that
#  was ftped in ftp.out
#  1. /tmp/.backup
#  2. $DBDIR/save/AI$TIME/$DBNAME.Z
#  3. $REST
###############################################
ftp_func() {

ftp -n -v <<EOF
open $AIBKSERVER
user bankadm $passw
binary
cd $AIAPPLY
put /tmp/.backup .backup
cd $SAVEDBDIR
mkdir AI${TIME}
cd AI${TIME}
put ${TDIR}/${BKFILE} ${BKFILE}
put ${TDIR}/${RSTFILE} ${RSTFILE}
bye
EOF

}


# # # # # # # # # # # # # # # # # # # # # # # #
###############################################
#  M A I N    B L O C K
###############################################
# # # # # # # # # # # # # # # # # # # # # # # #



###############################################
#  1.  Check if DB is stopped ....
###############################################

echo "1. Check DB status..."
if [ -f $DBDIR/$DBNAME.lk ]
then
    echo "aitrunc.sh [$2]: Cannot truncate AI files! You need to stop database server!"
    exit 1
fi


###############################################
#  2.  Stop AI journal
###############################################
echo "2. Stop AI logging..."
rfutil $DBDIR/$DBNAME -C aimage end > /dev/null


###############################################
#  3.  Truncate AI and BI files
###############################################

# AI 
echo "3. Truncate AI..."
rfutil $DBDIR/$DBNAME -C aimage truncate -G 0 > /dev/null

# BI
echo "4. Truncate BI..."
proutil $DBDIR/$DBNAME -C truncate bi -G 0 > /dev/null


###############################################
#  4.  Full copy of database
###############################################

echo "5. Make a full backup..."
aisave $DBDIR/$DBNAME.db $TDIR 


###############################################
#  5. Prepare .backup file for BACKUP server 
###############################################
echo $TDIR > /tmp/.backup


###############################################
#  COMMENT: At this moment we have prepared
#       1.  $TDIR/$DBNAME.Z
#       2.  $TDIR/$DBNAME.res
#       3.  /tmp/.backup
###############################################
###############################################
#  6. Move files to BACKUP server
###############################################
echo "7. Copy files through FTP..."
ftp_func;


###############################################
#  7.  Start AI journal
###############################################
echo "8. Start AI logging..."
rfutil $DBDIR/$DBNAME -C aimage begin > /dev/null


###############################################
#  8.  Clear temp files
###############################################
rm -f /tmp/.backup

#cd $AI_TO_DR
#for FILE_NAME in `ls $AIDBNAME*`
#do
#  ftp_func;
#  move_func;
#  rm -f ftp.out
#done

else 
echo "\nPassword incorrect!"
fi
