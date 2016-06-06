/* mnprtcn.p
 * MODULE
       Бухгалтерия
 * DESCRIPTION
       Отчет по счетам клиентов для Приложения 2
 * RUN

 * CALLER
        
 * SCRIPT

 * INHERIT

 * MENU
        
 * AUTHOR
        23/09/04 kanat
 * CHANGES
        27/09/04 kanat - убрал ссылки на базу bank и соответствующие .i
        01.09.2010 marinav -   txb.crchis.regdt на txb.crchis.rdt
*/

def shared var v-date-fin as date.
def var v-sbal as decimal.
def var v-abal as decimal.
def var v-gl-string as char init "1321,1322,1323,1326,1327,1328,1401,1403,1405,1407,1409,1411,1417,1420,1421,1422,1423,1424,1425,1429,1458,1552,1733,1734,1740,1741,1748,1752,2064,2066,2067,2068,2203,2210,2211,2215,2217,2219,2221,2223,2224,2225,2226,2227,2228,2230,2232,2255,2552,2706,2718,2719,2720,2721,2723,2725,2726,2741,2742,2743,2745,2746,2747,2748".
def shared var v-operation as char.

def shared temp-table ttmps 
    field aaa as char
    field crc as integer
    field sum as decimal
    field ofc as char
    field gl as integer
    field name as char
    field sector as char
    field balgl as char.

for each txb.aaa where txb.aaa.regdt <= v-date-fin and 
                 lookup(substr(string(txb.aaa.gl), 1, 4), v-gl-string) > 0 and 
                 txb.aaa.sta <> "C" no-lock break by txb.aaa.crc.

find last txb.aab where txb.aab.aaa = txb.aaa.aaa and txb.aab.fdt <= v-date-fin no-lock no-error.
if avail txb.aab and txb.aab.bal <> 0 then do:
if txb.aaa.crc <> 1 then do:
find last txb.crchis where txb.crchis.crc = txb.aaa.crc and txb.crchis.rdt <= v-date-fin no-lock no-error.                
v-sbal = txb.aab.bal.
v-abal = v-sbal * txb.crchis.rate[1].
end.
else
v-abal = txb.aab.bal.


find first txb.cif where txb.cif.cif = txb.aaa.cif and 
		     substr(string(txb.cif.geo), 3, 1) = "2" and 
                     caps(txb.cif.type) = "B" and 
                     not txb.cif.prefix begins "Представ" and 
                     not txb.cif.prefix begins "Представит-во" and 
                     not txb.cif.prefix begins "Филиал" and 
                     not txb.cif.prefix begins "Фил-л" and 
                     not txb.cif.prefix begins "Пред-во" and
                     not txb.cif.prefix begins "Представ-во"
                     no-lock no-error.                       /*ЮЛ и нерезиденты*/ 

if avail txb.cif then do:

find txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.d-cod = "secek" and 
(txb.sub-cod.ccode = "5" or txb.sub-cod.ccode = "6" or txb.sub-cod.ccode = "7" or txb.sub-cod.ccode = "8") no-lock no-error.
if avail txb.sub-cod then do:

create ttmps.
       update ttmps.aaa    = txb.aaa.aaa
              ttmps.crc    = txb.aaa.crc
              ttmps.sum    = abs(v-abal)
              ttmps.ofc    = txb.aaa.who
              ttmps.gl     = txb.aaa.gl
              ttmps.name   = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name))
              ttmps.sector = txb.sub-cod.ccode 
              ttmps.balgl  = substr(string(ttmps.gl),1,4) + "2" + ttmps.sector + if ttmps.crc = 1 then "1" else if ttmps.crc = 2 or ttmps.crc = 11 then "2" else "3".
end.
end.
end.
end.

for each txb.arp where lookup(substr(string(txb.arp.gl), 1, 4), v-gl-string) > 0 and 
                       substr(string(txb.arp.geo), 3, 1) = "2" no-lock.
find first txb.gl where txb.gl.gl = txb.arp.gl no-lock no-error.

find last txb.hisarp where txb.hisarp.arp = txb.arp.arp and txb.hisarp.fdt <= v-date-fin no-lock no-error.
if avail txb.hisarp then do:
if txb.arp.crc <> 1 then do:
find last txb.crchis where txb.crchis.crc = txb.arp.crc and txb.crchis.rdt <= v-date-fin no-lock no-error.

                if txb.gl.type = "A" then
		v-sbal = txb.hisarp.dam[1] - txb.hisarp.cam[1].
		else 
		v-sbal = txb.hisarp.cam[1] - txb.hisarp.dam[1].

v-abal = v-sbal * txb.crchis.rate[1].
end.
else do: 
                if txb.gl.type = "A" then
		v-abal = txb.hisarp.dam[1] - txb.hisarp.cam[1].
		else 
		v-abal = txb.hisarp.cam[1] - txb.hisarp.dam[1].
end.
end.


else do:
if txb.arp.crc <> 1 then do:
find last txb.crchis where txb.crchis.crc = txb.arp.crc and txb.crchis.rdt <= v-date-fin no-lock no-error.

                if txb.gl.type = "A" then
		v-sbal = txb.arp.dam[1] - txb.arp.cam[1].
		else 
		v-sbal = txb.arp.cam[1] - txb.arp.dam[1].

v-abal = v-sbal * txb.crchis.rate[1].
end.
else do:
                if txb.gl.type = "A" then
		v-abal = txb.arp.dam[1] - txb.arp.cam[1].
		else 
		v-abal = txb.arp.cam[1] - txb.arp.dam[1].
end.
end.


find txb.sub-cod where txb.sub-cod.sub = 'arp' and txb.sub-cod.acc = txb.arp.arp and txb.sub-cod.d-cod = "secek" and 
(txb.sub-cod.ccode = "5" or txb.sub-cod.ccode = "6" or txb.sub-cod.ccode = "7" or txb.sub-cod.ccode = "8") no-lock no-error.
if avail txb.sub-cod then do:

create ttmps.
       update ttmps.aaa    = txb.arp.arp
              ttmps.crc    = txb.arp.crc
              ttmps.sum    = v-abal
              ttmps.ofc    = txb.arp.who
              ttmps.gl     = txb.arp.gl
              ttmps.name   = txb.arp.des
              ttmps.sector = txb.sub-cod.ccode 
              ttmps.balgl  = substr(string(ttmps.gl),1,4) + "2" + ttmps.sector + if ttmps.crc = 1 then "1" else if ttmps.crc = 2 or ttmps.crc = 11 then "2" else "3".

end.
end.

