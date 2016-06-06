/* r-cash1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
	Общийй отчет по проведенным кассовым операциям
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * BASES
        BANK, COMM
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        01/10/08 marinav
 * CHANGES
        18/05/09 marinav - добавлен счет 733960
        27/05/10 marinav - добавлены  733961 733962 733963
        09.06.2010 marinav- уменьшен шрифт
        11.06.10   marinav - добавлены счета 733970 733971
        30.07.2010 marinav - измнена последовательность строк
        12.01.11 marinav - убран внебаланс
        18.07.2011 k.gitalov изменил формат ">>>,>>>,>>>,>>9.99" на ">>>,>>>,>>>,>>9.99-"
        20/07/2011 lyubov - изменила алгоритм подсчета документов по дебету
        15.09.2011 Lyubov исправила cashf.crc = 99, вместо 9
        25/04/2012 evseev  - rebranding. Название банка из sysc.
*/
{nbankBik.i}
def shared var g-ofc like ofc.ofc.
def shared var g-today as date.
def var m-ln    like aal.ln    no-undo.
def var m-dc    like jl.dc    no-undo.
def var m-sumd  like aal.amt   no-undo.
def var m-sumk  like aal.amt   no-undo.
def var m-damk  as inte   no-undo.
def var m-camk  as inte   no-undo.
def var m-cashgl like jl.gl    no-undo.
def var v-bnk as char.
def var v-acc1 as char.
def var v-acc2 as char.

def temp-table cashf
    field crc like crc.crc
    field des as char
    field bal like glbal.dam
    field dam like glbal.dam
    field damk as inte
    field cam like glbal.cam
    field camk as inte.

for each crc where crc.sts <> 9 no-lock:
    create cashf.
    cashf.crc = crc.crc.
    cashf.dam = 0.
    cashf.cam = 0.
end.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
v-bnk = sysc.chval.

find sysc where sysc.sysc = "CASHGL" no-lock no-error.
if available sysc then do:


def var v-from as date .
     v-from = g-today.
     update   v-from label "  Дата отчета"  help " Задайте дату отчета" skip
              with row 8 centered  side-label frame opt title "Задайте дату отчета".
     hide frame  opt.

   m-cashgl = sysc.inval.

find first jl where jl.jdt = v-from no-lock no-error.
if available jl then do:
      for each jl  where jl.jdt = v-from no-lock  break by jl.crc by jl.jh by jl.ln :

   	  if first-of(jl.crc) then do:
	     find crc where crc.crc = jl.crc no-lock no-error.
	     m-sumd = 0. m-damk = 0.
	     m-sumk = 0. m-camk = 0.
             m-ln = 0.
 	  end.

          if jl.gl = m-cashgl then do:
		if jl.dc eq "D" then do:
                   m-sumd = m-sumd + jl.dam.
                   m-damk = m-damk + 1.
                   if jl.jh = m-ln and m-dc = jl.dc then do:
                   find last compaydoc where jl.jh = compaydoc.jh no-lock no-error.
                   if avail compaydoc then m-damk = m-damk - 1.
                   end.
                end.
                else do:
                   m-sumk = m-sumk + jl.cam.
                   if jl.jh ne m-ln then m-camk = m-camk + 1.
                   if jl.jh = m-ln and m-dc ne jl.dc then m-camk = m-camk + 1.
                end.
                m-ln = jl.jh. m-dc = jl.dc.
	  end.

         if last-of(jl.crc) then do:
	    find first cashf where cashf.crc = jl.crc.
	    cashf.dam  = cashf.dam  + m-sumd .
	    cashf.cam  = cashf.cam  + m-sumk .
	    cashf.damk = cashf.damk + m-damk .
	    cashf.camk = cashf.camk + m-camk .
	end.
    end.
end.

m-sumd = 0. m-damk = 0. m-sumk = 0. m-camk = 0. m-ln = 0.
/******************************************************/

/******************************************************/

/******************************************************/

/******************************************************/

/******************************************************/

/******************************************************/

/******************************************************/

/******************************************************/

/******************************************************/

/******************************************************/

/******************************************************/


find first cmp.
define stream rep.
output stream rep to cas.htm.

put stream rep unformatted "<html><head><title>" + v-nbank1 + "</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.



for each crc where crc.sts ne 9 no-lock:
       put stream rep unformatted "<table width=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

       put stream rep unformatted "<tr style=""font:bold"" ><td align=""center"" >Сводная справка о кассовых оборотах за день <BR>".
       put stream rep unformatted "</td></tr>" skip.
       put stream rep unformatted "<tr style=""font:bold"" >"
                                  "<td align=""center"" > за " string(v-from) " г.</td></tr>"  skip.
       put stream rep "</table>" skip.

       put stream rep unformatted "<table width=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"" >"
                  "<td align=""left"" >" cmp.name    format 'x(79)' "</td></tr>"
                  "<tr></tr>"
                   skip.
       put stream rep "</table>" skip.


       put stream rep unformatted "<br><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold;font-size:x-small"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"
                  "<td align=""center"" rowspan=2>Наименование <br> ценностей</td>"
                  "<td align=""center"" rowspan=2>Код <br> вал</td>"
                  "<td rowspan=2>Остаток на <br> начало дня</td>"
                  "<td colspan=2>Приход</td>"
                  "<td colspan=2>Расход</td>"
                  "<td rowspan=2>Остаток на <br> конец дня</td>"
                  "</tr>"
                   skip.

       put stream rep unformatted
                  "<tr style=""font:bold;font-size:x-small"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"
                  "<td >Кол-во <br> док.</td>"
                  "<td >Сумма</td>"
                  "<td >Кол-во <br> док.</td>"
                  "<td >Сумма</td>"
                  "</tr>"
                   skip.

        find first cashf where cashf.crc = crc.crc no-lock no-error.
        find last glday where glday.gl = m-cashgl and glday.crc = crc.crc and glday.gdt < v-from no-lock no-error.
        if available glday then
         put stream rep unformatted "<tr align=""right"" style=""font:bold;font-size:8.0pt""><b>"
                   "<td align=""center"">" crc.code "</td></b>"
                   "<td align=""center"">" crc.crc "</td>"
                   "<td>" glday.bal format ">>>,>>>,>>>,>>9.99-" "</td>" skip
                   "<td align=""center"">" cashf.damk "</td>"
                   "<td>" cashf.dam format ">>>,>>>,>>>,>>9.99-" "</td>" skip
                   "<td align=""center"">" cashf.camk "</td>"
                   "<td>" cashf.cam format ">>>,>>>,>>>,>>9.99-" "</td>" skip
                   "<td>" (glday.bal + (cashf.dam - cashf.cam)) format ">>>,>>>,>>>,>>9.99-" "</td>" skip
                   "</tr>".

        else
         put stream rep unformatted "<tr align=""right"" style=""font:bold;font-size:8.0pt"">"
                   "<td>" crc.code "</td>"
                   "<td></td>" skip
                   "<td>" cashf.dam format ">>>,>>>,>>>,>>9.99-" "</td>" skip
                   "<td>" cashf.cam format ">>>,>>>,>>>,>>9.99-" "</td>" skip
                   "<td></td>" skip
                   "</tr>".

         if crc.crc = 1 then do:
            for each cashf where cashf.crc = 99 no-lock.
                if cashf.des begins "Бланки строгой отчетности"
                      then put stream rep unformatted "<tr align=""right"" style=""font-size:8.0pt"">".
                      else put stream rep unformatted "<tr align=""right"" style=""font:bold;font-size:8.0pt"">".
                      put stream rep unformatted
                          "<td align=""center"">" cashf.des "</td>"
                          "<td align=""center"">" crc.crc "</td>"
                          "<td>" cashf.bal format ">>>,>>>,>>>,>>9.99-" "</td>" skip
                          "<td align=""center"">" cashf.damk "</td>"
                          "<td>" cashf.dam format ">>>,>>>,>>>,>>9.99-" "</td>" skip
                          "<td align=""center"">" cashf.camk "</td>"
                          "<td>" cashf.cam format ">>>,>>>,>>>,>>9.99-" "</td>" skip
                          "<td>" (cashf.bal + (cashf.dam - cashf.cam)) format ">>>,>>>,>>>,>>9.99-" "</td>" skip
                          "</tr>".
            end.
         end.
    put stream rep "</table>" skip.

    put stream rep unformatted "<br><br><table width=100% cellpadding=""7"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr >"
                  "<td colspan=3>Заведующий кассой ______________</td><td ></td><td colspan=3>Обороты сверены с балансовыми <br> данными (лицевым счетом)</td>"
                  "</tr>"
                  "<tr >"
                  "<td align=""center"" colspan=3>(подпись)</td><td ></td><td colspan=3>______________________</td>"
                  "</tr>"
                  "<tr >"
                  "<td colspan=3></td><td ></td><td colspan=3>(подпись бухгалтера)</td>"
                  "</tr></table>"
                  skip.

    put stream rep "<br clear=all style='page-break-before:always'>" skip.
end.

end.
else do:
    message "Нет записи CASHGL в sysc".
end.


put stream rep "</body></html>" skip.
output stream rep close.

unix silent cptwin cas.htm winword.



