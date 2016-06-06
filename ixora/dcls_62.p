/* dcls62.p
 * MODULE
        dayclose.p
 * DESCRIPTION
        Процедура предназначена для закрытия льгот в тарификаторе для клиентов с недействующими счетами.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        dayclose.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        29.03.05 saltanat 
 * CHANGES
        05.07.2005 saltanat - Выборка льгот по счетам.
*/
{global.i}

FUNCTION f_lgr RETURNS char (INPUT v-lgr as char ).
    find lgr where lgr.lgr = v-lgr no-lock no-error.
    if avail lgr then return lgr.led.
    else return ''.
END FUNCTION.

for each cif where cif.type begins 'B' no-lock:
    find first aaa where aaa.cif eq cif.cif
                     and aaa.sta ne 'C'
                     and f_lgr(aaa.lgr) ne 'ODA'
                     no-lock no-error.
    if avail aaa then next.
    else do:
        for each tarifex where tarifex.cif = cif.cif and tarifex.stat = 'r' exclusive-lock:
	    assign 
    	    tarifex.stat   = 'h'
       		tarifex.who    = g-ofc
       		tarifex.whn    = g-today
	        tarifex.wtim   = time
	        tarifex.akswho = g-ofc
	        tarifex.akswhn = g-today
	        tarifex.awtim  = time
	        tarifex.delwho = g-ofc
	        tarifex.delwhn = g-today
	        tarifex.dwtim  = time. 
    	run tarifexhis_update. 
		end. /* tarifex */
    	
    	for each tarifex2 where tarifex2.cif = tarifex.cif and tarifex2.stat = 'r' exclusive-lock:
    	    assign 
                tarifex2.stat   = 'h'
	       		tarifex2.who    = g-ofc
       			tarifex2.whn    = g-today
	        	tarifex2.wtim   = time
		        tarifex2.akswho = g-ofc
		        tarifex2.akswhn = g-today
	    	    tarifex2.awtim  = time
	        	tarifex2.delwho = g-ofc
	        	tarifex2.delwhn = g-today
	        	tarifex2.dwtim  = time. 
    		run tarifex2his_update.  
    	end. /* tarifex2 */
    	
    end. /* not avail aaa */
end. /* cif */

/* ---- процедура сохранения истории при добавлении и изменении данных" ---- */
procedure tarifexhis_update.
	create tarifexhis.
	buffer-copy tarifex to tarifexhis.
end procedure.

procedure tarifex2his_update.
	create tarifex2his.
	buffer-copy tarifex2 to tarifex2his.
end procedure.
