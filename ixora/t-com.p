/* t-com.p
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
        14/04/06 u00600
 * CHANGES
        10/05/06 u00600 - если не находит в remtrz по полю remtrz, то ищем в remtrz.sqn
        15/08/06 u00600 - оптимизация

*/

def var seltxb as int no-undo.
def var v-namenk as char no-undo.
def var v-nazp as char no-undo.
def var v-sum as deci no-undo.
def var v-dt as date no-undo.

def temp-table t-tax no-undo
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

def var v-r as char no-undo.
def var v-name as char no-undo.

def var rid as rowid no-undo.

def var v-rnn as char format "x(12)" init '' label "Введите РНН" no-undo.
def var nk as char format "x(12)" init '' label "Налоговый комитет" no-undo.
def var kbk as char label "КБК" init '' no-undo.
def var sum1 as decimal format "z,zzz,zzz,zz9.99" label "Сумма с..." init 0 no-undo.
def var sum2 as decimal format "z,zzz,zzz,zz9.99" label "Сумма по..." init 999999999 no-undo.
def var datums as date format "99/99/9999" label "Период с..." init today no-undo.
def var datums1 as date format "99/99/9999" label "Период по..." init today no-undo.

define frame report_frame
 v-rnn skip
 nk help "F2-Выбор" skip
 kbk skip
 datums  datums1 help "Введите период отчета" skip
 sum1  sum2 help "Введите сумму" skip
 with row 5 side-labels centered.  

on help of nk in frame report_frame do:
  run rnn_nk. 
end.

displ v-rnn nk kbk datums datums1 sum1 sum2 with frame report_frame.
update v-rnn nk kbk datums datums1 sum1 sum2 with frame report_frame.

message " Отчет формируется... ".

if v-rnn <> '' then do:
do v-dt = datums to datums1.

  for each tax where tax.rnn = v-rnn no-lock use-index rnn .
    if tax.sum < sum1 or tax.sum > sum2 then next.
    if tax.date = v-dt and tax.duid = ? then do:

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
       /*else do:
         find first remtrz where substr(remtrz.sqn, 7, 10) = tax.senddoc no-lock no-error.
         if avail remtrz then assign t-tax.acc = remtrz.dracc
                                    t-tax.sqn = remtrz.t_sqn
                                    t-tax.nazp = remtrz.det[1] + remtrz.det[2] + remtrz.det[3]
                                    t-tax.data = remtrz.valdt2. 
       end.*/
  end.
  end.

  for each commonpl where commonpl.rnn = v-rnn no-lock use-index rnn.
    if commonpl.sum < sum1 or commonpl.sum > sum2 then next.
    if commonpl.date = v-dt and commonpl.deluid = ? then do:
    
    find first taxnk where taxnk.rnn = commonpl.rnnbn no-lock no-error.
         if avail taxnk then v-namenk = taxnk.name. else v-namenk = ''.       
       create t-tax.                        	
       assign t-tax.rnn = commonpl.rnn
              t-tax.kbk = commonpl.kb
              t-tax.name = commonpl.fio
              t-tax.sum = commonpl.sum
              t-tax.rnnbn = commonpl.rnnbn
              t-tax.nazp = commonpl.npl
              t-tax.namebn = v-namenk. 

       find first remtrz where remtrz.remtrz = commonpl.rmzdoc no-lock no-error.
       if avail remtrz then  assign t-tax.acc = remtrz.dracc
                                    t-tax.sqn = remtrz.t_sqn
                                    t-tax.data = remtrz.valdt2.
  end.
  end.

end.
end.
else do:
do v-dt = datums to datums1.
  for each tax where tax.date = v-dt and tax.duid = ? /*and (tax.sum  ge sum1 and tax.sum le sum2)*/ and
      (string(tax.kb) = kbk or kbk = '') and (tax.rnn_nk = nk or nk = '') no-lock.
   if tax.sum < sum1 or tax.sum > sum2 then next.

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

       /*else do:
         find first remtrz where substr(remtrz.sqn, 7, 10) = tax.senddoc no-lock no-error.
         if avail remtrz then assign t-tax.acc = remtrz.dracc
                                    t-tax.sqn = remtrz.t_sqn
                                    t-tax.nazp = remtrz.det[1] + remtrz.det[2] + remtrz.det[3]
                                    t-tax.data = remtrz.valdt2. 
       end.*/
  end.

  for each commonpl where commonpl.date = v-dt and commonpl.deluid = ? and
    (commonpl.kb = integer(kbk) or kbk = '') and (commonpl.rnnbn = nk or nk = '') no-lock.
    if commonpl.sum < sum1 or commonpl.sum > sum2 then next.

    find first taxnk where taxnk.rnn = commonpl.rnnbn no-lock no-error.
         if avail taxnk then v-namenk = taxnk.name. else v-namenk = ''.       
       create t-tax.                        	
       assign t-tax.rnn = commonpl.rnn
              t-tax.kbk = commonpl.kb
              t-tax.name = commonpl.fio
              t-tax.sum = commonpl.sum
              t-tax.rnnbn = commonpl.rnnbn
              t-tax.nazp = commonpl.npl
              t-tax.namebn = v-namenk. 

       find first remtrz where remtrz.remtrz = commonpl.rmzdoc no-lock no-error.
       if avail remtrz then assign t-tax.acc = remtrz.dracc
                                   t-tax.sqn = remtrz.t_sqn
                                   t-tax.data = remtrz.valdt2.

  end.

end.
end.

def buffer b-tax for t-tax.
v-sum = 0.

for each t-tax break by t-tax.sqn.
 
    if last-of (t-tax.sqn) then do:
       for each remtrz where remtrz.valdt2 = t-tax.data and remtrz.t_sqn = t-tax.sqn no-lock.
           v-sum = v-sum + remtrz.amt .
       end.
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
    "<br><P align=""left"" style=""font:bold"">Документы по налоговым платежам с расшифровкой <br>"
     " За период с " string(datums, "99/99/9999") " по "  string(datums1, "99/99/9999") " </P>" skip.


put  unformatted     
         "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
          "<TR align=""center"" style=""font:bold"">" skip
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
          "<TD >" t-tax.nazp "</TD>" skip
          "<TD >" t-tax.namebn "</TD>" skip
          "<TD >&nbsp;" t-tax.rnnbn "</TD>" skip
          "</TR>" skip.
end.


put unformatted "</table>" skip.
put unformatted "</table></body></html>" skip.
output close.

unix silent cptwin rep.html excel.exe.

pause 0.

Procedure rnn_nk.
 DEFINE QUERY q1 FOR taxnk.
 def browse b1 
    query q1 no-lock
    display 
        taxnk.rnn label "РНН"  format "x(12)"
        taxnk.name  label "Наименование" format 'x(35)'
        with no-labels 15 down title "Налоговые комитеты".
 def frame fr1 
    b1
    with centered overlay view-as dialog-box.
    
 on return of b1 in frame fr1
    do: 
      rid = rowid(taxnk).
      find first taxnk where rowid(taxnk) = rid no-lock no-error.

       assign
        v-r = taxnk.rnn
        v-name = taxnk.name
        no-error.

    	update nk :screen-value    = v-r with frame report_frame.

       apply "endkey" to frame fr1.
    end.  
                    
 open query q1 for each taxnk no-lock.

   b1:SET-REPOSITIONED-ROW (7, "CONDITIONAL").
   ENABLE all with frame fr1.
   apply "value-changed" to b1 in frame fr1.
   WAIT-FOR endkey of frame fr1.
 hide frame fr1.
 return "ok".
end.
