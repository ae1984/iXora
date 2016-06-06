/* debtxb.p
 * MODULE
        Быстрые деньги
 * DESCRIPTION
        Соотношение должников к кредитному портфелю
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        debtors.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-13-6-5
 * AUTHOR
        05.04.05 saltanat
 * CHANGES
        07.04.05 saltanat Вместо вызова lonbalcrc, сделала - lonbalcrc_txb.
*/

define input parameter v-bank as char.

define shared variable vdt as date extent 3.
define shared temp-table tmp
  field bank      as character
  field sum       as deci extent 3
  field code      as inte
index idx bank
index idc code.


define variable v-lev1  as deci.
define variable v-lev7  as deci.
define variable v-lev9  as deci.
define variable v-lev16 as deci.
define variable i as inte.

for each pkanketa where pkanketa.bank = v-bank and pkanketa.credtype = '6' no-lock:
     if pkanketa.lon <> '' and pkanketa.lon <> ? then do:
         find txb.lon where txb.lon.lon = pkanketa.lon no-lock no-error.
         if not avail txb.lon then next.

         if txb.lon.opnamt <= 0 then next.

         do i = 1 to 3 :
	        v-lev1 = 0 . v-lev7 = 0 . v-lev9 = 0 . v-lev16 = 0 . 
         
         	run lonbalcrc_txb('lon',txb.lon.lon,vdt[i],'1',no,txb.lon.crc,output v-lev1).
         	run lonbalcrc_txb('lon',txb.lon.lon,vdt[i],'7',no,txb.lon.crc,output v-lev7).
         	run lonbalcrc_txb('lon',txb.lon.lon,vdt[i],'9',no,txb.lon.crc,output v-lev9).
         	run lonbalcrc_txb('lon',txb.lon.lon,vdt[i],'16',no,1,output v-lev16).
         
            if v-lev1 + v-lev7 = 0 then next. 
                       
         	run p_add(i,v-bank,v-lev1,v-lev7,v-lev9,v-lev16).
         	run p_add(i,'all',v-lev1,v-lev7,v-lev9,v-lev16).
         end.
         
     end.
end.

procedure p_add.
  define input parameter p-i     as inte.
  define input parameter p-bank  as char.
  define input parameter p-lev1  as deci.
  define input parameter p-lev7  as deci.
  define input parameter p-lev9  as deci.
  define input parameter p-lev16 as deci.
  define variable i as inte.

  do i = 1 to 7 :
   find tmp where tmp.bank = p-bank and tmp.code = i no-error.
   if not avail tmp then do:
    	create tmp.
       	assign tmp.bank = p-bank
       	       tmp.code = i. 
   end.
   
   CASE i:
    WHEN 1 THEN                             tmp.sum[p-i] = tmp.sum[p-i] + 1.
    WHEN 2 THEN do:
                if p-lev7 + p-lev9 > 0 then tmp.sum[p-i] = tmp.sum[p-i] + 1. 
           end.
    WHEN 3 THEN                             tmp.sum[p-i] = tmp.sum[p-i] + p-lev1 + p-lev7.
    WHEN 4 THEN do:
                if p-lev7 + p-lev9 > 0 then tmp.sum[p-i] = tmp.sum[p-i] + p-lev1 + p-lev7 + p-lev9 + p-lev16.
           end.     
    WHEN 5 THEN do:
                if p-lev7 + p-lev9 > 0 then tmp.sum[p-i] = tmp.sum[p-i] + p-lev1 + p-lev7. 
           end.
    WHEN 6 THEN do:
                if p-lev7 + p-lev9 > 0 then tmp.sum[p-i] = tmp.sum[p-i] + p-lev9. 
           end.
    WHEN 7 THEN do:
                if p-lev7 + p-lev9 > 0 then tmp.sum[p-i] = tmp.sum[p-i] + p-lev16. 
           end.
   END CASE.
   
  end. 
     
end.