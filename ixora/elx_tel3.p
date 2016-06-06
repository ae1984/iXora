/* elx_tel3.p 
 * BASES
        -bank -comm
 * MODULE
        Elecsnet
 * DESCRIPTION
        Формирование платежа на счет организации (Элекснет)
 * MENU
        5-2-1-1-4-3        
 * AUTHOR
        17/10/2006 u00124
 * CHANGES
        17/11/2006 u00124 Редактирование меню
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
def var selprc  as decimal format "9.9999".
def var selcom  as decimal format ">>>9.99".
def var selbn   as char.
def var selarp  as char format "x(9)" init "".
def  var selgrp  as integer.



def buffer b-syscarp for sysc.
def buffer b-ktrekv for sysc.
find last b-syscarp where b-syscarp.sysc = "ATARP" no-lock no-error.

find last b-ktrekv  where b-ktrekv.sysc  = "KTREKV" no-lock no-error.



dat = g-today.
selbik = comm-bik().

update dat label ' Укажите дату ' format '99/99/9999' skip with side-label row 5 centered frame dataa .



 selarp = ENTRY(1, b-ktrekv.chval).
 selprc = decimal(ENTRY(9, b-ktrekv.chval)).
 selcom = 0.
 selbn  = "ГЦТ Алматытелеком". 
 selgrp = 17.    







s_customs_arp = GET-SYSC-CHA ("CSTARP").
if s_customs_arp = ? then s_customs_arp = "".

if selarp = "" then do:
    MESSAGE "Не выбран АРП-счет." VIEW-AS ALERT-BOX TITLE "Внимание".
    return.
end.

/*if comm-chk(selarp,dat) then return. */


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
/*
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
end. */

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


do:

     MESSAGE "Сформировать транзакц. на сумму " (summa - (summa * selprc)) " тенге." skip "~nc ARP: " selarp "на счет: " string(ENTRY(3, b-ktrekv.chval),"999999999") " банк: " string(ENTRY(4, b-ktrekv.chval),"999999999")
       VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
       TITLE "Зачисление платежей" UPDATE choice4 as logical.

     case choice4:
        when false then return.
     end.

     choice4 = false.

      REPEAT WHILE (not comm-arp(selarp,summa - (summa * selprc))) and (not choice4):
           MESSAGE "Не хватает средств на счете " + selarp + "~nПопытаться еще раз ?"
           VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Проверка остатка" UPDATE choice4.
           case choice4:
              when true then if comm-arp(selarp,summa - (summa * selprc)) then leave. else choice4 = false.
              otherwise return.
           end.
      end.

     display "Формируется п/п на сумму: "
         (summa - (summa * selprc)) format "->,>>>,>>>,>>9.99"
         "~nКомиссия" (summa * selprc) format "->,>>>,>>>,>>9.99"
         with no-labels centered frame fsm.

       s_tmp_tu = ''.

     tmp = str_branch_name + ' ' + s_tmp_tu + 'платежи' + ', сумма ' + trim( string(summa,">>>>>>>>9.99") ) +
           ' в тенге по реестру от ' + string(dat,"99.99.9999") + ' комиссия ' +
           trim( string((summa * selprc), ">>>>>>>>>9.99") ) + ' тенге, в тч НДС'.



     do:

        do:


         if selarp <> "010904705" then do:
           sumx = summa - (summa * selprc).
           /* найдем сколько по клирингу положено */
           find first sysc where sysc.sysc = "NETGRO" no-lock no-error.
           /* клиринг */
           find first tarif2 where tarif2.num = "1" and tarif2.kod = "63" and tarif2.stat = 'r' no-lock.
           clsum = tarif2.ost.
           /* гросс */
           find first tarif2 where tarif2.num = "2" and tarif2.kod = "14" and tarif2.stat = 'r' no-lock.
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
              17,
              sumx,                   /* вся сумма полностью */
              selarp,
              ENTRY(4, b-ktrekv.chval),
              ENTRY(3, b-ktrekv.chval),
              0,                      /* KBK string(tcommpl.kb,"999999") */
              no,                     /* MB or RB   */
              ENTRY(5, b-ktrekv.chval), 
              ENTRY(2, b-ktrekv.chval), 
              ENTRY(6, b-ktrekv.chval),
              ENTRY(7, b-ktrekv.chval),
              ENTRY(8, b-ktrekv.chval),
              tmp,
              "SG",
              1,
              2,
              "",
              "",
              dat). 

              /* КЛИРИНГ */
           else do:

              /* разбросаем суммы по отдельным пачкам */
              do while sumx >= sysc.deval - 100:

                 run commpl (
                 17,
                 sysc.deval - 100,       /* ровно столько, сколько точно пройдет */
                 selarp,
                 ENTRY(4, b-ktrekv.chval),
                 ENTRY(3, b-ktrekv.chval),
                 0,                     
                 no,                    
                 ENTRY(5, b-ktrekv.chval),
                 ENTRY(2, b-ktrekv.chval),
                 ENTRY(6, b-ktrekv.chval),
                 ENTRY(7, b-ktrekv.chval),
                 ENTRY(8, b-ktrekv.chval),
                 tmp,
                 "SG",
                 1,
                 1,
                 "",
                 "",
                 dat). 

                 sumx = sumx - sysc.deval + 100. /* отрежем кусочек суммы */

              end.

              /* сбросим остаток суммы */
              run commpl (
              17,
              sumx,                   /* в sumx - сумма, оставшаяся после урезания */
              selarp,
              ENTRY(4, b-ktrekv.chval),
              ENTRY(3, b-ktrekv.chval),
              0,                      
              no,                     
              ENTRY(5, b-ktrekv.chval),
              ENTRY(2, b-ktrekv.chval),
              ENTRY(6, b-ktrekv.chval),
              ENTRY(7, b-ktrekv.chval),
              ENTRY(8, b-ktrekv.chval),
              tmp,
              "SG",
              1,
              1,
              "",
              "",
              dat). /* Плат. система */
           end.  /* clear */
         end. /* не ТОО Дана */
       end.  /* if not customs */
     end. /* if selbik <> "TXB.." */

     create tdocs.
     assign
         tdocs.g = selarp
         tdocs.d = return-value.
  end.  /*  if avail commonls */
end.  /*  if summa > 0 then ... */



    for each tcommpl, commonpl where rowid(commonpl) = tcommpl.rid:
      find first tdocs where tdocs.g = selarp.
      assign
          commonpl.rmzdoc = tdocs.d.
    end.




