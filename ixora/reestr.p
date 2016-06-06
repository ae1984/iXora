/* reestr.p
 * MODULE
        Коммунальные
 * DESCRIPTION
        Выбор платежей по разным реквизитам
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
        24/03/06 marinav
 * CHANGES
        10.08.2006 marinav оптимизация
*/


{global.i}

define variable datums  as date format '99/99/9999'.
define variable datums1  as date format '99/99/9999'.
define var flag as logi init false.
def var v-kbk as char init  '106105'.
def var v-namenk as char.
def var v-sum as deci.

def temp-table t-tax
    field sqn as char
    field ssum as deci
    field acc as char
    field rnn as char
    field kbk as inte 
    field data as date
    field name as char
    field sum as deci
    field nazp as char
    field rnnbn  as char
    field namebn as char
    index dat IS PRIMARY data rnn 
    index sqn sqn. 

datums = g-today.
datums1 = g-today.

update datums label ' Укажите дату с ' format '99/99/9999' datums1 label ' по ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .

message " Отчет формируется ".


message datums datums1.

for each tax where tax.date >= datums and tax.date <= datums1 and txb = 0 and duid = ?  no-lock use-index dateuid.
    if tax.rnn_nk ne '600500000015' then next.
    if lookup (string(tax.kb), v-kbk) > 0 then do:
       find first taxnk where taxnk.rnn = tax.rnn_nk no-lock no-error.
       if avail taxnk then v-namenk = taxnk.name. else v-namenk = ''.
       create t-tax.
       assign t-tax.rnn = tax.rnn
              t-tax.kbk = tax.kb
              t-tax.name = tax.chval[1]
              t-tax.sum = tax.sum
              t-tax.rnnbn = tax.rnn_nk
              t-tax.namebn = v-namenk. 

       find first remtrz where remtrz.remtrz = tax.senddoc no-lock no-error.
       if avail remtrz then  assign t-tax.acc = remtrz.dracc
                                    t-tax.sqn = remtrz.t_sqn
                                    t-tax.nazp = remtrz.det[1] + remtrz.det[2] + remtrz.det[3]
                                    t-tax.data = remtrz.valdt2.                                

    end.
end.

for each commonpl where txb = 0 and commonpl.date >= datums and commonpl.date <= datums1 and commonpl.deluid = ?  no-lock use-index txbdtgrp.
    if commonpl.rnnbn ne '600500000015' then next.

    if lookup (string(commonpl.kb), v-kbk) > 0 then do:
       find first taxnk where taxnk.rnn = commonpl.rnnbn no-lock no-error.
       if avail taxnk then v-namenk = taxnk.name. else v-namenk = ''.
       create t-tax.                        	
       assign t-tax.rnn = commonpl.rnn
              t-tax.kbk = commonpl.kb
              t-tax.name = commonpl.fio
              t-tax.sum = commonpl.sum
              t-tax.rnnbn = commonpl.rnnbn
              t-tax.namebn = v-namenk. 

       find first remtrz where remtrz.remtrz = commonpl.rmzdoc no-lock no-error.
       if avail remtrz then  assign t-tax.acc = remtrz.dracc
                                    t-tax.sqn = remtrz.t_sqn
                                    t-tax.nazp = remtrz.det[1] + remtrz.det[2] + remtrz.det[3] 
                                    t-tax.data = remtrz.valdt2.                                

    end.
end.

def buffer b-tax for t-tax.
v-sum = 0.

for each t-tax break by t-tax.sqn.
    v-sum = v-sum + t-tax.sum .

    if last-of (t-tax.sqn) then do:
       for each b-tax where b-tax.sqn = t-tax.sqn use-index sqn.
           b-tax.ssum = v-sum.
       end.
       v-sum = 0. 
    end. 
end.


output to rep.html.

{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted   
    "<br><P align=""left"" style=""font:bold"">Документы по налоговым платежам с расшифровкой</P>" skip.

put  unformatted     
         "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
          "<TR align=""center"" style=""font:bold"" bgcolor=""#C0C0C0"">" skip
          "<td align=center>Сводный <br>референс <br>платежа</td>"
          "<td align=center>Сумма сводного<br> платежа</td>"
          "<td align=center>Счет<br> плательщика</td></td>"
          "<td align=center>РНН<br>плательщика</td>"
          "<td align=center>КБК</td>"
          "<td align=center>Дата<br>валютирования </td>"
          "<td align=center>Фамилия</td>"
          "<td align=center>Сумма </td>"
          "<td align=center>Назначение <br>платежа</td>"
          "<td align=center>Получатель </td>"
          "<td align=center>РНН<br> получателя </td>"
        "</tr><tr></tr>" skip.


for each t-tax no-lock:
       put unformatted 
        "<TR><TD>" t-tax.sqn "</TD>" skip
          "<TD >" t-tax.ssum "</TD>" skip
          "<TD >&nbsp;" t-tax.acc "</TD>" skip
          "<TD >&nbsp;" t-tax.rnn "</TD>" skip
          "<TD >&nbsp;" t-tax.kbk  "</TD>" skip
          "<TD >" t-tax.data "</TD>" skip
          "<TD >" t-tax.name "</TD>" skip
          "<TD >" t-tax.sum "</TD>" skip
          "<TD >" t-tax.nazp format "x(100)" "</TD>" skip
          "<TD >" t-tax.namebn "</TD>" skip
          "<TD >&nbsp;" t-tax.rnnbn "</TD>" skip
          "</TR>" skip.
end.


put unformatted "</table>" skip.
put unformatted "</table></body></html>" skip.
output close.
unix silent cptwin rep.html excel.exe.

