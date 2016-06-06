#!/bin/sh
##############################################################################
#
# aiftp.sh
# The script will ftp files with the mask of $AIDBNAME* from AI_TO_DR dir to
# DR server. Make a list of everything that was ftped in ftp.out
# and then move files that were ftped to AIBACKUP directory
#
# Here I ftp file with the name of TMP_*, so the file would not be taken
# for processing on DR server before FTP is finished. I rename it at the end.
#
##############################################################################

# FTP a file and make a list of everything that was ftped in ftp.out
ftp_func() {

ftp -n -v <<EOF
open $BACKUPSERVER
user bankadm Bflv0202
binary
cd $REMOTE_DIR
put ${FILE_NAME} TMP_${FILE_NAME}
rename TMP_${FILE_NAME} $FILE_NAME
mls ${AIDBNAME}* ftp.out
bye
EOF

}
# after FTP move ai files from AI_TO_DR directory to AIBACKUP
move_func() {

if [ -f ftp.out ]
then
  for FTP_LIST in `cat ftp.out`
  do
    if [ -f $FTP_LIST ]
    then
      mv $FTP_LIST $AIBACKUP/$BKDATE
    fi
  done
fi
}

# gzip to compress it about 5 times
zip_func() {

  /usr/bin/gzip -c1 $FILE_NAME > ${FILE_NAME}.gz
}

# Main block
rm -f ftp.out
cd $AITODR
for FILE_NAME in `ls $AIDBNAME*`
do
  ftp_func;
  move_func;
  rm -f ftp.out
done
