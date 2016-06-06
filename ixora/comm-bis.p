/* comm-bis.p
 * MODULE
        Коммунальные и прочие платежи 
 * DESCRIPTION
        Отправка прочих платежей по организациям
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
        07/04/2005 kanat
 * CHANGES
        24/05/06   marinav  - добавлен параметр даты факт приема платежа
*/


{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

def var ourlist as char.
def var v-users as char.

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
def var dat as date.
def var tsum as decimal.
def var tmp as char.
def var selbik as char.
def new shared var s-jh like jh.jh.
def var rcode as int.
def var rdes  as cha.
def var summa as decimal.
def var sumx as decimal.  /* для рассчета клиринг / гросс */
def var clsum as decimal.  /* сумма клиринга */
def var grsum as decimal. /* сумма гросса */
def var tmpsum as decimal.
def var cover as int init 1.
def var s_tmp_tu as char.
def var j as int NO-UNDO.

dat = g-today.
selbik = comm-bik().

update dat label ' Укажите дату ' format '99/99/9999' skip
with side-label row 5 centered frame dataa .


/* kanat - 07/04/2005 - Формирование списка для отправки Прочих платежей */
{otr-sel.i}

s_customs_arp = GET-SYSC-CHA ("CSTARP").
if s_customs_arp = ? then s_customs_arp = "".

if selarp = "" then do:
    MESSAGE "Не выбран АРП-счет." VIEW-AS ALERT-BOX TITLE "Внимание".
    return.
end.

if comm-chk(selarp,dat) then return.

/* Список подразделений TXB относящихся к текущему филиалу */
ourlist = "".
for each txb where city = seltxb and txb.visible and txb.consolid no-lock.
  ourlist = ourlist + trim(string(comm.txb.txb,">9")) + ",".
end.
ourlist = substr(ourlist, 1, length(ourlist) - 1).

/* проверка все подразделений на не зачисленные на АРП счета */
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


/* подготовим временную таблицу */
do j = 1 to num-entries (ourlist):
for each commonpl where commonpl.txb = int (entry(j, ourlist)) and commonpl.date = dat and commonpl.rmzdoc = ? and
                        commonpl.arp = selarp and commonpl.deluid = ? and 
                        commonpl.grp = selgrp no-lock:
    create tcommpl.
    buffer-copy commonpl to tcommpl.
    tcommpl.rid = rowid(commonpl).
    if commonpl.txb = seltxb then tcommpl.arp = selarp.
     			     else do:
    			     	     find first txb where txb.txb = seltxb no-lock.
	    		 	     tcommpl.arp = txb.commarp.
	    		     end.
    tcommpl.rid = rowid(commonpl). 
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

        tmp = 'Принятые ' + s_tmp_tu + 'платежи' + ', сумма ' + trim( string(summa,">>>>>>>>9.99") ) + 
              ' в тенге по реестру от ' + string(dat,"99.99.9999") + ' комиссия ' + 
               trim( string((summa * commonls.comprc), ">>>>>>>>>9.99") ) + ' тенге, в тч НДС'.


if selgrp = 9 then do: 
{others_pay.i}
end.


        if selbik = string(commonls.bikbn,"999999999") and selgrp <> 9 then do:
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

        tmp = 'Принятые платежи - ' + temp-commonls.npl + ', сумма ' + trim( string(summa,">>>>>>>>9.99") ) + 
              ' в тенге по реестру от ' + string(dat,"99.99.9999") + ' комиссия ' + 
               trim( string((summa * temp-commonls.comprc), ">>>>>>>>>9.99") ) + ' тенге, в тч НДС'.

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




        if selbik <> string(commonls.bikbn,"999999999") and selgrp <> 9 then do:

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

        tmp = 'Принятые платежи - ' + temp-commonls.npl + ', сумма ' + trim( string(summa,">>>>>>>>9.99") ) + 
              ' в тенге по реестру от ' + string(dat,"99.99.9999") + ' комиссия ' + 
               trim( string((summa * temp-commonls.comprc), ">>>>>>>>>9.99") ) + ' тенге, в тч НДС'.

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



if selgrp = 9 then do:      						/* если прочие платежи */                               
for each tcommpl, commonpl where rowid(commonpl) = tcommpl.rid:
    find first toters where toters.g = tcommpl.rid.
    assign
        commonpl.rmzdoc = toters.d.                                     /* либо jou либо rmz */
end.
end.
else do: 								/* если не прочие платежи */

if lookup(selarp, s_customs_arp) <> 0 then do:
for each tcommpl, commonpl where rowid(commonpl) = tcommpl.rid:
    find first trmz where trmz.g = tcommpl.rid.
    assign
        commonpl.rmzdoc = trmz.d.
end.
end.

if lookup(selarp, s_customs_arp) = 0 and selarp <> "010904705" then do:                                     
for each tcommpl, commonpl where rowid(commonpl) = tcommpl.rid:
    find first tdocs where tdocs.g = selarp.
    assign
        commonpl.rmzdoc = tdocs.d.
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


