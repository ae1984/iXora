/* comdelrp.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Отчет по удаленным платежам за период
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
        25.09.2003 sasco
 * CHANGES
        08.10.2003 sasco Переделал отчет на "удаленные" и "все"
        15.10.2003 sasco Проверка на commonpl.type <> 0
        23.10.2003 sasco Убрал проверку на не пустую причину удаления платежа
        14.07.2004 kanat Добавил вывод дубликатов в отчете 
        10.05.2005 kanat - Для социальных платежей chval[4] используется для других целей
        31.08.2006 dpuchkov добавил вывод удаленных прочих платежей Алматытелеком
*/


{gl-utils.i}
{get-dep.i}
{comm-txb.i}

def var seltxb as integer.
seltxb = comm-cod().

def var dt1 as date.
def var dt2 as date.
def shared var g-today as date.
    
dt1 = g-today.
dt2 = g-today.

define variable why as character initial "Неправильный РНН,Неправильная сумма,Повторно набранный платеж,Другая причина".
define variable reptype as character initial "1".

def var v-depart as integer.

update dt1 label "Начальная дата" dt2 label "Конечная дата" with centered frame df.

do while true on endkey undo, return:
   message "Отчет: (1) Удаленные платежи, (2) Удаления + изменения" update reptype.
   if reptype = "1" or reptype = "2" then leave.
end.

define temp-table tmp
            field rko     as integer
            field sub     as character 
            field name    as character 

            field uid     like tax.uid
            field dnum    like tax.dnum
            field date    like tax.date
            field ctime   as integer
            
            field kb      like tax.kb
            field sum0    like tax.sum
            field sum     like tax.sum
            field comsum  like tax.comsum
            field rnn     like tax.rnn
            field rnnnk   like tax.rnn_nk
            field accnt   like commonpl.accnt
            field counter like commonpl.counter
            field dubcnt  as integer

            field deluid  like tax.duid
            field deltime as integer
            
            field newdnum as integer 
            field newdate as date 
            field p-why   as character 

            index idx_tmp is primary sub rko date uid dnum.


for each commonpl where commonpl.txb = seltxb and 
                        commonpl.date >= dt1 and 
                        commonpl.date <= dt2 and
                        commonpl.deluid <> ? and 
                        commonpl.grp <> 15
                        no-lock:
find first commonls where commonls.txb = seltxb and 
                       commonls.grp = commonpl.grp and 
                       commonls.type = commonpl.type and 
                       commonls.visible
                       no-lock no-error.
   if available commonls then do:
   if reptype = "1" then if lookup (commonpl.delwhy, why) = 0 and not (commonpl.delwhy begins entry(4, why, ',')) then next.

   if commonpl.uid <> "epdadm" then do: 
   v-depart = get-dep (commonpl.uid, commonpl.date).

   create tmp.
   assign tmp.rko = v-depart
          tmp.sub = "COM"
          tmp.name = commonls.bn
          tmp.uid = commonpl.uid
          tmp.dnum = commonpl.dnum
          tmp.date = commonpl.date
          tmp.ctime = commonpl.cretime
          tmp.sum = commonpl.sum
          tmp.comsum = commonpl.comsum
          tmp.rnn = commonpl.rnn
          tmp.accnt = commonpl.accnt
          tmp.counter = commonpl.counter
          tmp.deltime = commonpl.deltime
          tmp.deluid = commonpl.deluid
          tmp.p-why = commonpl.delwhy
          tmp.newdnum = commonpl.deldnum
          tmp.dubcnt = integer(commonpl.chval[4])
          tmp.newdate = commonpl.deldate.
          if tmp.deltime = ? then tmp.deltime = tmp.ctime + 100.
   end.
   end.
end.






for each commtk where commtk.txb = seltxb and 
                        commtk.date >= dt1 and 
                        commtk.date <= dt2 and
                        commtk.deluid <> ? and 
                        commtk.grp <> 15
                        no-lock:
find first commonls where commonls.txb = seltxb and 
                       commonls.grp = commtk.grp and 
                       commonls.type = commtk.type and 
                       commonls.visible
                       no-lock no-error.
   if available commonls then do:
   if reptype = "1" then if lookup (commtk.delwhy, why) = 0 and not (commtk.delwhy begins entry(4, why, ',')) then next.

   if commtk.uid <> "epdadm" then do: 
   v-depart = get-dep (commtk.uid, commtk.date).

   create tmp.
   assign tmp.rko = v-depart
          tmp.sub = "COM"
          tmp.name = commonls.bn
          tmp.uid = commtk.uid
          tmp.dnum = commtk.dnum
          tmp.date = commtk.date
          tmp.ctime = commtk.cretime
          tmp.sum = commtk.sum
          tmp.comsum = commtk.comsum
          tmp.rnn = commtk.rnn
          tmp.accnt = commtk.accnt
          tmp.counter = commtk.counter
          tmp.deltime = commtk.deltime
          tmp.deluid = commtk.deluid
          tmp.p-why = commtk.delwhy
          tmp.newdnum = commtk.deldnum
          tmp.dubcnt = integer(commtk.chval[4])
          tmp.newdate = commtk.deldate.
          if tmp.deltime = ? then tmp.deltime = tmp.ctime + 100.
   end.
   end.
end.











for each commonpl where commonpl.txb = seltxb and 
                        commonpl.date >= dt1 and 
                        commonpl.date <= dt2 and
                        commonpl.deluid <> ? and 
                        commonpl.grp = 15
                        no-lock:
 find first commonls where commonls.txb = seltxb and 
                       commonls.grp = commonpl.grp and 
                       commonls.type = commonpl.type and 
                       commonls.visible = no
                       no-lock no-error.
   if available commonls then do:

   if commonpl.uid <> "epdadm" then do:
   v-depart = get-dep (commonpl.uid, commonpl.date).
   create tmp.
   assign tmp.rko = v-depart
          tmp.sub = "COM"
          tmp.name = commonls.bn
          tmp.uid = commonpl.uid
          tmp.dnum = commonpl.dnum
          tmp.date = commonpl.date
          tmp.ctime = commonpl.cretime
          tmp.sum = commonpl.sum
          tmp.comsum = commonpl.comsum
          tmp.rnn = commonpl.rnn
          tmp.accnt = commonpl.accnt
          tmp.counter = commonpl.counter
          tmp.deltime = commonpl.deltime
          tmp.deluid = commonpl.deluid
          tmp.p-why = commonpl.delwhy
          tmp.newdnum = commonpl.deldnum
          tmp.dubcnt = integer(commonpl.chval[5]).
          tmp.newdate = commonpl.deldate.
          if tmp.deltime = ? then tmp.deltime = tmp.ctime + 100.
   end.
   end.
end.


/* -------------------------------------------------------------- */

for each tax where tax.txb = seltxb and 
                   tax.date >= dt1 and 
                   tax.date <= dt2 and
                   tax.duid <> ?
                   no-lock:

   if reptype = "1" then if lookup (tax.delwhy, why) = 0 and not (tax.delwhy begins entry(4, why, ',')) then next.
/*   if tax.delwhy = "" or tax.delwhy = ? then next. */

   if tax.uid <> "epdadm" then do:
   v-depart = get-dep (tax.uid, tax.date).

   create tmp.
   assign tmp.rko = v-depart
          tmp.sub = "TAX"
          tmp.name = "Налоговые платежи"
          tmp.uid = tax.uid
          tmp.dnum = tax.dnum
          tmp.date = tax.date
          tmp.ctime = tax.created
          tmp.sum = tax.sum
          tmp.comsum = tax.comsum
          tmp.rnnnk = tax.rnn_nk
          tmp.kb = tax.kb
          tmp.rnn = tax.rnn
          tmp.deltime = tax.deltime
          tmp.deluid = tax.duid
          tmp.p-why = tax.delwhy
          tmp.newdnum = tax.deldnum
          tmp.dubcnt = integer(tax.chval[4])
          tmp.newdate = tax.deldate.
          if tmp.deltime = ? then tmp.deltime = tmp.ctime + 100.
   end.
end.


/* -------------------------------------------------------------- */

for each almatv where almatv.txb = seltxb and 
                      almatv.dtfk >= dt1 and 
                      almatv.dtfk <= dt2 and
                      almatv.deluid <> ?
                      no-lock:
/*
   if reptype = "1" then if lookup (almatv.delwhy, why) = 0 and not (almatv.delwhy begins entry(4, why, ',')) then next.
   if almatv.delwhy = "" or almatv.delwhy = ? then next. */

   if almatv.uid <> "epdadm" then do:
   v-depart = get-dep (almatv.uid, almatv.dtfk).

   create tmp.
   assign tmp.rko = v-depart
          tmp.sub = "ATV"
          tmp.name = "Платежи Alma TV"
          tmp.uid = almatv.uid
          tmp.dnum = almatv.ndoc
          tmp.accnt = almatv.accnt
          tmp.date = almatv.dtfk
          tmp.sum0 = almatv.summ
          tmp.sum = almatv.summfk
          tmp.ctime = almatv.cretime
          tmp.comsum = 0
          tmp.deltime = almatv.deltime
          tmp.deluid = almatv.deluid
          tmp.p-why = almatv.delwhy
          tmp.newdnum = almatv.deldnum
          tmp.dubcnt = 0
          tmp.newdate = almatv.deldate.
          if tmp.deltime = ? then tmp.deltime = tmp.ctime + 100.
   end.
end.


/* -------------------------------------------------------------- */

for each p_f_payment where p_f_payment.txb = seltxb and 
                           p_f_payment.date >= dt1 and 
                           p_f_payment.date <= dt2 and
                           p_f_payment.deluid <> ?
                           no-lock:
/*
   if reptype = "1" then if lookup (p_f_payment.delwhy, why) = 0 and not (p_f_payment.delwhy begins entry(4, why, ',')) then next.
   if p_f_payment.delwhy = "" or p_f_payment.delwhy = ? then next. */

   if p_f_payment.uid <> "epdadm" then do:
   v-depart = get-dep (p_f_payment.uid, p_f_payment.date).

   create tmp.
   assign tmp.rko = v-depart
          tmp.sub = "PEN"
          tmp.name = "Пенсионные и прочие платежи"
          tmp.uid = p_f_payment.uid
          tmp.dnum = p_f_payment.dnum
          tmp.date = p_f_payment.date
          tmp.ctime = 0
          tmp.sum = p_f_payment.amt
          tmp.comsum = p_f_payment.comiss
          tmp.rnnnk = p_f_payment.distr
          tmp.rnn = p_f_payment.rnn
          tmp.deltime = p_f_payment.deltime
          tmp.deluid = p_f_payment.deluid
          tmp.p-why = p_f_payment.delwhy
          tmp.newdnum = p_f_payment.deldnum
          tmp.dubcnt = integer(p_f_payment.chval[4])
          tmp.newdate = p_f_payment.deldate.
          if tmp.deltime = ? then tmp.deltime = tmp.ctime + 100.
    end.
end.


/* -------------------------------------------------------------- */

for each tmp break by tmp.sub by tmp.name by tmp.rko:

    if first-of (tmp.sub) then do:

       output to value (tmp.sub + ".htm").

       case tmp.sub:
            when "COM" then do:
                           {html-title.i
                            &title = "Коммунальные платежи"
                            &size-add = "1"
                           }
                       end.
            when "TAX" then do:
                           {html-title.i
                            &title = "Налоговые платежи"
                            &size-add = "1"
                           }
                       end.
            when "PEN" then do:
                           {html-title.i
                            &title = "Пенсионные платежи"
                            &size-add = "1"
                           }
                       end.

            when "ATV" then do:
                           {html-title.i
                            &title = "Платежи Alma TV"
                            &size-add = "1"
                           }
                       end.
       end case.

       put unformatted SUBSTITUTE ("<H1> Отчет об удаленных платежах за период с &1 по &2 </H1>", dt1, dt2) SKIP.

    end.

    if first-of (tmp.name) then do: 
       put unformatted "<H2>" CAPS (tmp.name) "</H2>" SKIP.
    end.

    if first-of (tmp.rko) then do: 
       find ppoint where ppoint.point = 1 and ppoint.depart = tmp.rko no-lock no-error.
       put unformatted "<H3>" CAPS (ppoint.name) "</H3>" SKIP.
       put unformatted "<table cellpadding=""5"" style=""font-size:14px"" border=""1""><tr>" skip.

       put unformatted "<td bgcolor=""#C0C0C0""> Дата </td>".

       if tmp.sub = "ATV" then put unformatted "<td bgcolor=""#C0C0C0""> Контракт </td><td bgcolor=""#C0C0C0""> Счет-извещение </td>".
                          else put unformatted "<td bgcolor=""#C0C0C0""> Номер документа </td>".

       put unformatted (if tmp.sub = "PEN" then " " 
                                           else "<td bgcolor=""#C0C0C0""> Время </td>")
                       "<td bgcolor=""#C0C0C0""> Логин </td>"
                       "<td bgcolor=""#C0C0C0""> Кассир (ФИО) </td>"
                       (if tmp.sub <> "ATV" then "<td bgcolor=""#C0C0C0""> Сумма </td>  <td bgcolor=""#C0C0C0""> Комиссия </td>  <td bgcolor=""#C0C0C0""> РНН </td> <td bgcolor=""#C0C0C0"">" 
                                            else "<td bgcolor=""#C0C0C0""> Выставленная сумма </td>  <td bgcolor=""#C0C0C0""> Фактически оплачено </td>" )
                       .

       if tmp.sub = "COM" then put unformatted "Лицевой счет </td> <td bgcolor=""#C0C0C0"">Номер </td> <td bgcolor=""#C0C0C0"">".
       if tmp.sub = "TAX" then put unformatted "РНН НК </td> <td bgcolor=""#C0C0C0""> КБК </td> <td bgcolor=""#C0C0C0"">".
       if tmp.sub = "ATV" then put unformatted " ".
       if tmp.sub = "PEN" then put unformatted "РНН Пенсионного Фонда </td> <td bgcolor=""#C0C0C0"">".

       put unformatted "Кто удалил </td>"
                       "<td bgcolor=""#C0C0C0""> Время удаления </td>"
                       "<td bgcolor=""#C0C0C0""> Причина удаления </td>"
                       "<td bgcolor=""#C0C0C0""> Новый документ </td>"
                       "<td bgcolor=""#C0C0C0""> За дату </td>" 
                       "<td bgcolor=""#C0C0C0""> Дубликаты </td>" SKIP.
       put unformatted "</tr>" skip.
    end.

 
    find ofc where ofc.ofc = tmp.uid no-lock no-error.
    put unformatted "<tr><td>" tmp.date 
                    (if tmp.sub = "ATV" then ("</td><td>" + string(tmp.dnum, "zzzzzzzzzzz9") + "</td><td>" + string(tmp.accnt, "zzzzzzzzzzz9") + "</td><td>") 
                                        else ("</td><td>" + string(tmp.dnum, "zzzzzzzzzzz9") + "</td><td>"))
                    (if tmp.sub = "PEN" then (" ")
                                        else (string (tmp.ctime, "HH:MM:SS") + "</td><td>"))
                    tmp.uid "</td><td>" ofc.name "</td><td>" 
                    (if tmp.sub <> "ATV" then (XLS-NUMBER (tmp.sum) + "</td><td>" + XLS-NUMBER (tmp.comsum) + "</td><td>`" + tmp.rnn + "</td><td>")
                                         else (XLS-NUMBER (tmp.sum0) + "</td><td>" + XLS-NUMBER (tmp.sum) + "</td><td>")).

    if tmp.sub = "COM" then put unformatted tmp.accnt "</td><td>" tmp.counter "</td><td>".
    if tmp.sub = "TAX" then put unformatted "`" tmp.rnnnk "</td><td>" tmp.kb "</td><td>".
    if tmp.sub = "ATV" then put unformatted " ".
    if tmp.sub = "PEN" then put unformatted "`" tmp.rnnnk "</td><td>".

    put unformatted tmp.deluid "</td><td>" 
                    string (tmp.deltime, "HH:MM:SS") "</td><td>"
                    tmp.p-why "</td><td>".

    if tmp.newdnum ne ? then put unformatted tmp.newdnum "</td><td>" tmp.newdate "</td><td>" SKIP.
                        else put unformatted "&nbsp; </td><td> &nbsp; </td><td>" SKIP.

    put unformatted string (tmp.dubcnt) "</tr>".

    if last-of (tmp.rko) then do: 
       put unformatted "</table>" SKIP.
    end.

    if last-of (tmp.sub) then do:
       {html-end.i}
       output close.
       UNIX SILENT VALUE ("cptwin " + tmp.sub + ".htm excel").
       UNIX SILENT VALUE ("rm -f " + tmp.sub + ".htm").
    end.

end.

hide frame dt1.
