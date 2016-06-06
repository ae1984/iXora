/* comprtrp.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Отчет по принятым коммунальным платежам за период
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.2.10.10.12
 * AUTHOR
        10.10.2003 sasco
 * BASES
        BANK COMM
 * CHANGES
        13/10/2003 sasco Вывод кол-ва квитанций налоговых вместо кол-ва отдельных КБК
        13/10/2003 sasco Запрос на учет квитанций по коммунальным платежам
        15/10/2003 sasco Прочие платежи (из пенсионных) не анализируются
        17.10.2003 sasco Переделал налоговые
        23.10.2003 sasco Учет прочих платежей
        14.11.2003 sasco Удаленные платежи, которые удалил не кассир, теперь не учитываются
        15.07.2004 kanat Добавил вывод дубликатов в отчете
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        10.05,2005 kanat Добавил обработку социальных платежей
        20.10.2005 dpuchkov - добавил информацию о менеджере который выдал дубликат
        31.08.2006 dpuchkov добавил вывод удаленных прочих платежей Алматытелеком
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/


{get-dep.i}
{comm-txb.i}
{gl-utils.i}

def shared var g-today as date.

define variable xdub_num as integer init 0.
define variable luid as character initial "".
define variable ldnum as integer initial 0.
define variable ltime as integer initial 0.
define variable ckv as int.
define variable ckv_dup as int.

define variable seltxb as integer.
define variable take_comm as logical format "да/нет" initial no.

define temp-table tmp
            field ofc     as character
            field name as character
            field rko     as integer
            field depart  as character

            field numall  as integer
            field numkvi  as integer
            field numdel  as integer
            field numprt  as integer
            field numdup  as integer

            field sumall  as decimal
            field sumkvi  as decimal
            field sumdel  as decimal
            field sumprt  as decimal
            field sumdup  as decimal
            field swho    as char

            index idx_tmp is primary name.

define variable dt1 as date.
define variable dt2 as date.

seltxb = comm-cod().

dt1 = g-today.
dt2 = g-today.

update dt1 label "Начальная дата" dt2 label "Конечная дата" with row 2 centered overlay frame dt1.
message "Учитывать платежи ИВЦ/Алсеко/Водоканал, АлмаТВ, Казтелеком?" update take_comm.

displ "Ждите... 0%" with row 6 centered no-label overlay frame waitfr0.
pause 0.

/* ---------------------------------------------------------------------------- */

find first tarif2 where tarif2.num = "1" and tarif2.kod = "10"
                    and tarif2.stat = 'r' no-lock no-error.

if take_comm then
for each almatv where almatv.txb = seltxb and
                      almatv.dtfk >= dt1 and
                      almatv.dtfk <= dt2
                      no-lock:

   if almatv.deluid <> ? and almatv.deluid <> almatv.uid then next.

   find tmp where tmp.ofc = almatv.uid no-error.
   if not available tmp then do:

      create tmp.
      tmp.ofc = LOWER (almatv.uid).
      tmp.rko = get-dep (almatv.uid, almatv.dtfk).

      find ppoint where ppoint.point = 1 and ppoint.depart = tmp.rko no-lock no-error.
      tmp.depart = CAPS (ppoint.name).

      find ofc where ofc.ofc = almatv.uid no-lock no-error.
      tmp.name = CAPS (ofc.name).

   end.

   ckv = ?.
   ckv = integer (almatv.chval[5]) no-error.
   if ckv = ? then ckv = 0.

   tmp.numall = tmp.numall + 1.
   tmp.sumall = tmp.sumall + almatv.summfk.

   tmp.numprt = tmp.numprt + ckv.
   tmp.sumprt = tmp.sumprt + (ckv * almatv.summfk).

   tmp.numdup = 0.
   tmp.sumdup = 0.

   if almatv.deluid = ? then do:
          tmp.numkvi = tmp.numkvi + 1.
          tmp.sumkvi = tmp.sumkvi + almatv.summfk.
   end.
   else do:
          tmp.numdel = tmp.numdel + 1.
          tmp.sumdel = tmp.sumdel + almatv.summfk.
   end.

end.

displ "Ждите... 25%" with row 6 centered no-label overlay frame waitfr1.
pause 0.

/* ---------------------------------------------------------------------------- */
for each p_f_payment where p_f_payment.txb = seltxb and
                           p_f_payment.date >= dt1 and
                           p_f_payment.date <= dt2 and
                           (take_comm or p_f_payment.cod <> 400)
                           no-lock:

   if p_f_payment.deluid <> ? and p_f_payment.deluid <> p_f_payment.uid then next.

   find tmp where tmp.ofc = p_f_payment.uid no-error.
   if not available tmp then do:

      create tmp.
      tmp.ofc = LOWER (p_f_payment.uid).
      tmp.rko = get-dep (p_f_payment.uid, p_f_payment.date).

      find ppoint where ppoint.point = 1 and ppoint.depart = tmp.rko no-lock no-error.
      tmp.depart = CAPS (ppoint.name).

      find ofc where ofc.ofc = p_f_payment.uid no-lock no-error.
      tmp.name = CAPS (ofc.name).
xdub_num = 0.
for each dbl where dbl.dt = p_f_payment.date and dbl.dnum = p_f_payment.dnum and dbl.rnn = p_f_payment.rnn and dbl.sum = p_f_payment.amt no-lock:
    find last ofc where ofc.ofc = dbl.who no-lock no-error.
    if avail ofc then do:
       tmp.swho = tmp.swho + ofc.name  + "<br>" .
       xdub_num = xdub_num + 1.
    end.
end.

   end.

   ckv = ?.
   ckv = integer (p_f_payment.chval[5]) no-error.
   if ckv = ? then ckv = 0.

   ckv_dup = ?.
   ckv_dup = integer (p_f_payment.chval[4]) no-error.
   if ckv_dup = ? then ckv_dup = 0.

   tmp.numall = tmp.numall + 1.
   tmp.sumall = tmp.sumall + p_f_payment.amt.

   tmp.numprt = tmp.numprt + ckv.
   tmp.sumprt = tmp.sumprt + (ckv * p_f_payment.amt).

ckv_dup = xdub_num.
   tmp.numdup = tmp.numdup + ckv_dup.
   tmp.sumdup = tmp.sumdup + (ckv_dup * tarif2.ost).

   if p_f_payment.deluid = ? then do:
          tmp.numkvi = tmp.numkvi + 1.
          tmp.sumkvi = tmp.sumkvi + p_f_payment.amt.
   end.
   else do:
          tmp.numdel = tmp.numdel + 1.
          tmp.sumdel = tmp.sumdel + p_f_payment.amt.
   end.

end.


displ "Ждите... 50%" with row 6 centered no-label overlay frame waitfr2.
pause 0.

/* ---------------------------------------------------------------------------- */

for each commonpl where commonpl.txb = seltxb and
                        commonpl.date >= dt1 and
                        commonpl.date <= dt2 and
                        commonpl.grp <> 15
                        no-lock break by commonpl.dnum:

if commonpl.deluid <> ? and commonpl.deluid <> commonpl.uid then next.

   if not take_comm then
      if commonpl.grp = 3 or commonpl.grp = 5 or commonpl.grp = 6 or commonpl.grp = 7 or commonpl.grp = 8
         then next.

   find commonls where commonls.txb = seltxb and
                       commonls.grp = commonpl.grp and
                       commonls.type = commonpl.type and
                       commonls.visible = yes
                       no-lock no-error.

   find tmp where tmp.ofc = commonpl.uid no-error.
   if not available tmp then do:

      create tmp.
      tmp.ofc = LOWER (commonpl.uid).
      tmp.rko = get-dep (commonpl.uid, commonpl.date).

      find ppoint where ppoint.point = 1 and ppoint.depart = tmp.rko no-lock no-error.
      tmp.depart = CAPS (ppoint.name).

      find ofc where ofc.ofc = commonpl.uid no-lock no-error.
      tmp.name = CAPS (ofc.name).

   end.

   ckv = ?.
   ckv = integer (commonpl.chval[5]) no-error.
   if ckv = ? then ckv = 0.

xdub_num = 0.
for each dbl where dbl.dt = commonpl.date and dbl.dnum = commonpl.dnum and dbl.rnn = commonpl.rnn and dbl.sum = commonpl.sum no-lock:
    find last ofc where ofc.ofc = dbl.who no-lock no-error.
    if avail ofc then do:
       tmp.swho = tmp.swho + ofc.name  + "<br>" .
        xdub_num = xdub_num + 1.
    end.
end.


   ckv_dup = ?.
   ckv_dup = integer (commonpl.chval[4]) no-error.

   if ckv_dup = ? then ckv_dup = 0.

   tmp.numall = tmp.numall + 1.
   tmp.sumall = tmp.sumall + commonpl.sum.

   tmp.numprt = tmp.numprt + ckv.
   tmp.sumprt = tmp.sumprt + (ckv * commonpl.sum).

ckv_dup = xdub_num.
   tmp.numdup = tmp.numdup + ckv_dup.
   tmp.sumdup = tmp.sumdup + (ckv_dup * tarif2.ost).


   if commonpl.deluid = ? then do:
          tmp.numkvi = tmp.numkvi + 1.
          tmp.sumkvi = tmp.sumkvi + commonpl.sum.
   end.
   else do:
          tmp.numdel = tmp.numdel + 1.
          tmp.sumdel = tmp.sumdel + commonpl.sum.
   end.
end.
































for each commtk where commtk.txb = seltxb and
                        commtk.date >= dt1 and
                        commtk.date <= dt2 and
                        commtk.grp <> 15
                        no-lock break by commtk.dnum:

if commtk.deluid <> ? and commtk.deluid <> commtk.uid then next.

   if not take_comm then
      if commtk.grp = 3 or commtk.grp = 5 or commtk.grp = 6 or commtk.grp = 7 or commtk.grp = 8
         then next.

   find commonls where commonls.txb = seltxb and
                       commonls.grp = commtk.grp and
                       commonls.type = commtk.type and
                       commonls.visible = yes
                       no-lock no-error.

   find tmp where tmp.ofc = commtk.uid no-error.
   if not available tmp then do:

      create tmp.
      tmp.ofc = LOWER (commtk.uid).
      tmp.rko = get-dep (commtk.uid, commtk.date).

      find ppoint where ppoint.point = 1 and ppoint.depart = tmp.rko no-lock no-error.
      tmp.depart = CAPS (ppoint.name).

      find ofc where ofc.ofc = commtk.uid no-lock no-error.
      tmp.name = CAPS (ofc.name).

   end.

   ckv = ?.
   ckv = integer (commtk.chval[5]) no-error.
   if ckv = ? then ckv = 0.

xdub_num = 0.
for each dbl where dbl.dt = commtk.date and dbl.dnum = commtk.dnum and dbl.rnn = commtk.rnn and dbl.sum = commtk.sum no-lock:
    find last ofc where ofc.ofc = dbl.who no-lock no-error.
    if avail ofc then do:
       tmp.swho = tmp.swho + ofc.name  + "<br>" .
        xdub_num = xdub_num + 1.
    end.
end.


   ckv_dup = ?.
   ckv_dup = integer (commtk.chval[4]) no-error.

   if ckv_dup = ? then ckv_dup = 0.

   tmp.numall = tmp.numall + 1.
   tmp.sumall = tmp.sumall + commtk.sum.

   tmp.numprt = tmp.numprt + ckv.
   tmp.sumprt = tmp.sumprt + (ckv * commtk.sum).

ckv_dup = xdub_num.
   tmp.numdup = tmp.numdup + ckv_dup.
   tmp.sumdup = tmp.sumdup + (ckv_dup * tarif2.ost).


   if commtk.deluid = ? then do:
          tmp.numkvi = tmp.numkvi + 1.
          tmp.sumkvi = tmp.sumkvi + commtk.sum.
   end.
   else do:
          tmp.numdel = tmp.numdel + 1.
          tmp.sumdel = tmp.sumdel + commtk.sum.
   end.
end.
















/* социальные платежи */

for each commonpl where commonpl.txb = seltxb and
                        commonpl.date >= dt1 and
                        commonpl.date <= dt2 and
                        commonpl.grp = 15
                        no-lock break by commonpl.dnum:

if commonpl.deluid <> ? and commonpl.deluid <> commonpl.uid then next.

   find commonls where commonls.txb = seltxb and
                       commonls.grp = commonpl.grp and
                       commonls.type = commonpl.type and
                       commonls.visible = no
                       no-lock no-error.

   find tmp where tmp.ofc = commonpl.uid no-error.
   if not available tmp then do:

      create tmp.
      tmp.ofc = LOWER (commonpl.uid).
      tmp.rko = get-dep (commonpl.uid, commonpl.date).

      find ppoint where ppoint.point = 1 and ppoint.depart = tmp.rko no-lock no-error.
      tmp.depart = CAPS (ppoint.name).

      find ofc where ofc.ofc = commonpl.uid no-lock no-error.
      tmp.name = CAPS (ofc.name).

   end.

   ckv = ?.
   ckv = integer (commonpl.chval[5]) no-error.
   if ckv = ? then ckv = 0.
   ckv_dup = 0.

   tmp.numall = tmp.numall + 1.
   tmp.sumall = tmp.sumall + commonpl.sum.

   tmp.numprt = tmp.numprt + ckv.
   tmp.sumprt = tmp.sumprt + (ckv * commonpl.sum).

   tmp.numdup = tmp.numdup + ckv_dup.
   tmp.sumdup = tmp.sumdup + (ckv_dup * tarif2.ost).

   if commonpl.deluid = ? then do:
          tmp.numkvi = tmp.numkvi + 1.
          tmp.sumkvi = tmp.sumkvi + commonpl.sum.
   end.
   else do:
          tmp.numdel = tmp.numdel + 1.
          tmp.sumdel = tmp.sumdel + commonpl.sum.
   end.
end.


displ "Ждите... 75%" with row 6 centered no-label overlay frame waitfr3.
pause 0.


/* ---------------------------------------------------------------------------- */

for each tax where tax.txb = seltxb and
                   tax.date >= dt1 and
                   tax.date <= dt2
                   no-lock
                   by tax.uid by tax.dnum by tax.created:

   if tax.duid <> ? and tax.duid <> tax.uid then next.

   find tmp where tmp.ofc = tax.uid no-error.
   if not available tmp then do:

      create tmp.
      tmp.ofc = LOWER (tax.uid).
      tmp.rko = get-dep (tax.uid, tax.date).

      find ppoint where ppoint.point = 1 and ppoint.depart = tmp.rko no-lock no-error.
      tmp.depart = CAPS (ppoint.name).

      find ofc where ofc.ofc = tax.uid no-lock no-error.
      tmp.name = CAPS (ofc.name).

   end.

xdub_num = 0.
for each dbl where dbl.dt = tax.date and dbl.dnum = tax.dnum and dbl.rnn = tax.rnn and dbl.sum = tax.sum no-lock:
    find last ofc where ofc.ofc = dbl.who no-lock no-error.
    if avail ofc then do:
       tmp.swho = tmp.swho + ofc.name  + "<br>" .
       xdub_num = xdub_num + 1.
    end.
end.

   ckv = ?.
   ckv = integer (tax.chval[5]) no-error.
   if ckv = ? then ckv = 0.

   ckv_dup = ?.
   ckv_dup = integer (tax.chval[4]) no-error.
   if ckv_dup = ? then ckv_dup = 0.
ckv_dup = xdub_num.

   tmp.sumall = tmp.sumall + tax.sum.
   tmp.sumprt = tmp.sumprt + (tax.sum * ckv).
   tmp.sumdup = tmp.sumdup + (ckv_dup * tarif2.ost).

   if tax.duid = ? then assign tmp.sumkvi = tmp.sumkvi + tax.sum.
                   else assign tmp.sumdel = tmp.sumdel + tax.sum.

   if tax.uid <> luid or tax.dnum <> ldnum or tax.created <> ltime
   then do:
        assign luid = tax.uid
               ldnum = tax.dnum
               ltime = tax.created.

        assign tmp.numall = tmp.numall + 1
               tmp.numprt = tmp.numprt + ckv
               tmp.numdup = tmp.numdup + ckv_dup.


        if tax.duid = ? then tmp.numkvi = tmp.numkvi + 1.
                        else tmp.numdel = tmp.numdel + 1.
   end.

end.

displ "Ждите...100% ... " skip "Формирование файла..." with row 6 centered no-label overlay frame waitfr4.
pause 0.

find first tmp no-error.
if not available tmp then do:
   message "Нет информации о платежах за период!" view-as alert-box title ' '.
   return.
end.

/* -------------------------------------------------------------- */

output to comprt.htm.

{html-title.i
 &title = "Отчет по принятым платежам"
 &size-add = "1"
}

put unformatted SUBSTITUTE ("<H1> Отчет о платежах за период с &1 по &2 </H1>", dt1, dt2) SKIP.

if not take_comm then put unformatted "<H3> (Без учета коммунальных платежей) </H3>" SKIP.
                 else put unformatted "<H3> (С учетом коммунальных платежей) </H3>" SKIP.

put unformatted "<table cellpadding=""5"" style=""font-size:14px"" border=""1""><tr>" skip
                "<td rowspan=""2"" bgcolor=""#C0C0C0""> Кассир (ФИО) </td>" skip
                "<td rowspan=""2"" bgcolor=""#C0C0C0""> Логин </td>" skip
                "<td colspan=""2"" bgcolor=""#C0C0C0""> Принято платежей </td>" skip
                "<td colspan=""2"" bgcolor=""#C0C0C0""> Удалено платежей </td>" skip
                "<td colspan=""2"" bgcolor=""#C0C0C0""> Итого платежей </td>" skip
                "<td colspan=""2"" bgcolor=""#C0C0C0""> Распечатано </td>" skip
                "<td colspan=""2"" bgcolor=""#C0C0C0""> Дубликатов </td>" skip

                "<td rowspan=""2"" bgcolor=""#C0C0C0""> Фамилия <br> менеджера </td>" skip

                "<td rowspan=""2"" bgcolor=""#C0C0C0""> СПФ </td>" skip
                "</tr><tr>" skip
                "<td bgcolor=""#C0C0C0""> Количество </td>" skip
                "<td bgcolor=""#C0C0C0""> На сумму </td>" skip
                "<td bgcolor=""#C0C0C0""> Количество </td>" skip
                "<td bgcolor=""#C0C0C0""> На сумму </td>" skip
                "<td bgcolor=""#C0C0C0""> Количество </td>" skip
                "<td bgcolor=""#C0C0C0""> На сумму </td>" skip
                "<td bgcolor=""#C0C0C0""> Количество </td>" skip
                "<td bgcolor=""#C0C0C0""> На сумму </td>" skip
                "<td bgcolor=""#C0C0C0""> Количество </td>" skip
                "<td bgcolor=""#C0C0C0""> На сумму </td>" skip
                "</tr>" skip.

for each tmp:
    put unformatted "<tr>".
    put unformatted "<td> " tmp.name "</td>" skip
                    "<td> " tmp.ofc "</td>" skip

                    "<td> " tmp.numkvi "</td>" skip
                    "<td> " XLS-NUMBER (tmp.sumkvi) "</td>" skip

                    "<td> " tmp.numdel "</td>" skip
                    "<td> " XLS-NUMBER (tmp.sumdel) "</td>" skip

                    "<td> " tmp.numall "</td>" skip
                    "<td> " XLS-NUMBER (tmp.sumall) "</td>" skip

                    "<td> " tmp.numprt "</td>" skip
                    "<td> " XLS-NUMBER (tmp.sumprt) "</td>" skip

                    "<td> " tmp.numdup "</td>" skip
                    "<td> " XLS-NUMBER (tmp.sumdup) "</td>" skip

                    "<td> " tmp.swho "</td>" skip



                    "<td> " tmp.depart "</td>" skip


                    "</tr>" skip.

    delete tmp.
end.

/* -------------------------------------------------------------- */

put unformatted "</table>" skip.
{html-end.i}
output close.

UNIX SILENT VALUE ("cptwin comprt.htm excel").
UNIX SILENT VALUE ("rm -f comprt.htm").

hide frame waitfr4.  pause 0.
hide frame waitfr3.  pause 0.
hide frame waitfr2.  pause 0.
hide frame waitfr1.  pause 0.
hide frame waitfr0.  pause 0.
hide frame dt1.      pause 0.


