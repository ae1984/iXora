/* nostmtrx.p
 * MODULE
	Генератор транзакций
 * DESCRIPTION
	Неподтвержденные сегодняшние операции исполн.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
	8.4
 * AUTHOR
        31/12/99 pragma
 * BASE`s
	BANK

 * CHANGES
    05.06.2013 yerganat  - tz N1487, Внесение изменений в п.м. 2.5.1.9

*/

def shared var g-today as date.
def shared var g-ofc like ofc.ofc.
def var flag as log initial false.
def var fjh as log initial false.


def stream rep.
def var repname as char no-undo init "fileexcel.htm".
def temp-table wrk-forreport
    field jh      like jh.jh
    field sts     like jh.sts
    field ref   like jh.ref
    field sum     like jl.dam
    field name    like cif.name
    field purpose as character
    field who     like jh.who.


display " Ж д и т е ... " with centered row 11 frame gg.
pause 0.

for each jh where jh.jdt = g-today   no-lock on endkey undo ,leave with frame jha.
	if  g-ofc eq jh.who and  jh.sts ne 6  then
	do:
		find first jl of jh no-lock no-error.
		if available jl then
		do:
			flag = true.
            create wrk-forreport.
                wrk-forreport.jh=jh.jh.
                wrk-forreport.sts=jh.sts.
                wrk-forreport.ref=jh.ref.


                /*здесь код назначения платежа*/
                if jh.ref begins "RMZ" then
                do:
                   find first remtrz where remtrz.jh1 = jh.jh no-lock no-error.
                        if avail remtrz then
                        do:
                           wrk-forreport.name = remtrz.ord.
                           wrk-forreport.purpose = remtrz.detpay[1] + " " + remtrz.detpay[2] + " " + remtrz.detpay[3] + " " + remtrz.detpay[4].
                           wrk-forreport.sum = remtrz.amt.
                        end.
                end.
                if jh.ref begins "jou" then
                do:
                   find first joudoc where joudoc.jh = jh.jh no-lock no-error.
                        if avail joudoc then
                        do:
                           find first filpayment where filpayment.jh = jh.jh no-lock no-error.
                           if avail filpayment then
                                wrk-forreport.name = filpayment.name.
                           else do:
                             if joudoc.info <> "-" then
                                 wrk-forreport.name = joudoc.info.
                             else wrk-forreport.name = joudoc.benName.
                           end.
                           wrk-forreport.purpose = joudoc.remark[1] + " " + joudoc.remark[2].
                           if joudoc.dramt <> 0 then
                               wrk-forreport.sum = joudoc.dramt.
                           else
                               wrk-forreport.sum = joudoc.comamt.
                        end.
                end.



                wrk-forreport.who=jh.who.

		end.
	end.
	if keyfunction(lastkey) = "end-error" then leave.
end.

for each wrk-forreport no-lock.
    hide frame gg.
	display wrk-forreport.jh label "транз.Nr"
            wrk-forreport.sts
            wrk-forreport.ref label "номер документа" .
end.


do:
    output stream rep to value(repname).
        put stream rep "<html><head><title>Управленческая отчетность факт</title>" skip
                       "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                       "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

        put stream rep unformatted
            "<b>Неподтвержденные сегодняшние операции исполнителя</b><BR><BR>" skip
            "<table border=1 cellpadding=0 cellspacing=0>" skip
            "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
            "<td width=100> Транз. Nr	</td> " skip
            "<td width=100> Номер документа	</td>" skip
            "<td width=100> Сумма операции	</td>" skip
            "<td width=100> Наименование организации/ФИО</td>" skip
            "<td width=100> Назначение платежа	</td>" skip
            "<td width=100> id исполнителя</td></tr>" skip.

         for each wrk-forreport:
            put stream rep unformatted
                "<tr>" skip
                "<td width=100>" wrk-forreport.jh "</td> " skip
                "<td width=100>" wrk-forreport.ref "</td>" skip
                "<td width=100>" wrk-forreport.sum "</td>" skip
                "<td width=100>" wrk-forreport.name "</td>" skip
                "<td width=100>" wrk-forreport.purpose "</td>" skip
                "<td width=100>" wrk-forreport.who "</td></tr>" skip.
         end.

        put stream rep unformatted "</table></body></html>" skip.

    output stream rep close.

    unix silent value("cptwin " + repname + " excel").
end.
/*
for each aah where aah.regdt = g-today no-lock on endkey undo ,leave with column 50 frame hhh.
	if  g-ofc eq aah.who and aah.stn ne 6 then
	do:
   		find first aal of aah no-lock no-error.
   		if not available aal then next.
   		fjh = false.
    		for each aal of aah no-lock.
     			if aal.jh eq 0 then fjh = true.
    		end.
  		if fjh then
     		do:
     			flag = true.
     			hide frame gg.
     			display aah.aah format 'zzzzzzz9' aah.stn aah.aaa with frame hhh.
    		end.
   	end.
	if keyfunction(lastkey) = "end-error" then leave.
end.
*/
if not flag then
do:
	hide frame gg.
	display  " Нет не подтвержденных операций " with centered row 11 frame nn.
end.
