/* comm-cif.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
     07.07.03 kanat добавил новый параметр при вызове процедуры commpl - РНН плательщика для таможенных платежей, по - умолчанию ставятся пустые кавычки
              csts_pay.i - кусок программы, где происходит зачисление таможенных платежей
     08.07.03 kanat в csts_pay.i внес изменения по обработке КБК при зачислении таможенных платежей
     16.07.03 kanat для таможенных платежей в номер пачки для remtrz.sqn в commpl передается номер квитанции
     30.07.03 kanat добавил новый параметр при вызове commpl - ФИО плательщика у которого РНН = 000000000000
     29.12.03 kanat платежи за 31.12.2003 не отправляются
     01.14.04 kanat добавил передачу в платежное поручение номера КТС для таможенных платежей (dockts)
     02.24.04 kanat добавил end из cstms_pay.i.
     05.03.04 kanat добавил временную обработку прочих платежей. Прочие платежи будут далее обрабатываться в отдельной процедуре.
     14.03.04 kanat добавил проверку прочих платежей по группе получателей.
     08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
     23.02.2005 kanat добавил отдельную обработку платежей ТОО Дана по типам платежей
     25.02.2005 kanat добавил доп. условия по типам платежей
     28.02.2005 kanat добавил поле в temp-table tdana
     02.03.2005 kanat добавил обработку платежей клиентам банка для ТОО Дана ит.д.
     25.03.2005 kanat перекомпиляция
     30.03.2005 kanat перекомпиляция
     25/04/2005 kanat добавил обработку районной таможни
     26/04/2005 kanat добавил проверки по счетам АРП районной таможни
     01/07/2005 sasco проверка на 190501914
     07/04/2005 kanat Формирование списка для отправки платежей без Алсеко, ИВЦ, АПК, Прочих платежей
     14/03/2006 kanat добавил название филиала
     24/05/06   marinav  - добавлен параметр даты факт приема платежа
     27.07.2006 dpuchkov - добавил обработку прочих платежей Алматытелеком.
     10.08.2006 dpuchkov - вынес АРП по прочим платежам в SYSC
     07.07.2007 id00004  - убрал ненужную информацию.

*/


{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().
def var str_branch_name as char no-undo.

def var ourlist as char  no-undo.
def var v-users as char  no-undo.

{comm-arp.i} /* Проверка остатка на АРП c заданной суммой */
{comm-chk.i} /* Проверка незачисленных платежей на АРП по счету за дату */
{comm-bik.i}
{sysc.i}
{yes-no.i}

define buffer temp-commonls for commonls.

define temp-table tcommpl like commonpl
    field rid as rowid.

define temp-table temp-comp like commonpl
    field rid as rowid.

define temp-table tdocs
    field g like commonpl.arp
    field d like commonpl.rmzdoc
    index g is primary unique g.



define temp-table trmz
    field g as rowid
    field d as char
    index g is primary unique g.



define temp-table toters
    field g as rowid
    field d as char
    index g is primary unique g.


define temp-table tdana
    field t as integer
    field d as char
    index t is primary unique t.

def var i_doc_count as integer init 0.
def var s_customs_arp as char.



def shared var g-today as date.
def var dat as date                     no-undo.
def var tsum as decimal                 no-undo.
def var tmp as char                     no-undo.
def var selbik as char                  no-undo.
def new shared var s-jh like jh.jh.
def var rcode as int                    no-undo.
def var rdes  as cha                    no-undo.
def var summa as decimal                no-undo.
def var sumx as decimal                 no-undo.  /* для рассчета клиринг / гросс */
def var clsum as decimal                no-undo.  /* сумма клиринга */
def var grsum as decimal                no-undo.  /* сумма гросса   */
def var tmpsum as decimal               no-undo.
def var cover as int init 1             no-undo.
def var s_tmp_tu as char                no-undo.
def var j as int                        no-undo.


def buffer b-syscarp for sysc.
find last b-syscarp where b-syscarp.sysc = "ATARP" no-lock no-error.

dat = g-today.
selbik = comm-bik().

update dat label ' Укажите дату ' format '99/99/9999' skip
with side-label row 5 centered frame dataa .

/* kanat - 07/04/2005 - Формирование списка для отправки платежей без Алсеко, ИВЦ, АПК, Прочих платежей */
{comm-fel.i}

s_customs_arp = GET-SYSC-CHA ("CSTARP").
if s_customs_arp = ? then s_customs_arp = "".

if selarp = "" then do:
    MESSAGE "Не выбран АРП-счет." VIEW-AS ALERT-BOX TITLE "Внимание".
    return.
end.

if comm-chk(selarp,dat) then return.
find first txb no-lock where txb.consolid and txb.txb = seltxb.
if avail txb then
  str_branch_name = txb.info.
else
  str_branch_name = 'Новый Филиал'.

/* Список подразделений TXB относящихся к текущему филиалу */
ourlist = "".
for each txb where city = seltxb and txb.visible and txb.consolid no-lock.
  ourlist = ourlist + trim(string(comm.txb.txb,">9")) + ",".
end.
ourlist = substr(ourlist, 1, length(ourlist) - 1).

/* проверка все подразделений на не зачисленные на АРП счета */

/*if selbn <> "АлматыТелеком Прочие" then do:*/
if selarp <> b-syscarp.chval then do:
         do j = 1 to num-entries (ourlist):
           find first commonpl where commonpl.deluid = ? and commonpl.date = dat and commonpl.joudoc = ? and
                                   commonpl.txb = int(entry(j, ourlist)) and commonpl.grp = selgrp no-lock no-error.

           if avail commonpl then do:
             for each commonpl no-lock where commonpl.deluid = ? and commonpl.date = dat and
                     commonpl.joudoc = ? and commonpl.txb = int(entry(j, ourlist)) and commonpl.grp = selgrp break by commonpl.uid:

                if first-of(commonpl.uid) then
                  v-users = "~n" + commonpl.uid + "(TXB" + string(commonpl.txb,"99") + ")" + v-users.
             end.
                
             MESSAGE "Есть платежи, не зачисленные на транз. счета" +
             "~nКассиры: " + v-users VIEW-AS ALERT-BOX TITLE "Внимание".
             return.
           end.
         end.
end.
else do:
       do j = 1 to num-entries (ourlist):
         find first commtk where commtk.deluid = ? and commtk.date = dat and commtk.joudoc = ? and
                                 commtk.txb = int(entry(j, ourlist)) and commtk.grp = selgrp no-lock no-error.

         if avail commtk then do:
           for each commtk no-lock where commtk.deluid = ? and commtk.date = dat and
                   commtk.joudoc = ? and commtk.txb = int(entry(j, ourlist)) and commtk.grp = selgrp break by commtk.uid:

              if first-of(commtk.uid) then
                v-users = "~n" + commtk.uid + "(TXB" + string(commtk.txb,"99") + ")" + v-users.
           end.
              
           MESSAGE "Есть платежи, не зачисленные на транз. счета" +
           "~nКассиры: " + v-users VIEW-AS ALERT-BOX TITLE "Внимание".
           return.
         end.
       end.
end.

/* подготовим временную таблицу */
do j = 1 to num-entries (ourlist):
/* if selbn <> "АлматыТелеком Прочие" then do: */
if selarp <> b-syscarp.chval then do:
  for each commonpl where commonpl.txb = int (entry(j, ourlist)) and commonpl.date = dat and commonpl.rmzdoc = ? and
                        commonpl.arp = selarp and commonpl.deluid = ? and
                        commonpl.grp = selgrp no-lock:
    create tcommpl.
    buffer-copy commonpl to tcommpl.
    tcommpl.rid = rowid(commonpl).
    if commonpl.txb = seltxb then
      tcommpl.arp = selarp.
    else do:
      find first txb where txb.txb = seltxb no-lock.
      tcommpl.arp = txb.commarp.
    end.
    tcommpl.rid = rowid(commonpl).
  end.
end.
else do:
    for each commtk where commtk.txb = int (entry(j, ourlist)) and commtk.date = dat and commtk.rmzdoc = ? and
                          commtk.arp = selarp and commtk.deluid = ? and
                          commtk.grp = selgrp no-lock:
      create tcommpl.
      buffer-copy commtk to tcommpl.
      tcommpl.rid = rowid(commtk).
      if commtk.txb = seltxb then
        tcommpl.arp = selarp.
      else do:
        find first txb where txb.txb = seltxb no-lock.
        tcommpl.arp = txb.commarp.
      end.
      tcommpl.rid = rowid(commtk).
    end.
end.

end.

/* итоговая сумма */
for each tcommpl:
  accumulate tcommpl.sum(total).
end.

summa = (accum total tcommpl.sum).

if summa > 0 then do:



   hide frame fsm.


   /* настройка организации - из текущего подразделения - якобы "центральный офис" */
   find first commonls where commonls.txb = seltxb and commonls.arp = selarp and
              commonls.visible = yes and commonls.grp = selgrp no-lock use-index type.

   if avail commonls then do:

     MESSAGE "Сформировать транзакц. на сумму " (summa - (summa * selprc)) " тенге." skip "~nc ARP: " selarp "на счет: " string(commonls.iik,"999999999") " банк: " string(commonls.bikbn,"999999999")
       VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
       TITLE "Зачисление платежей" UPDATE choice4 as logical.

     case choice4:
        when false then return.
     end.

     choice4 = false.

      REPEAT WHILE (not comm-arp(selarp,summa - (summa * commonls.comprc))) and (not choice4):
           MESSAGE "Не хватает средств на счете " + selarp + "~nПопытаться еще раз ?"
           VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Проверка остатка" UPDATE choice4.
           case choice4:
              when true then if comm-arp(selarp,summa - (summa * commonls.comprc)) then leave. else choice4 = false.
              otherwise return.
           end.
      end.

     display "Формируется п/п на сумму: "
         (summa - (summa * commonls.comprc)) format "->,>>>,>>>,>>9.99"
         "~nКомиссия" (summa * commonls.comprc) format "->,>>>,>>>,>>9.99"
         with no-labels centered frame fsm.

     if commonls.rnnbn = '600700012225' or commonls.iik = 000144933 then
       s_tmp_tu = 'залоговые '.
     else
       s_tmp_tu = ''.

     tmp = str_branch_name + ' ' + s_tmp_tu + 'платежи' + ', сумма ' + trim( string(summa,">>>>>>>>9.99") ) +
           ' в тенге по реестру от ' + string(dat,"99.99.9999") + ' комиссия ' +
           trim( string((summa * commonls.comprc), ">>>>>>>>>9.99") ) + ' тенге, в тч НДС'.


     if selgrp = 9 and selarp <> "003904301" then do:
       {others_pay.i}
     end.


     if selbik = string(commonls.bikbn,"999999999") and (selgrp <> 9 or (selgrp = 9 and selarp = "003904301")) then do:
       if selarp = "010904705" then do:
         for each tcommpl where tcommpl.txb = seltxb and tcommpl.arp = "010904705" and tcommpl.grp = 1 no-lock break by tcommpl.type.
           accumulate tcommpl.sum (sub-total by tcommpl.type).
           if last-of (tcommpl.type) then do:

             summa = (accum sub-total by tcommpl.type tcommpl.sum).
             sumx = summa - (summa * selprc).

             find first temp-commonls where temp-commonls.txb = seltxb and
                                       temp-commonls.grp = tcommpl.grp and
                                       temp-commonls.arp = tcommpl.arp and
                                       temp-commonls.type = tcommpl.type no-lock no-error.

             tmp = str_branch_name + ' платежи - ' + temp-commonls.npl + ', сумма ' + trim( string(summa,">>>>>>>>9.99") ) +
                   ' в тенге по реестру от ' + string(dat,"99.99.9999") + ' комиссия ' +
                   trim( string((summa * temp-commonls.comprc), ">>>>>>>>>9.99") ) + ' тенге, в тч НДС'  .

             /*
             string(summa - (summa * selprc)) + "|" +
             */

             s-jh = 0.
             run trxgen("ALX0005", "|",
             string(sumx) + "|" +
             selarp + "|" +
             string(temp-commonls.iik,"999999999") + "|" +
             tmp +
             "|" + substring(temp-commonls.kod,1,1) +
             "|" + substring(temp-commonls.kbe,1,1) +
             "|" + substring(temp-commonls.kod,2,1) +
             "|" + substring(temp-commonls.kbe,2,1) +
             "|" + temp-commonls.knp,
             "cif", "",
             output rcode,
             output rdes,
             input-output s-jh).

             if rcode ne 0 then do:
                message " Ошибка проводки rcode = " + string(rcode) + ":" +
                rdes + " " + string(s-jh). pause.
                return.
             end.

             create tdana.
             assign
                 tdana.t = tcommpl.type
                 tdana.d = return-value.
             run vou_bank(2).
             run jl-stmp.
           end.
         end.
       end.
       else do:
            s-jh = 0.
            run trxgen("ALX0005", "|",
            string(summa - (summa * selprc)) + "|" +
            selarp + "|" +
            string(commonls.iik,"999999999") + "|" +
            tmp +
            "|" + substring(commonls.kod,1,1) +
            "|" + substring(commonls.kbe,1,1) +
            "|" + substring(commonls.kod,2,1) +
            "|" + substring(commonls.kbe,2,1) +
            "|" + commonls.knp,
            "cif", "",
            output rcode,
            output rdes,
            input-output s-jh).

            if rcode ne 0 then do :
                message " Ошибка проводки rcode = " + string(rcode) + ":" +
                rdes + " " + string(s-jh). pause.
                return.
            end.
            run vou_bank(2).

            run jl-stmp.

       end.
     end.  /* commonls.bikbn <> selbik ... */



     if selbik <> string(commonls.bikbn,"999999999") and (selgrp <> 9 or (selgrp = 9 and selarp = "003904301") ) then do:

       /*--------------------------------- Проверка для таможенного управления для внешних платежей ----------------------------------*/
       if lookup (selarp, s_customs_arp) > 0 then do:
                  {cstms_pay.i}
       end.
       else do:
       /*-----------------------------------------------------------------------------------------------------------------------------*/

         if selarp <> "010904705" then do:

           sumx = summa - (summa * selprc).

           /* найдем сколько по клирингу положено */
           find first sysc where sysc.sysc = "NETGRO" no-lock no-error.

           /* клиринг */
           find first tarif2 where tarif2.num = "1" and tarif2.kod = "63"
                               and tarif2.stat = 'r' no-lock.
           clsum = tarif2.ost.

           /* гросс */
           find first tarif2 where tarif2.num = "2" and tarif2.kod = "14"
                               and tarif2.stat = 'r' no-lock.
           grsum = tarif2.ost + clsum.

           /* скока клирингов влезет */
           tmpsum = sumx / (sysc.deval - 100).

           /*  рассчет  выгодности  клиринга  с  точки  зрения  */
           /* необходимости гросса согласно установленным тарифам */
           if  ( if tmpsum - trunc (tmpsum, 0) <> 0 then
                     trunc (tmpsum, 0) + 1 else tmpsum ) * clsum > grsum
                   then cover = 2. /* GROSS */
                   else cover = 1. /* CLEAR */

           /* ГРОСС */
           if cover = 2 then

              run commpl (
              commonls.grp,
              sumx,                   /* вся сумма полностью */
              selarp,
              if commonls.bikbn = 190501914 then 'TXB00' else string(commonls.bikbn),
              commonls.iik,
              0,                      /* KBK string(tcommpl.kb,"999999") */
              no,                     /* MB or RB   */
              trim(commonls.bn),      /* name */
              commonls.rnnbn,         /* rnn_nk     */
              commonls.knp,
              commonls.kod,
              commonls.kbe,
              tmp,
              if seltxb = 0 then commonls.que else "1P",
              commonls.kolprn,
              if commonls.bikbn = 190501914 then 5 else 2,
              "",
              "",
              dat). /* Плат. система */

              /* КЛИРИНГ */
           else do:

              /* разбросаем суммы по отдельным пачкам */
              do while sumx >= sysc.deval - 100:

                 run commpl (
                 commonls.grp,
                 sysc.deval - 100,       /* ровно столько, сколько точно пройдет */
                 selarp,
                 if commonls.bikbn = 190501914 then 'TXB00' else string(commonls.bikbn),
                 commonls.iik,
                 0,                      /* KBK string(tcommpl.kb,"999999") */
                 no,                     /* MB or RB   */
                 trim(commonls.bn),      /* name */
                 commonls.rnnbn,         /* rnn_nk     */
                 commonls.knp,
                 commonls.kod,
                 commonls.kbe,
                 tmp,
                 if seltxb = 0 then commonls.que else "1P",
                 commonls.kolprn,
                 if commonls.bikbn = 190501914 then 5 else 1,
                 "",
                 "",
                 dat). /* Плат. система */

                 sumx = sumx - sysc.deval + 100. /* отрежем кусочек суммы */

              end.

              /* сбросим остаток суммы */
              run commpl (
              commonls.grp,
              sumx,                   /* в sumx - сумма, оставшаяся после урезания */
              selarp,
              if commonls.bikbn = 190501914 then 'TXB00' else string(commonls.bikbn),
              commonls.iik,
              0,                      /* KBK string(tcommpl.kb,"999999") */
              no,                     /* MB or RB   */
              trim(commonls.bn),      /* name */
              commonls.rnnbn,         /* rnn_nk     */
              commonls.knp,
              commonls.kod,
              commonls.kbe,
              tmp,
              if seltxb = 0 then commonls.que else "1P",
              commonls.kolprn,
              if commonls.bikbn = 190501914 then 5 else 1,
              "",
              "",
              dat). /* Плат. система */
           end.  /* clear */
         end. /* не ТОО Дана */
         else do:   /* ТОО Дана */
           /*-----------------------------------------------------------------------------------------------------------------*/
           for each tcommpl where tcommpl.txb = seltxb and tcommpl.arp = "010904705" and tcommpl.grp = 1 no-lock break by tcommpl.type.
             accumulate tcommpl.sum (sub-total by tcommpl.type).
             if last-of (tcommpl.type) then do:
               summa = (accum sub-total by tcommpl.type tcommpl.sum).
               sumx = summa - (summa * selprc).

               find first temp-commonls where temp-commonls.txb = seltxb and
                                   temp-commonls.grp = tcommpl.grp and
                                   temp-commonls.arp = tcommpl.arp and
                                   temp-commonls.type = tcommpl.type no-lock no-error.

               tmp = str_branch_name + ' платежи - ' + temp-commonls.npl + ', сумма ' + trim( string(summa,">>>>>>>>9.99") ) +
                 ' в тенге по реестру от ' + string(dat,"99.99.9999") + ' комиссия ' +
               trim( string((summa * temp-commonls.comprc), ">>>>>>>>>9.99") ) + ' тенге, в тч НДС' .

               /* найдем сколько по клирингу положено */
               find first sysc where sysc.sysc = "NETGRO" no-lock no-error.

               /* клиринг */
               find first tarif2 where tarif2.num = "1" and tarif2.kod = "63"
                                 and tarif2.stat = 'r' no-lock.
               clsum = tarif2.ost.

               /* гросс */
               find first tarif2 where tarif2.num = "2" and tarif2.kod = "14"
                                 and tarif2.stat = 'r' no-lock.
               grsum = tarif2.ost + clsum.

               /* скока клирингов влезет */
               tmpsum = sumx / (sysc.deval - 100).

               /*  рассчет  выгодности  клиринга  с  точки  зрения  */
               /* необходимости гросса согласно установленным тарифам */
               if  ( if tmpsum - trunc (tmpsum, 0) <> 0 then
                       trunc (tmpsum, 0) + 1 else tmpsum ) * clsum > grsum
                     then cover = 2. /* GROSS */
                     else cover = 1. /* CLEAR */

               /* ГРОСС */
               if cover = 2 then do:

                 run commpl (
                 temp-commonls.grp,
                 sumx,                   /* вся сумма полностью */
                 selarp,
                 if temp-commonls.bikbn = 190501914 then 'TXB00' else string(temp-commonls.bikbn),
                 temp-commonls.iik,
                 0,                      /* KBK string(tcommpl.kb,"999999") */
                 no,                     /* MB or RB   */
                 trim(temp-commonls.bn),      /* name */
                 temp-commonls.rnnbn,         /* rnn_nk     */
                 temp-commonls.knp,
                 temp-commonls.kod,
                 temp-commonls.kbe,
                 tmp,
                 if seltxb = 0 then temp-commonls.que else "1P",
                 temp-commonls.kolprn,
                 if temp-commonls.bikbn = 190501914 then 5 else 2,
                 "",
                 "",
                 dat). /* Плат. система */

               end.
               /* КЛИРИНГ */
               else do:

                 /* разбросаем суммы по отдельным пачкам */
                 do while sumx >= sysc.deval - 100:

                   run commpl (
                   temp-commonls.grp,
                   sysc.deval - 100,       /* ровно столько, сколько точно пройдет */
                   selarp,
                   if temp-commonls.bikbn = 190501914 then 'TXB00' else string(temp-commonls.bikbn),
                   temp-commonls.iik,
                   0,                      /* KBK string(tcommpl.kb,"999999") */
                   no,                     /* MB or RB   */
                   trim(temp-commonls.bn),      /* name */
                   temp-commonls.rnnbn,         /* rnn_nk     */
                   temp-commonls.knp,
                   temp-commonls.kod,
                   temp-commonls.kbe,
                   tmp,
                   if seltxb = 0 then temp-commonls.que else "1P",
                   if temp-commonls.bikbn = 190501914 then 5 else temp-commonls.kolprn,
                   1,
                   "",
                   "",
                   dat). /* Плат. система */

                   sumx = sumx - sysc.deval + 100. /* отрежем кусочек суммы */

                 end.

                 /* сбросим остаток суммы */

                 run commpl (
                 temp-commonls.grp,
                 sumx,                   /* в sumx - сумма, оставшаяся после урезания */
                 selarp,
                 if temp-commonls.bikbn = 190501914 then 'TXB00' else string(temp-commonls.bikbn),
                 temp-commonls.iik,
                 0,                      /* KBK string(tcommpl.kb,"999999") */
                 no,                     /* MB or RB   */
                 trim(temp-commonls.bn),      /* name */
                 temp-commonls.rnnbn,         /* rnn_nk     */
                 temp-commonls.knp,
                 temp-commonls.kod,
                 temp-commonls.kbe,
                 tmp,
                 if seltxb = 0 then temp-commonls.que else "1P",
                 temp-commonls.kolprn,
                 if temp-commonls.bikbn = 190501914 then 5 else 1,
                 "",
                 "",
                 dat). /* Плат. система */
               end.  /* clear */

               create tdana.
               assign
                 tdana.t = tcommpl.type
                 tdana.d = return-value.


             end. /* last of type ...  */
           end. /* for each tcommpl break by tcommpl.type ...  */
           /*-----------------------------------------------------------------------------------------------------------------*/
         end.
       end.  /* if not customs */
     end. /* if selbik <> "TXB.." */

     create tdocs.
     assign
         tdocs.g = selarp
         tdocs.d = return-value.

  end.  /*  if avail commonls */
  else do:  /*Зачем это нужно было ? :))*/
       MESSAGE "Необработанные платежи не найдены."
       VIEW-AS ALERT-BOX TITLE "Внимание".
       return.
  end.
end.  /*  if summa > 0 then ... */

if selgrp = 9 and selarp <> "003904301" then do:                                                  /* если прочие платежи */
  for each tcommpl, commonpl where rowid(commonpl) = tcommpl.rid:
    find first toters where toters.g = tcommpl.rid.
    assign
        commonpl.rmzdoc = toters.d.                                     /* либо jou либо rmz */
  end.
end.
else do:                                                                /* если не прочие платежи */

  if lookup(selarp, s_customs_arp) <> 0 then do:
    for each tcommpl, commonpl where rowid(commonpl) = tcommpl.rid:
      find first trmz where trmz.g = tcommpl.rid.
      assign
          commonpl.rmzdoc = trmz.d.
    end.
  end.

  if lookup(selarp, s_customs_arp) = 0 and selarp <> "010904705" then do:
/* if selbn <> "АлматыТелеком Прочие" then do: */
if selarp <> b-syscarp.chval then do:
    for each tcommpl, commonpl where rowid(commonpl) = tcommpl.rid:
      find first tdocs where tdocs.g = selarp.
      assign
          commonpl.rmzdoc = tdocs.d.
    end.
end.
else
do:
    for each tcommpl, commtk where rowid(commtk) = tcommpl.rid:
      find first tdocs where tdocs.g = selarp.
      assign
          commtk.rmzdoc = tdocs.d.
    end.
end.
  end.

  if selarp = "010904705" then do:
    for each tcommpl, commonpl where rowid(commonpl) = tcommpl.rid:
      find first tdana where tdana.t = tcommpl.type.
      assign
         commonpl.rmzdoc = tdana.d.
    end.
  end.
end.
