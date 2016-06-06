def var dt1     as date.
def var dt2     as date.
def var dt     as date.




dt1 = 01/01/09.
dt2 = 04/04/09.

define stream rep.

output stream rep to /home/id00363/tz/crchis-array.php.

put stream rep unformatted "<? $crc = array(".

repeat dt = dt1 to dt2:

put stream rep unformatted "'" dt format '99.99.9999' "' => array(".

    find last crchis where crchis.rdt <= dt and bank.crchis.crc = 2  and crchis.tim <> 99999 no-lock no-error.

    find first crc where crc.crc = crchis.crc.
           
           put stream rep unformatted  "'" crc.code "' => \"" crchis.rate[1] "\","  skip.
          

    find last crchis where crchis.rdt <= dt and bank.crchis.crc = 3  and crchis.tim <> 99999 no-lock no-error.

    find first crc where crc.crc = crchis.crc.
    
   put stream rep unformatted  "'" crc.code "' => \"" crchis.rate[1] "\","  skip.
   
   find last crchis where crchis.rdt <= dt and bank.crchis.crc = 4  and crchis.tim <> 99999 no-lock no-error.

   find first crc where crc.crc = crchis.crc.

put stream rep unformatted  "'" crc.code "' => \"" crchis.rate[1] "\","  skip.

put stream rep unformatted "),".

end.

put stream rep unformatted  "'' => \" "\""  skip.
put stream rep unformatted "); ?>".

output stream rep close.
