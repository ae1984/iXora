/* chkcon.p
 * MODULE
        Платежные системы
 * DESCRIPTION
        Отчет для контроля денежных средств по чекам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        05.11.2004 saltanat
 * CHANGES
*/

{mainhead.i}
{rkorepfun.i}

def var v-dtb  as date.
def var v-dte  as date.
def var v-trx  as char init 'OCK0003,OCK0043,OCK0018'.
def var i      as inte.
def var itog   as deci init 0 extent 5. /* * * USD   * * */
def var itogE  as deci init 0 extent 5. /* * * EURO  * * */
def var itogR  as deci init 0 extent 5. /* * * RUB   * * */
def var itogT  as deci init 0 extent 5. /* * * TENGE * * */

def temp-table cheks
    field id   as   inte
    field jh   like jl.jh
    field fio  as   char
    field arp  as   char
    field dt1  as   date
    field pay1 as   deci    init 0
    field crc1 like crc.crc
    field pay2 as   deci    init 0
    field crc2 like crc.crc
    field pay3 as   deci    init 0
    field crc3 like crc.crc
    field dt3  as   date
    field pay4 as   deci    init 0
    field crc4 like crc.crc
    field dt4  as   date
    field pay5 as   deci    init 0
    field crc5 like crc.crc. 

form
   skip(1)
      v-dtb label ' Начало периода' format '99/99/9999' skip
      v-dte label ' На дату '       format '99/99/9999' skip(1)
with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА" frame f-dt.

v-dtb = g-today.
v-dte = g-today.

update v-dtb v-dte with frame f-dt.

i = 0.

for each jl where jl.jdt >= v-dtb and jl.jdt <= v-dte 
              and jl.gl <> 0 no-lock. 

 if lookup(jl.trx,v-trx) > 0 then do:

  find ujo where ujo.jh = jl.jh no-lock no-error.
  if avail ujo then do:


   for each ujolink where ujolink.docnum = ujo.docnum no-lock:

    if ujolink.parnum = 1 then do:
	    /* * *  Чек, принятый на процедуру инкассо  * * */
	    if jl.trx = 'OCK0003' and jl.gl = 715010 then do:
               find first cheks where cheks.jh = jl.jh no-lock no-error.
               if not avail cheks then do:
		    i = i + 1.
		    create cheks.
		    assign cheks.id = i
		           cheks.jh = jl.jh.
               end.

	       cheks.dt1  = jl.jdt.
	       cheks.pay2 = decimal(ujolink.parval).
	       cheks.crc2 = jl.crc.
               
               if jl.crc = 2 then
               itog[2]    = itog[2] + decimal(ujolink.parval).
               else if jl.crc = 11 then
               itogE[2]    = itogE[2] + decimal(ujolink.parval).
               else if jl.crc = 4 then
               itogR[2]    = itogR[2] + decimal(ujolink.parval).
               else if jl.crc = 1 then
               itogT[2]    = itogT[2] + decimal(ujolink.parval).
	    end.
	    /* * *  Выплата по чеку  * * */
	    if jl.trx = 'OCK0043' and jl.gl = 187010 then do:
               find first cheks where cheks.jh = jl.jh no-lock no-error.
               if not avail cheks then do:
		    i = i + 1.
		    create cheks.
		    assign cheks.id = i
		           cheks.jh = jl.jh.
               end.

           cheks.dt1  = jl.jdt.
	       cheks.pay1 = decimal(ujolink.parval).
	       cheks.crc1 = jl.crc.

               if jl.crc = 2 then
               itog[1]    = itog[1] + decimal(ujolink.parval).
               else if jl.crc = 11 then
               itogE[1]    = itogE[1] + decimal(ujolink.parval).
               else if jl.crc = 4 then
               itogR[1]    = itogR[1] + decimal(ujolink.parval).
               else if jl.crc = 1 then
               itogT[1]    = itogT[1] + decimal(ujolink.parval).

	    end.
	    /* * *  Выплата после процедуры инкассо  * * */
	    if jl.trx = 'OCK0043' and jl.gl = 287012 then do:
               find first cheks where cheks.jh = jl.jh no-lock no-error.
               if not avail cheks then do:
		    i = i + 1.
		    create cheks.
		    assign cheks.id = i
		           cheks.jh = jl.jh.
               end.

	       cheks.dt4  = jl.jdt.
	       cheks.pay4 = decimal(ujolink.parval).
	       cheks.crc4 = jl.crc.

               if jl.crc = 2 then
               itog[4]    = itog[4] + decimal(ujolink.parval).
               else if jl.crc = 11 then
               itogE[4]    = itogE[4] + decimal(ujolink.parval).
               else if jl.crc = 4 then
               itogR[4]    = itogR[4] + decimal(ujolink.parval).
               else if jl.crc = 1 then
               itogT[4]    = itogT[4] + decimal(ujolink.parval).

	    end.
	    /* * *  Покрытие  * * */
	    if jl.trx = 'OCK0018' then do:      
               find first cheks where cheks.jh = jl.jh no-lock no-error.
               if not avail cheks then do:
		    i = i + 1.
		    create cheks.
		    assign cheks.id = i
		           cheks.jh = jl.jh.
               end.

	       cheks.dt3  = jl.jdt.
	       cheks.pay3 = decimal(ujolink.parval).
	       cheks.crc3 = jl.crc.      

               if jl.crc = 2 then
               itog[3]    = itog[3] + decimal(ujolink.parval).
               else if jl.crc = 11 then
               itogE[3]    = itogE[3] + decimal(ujolink.parval).
               else if jl.crc = 4 then
               itogR[3]    = itogR[3] + decimal(ujolink.parval).
               else if jl.crc = 1 then
               itogT[3]    = itogT[3] + decimal(ujolink.parval).

	    end.
    end. /* parnum = 1 */

    else if ujolink.parnum = 2 then do:
       find first cheks where cheks.jh = jl.jh no-lock no-error.
       if not avail cheks then do:
          i = i + 1.
          create cheks.
          assign cheks.id = i
                 cheks.jh = jl.jh.
       end.

       cheks.arp = ujolink.parval.
    end.

    else if ujolink.parnum = 3 then do:
       find first cheks where cheks.jh = jl.jh no-lock no-error.
       if not avail cheks then do:
          i = i + 1.
          create cheks.
          assign cheks.id = i
                 cheks.jh = jl.jh.
       end.

       cheks.fio = ujolink.parval.
    end.

   end. /* * * ujolink * * */

  end. /* * * ujo * * */

 end.

end.

/* вывод отчета в HTML */

def stream vcrpt.
output stream vcrpt to vcreestr.htm.

{html-title.i 
 &stream = " stream vcrpt "
 &title = "Отчет по движению денежных средств по чекам"
 &size-add = "xx-"
}

put stream vcrpt unformatted 
   "<P align = ""left""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
   "<B>Отчет по движению денежных средств по чекам<BR>за период с " + string(v-dtb, "99/99/9999") + 
       " по " + string(v-dte, "99/99/9999") + "</B></FONT></P>" skip

   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"" bordercolor=#d8e4f8>" skip.
put stream vcrpt unformatted 
   "<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8 bgcolor=#afcbfd>" skip
     "<TD><FONT size=""2""><B>п/н</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Транзакция<BR>исполнителя</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>ФИО</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>ARP<BR>карточка</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Дата<BR>принятия</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Выплата<BR>по чеку</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Инкассо</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Сумма<BR>покрытия</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Дата<BR>покрытия</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Выплата<BR>после<BR>процедуры<BR>инкассо</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Дата<BR>выплаты</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Остаток</B></FONT></TD>" skip
   "</TR>" skip.

for each cheks break by cheks.fio.
   put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD><FONT size=""2"">" + string(cheks.id) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + string(cheks.jh) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + cheks.fio        + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + cheks.arp        + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if cheks.dt1  = ? then '' else string(cheks.dt1, "99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if cheks.pay1 = 0 then '' else string(cheks.pay1) + ' = ' + def_valute(cheks.crc1) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if cheks.pay2 = 0 then '' else string(cheks.pay2) + ' = ' + def_valute(cheks.crc2) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if cheks.pay3 = 0 then '' else string(cheks.pay3) + ' = ' + def_valute(cheks.crc3) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if cheks.dt3  = ? then '' else string(cheks.dt3, "99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if cheks.pay4 = 0 then '' else string(cheks.pay4) + ' = ' + def_valute(cheks.crc4) + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if cheks.dt4  = ? then '' else string(cheks.dt4, "99/99/99") + "</FONT></TD>" skip
     "<TD><FONT size=""2"">" + if cheks.pay5 = 0 then '' else string(cheks.pay5) + ' = ' + def_valute(cheks.crc5) + "</FONT></TD>" skip
   "</TR>" skip.
end.

if itog[1] + itog[2] + itog[3] + itog[4] + itog[5] > 0 then 
put stream vcrpt unformatted 
   "<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8 bgcolor=#afcbfd>" skip
     "<TD><FONT size=""2""><B>Итого в USD</B></FONT></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itog[1] / 2) + "</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itog[2]) + "</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itog[3]) + "</B></FONT></TD>" skip
     "<TD></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itog[4]) + "</B></FONT></TD>" skip
     "<TD></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itog[5]) + "</B></FONT></TD>" skip
   "</TR>" skip.

if itogE[1] + itogE[2] + itogE[3] + itogE[4] + itogE[5] > 0 then 
put stream vcrpt unformatted 
   "<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8 bgcolor=#afcbfd>" skip
     "<TD><FONT size=""2""><B>Итого в EUR</B></FONT></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itogE[1] / 2) + "</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itogE[2]) + "</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itogE[3]) + "</B></FONT></TD>" skip
     "<TD></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itogE[4]) + "</B></FONT></TD>" skip
     "<TD></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itogE[5]) + "</B></FONT></TD>" skip
   "</TR>" skip.

if itogR[1] + itogR[2] + itogR[3] + itogR[4] + itogR[5] > 0 then 
put stream vcrpt unformatted 
   "<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8 bgcolor=#afcbfd>" skip
     "<TD><FONT size=""2""><B>Итого в RUB</B></FONT></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itogR[1] / 2) + "</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itogR[2]) + "</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itogR[3]) + "</B></FONT></TD>" skip
     "<TD></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itogR[4]) + "</B></FONT></TD>" skip
     "<TD></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itogR[5]) + "</B></FONT></TD>" skip
   "</TR>" skip.

if itogT[1] + itogT[2] + itogT[3] + itogT[4] + itogT[5] > 0 then 
put stream vcrpt unformatted 
   "<TR align=""center"" valign=""bottom"" bordercolor=#d8e4f8 bgcolor=#afcbfd>" skip
     "<TD><FONT size=""2""><B>Итого в TENGE</B></FONT></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itogT[1] / 2) + "</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itogT[2]) + "</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itogT[3]) + "</B></FONT></TD>" skip
     "<TD></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itogT[4]) + "</B></FONT></TD>" skip
     "<TD></TD>" skip
     "<TD><FONT size=""2""><B>" + string(itogT[5]) + "</B></FONT></TD>" skip
   "</TR>" skip.

put stream vcrpt unformatted  
"</TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

hide message no-pause.

unix silent cptwin vcreestr.htm excel.



