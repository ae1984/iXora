/* elx_tel4.p 
 * BASES
        -bank -comm
 * MODULE
        Elecsnet
 * DESCRIPTION
        Зачисление процентов на счета организаций принятых через Элекснет
 * MENU
        5-2-1-1-4-4        
 * AUTHOR
        17/10/2006 u00124
 * CHANGES
        17/11/2006 u00124 Редактирование меню
*/

{comm-txb.i}
{get-dep.i}
def var seltxb as int                     .
def var v-taxsum as decimal               .
def var v-temp-sum as decimal             .
def var v-sumprc as decimal               .
def buffer temp-commonls for commonls.
def var v-gl-f as char                    no-undo.
def var v-gl-u as char                    no-undo.
def var v-depd as char                    no-undo.
def var v-dox as char                     no-undo. 
def var v-dep  as char                    no-undo.

seltxb = comm-cod().

{comm-arp.i} /* Проверка остатка на АРП c заданной суммой */

 {comm-chk.i}   /* Проверка незачисленных платежей на АРП по счету за дату */

{comm-com.i}

define var ctype as int.
           ctype = 1.
             /* ctype =  1 : %% организации     */
             /*       = 10 : 10 тенге для банка */

define temp-table tcommpl no-undo like commonpl
    field depd as char      
    field v-gl as char      
    field rid as rowid.

define temp-table tcom no-undo 
            field depd as char      
            field v-gl as char      
            field comdoc as int.

def shared var g-today as date.
def var dat as date.
def var tsum as decimal.
def new shared var s-jh like jh.jh.
def var summa as decimal.

def var selprc  as decimal format "9.9999".
def var selcom  as decimal format ">>>9.99".
def var selbn   as char.
def var selarp  as char format "x(9)" init "".
def var selgrp  as integer.


def buffer b-syscarp for sysc.
find last b-syscarp where b-syscarp.sysc = "ATARP" no-lock no-error.

dat = g-today.

update dat label ' Укажите дату ' format '99/99/9999' skip
with side-label row 5 centered frame dataa .


def buffer b-ktrekv for sysc.
find last b-ktrekv  where b-ktrekv.sysc  = "KTREKV" no-lock no-error.


find first sysc where sysc.sysc = 'GLCOMM' no-lock no-error.
if avail sysc then assign v-gl-u = entry(1, sysc.chval) v-gl-f = entry(2, sysc.chval).
              else do:
                  message "Не найдена настройка в SYSC 'GLCOMM'"  view-as alert-box.
                  return.
              end.



 selarp = ENTRY(1, b-ktrekv.chval).
 selprc = decimal(ENTRY(9, b-ktrekv.chval)).
 selcom = 0.
 selbn  = "ГЦТ Алматытелеком". 
 selgrp = 17.



if selarp = "" then do:
    MESSAGE "Не выбран АРП-счет." VIEW-AS ALERT-BOX TITLE "Внимание".
    return.
end.


/*if comm-chk(selarp,dat) then return. */

if ctype = 1 then do:
/*if selbn <> "АлматыТелеком Прочие" then do:*/
if selarp <> b-syscarp.chval then do:
     for each commonpl where commonpl.txb = seltxb and
                             commonpl.date = dat  and
                             commonpl.prcdoc = ? and commonpl.arp = selarp and
                             commonpl.grp = selgrp and commonpl.deluid = ?
                             no-lock:
         create tcommpl.
         buffer-copy commonpl to tcommpl.
         tcommpl.rid = rowid(commonpl).
     end.
end.
end.


for each tcommpl:
    accumulate tcommpl.sum(total).
    accumulate tcommpl.comsum(total).
end.


if ctype = 1 then
   do:
            summa = accum total tcommpl.sum.
            summa = truncate(summa * selprc, 2).
            v-temp-sum = summa.
   end.
   else

if (ctype = 1 and v-temp-sum = 0) or (ctype = 10 and summa = 0) then do:
    MESSAGE "Необработанные платежи не найдены."
    VIEW-AS ALERT-BOX TITLE "Внимание".
    return.
end.

MESSAGE "Сформировать транзакц. на сумму " summa " тенге."
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Платежи" UPDATE choice4 as logical.

    case choice4:
       when false then return.
    end.        

    choice4 = false.

    REPEAT WHILE (not comm-arp(selarp,summa)) or choice4 <> false: 
         MESSAGE "Не хватает средств на счете " + selarp + "~nПопытаться еще раз ?"
                   VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                   TITLE "Проверка остатка" UPDATE choice4.

         case choice4:
            when false then return.
         end.        
     end.

find first cods where cods.gl  = integer(v-gl-u) and cods.arc = no exclusive-lock no-error.
if avail cods then do trans: cods.lookaaa = yes. end.
find first cods where cods.gl  = integer(v-gl-f) and cods.arc = no exclusive-lock no-error.
if avail cods then do trans: cods.lookaaa = yes. end.


do transaction:
        if (ctype = 1 and summa > 0 and v-temp-sum > 0) or (ctype = 10 and summa > 0) then do:

            display "Формируется п/п на сумму: " summa format "->,>>>,>>9.99"
            with no-labels centered frame fsm.
                            

            if ctype = 1 then do:
                 run trx  (     6, 
                                summa, 
                                1,
                                '', 
                                selarp,
                                460111, /* счет % */
                                '',                            
                                "Комиссия " +
                                string (selprc * 100,">9.9") + "% за платежи " + "АО Казахтелеком", "16", '14', '840').
                 if return-value = '' then undo, return.          
                 s-jh = int(return-value).            
            end.

        end.
end.  

find first cods where cods.gl  = integer(v-gl-u) and cods.arc = no exclusive-lock no-error.
if avail cods and cods.lookaaa = yes then do trans: cods.lookaaa = no. end.
find first cods where cods.gl  = integer(v-gl-f) and cods.arc = no exclusive-lock no-error.
if avail cods and cods.lookaaa = yes then do trans: cods.lookaaa = no. end.
release cods.

do transaction:
/*if selbn <> "АлматыТелеком Прочие" then do:*/
if selarp <> b-syscarp.chval then do:
for each tcommpl, commonpl where rowid(commonpl) = tcommpl.rid:
if ctype = 1 then assign commonpl.prcdoc = return-value.
             else do:
                find tcom where tcom.depd = tcommpl.depd and tcom.v-gl = tcommpl.v-gl no-error.
                if avail tcom then commonpl.comdoc = string(tcom.comdoc).
             end.
end.
end.
else do:
   for each tcommpl, commtk where rowid(commtk) = tcommpl.rid:
       if ctype = 1 then assign commtk.prcdoc = return-value.
       else do:
            find tcom where tcom.depd = tcommpl.depd and tcom.v-gl = tcommpl.v-gl no-error.
            if avail tcom then commtk.comdoc = string(tcom.comdoc).
       end.
   end.
end.

end.
hide frame fsm.
  
















