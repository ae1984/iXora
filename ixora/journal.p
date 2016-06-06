/* journal.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        30/09/2008 galina
 * BASES
        BANK
 * CHANGES
*/

def var v-journal as char no-undo.
def var v-sel as integer no-undo.
def var v-journalch as char no-undo. 
 
 
 
for each codfr where codfr.codfr = "journals" and codfr.code <> "msc" no-lock:
 if v-journalch <> "" then v-journalch = v-journalch + " |".
  v-journalch = v-journalch + string(codfr.code) + " " + codfr.name[1].
end.
    v-sel = 0.
    run sel2 (" ВЫБЕРИТЕ ЖУРНАЛ ", v-journalch, output v-sel).
    if v-sel = 0 then return.
    v-journal = trim(entry(1,(entry(v-sel,v-journalch, '|')),' ')).
    CASE v-journal:
    	WHEN "01" THEN run jcontract.
    		
    	WHEN "02" THEN run jorder.
    		
    	WHEN "03" THEN run jcommand.
    
    	WHEN "04" THEN run joperation.
    		
    	WHEN "05" THEN run jdeal(0, "Журнал заключенных сделок").
    		
    	WHEN "06" THEN run jdeal(1, "Журнал исполненных сделок").
    
    	WHEN "07" THEN run jdeal(2, "Журнал неисполненных сделок").
    		
    	WHEN "08" THEN  run jsecurities.
    		
    	WHEN "09" THEN run jmoney.
    	
    	WHEN "10" THEN run jprofit.
    	
    	WHEN "11" THEN run jcomplaint.
    	
    	WHEN "12" THEN run jreports.
		
    END CASE.

hide all no-pause.    