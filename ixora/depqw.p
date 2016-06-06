/* depqw.p
 * MODULE
       Бухгалтерия
 * DESCRIPTION
       Временная структура депозитов
 * RUN

 * CALLER
        
 * SCRIPT

 * INHERIT

 * MENU
        
 * BASES
        BANK COMM TXB
 * AUTHOR
        21/07/04 kanat
 * CHANGES
        22/07/04 kanat - добавил доп. условие по просьбе заказчика - aaa.rate <> 0
        13/10/04 kanat - переделал для БД txb
*/

def shared temp-table ttmps
           field aaa as char
    	   field bal as decimal
           field crc as integer
           field regdt as date
           field expdt as date
           field quarter as integer
           field cif as char
           field year as integer.

def shared temp-table ttmps1
           field aaa as char
           field bal as decimal
           field crc as integer
           field regdt as date
           field expdt as date
           field quarter as integer
           field cif as char
           field year as integer.

def shared var v-date-begin as date.
def shared var v-date-qw as date.
def shared var v-date-fin as date.

def var v-cnt as integer init 1.
           
for each txb.aaa where txb.aaa.expdt >= v-date-qw and txb.aaa.expdt <= v-date-fin and txb.aaa.sta <> "C" and txb.aaa.rate <> 0 no-lock break by txb.aaa.expdt.
find first txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock no-error.
if avail txb.lgr then do:
find first txb.cif where txb.cif.cif = txb.aaa.cif and
                     caps(txb.cif.type) <> "B"
                     no-lock no-error.
if avail txb.cif then do:
find last txb.aab where txb.aab.aaa = txb.aaa.aaa and txb.aab.fdt <= v-date-begin no-lock no-error.
if avail txb.aab and txb.aab.bal <> 0 then do:
create ttmps no-error.
update ttmps.aaa = txb.aaa.aaa
       ttmps.bal = txb.aab.bal 
       ttmps.crc = txb.aaa.crc 
       ttmps.regdt = txb.aaa.regdt       
       ttmps.expdt = txb.aaa.expdt 
       ttmps.cif = txb.aaa.cif 
       ttmps.quarter = round(month(txb.aaa.expdt) / 4,0) + 1 
       ttmps.year = year(txb.aaa.expdt) no-error.  

end.
end.
end.
end.


for each txb.aaa where txb.aaa.expdt >= v-date-qw and txb.aaa.expdt <= v-date-fin and txb.aaa.sta <> "C" and txb.aaa.rate <> 0 no-lock break by txb.aaa.expdt.
find first txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock no-error.
if avail txb.lgr then do:
find first txb.cif where txb.cif.cif = txb.aaa.cif and
                     caps(txb.cif.type) = "B"
                     no-lock no-error.
if avail txb.cif then do:
find last txb.aab where txb.aab.aaa = txb.aaa.aaa and txb.aab.fdt <= v-date-begin no-lock no-error.
if avail txb.aab and txb.aab.bal <> 0 then do:
create ttmps1 no-error.
update ttmps1.aaa = txb.aaa.aaa
       ttmps1.bal = txb.aab.bal 
       ttmps1.crc = txb.aaa.crc 
       ttmps1.regdt = txb.aaa.regdt       
       ttmps1.expdt = txb.aaa.expdt 
       ttmps1.cif = txb.aaa.cif 
       ttmps1.quarter = round(month(txb.aaa.expdt) / 4,0) + 1 
       ttmps1.year = year(txb.aaa.expdt) no-error.  
end.
end.
end.
end.

