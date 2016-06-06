/* r-cash2.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
	отчет по проведенным кассовым операциям по кассиру
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * BASES
        BANK COMM
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        02/10/08 marinav
 * CHANGES
        29.07.2010 marinav - добавлено название СП
        13.01.2011 aigul - вывод значения "-" для поля "Остаток на конец дня"
        20/07/2011 lyubov - изменила алгоритм подсчета документов по дебету
        25/04/2012 evseev  - rebranding. Название банка из sysc.
        24.05.2012 Lyubov - в связи с переходом на раздельное формирование касс. ордеров, по комм. платежам сумму и комиссию считаем за 2 док-та
        30.09.2013 damir - Внедрено Т.З. № 1496.
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

def var v-av1 as deci. /*аванс*/
def var v-av2 as deci. /*остаток*/
def var v-av3 as deci. /*принято*/
def var v-av4 as deci. /*передано*/

def temp-table cashf
    field crc like crc.crc
    field dam like glbal.dam
    field damk as inte
    field cam like glbal.cam
    field camk as inte.

define temp-table wrk1 no-undo
    field gl  like jl.gl
    field jh  like jl.jh
    field dam like jl.dam
    field cam like jl.cam
    field crc like jl.crc
    field who like jl.who
    field tim as char
    field tel like jl.teller
    field rem as char
    field dc  like jl.dc
    field cd  as   inte
    index ind is PRIMARY cd cam dam.

for each crc where crc.sts <> 9 no-lock:
    create cashf.
    cashf.crc = crc.crc.
    cashf.dam = 0.
    cashf.cam = 0.
end.

find sysc where sysc.sysc = "CASHGL" no-lock no-error.
if available sysc then do:


def var v-from as date .
     v-from = g-today.
     update   v-from label "  Дата отчета"  help " Задайте дату отчета" skip
              with row 8 centered  side-label frame opt title "Задайте дату отчета".
     hide frame  opt.

   m-cashgl = sysc.inval.

find first jl where jl.jdt = v-from and jl.teller = g-ofc no-lock no-error.
if available jl then do:
    for each jl  where jl.jdt = v-from and jl.teller = g-ofc no-lock  break by jl.crc by jl.jh by jl.ln :
        if first-of(jl.crc) then do:
            find crc where crc.crc = jl.crc no-lock no-error.
            m-sumd = 0. m-damk = 0.
            m-sumk = 0. m-camk = 0.
            m-ln = 0.
            empty temp-table wrk1.
        end.

        if jl.gl = m-cashgl then do:
            if not (jl.rem[1] + jl.rem[2] matches "*обмен валюты*") then
            find first wrk1 where wrk1.jh = jl.jh and wrk1.crc = jl.crc and wrk1.dc = jl.dc and not (wrk1.rem matches "*обмен валюты*")  no-error.
            else
            find first wrk1 where wrk1.jh = jl.jh and wrk1.crc = jl.crc and wrk1.dc = jl.dc and wrk1.rem matches "*обмен валюты*"  no-error.
            if not available wrk1 then do:
                create wrk1.
                wrk1.jh = jl.jh.
                wrk1.crc = jl.crc.
                wrk1.dam = jl.dam.
                wrk1.cam = jl.cam.
                wrk1.dc = jl.dc.
                wrk1.cd = if wrk1.dc = 'D' then 1 else 2.
            end.
            else do:
                wrk1.dam = wrk1.dam + jl.dam.
                wrk1.cam = wrk1.cam + jl.cam.
            end.

            if jl.dc eq "D" then m-sumd = m-sumd + jl.dam.
            else m-sumk = m-sumk + jl.cam.
        end.

        if last-of(jl.crc) then do:
            for each wrk1 exclusive-lock:
                if wrk1.cd = 1 then m-damk = m-damk + 1.
                if wrk1.cd = 2 then m-camk = m-camk + 1.
            end.

            find first cashf where cashf.crc = jl.crc.
            cashf.dam  = cashf.dam  + m-sumd .
            cashf.cam  = cashf.cam  + m-sumk .
            cashf.damk = cashf.damk + m-damk .
            cashf.camk = cashf.camk + m-camk .
        end.
    end.
end.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
find first codfr where codfr.codfr = "sproftcn" and codfr.code = ofc.titcd no-lock no-error.

find first cmp.
define stream rep.
output stream rep to cas.htm.

put stream rep unformatted "<html><head><title>" + v-nbank1 + "</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.



for each crc where crc.sts ne 9 no-lock:

       put stream rep unformatted "<br><table width=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"" >"
                  "<td align=""center"">" cmp.name format 'x(79)' "</td></tr>"
                  "<tr style=""font:bold"" >"
                  "<td align=""center"">" codfr.name[1] format 'x(79)' "</td></tr><br>"
                   skip.
       put stream rep "</table>" skip.

       put stream rep unformatted "<table width=100% border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" skip.

       put stream rep unformatted "<tr><td align=""center"" ><h3>Отчетная справка о кассовых оборотах за день <BR> и остатках ценностей".
       put stream rep unformatted "</h3></td></tr>" skip.
       put stream rep unformatted "<tr style=""font:bold"" >"
                                  "<td align=""center"" ><h3> за " string(v-from) " г.</td></tr>"  skip.
       put stream rep unformatted "<tr><td align=""left"" >" ofc.name "</td></tr>"  skip.

       /*
       put stream rep unformatted "<tr></tr><tr></tr><tr></tr><tr><td align=""left"" ><b>Аванс на начало дня : " crc.code v-av1 format '>>>,>>>,>>>,>>9.99' " <BR>".
       put stream rep unformatted "</td></tr>" skip.
       */
       put stream rep "</table>" skip.

       put stream rep unformatted "<br><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold;font-size:x-small"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"
                  "<td align=""center"" rowspan=3>Наим-ние <br> цен-тей</td>"
                  "<td align=""center"" rowspan=3>Код <br> вал</td>"
                  "<td rowspan=3>Принято <br> ценностей от <br> заведующего <br> кассой на сумму</td>"
                  "<td colspan=4>Обороты за день</td>"
                  "<td rowspan=2>Передано <br> ценностей <br> заведующему <br>кассой на сумму</td>"
                  "<td rowspan=2>Остаток <br> на конец дня </td>"
                  "</tr>" skip.

       put stream rep unformatted
                  "<tr style=""font:bold;font-size:x-small"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"
                  "<td colspan=2>Приход</td>"
                  "<td colspan=2>Расход</td>"
                  "</tr>" skip.

       put stream rep unformatted
                  "<tr style=""font:bold;font-size:x-small"" align=""center"" valign=""top"" bgcolor=""#C0C0C0"">"
                  "<td >Кол-во <br> док-в</td>"
                  "<td >Сумма</td>"
                  "<td >Кол-во <br> док-в</td>"
                  "<td >Сумма</td>"
                  "</tr>" skip.

       v-av1 = 0.
       v-av2 = 0.
       v-av3 = 0.
       v-av4 = 0.

        find first cashf where cashf.crc = crc.crc no-lock no-error.

        for each cashofc where cashofc.whn eq v-from and cashofc.ofc eq g-ofc and cashofc.sts eq 1 and cashofc.crc eq crc.crc no-lock :
             v-av1 = v-av1 + cashofc.amt.
        end.

        for each cashofc where cashofc.whn eq v-from and cashofc.ofc eq g-ofc and cashofc.sts eq 2 and cashofc.crc eq crc.crc no-lock:
            v-av2 = v-av2 + cashofc.amt.
        end.

        for each cashofc where cashofc.whn eq v-from and cashofc.ofc eq g-ofc and cashofc.sts eq 3 and cashofc.crc eq crc.crc no-lock:
            v-av3 = v-av3 + cashofc.amt.
        end.

        for each cashofc where cashofc.whn eq v-from and cashofc.ofc eq g-ofc and cashofc.sts eq 4 and cashofc.crc eq crc.crc no-lock:
            v-av4 = v-av4 + cashofc.amt.
        end.

        put stream rep unformatted "<tr align=""right"" style=""font-size:x-small"">"
                   "<td align=""center"">" crc.code "</td>"
                   "<td align=""center"">" crc.crc  "</td>"
                   "<td>" (v-av3 + v-av1) format ">>>,>>>,>>>,>>9.99" "</td>" skip
                   "<td align=""center"">" cashf.damk "</td>"
                   "<td>" cashf.dam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                   "<td align=""center"">" cashf.camk "</td>"
                   "<td>" cashf.cam format ">>>,>>>,>>>,>>9.99" "</td>" skip
                   "<td>" v-av4 format ">>>,>>>,>>>,>>9.99" "</td>" skip
                   "<td>" v-av2 format "->>>,>>>,>>>,>>9.99" "</td>" skip
                   "</tr>".

        put stream rep "</table>" skip.

        put stream rep unformatted "<br><br><br><br><table width=100% cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
            "<tr><td>Кассовый работник __________________</td><td ></td><td>Обороты проверил</td></tr>"
            "<tr><td>                                    </td><td ></td><td>______________________</td></tr>"
            "<tr><td>Заведующий кассой __________________</td><td ></td><td>(подпись учетно-операционного <br> работника)  </td></tr>"
            "</table>"
            skip.

        if crc.crc ne 6 then put stream rep "<BR><BR><br clear=all style='page-break-before:always'>" skip.
end.

end.
else do:
    message "Нет записи CASHGL в sysc".
end.


put stream rep "</body></html>" skip.
output stream rep close.

unix silent cptwin cas.htm winword.



