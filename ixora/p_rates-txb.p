/* p_rates-txb.p
 * MODULE
        PUSH-отчеты - кредиты
 * DESCRIPTION
        Средние ставки по кредитному портфелю
        (КОНСОЛИДИРОВАННО)
        - основная часть отчета, сбор данных по филиалу
 * RUN
        
 * CALLER
        lonrates.p
 * SCRIPT
        
 * INHERIT

 * MENU
        
 * AUTHOR
        28/03/05 sasco
 * CHANGES
 	03/07/06 u00121 - добавил no-undo в таблицу tmp
 			- добавил индекс (idx-tmp2) в tmp
*/

define shared temp-table tmp no-undo
     field rate as decimal
     field ost as decimal
     field crc as int 
     field ostk as decimal
     field cnt as integer 
     field perc as decimal
     index itmp is primary rate
     index idx-tmp2 rate crc.

define shared variable rats as decimal extent 12.
define shared variable ratc as char extent 12.

define variable vres as decimal.
define shared variable v-dt as date initial today.

for each txb.lon no-lock:

    if txb.lon.prem <= 0 then next.

    find first txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
    if not avail txb.cif then next.
    if txb.cif.type <> "B" then next. 

    find last tmp where tmp.rate = txb.lon.prem and tmp.crc = txb.lon.crc no-error.
    if not avail tmp then do:
       create tmp.
       assign
	       tmp.rate = txb.lon.prem
	       tmp.crc = txb.lon.crc
	       tmp.cnt = 0.
    end.

    if v-dt >= 03/05/2004 then 
    	run lonbal_txb ('lon',txb.lon.lon,v-dt,"1,7",no,output vres).
    else 
    	run lon_txb(txb.lon.lon,v-dt - 1,output vres).

    if vres <= 0 then next.

    tmp.ost = tmp.ost + vres.
    tmp.ostk = tmp.ostk + rats[txb.lon.crc] * vres.
    tmp.cnt = tmp.cnt + 1.

end.

