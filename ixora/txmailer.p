/* txmailer.p
 * MODULE
        Налоговые 
 * DESCRIPTION
        Отправка e-mail по налоговым комитетам (TXB00 only)
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
        28/01/04 sasco
 * CHANGES
*/


{yes-no.i}
{comm-txb.i}
{gl-utils.i}

define shared variable g-ofc as char.
define shared variable g-today as date.

define variable seltxb as integer.
seltxb = comm-cod().


define variable v-dt as date.
v-dt = g-today.

update v-dt label "Введите дату" with row 1 centered side-labels overlay title "" frame getdatfr.
hide frame getdatfr.

{txnkmail.i

 &operation = " отправка реестра по "
 &proc = "
          v-mail = taxnk.email.
          update v-mail with frame fm.
          hide frame fm.
          run SEND_TAX.
         "
}


procedure SEND_TAX.

find first tax where tax.txb = seltxb and tax.date = v-dt and tax.rnn_nk = taxnk.rnn and tax.deldate = ? no-lock no-error.
if not avail tax then do: 
   message "За " v-dt " налоговых платежей~nпо " taxnk.name "~nне было!" view-as alert-box title "".
   return.
end.

output to tax.html.
{html-start.i}
put unformatted "<H4>" taxnk.name "(" taxnk.rnn ")</H4>" skip.
put unformatted "<H4>Дата: " v-dt format "99/99/9999" "</H4>" skip.
put unformatted "<table width=""500"" border=""1"" cellpadding=""0"" cellspacing=""0"" style=""font-size:12px; border-collapse: collapse"">" SKIP. 
put unformatted "<tr>" skip.
put unformatted "<td>Номер пачки</td>" skip.
put unformatted "<td>Номер квит.</td>" skip.
put unformatted "<td>РНН плательщика</td>" skip.
put unformatted "<td>КБК</td>" skip.
put unformatted "<td align=""right"">Сумма</td>" skip.
put unformatted "<td align=""right"">КНП</td>" skip.
put unformatted "</tr>" skip.
for each tax where tax.txb = seltxb and tax.date = v-dt and tax.rnn_nk = taxnk.rnn and tax.deldate = ? no-lock by tax.kb by tax.dnum:
   accumulate tax.sum (total).
   accumulate tax.sum (count).
   put unformatted "<tr>" skip.
   put unformatted "<td>" tax.gr "</td>" skip.
   put unformatted "<td>" tax.dnum "</td>" skip.
   put unformatted "<td>" tax.rnn "</td>" skip.
   put unformatted "<td>" tax.kb "</td>" skip.
   put unformatted "<td align=""right"">" XLS-NUMBER (tax.sum) "</td>" skip.
   if tax.intval[1] = 0 then put unformatted "<td align=""right"">" taxnk.knp format "x(3)" "</td>" skip.
                        else put unformatted "<td align=""right"">" tax.intval[1] format "zz9" "</td>" skip.
   put unformatted "</tr>" skip.
end.

put unformatted "</table>" skip.

put unformatted "<H4>ИТОГО: " accum count (tax.sum) " платежей на сумму " accum total (tax.sum) "</H4>" skip.

{html-end.i}
output close.

if not yes-no ("", "Отправить реестр платежей~n" + taxnk.name + "~nпо адресу " + v-mail) then leave.

run savelog ("taxmail", "Отправка реестра платежей за " + string (v-dt, "99/99/9999") + ", " + 
             TRIM (taxnk.name) + ", РНН НК " + taxnk.rnn + ", по адресу " + v-mail).

unix silent value ("cp tax.html tmp-tax.html").
unix silent value ("un-win tmp-tax.html tax.html").
unix silent value ("rm tmp-tax.html").
run mail (v-mail, "TEXAKABANK<abpk@elexnet.kz>","Реестр платежей",
"В приложении содержится выписка по принятым налоговым платежам","1","","tax.html") .

end procedure.
